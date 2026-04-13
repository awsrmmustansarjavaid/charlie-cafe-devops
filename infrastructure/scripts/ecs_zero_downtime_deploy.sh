#!/bin/bash

# ==========================================================
# 🚀 Enterprise Zero-Downtime CI/CD Pipeline
# ECS + ECR + Rolling Deployment (No CodeDeploy, Free Tier)
# ==========================================================

set -e  # Stop script if any command fails

# -----------------------------
# 🧾 CONFIGURATION VARIABLES
# -----------------------------
ACCOUNT_ID=537236558357
REGION=us-east-1
REPOSITORY=charlie-cafe
CLUSTER_NAME=charlie-cluster
SERVICE_NAME=charlie-service
DOCKERFILE_PATH=docker/apache-php/Dockerfile
TASK_DEFINITION_FILE=task-definition.json

# -----------------------------
# 🐳 STEP 1: BUILD DOCKER IMAGE
# -----------------------------
echo "🚀 [STEP 1] Building Docker image..."
docker build -t $REPOSITORY -f $DOCKERFILE_PATH .

# -----------------------------
# 🏷 STEP 2: TAG IMAGE FOR ECR
# -----------------------------
echo "🏷 [STEP 2] Tagging image for ECR..."
docker tag $REPOSITORY:latest \
$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY:latest

# -----------------------------
# 🔐 STEP 3: LOGIN TO AMAZON ECR
# (Uses EC2 IAM Role automatically)
# -----------------------------
echo "🔐 [STEP 3] Logging in to ECR..."
aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin \
$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# -----------------------------
# 📤 STEP 4: PUSH IMAGE TO ECR
# -----------------------------
echo "📤 [STEP 4] Pushing image to ECR..."
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY:latest

# -----------------------------
# 📦 STEP 5: REGISTER TASK DEFINITION
# -----------------------------
echo "📦 [STEP 5] Registering new ECS task definition..."
aws ecs register-task-definition \
  --cli-input-json file://$TASK_DEFINITION_FILE

# -----------------------------
# 🚀 STEP 6: UPDATE ECS SERVICE
# (Triggers Rolling Deployment)
# -----------------------------
echo "🚀 [STEP 6] Updating ECS service (Rolling Deployment)..."
aws ecs update-service \
  --cluster $CLUSTER_NAME \
  --service $SERVICE_NAME \
  --force-new-deployment

# -----------------------------
# ✅ FINAL STATUS
# -----------------------------
echo "🎉 Deployment triggered successfully!"
echo "📊 Check status with:"
echo "aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME"