# Charlie Cafe Verfications 

### ✅ Pre-checks (tools & environment)

Before running the script, make sure all required tools are installed:

- Run:

```
ls -la
aws --version
jq --version
mysql --version
docker --version
git --version
curl --version
docker --version
docker info
aws secretsmanager get-secret-value --secret-id CafeDevDBSM --region us-east-1
```

#### ✅ Expected output:

```
Docker version 24.x.x, build ...
...
Server:
 Containers: ...
 Images: ...
```

#### ✅ What this verifies:

- EC2 has AWS CLI, Docker, Git, MySQL client, curl, jq installed

- Docker daemon is running

This confirms Docker is installed and the daemon is running.

### ✅ Step 1 — Project directory & GitHub repo

Script clones or navigates to your repo:

```
cd ~/charlie-cafe-devops
git status
ls -laR
```

#### ✅ What to check:

- git status should show the branch (main) and any changes.

- If the folder didn’t exist before, script cloned the repo automatically.

### ✅ Step 2 — Tool check

- Script checks for aws, jq, mysql, docker, git, curl.

You already did:

```
aws --version
jq --version
mysql --version
docker --version
git --version
curl --version
curl http://localhost
```

✅ Success criteria: All commands show version numbers.

### ✅ Step 3 — Fetch DB credentials from Secrets Manager

```
aws secretsmanager get-secret-value \
  --secret-id CafeDevDBSM \
  --region us-east-1
```

#### ✅ What to check:

- JSON output with username, password, host, dbname

- Script extracts them using jq. You can test separately:

```
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id CafeDevDBSM --region us-east-1 --query SecretString --output text)
echo $SECRET_JSON | jq
```

### ✅ Step 4 — Check that the repo exists and is correct

```
cd ~/charlie-cafe-devops
pwd
ls -la
```

#### ✅ You should see:

- .git folder → confirms this is a Git repository

- Files from your repo (e.g., README.md)

### ✅ Step 5 — Check Git remote URL

```
git remote -v
```

#### ✅ You should see:

```
origin  git@github.com:awsrmmustansarjavaid/charlie-cafe-devops.git (fetch)
origin  git@github.com:awsrmmustansarjavaid/charlie-cafe-devops.git (push)
```

✅ Confirms you are connected via SSH and using the correct repo.

### ✅ Step 6 — Verify SSH connection to GitHub

```
ssh -T git@github.com
```

#### ✅ Expected output:

```
Hi awsrmmustansarjavaid/charlie-cafe-devops! You've successfully authenticated, but GitHub does not provide shell access.
```

✅ Confirms EC2 can authenticate with GitHub via your deploy key.

### ✅ Step 7 — Check Git status

```
git status
```

Expected output if nothing has changed:

```
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

✅ Confirms repo is synced and ready for commits.

### ✅ Step 8 — Test a dummy change (optional)

```
echo "# Test Deploy $(date)" >> test.txt
git add test.txt
git commit -m "Test auto-deploy"
git push origin main
```

Check GitHub → test.txt should appear in your repo
Confirms push works automatically via SSH key

After test, you can remove the test file:

```
rm test.txt
git add .
git commit -m "Remove test file"
git push origin main
```

### ✅ Step 9 — Verify script behavior

Run your script again:

```
./ec2_git_auto_deploy.sh
```

Expected output:

```
✅ Repository already exists. Pulling latest changes...
⚠️ Nothing to commit.
Everything up-to-date
🚀 Auto-deploy complete!
```

✅ Confirms the script works idempotently — it won’t break if nothing changed.

### 🚀 ✅ COMPLETE VERIFICATION SCRIPT

Save this as:

```
nano verify-devops-env.sh
```

[verify-devops-env.sh](../infrastructure/scripts/verify-devops-env.sh)

```
#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — FULL DevOps & Git/RDS Verification Script
# ==========================================================
# This script verifies:
#   ✅ Required tools
#   ✅ Docker daemon
#   ✅ Project directory & Git
#   ✅ AWS Secrets Manager connectivity
#   ✅ Local application health (curl)
#   ✅ RDS database connectivity & analytics
#   ✅ SSH configuration & GitHub access
#   ✅ Git repo verification & optional test commit
# ==========================================================

echo "=================================================="
echo "🚀 Starting Full Environment Verification"
echo "=================================================="

PASS_COUNT=0
FAIL_COUNT=0

# ----------------------------------------------------------
# Function: Check if command exists
# ----------------------------------------------------------
check_command() {
    if command -v $1 &> /dev/null
    then
        echo "✅ $1 is installed"
        ((PASS_COUNT++))
    else
        echo "❌ $1 is NOT installed"
        ((FAIL_COUNT++))
    fi
}

