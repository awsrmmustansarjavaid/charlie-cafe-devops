#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — DevOps Environment Verification & RDS Analytics
# ==========================================================
# This script verifies:
#   ✅ Required tools
#   ✅ Docker daemon
#   ✅ Project directory & Git
#   ✅ AWS Secrets Manager connectivity
#   ✅ Local application health (curl)
#   ✅ RDS database connectivity & analytics
# ==========================================================

echo "=================================================="
echo "🚀 Starting Environment Verification"
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
echo "🔎 Step 5: Fetching RDS credentials from AWS Secrets Manager..."

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
# Step 6: Application Health Check
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
# Step 7: RDS Verification & Analytics
# ----------------------------------------------------------
echo ""
echo "🔎 Step 7: Verifying RDS database connectivity and running analytics..."

if [ -n "$DB_HOST" ] && [ -n "$DB_USER" ] && [ -n "$DB_PASS" ]; then
    # SQL commands for verification
    SQL_QUERY="
USE $DB_NAME;

-- Check Database
SELECT DATABASE();

-- Show Tables
SHOW TABLES;

-- Describe Tables
DESCRIBE employees;
DESCRIBE attendance;
DESCRIBE leaves;
DESCRIBE holidays;
DESCRIBE orders;

-- Row Counts
SELECT
  (SELECT COUNT(*) FROM orders) AS total_orders,
  (SELECT COUNT(*) FROM employees) AS total_employees,
  (SELECT COUNT(*) FROM attendance) AS total_attendance,
  (SELECT COUNT(*) FROM holidays) AS total_holidays;

-- Paid Orders
SELECT COUNT(*) AS paid_orders
FROM orders
WHERE payment_status='PAID';

-- Today Sales
SELECT COUNT(*) AS today_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= CURDATE();

-- Week Sales
SELECT COUNT(*) AS week_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= NOW() - INTERVAL 7 DAY;

-- Month Sales
SELECT COUNT(*) AS month_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= DATE_FORMAT(NOW(),'%Y-%m-01');
"

    # Execute SQL using mysql CLI
    echo "$SQL_QUERY" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" 2>/tmp/rds_error.log

    if [ $? -eq 0 ]; then
        echo "✅ RDS database connected and SQL executed successfully"
        ((PASS_COUNT++))
    else
        echo "❌ Failed to connect or execute SQL on RDS"
        cat /tmp/rds_error.log
        ((FAIL_COUNT++))
    fi
else
    echo "❌ RDS credentials not available, skipping RDS check"
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