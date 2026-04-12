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

### ✅ Prerequisites

#### 🔹 0. GITHUB

- Github Account

- Github Repo

- Github Repository secrets

#### 🔹 1. AWS Account

- Active AWS account with proper IAM permissions

#### 🔹 2. AWS Services Knowledge

#### 🌐 Networking Services

- VPC (Virtual Private Cloud)

- Security Groups

- VPC Endpoints

- NAT Gateway

- Internet Gateway (IGW)

- Application Load Balancer (ALB)

- EC2 (Elastic Compute Cloud)

- CloudFront

#### 🗄️ Database Services

- RDS (Relational Database Service)

- DynamoDB

#### 🔐 Credential & Secret Management

- AWS Secrets Manager

#### 🔑 Authentication & Authorization

- Amazon Cognito

#### ⚡ Serverless Services

- AWS Lambda

- API Gateway

#### 🚀 DevOps & Container Services

- ECS (Elastic Container Service)

- ECR (Elastic Container Registry)

#### 🔹 3. Technical Skills

- Basic Linux commands

- Basic networking concepts (optional but recommended)

- PHP and MySQL fundamentals

#### 🔹 4. Tools & Access

- SSH client (e.g., PuTTY, Terminal) or AWS Cloud9

- Git & GitHub basics

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

---
## 1️⃣ Initialize GitHub Repo

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

#### ✅ Paste 

[GitHub-Actions](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/AWS%20Services%20Configurations%20/AWS%20IAM%20Role%20&%20Policies/Charlie%20Cafe%20IAm%20Policies/GitHub-Actions.json)

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

### 4️⃣ Configure AWS Secrets in GitHub

- Go to GitHub repo → Settings → Secrets → Actions → Add the following secrets:

| Secret Name             | Value                                          |
| ----------------------- | ---------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | Your IAM user access key                       |
| `AWS_SECRET_ACCESS_KEY` | Your IAM user secret key                       |
| `AWS_REGION`            | e.g., `us-east-1`                              |
| `AWS_ACCOUNT_ID`        | Your AWS account ID                            |
| `EC2_INSTANCE_ID`       | `i-0123456789abcdef0` (target EC2)             |
| `EC2_USER`              | `ec2-user` (default username)                  |
| `ECR_REPO`              | If using containerized Lambda or ECS           |
| `ECS_CLUSTER`           | If using ECS                                   |
| `ECS_SERVICE`           | If using ECS                                   |
| `RDS_SECRET_ARN`        | ARN of your AWS Secrets Manager RDS credential |

---
## 2️⃣ Initialize AWS 



### 1️⃣ IAM Policy 

[Charlie Cafe DevOps IAM Policy](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/AWS%20Services%20Configurations%20/AWS%20IAM%20Role%20&%20Policies/Charlie-Cafe_IAM_Roles_Config.md)



---
## ☁️ PHASE 2 ☕ Charlie Cafe Full AWS DevOps Upgrade from GitHub

#### Right now:

✅ EC2 deployment → automated

✅ RDS → automated

❌ Lambda → still manual (this is what we’ll fix)



### 2️⃣ Basic Lambda Configurations

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

### 3️⃣ Create Lambda Function

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

### 4️⃣ API Gateway Endpoints

#### 1️⃣ Create a REST API

- Open AWS Management Console → API Gateway.

- Click Create API.

- Choose REST API → Build.

- Configuration:

  - API name: CafeOrderAPI

  - Description: API for processing café orders

  - Endpoint type: Regional (default)

- Click Create API.

#### 2️⃣ Create Resource

- In your API, click Resources → Actions → Create Resource.

- Configure:

  - Integration type: Lambda Function

  - Lambda Region: us-east-1

  - Check Use Lambda Proxy integration

