#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — FULL DevOps & Post-Deployment Verification Script
# ==========================================================
# This script performs:
#   ✅ Required tools verification
#   ✅ Docker daemon & image/container check
#   ✅ Project directory & Git check
#   ✅ AWS Secrets Manager connectivity
#   ✅ Local application health (curl)
#   ✅ RDS database connectivity & analytics
#   ✅ SSH configuration & GitHub access
#   ✅ Git repo verification & optional test commit
#   ✅ Post-deployment verification (ports, logs, restart policy)
# ==========================================================

echo "=================================================="
echo "🚀 Starting Full Environment & Deployment Verification"
echo "=================================================="

PASS_COUNT=0
FAIL_COUNT=0

# ----------------------------------------------------------
# Function: Check if command exists
# ----------------------------------------------------------
check_command() {
    if command -v $1 &> /dev/null
    then
        echo "✅ $1 is installed"
        ((PASS_COUNT++))
    else
        echo "❌ $1 is NOT installed"
        ((FAIL_COUNT++))
    fi
}

# ----------------------------------------------------------
# Step 1: Required Tools
# ----------------------------------------------------------
echo ""
echo "🔎 Step 1: Checking required tools..."
check_command aws
check_command jq
check_command mysql
check_command docker
check_command git
check_command curl
check_command ssh

# ----------------------------------------------------------
# Step 2: Version Checks
# ----------------------------------------------------------
echo ""
echo "🔎 Step 2: Checking versions..."
echo "---- Versions ----"
aws --version 2>/dev/null || echo "❌ aws failed"
jq --version 2>/dev/null || echo "❌ jq failed"
mysql --version 2>/dev/null || echo "❌ mysql failed"
docker --version 2>/dev/null || echo "❌ docker failed"
git --version 2>/dev/null || echo "❌ git failed"
curl --version 2>/dev/null || echo "❌ curl failed"
ssh -V 2>/dev/null || echo "❌ ssh failed"

# ----------------------------------------------------------
# Step 3: Docker Status
# ----------------------------------------------------------
echo ""
echo "🔎 Step 3: Checking Docker daemon..."
if sudo systemctl is-active --quiet docker
then
    echo "✅ Docker daemon is running"
    ((PASS_COUNT++))
else
    echo "❌ Docker daemon is NOT running"
    ((FAIL_COUNT++))
fi

docker info >/dev/null 2>&1 && echo "✅ docker info OK" || echo "❌ docker info failed"

# ----------------------------------------------------------
# Step 4: Project Directory & Git
# ----------------------------------------------------------
echo ""
echo "🔎 Step 4: Checking project directory..."
PROJECT_DIR="/home/ec2-user/charlie-cafe-devops"

if [ -d "$PROJECT_DIR" ]; then
    echo "✅ Project directory exists: $PROJECT_DIR"
    cd "$PROJECT_DIR" || exit

    echo ""
    echo "📂 Git Status:"
    git status 2>/dev/null || echo "❌ Not a git repo"

    echo ""
    echo "📁 Directory structure:"
    ls -la

    echo ""
    echo "🔹 Checking Git remote URL..."
    git remote -v || echo "❌ Cannot show remotes"

    echo ""
    echo "🔹 Verifying SSH connection to GitHub..."
    ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | tee /tmp/github_ssh_test.log
    if grep -q "successfully authenticated" /tmp/github_ssh_test.log; then
        echo "✅ GitHub SSH authentication successful"
        ((PASS_COUNT++))
    else
        echo "❌ GitHub SSH authentication failed"
        ((FAIL_COUNT++))
    fi

    echo ""
    echo "🔹 Checking Git status..."
    git status || echo "❌ Cannot get git status"

    # Optional test commit
    TEST_FILE="test_auto_deploy.txt"
    echo "# Test Deploy $(date)" >> $TEST_FILE
    git add $TEST_FILE
    git commit -m "Test auto-deploy $(date)" >/dev/null 2>&1 || echo "⚠️ Nothing to commit"
    git push origin main >/dev/null 2>&1 && echo "✅ Test file pushed to GitHub" || echo "⚠️ Could not push test file"
    rm -f $TEST_FILE
    git add . >/dev/null 2>&1
    git commit -m "Remove test file" >/dev/null 2>&1
    git push origin main >/dev/null 2>&1

else
    echo "❌ Project directory NOT found"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 5: SSH Verification
# ----------------------------------------------------------
echo ""
echo "🔎 Step 5: Checking SSH keys..."
echo "📂 ~/.ssh contents:"
ls -l ~/.ssh

if [ -f ~/.ssh/id_deploy ]; then
    echo "✅ Deploy private key exists"
    ((PASS_COUNT++))
