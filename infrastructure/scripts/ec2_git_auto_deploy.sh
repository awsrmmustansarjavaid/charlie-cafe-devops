#!/bin/bash

# ==========================================================
# 🚀 Charlie Cafe — EC2 Git Auto-Deploy Script
# ==========================================================
# This script:
# 1️⃣ Verifies SSH connection to GitHub
# 2️⃣ Clones the repository (if not already cloned)
# 3️⃣ Enters the repository folder
# 4️⃣ Adds, commits, and pushes changes to main branch
# ==========================================================

# -------------------------------
# 1️⃣ Verify SSH connection to GitHub
# -------------------------------
echo "🔍 Verifying GitHub SSH access..."
ssh -T git@github.com || { echo "❌ SSH connection to GitHub failed!"; exit 1; }
echo "✅ SSH connection to GitHub successful!"

# -------------------------------
# 2️⃣ Define repository info
# -------------------------------
REPO_SSH="git@github.com:awsrmmustansarjavaid/charlie-cafe-devops.git"
REPO_DIR="$HOME/charlie-cafe-devops"

# -------------------------------
# 3️⃣ Clone repository if not exists
# -------------------------------
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "📥 Cloning repository..."
    git clone "$REPO_SSH" "$REPO_DIR" || { echo "❌ Failed to clone repository!"; exit 1; }
else
    echo "📂 Repository already exists, pulling latest changes..."
    cd "$REPO_DIR"
    git pull origin main
fi

# -------------------------------
# 4️⃣ Enter repository folder
# -------------------------------
cd "$REPO_DIR" || { echo "❌ Failed to enter repository directory!"; exit 1; }

# -------------------------------
# 5️⃣ Add, commit, and push changes
# -------------------------------
echo "📝 Adding, committing, and pushing changes..."
git add .
git commit -m "Test auto-deploy" || echo "⚠️ No changes to commit."
git push origin main || { echo "❌ Failed to push changes!"; exit 1; }

echo "🚀 Auto-deploy completed successfully!"