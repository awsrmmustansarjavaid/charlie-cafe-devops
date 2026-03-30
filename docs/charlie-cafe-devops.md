# Charlie Cafe - DEVOPS Bash Script

### 1️⃣ Initialize GitHub Repo

### ✅ 1. Initialize locally

```
cd charlie-cafe

git init
git add .
git commit -m "Initial commit - Charlie Cafe Project"
```

### ✅ 2. Connect to GitHub

```
git remote add origin https://github.com/YOUR_USERNAME/charlie-cafe-devops.git
git branch -M main
git push -u origin main
```

### ✅ Fully Final Initialize GitHub Repo Script

#### init-github.sh → Initialize Git & Push to GitHub

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

### 2️⃣ Charlie Cafe RDS Schema

#### 📄 Read more here 

[Charlie Cafe Readme_RDS_schema](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/3cc7be3a035c31c2f621682ac611a5dd9c5487d3/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/Charlie%20Cafe%20DevOPS/Readme_RDS_schema.md)

#### ✅ ✅ FINAL SPLIT (PRODUCTION STYLE)

You will have:

```
schema.sql   → structure (DB + tables)
data.sql     → sample/test data
verify.sql   → testing + analytics
```

#### 👉 Create this file:

```
infrastructure/rds/schema.sql
```

```
infrastructure/rds/data.sql
```

```
infrastructure/rds/verify.sql
```

### ⚙️ HOW IT WORKS (STEP BY STEP)

> ### Method 1️⃣ How to run your current files in production without Docker/CI/CD

### ✅ Step 1 — Create schema

```
mysql -h <host> -u <user> -p < schema.sql
```

#### 👉 Creates:

- database

- tables

- relationships

### ✅ Step 2 — Insert data

```
mysql -h <host> -u <user> -p < data.sql
```

### ✅ Step 3 — Verify

```
mysql -h <host> -u <user> -p < verify.sql
```

### 3️⃣ Dockerize MySQL for local testing

> ### Method 2️⃣ integrate schema.sql, data.sql, verify.sql into Docker + CI/CD

### 1️⃣ Create a devops-setup_rds.sh

> #### 📦 1. ✅ devops-setup_rds.sh → MySQL (database with schema.sql)

```
#!/bin/bash

# =============================================================
# ☕ Charlie Cafe — RDS Setup Script (FINAL PRODUCTION VERSION)
# -------------------------------------------------------------
# Purpose:
# ✔ Fetch DB credentials securely from AWS Secrets Manager
# ✔ Create database (if not exists)
# ✔ Apply schema.sql (tables + relationships)
# ✔ Apply data.sql (optional sample data)
# ✔ Run verify.sql (QA checks)
# ✔ Safe to run multiple times
# =============================================================

set -euo pipefail

# =============================================================
# CONFIGURATION (EDIT IF NEEDED)
# =============================================================
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# =============================================================
# COLORS (FOR CLEAN OUTPUT)
# =============================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}========================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================================${NC}\n"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
  echo -e "${RED}❌ $1${NC}\n"
}

# =============================================================
# STEP 1 — CHECK REQUIRED TOOLS
# =============================================================
print_header "Checking Required Tools"

command -v aws >/dev/null 2>&1 || { print_error "AWS CLI not installed"; exit 1; }
command -v jq >/dev/null 2>&1 || { print_error "jq not installed"; exit 1; }
command -v mysql >/dev/null 2>&1 || { print_error "MySQL client not installed"; exit 1; }

print_success "All required tools are installed"

# =============================================================
# STEP 2 — FETCH SECRET FROM AWS SECRETS MANAGER
# =============================================================
print_header "Fetching DB Credentials from Secrets Manager"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "Credentials loaded successfully"

# =============================================================
# STEP 3 — TEST RDS CONNECTION
# =============================================================
print_header "Testing RDS Connection"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1 \
  && print_success "RDS connection successful" \
  || { print_error "Failed to connect to RDS"; exit 1; }

# =============================================================
# STEP 4 — CREATE DATABASE (SAFE)
# =============================================================
print_header "Creating Database (if not exists)"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database ensured"

# =============================================================
# STEP 5 — APPLY SCHEMA
# =============================================================
print_header "Applying Database Schema"

if [ -f "$SCHEMA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"
  print_success "Schema applied successfully"
else
  print_error "Schema file not found: $SCHEMA_FILE"
  exit 1
fi

# =============================================================
# STEP 6 — APPLY SAMPLE DATA (OPTIONAL)
# =============================================================
print_header "Applying Sample Data (Optional)"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ Data file not found, skipping...${NC}"
fi

# =============================================================
# STEP 7 — VERIFY DATABASE
# =============================================================
print_header "Running Verification"

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "Verification completed"
else
  echo -e "${YELLOW}⚠️ Verify file not found, skipping...${NC}"
fi

# =============================================================
# FINAL SUCCESS MESSAGE
# =============================================================
print_header "☕ Charlie Cafe RDS Setup Completed"

echo -e "${GREEN}✔ RDS Connected${NC}"
echo -e "${GREEN}✔ Database Created/Verified${NC}"
echo -e "${GREEN}✔ Schema Applied${NC}"
echo -e "${GREEN}✔ Data Inserted (if available)${NC}"
echo -e "${GREEN}✔ Verification Completed${NC}"

echo -e "\n🎉 Your Charlie Cafe database is fully ready on AWS RDS!\n"
```

