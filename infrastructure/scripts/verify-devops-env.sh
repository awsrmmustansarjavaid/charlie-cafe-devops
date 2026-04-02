#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — DevOps Environment Verification Script
# ==========================================================
# This script verifies:
#   ✅ Required tools installation
#   ✅ Tool versions
#   ✅ Docker daemon status
#   ✅ Project directory & Git status
#   ✅ AWS Secrets Manager connectivity
#   ✅ Local application health (via curl)
# ==========================================================

echo "=================================================="
echo "🚀 Starting DevOps Environment Verification"
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

echo ""
echo "🔎 Step 1: Checking required tools..."

check_command aws
check_command jq
check_command mysql
check_command docker
check_command git
check_command curl

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

echo ""
echo "Docker Info:"
docker info >/dev/null 2>&1 && echo "✅ docker info OK" || echo "❌ docker info failed"

# ----------------------------------------------------------
# Step 4: Project Directory Check
# ----------------------------------------------------------
echo ""
echo "🔎 Step 4: Checking project directory..."

PROJECT_DIR=~/charlie-cafe-devops

if [ -d "$PROJECT_DIR" ]; then
    echo "✅ Project directory exists: $PROJECT_DIR"
    cd $PROJECT_DIR

    echo ""
    echo "📂 Git Status:"
    git status 2>/dev/null || echo "❌ Not a git repo"

    echo ""
    echo "📁 Directory structure:"
    ls -la
else
    echo "❌ Project directory NOT found"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 5: AWS Secrets Manager Check
# ----------------------------------------------------------
echo ""
echo "🔎 Step 5: AWS Secrets Manager check..."

SECRET_NAME="CafeDevDBSM"
REGION="us-east-1"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_NAME \
  --region $REGION \
  --query SecretString \
  --output text 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "✅ Secret fetched successfully"

    echo ""
    echo "🔐 Parsed Secret:"
    echo $SECRET_JSON | jq .

    DB_HOST=$(echo $SECRET_JSON | jq -r .host)
    DB_USER=$(echo $SECRET_JSON | jq -r .username)
    DB_NAME=$(echo $SECRET_JSON | jq -r .dbname)

    echo ""
    echo "📊 Extracted Values:"
    echo "Host: $DB_HOST"
    echo "User: $DB_USER"
    echo "DB Name: $DB_NAME"

    ((PASS_COUNT++))
else
    echo "❌ Failed to fetch secret"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 6: Application Health Check (curl localhost)
# ----------------------------------------------------------
echo ""
echo "🔎 Step 6: Checking Application Health (http://localhost)..."

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