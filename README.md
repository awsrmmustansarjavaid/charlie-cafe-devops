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

- **Refer:** [AWS Charlie Cafe Project](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/1eec632562867d778e7f490f9e0efcfc57027b6f/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20%28Dev%20%2B%20Prod%29/AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project.md)

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

> #### Optional Task 

- Read more here [GitHub Auto-Deploy Config](./docs/GitHub_Auto-Deploy_Config.md)

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

[Charlie Cafe DevOps IAM Policy](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/ee4f9cc434fe3a6d5598db09d452667efb16daa2/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20%28Dev%20%2B%20Prod%29/AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20AWS%20IAM%20Policy%20JSON%20Script/Charlie%20Cafe%20DevOps.json)

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

| Lambda Function Name          | Python File Name                 | Handler (Set in Lambda)                      |
| ----------------------------- | -------------------------------- | -------------------------------------------- |
| CafeOrderProcessor            | CafeOrderProcessor.py            | CafeOrderProcessor.lambda_handler            |
| CafeMenuLambda                | CafeMenuLambda.py                | CafeMenuLambda.lambda_handler                |
| CafeOrderStatusLambda         | CafeOrderStatusLambda.py         | CafeOrderStatusLambda.lambda_handler         |
| GetOrderStatusLambda          | GetOrderStatusLambda.py          | GetOrderStatusLambda.lambda_handler          |
| CafeOrderWorkerLambda         | CafeOrderWorkerLambda.py         | CafeOrderWorkerLambda.lambda_handler         |
| AdminMarkPaidLambda           | AdminMarkPaidLambda.py           | AdminMarkPaidLambda.lambda_handler           |
| CafeAnalyticsLambda           | CafeAnalyticsLambda.py           | CafeAnalyticsLambda.lambda_handler           |
| hr-attendance                 | hr-attendance.py                 | hr-attendance.lambda_handler                 |
| hr-employee-profile           | hr-employee-profile.py           | hr-employee-profile.lambda_handler           |
| hr-attendance-history         | hr-attendance-history.py         | hr-attendance-history.lambda_handler         |
| hr-leaves-holidays            | hr-leaves-holidays.py            | hr-leaves-holidays.lambda_handler            |
| cafe-attendance-admin-service | cafe-attendance-admin-service.py | cafe-attendance-admin-service.lambda_handler |

- ### 2️⃣ Basic Lambda Configurations

| Setting         | Value                          |
|-----------------|--------------------------------|
| Runtime         | Python 3.10, 3.11, or 3.12    |
| Architecture    | x86_64                         |
| Execution role  | Use existing role              |
| Role            | Lambda-Cafe-Order-Role         |
| Timeout         | 10–30 seconds                  |

- ### 3️⃣ FIX HANDLER (VERY IMPORTANT)

- Go to: 👉 Scroll Down → Runtime settings

- Click Edit

- Set Handler like this:

```
CafeOrderProcessor.lambda_handler
```

- RULE:

```
filename.function
```


⚠️ If wrong → CI/CD works but Lambda FAILS

- Save

✅ You only need to do this once per function. After this, your Bash script can fully update the code and layers automatically.

- ### 4️⃣ Move Lambda Into VPC

| Lambda Function Name             |
|---------------------------------|
| CafeOrderProcessor               | 
| CafeOrderStatusLambda            | 
| GetOrderStatusLambda             | 
| CafeOrderWorkerLambda            | 
| AdminMarkPaidLambda              | 
| CafeAnalyticsLambda              | 
| hr-attendance                    | 
| hr-employee-profile              | 
| hr-attendance-history            | 
| hr-leaves-holidays               | 
| cafe-attendance-admin-service    | 

- AWS Console → Lambda → Your Function

- Go to Configuration → Open VPC → Click Edit

- Select:

  - VPC → same as EC2

  - Subnets → PRIVATE subnets (important)

  - Security Group → Lambda SG

- Save

- ### 5️⃣ 🌐 Environment Variables

- #### 1️⃣ CafeOrderProcessor

