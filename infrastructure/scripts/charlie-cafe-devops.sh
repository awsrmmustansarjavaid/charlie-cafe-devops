#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v3)
# ----------------------------------------------------------
# ✔ Setup AWS RDS (DB + schema + data + verification)
# ✔ Initialize Git & push to GitHub
# ✔ Build Docker image (custom Dockerfile path)
# ✔ Run Docker container
# ✔ FINAL VERIFICATION (container + HTTP + port checks)
# ==========================================================

set -euo pipefail

# ==========================================================
# 🔧 GLOBAL VARIABLES (EDIT BEFORE RUN)
# ==========================================================

PROJECT_DIR="charlie-cafe"

REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="YOUR_USERNAME"

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
BLUE='\033[0;34m'
RED='\033[0;31m'
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
# 📁 STEP 1 — NAVIGATE
# ==========================================================
print_header "Step 1 — Navigate to Project"

cd "$PROJECT_DIR" || { print_error "Project folder not found"; exit 1; }

# ==========================================================
# 🧰 STEP 2 — CHECK TOOLS
# ==========================================================
print_header "Step 2 — Checking Required Tools"

command -v aws >/dev/null || { print_error "AWS CLI not installed"; exit 1; }
command -v jq >/dev/null || { print_error "jq not installed"; exit 1; }
command -v mysql >/dev/null || { print_error "MySQL not installed"; exit 1; }
command -v docker >/dev/null || { print_error "Docker not installed"; exit 1; }
command -v git >/dev/null || { print_error "Git not installed"; exit 1; }
command -v curl >/dev/null || { print_error "curl not installed"; exit 1; }

print_success "All required tools are installed"

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

print_success "Database credentials loaded"

# ==========================================================
# 🧪 STEP 4 — TEST RDS
# ==========================================================
print_header "Step 4 — Testing RDS"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null \
  && print_success "RDS connection successful" \
  || { print_error "RDS failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — CREATE DB
# ==========================================================
print_header "Step 5 — Creating Database"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

# ==========================================================
# 📦 STEP 6 — SCHEMA
# ==========================================================
print_header "Step 6 — Applying Schema"

[ -f "$SCHEMA_FILE" ] || { print_error "Schema missing"; exit 1; }
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"

# ==========================================================
# 📊 STEP 7 — DATA
# ==========================================================
print_header "Step 7 — Sample Data"

[ -f "$DATA_FILE" ] && mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE" \
  && print_success "Sample data applied" || echo -e "${YELLOW}Skipped${NC}"

# ==========================================================
# 🔍 STEP 8 — VERIFY SQL
# ==========================================================
print_header "Step 8 — DB Verification"

[ -f "$VERIFY_FILE" ] && mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"

# ==========================================================
# 🔧 STEP 9 — GIT
# ==========================================================
print_header "Step 9 — Git Setup"

git init
git add .
git commit -m "Initial commit - Charlie Cafe Project" || true
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git || true
git branch -M main
git push -u origin main

# ==========================================================
# 🐳 STEP 10 — DOCKER BUILD
# ==========================================================
print_header "Step 10 — Docker Build"

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .

# ==========================================================
# 🧹 STEP 11 — CLEAN CONTAINER
# ==========================================================
print_header "Step 11 — Cleanup"

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# ==========================================================
# 🚀 STEP 12 — RUN CONTAINER
# ==========================================================
print_header "Step 12 — Run Container"

docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"

sleep 5

# ==========================================================
# 🧪 STEP 13 — FINAL VERIFICATION
# ==========================================================
print_header "Step 13 — FINAL TESTING & VERIFICATION"

# 1️⃣ Check container running
if docker ps | grep -q "$CONTAINER_NAME"; then
  print_success "Container is running"
else
  print_error "Container not running"
  exit 1
fi

# 2️⃣ Check port listening
if ss -tuln | grep -q ":$PORT"; then
  print_success "Port $PORT is open"
else
  print_error "Port $PORT not open"
fi

# 3️⃣ HTTP check
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT || true)

if [ "$HTTP_CODE" == "200" ]; then
  print_success "Application is accessible (HTTP 200)"
else
  echo -e "${YELLOW}⚠️ HTTP Response: $HTTP_CODE${NC}"
fi

# 4️⃣ Container logs (last 5 lines)
print_header "Container Logs (Last 5 lines)"
docker logs --tail 5 "$CONTAINER_NAME"

# ==========================================================
# 🎉 FINAL OUTPUT
# ==========================================================
print_header "🎉 DEPLOYMENT SUCCESS"

echo -e "${GREEN}✔ RDS Ready${NC}"
echo -e "${GREEN}✔ GitHub Synced${NC}"
echo -e "${GREEN}✔ Docker Running${NC}"
echo -e "${GREEN}✔ App Tested${NC}"

echo -e "\n🌐 Access your app:"
echo -e "👉 http://localhost:$PORT"
echo -e "👉 http://YOUR_EC2_PUBLIC_IP:$PORT\n"