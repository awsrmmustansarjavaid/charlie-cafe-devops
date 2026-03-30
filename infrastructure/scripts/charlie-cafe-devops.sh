#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v2)
# ----------------------------------------------------------
# ✔ Setup AWS RDS (DB + schema + data + verification)
# ✔ Initialize Git & push to GitHub
# ✔ Build Docker image (custom Dockerfile path)
# ✔ Run Docker container
# ✔ Production-ready with safety checks
# ==========================================================

# ❗ Exit on:
# - any error (-e)
# - undefined variable (-u)
# - pipeline failure (pipefail)
set -euo pipefail

# ==========================================================
# 🔧 GLOBAL VARIABLES (EDIT BEFORE RUN)
# ==========================================================

# --- Project ---
PROJECT_DIR="charlie-cafe"

# --- GitHub ---
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="YOUR_USERNAME"

# --- Docker ---
IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"

# --- Dockerfile Path (UPDATED) ---
DOCKERFILE_PATH="docker/apache-php/Dockerfile"

# --- AWS RDS / Secrets ---
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# ==========================================================
# 🎨 COLORS FOR OUTPUT (FOR READABILITY)
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

print_success() {
  echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
  echo -e "${RED}❌ $1${NC}\n"
}

# ==========================================================
# 📁 STEP 1 — MOVE INTO PROJECT DIRECTORY
# ==========================================================
print_header "Step 1 — Navigate to Project"

cd "$PROJECT_DIR" || { print_error "Project folder not found"; exit 1; }

print_success "Project directory ready"

# ==========================================================
# 🧰 STEP 2 — CHECK REQUIRED TOOLS
# ==========================================================
print_header "Step 2 — Checking Required Tools"

command -v aws >/dev/null || { print_error "AWS CLI not installed"; exit 1; }
command -v jq >/dev/null || { print_error "jq not installed"; exit 1; }
command -v mysql >/dev/null || { print_error "MySQL client not installed"; exit 1; }
command -v docker >/dev/null || { print_error "Docker not installed"; exit 1; }
command -v git >/dev/null || { print_error "Git not installed"; exit 1; }

print_success "All required tools are installed"

# ==========================================================
# ☁️ STEP 3 — FETCH DB CREDENTIALS FROM AWS
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
# 🧪 STEP 4 — TEST RDS CONNECTION
# ==========================================================
print_header "Step 4 — Testing RDS Connection"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1 \
  && print_success "RDS connection successful" \
  || { print_error "RDS connection failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — CREATE DATABASE
# ==========================================================
print_header "Step 5 — Creating Database"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database ready"

# ==========================================================
# 📦 STEP 6 — APPLY SCHEMA
# ==========================================================
print_header "Step 6 — Applying Schema"

if [ -f "$SCHEMA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"
  print_success "Schema applied"
else
  print_error "Schema file missing: $SCHEMA_FILE"
  exit 1
fi

# ==========================================================
# 📊 STEP 7 — APPLY DATA (OPTIONAL)
# ==========================================================
print_header "Step 7 — Applying Sample Data"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ No data file found, skipping...${NC}"
fi

# ==========================================================
# 🔍 STEP 8 — VERIFY DATABASE
# ==========================================================
print_header "Step 8 — Verification"

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "Verification completed"
else
  echo -e "${YELLOW}⚠️ No verify file found, skipping...${NC}"
fi

# ==========================================================
# 🔧 STEP 9 — GIT SETUP
# ==========================================================
print_header "Step 9 — Git Initialization"

git init
git add .
git commit -m "Initial commit - Charlie Cafe Project" || true

git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git || true
git branch -M main

git push -u origin main

print_success "Code pushed to GitHub"

# ==========================================================
# 🐳 STEP 10 — DOCKER BUILD (UPDATED PATH)
# ==========================================================
print_header "Step 10 — Docker Build"

# Build using custom Dockerfile path
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .

print_success "Docker image built using $DOCKERFILE_PATH"

# ==========================================================
# 🧹 STEP 11 — REMOVE OLD CONTAINER
# ==========================================================
print_header "Step 11 — Cleanup Old Container"

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

print_success "Old container removed (if existed)"

# ==========================================================
# 🚀 STEP 12 — RUN CONTAINER
# ==========================================================
print_header "Step 12 — Run Application"

docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"

print_success "Container is running"

# ==========================================================
# 📊 FINAL STATUS
# ==========================================================
print_header "Final Status"

docker ps

echo -e "\n🎉 ${GREEN}Charlie Cafe FULL DevOps Setup Completed!${NC}"
echo -e "🌐 Access your app: http://YOUR_EC2_PUBLIC_IP\n"