| Key           | Value                  |
| ------------- | ---------------------- |
| SQS_QUEUE_URL | (paste your Queue URL) |

- #### 2️⃣ cafe-attendance-admin-service

| Key              | Value            |
|------------------|------------------|
| DYNAMODB_TABLE   | CafeAttendance   |


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

### 🌐 Verification Test 

#### 1️⃣ One-liner to list all Lambda functions in your region

```
aws lambda list-functions --region us-east-1 --query 'Functions[].FunctionName' --output table
```

✅ This will show a table of all Lambda function names. You can check if your functions (like CafeOrderProcessor or CafeMenuLambda) exist.

#### 2️⃣ Optional: check if a specific Lambda exists before running script

```
LAMBDA_NAME="CafeOrderProcessor"
aws lambda get-function --function-name $LAMBDA_NAME --region us-east-1 >/dev/null 2>&1 && echo "$LAMBDA_NAME exists ✅" || echo "$LAMBDA_NAME does not exist ❌"
```

- Replace CafeOrderProcessor with any function name

- Returns exists / does not exist

#### 3️⃣ Bash snippet to check all your functions at once

```
#!/bin/bash

LAMBDA_LIST=("CafeOrderProcessor" "CafeMenuLambda" "CafeOrderStatusLambda" "GetOrderStatusLambda")

for func in "${LAMBDA_LIST[@]}"; do
    aws lambda get-function --function-name "$func" --region us-east-1 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ $func exists"
    else
        echo "❌ $func does not exist"
    fi
done
```

- This is a pre-check script you can run before your main deployment script

- Ensures all Lambda functions exist and are ready to receive code and layers

### EC2 Docker Health

```
nano ec2_docker_health.sh
```

[ec2_docker_health.sh](./infrastructure/scripts/ec2_docker_health.sh)

#### 🔹 Usage

```
chmod +x ec2_docker_health.sh
./ec2_docker_health.sh
```

✅ This will work every time on EC2, no matter where you run it from, as long as the repo is cloned in ~/charlie-cafe-devops.

### Docker Container

Read more [verify_docker-container](./docs/Readme/verify_docker-container.md)


---
## ☁️ PHASE 3 — AWS DEVOPS UPGRADE

### 1️⃣ CREATE ECR (DOCKER REGISTRY)

#### 1️⃣ Create Repository

- Go to: ECR → Create Repository

- Name: charlie-cafe

- Visibility: Private

- Keep Mutable tags (default)

- Click Create repository

#### ✅ Copy Repository URI

- ✅ Example: You should now see your repo:

```
123456789.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe
```

#### 2️⃣ Login to ECR

On your local machine (or EC2):

```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
```

#### 3️⃣ Go to the folder with the Dockerfile

```
cd ~/charlie-cafe-devops/docker/apache-php/
```

  - Check the file exists:

#### should show your Dockerfile

```
ls -l Dockerfile
```

#### 4️⃣ Build and Tag Docker Image

From your project directory (where Dockerfile is):

```
docker build -t charlie-cafe .
```

- -t charlie-cafe → names your image charlie-cafe.

- . → tells Docker to use the current folder for the Dockerfile and context.

#### 5️⃣ Tag the Docker image for ECR

```
docker tag charlie-cafe:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
```

#### 6️⃣ Push the Docker image to ECR

```
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
```

✅ After this, your Docker image will be in ECR, ready for ECS or Fargate deployment.

#### 💡 Optional tip: If you want to build from anywhere, you can also specify the Dockerfile path:

```
docker build -t charlie-cafe -f ~/charlie-cafe-devops/docker/apache-php/Dockerfile ~/charlie-cafe-devops/docker/apache-php/
```

✅ This avoids having to cd into the folder.

### 2️⃣ ECS SETUP

#### 1️⃣ Create Cluster

- Go ECS → Clusters → Create Cluster

- Type: Fargate

> #### Networking Only (Fargate)

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

### 3️⃣ ALB + ECS SERVICE

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

### 4️⃣ GITHUB CI/CD (AUTO DEPLOY)

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



