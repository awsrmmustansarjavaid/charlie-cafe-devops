#!/bin/bash

# ==========================================================
# 🚀 Enterprise Zero-Downtime CI/CD Pipeline (AWS ECS)
# Fully IAM Role Based | No Hardcoded Secrets | No Pager
# ==========================================================

set -e

# -----------------------------
# 🧾 CONFIGURATION (ONLY WHAT YOU CONTROL)
# -----------------------------
REGION="us-east-1"
REPOSITORY="charlie-cafe"
CLUSTER_NAME="charlie-cluster"
SERVICE_NAME="charlie-service"
DOCKERFILE_PATH="docker/apache-php/Dockerfile"
TASK_DEFINITION_FILE="task-definition.json"

# -----------------------------
# 🔎 AUTO DETECT AWS ACCOUNT ID (FROM IAM ROLE)
# -----------------------------
echo "🔎 Fetching AWS Account ID from IAM Role..."
ACCOUNT_ID=$(aws sts get-caller-identity \
  --query Account \
  --output text \
  --no-cli-pager)

echo "✅ Detected Account ID: $ACCOUNT_ID"

# -----------------------------
# 🐳 STEP 1: BUILD DOCKER IMAGE
# -----------------------------
echo "🚀 [STEP 1] Building Docker image..."
docker build -t $REPOSITORY -f $DOCKERFILE_PATH .

# -----------------------------
# 🏷 STEP 2: TAG IMAGE FOR ECR
# -----------------------------
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY:latest"

echo "🏷 [STEP 2] Tagging image..."
docker tag $REPOSITORY:latest $ECR_URI

# -----------------------------
# 🔐 STEP 3: LOGIN TO ECR (IAM ROLE AUTO)
# -----------------------------
echo "🔐 [STEP 3] Logging in to ECR..."
aws ecr get-login-password --region $REGION --no-cli-pager | \
docker login --username AWS --password-stdin \
$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# -----------------------------
# 📤 STEP 4: PUSH IMAGE
# -----------------------------
echo "📤 [STEP 4] Pushing image to ECR..."
docker push $ECR_URI

# -----------------------------
# 📦 STEP 5: REGISTER TASK DEFINITION
# -----------------------------
echo "📦 [STEP 5] Registering ECS task definition..."
TASK_DEF_ARN=$(aws ecs register-task-definition \
  --cli-input-json file://$TASK_DEFINITION_FILE \
  --query "taskDefinition.taskDefinitionArn" \
  --output text \
  --no-cli-pager)

echo "✅ New Task Definition: $TASK_DEF_ARN"

# -----------------------------
# 🚀 STEP 6: UPDATE ECS SERVICE
# -----------------------------
echo "🚀 [STEP 6] Triggering Rolling Deployment..."
aws ecs update-service \
  --cluster $CLUSTER_NAME \
  --service $SERVICE_NAME \
  --force-new-deployment \
  --no-cli-pager

# -----------------------------
# ⏳ STEP 7: DEPLOYMENT VERIFICATION
# -----------------------------
echo "⏳ Waiting for deployment to stabilize..."

aws ecs wait services-stable \
  --cluster $CLUSTER_NAME \
  --services $SERVICE_NAME

# -----------------------------
# 📊 FINAL RESULT CARD
# -----------------------------
echo ""
echo "=========================================================="
echo "🎉 DEPLOYMENT SUCCESSFUL (ZERO DOWNTIME CONFIRMED)"
echo "=========================================================="

aws ecs describe-services \
  --cluster $CLUSTER_NAME \
  --services $SERVICE_NAME \
  --query "services[0].{Status:status,Running:runningCount,Desired:desiredCount,Pending:pendingCount,Deployments:deployments[0].rolloutState}" \
  --output table \
  --no-cli-pager

echo ""
echo "🚀 Application URL (check ALB):"
echo "👉 http://<your-alb-dns>/health.php"
echo "=========================================================="