### 📦 2. ✅ Dockerfile → Apache + PHP (frontend)

```
nano docker/apache-php/Dockerfile
```

[Dockerfile](./docker/apache-php/Dockerfile)


### 4️⃣ ⚙️ FINAL docker-compose.yml (FULLY CONNECTED)

```
nano docker-compose.yml
```

[docker-compose.yml](./docker-compose.yml)

### 5️⃣ 📦 2. Create .dockerignore (IMPORTANT)

This prevents junk files from going into Docker image.

#### Create:

```
.dockerignore
```

```
.git
.gitignore
node_modules
.env
*.log
vendor
docker-compose.yml
.github
README.md
docs/
```

#### 🔍 Why these are added

- .git, .github → not needed inside image

- node_modules, vendor → heavy + rebuildable

- .env → sensitive

- logs → useless in image

- docs/config → not required in runtime

### 6️⃣ 📦 3. Create .gitignore (IMPORTANT)

#### Create:

```
.gitignore
```

```
node_modules/
vendor/
.env
*.log
.DS_Store
Thumbs.db
docker/*.tar
docs/
```

### 6️⃣ ⚙️ 3. Build Your Docker Image

SSH into EC2 and go to your project:

```
cd charlie-cafe-devops
```

Then run:

```
docker build -t charlie-cafe .
```

### 7️⃣ 4. Run Your Container

```
docker run -d -p 80:80 --name cafe-app charlie-cafe
```

### 8️⃣ 5. Run Your Project Locally

