# ☕ Charlie Cafe DevOps Project

### 🧱 PHASE 1 — Local Dockerize 

### 🔹 Overview

#### Full-stack cloud-based cafe ordering system using:

- AWS Lambda

- API Gateway

- RDS MySQL

- Docker (local dev)

- GitHub CI/CD

### 🔹 Architecture

Include diagram (VERY IMPORTANT for job portfolio)

```
User → CloudFront → API Gateway → Lambda → RDS
                     ↓
                    S3
```

### 🔹 Features

- Order system

- Payment tracking

- Admin panel

- Live order status

### 🔹 Local Setup (Docker)

```
docker-compose up --build
```

### 🔹 AWS Deployment

- **Refer:** [AWS Charlie Cafe Project](./docs/AWS%20Charlie%20Cafe%20Project.md)

### 🔹 DevOps Features

- Dockerized frontend

- GitHub CI/CD

- Automated build pipeline

### 🚀 1. Final DevOps Architecture (Your Project Now)

#### You already have:

- Frontend (HTML, CSS, JS, PHP)

- Backend (Lambda Python)

- RDS + Secrets Manager

- Bash automation scripts

#### We will enhance it like this:

```
Developer → GitHub → Docker → Local Testing
                      ↓
                CI/CD Pipeline
                      ↓
                AWS Deployment
```

#### Using:

- GitHub

- Docker

- GitHub Actions

## 📁 Professional Repository Structure

### Create your repo like this:

> #### Update your repo to this (no file changes, only organization):

```
charlie-cafe-devops/
│
├── README.md
├── appspec.yaml              ✅ (NEW - REQUIRED)
├── LICENSE
├── .gitignore
├── .dockerignore                
├── docker-compose.yml
│
├── app/                         # Your original code (UNCHANGED)
│   ├── frontend/
│   │   ├── *.html/
│   │   ├── *.php/
│   │   ├── css/
│   │   └── js/
│   │
│   └── backend/
│       └── lambda/
│           ├── *.py
│
├── infrastructure/
│   ├── rds/
│   │   ├── schema.sql          
│   │   ├── data.sql            ✅ (separate data)
│   │   └── verify.sql          ✅ (for CI/CD testing)
│   │
│   ├── scripts/
│   │   ├── setup_lamp.sh
│   │   ├── setup_rds.sh
│   │   ├── s3_to_ec2.sh
│   │   ├── ec2_to_s3.sh
│   │   └── lambda_layer.sh     
│
├── docker/
│   ├── apache-php/
│   │   └── Dockerfile          
│   │
│   └── mysql/
│       └── Dockerfile          
│
├── docs/
│   ├── architecture.md
│   ├── deployment.md
│   ├── docker.md               
│   └── AWS Charlie Cafe Project.md
│
└── .github/
    └── workflows/
        └── deploy.yml          
```

### 👉 Important:

- Your original files go inside folders as-is

- No edits needed

### 📝 Create DEVOPS Files

#### 📑 1. [Dockerfile](./docker/apache-php/Dockerfile)

#### 📑 2. [docker-compose.yml](./docker-compose.yml)

#### 📑 3. [.dockerignore](https://github.com/awsrmmustansarjavaid/charlie-cafe-devops/blob/main/.dockerignore)

#### 📑 4. [.gitignore](https://github.com/awsrmmustansarjavaid/charlie-cafe-devops/blob/main/.gitignore)

#### 📑 5. [deploy.yml](https://github.com/awsrmmustansarjavaid/charlie-cafe-devops/blob/main/.github/workflows/deploy.yml)

### 1️⃣ Initialize GitHub Repo

### 1️⃣ Create repo on GitHub

- Go to: 👉 https://github.com  → New Repo

- Name:

```
charlie-cafe-devops
```

### 2️⃣ Create IAM User for GitHub Actions

- Go to AWS → IAM → Users → Add user

  - UserName: github-ci-cd-user

  - ✅ Select:

