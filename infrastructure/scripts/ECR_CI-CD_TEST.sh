#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — ECR PUSH + CI/CD TEST SCRIPT
# ----------------------------------------------------------
# ✔ Login to AWS ECR
# ✔ Build Docker Image
# ✔ Tag Image
# ✔ Push to ECR
# ✔ Trigger GitHub Pipeline
# ✔ Display ALB URL
# ==========================================================

# -------------------------------
# 🔧 CONFIGURATION (EDIT THESE)
# -------------------------------
AWS_REGION="us-east-1"
ECR_URI="YOUR_ECR_URI"              # e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe
IMAGE_NAME="charlie-cafe"
IMAGE_TAG="latest"
ALB_DNS="YOUR-ALB-DNS"             # e.g. charlie-alb-123.us-east-1.elb.amazonaws.com

# -------------------------------
# 1️⃣ LOGIN TO ECR
# -------------------------------
echo "🔐 Logging into AWS ECR..."

aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $ECR_URI

if [ $? -ne 0 ]; then
  echo "❌ ECR Login Failed"
  exit 1
fi

echo "✅ ECR Login Successful"
echo "----------------------------------------"

# -------------------------------
# 2️⃣ BUILD DOCKER IMAGE
# -------------------------------
echo "🐳 Building Docker Image..."

docker build -t $IMAGE_NAME .

if [ $? -ne 0 ]; then
  echo "❌ Docker Build Failed"
  exit 1
fi

echo "✅ Docker Build Successful"
echo "----------------------------------------"

# -------------------------------
# 3️⃣ TAG DOCKER IMAGE
# -------------------------------
echo "🏷️ Tagging Image..."

docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_URI:$IMAGE_TAG

if [ $? -ne 0 ]; then
  echo "❌ Docker Tag Failed"
  exit 1
fi

echo "✅ Image Tagged Successfully"
echo "----------------------------------------"

# -------------------------------
# 4️⃣ PUSH TO ECR
# -------------------------------
echo "📤 Pushing Image to ECR..."

docker push $ECR_URI:$IMAGE_TAG

if [ $? -ne 0 ]; then
  echo "❌ Docker Push Failed"
  exit 1
fi

echo "✅ Image Pushed to ECR"
echo "----------------------------------------"

# -------------------------------
# 5️⃣ TEST CI/CD PIPELINE
# -------------------------------
echo "🔄 Triggering CI/CD Pipeline..."

git add .

git commit -m "🚀 Auto deployment test $(date +'%Y-%m-%d %H:%M:%S')" || echo "⚠️ Nothing to commit"

git push

if [ $? -ne 0 ]; then
  echo "❌ Git Push Failed"
  exit 1
fi

echo "✅ Pipeline Triggered Successfully"
echo "----------------------------------------"

# -------------------------------
# 6️⃣ ACCESS APPLICATION
# -------------------------------
echo "🌐 Application URL:"
echo "http://$ALB_DNS"

echo "----------------------------------------"
echo "🎉 ALL TASKS COMPLETED SUCCESSFULLY"