| Resource Name        | Resource Path           | Lambda Function                | API Method | Enable CORS |
|---------------------|------------------------|-------------------------------|------------|-------------|
| orders              | /orders               | CafeOrderProcessor            | POST       | Yes         |
| get-order-status    | /get-order-status     | GetOrderStatusLambda          | GET        | Yes         |
| cafe-order-status   | /cafe-order-status    | CafeOrderStatusLambda         | GET        | Yes         |
| order-update        | /order-update         | CafeOrderWorkerLambda         | POST       | Yes         |
| mark-paid           | /admin/mark-paid      | AdminMarkPaidLambda           | POST       | Yes         |
| analytics           | /analytics            | CafeAnalyticsLambda           | GET        | Yes         |
| Attendance          | /attendance/checkin   | hr-attendance                 | POST       | Yes         |
| Attendance          | /attendance/checkout  | hr-attendance                 | POST       | Yes         |
| Employee Profile    | /employee-profile     | hr-employee-profile           | POST       | Yes         |
| Attendance History  | /attendance-history   | hr-attendance-history         | POST       | Yes         |
| Leaves & Holidays   | /leaves-holidays      | hr-leaves-holidays            | POST       | Yes         |
| hr-analytics        | /hr-analytics         | cafe-attendance-admin-service | GET        | Yes         |

- Click Save → OK to give permissions to API Gateway to invoke Lambda.

#### 3️⃣ Enable CORS (Cross-Origin Resource Sharing)
> Repeat the same configuration for all API application resources listed above.

- Select resource 

> for example /orders

- Click Actions → Enable CORS.

- Configure:

  - Allowed Methods: Select method of paritcular resource

  - Allowed Headers: Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token

  - Allow Credentials: unchecked

- Click Enable CORS and replace existing CORS headers.

- Click Yes, replace existing values if prompted.

#### 4️⃣ Deploy API

- Click Actions → Deploy API.

- Configure:

  - Deployment stage: prod

  - Stage description: Development stage

  - Deployment description: Initial deployment

- Click Deploy.

#### 5️⃣ Cognito Authorizers

- Go to Authorizers

- Create new:

  - Name: Cognito-Authorizer

  - Type: Cognito

  - User Pool: your pool

  - Token source: Authorization

- Attach authorizer to these 3 endpoints:

```
/employee-profile

/attendance-history

/leaves-holidays
```

👉 Now API Gateway expects:

```
Authorization: Bearer <JWT>
```

#### 6️⃣ Copy API Invoke URL

After deployment, you’ll see an Invoke URL at the top of the Stage page, e.g.:

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/
```

#### ✅ Final API Endpoint

| Resource Name        | Full Endpoint URL                                      | Lambda Function                | Method | CORS |
|---------------------|--------------------------------------------------------|-------------------------------|--------|------|
| orders              | https://api.yourdomain.com/orders                     | CafeOrderProcessor            | POST   | Yes  |
| get-order-status    | https://api.yourdomain.com/get-order-status          | GetOrderStatusLambda          | GET    | Yes  |
| cafe-order-status   | https://api.yourdomain.com/cafe-order-status         | CafeOrderStatusLambda         | GET    | Yes  |
| order-update        | https://api.yourdomain.com/order-update              | CafeOrderWorkerLambda         | POST   | Yes  |
| mark-paid           | https://api.yourdomain.com/admin/mark-paid           | AdminMarkPaidLambda           | POST   | Yes  |
| analytics           | https://api.yourdomain.com/analytics                 | CafeAnalyticsLambda           | GET    | Yes  |
| attendance-checkin  | https://api.yourdomain.com/attendance/checkin        | hr-attendance                 | POST   | Yes  |
| attendance-checkout | https://api.yourdomain.com/attendance/checkout       | hr-attendance                 | POST   | Yes  |
| employee-profile    | https://api.yourdomain.com/employee-profile          | hr-employee-profile           | POST   | Yes  |
| attendance-history  | https://api.yourdomain.com/attendance-history        | hr-attendance-history         | POST   | Yes  |
| leaves-holidays     | https://api.yourdomain.com/leaves-holidays           | hr-leaves-holidays            | POST   | Yes  |
| hr-analytics        | https://api.yourdomain.com/hr-analytics              | cafe-attendance-admin-service | GET    | Yes  |

Your endpoint becomes:

```
https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/orders