```
Provide user access to the AWS Management Console → ❌ UNCHECK
```

#### 👉 IMPORTANT:

  - You only need programmatic access (API)

  - NOT console login

- Attach policy (minimum required):

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode",
        "lambda:GetFunction",
        "lambda:ListFunctions",
        "ec2:DescribeInstances",
        "ssm:SendCommand",
        "ssm:GetCommandInvocation",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    }
  ]
}
```

- Policy Name: GitHub-Actions

- 👉 Then attach this policy to your user

### 3️⃣ 🔐 Create IAM User Access Key for GitHub

- Go to AWS → IAM → Users → your user

- Go to Security credentials → Access keys → Create Access key

- #### Choose Use Case:

  Select: 👉 Command Line Interface (CLI)

- Click Next → Create

- ### ✅ Save Keys (VERY IMPORTANT)

You will get:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### 3️⃣ GitHub → Auto-Deploy Setup (Charlie Cafe)

- Read more here [GitHub Actions auto-deploy-EC2](./docs/Readme/GitHub%20Actions%20auto-deploy.md)

- ### ✅ Method 1️⃣  Add GitHub Secrets for AWS Access Key (Recommanded)

#### 1️⃣ Add Keys to GitHub Secrets

- Go to your repo: 👉 Settings → Secrets → Actions → New repository secret

- #### Add: 

| Secret Name             | Value                              |
| ----------------------- | ---------------------------------- |
| `AWS_ACCESS_KEY_ID`     | (your IAM user access key ID)      |
| `AWS_SECRET_ACCESS_KEY` | (your IAM user secret access key)  |
| `AWS_REGION`            | `us-east-1` (or your region)       |
| `EC2_INSTANCE_ID`       | `i-0123456789abcdef0` (target EC2) |
| `EC2_USER`              | `ec2-user` (default username)      |

✅ Example: AWS_REGION = us-east-1

> 💡 Tip: Instead of hardcoding EC2 IP, use EC2 instance ID + AWS SSM to target instance — no SSH needed.

### 4️⃣ SSM Agent

#### ✅ 1. SSM Agent installed 

```
sudo systemctl status amazon-ssm-agent
```

If NOT running:

```
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
```

#### ✅ 2. Verify SSM Connectivity

- Go to: 👉 AWS Console → Systems Manager → Managed Instances

✅ You MUST see:

- Your EC2 instance listed

- Status: Online

### 5️⃣ Git Auto Deploy

```
nano deploy_via_ssm.sh
```

[deploy_via_ssm.sh](./infrastructure/scripts/deploy_via_ssm.sh)

```
chmod +x deploy_via_ssm.sh
./deploy_via_ssm.sh
```

### 6️⃣ Verification Test 

```
nano charlie_cafe_full_check.sh
```

[charlie_cafe_full_check.sh](./infrastructure/scripts/charlie_cafe_full_check.sh)

```
chmod +x charlie_cafe_full_check.sh
./charlie_cafe_full_check.sh
```

- ### ✅ Method 2️⃣  Add GitHub Secrets for EC2 using SSH

> #### Auto-deploy from GitHub → EC2 using SSH 

### 1️⃣ Prepare EC2 for SSH Deployment

### ✅ Check if keys already exist

Run this on your EC2:

```
ls -la ~/.ssh
```

#### 🔍 What you should see:

- id_deploy → ✅ private key

- id_deploy.pub → ✅ public key

- If both exist → you’re good

- If not → you need to generate them (I’ll show below)

### ✅ Check permissions (VERY IMPORTANT)

```
ls -l ~/.ssh
```

#### Fix permissions if needed:

```
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_deploy
chmod 644 ~/.ssh/id_deploy.pub
```

#### Generate an SSH key on your EC2 instance (if you don’t already have one):

```
ssh-keygen -t ed25519 -C "ec2-auto-deploy" -f ~/.ssh/id_deploy -N ""
```

- This creates ~/.ssh/id_deploy (private) and ~/.ssh/id_deploy.pub (public).

#### Then verify again:

```
ls ~/.ssh
```

#### 🔑 Copy the public key:

```
cat ~/.ssh/id_deploy.pub
```

#### Output looks like:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... ec2-auto-deploy
```

