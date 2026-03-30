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


### ☁️ PHASE 2 — AWS DEVOPS Upgradion 

### ✅ FULL AUTO DEPLOYMENT (GitHub → AWS)

### 🚀 🎯 FINAL GOAL

#### Every time you push code:

```
GitHub → Build Docker → Push to ECR → Deploy to ECS → Live App Updated
```

### 🧱  — CREATE IAM USER FOR GITHUB

### ✅ 1. Go to IAM

- AWS Console → IAM → Users → Create User

### ✅ 2. Configure

- Username:

```
charlie-github-user
```

#### Enable:

✔ Programmatic access

### ✅ 3. Attach Policy

#### Attach your merged policy:

```
charlie-cafe-iam-policy
```

### ✅ 4. Create User

👉 Copy:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### 1️⃣ — CREATE ECR (DOCKER IMAGE STORAGE)

### ✅ Step 1 — Open AWS Console

- Go to: ECR → Repositories → Create repository

### ✅ Step 2 — Create Repo

- Name:

```
charlie-cafe
```

- Visibility: Private

- Click Create

### ✅ Step 3 — Copy Repository URI

#### Example:

```
123456789.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe
```

### 🐳 2️⃣  PUSH DOCKER IMAGE TO ECR

### ✅ Step 1 — Login to ECR

```
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin YOUR_ECR_URI
```

### ✅ Step 2 — Build Image

```
docker build -t charlie-cafe .
```

### ✅ Step 3 — Tag Image

```
docker tag charlie-cafe:latest YOUR_ECR_URI:latest
```

### ✅ Step 4 — Push Image

```
docker push YOUR_ECR_URI:latest
```

### 3️⃣ CREATE ECS CLUSTER

### ✅ Step 1 — Go to ECS

```
ECS → Clusters → Create Cluster
```

### ✅ Step 2 — Select

```
Networking only (Fargate)
```

### ✅ Step 3 — Name:

```
charlie-cluster
```

Click Create

### 4️⃣  CREATE TASK DEFINITION

### ✅ Step 1 — Create Task

```
ECS → Task Definitions → Create
```

### ✅ Step 2 — Choose:

```
Fargate
```

### ✅ Step 3 — Configure

| Field  | Value        |
| ------ | ------------ |
| Name   | charlie-task |
| CPU    | 0.5 vCPU     |
| Memory | 1 GB         |

### ✅ Step 4 — Add Container

| Field | Value             |
| ----- | ----------------- |
| Name  | charlie-container |
| Image | YOUR_ECR_URI      |
| Port  | 80                |

### ✅ Step 5 — Environment Variables (Optional but recommended)

```
DB_HOST = your-rds-endpoint
DB_USER = admin
DB_PASS = ****
```

### 5️⃣ CREATE SERVICE + LOAD BALANCER

### ✅ Step 1 — Create Service

```
Cluster → Create Service
```

### ✅ Step 2 — Configure

| Field        | Value           |
| ------------ | --------------- |
| Launch Type  | Fargate         |
| Task         | charlie-task    |
| Service Name | charlie-service |
| Tasks        | 1               |

### ✅ Step 3 — Add Load Balancer

#### Choose:

```
Application Load Balancer
```

### ✅ Step 4 — Configure

- Listener: HTTP 80

- Target group: create new

### ✅ Step 5 — Health Check Path

```
/health.php
```

### ✅ Step 6 — Create Service

### 6️⃣ ACCESS YOUR APP

#### After deployment:

#### 👉 Copy ALB DNS:

```
http://your-alb-url
```

### 7️⃣ FULL CI/CD (AUTO DEPLOY)

Now upgrade your GitHub pipeline 👇

### ✅ Add ECR + ECS Deploy to deploy.yml

#### Add these steps:

