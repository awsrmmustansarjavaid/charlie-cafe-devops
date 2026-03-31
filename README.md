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
├── LICENSE
├── .gitignore
├── .dockerignore                
├── docker-compose.yml
│
├── app/                         # Your original code (UNCHANGED)
│   ├── frontend/
│   │   ├── *.html
│   │   ├── *.php
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

### 1️⃣ Initialize GitHub Repo

### 1️⃣ Create repo on GitHub

- Go to: 👉 https://github.com  → New Repo

- Name:

```
charlie-cafe-devops
```

### 2️⃣ Create DEVOPS Files

#### 📑 1. [Dockerfile](./docker/apache-php/Dockerfile)

#### 📑 2. [docker-compose.yml](./docker-compose.yml)

#### 📑 3. [.dockerignore](https://github.com/awsrmmustansarjavaid/charlie-cafe-devops/blob/main/.dockerignore)

#### 📑 4. [.gitignore](https://github.com/awsrmmustansarjavaid/charlie-cafe-devops/blob/main/.gitignore)

#### 📑 5. [deploy.yml](https://github.com/awsrmmustansarjavaid/charlie-cafe-devops/blob/main/.github/workflows/deploy.yml)

### 3️⃣ Initialize DEVOPS SCRIPT

#### 📁 Read More [Charlie Cafe DEVOPS](./docs/charlie-cafe-devops.md)

```
nano charlie-cafe-devops.sh
```

[charlie-cafe-devops.sh](./infrastructure/scripts/charlie-cafe-devops.sh)

### ⚠️ Final Quick Checklist

Before running:

```
chmod +x charlie-cafe-devops.sh
./charlie-cafe-devops.sh
```

#### ⚠️ FINAL THINGS YOU MUST EDIT BEFORE RUN

🔴 1. GitHub Username

```
GITHUB_USERNAME="YOUR_USERNAME"
```

🔴 2. AWS Secret ARN

```
SECRET_ARN="your-real-secret-arn"
```

🔴 3. Project Folder Name

```
PROJECT_DIR="charlie-cafe"
```

👉 Make sure your folder name matches EXACTLY

🔴 4. (Optional) Port

```
PORT="80"
```

🔴 5. EC2 Security Group

Make sure port is open:

- HTTP → 80

- Or 8080 if changed

### 🌐 Now test in browser:

```
http://YOUR-EC2-PUBLIC-IP
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

## ☁️ PHASE 2 — AWS DEVOPS UPGRADE

### ✅ FULL AUTO DEPLOYMENT (GitHub → AWS)

### 🚀 🎯 FINAL GOAL

#### Every time you push code:

```
GitHub → Build Docker → Push to ECR → Deploy to ECS → Live App Updated
```

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

### 3️⃣  PUSH DOCKER IMAGE TO ECR

#### 🐳 PUSH DOCKER IMAGE (MANUAL TEST)

```
# Login
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin YOUR_ECR_URI

# Build
docker build -t charlie-cafe .

# Tag
docker tag charlie-cafe:latest YOUR_ECR_URI:latest

# Push
docker push YOUR_ECR_URI:latest
```

### 4️⃣ ECS SETUP

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

### 5️⃣ ALB + ECS SERVICE

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

### 6️⃣ GITHUB CI/CD (AUTO DEPLOY)

#### 1️⃣ Add GitHub Secrets

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
AWS_ACCOUNT_ID
ECS_CLUSTER
ECS_SERVICE
ECR_REPO
```

#### 📄 FINAL deploy.yml

```
name: ☕ Charlie Cafe Full DevOps Pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:

    - name: 📥 Checkout Code
      uses: actions/checkout@v3

    - name: 🔐 Configure AWS
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: 🐳 Login to ECR
      run: |
        aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | \
        docker login --username AWS --password-stdin \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

    - name: 🏗️ Build Image
      run: docker build -t charlie-cafe .

    - name: 🏷️ Tag Image
      run: |
        docker tag charlie-cafe:latest \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/charlie-cafe:latest

    - name: 📤 Push Image
      run: |
        docker push \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/charlie-cafe:latest

    - name: 🚀 Deploy ECS
      run: |
        aws ecs update-service \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service ${{ secrets.ECS_SERVICE }} \
          --force-new-deployment

    - name: 🎉 Done
      run: echo "Deployment successful 🚀"
```

### 7️⃣ TEST PIPELINE

```
git add .
git commit -m "test deployment"
git push
```

👉 Check: GitHub → Actions

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
## 🌐 PHASE 3 — BLUE/GREEN DEPLOYMENT (ZERO DOWNTIME)

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

```
version: 1
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "charlie-task"
        LoadBalancerInfo:
          ContainerName: "charlie-container"
          ContainerPort: 80
```

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
## 🌐 PHASE 4 — CANARY + AUTO ROLLBACK + MONITORING

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




