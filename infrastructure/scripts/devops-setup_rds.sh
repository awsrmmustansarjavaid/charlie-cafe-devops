#!/bin/bash

# -------------------------------------------------
# ☕ Charlie Cafe — RDS Setup via Secrets Manager
# -------------------------------------------------

set -e

AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

echo "📡 Fetching DB credentials from Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo $SECRET_JSON | jq -r '.host')
DB_USER=$(echo $SECRET_JSON | jq -r '.username')
DB_PASS=$(echo $SECRET_JSON | jq -r '.password')
DB_NAME=$(echo $SECRET_JSON | jq -r '.dbname')

echo "✅ Credentials loaded"

# -------------------------------------------------
# CREATE DATABASE (SAFE)
# -------------------------------------------------
echo "🗄️ Creating database if not exists..."

mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME;
"

# -------------------------------------------------
# APPLY SCHEMA
# -------------------------------------------------
echo "📦 Applying schema..."

mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/schema.sql

# -------------------------------------------------
# APPLY DATA (OPTIONAL)
# -------------------------------------------------
echo "📊 Applying sample data..."

mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/data.sql

# -------------------------------------------------
# VERIFY
# -------------------------------------------------
echo "🔍 Running verification..."

mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/verify.sql

echo "🎉 RDS setup completed successfully!"