#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — COMPLETE DevOps Verification Script
# ==========================================================

# ---------------- COLORS ----------------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

pass() { echo -e "${GREEN}✅ $1${NC}"; ((PASS_COUNT++)); }
fail() { echo -e "${RED}❌ $1${NC}"; ((FAIL_COUNT++)); }
warn() { echo -e "${YELLOW}⚠️ $1${NC}"; }

section() {
  echo ""
  echo -e "${BLUE}==================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}==================================================${NC}"
}

echo -e "${BLUE}🚀 Starting Full Environment Verification${NC}"

# ==========================================================
# 1️⃣ REQUIRED TOOLS
# ==========================================================
section "🔎 Step 1: Required Tools"

for cmd in aws jq mysql docker git curl ssh; do
    command -v $cmd &>/dev/null && pass "$cmd installed" || fail "$cmd NOT installed"
done

# ==========================================================
# 2️⃣ VERSION CHECKS
# ==========================================================
section "📦 Step 2: Versions"

aws --version 2>/dev/null
jq --version 2>/dev/null
mysql --version 2>/dev/null
docker --version 2>/dev/null
git --version 2>/dev/null
curl --version 2>/dev/null
ssh -V 2>/dev/null

# ==========================================================
# 3️⃣ DOCKER STATUS + DETAILS
# ==========================================================
section "🐳 Step 3: Docker Verification"

if systemctl is-active --quiet docker; then
    pass "Docker running"
else
    fail "Docker NOT running"
    sudo systemctl start docker
fi

docker info &>/dev/null && pass "Docker info OK" || fail "Docker info failed"

echo "🔹 Docker Images:"
docker images

echo "🔹 Running Containers:"
docker ps

echo "🔹 All Containers:"
docker ps -a

# ==========================================================
# 4️⃣ APACHE TEST CONTAINER
# ==========================================================
section "🌐 Step 4: Apache Container Test"

TEST_CONTAINER="verify-apache-test"
docker rm -f $TEST_CONTAINER >/dev/null 2>&1

docker run -d --name $TEST_CONTAINER -p 8080:80 httpd:latest >/dev/null
sleep 5

curl -s http://localhost:8080 >/dev/null && pass "Apache 8080 OK" || fail "Apache 8080 failed"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)

[ "$HTTP_STATUS" == "200" ] && pass "App running on port 80" || warn "App not on port 80"

echo "🔹 Container Logs:"
docker logs $TEST_CONTAINER | head -n 5

docker rm -f $TEST_CONTAINER >/dev/null

# ==========================================================
# 5️⃣ PROJECT + GIT
# ==========================================================
section "📂 Step 5: Project & Git"

PROJECT_DIR="/home/ec2-user/charlie-cafe-devops"

if [ -d "$PROJECT_DIR" ]; then
    pass "Project directory exists"
    cd "$PROJECT_DIR" || exit

    git status &>/dev/null && pass "Git repo OK" || fail "Not a git repo"

    echo "🔹 Directory:"
    ls -la

    echo "🔹 Git Remote:"
    git remote -v

else
    fail "Project directory missing"
fi

# ==========================================================
# 6️⃣ SSH + GITHUB AUTH
# ==========================================================
section "🔐 Step 6: SSH & GitHub"

ls -l ~/.ssh

[ -f ~/.ssh/id_deploy ] && pass "Private key exists" || fail "Private key missing"
[ -f ~/.ssh/id_deploy.pub ] && pass "Public key exists" || fail "Public key missing"

ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated"

[ $? -eq 0 ] && pass "GitHub SSH OK" || fail "GitHub SSH failed"

# ==========================================================
# 7️⃣ GIT TEST (COMMIT + PUSH)
# ==========================================================
section "🧪 Step 7: Git Push Test"

TEST_FILE="test_auto_deploy.txt"

echo "# Test $(date)" >> $TEST_FILE
git add $TEST_FILE
git commit -m "Test commit $(date)" >/dev/null 2>&1

if git push origin main >/dev/null 2>&1; then
    pass "Git push successful"
else
    fail "Git push failed"
fi

rm -f $TEST_FILE
git add . >/dev/null 2>&1
git commit -m "Cleanup test file" >/dev/null 2>&1
git push origin main >/dev/null 2>&1

# ==========================================================
# 8️⃣ GITHUB CLONE TEST
# ==========================================================
section "🌍 Step 8: GitHub Clone Test"

TEST_DIR="$HOME/github_test_repo"
rm -rf $TEST_DIR

if git clone https://github.com/octocat/Hello-World.git $TEST_DIR; then
    pass "GitHub clone OK"
    cd $TEST_DIR
    git pull
    git log -1 --oneline
else
    fail "GitHub clone failed"
fi

# ==========================================================
# 9️⃣ NETWORK CHECK
# ==========================================================
section "🌐 Step 9: Network"

ping -c 2 github.com >/dev/null 2>&1 && pass "Internet OK" || fail "No Internet"

# ==========================================================
# 🔟 AWS + RDS
# ==========================================================
section "🗄️ Step 10: AWS + RDS"

SECRET_NAME="CafeDevDBSM"
REGION="us-east-1"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_NAME \
  --region $REGION \
  --query SecretString \
  --output text 2>/dev/null)

if [ $? -eq 0 ]; then
    pass "AWS Secret fetched"

    DB_HOST=$(echo $SECRET_JSON | jq -r .host)
    DB_USER=$(echo $SECRET_JSON | jq -r .username)
    DB_PASS=$(echo $SECRET_JSON | jq -r .password)

else
    fail "AWS Secret failed"
fi

if [ -n "$DB_HOST" ]; then
    echo "SELECT NOW();" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" &>/dev/null \
        && pass "RDS connection OK" \
        || fail "RDS connection failed"
fi

# ==========================================================
# FINAL RESULT
# ==========================================================
section "📊 FINAL RESULT"

TOTAL=$((PASS_COUNT + FAIL_COUNT))
SUCCESS=$((PASS_COUNT * 100 / TOTAL))

echo -e "Total Checks : $TOTAL"
echo -e "${GREEN}Passed       : $PASS_COUNT${NC}"
echo -e "${RED}Failed       : $FAIL_COUNT${NC}"
echo -e "${YELLOW}Success Rate : $SUCCESS%${NC}"

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL CHECKS PASSED — READY 🚀${NC}"
elif [ $SUCCESS -ge 70 ]; then
    echo -e "${YELLOW}⚠️ PARTIAL SUCCESS — NEED FIXES${NC}"
else
    echo -e "${RED}❌ SYSTEM NOT READY${NC}"
fi

echo "=================================================="