https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/get-order-status

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/cafe-order-status

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/order-update

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/admin/mark-paid

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/analytics

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/attendance/checkin

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/attendance/checkout

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/employee-profile

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/attendance-history

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/leaves-holidays

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/hr-analytics

```

### 5️⃣ Git Auto Deploy

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

Read more about [Charlie Cafe - AWS DEVOPS ECS & ECR Configurations](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/AWS%20Services%20Configurations%20/Charlie-cafe_AWS-DEVOPS_ECS_ECR-Configurations.md)

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

- ### 1️⃣ Create ECS Service-Linked IAM Role

- Go to IAM → Roles → Create Role.

- Choose AWS Service → Elastic Container Service.

- Under Use Case, select Elastic Container Service (this is for ECS itself, not tasks or EC2).

- Click Next: Permissions → You do not need to attach any extra policy (AWS adds AmazonECSServiceRolePolicy automatically).

- Name the role: AWSServiceRoleForECS.

- Click Create Role.

✅ This is the official Service-Linked Role required by ECS.

### Option B: Automatic (Easiest)

Run this CLI command in your AWS CLI:

```
aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com
```

✅ This automatically creates the required role: AWSServiceRoleForECS

> Note: This requires your IAM user/role to have iam:CreateServiceLinkedRole permission.

- ### 2️⃣ Create ECS Cluster

- Go to ECS → Clusters → Create Cluster.

- Select Networking Only (Fargate).

- Click Next Step.

- Name your cluster: charlie-cluster.

- Leave other defaults (VPC, subnets) for now unless you have a specific setup.

- Click Create.

Wait until the status shows Active.

✅ No need to attach EC2 instances since this is Fargate.

- ### 3️⃣ Create Task Execution Role (if not exists)

The task execution role is needed for Fargate to pull images from ECR and write logs to CloudWatch.

- Go to IAM → Roles → Create Role → AWS Service → Elastic Container Service → Task Execution Role.

- Click Next: Permissions.

- Attach AmazonECSTaskExecutionRolePolicy.

- Name it: ecsTaskExecutionRole.

- Click Create Role.

This role will be used later in the task definition.

- ### 4️⃣ Create Task Definition

- Go to ECS → Task Definitions → Create new Task Definition.

- Select Fargate → Click Next.

- Task Definition Family: charlie-task.

- Task Role: Leave None (for now).

- Task Execution Role: Select ecsTaskExecutionRole created in Step 2.

- Network Mode: awsvpc.

- CPU: 0.5 vCPU.

- Memory: 1 GB.

- Click Next to add containers.

- ### 5️⃣ Add Container to Task

- Container Name: charlie-container.

- Image: 537236558357.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest.

- Port Mapping:

- Container Port: 80

- Protocol: TCP

- Environment Variables (optional for now):

  - DB_HOST = your-rds-endpoint

  - DB_USER = admin

  - DB_PASS = your-password

- Logging:

  - Check Enable CloudWatch Logs

  - Log group: /ecs/charlie-task

  - Region: us-east-1

  - Stream prefix: ecs

- Create log group: true

- Leave other optional settings (HealthCheck, Restart Policy, Storage) as default.

- Click Add → Click Create Task Definition.

- ### 6️⃣  Network Connectivity

> #### NAT GW / VPC ENDPoint

Read more [“Click here for configuration.”](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/charlie-cafe-devops-Network%20Connectivity.md)

#### 🔹 Step 1: VPC Endpoints (Private Access)

| Endpoint                        | Type      | Notes                                            |
| ------------------------------- | --------- | ------------------------------------------------ |
| com.amazonaws.us-east-1.ecr.api | Interface | ECS tasks → ECR API                              |
| com.amazonaws.us-east-1.ecr.dkr | Interface | ECS tasks → Docker registry                      |
| com.amazonaws.us-east-1.s3      | Gateway   | Needed because ECR image layers are stored in S3 |

- Steps:

  - Go VPC → Endpoints → Create Endpoint

  - Choose service (above)

  - Attach private subnet of ECS tasks

  - Security group: allows inbound HTTPS from ECS tasks

  - Redeploy ECS service

✅ This is recommended if you want production-level private networking.

#### 🔹 Step 2: Quick Test Before Redeploy

Use a temporary EC2 instance in the same subnet as your ECS tasks:

```
# Test ECR API
curl -v https://api.ecr.us-east-1.amazonaws.com/

