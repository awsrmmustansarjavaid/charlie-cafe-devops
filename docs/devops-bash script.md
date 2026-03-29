# Charlie Cafe - DEVOPS Bash Script

### 🧠 1. init-github.sh → Initialize Git & Push to GitHub

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — GIT INITIALIZATION SCRIPT
# ----------------------------------------------------------
# ✔ Initializes local Git repo
# ✔ Commits project
# ✔ Connects to GitHub
# ✔ Pushes code to main branch
# ==========================================================

# ❗ EXIT SCRIPT IF ANY COMMAND FAILS
set -e

# -------------------------------
# 🔧 VARIABLES (EDIT THESE)
# -------------------------------
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="YOUR_USERNAME"

# -------------------------------
# 📁 MOVE INTO PROJECT DIRECTORY
# -------------------------------
echo "📂 Moving into project folder..."
cd charlie-cafe || { echo "❌ Folder not found!"; exit 1; }

# -------------------------------
# 🧱 INITIALIZE GIT
# -------------------------------
echo "🔧 Initializing Git..."
git init

# -------------------------------
# ➕ ADD FILES
# -------------------------------
echo "📦 Adding files..."
git add .

# -------------------------------
# 💾 COMMIT
# -------------------------------
echo "💾 Creating initial commit..."
git commit -m "Initial commit - Charlie Cafe Project"

# -------------------------------
# 🔗 CONNECT TO GITHUB
# -------------------------------
echo "🔗 Connecting to GitHub..."
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git

# -------------------------------
# 🌿 SET MAIN BRANCH
# -------------------------------
echo "🌿 Setting main branch..."
git branch -M main

# -------------------------------
# 🚀 PUSH TO GITHUB
# -------------------------------
echo "🚀 Pushing to GitHub..."
git push -u origin main

echo "✅ GitHub setup complete!"
```

### 🧠 2. docker-setup.sh → Build & Run Container (EC2)

```
#!/bin/bash

# ==========================================================
# 🐳 CHARLIE CAFE — DOCKER SETUP SCRIPT
# ----------------------------------------------------------
# ✔ Builds Docker image
# ✔ Runs container on port 80
# ✔ Removes old container if exists
# ==========================================================

set -e

# -------------------------------
# 🔧 VARIABLES
# -------------------------------
IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"

# -------------------------------
# 📂 GO TO PROJECT DIRECTORY
# -------------------------------
echo "📂 Navigating to project directory..."
cd ~/charlie-cafe-devops || { echo "❌ Project not found!"; exit 1; }

# -------------------------------
# 🧹 REMOVE OLD CONTAINER (IF EXISTS)
# -------------------------------
echo "🧹 Cleaning old container..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

# -------------------------------
# 🏗️ BUILD DOCKER IMAGE
# -------------------------------
echo "🏗️ Building Docker image..."
docker build -t $IMAGE_NAME .

# -------------------------------
# 🚀 RUN CONTAINER
# -------------------------------
echo "🚀 Running container..."
docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME

# -------------------------------
# 📊 STATUS
# -------------------------------
echo "📊 Running containers:"
docker ps

echo "✅ Docker setup completed!"
```

### 🔥 FINAL MERGED DEVOPS SCRIPT

✔ Git init + push to GitHub

✔ Build Docker image

✔ Run container

✔ (Optionally reusable on EC2)

Here’s your 🔥 FINAL MERGED DEVOPS SCRIPT with proper comments:

#### 🚀 charlie-cafe-devops.sh (All-in-One Script)

```
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
```

### 🧠 How to Use

```
# 1. Save file
nano charlie-cafe-devops.sh

# 2. Make executable
chmod +x charlie-cafe-devops.sh

# 3. Run
./charlie-cafe-devops.sh
```

### ⚠️ Important Notes (Don’t Skip)

#### 🔴 You MUST edit this first:

```
GITHUB_USERNAME="YOUR_USERNAME"
```

#### 🔴 If repo already exists:

This line avoids error:

```
git remote add origin ... || true
```

#### 🔴 If running on EC2:

Make sure Docker is installed:

```
docker --version
```

### 💡 Pro Upgrade (Next Step)

#### After this, your next level (VERY important for DevOps):

👉 Push Docker image to ECR

👉 Deploy to ECS

👉 Attach ALB

👉 Automate using GitHub Actions

---

