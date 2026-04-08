#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — Fully Automated Lambda Deployment
# ==========================================================
# Features:
# 1. Pull latest code from GitHub
# 2. Build and publish PyMySQL Lambda layer
# 3. Update existing Lambda functions code safely
# 4. Attach PyMySQL layer to all Lambdas
# 5. Waits properly to avoid ResourceConflictException
# ==========================================================

set -euo pipefail

# -------------------------------
# CONFIGURATION
# -------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"
GITHUB_REPO="https://github.com/your github username /charlie-cafe-devops.git"
LOCAL_REPO="charlie-cafe-devops"
LAMBDA_SUBDIR="app/backend/lambda"
LAYER_NAME="pymysql-layer"
LAYER_PACKAGE="pymysql-layer.zip"
PYTHON_RUNTIME="python3.10"

LAMBDAS=(
  "CafeOrderProcessor:CafeOrderProcessor.py"
  "CafeMenuLambda:CafeMenuLambda.py"
  "CafeOrderStatusLambda:CafeOrderStatusLambda.py"
  "GetOrderStatusLambda:GetOrderStatusLambda.py"
  "CafeOrderWorkerLambda:CafeOrderWorkerLambda.py"
  "AdminMarkPaidLambda:AdminMarkPaidLambda.py"
  "CafeAnalyticsLambda:CafeAnalyticsLambda.py"
  "hr-attendance:hr-attendance.py"
  "hr-employee-profile:hr-employee-profile.py"
  "hr-attendance-history:hr-attendance-history.py"
  "hr-leaves-holidays:hr-leaves-holidays.py"
  "cafe-attendance-admin-service:cafe-attendance-admin-service.py"
)

# -------------------------------
# FETCH AWS ACCOUNT ID
# -------------------------------
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"

# -------------------------------
# CLONE OR UPDATE GITHUB
# -------------------------------
if [[ -d "$LOCAL_REPO" ]]; then
  echo "📦 Updating repo..."
  cd "$LOCAL_REPO"
  git reset --hard
  git pull origin main
  cd ..
else
  echo "📦 Cloning repo..."
  git clone "$GITHUB_REPO"
fi
echo "✅ Repo ready"

# -------------------------------
# BUILD PYMYSQL LAYER
# -------------------------------
echo "🏗️ Building PyMySQL Lambda Layer..."
rm -rf python "$LAYER_PACKAGE"
mkdir python
pip3 install pymysql -t python/ --no-cache-dir > /dev/null
zip -r "$LAYER_PACKAGE" python > /dev/null
rm -rf python
echo "✅ Layer packaged"

# -------------------------------
# PUBLISH LAYER
# -------------------------------
LAYER_ARN=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --zip-file fileb://"$LAYER_PACKAGE" \
  --compatible-runtimes python3.10 python3.11 python3.12 \
  --query 'LayerVersionArn' --output text)
echo "✅ Layer published: $LAYER_ARN"

# -------------------------------
# STEP 1: UPDATE ALL LAMBDA CODES
# -------------------------------
echo "🚀 Updating Lambda codes..."
for FUNC in "${LAMBDAS[@]}"; do
  FUNC_NAME="${FUNC%%:*}"
  FILE_NAME="${FUNC##*:}"
  ZIP_FILE="${FUNC_NAME}.zip"

  zip -j "$ZIP_FILE" "$LOCAL_REPO/$LAMBDA_SUBDIR/$FILE_NAME" > /dev/null

  echo "🔄 Updating code for $FUNC_NAME..."
  aws lambda update-function-code --function-name "$FUNC_NAME" --zip-file fileb://"$ZIP_FILE"
  aws lambda wait function-updated --function-name "$FUNC_NAME"  # WAIT until update finishes

  rm -f "$ZIP_FILE"
  echo "✅ Code updated: $FUNC_NAME"
done

# -------------------------------
# STEP 2: ATTACH LAYER TO ALL LAMBDAS
# -------------------------------
echo "🔗 Attaching PyMySQL Layer to all Lambdas..."
for FUNC in "${LAMBDAS[@]}"; do
  FUNC_NAME="${FUNC%%:*}"
  echo "🔄 Updating configuration for $FUNC_NAME..."
  aws lambda update-function-configuration --function-name "$FUNC_NAME" --layers "$LAYER_ARN"
  aws lambda wait function-updated --function-name "$FUNC_NAME"
  echo "✅ Layer attached: $FUNC_NAME"
done

echo "🎉 All Lambda functions updated and layer attached successfully!"