```
# Login to AWS
- name: Configure AWS
  uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: us-east-1

# Login to ECR
- name: Login to ECR
  run: |
    aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin YOUR_ECR_URI

# Build & Push
- name: Build & Push Image
  run: |
    docker build -t charlie-cafe .
    docker tag charlie-cafe:latest YOUR_ECR_URI:latest
    docker push YOUR_ECR_URI:latest

# Deploy to ECS
- name: Deploy ECS
  run: |
    aws ecs update-service \
      --cluster charlie-cluster \
      --service charlie-service \
      --force-new-deployment
```

### 8️⃣ ADD GITHUB SECRETS

- Go to your GitHub repo: 👉 Settings → Secrets → Actions → New repository secret

#### ✅ Add these:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION = us-east-1
ECR_REPOSITORY = charlie-cafe
ECS_CLUSTER = charlie-cluster
ECS_SERVICE = charlie-service
```

### 🐳 STEP 2 — CONFIRM ECR REPO

- Go to: ECR → Repositories

#### Ensure:

```
charlie-cafe
```

exists.

### 🚀 STEP 3 — CONFIRM ECS SETUP

Make sure you already created:

#### ✅ Cluster

```
charlie-cluster
```

#### ✅ Service

```
charlie-service
```

#### ✅ Task Definition

```
charlie-task
```

### ⚠️ IMPORTANT (DO THIS)

#### Your ECS task must use:

- Correct container name

- Image from ECR

- Port 80

### 📄 STEP 4 — FINAL deploy.yml (FULL AUTO DEPLOY)

#### Replace your existing file:

```
.github/workflows/deploy.yml
```

#### ✅ COMPLETE FINAL FILE

```
name: ☕ Charlie Cafe Full DevOps Pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:

    # -------------------------------------------------
    # 1️⃣ Clone Repo
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
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

    # -------------------------------------------------
    # 4️⃣ Build Docker Image
    # -------------------------------------------------
    - name: 🏗️ Build Docker Image
      run: |
        docker build -t $ECR_REPO .

    # -------------------------------------------------
    # 5️⃣ Tag Image
    # -------------------------------------------------
    - name: 🏷️ Tag Image
      run: |
        docker tag $ECR_REPO:latest \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/$ECR_REPO:latest

    # -------------------------------------------------
    # 6️⃣ Push Image to ECR
    # -------------------------------------------------
    - name: 📤 Push Image
      run: |
        docker push \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/$ECR_REPO:latest

    # -------------------------------------------------
    # 7️⃣ Deploy to ECS
    # -------------------------------------------------
    - name: 🚀 Deploy to ECS
      run: |
        aws ecs update-service \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service ${{ secrets.ECS_SERVICE }} \
          --force-new-deployment

    # -------------------------------------------------
    # 8️⃣ Success
    # -------------------------------------------------
    - name: 🎉 Done
      run: echo "Deployment successful 🚀"