```
docker-compose up --build
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

> #### Update Version: 1.0


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

## 🔥 FINAL MERGED DEVOPS SCRIPT 

> #### Update Version: 1.1

✔ Proper flow (RDS → Git → Docker)

✔ Clear sections

✔ Safe execution

✔ Professional comments

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL)
# ----------------------------------------------------------
# ✔ Setup AWS RDS (DB + schema + data + verification)
# ✔ Initialize Git & push to GitHub
# ✔ Build Docker image
# ✔ Run Docker container
# ✔ Production-ready structure with safety checks
# ==========================================================

# ❗ Exit on error, undefined variable, pipe failure
set -euo pipefail

# ==========================================================
# 🔧 GLOBAL VARIABLES (EDIT BEFORE RUN)
# ==========================================================

# --- Project ---
PROJECT_DIR="charlie-cafe"

# --- GitHub ---
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="YOUR_USERNAME"

# --- Docker ---
IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"

# --- AWS RDS / Secrets ---
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# ==========================================================
# 🎨 COLORS FOR OUTPUT
# ==========================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}========================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================================${NC}\n"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
  echo -e "${RED}❌ $1${NC}\n"
}

# ==========================================================
# 📁 STEP 1 — MOVE INTO PROJECT DIRECTORY
# ==========================================================
print_header "Step 1 — Navigate to Project"

cd $PROJECT_DIR || { print_error "Project folder not found"; exit 1; }

print_success "Project directory ready"

# ==========================================================
# 🧰 STEP 2 — CHECK REQUIRED TOOLS
# ==========================================================
print_header "Step 2 — Checking Required Tools"

command -v aws >/dev/null || { print_error "AWS CLI not installed"; exit 1; }
command -v jq >/dev/null || { print_error "jq not installed"; exit 1; }
command -v mysql >/dev/null || { print_error "MySQL client not installed"; exit 1; }
command -v docker >/dev/null || { print_error "Docker not installed"; exit 1; }
command -v git >/dev/null || { print_error "Git not installed"; exit 1; }

print_success "All required tools are installed"

# ==========================================================
# ☁️ STEP 3 — FETCH DB CREDENTIALS FROM AWS
# ==========================================================
print_header "Step 3 — Fetching DB Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "Database credentials loaded"

# ==========================================================
# 🧪 STEP 4 — TEST DB CONNECTION
# ==========================================================
print_header "Step 4 — Testing RDS Connection"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1 \
  && print_success "RDS connection successful" \
  || { print_error "RDS connection failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — CREATE DATABASE
# ==========================================================
print_header "Step 5 — Creating Database"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database ready"

# ==========================================================
# 📦 STEP 6 — APPLY SCHEMA
# ==========================================================
print_header "Step 6 — Applying Schema"

if [ -f "$SCHEMA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"
  print_success "Schema applied"
else
  print_error "Schema file missing"
  exit 1
fi

# ==========================================================
# 📊 STEP 7 — APPLY DATA (OPTIONAL)
# ==========================================================
print_header "Step 7 — Applying Sample Data"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ No data file found, skipping...${NC}"
fi

# ==========================================================
# 🔍 STEP 8 — VERIFY DATABASE
# ==========================================================
print_header "Step 8 — Verification"

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "Verification completed"
else
  echo -e "${YELLOW}⚠️ No verify file found, skipping...${NC}"
fi

# ==========================================================
# 🔧 STEP 9 — GIT SETUP
# ==========================================================
print_header "Step 9 — Git Initialization"

git init
git add .
git commit -m "Initial commit - Charlie Cafe Project" || true

git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git || true
git branch -M main

git push -u origin main

print_success "Code pushed to GitHub"

# ==========================================================
# 🐳 STEP 10 — DOCKER BUILD
# ==========================================================
print_header "Step 10 — Docker Build"

docker build -t $IMAGE_NAME .

print_success "Docker image built"

# ==========================================================
# 🧹 STEP 11 — REMOVE OLD CONTAINER
# ==========================================================
print_header "Step 11 — Cleanup Old Container"

docker rm -f $CONTAINER_NAME 2>/dev/null || true

print_success "Old container removed (if existed)"

# ==========================================================
# 🚀 STEP 12 — RUN CONTAINER
# ==========================================================
print_header "Step 12 — Run Application"

docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME

print_success "Container is running"

# ==========================================================
# 📊 FINAL STATUS
# ==========================================================
print_header "Final Status"

docker ps

echo -e "\n🎉 ${GREEN}Charlie Cafe FULL DevOps Setup Completed!${NC}"
echo -e "🌐 Access your app: http://YOUR_EC2_PUBLIC_IP\n"
```

### 🧠 Key Improvements (Important)

#### ✅ Correct execution order:

- RDS setup

- Git push

- Docker deploy

#### ✅ Safe for re-run:

- git commit || true

- git remote add || true

- docker rm -f || true

#### ✅ Production-style features:

- set -euo pipefail

- Color logs

- Structured steps

- Validation checks

### 🌐 FINAL MERGED DEVOPS SCRIPT 

> #### Update Version: 1.2

✔ Dockerfile → ✅ Used by your script

✔ docker-compose.yml → ⚠️ NOT used currently

✔ GitHub Actions (deploy.yml) → ✅ Will work AFTER push

### 🧠 What Happens When You Run Your Script

### 1️⃣ Dockerfile

Your script runs:

```
docker build -t charlie-cafe .
```

👉 This uses your Dockerfile automatically

✔ No issue here

