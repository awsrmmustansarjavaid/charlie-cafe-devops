#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — Fully Automated Lambda Deployment (PRO)
# ==========================================================
# Features:
# ✔ Git pull / clone
# ✔ Build & publish PyMySQL layer
# ✔ Update Lambda code with progress tracking
# ✔ Attach layer to all Lambdas
# ✔ Spinner during wait (no more "stuck" feeling)
# ✔ Clean logs + progress counter
# ==========================================================

set -euo pipefail

# -------------------------------
# CONFIGURATION
# -------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"
GITHUB_REPO="https://github.com/awsrmmustansarjavaid/charlie-cafe-devops.git"
LOCAL_REPO="charlie-cafe-devops"
LAMBDA_SUBDIR="app/backend/lambda"
LAYER_NAME="pymysql-layer"
LAYER_PACKAGE="pymysql-layer.zip"

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

TOTAL=${#LAMBDAS[@]}

# -------------------------------
# SPINNER FUNCTION (for wait)
# -------------------------------
spin() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'

  while kill -0 $pid 2>/dev/null; do
    for i in $(seq 0 3); do
      printf "\r⏳ Processing... ${spinstr:$i:1}"
      sleep $delay
    done
  done
  printf "\r"
}

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
  git reset --hard > /dev/null
  git pull origin main > /dev/null
  cd ..
else
  echo "📦 Cloning repo..."
  git clone "$GITHUB_REPO" > /dev/null
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
echo "🚀 Publishing layer..."
LAYER_ARN=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --zip-file fileb://"$LAYER_PACKAGE" \
  --compatible-runtimes python3.10 python3.11 python3.12 \
  --query 'LayerVersionArn' --output text)

echo "✅ Layer published: $LAYER_ARN"

# -------------------------------
# STEP 1: UPDATE ALL LAMBDA CODES
# -------------------------------
echo ""
echo "🚀 Updating Lambda codes..."
COUNT=0

for FUNC in "${LAMBDAS[@]}"; do
  COUNT=$((COUNT + 1))
  FUNC_NAME="${FUNC%%:*}"
  FILE_NAME="${FUNC##*:}"
  ZIP_FILE="${FUNC_NAME}.zip"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 [$COUNT/$TOTAL] Updating: $FUNC_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  zip -j "$ZIP_FILE" "$LOCAL_REPO/$LAMBDA_SUBDIR/$FILE_NAME" > /dev/null

  aws lambda update-function-code \
    --function-name "$FUNC_NAME" \
    --zip-file fileb://"$ZIP_FILE" > /dev/null

  # Spinner while waiting
  aws lambda wait function-updated --function-name "$FUNC_NAME" &
  spin $!
  wait $!

  rm -f "$ZIP_FILE"

  echo "✅ Code updated: $FUNC_NAME"
done

echo ""
echo "🎉 All Lambda codes updated!"

# -------------------------------
# STEP 2: ATTACH LAYER
# -------------------------------
echo ""
echo "🔗 Attaching PyMySQL Layer..."
COUNT=0

for FUNC in "${LAMBDAS[@]}"; do
  COUNT=$((COUNT + 1))
  FUNC_NAME="${FUNC%%:*}"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔗 [$COUNT/$TOTAL] Attaching Layer: $FUNC_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  aws lambda update-function-configuration \
    --function-name "$FUNC_NAME" \
    --layers "$LAYER_ARN" > /dev/null

  # Spinner while waiting
  aws lambda wait function-updated --function-name "$FUNC_NAME" &
  spin $!
  wait $!

  echo "✅ Layer attached: $FUNC_NAME"
done

echo ""
echo "🎉 ALL DONE — Lambda + Layer deployment successful!"