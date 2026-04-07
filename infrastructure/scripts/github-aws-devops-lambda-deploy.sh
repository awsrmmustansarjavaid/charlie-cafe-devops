#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — GitHub + AWS DevOps + Lambda Deploy Script (Dynamic Version)
# ----------------------------------------------------------
# This script automates:
#   ✔ Lambda Layer (PyMySQL) build & publish
#   ✔ Attach Layer to all Lambda functions automatically
#   ✔ Package and deploy Lambda functions automatically
#
# FEATURES:
#   - No hardcoding of AWS Account ID
#   - Auto-detects Lambda functions in directory
#   - Fully compatible with EC2 IAM role or AWS CLI credentials
#
# USAGE:
#   ./github-aws-devops-lambda-deploy.sh
# ==========================================================

set -e  # Exit immediately if any command fails

# ----------------------------------------------------------
# 🔧 CONFIGURATION
# ----------------------------------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"  # Use ENV var or default
LAMBDA_DIR="app/backend/lambda"
LAYER_DIR="layer"
ZIP_LAYER="pymysql-layer.zip"
ZIP_OUTPUT_DIR="lambda_zips"
LAYER_NAME="pymysql-layer"
TEST_LAMBDA="CafeOrderProcessor"       # Lambda to test at the end

# ----------------------------------------------------------
# ⚡ DYNAMIC AWS ACCOUNT ID (no hardcoding)
# ----------------------------------------------------------
echo "⚡ Fetching AWS Account ID dynamically..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✅ AWS Account ID detected: $AWS_ACCOUNT_ID"

# ----------------------------------------------------------
# 🧹 CLEAN OLD FILES
# ----------------------------------------------------------
echo "🧹 Cleaning old build files..."
rm -rf "$LAYER_DIR" "$ZIP_LAYER" "$ZIP_OUTPUT_DIR"

# ----------------------------------------------------------
# 🏗️ STEP 1 — BUILD LAMBDA LAYER (PyMySQL)
# ----------------------------------------------------------
echo "🏗️ Building Lambda Layer..."
mkdir -p "$LAYER_DIR/python"

# Install dependencies inside layer/python/
pip3 install pymysql -t "$LAYER_DIR/python" --no-cache-dir

# Zip the layer (IMPORTANT: must contain python/ folder)
cd "$LAYER_DIR"
zip -r "../$ZIP_LAYER" python > /dev/null
cd ..

echo "✅ Layer packaged: $ZIP_LAYER"

# ----------------------------------------------------------
# 🚀 STEP 2 — PUBLISH LAYER TO AWS
# ----------------------------------------------------------
echo "🚀 Publishing Lambda Layer..."

LAYER_VERSION=$(aws lambda publish-layer-version \
  --region "$AWS_REGION" \
  --layer-name "$LAYER_NAME" \
  --zip-file "fileb://$ZIP_LAYER" \
  --compatible-runtimes python3.10 python3.11 \
  --query 'Version' \
  --output text)

echo "✅ Layer published: Version $LAYER_VERSION"

# ----------------------------------------------------------
# 🔗 STEP 3 — ATTACH LAYER TO ALL LAMBDAS IN DIRECTORY
# ----------------------------------------------------------
echo "🔗 Attaching Layer to Lambda functions..."

for file in "$LAMBDA_DIR"/*.py; do
  fname=$(basename "$file" .py)
  echo "➡️ Updating $fname with Layer..."
  
  aws lambda update-function-configuration \
    --region "$AWS_REGION" \
    --function-name "$fname" \
    --layers "arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:layer:$LAYER_NAME:$LAYER_VERSION"
done

echo "✅ Layer attached to all Lambdas"

# ----------------------------------------------------------
# 📦 STEP 4 — PACKAGE LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "📦 Packaging Lambda functions..."
mkdir -p "$ZIP_OUTPUT_DIR"

for file in "$LAMBDA_DIR"/*.py; do
  fname=$(basename "$file" .py)
  echo "➡️ Packaging $fname..."
  zip -j "$ZIP_OUTPUT_DIR/$fname.zip" "$file" > /dev/null
done

echo "✅ All Lambdas packaged"

# ----------------------------------------------------------
# 🚀 STEP 5 — DEPLOY LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "🚀 Deploying Lambda functions..."

for zip in "$ZIP_OUTPUT_DIR"/*.zip; do
  fname=$(basename "$zip" .zip)
  echo "➡️ Deploying $fname..."
  
  aws lambda update-function-code \
    --region "$AWS_REGION" \
    --function-name "$fname" \
    --zip-file "fileb://$zip"
done

echo "✅ All Lambdas deployed successfully"

# ----------------------------------------------------------
# 🧪 STEP 6 — TEST ONE LAMBDA
# ----------------------------------------------------------
echo "🧪 Testing $TEST_LAMBDA..."
aws lambda invoke \
  --region "$AWS_REGION" \
  --function-name "$TEST_LAMBDA" \
  --payload '{}' response.json > /dev/null

echo "📄 Lambda Response:"
cat response.json

echo "✅ Test completed"

# ----------------------------------------------------------
# 🎉 FINAL
# ----------------------------------------------------------
echo "🎉 GitHub + AWS DevOps + Lambda Deployment Completed!"