✔ Just make sure path is correct

⚠️ Important

If your Dockerfile is inside:

```
docker/apache-php/Dockerfile
```

Then your script WILL FAIL ❌

### ✅ Fix (choose ONE)

#### Option A (Recommended)

Move Dockerfile to root:

```
charlie-cafe/
 ├── Dockerfile   ✅
 ├── docker-compose.yml
```

#### Option B (Advanced)

Update script:

```
docker build -t $IMAGE_NAME -f docker/apache-php/Dockerfile .
```

### 2️⃣ docker-compose.yml

Right now your script uses:

```
docker run -d -p 80:80 ...
```

#### 👉 That means:

❌ docker-compose.yml is NOT used

❌ Multi-container setup ignored (DB, network, etc.)

✅ If You WANT docker-compose (Recommended for DevOps)

Replace this part in script:

```
docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME
```

👉 WITH:

```
docker-compose up --build -d
```

### 🔥 My Recommendation

Since your project includes:

✔ RDS

✔ API

✔ Frontend

👉 Use docker-compose for local/dev

👉 Use ECS for production

### 3️⃣ GitHub Actions (deploy.yml)

Your script does:

```
git push -u origin main
```

👉 This will trigger:

➡️ .github/workflows/deploy.yml

✔ So YES — it will run automatically

✔ This is your CI/CD pipeline

### ⚠️ Important DevOps Warning (Very Important)

Right now your flow is:

Script runs Docker on EC2

GitHub Actions ALSO deploys

#### 👉 This can cause:

❌ Conflict

❌ Duplicate deployments

❌ Confusion (manual vs automated)

### 🧠 Best Practice (Real DevOps Way)

### 🔥 Choose ONE deployment method:

#### ✅ Option 1 (Beginner)

Use script only

👉 Ignore GitHub Actions for now

#### ✅ Option 2 (Professional DevOps) ⭐ RECOMMENDED

Use:

✔ Script → only for setup (RDS + Git push)

✔ GitHub Actions → deployment

✔ ECS → container hosting

👉 Remove this from script:

```
docker run ...
```

### ✅ Final Recommendation (For YOU)

Since you're learning AWS DevOps:

👉 Modify your script like this:

❌ REMOVE:

```
docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME
```

✅ ADD:

```
docker-compose up --build -d
```

### 🚀 Final Flow After Fix

Run script

RDS setup ✔

Code pushed ✔

GitHub Actions runs ✔

Deploy to AWS ✔

### 💡 Pro Tip (Game Changer)

You are very close to real DevOps level

Next step should be:

👉 Docker → ECR

👉 ECS (Fargate)

👉 ALB integration

👉 CI/CD automation

### 🚀 ✅ FINAL UPDATED SCRIPT

#### charlie-cafe-devops.sh (Dockerfile path fixed)

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — FULL DEVOPS AUTOMATION SCRIPT (FINAL v2)
# ----------------------------------------------------------
# ✔ Setup AWS RDS (DB + schema + data + verification)
# ✔ Initialize Git & push to GitHub
# ✔ Build Docker image (custom Dockerfile path)
# ✔ Run Docker container
# ✔ Production-ready with safety checks
# ==========================================================

# ❗ Exit on:
# - any error (-e)
# - undefined variable (-u)
# - pipeline failure (pipefail)
set -euo pipefail

# ==========================================================
# 🔧 GLOBAL VARIABLES (EDIT BEFORE RUN)
# ==========================================================

# --- Project ---
PROJECT_DIR="charlie-cafe"

# --- GitHub ---
REPO_NAME="charlie-cafe-devops"
GITHUB_USERNAME="YOUR_USERNAME"

# --- Docker ---
IMAGE_NAME="charlie-cafe"
CONTAINER_NAME="cafe-app"
PORT="80"

# --- Dockerfile Path (UPDATED) ---
DOCKERFILE_PATH="docker/apache-php/Dockerfile"

# --- AWS RDS / Secrets ---
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# ==========================================================
# 🎨 COLORS FOR OUTPUT (FOR READABILITY)
# ==========================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}========================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================================${NC}\n"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
  echo -e "${RED}❌ $1${NC}\n"
}

