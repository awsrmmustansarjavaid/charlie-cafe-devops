#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT
# ----------------------------------------------------------
# ✔ Initialize Git & push to GitHub
# ✔ Build Docker image
# ✔ Run Docker container
# ✔ Clean old container automatically
# ==========================================================

# ❗ Exit immediately if any command fails
set -e

# ==========================================================
# 🔧 VARIABLES (EDIT THESE BEFORE RUN)
# ==========================================================
PROJECT_DIR="charlie-cafe"             # Local project folder
REPO_NAME="charlie-cafe-devops"       # GitHub repo name
GITHUB_USERNAME="YOUR_USERNAME"       # Your GitHub username

IMAGE_NAME="charlie-cafe"             # Docker image name
CONTAINER_NAME="cafe-app"             # Docker container name
PORT="80"                             # App port

# ==========================================================
# 📁 STEP 1 — MOVE INTO PROJECT DIRECTORY
# ==========================================================
echo "📂 Moving into project directory..."
cd $PROJECT_DIR || { echo "❌ Project folder not found!"; exit 1; }

# ==========================================================
# 🔧 STEP 2 — INITIALIZE GIT
# ==========================================================
echo "🔧 Initializing Git repository..."
git init

# Add all files
echo "📦 Adding project files..."
git add .

# Commit files
echo "💾 Creating initial commit..."
git commit -m "Initial commit - Charlie Cafe Project"

# ==========================================================
# 🔗 STEP 3 — CONNECT TO GITHUB
# ==========================================================
echo "🔗 Connecting to GitHub repository..."
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git || true

# Set main branch
echo "🌿 Setting main branch..."
git branch -M main

# Push to GitHub
echo "🚀 Pushing code to GitHub..."
git push -u origin main

# ==========================================================
# 🐳 STEP 4 — DOCKER BUILD
# ==========================================================
echo "🏗️ Building Docker image..."
docker build -t $IMAGE_NAME .

# ==========================================================
# 🧹 STEP 5 — CLEAN OLD CONTAINER (IF EXISTS)
# ==========================================================
echo "🧹 Removing old container if exists..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

# ==========================================================
# 🚀 STEP 6 — RUN DOCKER CONTAINER
# ==========================================================
echo "🚀 Running Docker container..."
docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME

# ==========================================================
# 📊 STEP 7 — SHOW STATUS
# ==========================================================
echo "📊 Running containers:"
docker ps

# ==========================================================
# ✅ DONE
# ==========================================================
echo "🎉 Charlie Cafe DevOps setup completed successfully!"
echo "🌐 Access your app at: http://YOUR_EC2_PUBLIC_IP"