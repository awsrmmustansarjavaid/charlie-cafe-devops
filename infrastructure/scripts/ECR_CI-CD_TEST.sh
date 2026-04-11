#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — SIMPLE DEVOPS HELPER SCRIPT
# ----------------------------------------------------------
# ✔ Auto Detect ECR URI
# ✔ Auto Detect ALB DNS
# ✔ Push Code to Trigger CI/CD
# ==========================================================

echo "🚀 Starting Simple DevOps Helper..."

# -------------------------------
# 🔧 AUTO CONFIG
# -------------------------------
AWS_REGION=$(aws configure get region)

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Get ECR Repo (first repo)
ECR_REPO=$(aws ecr describe-repositories \
  --query "repositories[0].repositoryName" \
  --output text)

ECR_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO"

# Get ALB DNS
ALB_DNS=$(aws elbv2 describe-load-balancers \
  --query "LoadBalancers[0].DNSName" \
  --output text)

echo "----------------------------------------"
echo "📦 ECR URI: $ECR_URI"
echo "🌐 ALB DNS: $ALB_DNS"
echo "----------------------------------------"

# -------------------------------
# 🚀 TRIGGER CI/CD
# -------------------------------
echo "🔄 Triggering GitHub Pipeline..."

git add .

git commit -m "🚀 Auto Deploy $(date +'%Y-%m-%d %H:%M:%S')" || echo "⚠️ Nothing to commit"

git push

if [ $? -ne 0 ]; then
  echo "❌ Git Push Failed"
  exit 1
fi

# -------------------------------
# ✅ DONE
# -------------------------------
echo "----------------------------------------"
echo "✅ CI/CD Triggered Successfully"
echo "🌐 App URL: http://$ALB_DNS"
echo "----------------------------------------"
