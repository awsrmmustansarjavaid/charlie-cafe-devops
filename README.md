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
Cluster: charlie-cluster
Service: charlie-service
Launch type: Fargate
Load Balancer:
Use existing ALB
Listener: HTTP:80
Target group: charlie-blue
Container Mapping:
Container: charlie-container
Port: 80

#### 4️⃣ Verify
Go to: Target Group → charlie-blue
You should see:
IP addresses (NOT EC2)
Status: Healthy

#### 🌐 Access App





