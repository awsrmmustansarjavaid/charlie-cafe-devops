#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — Fully Automated GitHub + AWS Lambda Deploy
# ----------------------------------------------------------
# AUTOMATION FLOW:
#   1️⃣ Clone/Pull GitHub repo
#   2️⃣ Build PyMySQL Lambda Layer
#   3️⃣ Create or update Lambda functions automatically
#   4️⃣ Attach Layer to Lambdas
#   5️⃣ Deploy Lambda .py files
#   6️⃣ Test a Lambda function
#
# REQUIREMENTS:
#   - AWS CLI configured or EC2 IAM role
#   - Git installed
#
# USAGE:
#   ./deploy_charlie_cafe.sh
# ==========================================================

set -e

# ----------------------------------------------------------
# 🔧 CONFIGURATION
# ----------------------------------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"                # Can override with ENV
GITHUB_REPO_URL="https://github.com/YOUR_USERNAME/YOUR_REPO.git"
LOCAL_REPO_DIR="charlie-cafe-devops"
LAMBDA_SUBDIR="app/backend/lambda"                  # relative path inside repo
LAYER_DIR="layer"
ZIP_LAYER="pymysql-layer.zip"
ZIP_OUTPUT_DIR="lambda_zips"
LAYER_NAME="pymysql-layer"
TEST_LAMBDA="CafeOrderProcessor"                    # Lambda to test
PYTHON_RUNTIME="python3.11"                         # Lambda runtime

# ----------------------------------------------------------
# ⚡ DYNAMIC AWS ACCOUNT ID
# ----------------------------------------------------------
echo "⚡ Fetching AWS Account ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"

# ----------------------------------------------------------
# 📥 STEP 1 — CLONE OR UPDATE GITHUB REPO
# ----------------------------------------------------------
if [ -d "$LOCAL_REPO_DIR" ]; then
    echo "📦 Repository exists, pulling latest changes..."
    cd "$LOCAL_REPO_DIR"
    git reset --hard
    git pull origin main
    cd ..
else
    echo "📦 Cloning GitHub repository..."
    git clone "$GITHUB_REPO_URL" "$LOCAL_REPO_DIR"
fi
echo "✅ GitHub repo ready"

# ----------------------------------------------------------
# 🧹 CLEAN OLD FILES
# ----------------------------------------------------------
echo "🧹 Cleaning old build files..."
rm -rf "$LAYER_DIR" "$ZIP_LAYER" "$ZIP_OUTPUT_DIR"

# ----------------------------------------------------------
# 🏗️ STEP 2 — BUILD PYMYSQL LAMBDA LAYER
# ----------------------------------------------------------
echo "🏗️ Building PyMySQL Lambda Layer..."
mkdir -p "$LAYER_DIR/python"
pip3 install pymysql -t "$LAYER_DIR/python" --no-cache-dir

cd "$LAYER_DIR"
zip -r "../$ZIP_LAYER" python > /dev/null
cd ..
echo "✅ Layer packaged: $ZIP_LAYER"

# ----------------------------------------------------------
# 🚀 STEP 3 — PUBLISH LAYER
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
# 🔗 STEP 4 — PACKAGE, CREATE OR UPDATE LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "🔗 Creating/Updating Lambda functions..."
mkdir -p "$ZIP_OUTPUT_DIR"

LAMBDA_PATH="$LOCAL_REPO_DIR/$LAMBDA_SUBDIR"

for file in "$LAMBDA_PATH"/*.py; do
    fname=$(basename "$file" .py)
    zip_file="$ZIP_OUTPUT_DIR/$fname.zip"

    echo "➡️ Packaging $fname..."
    zip -j "$zip_file" "$file" > /dev/null

    # Check if Lambda exists
    if aws lambda get-function --function-name "$fname" --region "$AWS_REGION" >/dev/null 2>&1; then
        echo "   🔄 Function exists, updating code..."
        aws lambda update-function-code \
            --region "$AWS_REGION" \
            --function-name "$fname" \
            --zip-file "fileb://$zip_file"
    else
        echo "   ✨ Function does not exist, creating..."
        # Use EC2 IAM Role automatically assigned to Lambda (no ARN hardcoding)
        aws lambda create-function \
            --region "$AWS_REGION" \
            --function-name "$fname" \
            --runtime "$PYTHON_RUNTIME" \
            --role $(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/) \
            --handler "$fname.lambda_handler" \
            --zip-file "fileb://$zip_file"
    fi

    # Attach the PyMySQL Layer dynamically
    echo "   🔗 Attaching PyMySQL Layer..."
    aws lambda update-function-configuration \
        --region "$AWS_REGION" \
        --function-name "$fname" \
        --layers "arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:layer:$LAYER_NAME:$LAYER_VERSION"
done

echo "✅ All Lambdas created/updated and Layer attached"

# ----------------------------------------------------------
# 🧪 STEP 5 — TEST ONE LAMBDA
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
# 🎉 FINISHED
# ----------------------------------------------------------
echo "🎉 Full GitHub + AWS Lambda Deployment Completed!"