#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v9, SSH GIT)
# ==========================================================

set -euo pipefail

# ==========================================================
# 🔧 VARIABLES
# ==========================================================
PROJECT_DIR="charlie-cafe-devops"
REPO_NAME="charlie-cafe-devops"
GITHUB_USER="awsrmmustansarjavaid"
GITHUB_REPO="git@github.com:${GITHUB_USER}/${REPO_NAME}.git"

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
NC='\033[0m'

print_header() { echo -e "\n${BLUE}================================================${NC}\n${BLUE}$1${NC}\n${BLUE}================================================${NC}\n"; }
print_success() { echo -e "${GREEN}✅ $1${NC}\n"; }
print_error() { echo -e "${RED}❌ $1${NC}\n"; }

# ==========================================================
# 🔧 STEP 0 — EC2 BOOTSTRAP
# ==========================================================
print_header "Step 0 — EC2 Bootstrap & Tool Installation"

sudo dnf update -y
sudo dnf remove -y curl-minimal || true
sudo dnf install -y curl unzip wget nano vim tar htop git jq awscli mariadb105 docker

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user || true

# Install Docker Compose v2
mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker compose version
print_success "EC2 Bootstrap completed"

# ==========================================================
# 📁 STEP 1 — CLONE PROJECT (SSH)
# ==========================================================
print_header "Step 1 — Prepare Project"

if [ ! -d "$PROJECT_DIR" ]; then
  git clone "$GITHUB_REPO"
fi
cd "$PROJECT_DIR"
print_success "Project ready"

# ==========================================================
# ☁️ STEP 2 — FETCH AWS SECRETS
# ==========================================================
print_header "Step 2 — Fetch DB Credentials"

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
# 🧪 STEP 3 — TEST DB
# ==========================================================
print_header "Step 3 — Testing RDS"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" \
  && print_success "RDS OK" \
  || { print_error "RDS failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 4 — DATABASE SETUP
# ==========================================================
print_header "Step 4 — Database Setup"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"

[ -f "$DATA_FILE" ] && mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"

print_success "Database ready"

# ==========================================================
# 🔧 STEP 5 — GIT SYNC (SSH, NO TOKEN)
# ==========================================================
print_header "Step 5 — Git Sync via SSH"

git init
git add .
git commit -m "Auto commit" || true

git remote remove origin 2>/dev/null || true
git remote add origin "$GITHUB_REPO"

# Pull latest code via SSH
git pull origin main --rebase || true

print_success "Git synced via SSH"

# ==========================================================
# 🐳 STEP 6 — DOCKER BUILD & RUN
# ==========================================================
print_header "Step 6 — Docker Build"

docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
print_success "Docker image built"

print_header "Step 7 — Run Container"

sudo fuser -k ${PORT}/tcp 2>/dev/null || true
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"
sleep 5
print_success "Container running"

# ==========================================================
# 🧪 STEP 8 — VERIFY
# ==========================================================
print_header "Step 8 — Verification"

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