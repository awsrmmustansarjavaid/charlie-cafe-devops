#!/bin/bash

# ==========================================================
# ☕ CHARLIE CAFE — FULL DEVOPS VERIFICATION + AUTO SYNC
# File: charlie-cafe-full-devops-verify.sh
# ==========================================================

set -e

# ---------------- VARIABLES ----------------
AWS_ACCESS_KEY_ID="your-access-id"
AWS_SECRET_ACCESS_KEY="your-secret-key"
AWS_REGION="us-east-1"

GITHUB_USERNAME="your-username"
GITHUB_TOKEN="your-token"
GITHUB_REPO="charlie-cafe-devops"

SECRET_NAME="CafeDevDBSM"
ECR_REPO="your-ecr-repo"

# ---------------- COLORS ----------------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0

pass(){ echo -e "${GREEN}✅ $1${NC}"; ((PASS++)); }
fail(){ echo -e "${RED}❌ $1${NC}"; ((FAIL++)); }
warn(){ echo -e "${YELLOW}⚠️ $1${NC}"; }

section(){
echo ""
echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}$1${NC}"
echo -e "${BLUE}==================================================${NC}"
}

echo -e "${BLUE}🚀 Starting Charlie Cafe DevOps Full Verification${NC}"

# ==========================================================
# 1️⃣ REQUIRED TOOLS
# ==========================================================
section "🔎 Required Tools"

for cmd in aws jq mysql docker git curl ssh; do
 command -v $cmd &>/dev/null && pass "$cmd installed" || fail "$cmd missing"
done

# ==========================================================
# 2️⃣ DOCKER CHECK
# ==========================================================
section "🐳 Docker Verification"

if systemctl is-active --quiet docker; then
 pass "Docker running"
else
 warn "Docker not running, starting..."
 sudo systemctl start docker
 sudo systemctl enable docker
 pass "Docker started"
fi

docker --version
docker info | head -n 10

echo "Images:"
docker images

echo "Running Containers:"
docker ps

echo "All Containers:"
docker ps -a

# ==========================================================
# 3️⃣ APACHE TEST
# ==========================================================
section "🌐 Apache Container Test"

TEST_CONTAINER="verify-apache-test"

docker rm -f $TEST_CONTAINER >/dev/null 2>&1 || true

docker run -d --name $TEST_CONTAINER -p 8080:80 httpd:latest >/dev/null
sleep 5

curl -s http://localhost:8080 >/dev/null && pass "Apache 8080 OK" || fail "Apache failed"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)

[ "$HTTP_STATUS" == "200" ] && pass "Port 80 active" || warn "Port 80 not active"

docker logs $TEST_CONTAINER | head -n 5

docker rm -f $TEST_CONTAINER >/dev/null

# ==========================================================
# 4️⃣ PROJECT + GIT
# ==========================================================
section "📂 Project & Git"

PROJECT_DIR="$HOME/$GITHUB_REPO"

if [ -d "$PROJECT_DIR/.git" ]; then
 pass "Project exists"
 cd "$PROJECT_DIR"
else
 warn "Project not found, cloning..."
 git clone https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$GITHUB_REPO.git $PROJECT_DIR
 cd "$PROJECT_DIR"
fi

git status &>/dev/null && pass "Git OK" || fail "Git issue"

git remote -v

# ==========================================================
# 5️⃣ SSH + GITHUB
# ==========================================================
section "🔐 SSH & GitHub"

[ -f ~/.ssh/id_rsa ] && pass "SSH key exists" || warn "SSH key missing"

ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated" \
 && pass "GitHub SSH OK" || warn "GitHub SSH failed"

# ==========================================================
# 6️⃣ GIT PUSH TEST
# ==========================================================
section "🧪 Git Push Test"

TEST_FILE="test_$(date +%s).txt"

echo "test" > $TEST_FILE
git add .
git commit -m "Auto test commit" >/dev/null 2>&1 || true

git push origin main >/dev/null 2>&1 \
 && pass "Git push OK" || fail "Git push failed"

rm -f $TEST_FILE

# ==========================================================
# 7️⃣ GITHUB CLONE TEST
# ==========================================================
section "🌍 GitHub Clone Test"

TEST_DIR="$HOME/github_test_repo"
rm -rf $TEST_DIR

git clone https://github.com/octocat/Hello-World.git $TEST_DIR \
 && pass "Clone OK" || fail "Clone failed"

# ==========================================================
# 8️⃣ NETWORK
# ==========================================================
section "🌐 Network"

ping -c 2 github.com >/dev/null 2>&1 \
 && pass "Internet OK" || fail "No internet"

# ==========================================================
# 9️⃣ AWS + RDS
# ==========================================================
section "🗄️ AWS + RDS"

export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION

SECRET=$(aws secretsmanager get-secret-value \
 --secret-id $SECRET_NAME \
 --query SecretString \
 --output text 2>/dev/null)

if [ $? -eq 0 ]; then
 pass "Secret fetched"

 DB_HOST=$(echo $SECRET | jq -r .host)
 DB_USER=$(echo $SECRET | jq -r .username)
 DB_PASS=$(echo $SECRET | jq -r .password)

 echo "SELECT 1;" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" &>/dev/null \
  && pass "RDS OK" || fail "RDS failed"
else
 fail "Secret fetch failed"
fi

# ==========================================================
# 🔟 AWS ACCOUNT
# ==========================================================
section "☁️ AWS Account"

ACC_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

[ -n "$ACC_ID" ] && pass "AWS Account: $ACC_ID" || fail "AWS error"

# ==========================================================
# 11️⃣ AUTO SYNC
# ==========================================================
section "🔄 Auto Sync"

cd "$PROJECT_DIR"

git pull origin main

if [[ -n "$(git status --porcelain)" ]]; then
 git add .
 git commit -m "Auto sync $(date)"
 git push origin main
 pass "Changes pushed"
else
 pass "No changes"
fi

# ==========================================================
# 12️⃣ ECR
# ==========================================================
section "📦 ECR"

if [[ -n "$ECR_REPO" ]]; then
 aws ecr describe-repositories --repository-names "$ECR_REPO" >/dev/null 2>&1 \
  && pass "ECR OK" || warn "ECR not found"
fi

# ==========================================================
# FINAL RESULT
# ==========================================================
section "📊 RESULT"

TOTAL=$((PASS+FAIL))
SUCCESS=$((PASS*100/TOTAL))

echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Success: $SUCCESS%"

if [ $FAIL -eq 0 ]; then
 echo -e "${GREEN}🎉 SYSTEM READY${NC}"
else
 echo -e "${YELLOW}⚠️ NEED FIXES${NC}"
fi