You will add this to GitHub as a deploy key.

### 2️⃣ Add EC2 SSH Key to GitHub

- Go to your GitHub repo → Settings → Deploy keys → Add deploy key.

- Paste the public key from EC2.

- Check Allow write access (so it can pull/push if needed).

- Click Add key.

✅ Now your EC2 can authenticate with GitHub without a token.

### 3️⃣ Add EC2 Details as GitHub Secrets

#### 🔑 Copy the private key

> ⚠️ Important: Never share this key publicly. Keep it secret.

```
cat ~/.ssh/id_deploy
```

#### ✅ Verify UserName

```
whoami
```

- Go to your GitHub repo → Settings → Secrets → Actions → New repository secret:

| Secret Name   | Value                                      |
| ------------- | ------------------------------------------ |
| `EC2_SSH_KEY` | Paste **private key** (`~/.ssh/id_deploy`) |
| `EC2_USER`    | `ec2-user`                                 |
| `EC2_HOST`    | Your EC2 public IP or DNS                  |

> These secrets will be used by GitHub Actions to SSH into EC2 securely.

### 4️⃣ Keep Your Bash Script on EC2

- Upload your charlie-cafe-devops.sh to EC2 (e.g., ~/charlie-cafe-devops/charlie-cafe-devops.sh).

- Ensure it’s executable:

```
chmod +x ~/charlie-cafe-devops/charlie-cafe-devops.sh
```

✅ This avoids duplicating Docker, DB, git commands in GitHub Actions.

### 5️⃣ Now test:

```
ssh -T git@github.com
```

#### ✅ You should get:

```
Hi awsrmmustansarjavaid! You've successfully authenticated, but GitHub does not provide shell access.
```

✅ Perfect — SSH is working.

#### ✅ Fix host key verification

#### ✅ When you see:

```
The authenticity of host 'github.com (140.82.114.3)' can't be established.
```

- #### ✅ Add GitHub to known hosts:

> #### GitHub is asking if it can trust the server. To fix permanently:

```
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

- This adds GitHub’s public host key to your EC2 so it won’t ask again.

#### ✅ Now test:

```
ssh -T git@github.com
```

#### ✅ Step 1 Create SSH config for GitHub

```
nano ~/.ssh/config
```

#### Paste exactly:

```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_deploy
  IdentitiesOnly yes
