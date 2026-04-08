#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — EC2 Docker & Apache Health Check
# ==========================================================
# This script:
#   1️⃣ Checks Docker is running
#   2️⃣ Navigates to the repo root
#   3️⃣ Builds Docker image
#   4️⃣ Removes old container
#   5️⃣ Runs new container
#   6️⃣ Performs local health check
# ==========================================================

set -e  # Exit immediately on error

# ----------------------------
# Colors for output
# ----------------------------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; }

# ----------------------------
# 1️⃣ Check Docker is running
# ----------------------------
systemctl is-active --quiet docker && pass "Docker running" || { fail "Docker not running"; exit 1; }

# ----------------------------
# 2️⃣ Navigate to repo root
# ----------------------------
REPO_DIR=~/charlie-cafe-devops
if [ ! -d "$REPO_DIR" ]; then
    fail "Repo directory $REPO_DIR not found!"
    exit 1
fi
cd "$REPO_DIR"
pass "Navigated to repo: $REPO_DIR"

# ----------------------------
# 3️⃣ Build Docker image
# ----------------------------
DOCKERFILE_DIR="$REPO_DIR/docker/apache-php"
if [ ! -f "$DOCKERFILE_DIR/Dockerfile" ]; then
    fail "Dockerfile not found in $DOCKERFILE_DIR"
    exit 1
fi

docker build -t charlie-cafe -f "$DOCKERFILE_DIR/Dockerfile" "$REPO_DIR" && pass "Docker image built successfully" || { fail "Docker build failed"; exit 1; }

# ----------------------------
# 4️⃣ Remove old container
# ----------------------------
docker rm -f charlie-cafe || true

# ----------------------------
# 5️⃣ Run new container
# ----------------------------
docker run -d -p 80:80 --name charlie-cafe charlie-cafe && pass "Container started" || { fail "Container failed"; exit 1; }

# ----------------------------
# 6️⃣ Wait a few seconds
# ----------------------------
sleep 10

# ----------------------------
# 7️⃣ Test Apache container
# ----------------------------
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$HTTP_STATUS" == "200" ]; then
    pass "Apache container responding on localhost"
else
    fail "Apache container NOT responding, HTTP $HTTP_STATUS"
    echo "Showing last 20 lines of container logs:"
    docker logs charlie-cafe | tail -n 20
    exit 1
fi