echo ""
echo "🔎 Step 1: Checking required tools..."
check_command aws
check_command jq
check_command mysql
check_command docker
check_command git
check_command curl
check_command ssh

# ----------------------------------------------------------
# Step 2: Version Checks
# ----------------------------------------------------------
echo ""
echo "🔎 Step 2: Checking versions..."
echo "---- Versions ----"
aws --version 2>/dev/null || echo "❌ aws failed"
jq --version 2>/dev/null || echo "❌ jq failed"
mysql --version 2>/dev/null || echo "❌ mysql failed"
docker --version 2>/dev/null || echo "❌ docker failed"
git --version 2>/dev/null || echo "❌ git failed"
curl --version 2>/dev/null || echo "❌ curl failed"
ssh -V 2>/dev/null || echo "❌ ssh failed"

# ----------------------------------------------------------
# Step 3: Docker Status
# ----------------------------------------------------------
echo ""
echo "🔎 Step 3: Checking Docker daemon..."
if sudo systemctl is-active --quiet docker
then
    echo "✅ Docker daemon is running"
    ((PASS_COUNT++))
else
    echo "❌ Docker daemon is NOT running"
    ((FAIL_COUNT++))
fi

docker info >/dev/null 2>&1 && echo "✅ docker info OK" || echo "❌ docker info failed"

# ----------------------------------------------------------
# Step 4: Project Directory & Git
# ----------------------------------------------------------
echo ""
echo "🔎 Step 4: Checking project directory..."
PROJECT_DIR="/home/ec2-user/charlie-cafe-devops"

if [ -d "$PROJECT_DIR" ]; then
    echo "✅ Project directory exists: $PROJECT_DIR"
    cd "$PROJECT_DIR" || exit

    echo ""
    echo "📂 Git Status:"
    git status 2>/dev/null || echo "❌ Not a git repo"

    echo ""
    echo "📁 Directory structure:"
    ls -la

    echo ""
    echo "🔹 Checking Git remote URL..."
    git remote -v || echo "❌ Cannot show remotes"

    echo ""
    echo "🔹 Verifying SSH connection to GitHub..."
    ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | tee /tmp/github_ssh_test.log
    if grep -q "successfully authenticated" /tmp/github_ssh_test.log; then
        echo "✅ GitHub SSH authentication successful"
        ((PASS_COUNT++))
    else
        echo "❌ GitHub SSH authentication failed"
        ((FAIL_COUNT++))
    fi

    echo ""
    echo "🔹 Checking Git status..."
    git status || echo "❌ Cannot get git status"

    # Optional test commit
    TEST_FILE="test_auto_deploy.txt"
    echo "# Test Deploy $(date)" >> $TEST_FILE
    git add $TEST_FILE
    git commit -m "Test auto-deploy $(date)" >/dev/null 2>&1 || echo "⚠️ Nothing to commit"
    git push origin main >/dev/null 2>&1 && echo "✅ Test file pushed to GitHub" || echo "⚠️ Could not push test file"
    rm -f $TEST_FILE
    git add . >/dev/null 2>&1
    git commit -m "Remove test file" >/dev/null 2>&1
    git push origin main >/dev/null 2>&1

else
    echo "❌ Project directory NOT found"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 5: SSH Verification
# ----------------------------------------------------------
echo ""
echo "🔎 Step 5: Checking SSH keys..."
echo "📂 ~/.ssh contents:"
ls -l ~/.ssh

if [ -f ~/.ssh/id_deploy ]; then
    echo "✅ Deploy private key exists"
    ((PASS_COUNT++))
else
    echo "❌ Deploy private key NOT found"
    ((FAIL_COUNT++))
fi

if [ -f ~/.ssh/id_deploy.pub ]; then
    echo "✅ Deploy public key exists"
    ((PASS_COUNT++))
else
    echo "❌ Deploy public key NOT found"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 6: AWS Secrets Manager Check
# ----------------------------------------------------------
echo ""
echo "🔎 Step 6: Fetching RDS credentials from AWS Secrets Manager..."
SECRET_NAME="CafeDevDBSM"
REGION="us-east-1"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_NAME \
  --region $REGION \
  --query SecretString \
  --output text 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "✅ Secret fetched successfully"
    DB_HOST=$(echo $SECRET_JSON | jq -r .host)
    DB_USER=$(echo $SECRET_JSON | jq -r .username)
    DB_PASS=$(echo $SECRET_JSON | jq -r .password)
    DB_NAME=$(echo $SECRET_JSON | jq -r .dbname)

    echo "📊 Database Host: $DB_HOST"
    echo "📊 Database User: $DB_USER"
    echo "📊 Database Name: $DB_NAME"
    ((PASS_COUNT++))