```

Save and exit (CTRL+O, ENTER, CTRL+X)

> This tells SSH to always use id_deploy when connecting to GitHub.

#### ✅ Step 2  Start the SSH agent and add the key

```
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_deploy
```
-  You should see something like: Identity added: /home/ec2-user/.ssh/id_deploy (ec2-auto-deploy)

#### ✅ Step 3  Test connection to GitHub

Hardcode the identity file in SSH command in the script

If you want the script to always work with sudo:

Replace:

```
ssh -T git@github.com
```

With:

```
ssh -i /home/ec2-user/.ssh/id_deploy -o IdentitiesOnly=yes -T git@github.com
```

#### ✅ Expected output:

```
Hi <your-github-username>! You've successfully authenticated, but GitHub does not provide shell access.
```

#### If you still get Permission denied, it usually means:

- Public key not correctly added to GitHub

- Wrong repository (deploy keys are repo-specific)

- SSH config not applied

### 6️⃣ Git Auto Deploy

```
nano ec2_git_auto_deploy.sh
```

[ec2_git_auto_deploy.sh](./infrastructure/scripts/ec2_git_auto_deploy.sh)

```
chmod +x ec2_git_auto_deploy.sh
./ec2_git_auto_deploy.sh
```

- Go to GitHub → Actions → Check the workflow logs.

- #### On EC2, verify Docker:

```
sudo docker ps
```

- You should see your container cafe-app running.

- Open your EC2 public IP in the browser — your app should be live.

### 🚀 ✅ COMPLETE VERIFICATION SCRIPT

Save this as:

```
nano verify-devops-env.sh
```

[verify-devops-env.sh](./infrastructure/scripts/verify-devops-env.sh)

```
chmod +x verify-devops-env.sh
./verify-devops-env.sh
```

### 🌐 Now test in browser:

```
http://YOUR-EC2-PUBLIC-IP
```

### 🚀 After Any Change on EC2

- #### 1️⃣ Go to your project directory

```
cd ~/charlie-cafe-devops
```

- #### 2️⃣ Fix file ownership (if you ever used sudo accidentally)

```
sudo chown -R ec2-user:ec2-user ~/charlie-cafe-devops
```

This ensures Git can write files.

- #### 3️⃣ Pull latest remote changes

Before committing your changes, make sure your branch is up-to-date:

```
git pull --rebase origin main
```

> If you prefer merge instead of rebase:

```
git pull origin main
```

This resolves divergent branches safely.

- ####  4️⃣ Make your changes

Edit files, add new ones, etc.

- #### 5️⃣ Stage changes

```
git add .
```

- #### 6️⃣ Commit changes

```
git commit -m "Describe your change here"
```

- #### 7️⃣ Push to GitHub

```
git push origin main
```

- 8️⃣ Verify push

```
git status
git log -1
```

- git status should show nothing to commit, working tree clean.

- git log -1 shows your last commit pushed.

### ⚠️ Important Notes

- Never run Git commands with sudo inside ~/charlie-cafe-devops.

- Always make sure your branch is synced (git pull --rebase) before pushing.

- If you see "Permission denied" errors, check your SSH deploy key and ssh-agent:

```
ssh-add -l        # lists loaded keys
ssh -T git@github.com
```

### 🧱 Charlie Cafe -- Github Logs

[Charlie Cafe -- Github Logs](./docs/Charlie-cafe_github-logs.md)

```
nano ~/github_logs_setup_capture.sh
```

[github_logs_setup_capture](./infrastructure/scripts/github_logs_setup_capture.sh)

```
chmod +x ~/github_logs_setup_capture.sh
~/github_logs_setup_capture.sh
```

- #### Check logs:

```
ls -la ~/charlie-cafe-devops/github_logs
less ~/charlie-cafe-devops/github_logs/github_logs_173_20260402_151230.txt
```

### 🧱 PHASE 1 — PREPARE YOUR PROJECT (DONE ✅)

✔ Dockerfile

✔ docker-compose

✔ GitHub repo

✔ CI/CD

#### 👉 Good — move next level: real AWS DevOps (ECS + ECR + CI/CD deployment) to upgrade your current Docker + GitHub setup into a production-grade AWS DevOps architecture.

### 🚀 🎯 FINAL TARGET ARCHITECTURE (UPGRADED)

#### You will move from:

```
Local Docker + GitHub CI
```

#### ➡️ TO:

```
GitHub → CI/CD → ECR → ECS (Fargate) → ALB → Users
                          ↓
                         RDS
