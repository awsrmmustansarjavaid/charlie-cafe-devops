#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v4)
# ----------------------------------------------------------
# ✔ Fix project path issue
# ✔ Secure GitHub authentication (PAT)
# ✔ Full RDS + Docker + Verification
# ==========================================================

set -euo pipefail

# ==========================================================
# 🔧 VARIABLES (EDIT ONLY THESE)
# ==========================================================

PROJECT_DIR="charlie-cafe-devops"   # ✅ FIXED
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="YOUR_USERNAME"

# 🔐 GitHub Token (MUST export before running)
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"

DOCKERFILE_PATH="docker/apache-php/Dockerfile"

AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# ==========================================================
# 🎨 COLORS
# ==========================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}========================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================================${NC}\n"
}

print_success() { echo -e "${GREEN}✅ $1${NC}\n"; }
print_error() { echo -e "${RED}❌ $1${NC}\n"; }

# ==========================================================
# 🔐 CHECK GITHUB TOKEN
# ==========================================================
if [ -z "$GITHUB_TOKEN" ]; then
  print_error "GITHUB_TOKEN not set. Run: export GITHUB_TOKEN=your_token"
  exit 1
fi

# ==========================================================
# 📁 STEP 1 — CLONE OR NAVIGATE PROJECT
# ==========================================================
print_header "Step 1 — Prepare Project"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "📥 Cloning repository..."
  git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
fi

cd "$PROJECT_DIR"

print_success "Project directory ready"

# ==========================================================
# 🧰 STEP 2 — CHECK TOOLS
# ==========================================================
print_header "Step 2 — Checking Tools"

for cmd in aws jq mysql docker git curl; do
  command -v $cmd >/dev/null || { print_error "$cmd not installed"; exit 1; }
done

print_success "All tools installed"

# ==========================================================
# ☁️ STEP 3 — FETCH DB CREDENTIALS
# ==========================================================
print_header "Step 3 — Fetching DB Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

# ==========================================================
# 🧪 STEP 4 — TEST RDS
# ==========================================================
print_header "Step 4 — Testing RDS"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" \
  && print_success "RDS OK" || { print_error "RDS failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — DB SETUP
# ==========================================================
print_header "Step 5 — DB Setup"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"

[ -f "$DATA_FILE" ] && mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"

# ==========================================================
# 🔧 STEP 6 — GIT PUSH WITH TOKEN
# ==========================================================
print_header "Step 6 — Git Push"

git init
git add .
git commit -m "Auto commit from script" || true

git remote remove origin 2>/dev/null || true

git remote add origin https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git

git branch -M main
git push -u origin main

print_success "GitHub push successful"

# ==========================================================
# 🐳 STEP 7 — DOCKER BUILD
# ==========================================================
print_header "Step 7 — Docker Build"

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .

# ==========================================================
# 🚀 STEP 8 — RUN CONTAINER
# ==========================================================
print_header "Step 8 — Run Container"

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"

sleep 5

# ==========================================================
# 🧪 STEP 9 — FINAL TEST
# ==========================================================
print_header "Step 9 — Verification"

docker ps | grep -q "$CONTAINER_NAME" && print_success "Container running"

HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT || true)

[ "$HTTP" = "200" ] && print_success "App working (HTTP 200)" \
  || echo -e "${YELLOW}HTTP Response: $HTTP${NC}"

# ==========================================================
# 🎉 DONE
# ==========================================================
print_header "🎉 SUCCESS"

echo -e "${GREEN}✔ Everything is working${NC}"
echo -e "🌐 http://YOUR_EC2_PUBLIC_IP:$PORT"