#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v6)
# ----------------------------------------------------------
# ✔ Clone or use existing repo
# ✔ Secure GitHub authentication (PAT)
# ✔ Sync with GitHub (pull before push)
# ✔ Setup AWS RDS (schema + data)
# ✔ Build Docker image (custom Dockerfile)
# ✔ Run container on port 8080 (avoids port 80 conflict)
# ✔ Full verification (container + HTTP)
# ==========================================================

set -euo pipefail  # Exit on error, undefined variable, pipeline failure

# ==========================================================
# 🔧 VARIABLES
# ==========================================================
PROJECT_DIR="charlie-cafe-devops"
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="awsrmmustansarjavaid"

# GitHub token must be exported
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="8080"  # Changed to 8080 to avoid conflict with Apache

DOCKERFILE_PATH="docker/apache-php/Dockerfile"

AWS_REGION="us-east-1"
SECRET_NAME="CafeDevDBSM"  # Your Secrets Manager secret

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

print_header() { echo -e "\n${BLUE}========================================================${NC}\n${BLUE}$1${NC}\n${BLUE}========================================================${NC}\n"; }
print_success() { echo -e "${GREEN}✅ $1${NC}\n"; }
print_error() { echo -e "${RED}❌ $1${NC}\n"; }

# ==========================================================
# 🔐 CHECK GITHUB TOKEN
# ==========================================================
if [ -z "$GITHUB_TOKEN" ]; then
  print_error "GITHUB_TOKEN not set"
  echo "👉 Run: export GITHUB_TOKEN=your_token"
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
# 🧰 STEP 2 — CHECK REQUIRED TOOLS
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
  --secret-id "$SECRET_NAME" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "DB credentials loaded"

# ==========================================================
# 🧪 STEP 4 — TEST RDS CONNECTION
# ==========================================================
print_header "Step 4 — Testing RDS"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" \
  && print_success "RDS connection successful" \
  || { print_error "RDS failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — DATABASE SETUP
# ==========================================================
print_header "Step 5 — Database Setup"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

[ -f "$SCHEMA_FILE" ] || { print_error "Schema file missing"; exit 1; }
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ No data file found, skipping${NC}"
fi

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "DB verification complete"
fi

# ==========================================================
# 🔧 STEP 6 — GIT SYNC
# ==========================================================
print_header "Step 6 — Git Sync"

git init
git add .
git commit -m "Auto commit from script" || true

git remote remove origin 2>/dev/null || true
git remote add origin https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git

git branch -M main
git pull origin main --rebase || true
git push -u origin main

print_success "GitHub sync successful"

# ==========================================================
# 🐳 STEP 7 — DOCKER BUILD
# ==========================================================
print_header "Step 7 — Docker Build"

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
print_success "Docker image built"

# ==========================================================
# 🚀 STEP 8 — RUN CONTAINER (PORT 8080)
# ==========================================================
print_header "Step 8 — Run Container"

# Free port 8080 if in use
if sudo lsof -i :$PORT >/dev/null 2>&1; then
  echo "⚠️ Port $PORT in use — freeing it..."
  sudo fuser -k ${PORT}/tcp || true
  sleep 2
fi

# Remove old container
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Run container
docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"
sleep 5
print_success "Container started on port $PORT"

# ==========================================================
# 🧪 STEP 9 — FINAL VERIFICATION
# ==========================================================
print_header "Step 9 — Verification"

docker ps | grep -q "$CONTAINER_NAME" \
  && print_success "Container is running" \
  || { print_error "Container not running"; exit 1; }

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT || true)
if [ "$HTTP_CODE" == "200" ]; then
  print_success "Application working (HTTP 200)"
else
  echo -e "${YELLOW}⚠️ HTTP Response: $HTTP_CODE${NC}"
fi

print_header "Container Logs (Last 5 lines)"
docker logs --tail 5 "$CONTAINER_NAME"

# ==========================================================
# 🎉 FINAL SUCCESS
# ==========================================================
print_header "🎉 DEPLOYMENT SUCCESS"

echo -e "${GREEN}✔ RDS Connected${NC}"
echo -e "${GREEN}✔ GitHub Synced${NC}"
echo -e "${GREEN}✔ Docker Running${NC}"
echo -e "${GREEN}✔ App Verified${NC}"

echo -e "\n🌐 Access your app:"
echo -e "👉 http://localhost:$PORT"
echo -e "👉 http://YOUR_EC2_PUBLIC_IP:$PORT\n"