```

#### Using:

- Amazon ECS

- Amazon ECR

- AWS Fargate

- Application Load Balancer

---
## ☁️ PHASE 2 ☕ Charlie Cafe Full AWS DevOps Upgrade from GitHub

#### Right now:

✅ EC2 deployment → automated

✅ RDS → automated

❌ Lambda → still manual (this is what we’ll fix)

### 1️⃣ IAM Policy 

[Charlie Cafe DevOps IAM Policy](https://github.dev/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/ee4f9cc434fe3a6d5598db09d452667efb16daa2/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20%28Dev%20%2B%20Prod%29/AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20AWS%20IAM%20Policy%20JSON%20Script/Charlie%20Cafe%20DevOps.json)

### 2️⃣ Configure AWS Secrets in GitHub

- Go to GitHub repo → Settings → Secrets → Actions → Add the following secrets:

| Secret Name             | Value                                |
| ----------------------- | ------------------------------------ |
| `AWS_ACCESS_KEY_ID`     | Your IAM user access key             |
| `AWS_SECRET_ACCESS_KEY` | Your IAM user secret key             |
| `AWS_REGION`            | e.g., `us-east-1`                    |
| `AWS_ACCOUNT_ID`        | Your AWS account ID                  |
| `ECR_REPO`              | If using containerized Lambda or ECS |
| `ECS_CLUSTER`           | If using ECS                         |
| `ECS_SERVICE`           | If using ECS                         |

### 3️⃣ Basic Lambda Configurations

```
nano charlie_cafe_devops-rds_setup_full.sh
```

[charlie_cafe_devops-rds_setup_full.sh](./infrastructure/scripts/charlie_cafe_devops-rds_setup_full.sh)

#### 🧪 HOW TO USE

#### 1️⃣ Give permission

```
chmod +x charlie_cafe_devops-rds_setup_full.sh
```

#### 2️⃣ Run

```
./charlie_cafe_devops-rds_setup_full.sh
```

### 4️⃣ Create Lambda Function

- ### 1️⃣ Lambda Function 

- #### Name: 

1. CafeOrderProcessor

2. CafeMenuLambda

3. CafeOrderStatusLambda

4. GetOrderStatusLambda

5. CafeOrderWorkerLambda

6. AdminMarkPaidLambda

7. CafeAnalyticsLambda

8. hr-attendance

9. hr-employee-profile

10. hr-attendance-history

11. hr-leaves-holidays

12. cafe-attendance-admin-service


- ### 2️⃣ Basic Lambda Configurations

#### ✅ STEP 1 — CHECK BASIC SETTINGS

Inside Lambda → Configuration → General configuration

Make sure:

✔ Runtime

```
Python 3.10 or 3.11
```

✔ Timeout

```
10–30 seconds
```

👉 Click Edit → Save

### ✅ STEP 2 — FIX HANDLER (VERY IMPORTANT)

- Go to: 👉 Configuration → Runtime settings

- Click Edit

- Set Handler like this:

```
CafeOrderProcessor.lambda_handler
```

- RULE:

```
filename.function
```

So:

| File              | Handler                       |
| ----------------- | ----------------------------- |
| CafeMenuLambda.py | CafeMenuLambda.lambda_handler |
| hr-attendance.py  | hr-attendance.lambda_handler  |

⚠️ If wrong → CI/CD works but Lambda FAILS

### 4️⃣ Git Auto Deploy

```
nano github-aws-devops-lambda-deploy.sh
```

[github-aws-devops-lambda-deploy.sh](./infrastructure/scripts/github-aws-devops-lambda-deploy.sh)

#### 💡 What you only need to provide:

```
GITHUB_REPO_URL="https://github.com/YOUR_USERNAME/YOUR_REPO.git"
```

- Everything else is fully automated.

#### 🧪 HOW TO USE

#### 1️⃣ Give permission

```
chmod +x github-aws-devops-lambda-deploy.sh
```

#### 2️⃣ Run

```
./github-aws-devops-lambda-deploy.sh
```

---
## ☁️ PHASE 3 — AWS DEVOPS UPGRADE

### 1️⃣  — IAM SETUP (GitHub Access)

#### 1️⃣ Create IAM User

- Go to: IAM → Users → Create User

- Username: charlie-github-user

- Enable: ✔ Programmatic Access

#### 2️⃣ Attach your merged policy:

#### Attach:

```
charlie-cafe-iam-policy
```

#### 3️⃣ Save Credentials

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### 2️⃣ CREATE ECR (DOCKER REGISTRY)

#### 1️⃣ Create Repository

- Go to: ECR → Create Repository

- Name: charlie-cafe

- Visibility: Private

#### 2️⃣ Copy Repository URI

✅ Example:

```
123456789.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe
```

### 3️⃣ ECS SETUP

#### 1️⃣ Create Cluster

- ECS → Clusters → Create

- Type: Fargate

- Name: charlie-cluster

#### 2️⃣ Create Task Definition

- Name: charlie-task

- CPU: 0.5 vCPU

- Memory: 1 GB

#### 3️⃣ Add Container

- Container Config:

- Name: charlie-container

- Image: ECR URI

- Port: 80

#### 4️⃣ (Optional Env Variables)

```
DB_HOST = your-rds-endpoint
DB_USER = admin
DB_PASS = ****
```

### 4️⃣ ALB + ECS SERVICE

> #### KEEP existing ALB and upgrade it for ECS.

#### 1️⃣ Create NEW Target Groups (for ECS)

- 👉 Go to: EC2 → Target Groups

#### 🔵 Blue Target Group

- Name: charlie-blue

- Target type: IP (IMPORTANT)

- Port: 80

- Health check: /health.php

#### 🟢 Green Target Group

- Name: charlie-green

- Same config as above

#### 2️⃣ Update ALB Listener

- Go to: EC2 → Load Balancer → Listeners

- Edit HTTP:80

#### 👉 Set default:

```
Forward → charlie-blue
```

#### 3️⃣ Create ECS Service

- Cluster: charlie-cluster

- Service: charlie-service

- Launch type: Fargate

- Load Balancer:

- Use existing ALB

- Listener: HTTP:80

- Target group: charlie-blue

- Container Mapping:

- Container: charlie-container

- Port: 80

#### 4️⃣ Verify

- Go to: Target Group → charlie-blue

#### You should see:

- IP addresses (NOT EC2)

- Status: Healthy

#### 🌐 Access App

```
http://YOUR-ALB-DNS
```

### 5️⃣ GITHUB CI/CD (AUTO DEPLOY)

### 1️⃣ Add GitHub Secrets

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
AWS_ACCOUNT_ID
ECS_CLUSTER
ECS_SERVICE
ECR_REPO
```

