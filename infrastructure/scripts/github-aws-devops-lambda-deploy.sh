#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — Full GitHub + AWS DevOps + Lambda Deploy Script
# ----------------------------------------------------------
# AUTOMATION FLOW:
#   1️⃣ Clone/Pull GitHub repo
#   2️⃣ Build PyMySQL Lambda Layer
#   3️⃣ Create Lambda functions if they don't exist
#   4️⃣ Attach Layer to Lambdas
#   5️⃣ Package & deploy Lambda functions
#   6️⃣ Test Lambda
#
# REQUIREMENTS:
#   - AWS CLI configured (or EC2 IAM role with Lambda/S3 permissions)
#   - Git installed on EC2
#
# USAGE:
#   ./github-aws-devops-lambda-deploy.sh
# ==========================================================

set -e

# ----------------------------------------------------------
# 🔧 CONFIGURATION
# ----------------------------------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"
GITHUB_REPO_URL="https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO.git"
LOCAL_REPO_DIR="charlie-cafe-devops"
LAMBDA_DIR="$LOCAL_REPO_DIR/app/backend/lambda"
LAYER_DIR="layer"
ZIP_LAYER="pymysql-layer.zip"
ZIP_OUTPUT_DIR="lambda_zips"
LAYER_NAME="pymysql-layer"
TEST_LAMBDA="CafeOrderProcessor"
PYTHON_RUNTIME="python3.11"
ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/YourLambdaExecutionRole"  # Adjust if needed

# ----------------------------------------------------------
# ⚡ DYNAMIC AWS ACCOUNT ID
# ----------------------------------------------------------
echo "⚡ Fetching AWS Account ID dynamically..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✅ AWS Account ID detected: $AWS_ACCOUNT_ID"

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
echo "✅ GitHub repository ready"

# ----------------------------------------------------------
# 🧹 CLEAN OLD FILES
# ----------------------------------------------------------
echo "🧹 Cleaning old build files..."
rm -rf "$LAYER_DIR" "$ZIP_LAYER" "$ZIP_OUTPUT_DIR"

# ----------------------------------------------------------
# 🏗️ STEP 2 — BUILD LAMBDA LAYER (PyMySQL)
# ----------------------------------------------------------
echo "🏗️ Building Lambda Layer..."
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
# 🔗 STEP 4 — CREATE / ATTACH LAMBDA FUNCTIONS
# ----------------------------------------------------------
echo "🔗 Creating/Updating Lambda functions..."

mkdir -p "$ZIP_OUTPUT_DIR"

for file in "$LAMBDA_DIR"/*.py; do
    fname=$(basename "$file" .py)
    zip_file="$ZIP_OUTPUT_DIR/$fname.zip"

    echo "➡️ Packaging $fname..."
    zip -j "$zip_file" "$file" > /dev/null

    # Check if Lambda function exists
    if aws lambda get-function --function-name "$fname" --region "$AWS_REGION" >/dev/null 2>&1; then
        echo "   🔄 Function exists, updating code..."
        aws lambda update-function-code \
            --region "$AWS_REGION" \
            --function-name "$fname" \
            --zip-file "fileb://$zip_file"
    else
        echo "   ✨ Function does not exist, creating..."
        aws lambda create-function \
            --region "$AWS_REGION" \
            --function-name "$fname" \
            --runtime "$PYTHON_RUNTIME" \
            --role "$ROLE_ARN" \
            --handler "$fname.lambda_handler" \
            --zip-file "fileb://$zip_file"
    fi

    # Attach Layer
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
# 🎉 FINAL
# ----------------------------------------------------------
echo "🎉 Full GitHub + AWS DevOps + Lambda Deployment Completed!"