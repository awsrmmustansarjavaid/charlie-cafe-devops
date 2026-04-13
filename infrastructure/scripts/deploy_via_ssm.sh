#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — Auto Deployment Script via SSM (FINAL)
# ==========================================================
# ✔ No GitHub login prompts
# ✔ Fully automated EC2 deployment
# ✔ Safe git sync
# ✔ Docker redeploy
# ==========================================================

set -e  # stop on error

# -----------------------------
# 0️⃣ CONFIGURATION
# -----------------------------
APP_DIR="/home/ec2-user/charlie-cafe-devops"
REPO_URL="https://github.com/awsrmmustansarjavaid/charlie-cafe-devops.git"
GIT_BRANCH="main"

DOCKER_IMAGE="charlie-cafe"
DOCKER_CONTAINER="cafe-app"

# -----------------------------
# 1️⃣ CLONE OR UPDATE REPO (NO PASSWORD EVER)
# -----------------------------
if [ ! -d "$APP_DIR/.git" ]; then
    echo "📥 Cloning repository (fresh install)..."

    # FORCE NON-INTERACTIVE MODE
    GIT_TERMINAL_PROMPT=0 git clone --depth 1 -b "$GIT_BRANCH" "$REPO_URL" "$APP_DIR"

else
    echo "🔄 Updating repository..."

    cd "$APP_DIR"

    # Force clean sync with remote
    git fetch origin "$GIT_BRANCH"
    git reset --hard "origin/$GIT_BRANCH"
    git clean -fd
fi

# -----------------------------
# 2️⃣ ENTER APP DIRECTORY
# -----------------------------
cd "$APP_DIR" || exit 1

# -----------------------------
# 3️⃣ BUILD DOCKER IMAGE
# -----------------------------
echo "🐳 Building Docker image..."
docker build -t "$DOCKER_IMAGE" -f docker/apache-php/Dockerfile .

# -----------------------------
# 4️⃣ STOP OLD CONTAINER
# -----------------------------
echo "🛑 Stopping old container (if exists)..."
docker rm -f "$DOCKER_CONTAINER" || true

# -----------------------------
# 5️⃣ RUN NEW CONTAINER
# -----------------------------
echo "🚀 Starting new container..."
docker run -d -p 80:80 --name "$DOCKER_CONTAINER" "$DOCKER_IMAGE"

# -----------------------------
# 6️⃣ HEALTH CHECK
# -----------------------------
echo "❤️ Running health check..."

sleep 5

if curl -f http://localhost/health.php >/dev/null 2>&1; then
    echo "✅ Health check passed"
else
    echo "❌ Health check FAILED"
    echo "📜 Showing container logs:"
    docker logs "$DOCKER_CONTAINER"
    exit 1
fi

# -----------------------------
# 7️⃣ SUCCESS
# -----------------------------
echo "🎉 Deployment completed successfully!"