### 🧱 PART 1 — HOW TO ADD GITHUB SECRETS (STEP-BY-STEP)

#### 📍 Where to go 👉 Open your GitHub repository

```
Settings → Secrets and variables → Actions → New repository secret
```

#### ✅ REQUIRED SECRETS 

Add each one manually:

| Secret Name             | Value Example   | Where to Get    |
| ----------------------- | --------------- | --------------- |
| `AWS_ACCESS_KEY_ID`     | AKIA...         | IAM User        |
| `AWS_SECRET_ACCESS_KEY` | xxxxx           | IAM User        |
| `AWS_REGION`            | us-east-1       | Your AWS region |
| `AWS_ACCOUNT_ID`        | 123456789012    | AWS Account     |
| `ECS_CLUSTER`           | charlie-cluster | ECS Console     |
| `ECS_SERVICE`           | charlie-service | ECS Console     |
| `ECR_REPO`              | charlie-cafe    | ECR Repo Name   |

#### 📄 FINAL deploy.yml

```
# ==========================================================
# ☕ Charlie Cafe — FULL DEVOPS CI/CD PIPELINE
# ==========================================================

name: ☕ Charlie Cafe Full DevOps Pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    # ------------------------------------------------------
    # 🌍 GLOBAL VARIABLES (BEST PRACTICE)
    # ------------------------------------------------------
    env:
      AWS_REGION: ${{ secrets.AWS_REGION }}
      AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
      ECR_REPO: ${{ secrets.ECR_REPO }}
      ECS_CLUSTER: ${{ secrets.ECS_CLUSTER }}
      ECS_SERVICE: ${{ secrets.ECS_SERVICE }}

    steps:

    # ------------------------------------------------------
    # 1️⃣ CHECKOUT CODE
    # ------------------------------------------------------
    - name: 📥 Checkout Code
      uses: actions/checkout@v3

    # ------------------------------------------------------
    # 2️⃣ CONFIGURE AWS
    # ------------------------------------------------------
    - name: 🔐 Configure AWS
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    # ------------------------------------------------------
    # 3️⃣ LOGIN TO ECR
    # ------------------------------------------------------
    - name: 🐳 Login to ECR
      run: |
        aws ecr get-login-password --region $AWS_REGION | \
        docker login --username AWS --password-stdin \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

    # ------------------------------------------------------
    # 4️⃣ BUILD IMAGE
    # ------------------------------------------------------
    - name: 🏗️ Build Image
      run: docker build -t $ECR_REPO .

    # ------------------------------------------------------
    # 5️⃣ TAG IMAGE
    # ------------------------------------------------------
    - name: 🏷️ Tag Image
      run: |
        docker tag $ECR_REPO:latest \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest

    # ------------------------------------------------------
    # 6️⃣ PUSH IMAGE
    # ------------------------------------------------------
    - name: 📤 Push Image
      run: |
        docker push \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest

    # ------------------------------------------------------
    # 7️⃣ DEPLOY TO ECS
    # ------------------------------------------------------
    - name: 🚀 Deploy ECS
      run: |
        aws ecs update-service \
          --cluster $ECS_CLUSTER \
          --service $ECS_SERVICE \
          --force-new-deployment

    # ------------------------------------------------------
    # 8️⃣ SUCCESS
    # ------------------------------------------------------
    - name: 🎉 Done
      run: echo "Deployment successful 🚀"
```