```

### ⚠️ STEP 5 — ADD MISSING SECRET

You forgot one important thing:

#### 👉 Add this in GitHub Secrets:

```
AWS_ACCOUNT_ID
```

### 🧪 STEP 7 — TEST PIPELINE

#### Now run:

```
git add .
git commit -m "Test ECS deployment"
git push
```

### 🔍 Watch in GitHub:

👉 Actions tab

You will see:

```
✔ Build Docker
✔ Push to ECR
✔ Deploy ECS
```

### 🌐 STEP 8 — VERIFY DEPLOYMENT

- Go to: ECS → Cluster → Service

#### Check:

```
Tasks → Running
```

#### Then open:

```
http://YOUR-ALB-DNS
```





### 🎯 FINAL RESULT (YOUR PROJECT NOW)

#### You now have:

✅ Dockerized app

✅ Docker build automation

✅ GitHub CI/CD

✅ ECR image storage

✅ ECS deployment

✅ Load balancer

✅ Health checks

✅ Auto deployment

✅ Zero manual deployment

### 🧠 WHY THIS IS HUGE

#### This setup is exactly how companies deploy apps:

- No manual SSH

- No manual Docker run

- Fully automated

- Scalable

### 🧠 WHY THIS IS IMPORTANT

```
This setup transforms your project from a simple lab into a real production system by enabling automated building, testing, containerization, and deployment on scalable cloud infrastructure using ECS and ECR, which is how modern applications are deployed in industry.
```

## 🌐 Blue-Green Deployment on ECS (ZERO downtime)

### 🚀 🎯 WHAT YOU ARE BUILDING

You will upgrade from:

```
Normal ECS deployment (downtime possible)
```

#### ➡️ TO:

```
GitHub → ECR → ECS → CodeDeploy → ALB (Blue/Green)
```

#### Using:

- AWS CodeDeploy

- Amazon ECS

- Application Load Balancer

### 🧠 SIMPLE IDEA (VERY IMPORTANT)

| Version | Meaning                 |
| ------- | ----------------------- |
| Blue    | Old running app         |
| Green   | New version             |
| Switch  | Traffic shifts to Green |

👉 No downtime 🔥

### 🧱 PREREQUISITES (MUST BE READY)

#### You must already have:

✅ ECS Cluster

✅ ECS Service

✅ Task Definition

✅ ALB (working)

✅ Target Group

### ⚠️ IMPORTANT CHANGE

Your ECS Service must use:

```
Deployment type = CodeDeploy (NOT rolling update)
```

### 🧱 CREATE 2 TARGET GROUPS

### ✅ Step 1 — Go to ALB

```
EC2 → Target Groups → Create target group
```

### ✅ Step 2 — Create BLUE Target Group

#### Name:

```
charlie-blue
```

- Port: 80

- Health check path:

```
/health.php
```

- Click Create

### ✅ Step 3 — Create GREEN Target Group

#### Same steps:

```
charlie-green
```

### 🧱 CONFIGURE ALB LISTENER

### ✅ Step 1 — Go to Load Balancer

```
EC2 → Load Balancers → Your ALB
```

### ✅ Step 2 — Edit Listener (Port 80)

#### Default action: 👉 Forward to:

```
charlie-blue
```

###  🧱 CREATE CODEDEPLOY APPLICATION

### ✅ Step 1 — Open CodeDeploy

```
CodeDeploy → Applications → Create
```

### ✅ Step 2 — Configure

| Field            | Value       |
| ---------------- | ----------- |
| Name             | charlie-app |
| Compute platform | ECS         |

### 🧱 CREATE DEPLOYMENT GROUP

### ✅ Step 1 — Create Deployment Group

```
Inside charlie-app → Create deployment group
```

### ✅ Step 2 — Configure

| Field        | Value      |
| ------------ | ---------- |
| Name         | charlie-dg |
| Service role | Create new |

### ✅ Step 3 — Create IAM Role for CodeDeploy

- Go IAM → Roles → Create role

#### Attach Policy:

```
{
  "Effect": "Allow",
  "Action": [
    "ecs:*",
    "elasticloadbalancing:*",
    "codedeploy:*",
    "iam:PassRole"
  ],
  "Resource": "*"
}
```

### ✅ Step 4 — Continue Deployment Group

#### Select:

- Cluster: charlie-cluster

- Service: charlie-service

### ✅ Step 5 — Load Balancer

#### Select:

```
Application Load Balancer
```

### ✅ Step 6 — Add Target Groups

| Type       | Value         |
| ---------- | ------------- |
| Production | charlie-blue  |
| Test       | charlie-green |

### ✅ Step 7 — Deployment Settings

#### Choose:

```
AllAtOnce
```

(or Canary later)


### 🧱 CREATE appspec.yaml

#### 📄 Create file:

```
appspec.yaml
```

#### ✅ FINAL FILE

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

### 🧱 UPDATE GITHUB CI/CD

### ✅ Add Blue-Green Deployment Step

#### Add this to deploy.yml:

```
- name: 🚀 Deploy with CodeDeploy
  run: |
    aws deploy create-deployment \
      --application-name charlie-app \
      --deployment-group-name charlie-dg \
      --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
      --revision revisionType=AppSpecContent,appSpecContent="{\"content\": \"$(cat appspec.yaml | sed 's/\"/\\\"/g')\"}"