else
    echo "❌ Failed to fetch secret"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 7: Application Health Check
# ----------------------------------------------------------
echo ""
echo "🔎 Step 7: Checking Application Health (http://localhost)..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost)
if [ "$HTTP_STATUS" == "200" ]; then
    echo "✅ Application is UP (HTTP 200)"
    ((PASS_COUNT++))
elif [ "$HTTP_STATUS" == "000" ]; then
    echo "❌ Application is DOWN (No response)"
    ((FAIL_COUNT++))
else
    echo "⚠️ Application responded with HTTP $HTTP_STATUS"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 8: RDS Verification & Analytics
# ----------------------------------------------------------
echo ""
echo "🔎 Step 8: Verifying RDS database connectivity..."
if [ -n "$DB_HOST" ] && [ -n "$DB_USER" ] && [ -n "$DB_PASS" ]; then
    SQL_QUERY="SELECT NOW();"
    echo "$SQL_QUERY" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" 2>/tmp/rds_error.log
    if [ $? -eq 0 ]; then
        echo "✅ RDS database connected successfully"
        ((PASS_COUNT++))
    else
        echo "❌ Failed to connect to RDS"
        cat /tmp/rds_error.log
        ((FAIL_COUNT++))
    fi
else
    echo "❌ RDS credentials not available"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Final Result
# ----------------------------------------------------------
echo ""
echo "=================================================="
echo "📊 FINAL RESULT"
echo "=================================================="
echo "✅ Passed: $PASS_COUNT"
echo "❌ Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -eq 0 ]; then
    echo "🎉 ALL CHECKS PASSED — ENVIRONMENT READY 🚀"
else
    echo "⚠️ Some checks failed — fix issues above"
fi

echo "=================================================="
```

```
chmod +x verify-devops-env.sh
./verify-devops-env.sh
```
### 1️⃣ Verify Docker Installation & Daemon

#### Commands:

```
# Check Docker version
docker --version

# Check Docker daemon status
sudo systemctl status docker

# Test Docker run
docker run --rm hello-world
```

#### Expected results:

- docker --version → Something like Docker version 25.0.14, build 0bab007

- systemctl status docker → Active (running)

- docker run hello-world → Success message from Docker confirming container ran

#### Notes: This ensures Docker is installed, the daemon is running, and the engine can launch containers.

### 2️⃣ Verify Docker Compose

#### Commands:

```
docker compose version
docker compose config
```

#### Expected results:

- Version output: e.g., Docker Compose version v2.x.x

- docker compose config → Valid parsed configuration of your docker-compose.yml. No errors.

#### Notes: This ensures your docker-compose.yml is syntactically correct.

### 3️⃣ Verify Project Repository & Git

#### Commands:

```
cd ~/charlie-cafe-devops
pwd
ls -la
git status
git remote -v
ssh -T git@github.com
```

#### Expected results:

- .git folder exists

- Files from your repo exist (README.md, docker-compose.yml, etc.)

- git status → On branch main, nothing to commit

- git remote -v → Correct SSH URL

- ssh -T git@github.com → Hi <username>/<repo>! You've successfully authenticated, but GitHub does not provide shell access.

#### Notes: This ensures your repo is synced, SSH access works, and the deploy key is functional.

### 4️⃣ Verify Local CI/CD Auto-Deploy Script

#### Commands: 

```
./ec2_git_auto_deploy.sh
```

#### Expected results:

- Repository is checked/pulled correctly

- Nothing to commit if nothing changed

- Logs showing: ✅ Auto-deploy complete!

#### Notes: This confirms your GitHub deploy pipeline works locally on EC2.

### 5️⃣ Verify Docker Services with Docker Compose

#### Commands:

```
cd ~/charlie-cafe-devops
docker compose up -d
docker compose ps
docker logs <container_name>   # Example: docker logs charlie-cafe-app
docker compose down
```

#### Expected results:

- docker compose up -d → No errors

- docker compose ps → Shows all services running (STATUS: Up)

- docker logs → Shows expected application logs (no errors)

- docker compose down → Stops containers cleanly

#### Notes: This ensures your app stack can run locally with Docker Compose.

### 6️⃣ Verify Application Health (Local HTTP)

#### Commands:

```
curl -I http://localhost:8080   # or the port you expose in docker-compose.yml
```

#### Expected results:

- HTTP/1.1 200 OK → App is responding

- No curl: (7) Failed to connect errors

#### Notes: Confirms app is running and accessible.

### 7️⃣ Verify AWS CLI & Secrets Manager (for RDS)

#### Commands:

```
aws --version
aws secretsmanager get-secret-value --secret-id CafeDevDBSM --region us-east-1
```

#### Expected results:

- aws --version → e.g., aws-cli/2.12.1 Python/3.12.0 Linux/5.15.0-1031-aws exe/x86_64.amzn2023

- Secret JSON returns DB credentials without error

#### Notes: Ensures EC2 can connect to AWS APIs for secrets, required for ECS/ECR deployment.

### 8️⃣ Verify Database Connectivity (RDS)

#### Commands:

```
mysql -h <DB_HOST> -u <DB_USER> -p"<DB_PASS>" <DB_NAME> -e "SHOW TABLES;"
```

#### Expected results:

- List of tables returned

- No connection errors

#### Notes: Confirms that RDS can be reached from EC2 and credentials from Secrets Manager work.

### 9️⃣ Verify GitHub Actions & Logs (Local Fetch)

#### Commands:

```
# Ensure gh CLI installed
gh --version