### 6️⃣ 🚀 FINAL BASH SCRIPT (ECR + CI/CD TEST + ACCESS URL)

[ECR_CI-CD_TEST.sh](./infrastructure/scripts/ECR_CI-CD_TEST.sh)

#### 🧠 Important Notes (Very Important)

#### 🔹 Replace these values:

```
ECR_URI="YOUR_ECR_URI"
ALB_DNS="YOUR-ALB-DNS"
```

Example:

```
ECR_URI="123456789012.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe"
ALB_DNS="charlie-alb-123456.us-east-1.elb.amazonaws.com"
```

#### ▶️ How to Run

```
chmod +x ECR_CI-CD_TEST.sh
./ECR_CI-CD_TEST.sh
```

### 8️⃣ VERIFY DEPLOYMENT

- ECS → Cluster → Service → Tasks → Running

#### 🔍 Open:

```
http://YOUR-ALB-DNS
```

### 🎯 RESULT (PHASE 2 COMPLETE)

#### You now have:

✅ Dockerized app

✅ ECR storage

✅ ECS deployment

✅ ALB routing

✅ Health checks

✅ GitHub CI/CD

✅ Auto deployment

---
## 🌐 PHASE 4 — BLUE/GREEN DEPLOYMENT (ZERO DOWNTIME)

### 🎯 Flow

```
GitHub → ECR → ECS → CodeDeploy → ALB (Blue/Green)
```

### 1️⃣ Create CodeDeploy App

- Name: charlie-app

- Platform: ECS

### 2️⃣ Create Deployment Group

- Name: charlie-dg

- Cluster: charlie-cluster

- Service: charlie-service

#### Load Balancer:

- ALB: existing

- Production: charlie-blue

- Test: charlie-green

### 3️⃣ appspec.yaml

[appspec.yaml](./appspec.yaml)

### 4️⃣ Update CI/CD

> #### Add this to deploy.yml:

```
- name: 🚀 Deploy with CodeDeploy
  run: |
    aws deploy create-deployment \
      --application-name charlie-app \
      --deployment-group-name charlie-dg \
      --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
      --revision revisionType=AppSpecContent,appSpecContent="{\"content\": \"$(cat appspec.yaml | sed 's/\"/\\\"/g')\"}"
```

### ✅ ✅ FINAL CORRECTED deploy.yml (PRODUCTION READY)

👉 Right now your pipeline is doing:

```
ECS Rolling Update
```

👉 After adding CodeDeploy step, you will have:

```
CodeDeploy Blue/Green Deployment
```

