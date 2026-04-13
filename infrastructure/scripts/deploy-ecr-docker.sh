#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe - Secure Docker Build & ECR Deploy Script
# ==========================================================
# PURPOSE:
# Fully dynamic & secure deployment using IAM Role (no hardcoding)
#
# FEATURES:
# ✔ No AWS credentials stored
# ✔ Auto-detect AWS Account ID
# ✔ Uses IAM Role attached to EC2
# ✔ Safe & production-ready
#
# ==========================================================

set -e  # Exit immediately if any command fails

# -----------------------------
# 🔧 CONFIGURATION (SAFE)
# -----------------------------
PROJECT_DIR="$HOME/charlie-cafe-devops"
DOCKERFILE_PATH="docker/apache-php/Dockerfile"
IMAGE_NAME="charlie-cafe"
ECR_REPO="charlie-cafe"

# Auto-detect AWS region (fallback to us-east-1)
AWS_REGION=$(aws configure get region || echo "us-east-1")

# Auto-detect AWS Account ID (IAM role must have sts:GetCallerIdentity)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Construct ECR URL dynamically
ECR_URL="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# -----------------------------
# 1️⃣ VALIDATION CHECKS
# -----------------------------
echo "🔍 Validating environment..."

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found"
    exit 1
fi

# Check IAM role access
echo "🔐 Checking IAM role access..."
aws sts get-caller-identity > /dev/null

# -----------------------------
# 2️⃣ MOVE TO PROJECT ROOT
# -----------------------------
echo "📁 Moving to project directory..."
cd "$PROJECT_DIR" || { echo "❌ Project directory not found"; exit 1; }

# -----------------------------
# 3️⃣ LOGIN TO AWS ECR
# -----------------------------
echo "🔐 Logging into AWS ECR..."
aws ecr get-login-password --region "$AWS_REGION" \
| docker login --username AWS --password-stdin "$ECR_URL"

# -----------------------------
# 4️⃣ BUILD DOCKER IMAGE
# -----------------------------
echo "🐳 Building Docker image..."
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .

# -----------------------------
# 5️⃣ TAG IMAGE FOR ECR
# -----------------------------
echo "🏷️ Tagging image..."
docker tag "$IMAGE_NAME:latest" "$ECR_URL/$ECR_REPO:latest"

# -----------------------------
# 6️⃣ PUSH IMAGE TO ECR
# -----------------------------
echo "🚀 Pushing image to ECR..."
docker push "$ECR_URL/$ECR_REPO:latest"

# -----------------------------
# ✅ SUCCESS MESSAGE
# -----------------------------
echo "=========================================================="
echo "✅ Deployment completed successfully!"
echo "📦 Image: $ECR_URL/$ECR_REPO:latest"
echo "🌍 Region: $AWS_REGION"
echo "🆔 Account: $ACCOUNT_ID"
echo "=========================================================="