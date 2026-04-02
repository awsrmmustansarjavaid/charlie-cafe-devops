#!/bin/bash

# ===============================
# ☕ Charlie Cafe — Git Auto Push
# ===============================

# Set variables
# GitHub repository SSH URL (example)
REPO="git@github.com:your github username/charlie-cafe-devops.git"
DIR="/home/ec2-user/charlie-cafe-devops"   # ⚠️ Use absolute path
COMMIT_MSG="${1:-Auto-deploy update}"

# -------------------------------------------------
# 0️⃣ Start ssh-agent and add deploy key
# -------------------------------------------------
eval "$(ssh-agent -s)" > /dev/null
ssh-add /home/ec2-user/.ssh/id_deploy > /dev/null 2>&1

# -------------------------------------------------
# 1️⃣ Clone repo if it doesn't exist
# -------------------------------------------------
if [ ! -d "$DIR/.git" ]; then
    echo "📥 Cloning repository..."
    git clone "$REPO" "$DIR"
else
    echo "✅ Repository already exists. Pulling latest changes..."
    cd "$DIR" || exit
    git pull origin main
fi

# -------------------------------------------------
# 2️⃣ Enter repo
# -------------------------------------------------
cd "$DIR" || exit

# -------------------------------------------------
# 3️⃣ Add, commit, push changes
# -------------------------------------------------
git add .
git commit -m "$COMMIT_MSG" || echo "⚠️ Nothing to commit."
git push origin main

echo "🚀 Auto-deploy complete!"