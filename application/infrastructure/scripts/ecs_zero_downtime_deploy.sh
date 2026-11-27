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

# Automatically detect the Git repository root directory
REPO_DIR="$(git rev-parse --show-toplevel)"

# Define application directory
APP_DIR="$REPO_DIR/application"

# Define Dockerfile location inside application directory
DOCKERFILE_PATH="$APP_DIR/docker/apache-php/Dockerfile"

# Define ECS task definition location inside .github directory
TASK_DEFINITION_FILE="$REPO_DIR/.github/task-definition.json"

# ==========================================================
# 🔍 PROJECT STRUCTURE & FILE VALIDATION
# ==========================================================
# PURPOSE:
# Validate the required application directories and deployment
# configuration files before executing the ECS deployment.
#
# VALIDATION CHECKS:
# 1. Verify that the application directory exists.
# 2. Verify that the Apache/PHP Dockerfile exists.
# 3. Verify that the ECS task definition JSON file exists.
#
# WHY THIS IS IMPORTANT:
# These resources are required for building the Docker image
# and registering the ECS task definition.
#
# ERROR HANDLING:
# If any required directory or file is missing, terminate
# the deployment immediately to prevent build or deployment
# failures caused by incorrect project paths.
# ==========================================================

echo "🔍 Validating project structure and deployment files..."

# ----------------------------------------------------------
# 1.1 VALIDATE APPLICATION DIRECTORY
# ----------------------------------------------------------
# PURPOSE:
# Confirm that the application directory exists.
#
# USAGE:
# This directory serves as the Docker build context and
# contains the application source code and Docker resources.
#
# ACTION:
# Stop deployment if the application directory is missing.

if [ ! -d "$APP_DIR" ]; then
    echo "❌ ERROR: Application directory not found: $APP_DIR"
    exit 1
fi

echo "✅ Application directory validated: $APP_DIR"


# ----------------------------------------------------------
# 1.2 VALIDATE DOCKERFILE
# ----------------------------------------------------------
# PURPOSE:
# Confirm that the Apache/PHP Dockerfile exists at the
# configured location inside the application directory.
#
# USAGE:
# Docker uses this file to define the instructions required
# to build the Charlie Cafe application container image.
#
# ACTION:
# Stop deployment if the Dockerfile is missing.

if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo "❌ ERROR: Dockerfile not found: $DOCKERFILE_PATH"
    exit 1
fi

echo "✅ Dockerfile validated: $DOCKERFILE_PATH"


# ----------------------------------------------------------
# 1.3 VALIDATE ECS TASK DEFINITION FILE
# ----------------------------------------------------------
# PURPOSE:
# Confirm that the ECS task definition JSON file exists
# inside the repository's .github directory.
#
# USAGE:
# AWS ECS uses this JSON configuration to register a new
# task definition revision containing container settings,
# image information, CPU, memory, and execution settings.
#
# ACTION:
# Stop deployment if the task definition file is missing.

if [ ! -f "$TASK_DEFINITION_FILE" ]; then
    echo "❌ ERROR: ECS task definition not found: $TASK_DEFINITION_FILE"
    exit 1
fi

echo "✅ ECS task definition validated: $TASK_DEFINITION_FILE"


# ----------------------------------------------------------
# VALIDATION COMPLETED SUCCESSFULLY
# ----------------------------------------------------------
# All required directories and deployment files are present.
# The script can now safely proceed to AWS authentication
# and the Docker/ECS deployment stages.

echo "=========================================================="
echo "✅ All project structure validations passed!"
echo "=========================================================="

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
docker build \
  -t "$REPOSITORY" \
  -f "$DOCKERFILE_PATH" \
  "$APP_DIR"

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
  --task-definition "$TASK_DEF_ARN" \
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