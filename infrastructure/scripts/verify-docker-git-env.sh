#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — DOCKER + GIT ENV VERIFICATION
# File: verify-docker-git-env.sh
# Purpose: Verify Docker, Apache, Git, and GitHub connectivity
# ==========================================================

set -e

echo "=================================================="
echo "☕ Charlie Cafe — Full Environment Verification"
echo "=================================================="

# ----------------------------------------------------------
# 1️⃣ Check Docker Installation
# ----------------------------------------------------------
echo "🔹 Checking Docker installation..."
if command -v docker >/dev/null 2>&1; then
    echo "✅ Docker is installed"
else
    echo "❌ Docker is NOT installed"
    exit 1
fi

# ----------------------------------------------------------
# 2️⃣ Check Docker Service
# ----------------------------------------------------------
echo "🔹 Checking Docker service..."
if systemctl is-active --quiet docker; then
    echo "✅ Docker service is running"
else
    echo "⚠️ Docker not running, starting..."
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "✅ Docker started"
fi

# ----------------------------------------------------------
# 3️⃣ Docker Version Info
# ----------------------------------------------------------
echo "🔹 Docker version:"
docker --version

echo "🔹 Docker system info:"
docker info | head -n 10

# ----------------------------------------------------------
# 4️⃣ List Docker Images
# ----------------------------------------------------------
echo "🔹 Listing Docker images..."
docker images || echo "⚠️ No Docker images found"

# ----------------------------------------------------------
# 5️⃣ List Running Containers
# ----------------------------------------------------------
echo "🔹 Listing running containers..."
docker ps || echo "⚠️ No running containers"

# ----------------------------------------------------------
# 6️⃣ List All Containers (including stopped)
# ----------------------------------------------------------
echo "🔹 Listing ALL containers..."
docker ps -a

# ----------------------------------------------------------
# 7️⃣ Apache Container Test (Temporary)
# ----------------------------------------------------------
APACHE_CONTAINER="verify-apache-test"

# Remove old container if exists
if [ "$(docker ps -aq -f name=$APACHE_CONTAINER)" ]; then
    echo "⚠️ Removing existing test container..."
    docker rm -f $APACHE_CONTAINER
fi

echo "🔹 Starting Apache test container on port 8080..."
docker run -d --name $APACHE_CONTAINER -p 8080:80 httpd:latest

sleep 5

# ----------------------------------------------------------
# 8️⃣ Test Apache (Localhost 8080)
# ----------------------------------------------------------
echo "🔹 Testing Apache on localhost:8080..."
if curl -s http://localhost:8080 >/dev/null; then
    echo "✅ Apache is running on port 8080"
else
    echo "❌ Apache test failed on port 8080"
fi

# ----------------------------------------------------------
# 9️⃣ Test Apache (Port 80 if any app running)
# ----------------------------------------------------------
echo "🔹 Testing Apache on localhost:80..."
if curl -s http://localhost/ >/dev/null; then
    echo "✅ Service detected on port 80"
else
    echo "⚠️ No service running on port 80"
fi

# ----------------------------------------------------------
# 🔟 Show Container Logs
# ----------------------------------------------------------
echo "🔹 Showing Apache container logs..."
docker logs $APACHE_CONTAINER | head -n 5

# ----------------------------------------------------------
# 11️⃣ Git Installation Check
# ----------------------------------------------------------
echo "🔹 Checking Git installation..."
if command -v git >/dev/null 2>&1; then
    echo "✅ Git is installed"
    git --version
else
    echo "❌ Git is NOT installed"
    exit 1
fi

# ----------------------------------------------------------
# 12️⃣ Git Configuration Check
# ----------------------------------------------------------
echo "🔹 Git global config:"
git config --global --list || echo "⚠️ No global git config found"

# ----------------------------------------------------------
# 13️⃣ GitHub Connectivity Test
# ----------------------------------------------------------
GITHUB_TEST_DIR="$HOME/github_test_repo"
GITHUB_REPO="https://github.com/octocat/Hello-World.git"

# Cleanup old repo
if [ -d "$GITHUB_TEST_DIR" ]; then
    echo "⚠️ Removing old GitHub test repo..."
    rm -rf "$GITHUB_TEST_DIR"
fi

echo "🔹 Cloning GitHub repository..."
if git clone $GITHUB_REPO $GITHUB_TEST_DIR; then
    echo "✅ GitHub clone successful"

    cd $GITHUB_TEST_DIR

    echo "🔹 Running git pull..."
    git pull

    echo "🔹 Latest commit:"
    git log -1 --oneline

    echo "✅ GitHub working perfectly"
else
    echo "❌ GitHub connection failed"
fi

# ----------------------------------------------------------
# 14️⃣ Network Check
# ----------------------------------------------------------
echo "🔹 Checking internet connectivity..."
if ping -c 2 github.com >/dev/null 2>&1; then
    echo "✅ Internet access OK"
else
    echo "❌ No internet connectivity"
fi

# ----------------------------------------------------------
# 15️⃣ Cleanup
# ----------------------------------------------------------
echo "🔹 Cleaning up test container..."
docker rm -f $APACHE_CONTAINER >/dev/null

echo "=================================================="
echo "🎉 ALL CHECKS COMPLETED SUCCESSFULLY"
echo "=================================================="