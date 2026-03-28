# ☕ Charlie Cafe DevOps Project

### ### 🧱 PHASE 1 — Local Dockerize 

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

### ✅ 1. Create repo on GitHub

- Go to: 👉 https://github.com  → New Repo

- Name:

```
charlie-cafe-devops
```

### ✅ 2. Initialize locally

```
cd charlie-cafe

git init
git add .
git commit -m "Initial commit - Charlie Cafe Project"
```

### ✅ 3. Connect to GitHub

```
git remote add origin https://github.com/YOUR_USERNAME/charlie-cafe-devops.git
git branch -M main
git push -u origin main
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

### 1️⃣ Create a Dockerfile

Inside your project root (charlie-cafe-devops/), create:

### 📦 1. ✅ Dockerfile #1 → MySQL (database with schema.sql)

```
docker/mysql/Dockerfile
```

```
# -------------------------------------------------
# ☕ Charlie Cafe - MySQL Dockerfile (FINAL)
# Auto DB + Schema + Data Setup
# -------------------------------------------------

FROM mysql:8.0

# -------------------------------------------------
# Environment Variables
# -------------------------------------------------
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=cafe_db

# -------------------------------------------------
# Auto-run SQL files on container startup
# (Executed in alphabetical order)
# -------------------------------------------------
COPY infrastructure/rds/schema.sql /docker-entrypoint-initdb.d/01-schema.sql
COPY infrastructure/rds/data.sql /docker-entrypoint-initdb.d/02-data.sql

# -------------------------------------------------
# Expose MySQL port
# -------------------------------------------------
EXPOSE 3306
```

- MySQL image runs the scripts automatically on first container startup.

- verify.sql is not copied — you run it manually or via CI/CD test.

### 📦 2. ✅ Dockerfile #2 → Apache + PHP (frontend)

```
docker/apache-php/Dockerfile
```

```
# -------------------------------------------------
# ☕ Charlie Cafe - FINAL Dockerfile (PHP + Apache)
# Production Ready | DevOps Standard
# -------------------------------------------------

# Use official PHP with Apache
FROM php:8.2-apache

# -------------------------------------------------
# Install required PHP extensions
# (For MySQL / RDS connectivity)
# -------------------------------------------------
RUN docker-php-ext-install mysqli pdo pdo_mysql

# -------------------------------------------------
# Enable Apache rewrite module (for clean URLs / routing)
# -------------------------------------------------
RUN a2enmod rewrite

# -------------------------------------------------
# Set working directory
# -------------------------------------------------
WORKDIR /var/www/html

# -------------------------------------------------
# Copy frontend code (NO modification required)
# -------------------------------------------------
COPY app/frontend/ /var/www/html/

# -------------------------------------------------
# Set proper permissions
# -------------------------------------------------
RUN chown -R www-data:www-data /var/www/html

# -------------------------------------------------
# Expose Apache port
# -------------------------------------------------
EXPOSE 80
```

### 4️⃣ ⚙️ FINAL docker-compose.yml (FULLY CONNECTED)

```
version: "3.8"

services:

  web:
    build:
      context: .
      dockerfile: docker/apache-php/Dockerfile
    container_name: charlie_web
    ports:
      - "8080:80"
    volumes:
      - ./app/frontend:/var/www/html
    depends_on:
      - db
    restart: always

  db:
    build:
      context: .
      dockerfile: docker/mysql/Dockerfile
    container_name: charlie_db
    ports:
      - "3306:3306"
    restart: always
```


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

### 🌐 Now test in browser:

```
http://YOUR-EC2-PUBLIC-IP
```

### 9️⃣ GitHub Workflow (CI/CD)

#### 📁 GitHub Path Folder structure:

```
charlie-cafe-devops/
│
├── .github/
│   └── workflows/
│       └── deploy.yml   ✅ (HERE)
```

#### Create:

```
.github/workflows/deploy.yml
```

```
name: ☕ Charlie Cafe DevOps CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    # -------------------------------------------------
    # MySQL Service (for testing DB schema)
    # -------------------------------------------------
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: rootpassword
          MYSQL_DATABASE: cafe_db
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping -h localhost -uroot -prootpassword --silent"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

    steps:

    # -------------------------------------------------
    # Checkout Code
    # -------------------------------------------------
    - name: 📥 Checkout Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # Install MySQL Client
    # -------------------------------------------------
    - name: 🧰 Install MySQL Client
      run: sudo apt-get update && sudo apt-get install -y mysql-client

    # -------------------------------------------------
    # Wait for MySQL to be ready
    # -------------------------------------------------
    - name: ⏳ Wait for MySQL
      run: |
        until mysqladmin ping -h 127.0.0.1 -uroot -prootpassword --silent; do
          echo "Waiting for MySQL..."
          sleep 5
        done

    # -------------------------------------------------
    # Apply Database Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # Apply Sample Data
    # -------------------------------------------------
    - name: 📊 Apply Sample Data
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/data.sql

    # -------------------------------------------------
    # Run Verification Tests (QA)
    # -------------------------------------------------
    - name: ✅ Run DB Verification
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # Build Docker Image (PHP + Apache)
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # Run Container (Test)
    # -------------------------------------------------
    - name: 🚀 Run Docker Container
      run: docker run -d -p 8080:80 charlie-cafe

    # -------------------------------------------------
    # Basic Health Check
    # -------------------------------------------------
    - name: 🌐 Test Web Server
      run: |
        sleep 10
        curl -I http://localhost:8080 || exit 1

    # -------------------------------------------------
    # Success
    # -------------------------------------------------
    - name: 🎉 Deployment Success
      run: echo "Charlie Cafe CI/CD Pipeline Successful 🚀"
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


### ☁️ PHASE 2 — AWS DEVOPS UPgradion 

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

### 🔐 STEP 2 — ADD GITHUB SECRETS

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

- Go to GitHub: 👉 Settings → Secrets

#### Add:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### 🎯 FINAL RESULT (YOUR PROJECT NOW)

#### You now have:

✅ Dockerized app

✅ GitHub CI/CD

✅ ECR image storage

✅ ECS deployment

✅ Load balancer

✅ Health checks

✅ Auto deployment

### 🧠 WHY THIS IS IMPORTANT

```
This setup transforms your project from a simple lab into a real production system by enabling automated building, testing, containerization, and deployment on scalable cloud infrastructure using ECS and ECR, which is how modern applications are deployed in industry.
```


---