```

### 🧱 FULL FLOW (IMPORTANT)

#### When you push:

```
GitHub
 ↓
Build Docker
 ↓
Push to ECR
 ↓
CodeDeploy triggers
 ↓
Green version created
 ↓
Health check runs
 ↓
Traffic shifts
```

### 🧪 PHASE 9 — TEST

### ✅ Step 1

```
git commit -am "blue green test"
git push
```

### ✅ Step 2

- Go to: CodeDeploy → Deployments

### ✅ Step 3

#### Watch:

```
Blue → Green switching
```

### 🎯 FINAL RESULT

You now have:

✅ Zero downtime deployment

✅ Automatic rollback

✅ Traffic shifting

✅ Production-grade system

### 🧠 WHY THIS IS IMPORTANT

> #### Blue-Green deployment ensures users never experience downtime by running two environments simultaneously and switching traffic only after the new version is verified healthy, making deployments safe and reliable in production systems.

### 🎯 ✅ BENEFIT OF THIS TASK (BLUE-GREEN DEPLOYMENT)

In your Charlie Cafe DevOps project, implementing Blue-Green deployment using AWS CodeDeploy with Amazon ECS gives you:

#### 🔹 1. Zero Downtime

Users never see errors when you deploy.
Old version (Blue) stays live until new version (Green) is fully ready.

####  2. Safe Deployment

If new version fails:

👉 Traffic stays on old version

👉 No production break

#### 🔹 3. Instant Rollback

You don’t need to redeploy manually.

👉 Just switch traffic back to Blue

#### 🔹 4. Production-Level Architecture

This is exactly how real companies deploy apps behind Application Load Balancer.

#### 🔹 5. Professional Portfolio Value

This single feature shows:

👉 You understand real DevOps practices

👉 Not just lab-level deployment

## 🌐 Add Canary deployment + Auto rollback + CloudWatch alarms

### 🎯 ✅ WHAT YOU ARE ADDING

####  You are upgrading:

```
Blue/Green Deployment
```

#### ➡️ TO:

```
Canary Deployment + Auto Rollback + Monitoring
```

#### Using:

- AWS CodeDeploy

- Amazon CloudWatch

- Amazon ECS

### 🧠 ✅ BENEFIT (CLEAR & REAL)

#### 🔥 1. Safe Deployment

- Only small % of users get new version first (example: 10%)

#### 🔥 2. Automatic Rollback

- If something breaks → system auto switches back

#### 🔥 3. Zero Downtime

- Users never see failure

#### 🔥 4. Production-Level Reliability

- This is used in real companies (Netflix, Amazon, etc.)

### 🚀 🧱 ENABLE CANARY DEPLOYMENT

### ✅ Step 1 — Open CodeDeploy

```
CodeDeploy → Applications → charlie-app
```

### ✅ Step 2 — Edit Deployment Group

```
charlie-dg → Edit
```

### ✅ Step 3 — Change Deployment Type

#### Find:

```
Deployment configuration
```

### ✅ Step 4 — Select Canary

#### Choose:

```
CodeDeployDefault.ECSCanary10Percent5Minutes
```

### 🔍 Meaning:

| Step  | Action              |
| ----- | ------------------- |
| First | 10% traffic → Green |
| Wait  | 5 minutes           |
| Then  | 100% traffic        |

✅ Step 5 — Save

### 🚀 🧱 ENABLE AUTO ROLLBACK

### ✅ Step 1 — In Same Deployment Group

#### Find:

```
Rollback configuration
```

### ✅ Step 2 — Enable

✔ Enable rollback

### ✅ Step 3 — Select Events

✔ Deployment failure

✔ Alarm threshold breached

### ✅ Step 4 — Save

### 🚀 🧱 CREATE CLOUDWATCH ALARM

### ✅ Step 1 — Open CloudWatch

```
CloudWatch → Alarms → Create Alarm
```

### ✅ Step 2 — Select Metric

#### Click:

```
Browse → ApplicationELB → TargetGroup
```

### ✅ Step 3 — Choose Metric

#### Select:

```
UnHealthyHostCount
```

### ✅ Step 4 — Select Your Target Group

#### 👉 Choose:

```
charlie-green
```

### ✅ Step 5 — Configure Condition

| Field      | Value    |
| ---------- | -------- |
| Threshold  | >= 1     |
| Period     | 1 minute |
| Evaluation | 1        |

👉 Meaning:

If even 1 container fails → alarm triggers

### ✅ Step 6 — Name Alarm

```
charlie-health-alarm
```

### ✅ Step 7 — Create Alarm

### 🚀 🧱 ATTACH ALARM TO CODEDEPLOY

### ✅ Step 1 — Go Back to CodeDeploy

```
charlie-dg → Edit
```

### ✅ Step 2 — Find:

```
CloudWatch alarms
```

### ✅ Step 3 — Add Alarm

#### Select:

```
charlie-health-alarm
```

### ✅ Step 4 — Save

### 🚀 🧱 VERIFY HEALTH CHECK

### ✅ Ensure ALB uses:

```
/health.php
```

### ✅ Your health file must return:

```
status: OK
```

### 🚀 🧱 DEPLOY USING GITHUB

### ✅ Push Code

```
git add .
git commit -m "canary deployment test"
git push
```

### 🧪 PHASE 7 — WHAT WILL HAPPEN

#### Step-by-step:

```
1. GitHub builds Docker
2. Push to ECR
3. CodeDeploy starts
4. New version = GREEN
5. 10% traffic goes to GREEN
6. CloudWatch monitors health
```

### ✅ IF EVERYTHING OK

```
After 5 minutes → 100% traffic → GREEN
```

### ❌ IF ERROR HAPPENS

```
CloudWatch Alarm triggers
↓
CodeDeploy detects failure
↓
AUTO ROLLBACK
↓
Traffic back to BLUE
```

### 🎯 FINAL RESULT

You now have:

✅ Canary 

✅ Automatic rollback

✅ Health monitoring

✅ Zero downtime

✅ Production-grade system

### 🧠 FINAL UNDERSTANDING

> #### This setup ensures that new versions are released gradually and safely, while continuously monitoring system health and automatically reverting changes if any issue is detected, making deployments reliable and risk-free.

---
## upgrade your existing ALB setup for ECS + Blue/Green

.

### 🧠 🔥 FIRST — UNDERSTAND THE SITUATION

#### You currently have:

✅ ALB (for EC2)

✅ 1 Target Group (EC2 instance)

#### 👉 But for ECS Blue/Green you need:

❗ 2 Target Groups (Blue + Green)

❗ Target type = IP (not Instance)

### 🚨 IMPORTANT DIFFERENCE

| Old Setup (EC2)        | New Setup (ECS)             |
| ---------------------- | --------------------------- |
| Target type = Instance | Target type = IP            |
| Register EC2 manually  | ECS registers automatically |
| 1 Target Group         | 2 Target Groups             |

### ✅ WHAT YOU WILL DO (NO CONFUSION)

#### 👉 You will:

KEEP existing ALB ✅

IGNORE old EC2 target group ❌

CREATE new ECS target groups ✅

UPDATE listener ✅


### 🧱 STEP 1 — KEEP YOUR EXISTING ALB

- ✅ Go to: EC2 → Load Balancers → charlie-cafe-alb

✔ KEEP IT

❌ Do NOT delete

### 🧱 STEP 2 — CREATE NEW TARGET GROUP (BLUE)

- ✅ Go to: EC2 → Target Groups → Create

### ✅ Configure:

| Field       | Value           |
| ----------- | --------------- |
| Target type | IP ⚠️ IMPORTANT |
| Name        | charlie-blue    |
| Protocol    | HTTP            |
| Port        | 80              |
| VPC         | Same as ECS     |

### ✅ Health Check

```
/health.php
```

- ✅ Click Create

### 🧱 STEP 3 — CREATE GREEN TARGET GROUP

#### Repeat same steps:

```
Name: charlie-green
Target type: IP
```

### 🧱 STEP 4 — UPDATE ALB LISTENER

- ✅ Go to: EC2 → Load Balancers → charlie-cafe-alb

- ✅ Click: Listeners → HTTP : 80 → Edit

- #### ✅ Change Default Action: 

  - 👉 FROM: Old EC2 target group

  - 👉 TO: charlie-blue



- ✅ Save

### 🧱 STEP 5 — REMOVE OLD EC2 TARGET GROUP (OPTIONAL)

#### 👉 You can:

- Keep it (safe)

- Or delete later

### 🧱 STEP 6 — CREATE ECS SERVICE (USE EXISTING ALB)

- ✅ Go to: ECS → Cluster → charlie-cluster → Create Service

- #### ✅ Configure:

| Field        | Value           |
| ------------ | --------------- |
| Launch Type  | Fargate         |
| Task         | charlie-task    |
| Service Name | charlie-service |

- #### ✅ Load Balancer Section → 👉 Choose: Use existing load balancer

- #### ✅ Select:

| Field         | Value            |
| ------------- | ---------------- |
| Load Balancer | charlie-cafe-alb |
| Listener      | HTTP:80          |
| Target Group  | charlie-blue     |

- #### ✅ Container mapping

| Field          | Value             |
| -------------- | ----------------- |
| Container name | charlie-container |
| Port           | 80                |

- ✅ Create Service

### 🧱 STEP 7 — VERIFY ECS REGISTRATION

#### After service starts:

- 👉 Go to: Target Groups → charlie-blue → Targets

#### ✔ You should see:

```
IP addresses (NOT EC2 ID)
```

#### ✔ Status:

```
Healthy
```

### 🧱 STEP 8 — CONFIGURE CODEDEPLOY (IMPORTANT)

- ✅ Go to: CodeDeploy → Deployment Group

- #### ✅ Configure:

| Field         | Value            |
| ------------- | ---------------- |
| Load Balancer | charlie-cafe-alb |
| Production    | charlie-blue     |
| Test          | charlie-green    |

### 🎯 FINAL RESULT

#### Now your setup is:

```
ALB
 ↓
charlie-blue (LIVE)
charlie-green (NEW)
```

### 🔁 HOW IT WORKS NOW

#### During deployment:

- Green gets new version

- Health check runs

- Traffic shifts

- Blue becomes backup

### 🚨 COMMON MISTAKES (VERY IMPORTANT)

❌ Using Instance target type → WILL FAIL

❌ Using old EC2 target group → WRONG

❌ Not setting /health.php → unhealthy

### 🧠 FINAL CLARITY

👉 You are NOT replacing ALB

👉 You are upgrading it for ECS

### ✅ SIMPLE SUMMARY

| Step | Action                          |
| ---- | ------------------------------- |
| 1    | Keep ALB                        |
| 2    | Create 2 new target groups (IP) |
| 3    | Update listener → blue          |
| 4    | Create ECS service using ALB    |
| 5    | Attach both TGs in CodeDeploy   |

### 🚀 YOUR STATUS NOW

#### You now understand:

✅ ALB reuse

✅ ECS integration

✅ Blue/Green routing

✅ Target group difference

---