#### ⚠️ IMPORTANT RULE (MUST UNDERSTAND):

You should NOT use both:

- aws ecs update-service ❌

- aws deploy create-deployment ❌

👉 Use ONLY CodeDeploy for Blue/Green


#### This is your clean, fixed, and final version 👇

```
name: ☕ Charlie Cafe Full DevOps Pipeline (Blue/Green)

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    env:
      AWS_REGION: ${{ secrets.AWS_REGION }}
      ECR_REPO: charlie-cafe

    steps:

    # -------------------------------------------------
    # 1️⃣ Checkout Code
    # -------------------------------------------------
    - name: 📥 Checkout Code
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Configure AWS Credentials
    # -------------------------------------------------
    - name: 🔐 Configure AWS
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    # -------------------------------------------------
    # 3️⃣ Login to ECR
    # -------------------------------------------------
    - name: 🐳 Login to ECR
      run: |
        aws ecr get-login-password --region $AWS_REGION | \
        docker login --username AWS --password-stdin \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.$AWS_REGION.amazonaws.com

    # -------------------------------------------------
    # 4️⃣ Build Docker Image
    # -------------------------------------------------
    - name: 🏗️ Build Docker Image
      run: |
        docker build -t $ECR_REPO .

    # -------------------------------------------------
    # 5️⃣ Tag Docker Image
    # -------------------------------------------------
    - name: 🏷️ Tag Image
      run: |
        docker tag $ECR_REPO:latest \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest

    # -------------------------------------------------
    # 6️⃣ Push Image to ECR
    # -------------------------------------------------
    - name: 📤 Push Image
      run: |
        docker push \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest

    # -------------------------------------------------
    # 7️⃣ Deploy using CodeDeploy (Blue/Green)
    # -------------------------------------------------
    - name: 🚀 Deploy with CodeDeploy
      run: |
        aws deploy create-deployment \
          --application-name charlie-app \
          --deployment-group-name charlie-dg \
          --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
          --revision revisionType=AppSpecContent,appSpecContent="{\"content\": \"$(cat appspec.yaml | sed 's/\"/\\\"/g')\"}"

    # -------------------------------------------------
    # 8️⃣ Done
    # -------------------------------------------------
    - name: 🎉 Deployment Completed
      run: echo "Blue/Green deployment successful 🚀"
```

---
## 🌐 PHASE 5 — CANARY + AUTO ROLLBACK + MONITORING

### ✅ Enable Canary Deployment

#### Use:

```
CodeDeployDefault.ECSCanary10Percent5Minutes
```

### ✅ Enable Auto Rollback

#### Enable:

Deployment failure

Alarm triggered

### ✅ Create CloudWatch Alarm

Metric: UnHealthyHostCount

Target group: charlie-green

Threshold: >= 1

### ✅ Attach Alarm to CodeDeploy

Add alarm: charlie-health-alarm

### 🧪 FINAL FLOW

```
Push Code →
Build →
Push ECR →
Deploy →
10% Traffic →
Health Check →
✅ Success → 100%
❌ Failure → Auto Rollback
```

### 🧠 FINAL UNDERSTANDING

#### You now built a real production-grade DevOps system:

✅ CI/CD automation

✅ Containerized deployment

✅ Load balancing

✅ Zero downtime deployment

✅ Canary releases

✅ Auto rollback

✅ Monitoring

### 🚨 COMMON MISTAKES (FIXED)

❌ Using Instance target type → Use IP

❌ Using old EC2 target group → Ignore it

❌ Missing /health.php → Required

❌ Duplicate ALB configs → Now removed


## ✅ Charlie Cafe cleanup

[ec2-cleanup.sh](./infrastructure/scripts/ec2-cleanup.sh)

#### How to use:

- Save this as ec2-cleanup.sh on your EC2.

```
nano ec2-cleanup.sh
```

- Make it executable:

```
chmod +x ec2-cleanup.sh
```

- Run it:

```
./ec2-cleanup.sh
```

---



