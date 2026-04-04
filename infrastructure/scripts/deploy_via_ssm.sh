#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — Auto Deployment Script via SSM
# ----------------------------------------------------------
# This script is intended to run via AWS SSM or manually on EC2.
# It uses git pull, builds docker, and redeploys container.
# Compatible with GitHub Actions CI/CD using AWS Access Keys.
# ==========================================================

# -----------------------------
# 0️⃣ Variables (edit as needed)
# -----------------------------
APP_DIR="/home/ec2-user/charlie-cafe-devops"
DOCKER_IMAGE="charlie-cafe"
DOCKER_CONTAINER="cafe-app"
GIT_BRANCH="main"

# -----------------------------
# 1️⃣ Ensure app directory exists
# -----------------------------
if [ ! -d "$APP_DIR" ]; then
    echo "📥 App directory not found, cloning repository..."
    git clone -b $GIT_BRANCH https://github.com/YOUR_USERNAME/charlie-cafe-devops.git "$APP_DIR"
else
    echo "✅ App directory exists, pulling latest changes..."
    cd "$APP_DIR" || exit
    git fetch origin $GIT_BRANCH
    git reset --hard origin/$GIT_BRANCH
fi

# -----------------------------
# 2️⃣ Enter app directory
# -----------------------------
cd "$APP_DIR" || exit

# -----------------------------
# 3️⃣ Build Docker Image
# -----------------------------
echo "🐳 Building Docker image..."
docker build -t $DOCKER_IMAGE -f docker/apache-php/Dockerfile .

# -----------------------------
# 4️⃣ Stop & Remove Existing Container
# -----------------------------
echo "🛑 Stopping old container (if exists)..."
docker rm -f $DOCKER_CONTAINER || true

# -----------------------------
# 5️⃣ Run New Container
# -----------------------------
echo "🚀 Running new container..."
docker run -d -p 80:80 --name $DOCKER_CONTAINER $DOCKER_IMAGE

# -----------------------------
# 6️⃣ Health Check
# -----------------------------
echo "❤️ Running health check..."
if curl -f http://localhost/health.php >/dev/null 2>&1; then
    echo "✅ Health check passed"
else
    echo "❌ Health check FAILED"
    exit 1
fi

# -----------------------------
# 7️⃣ Success
# -----------------------------
echo "🎉 Deployment completed successfully!"