# ==========================================================
# 📁 STEP 1 — MOVE INTO PROJECT DIRECTORY
# ==========================================================
print_header "Step 1 — Navigate to Project"

cd "$PROJECT_DIR" || { print_error "Project folder not found"; exit 1; }

print_success "Project directory ready"

# ==========================================================
# 🧰 STEP 2 — CHECK REQUIRED TOOLS
# ==========================================================
print_header "Step 2 — Checking Required Tools"

command -v aws >/dev/null || { print_error "AWS CLI not installed"; exit 1; }
command -v jq >/dev/null || { print_error "jq not installed"; exit 1; }
command -v mysql >/dev/null || { print_error "MySQL client not installed"; exit 1; }
command -v docker >/dev/null || { print_error "Docker not installed"; exit 1; }
command -v git >/dev/null || { print_error "Git not installed"; exit 1; }

print_success "All required tools are installed"

# ==========================================================
# ☁️ STEP 3 — FETCH DB CREDENTIALS FROM AWS
# ==========================================================
print_header "Step 3 — Fetching DB Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "Database credentials loaded"

# ==========================================================
# 🧪 STEP 4 — TEST RDS CONNECTION
# ==========================================================
print_header "Step 4 — Testing RDS Connection"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1 \
  && print_success "RDS connection successful" \
  || { print_error "RDS connection failed"; exit 1; }

# ==========================================================
# 🏗️ STEP 5 — CREATE DATABASE
# ==========================================================
print_header "Step 5 — Creating Database"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database ready"

# ==========================================================
# 📦 STEP 6 — APPLY SCHEMA
# ==========================================================
print_header "Step 6 — Applying Schema"

if [ -f "$SCHEMA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"
  print_success "Schema applied"
else
  print_error "Schema file missing: $SCHEMA_FILE"
  exit 1
fi

# ==========================================================
# 📊 STEP 7 — APPLY DATA (OPTIONAL)
# ==========================================================
print_header "Step 7 — Applying Sample Data"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ No data file found, skipping...${NC}"
fi

# ==========================================================
# 🔍 STEP 8 — VERIFY DATABASE
# ==========================================================
print_header "Step 8 — Verification"

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "Verification completed"
else
  echo -e "${YELLOW}⚠️ No verify file found, skipping...${NC}"
fi

# ==========================================================
# 🔧 STEP 9 — GIT SETUP
# ==========================================================
print_header "Step 9 — Git Initialization"

git init
git add .
git commit -m "Initial commit - Charlie Cafe Project" || true

git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git || true
git branch -M main

git push -u origin main

print_success "Code pushed to GitHub"

# ==========================================================
# 🐳 STEP 10 — DOCKER BUILD (UPDATED PATH)
# ==========================================================
print_header "Step 10 — Docker Build"

# Build using custom Dockerfile path
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .

print_success "Docker image built using $DOCKERFILE_PATH"

# ==========================================================
# 🧹 STEP 11 — REMOVE OLD CONTAINER
# ==========================================================
print_header "Step 11 — Cleanup Old Container"

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

print_success "Old container removed (if existed)"

# ==========================================================
# 🚀 STEP 12 — RUN CONTAINER
# ==========================================================
print_header "Step 12 — Run Application"

docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"

print_success "Container is running"

# ==========================================================
# 📊 FINAL STATUS
# ==========================================================
print_header "Final Status"

docker ps

echo -e "\n🎉 ${GREEN}Charlie Cafe FULL DevOps Setup Completed!${NC}"
echo -e "🌐 Access your app: http://YOUR_EC2_PUBLIC_IP\n"
```

### 🔥 What You Just Fixed (Very Important)

### ✅ Dockerfile path issue solved:

```
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .
```

#### ✅ Script is now:

✔ Production-ready

✔ Re-runnable

✔ Clean structured

✔ DevOps-standard

#### ⚠️ Final Quick Checklist

Before running:

```
chmod +x charlie-cafe-devops.sh
```
#### 🔴 MUST EDIT:
```
GITHUB_USERNAME="YOUR_USERNAME"
SECRET_ARN="your-real-secret"
```

### 


---