# Test ECR Docker registry
curl -v https://537236558357.dkr.ecr.us-east-1.amazonaws.com/v2/
```

- Timeout → network problem

- JSON / HTTP 200 → network works

#### 🔹 Step 3: Verify ECS Once Networking Works

After your tasks can access ECR:

- Go to ECS → Clusters → charlie-cluster → Services → charlie-service

- Check Tasks:

  - Status: Running

  - Last Status: RUNNING

- Go to Target Groups → charlie-blue → Targets

  - Status: Healthy

  - Should see the private IP of the Fargate task

- Open your ALB DNS in browser:

  - You should see your app page served from the container

- Logs:

  - Go to CloudWatch Logs (if configured in task definition)

  - Verify container starts without errors

- ### 7️⃣  Run Task in Cluster

- Go to ECS → Clusters → charlie-cluster → Tasks → Run new Task.

- Launch Type: Fargate.

- Task Definition: charlie-task:1 (latest revision).

- Cluster VPC & Subnets: select defaults or your preferred VPC.

- Security group: allow TCP 80 (HTTP) from 0.0.0.0/0 if public access needed.

- Click Run Task.

✅ Your container should start. Check Logs → CloudWatch → /ecs/charlie-task to verify the app is running.

- ### 8️⃣  Verify Container

- Go to ECS → Cluster → Tasks.

- Click on your task → Containers → View Logs.

- Verify container started successfully, listening on port 80.

### 5️⃣ ALB + ECS SERVICE

> #### KEEP existing ALB and upgrade it for ECS.

#### 1️⃣ Create NEW Target Groups (for ECS)

- 👉 Go to EC2 → Target Groups → Create Target Group.

#### 🔵 Blue Target Group

- Name: charlie-blue

- Target type: IP (IMPORTANT)

> ✅ (because Fargate tasks get their own ENI and private IP in the VPC, not EC2 instances).

- Protocol / Port: HTTP / 80.

- Health check: /health.php

> ✅ (or / if your container does not have a health endpoint yet).

- VPC: Select the VPC where your ECS cluster / tasks run.

- Leave other settings default → Create.

> ✅ Important: Do NOT select EC2 instances. For Fargate, the targets are IP addresses of tasks, not EC2 machines.

#### 🟢 Green Target Group

> ✅ Repeat the same steps for the green deployment:

- Name: charlie-green

- Target Type: IP

- Protocol: HTTP / 80

- Health check: /health.php

- VPC: same as ECS tasks

- Click Create.

> ✅ This is usually used for blue/green deployments, but even if you are just testing, it’s good practice to have separate TGs.

#### 2️⃣ Update ALB Listener

- Go to: EC2 → Load Balancer → Listeners

- Edit HTTP:80

#### 👉 Set default:

- Default action: Forward → charlie-blue

#### 3️⃣ Create ECS Service

- Go ECS → Cluster → charlie-cluster → Create Service

- Service Name: charlie-service

- Launch type: Fargate

- Number of tasks: 1 (start small)

- Load Balancer: Application Load Balancer

  > Use existing ALB

- Listener: HTTP:80

- Target group: charlie-blue

- Container Mapping: charlie-container port 80

  - Container: charlie-container

  - Port: 80

✅ Click Create Service → Wait for tasks to become Running

#### 4️⃣ Verify Target Group

- Go EC2 → Target Groups → charlie-blue → Targets

> You should see IP addresses (Fargate tasks) and Status: Healthy

#### You should see:

- IP addresses (NOT EC2)

- Status: Healthy

#### 🌐 Access App

- Go to your ALB DNS in browser

```
http://YOUR-ALB-DNS
```

✅ It should now serve your Dockerized app

### 4️⃣ GITHUB CI/CD (AUTO DEPLOY)

- ### 1️⃣ Add GitHub Secrets

#### ✅ REQUIRED SECRETS 

- Go to GitHub repo → Settings → Secrets and variables → Actions → Add the following secrets:

- Add each one manually:

| Secret Name             | Value Example   | Where to Get    |
| ----------------------- | --------------- | --------------- |
| `AWS_ACCESS_KEY_ID`     | AKIA...         | IAM User        |
| `AWS_SECRET_ACCESS_KEY` | xxxxx           | IAM User        |
| `AWS_REGION`            | us-east-1       | Your AWS region |
| `AWS_ACCOUNT_ID`        | 123456789012    | AWS Account     |
| `ECS_CLUSTER`           | charlie-cluster | ECS Console     |
| `ECS_SERVICE`           | charlie-service | ECS Console     |
| `ECR_REPO`              | charlie-cafe    | ECR Repo Name   |

- ECR Repository created (charlie-cafe)

- ECS Cluster and Service running

✅ Everything you mentioned is already done.

### 5️⃣ Commit & Push

- Save the updated deploy.yml in .github/workflows/

- Commit & push to main

- GitHub Actions will automatically trigger

- Check Actions tab → Logs for each step

✅ If all steps succeed, your ECS service will be automatically updated whenever you push to main.

### 6️⃣ Testing the ECS Deployment

- Go to ECS → Cluster → charlie-cluster → Tasks

- You should see new tasks running with the latest image

- Go to ALB → Target Groups → charlie-blue → Targets

- Status should be Healthy

- Open your ALB DNS in the browser to test the live app

#### 🔍 Open:

```
http://YOUR-ALB-DNS
```

---
## 🚀 Enterprise Zero-Downtime CI/CD Pipeline (ECS + CodeDeploy + Immutable Images)

### ✅ Prerequisites

- Application Load Balancer (ALB) is configured

- Two target groups created:

  - charlie-blue

  - charlie-green

- Health check endpoint configured: /health.php

- ALB Listener (HTTP:80) is set to forward traffic to charlie-blue

> #### 👉 “ALB with blue/green target groups is already configured, with traffic currently routed to charlie-blue and health checks on /health.php.”

### 📁 REQUIRED FILES (VERY IMPORTANT)

You need 2 files in repo:

### ✅ 1. appspec.yaml

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

### ✅ 2. .github/task-definition.json

```
{
  "family": "charlie-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "YOUR_ECS_TASK_EXECUTION_ROLE_ARN",
  "containerDefinitions": [
    {
      "name": "charlie-container",
      "image": "IMAGE_PLACEHOLDER",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ]
    }
  ]
}
```

### 1️⃣ — ECS SERVICE (CRITICAL)

- Go to ECS → Service

- Click Update

- Change:

  ❌ Rolling update

  ✅ Blue/Green (CodeDeploy)

### 2️⃣ — CREATE CODEDEPLOY APP

- Name: charlie-ecs-app

- Platform: ECS

### 3️⃣ — CREATE DEPLOYMENT GROUP

- Name: charlie-ecs-deployment-group

- Cluster: charlie-cluster

- Service: charlie-service

- Attach:

  - ALB

  - Blue TG

  - Green TG

  - Listener: HTTP:80

### 4️⃣ — ECS TASK EXECUTION ROLE

- Use:

```
ecsTaskExecutionRole
```

- Put ARN in:

```
task-definition.json
```

### 5️⃣ — PUSH CODE

```
git add .
git commit -m "final pipeline"
git push origin main
```

---
## ☁️ CHARLIE CAFE — PRODUCTION BLUE/GREEN CANARY DEPLOYMENT WITH AUTO ROLLBACK & MONITORING

### 1️⃣ — Enable Canary Deployment

In deployment group:

#### Deployment config:

```
CodeDeployDefault.ECSCanary10Percent5Minutes
```

### 2️⃣ — Enable Auto Rollback

#### Enable:

✔ Rollback on:

- Deployment failure

- Alarm trigger

### 3️⃣ — Create CloudWatch Alarm

#### Create alarm:

- Name: charlie-health-alarm

- Metric: UnHealthyHostCount

- Target Group: charlie-green

- Condition: >= 1

### 4️⃣ — Attach Alarm to CodeDeploy

In deployment group:

- Attach: charlie-health-alarm

### 🧭 STEP-BY-STEP UPGRADE

### 1️⃣ — UPDATE CODEDEPLOY (MOST IMPORTANT)

- Go to: 👉 AWS CodeDeploy → Deployment Group

#### 🔧 CHANGE THIS:

- ❌ Old config: CodeDeployDefault.ECSAllAtOnce

- ✅ NEW CONFIG (CANARY): CodeDeployDefault.ECSCanary10Percent5Minutes

### 2️⃣ — ENABLE AUTO ROLLBACK

Inside SAME deployment group:

#### Turn ON:

```
✔ Rollback when deployment fails
✔ Rollback when CloudWatch alarm triggers
```

### 3️⃣ — CREATE CLOUDWATCH ALARM

- Go to: 👉 CloudWatch → Alarms → Create Alarm

### 📊 ALARM 1 (CRITICAL)

- Name: charlie-green-unhealthy-alarm

- Metric: ApplicationELB → UnHealthyHostCount

- Target Group: charlie-green

- Condition: >= 1 for 1 minute

### 4️⃣ — ATTACH ALARM TO CODEDEPLOY

- Go to: 👉 CodeDeploy Deployment Group

- Add: charlie-green-unhealthy-alarm

### 5️⃣ GitHub → Auto-Deploy Setup (Charlie Cafe)

> #### Optional Task 

- Read more here [GitHub Auto-Deploy Config](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/Github%20Tasks%20Configurations/GitHub_Auto-Deploy_Config.md)

### ✅ TRIGGER deploy.yml (VERY IMPORTANT)

- You DO NOT run deploy.yml manually ❌

- GitHub Actions runs it automatically ✅

#### 🔹 METHOD 1 — Trigger via Push (RECOMMENDED)

Run this on your local machine or EC2:

```
cd ~/charlie-cafe-devops

git add .
git commit -m "🚀 trigger deployment"
git push origin main
```

#### 👉 This will:

- Trigger GitHub Actions

- Start your CI/CD pipeline automatically

#### 🔹 METHOD 2 — Manual Trigger (Optional)

If your workflow supports it:

- Go to GitHub repo

- Click Actions tab

- Select workflow

- Click Run workflow

### 6️⃣ — VERIFY ECS + ALB BEHAVIOR

After deployment:

You will see:

#### Phase 1:

- 10% users → GREEN

#### Phase 2:

CloudWatch monitors health

#### Phase 3:

If OK → 100% traffic to GREEN

#### Phase 4:

If FAIL → rollback to BLUE

### 7️⃣ Charlie Cafe cleanup

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

### 8️⃣ Charlie Cafe -- Github Logs

[Charlie Cafe -- Github Logs](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/Github%20Tasks%20Configurations/Charlie-cafe_github-logs.md)

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
---
