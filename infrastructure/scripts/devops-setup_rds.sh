#!/bin/bash

# =============================================================
# ☕ Charlie Cafe — RDS Setup Script (FINAL PRODUCTION VERSION)
# -------------------------------------------------------------
# Purpose:
# ✔ Fetch DB credentials securely from AWS Secrets Manager
# ✔ Create database (if not exists)
# ✔ Apply schema.sql (tables + relationships)
# ✔ Apply data.sql (optional sample data)
# ✔ Run verify.sql (QA checks)
# ✔ Safe to run multiple times
# =============================================================

set -euo pipefail

# =============================================================
# CONFIGURATION (EDIT IF NEEDED)
# =============================================================
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# =============================================================
# COLORS (FOR CLEAN OUTPUT)
# =============================================================
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

# =============================================================
# STEP 1 — CHECK REQUIRED TOOLS
# =============================================================
print_header "Checking Required Tools"

command -v aws >/dev/null 2>&1 || { print_error "AWS CLI not installed"; exit 1; }
command -v jq >/dev/null 2>&1 || { print_error "jq not installed"; exit 1; }
command -v mysql >/dev/null 2>&1 || { print_error "MySQL client not installed"; exit 1; }

print_success "All required tools are installed"

# =============================================================
# STEP 2 — FETCH SECRET FROM AWS SECRETS MANAGER
# =============================================================
print_header "Fetching DB Credentials from Secrets Manager"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "Credentials loaded successfully"

# =============================================================
# STEP 3 — TEST RDS CONNECTION
# =============================================================
print_header "Testing RDS Connection"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1 \
  && print_success "RDS connection successful" \
  || { print_error "Failed to connect to RDS"; exit 1; }

# =============================================================
# STEP 4 — CREATE DATABASE (SAFE)
# =============================================================
print_header "Creating Database (if not exists)"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database ensured"

# =============================================================
# STEP 5 — APPLY SCHEMA
# =============================================================
print_header "Applying Database Schema"

if [ -f "$SCHEMA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"
  print_success "Schema applied successfully"
else
  print_error "Schema file not found: $SCHEMA_FILE"
  exit 1
fi

# =============================================================
# STEP 6 — APPLY SAMPLE DATA (OPTIONAL)
# =============================================================
print_header "Applying Sample Data (Optional)"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ Data file not found, skipping...${NC}"
fi

# =============================================================
# STEP 7 — VERIFY DATABASE
# =============================================================
print_header "Running Verification"

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "Verification completed"
else
  echo -e "${YELLOW}⚠️ Verify file not found, skipping...${NC}"
fi

# =============================================================
# FINAL SUCCESS MESSAGE
# =============================================================
print_header "☕ Charlie Cafe RDS Setup Completed"

echo -e "${GREEN}✔ RDS Connected${NC}"
echo -e "${GREEN}✔ Database Created/Verified${NC}"
echo -e "${GREEN}✔ Schema Applied${NC}"
echo -e "${GREEN}✔ Data Inserted (if available)${NC}"
echo -e "${GREEN}✔ Verification Completed${NC}"

echo -e "\n🎉 Your Charlie Cafe database is fully ready on AWS RDS!\n"