# Authenticated
gh auth status

# List workflows
gh workflow list

# List recent runs
gh run list --limit 5

# Fetch logs for latest run
gh run view <run_id> --log > github_logs_run_<run_id>.txt
```

#### Expected results:

- Workflows and run IDs listed

- Logs captured successfully in files

#### Notes: Ensures GitHub Actions are accessible and logs can be downloaded locally.

### 🔟 Verify Permissions

Sometimes push failures happen due to permissions on EC2 .git directory:

#### Commands:

```
sudo chown -R ec2-user:ec2-user ~/charlie-cafe-devops
chmod -R 755 ~/charlie-cafe-devops
```

#### Notes:This avoids errors like could not open '.git/COMMIT_EDITMSG': Permission denied.

### Optional Tests (for ECS/ECR readiness)

#### Build Docker images locally:

```
docker compose build
docker images
```

#### Tag for ECR:

```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com
docker tag charlie-cafe-app:latest <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe-app:latest
docker push <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe-app:latest
```

### Verify ECS readiness:

- Check task definitions, service definitions, clusters in AWS Console

- Ensure proper IAM roles exist

### ✅ Summary Table of Verification Checks

| Step                  | Command                               | Expected Result             |
| --------------------- | ------------------------------------- | --------------------------- |
| Docker                | `docker --version`                    | Version info                |
| Docker Daemon         | `sudo systemctl status docker`        | Active (running)            |
| Docker Test           | `docker run hello-world`              | Container runs successfully |
| Docker Compose        | `docker compose version`              | Version info                |
| Docker Compose Config | `docker compose config`               | Valid YAML                  |
| Git Repo              | `git status`                          | On branch main, clean       |
| Git Remote            | `git remote -v`                       | Correct SSH URL             |
| GitHub SSH            | `ssh -T git@github.com`               | Authenticated               |
| Auto-deploy           | `./ec2_git_auto_deploy.sh`            | Pull/push works             |
| Docker Services       | `docker compose up -d`                | Services up, logs okay      |
| App Health            | `curl http://localhost`               | HTTP 200 OK                 |
| AWS CLI               | `aws --version`                       | Version info                |
| Secrets Manager       | `aws secretsmanager get-secret-value` | Secret JSON                 |
| RDS                   | `mysql -h ...`                        | Tables listed               |
| GitHub Actions        | `gh run view <run_id> --log`          | Logs saved                  |
| Permissions           | `chown/chmod`                         | No permission errors        |

### 1️⃣ Create the cli-plugins directory for Docker Buildx 

> Docker Buildx is a CLI plugin for advanced builds (multi-platform, caching, BuildKit features).

```
mkdir -p ~/.docker/cli-plugins
```

> -p ensures that the full path is created if it doesn't exist.

### 2️⃣ Download the latest Buildx binary

```
# Get the latest Buildx version
DOCKER_BUILDX_VERSION=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | grep tag_name | cut -d '"' -f 4)

# Download binary into cli-plugins
curl -Lo ~/.docker/cli-plugins/docker-buildx \
https://github.com/docker/buildx/releases/download/$DOCKER_BUILDX_VERSION/buildx-$DOCKER_BUILDX_VERSION.linux-amd64
```

### 3️⃣ Make it executable

```
chmod +x ~/.docker/cli-plugins/docker-buildx
```

### 4️⃣ Verify installation

```
docker buildx version
```

#### Expected output:

```
github.com/docker/buildx 0.27.0 <commit> 2026-04-02
```

### ✅ 5️⃣ Test Docker Compose

After Buildx is upgraded:

```
docker compose up -d --build
docker compose ps
curl -I http://localhost:8080
```

#### ✅ Expected:

Build completes successfully
Container charlie_web is Up
curl returns HTTP/1.1 200 OK

### 💡 Tip: Always create ~/.docker/cli-plugins before downloading CLI plugins on Linux. On Amazon Linux 2023 it doesn’t exist by default.
---

