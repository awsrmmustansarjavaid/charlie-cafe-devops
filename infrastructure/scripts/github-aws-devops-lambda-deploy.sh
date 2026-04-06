#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — GitHub + AWS DevOps + Lambda Deploy Script
# ----------------------------------------------------------
# This script automates:
#   ✔ Lambda Layer (PyMySQL) build & publish
#   ✔ Attach Layer to all Lambda functions
#   ✔ Package and deploy Lambda functions
#
# REQUIREMENTS:
#   - AWS CLI configured
#   - IAM permissions:
#       lambda:UpdateFunctionCode
#       lambda:PublishLayerVersion
#       lambda:UpdateFunctionConfiguration
#
# USAGE:
#   ./github-aws-devops-lambda-deploy.sh
# ==========================================================

set -e  # Exit immediately if any command fails

# ----------------------------------------------------------
# 🔧 CONFIGURATION
# ----------------------------------------------------------
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="YOUR_ACCOUNT_ID"

LAMBDA_DIR="app/backend/lambda"
LAYER_DIR="layer"
ZIP_LAYER="pymysql-layer.zip"
ZIP_OUTPUT_DIR="lambda_zips"

# ----------------------------------------------------------
# 🧹 CLEAN OLD FILES
# ----------------------------------------------------------
echo "🧹 Cleaning old build files..."
rm -rf "$LAYER_DIR" "$ZIP_LAYER" "$ZIP_OUTPUT_DIR"

# ----------------------------------------------------------
# 🏗️ STEP 1 — BUILD LAMBDA LAYER (PyMySQL)
# ----------------------------------------------------------
echo "🏗️ Building Lambda Layer..."

mkdir -p $LAYER_DIR/python

# Install dependencies inside layer/python/
pip3 install pymysql -t $LAYER_DIR/python --no-cache-dir

# Zip the layer (IMPORTANT: must contain python/ folder)
cd $LAYER_DIR
zip -r ../$ZIP_LAYER python > /dev/null
cd ..

echo "✅ Layer packaged: $ZIP_LAYER"

# ----------------------------------------------------------
# 🚀 STEP 2 — PUBLISH LAYER TO AWS
# ----------------------------------------------------------
echo "🚀 Publishing Lambda Layer..."

LAYER_VERSION=$(aws lambda publish-layer-version \
  --region $AWS_REGION \
  --layer-name pymysql-layer \
  --zip-file fileb://$ZIP_LAYER \
  --compatible-runtimes python3.10 python3.11 \
  --query 'Version' \
  --output text)

echo "✅ Layer published: Version $LAYER_VERSION"

# ----------------------------------------------------------
# 🔗 STEP 3 — ATTACH LAYER TO ALL LAMBDAS
# ----------------------------------------------------------
echo "🔗 Attaching Layer to Lambda functions..."

for file in $LAMBDA_DIR/*.py; do
  fname=$(basename "$file" .py)

  echo "➡️ Updating $fname with Layer..."

  aws lambda update-function-configuration \
    --region $AWS_REGION \
    --function-name "$fname" \
    --layers arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:layer:pymysql-layer:$LAYER_VERSION
done

echo "✅ Layer attached to all Lambdas"

# ----------------------------------------------------------
# 📦 STEP 4 — PACKAGE LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "📦 Packaging Lambda functions..."

mkdir -p $ZIP_OUTPUT_DIR

for file in $LAMBDA_DIR/*.py; do
  fname=$(basename "$file" .py)

  echo "➡️ Packaging $fname..."

  zip -j $ZIP_OUTPUT_DIR/$fname.zip "$file" > /dev/null
done

echo "✅ All Lambdas packaged"

# ----------------------------------------------------------
# 🚀 STEP 5 — DEPLOY LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "🚀 Deploying Lambda functions..."

for zip in $ZIP_OUTPUT_DIR/*.zip; do
  fname=$(basename "$zip" .zip)

  echo "➡️ Deploying $fname..."

  aws lambda update-function-code \
    --region $AWS_REGION \
    --function-name "$fname" \
    --zip-file fileb://$zip
done

echo "✅ All Lambdas deployed successfully"

# ----------------------------------------------------------
# 🧪 STEP 6 — TEST ONE LAMBDA
# ----------------------------------------------------------
echo "🧪 Testing CafeOrderProcessor..."

aws lambda invoke \
  --region $AWS_REGION \
  --function-name CafeOrderProcessor \
  --payload '{}' response.json > /dev/null

echo "📄 Lambda Response:"
cat response.json

echo "✅ Test completed"

# ----------------------------------------------------------
# 🎉 FINAL
# ----------------------------------------------------------
echo "🎉 GitHub + AWS DevOps + Lambda Deployment Completed!"