else
    echo "❌ Deploy private key NOT found"
    ((FAIL_COUNT++))
fi

if [ -f ~/.ssh/id_deploy.pub ]; then
    echo "✅ Deploy public key exists"
    ((PASS_COUNT++))
else
    echo "❌ Deploy public key NOT found"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 6: AWS Secrets Manager Check
# ----------------------------------------------------------
echo ""
echo "🔎 Step 6: Fetching RDS credentials from AWS Secrets Manager..."
SECRET_NAME="CafeDevDBSM"
REGION="us-east-1"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_NAME \
  --region $REGION \
  --query SecretString \
  --output text 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "✅ Secret fetched successfully"
    DB_HOST=$(echo $SECRET_JSON | jq -r .host)
    DB_USER=$(echo $SECRET_JSON | jq -r .username)
    DB_PASS=$(echo $SECRET_JSON | jq -r .password)
    DB_NAME=$(echo $SECRET_JSON | jq -r .dbname)

    echo "📊 Database Host: $DB_HOST"
    echo "📊 Database User: $DB_USER"
    echo "📊 Database Name: $DB_NAME"
    ((PASS_COUNT++))
else
    echo "❌ Failed to fetch secret"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 7: Application Health Check
# ----------------------------------------------------------
echo ""
echo "🔎 Step 7: Checking Application Health (http://localhost)..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost)
if [ "$HTTP_STATUS" == "200" ]; then
    echo "✅ Application is UP (HTTP 200)"
    ((PASS_COUNT++))
elif [ "$HTTP_STATUS" == "000" ]; then
    echo "❌ Application is DOWN (No response)"
    ((FAIL_COUNT++))
else
    echo "⚠️ Application responded with HTTP $HTTP_STATUS"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 8: RDS Verification & Analytics
# ----------------------------------------------------------
echo ""
echo "🔎 Step 8: Verifying RDS database connectivity..."
if [ -n "$DB_HOST" ] && [ -n "$DB_USER" ] && [ -n "$DB_PASS" ]; then
    SQL_QUERY="SELECT NOW();"
    echo "$SQL_QUERY" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" 2>/tmp/rds_error.log
    if [ $? -eq 0 ]; then
        echo "✅ RDS database connected successfully"
        ((PASS_COUNT++))
    else
        echo "❌ Failed to connect to RDS"
        cat /tmp/rds_error.log
        ((FAIL_COUNT++))
    fi
else
    echo "❌ RDS credentials not available"
    ((FAIL_COUNT++))
fi

# ==========================================================
# Step 9: Post-Deployment Verification (Docker/Git/Health)
# ==========================================================
echo ""
echo "🔎 Step 9: Post-Deployment Verification"

DOCKER_IMAGE="charlie-cafe"
DOCKER_CONTAINER="cafe-app"
HEALTH_URL="http://localhost/health.php"

# Docker image check
docker images | grep $DOCKER_IMAGE >/dev/null 2>&1 && echo "✅ Docker image exists: $DOCKER_IMAGE" || echo "❌ Docker image NOT found"

# Docker container check
if docker ps | grep $DOCKER_CONTAINER >/dev/null 2>&1; then
    echo "✅ Container $DOCKER_CONTAINER is RUNNING"
else
    echo "❌ Container $DOCKER_CONTAINER is NOT running"
    docker ps -a | grep $DOCKER_CONTAINER
    docker logs $DOCKER_CONTAINER
fi

# Port & networking
sudo lsof -i :80 >/dev/null 2>&1 && echo "✅ Port 80 in use" || echo "❌ Port 80 not in use"
curl -f http://localhost >/dev/null 2>&1 && echo "✅ localhost reachable" || echo "❌ localhost NOT reachable"

# Health check
curl -f $HEALTH_URL >/dev/null 2>&1 && echo "✅ Health check passed" || echo "❌ Health check FAILED"

# Docker logs (last 10 lines)
docker logs --tail 10 $DOCKER_CONTAINER || echo "❌ Cannot fetch container logs"
docker exec -it $DOCKER_CONTAINER tail -n 10 /var/log/apache2/error.log || echo "❌ Cannot fetch Apache logs"

# Restart policy
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' $DOCKER_CONTAINER || echo "❌ Cannot fetch restart policy"

# ----------------------------------------------------------
# Final Result
# ----------------------------------------------------------
echo ""
echo "=================================================="
echo "📊 FINAL RESULT"
echo "=================================================="
echo "✅ Passed: $PASS_COUNT"
echo "❌ Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -eq 0 ]; then
    echo "🎉 ALL CHECKS PASSED — ENVIRONMENT READY 🚀"
else
    echo "⚠️ Some checks failed — fix issues above"
fi

echo "=================================================="