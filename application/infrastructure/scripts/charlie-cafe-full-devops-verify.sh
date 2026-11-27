#!/bin/bash

# ==========================================================
# ☕ CHARLIE CAFE — MASTER DEVOPS VERIFICATION SCRIPT
# ==========================================================
# Combines:
#   ✅ Environment verification
#   ✅ Docker + Apache test
#   ✅ Git & GitHub validation
#   ✅ AWS + RDS + Secrets
#   ✅ Auto sync repo
#   ✅ Post-deployment checks
# ==========================================================

set -e

# ---------------- CONFIG ----------------
AWS_REGION="us-east-1"
SECRET_NAME="CafeDevDBSM"
GITHUB_USERNAME="your-username"
GITHUB_TOKEN="your-token"
GITHUB_REPO="charlie-cafe-devops"
PROJECT_DIR="/home/ec2-user/charlie-cafe-devops"
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

echo -e "${BLUE}🚀 STARTING MASTER VERIFICATION${NC}"

# ==========================================================
# 1. REQUIRED TOOLS
# ==========================================================
section "🔎 Required Tools"

for cmd in aws jq mysql docker git curl ssh; do
 command -v $cmd >/dev/null && pass "$cmd installed" || fail "$cmd missing"
done

# ==========================================================
# 2. DOCKER CHECK
# ==========================================================
section "🐳 Docker Check"

if systemctl is-active --quiet docker; then
 pass "Docker running"
else
 warn "Docker not running → starting"
 sudo systemctl start docker
fi

docker info >/dev/null && pass "Docker OK" || fail "Docker issue"

docker images
docker ps

# ==========================================================
# 3. APACHE TEST CONTAINER
# ==========================================================
section "🌐 Apache Test"

docker rm -f verify-apache >/dev/null 2>&1 || true
docker run -d --name verify-apache -p 8080:80 httpd:latest >/dev/null

sleep 5

curl -s http://localhost:8080 >/dev/null && pass "Apache OK (8080)" || fail "Apache failed"

docker logs verify-apache | head -n 5
docker rm -f verify-apache >/dev/null

# ==========================================================
# 4. PROJECT + GIT
# ==========================================================
section "📂 Git Project"

if [ -d "$PROJECT_DIR/.git" ]; then
 pass "Project exists"
 cd "$PROJECT_DIR"

 git status >/dev/null && pass "Git OK" || fail "Git issue"

 git remote -v
else
 fail "Project missing"
fi

# ==========================================================
# 5. SSH + GITHUB
# ==========================================================
section "🔐 SSH & GitHub"

[ -f ~/.ssh/id_deploy ] && pass "SSH key exists" || fail "SSH key missing"

ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated" \
 && pass "GitHub SSH OK" || fail "GitHub SSH failed"

# ==========================================================
# 6. GIT PUSH TEST
# ==========================================================
section "🧪 Git Push Test"

cd "$PROJECT_DIR"

echo "test $(date)" > test.txt
git add test.txt
git commit -m "test commit" >/dev/null 2>&1 || true

git push origin main >/dev/null 2>&1 && pass "Git push OK" || fail "Git push failed"

rm -f test.txt

# ==========================================================
# 7. NETWORK
# ==========================================================
section "🌐 Network"

ping -c 2 github.com >/dev/null && pass "Internet OK" || fail "No internet"

# ==========================================================
# 8. AWS + SECRETS + RDS
# ==========================================================
section "🗄️ AWS + RDS"

SECRET=$(aws secretsmanager get-secret-value \
 --secret-id $SECRET_NAME \
 --region $AWS_REGION \
 --query SecretString \
 --output text 2>/dev/null)

if [ $? -eq 0 ]; then
 pass "Secret fetched"

 DB_HOST=$(echo $SECRET | jq -r .host)
 DB_USER=$(echo $SECRET | jq -r .username)
 DB_PASS=$(echo $SECRET | jq -r .password)
else
 fail "Secret fetch failed"
fi

if [ -n "$DB_HOST" ]; then
 echo "SELECT 1;" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" \
  && pass "RDS OK" || fail "RDS failed"
fi

# ==========================================================
# 9. AWS ACCOUNT
# ==========================================================
section "☁️ AWS Identity"

ACC=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

[ -n "$ACC" ] && pass "AWS Account: $ACC" || fail "AWS not working"

# ==========================================================
# 10. GITHUB AUTO SYNC
# ==========================================================
section "🔄 Auto Sync"

cd "$PROJECT_DIR"

git pull origin main

if [[ -n "$(git status --porcelain)" ]]; then
 git add .
 git commit -m "auto-sync $(date)"
 git push origin main
 pass "Changes synced"
else
 pass "No changes"
fi

# ==========================================================
# 11. POST DEPLOY CHECK
# ==========================================================
section "🚀 Post Deployment"

docker ps

curl -s http://localhost >/dev/null && pass "App running" || fail "App not running"

# ==========================================================
# FINAL RESULT
# ==========================================================
section "📊 RESULT"

TOTAL=$((PASS+FAIL))
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ $FAIL -eq 0 ]; then
 echo -e "${GREEN}🎉 ALL GOOD 🚀${NC}"
else
 echo -e "${YELLOW}⚠️ Fix issues${NC}"
fi