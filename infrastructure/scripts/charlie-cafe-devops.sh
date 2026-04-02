#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v8)
# ==========================================================

set -euo pipefail

# ==========================================================
# 🔧 VARIABLES
# ==========================================================
PROJECT_DIR="charlie-cafe-devops"
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="awsrmmustansarjavaid"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"

DOCKERFILE_PATH="docker/apache-php/Dockerfile"

AWS_REGION="us-east-1"
SECRET_NAME="CafeDevDBSM"

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
# 🔧 STEP 0 — EC2 BOOTSTRAP (FIXED)
# ==========================================================
print_header "Step 0 — EC2 Bootstrap & Tool Installation"

echo "🚀 Updating OS..."
dnf update -y

# ✅ FIX: Resolve curl conflict (VERY IMPORTANT)
echo "🚀 Fixing curl conflict (curl-minimal vs curl)..."
dnf remove -y curl-minimal || true
dnf install -y curl --allowerasing

echo "🚀 Installing base tools..."
dnf install -y unzip wget nano vim tar htop git jq awscli

echo "🚀 Installing MySQL client..."
dnf install -y mariadb105

echo "🚀 Installing Docker..."
dnf install -y docker
systemctl enable docker
systemctl start docker

echo "🚀 Adding ec2-user to Docker group..."
usermod -aG docker ec2-user || true

echo "🚀 Installing Docker Compose v2..."
mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker compose version

print_success "EC2 Bootstrap completed"

# ==========================================================
# 🔐 CHECK GITHUB TOKEN
# ==========================================================
if [ -z "$GITHUB_TOKEN" ]; then
  print_error "GITHUB_TOKEN not set"
  echo "👉 Run: export GITHUB_TOKEN=your_token"
  exit 1
fi

# ==========================================================
# 📁 STEP 1 — CLONE PROJECT
# ==========================================================
print_header "Step 1 — Prepare Project"

if [ ! -d "$PROJECT_DIR" ]; then
  git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
fi

cd "$PROJECT_DIR"
print_success "Project ready"

# ==========================================================
# 🧰 STEP 2 — CHECK TOOLS
# ==========================================================
print_header "Step 2 — Checking Tools"

for cmd in aws jq mysql docker git curl; do
  command -v $cmd >/dev/null || { print_error "$cmd missing"; exit 1; }
done

print_success "All tools OK"

# ==========================================================
# ☁️ STEP 3 — FETCH SECRETS
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
# 🧪 STEP 4 — TEST DB
# ==========================================================
print_header "Step 4 — Testing RDS"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" \
  && print_success "RDS OK" \
  || { print_error "RDS failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — DB SETUP
# ==========================================================
print_header "Step 5 — Database Setup"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"

[ -f "$DATA_FILE" ] && mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"

print_success "Database ready"

# ==========================================================
# 🔧 STEP 6 — GIT SYNC
# ==========================================================
print_header "Step 6 — Git Sync"

git init
git add .
git commit -m "Auto commit" || true

git remote remove origin 2>/dev/null || true
git remote add origin https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git

git pull origin main --rebase || true
git push -u origin main

print_success "Git synced"

# ==========================================================
# 🐳 STEP 7 — DOCKER BUILD
# ==========================================================
print_header "Step 7 — Docker Build"

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
print_success "Image built"

# ==========================================================
# 🚀 STEP 8 — RUN CONTAINER
# ==========================================================
print_header "Step 8 — Run Container"

sudo fuser -k ${PORT}/tcp 2>/dev/null || true
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"

sleep 5
print_success "Container running"

# ==========================================================
# 🧪 STEP 9 — VERIFY
# ==========================================================
print_header "Step 9 — Verification"

docker ps | grep -q "$CONTAINER_NAME" \
  && print_success "Container OK" \
  || { print_error "Container failed"; exit 1; }

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT || true)

echo "HTTP Status: $HTTP_CODE"

print_header "Logs"
docker logs --tail 5 "$CONTAINER_NAME"

# ==========================================================
# 🎉 DONE
# ==========================================================
print_header "🎉 DEPLOYMENT SUCCESS"

echo "👉 http://localhost:$PORT"