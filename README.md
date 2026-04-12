# ☕ Charlie Cafe DevOps Project

## ☕ Project Goal

### 🎯 Primary Goal

Build a scalable, secure, cloud-native café ordering system using modern DevOps practices.

### 🎯 Technical Goals

- Implement serverless backend (Lambda + API Gateway)

- Use event-driven architecture (SQS)

- Deploy containerized frontend (Docker → ECS)

- Build CI/CD pipeline (GitHub Actions)

- Ensure secure architecture (VPC + Secrets Manager + Cognito)

### 🎯 Business Goal

- Real-time order processing

- Secure employee/admin system

- Scalable system for future growth

## ☕ Architecture Data Flow Diagram

```
User (Browser / Mobile)
        ↓
CloudFront (CDN + HTTPS)
        ↓
Application Load Balancer (ALB)
        ↓
Frontend (EC2 / ECS Docker Container)
        ↓
API Gateway
        ↓
Lambda Functions
        ↓
-----------------------------------------
|           Backend Layer               |
|  → SQS (Order Queue)                 |
|  → DynamoDB (Menu / Orders / Metrics)|
|  → RDS MySQL (Relational Data)       |
|  → Secrets Manager (Credentials)     |
-----------------------------------------
        ↓
CloudWatch Logs & Monitoring
```

## ☕ AWS Official Architecture Diagram (Text Version)

Use this structure to draw in draw.io / Lucidchart / AWS Architecture Icons

```
[User]
   ↓
[CloudFront]
   ↓
[Application Load Balancer]
   ↓
[ECS / EC2 - Docker Container (Frontend)]
   ↓
[API Gateway]
   ↓
[Lambda Functions]
   ↓
 ┌───────────────────────────────┐
 | Backend Services              |
 |-------------------------------|
 | SQS (Order Queue)             |
 | DynamoDB (NoSQL Tables)       |
 | RDS (MySQL Database)          |
 | Secrets Manager               |
 └───────────────────────────────┘
   ↓
[CloudWatch]
```

### 💡 Pro Tip for Portfolio

- #### Use:

  - AWS official icons

- #### Color coding:

  🟦 Compute

  🟧 Storage

  🟪 Security

  🟩 Networking




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

### 1️⃣ IAM Role & Policies

- Create the following three IAM roles using the configurations defined in the [Charlie Cafe DevOps IAM Policy](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/AWS%20Services%20Configurations%20/AWS%20IAM%20Role%20&%20Policies/Charlie-Cafe_IAM_Roles_Config.md)

### 2️⃣ Network & Compute (Foundation)

#### 🔹 VPC Configuration

| Resource | Name         | CIDR Block    | Region      |
| -------- | ------------ | ------------- | ----------- |
| VPC      | `CafeDevVPC` | `10.0.0.0/16` | `us-east-1` |

#### 🔹 Public Subnet

| Resource      | Name                  | CIDR Block    | Auto Public IP |
| ------------- | --------------------- | ------------- | -------------- |
| Public Subnet | `CafeDevPublicSubnet` | `10.0.1.0/24` | Enabled        |

#### 🔹 Private Subnets

| Resource         | Name                    | CIDR Block    | Availability Zone |
| ---------------- | ----------------------- | ------------- | ----------------- |
| Private Subnet 1 | `CafeDevPrivateSubnet1` | `10.0.2.0/24` | AZ-a              |
| Private Subnet 2 | `CafeDevPrivateSubnet2` | `10.0.3.0/24` | AZ-b              |

#### 🔹 Internet Access Configuration

| Component        | Configuration                            |
| ---------------- | ---------------------------------------- |
| Internet Gateway | Create and attach to `CafeDevVPC`        |
| Route Table      | Add route `0.0.0.0/0 → Internet Gateway` |

#### 💡 Pro Tip

For production-ready setup, you should also include:

- Separate route tables for public and private subnets

- NAT Gateway for private subnet internet access

- Proper tagging (Environment = Dev, Project = CharlieCafe)

### 3️⃣ Security Groups (Quick View)

#### 🔹 Overview

| SG Name      | Purpose       | Attached To  | Inbound (Key)                    | Outbound  |
| ------------ | ------------- | ------------ | -------------------------------- | --------- |
| `default-sg` | General use   | EC2, RDS     | SSH, HTTP, HTTPS, MySQL, ALL TCP | Allow All |
| `rds-sg`     | DB protection | RDS          | MySQL (from Lambda + Default SG) | Allow All |
| `lambda-sg`  | Lambda access | Lambda (VPC) | HTTP/HTTPS, MySQL to RDS         | Allow All |

#### 🔹 Rules 

| SG Name    | Port   | Protocol | Source / Destination   | Purpose           |
| ---------- | ------ | -------- | ---------------------- | ----------------- |
| default-sg | 22     | TCP      | 0.0.0.0/0 (or your IP) | SSH access        |
| default-sg | 80     | TCP      | 0.0.0.0/0              | Web (HTTP)        |
| default-sg | 443    | TCP      | 0.0.0.0/0              | Web (HTTPS)       |
| default-sg | 3306   | TCP      | Open / restricted      | MySQL access      |
| rds-sg     | 3306   | TCP      | lambda-sg, default-sg  | DB access control |
| lambda-sg  | 3306   | TCP      | rds-sg                 | Connect to RDS    |
| lambda-sg  | 80/443 | TCP      | default-sg (optional)  | API testing       |

#### 🔹 NACL

| Component | Rule                             |
| --------- | -------------------------------- |
| NACL      | Allow all inbound/outbound (Dev) |

#### 💡 Important Notes 

🔒 RDS should NOT be public → only accessible via lambda-sg

⚡ Lambda needs outbound 3306 → RDS

🚫 Avoid 0.0.0.0/0 for MySQL in production

🧪 SSH/HTTP in Lambda SG = optional (debug only)

### 4️⃣ EC2 Configuration

| Parameter      | Value                   |
| -------------- | ----------------------- |
| Name           | `CafeDevWebServer`      |
| AMI            | Amazon Linux 2023       |
| Instance Type  | `t2.micro`              |
| VPC / Subnet   | Dev VPC / Public Subnet |
| Security Group | `default-sg`            |
| IAM Role       | `EC2-Cafe-Secrets-Role` |

#### 🌐 EC2 IAM ROle 

[EC2-Cafe-Secrets-Role](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/AWS%20Services%20Configurations%20/AWS%20IAM%20Role%20&%20Policies/Charlie%20Cafe%20IAm%20Policies/EC2-Cafe-Secrets-Role.json)

#### 🔹 EC2 User Data

| Item        | Details                          |
| ----------- | -------------------------------- |
| Script Name | `charlie-cafe-devops.sh`         |
| Purpose     | Install and configure LAMP stack |
| Location    | GitHub (User Data script)        |

#### 🌐 EC2 User Data Script

[charlie-cafe-devops.sh](./infrastructure/scripts/charlie-cafe-devops.sh)

### 5️⃣ EC2 Access & Setup

#### 🔹 Connect to EC2

| Step           | Command                                      |
| -------------- | -------------------------------------------- |
| Set Permission | `chmod 400 CafeDevKey.pem`                   |
| SSH Login      | `ssh -i CafeDevKey.pem ec2-user@<PUBLIC-IP>` |

#### 🔹 Verify User Data Execution

| Step            | Command                                            |
| --------------- | -------------------------------------------------- |
| Open Script     | `sudo nano charlie-cafe-full-devops-verify.sh`     |
| Make Executable | `sudo chmod +x charlie-cafe-full-devops-verify.sh` |
| Run Script      | `sudo ./charlie-cafe-full-devops-verify.sh`        |

#### 🌐 EC2 Verify Script

[charlie-cafe-full-devops-verify.sh](./infrastructure/scripts/charlie-cafe-full-devops-verify.sh)

#### 💡 Notes

- EC2 instance uses Amazon Linux 2023

- Prerequisite setup is automated using a User Data script

- The verification script ensures that the environment is properly configured and ready
---
## 3️⃣ VPC ENDPOINTS

### 1️⃣ VPC Interface Endpoints

#### 🔹 Secrets Manager Endpoint

| Parameter      | Value                                    |
| -------------- | ---------------------------------------- |
| Name           | `secretsmanager-INT-EP`                  |
| Service        | `com.amazonaws.us-east-1.secretsmanager` |
| Type           | Interface                                |
| VPC            | Your Dev VPC                             |
| Subnets        | Private subnets (Lambda same AZs)        |
| Security Group | Allow HTTPS (443) from Lambda SG         |
| Private DNS    | Enabled                                  |

#### 🔹 SQS Interface Endpoint

| Parameter      | Value                         |
| -------------- | ----------------------------- |
| Name           | `sqs-INT-EP`                  |
| Service        | `com.amazonaws.us-east-1.sqs` |
| Type           | Interface                     |
| VPC            | Same VPC                      |
| Subnets        | Private subnets               |
| Security Group | `Lambda-SG`                   |
| Private DNS    | Enabled                       |

#### 🔹 CloudWatch Logs Endpoint

| Parameter      | Value                          |
| -------------- | ------------------------------ |
| Name           | `cloudwatch-INT-EP`            |
| Service        | `com.amazonaws.us-east-1.logs` |
| Type           | Interface                      |
| VPC            | Same VPC                       |
| Subnets        | Private subnets                |
| Security Group | `Lambda-SG`                    |
| Private DNS    | Enabled                        |

#### 🔹 DynamoDB Gateway Endpoint

| Parameter    | Value                              |
| ------------ | ---------------------------------- |
| Name         | `dynamodb-GW-EP`                   |
| Service      | `com.amazonaws.us-east-1.dynamodb` |
| Type         | Gateway                            |
| VPC          | Same VPC                           |
| Route Tables | All private route tables           |
| Purpose      | Enable private DynamoDB access     |

### 🐳 2️⃣ ECR Interface VPC Endpoints

#### 🔹 Purpose: 

Allow ECS/Lambda to pull Docker images from ECR without internet or NAT Gateway.

#### 🔹 ECR API Endpoint

| Parameter      | Value                                  |
| -------------- | -------------------------------------- |
| Name           | `ecr-api-endpoint`                     |
| Service        | `com.amazonaws.us-east-1.ecr.api`      |
| Type           | Interface                              |
| Purpose        | ECS → ECR API communication            |
| Subnets        | Private subnets (same as ECS tasks)    |
| Security Group | Allow outbound HTTPS (443) from ECS SG |
| Private DNS    | Enabled                                |

#### 🔹 ECR Docker Registry Endpoint

| Parameter      | Value                               |
| -------------- | ----------------------------------- |
| Name           | `ecr-dkr-endpoint`                  |
| Service        | `com.amazonaws.us-east-1.ecr.dkr`   |
| Type           | Interface                           |
| Purpose        | Docker image pull (registry access) |
| Subnets        | Private ECS subnets                 |
| Security Group | ECS SG allowed outbound HTTPS (443) |
| Private DNS    | Enabled                             |

### 3️⃣ S3 Gateway Endpoint (Required for ECR)

#### 🔹 Purpose

ECR stores image layers in S3 → required for image downloads.

| Parameter    | Value                        |
| ------------ | ---------------------------- |
| Name         | `s3-ecr-gateway-endpoint`    |
| Service      | `com.amazonaws.us-east-1.s3` |
| Type         | Gateway                      |
| Purpose      | ECR image layers retrieval   |
| Route Tables | Private subnet route tables  |
| Destination  | S3 Prefix List               |

#### 🔄 Architecture Flow

```
Lambda (Private Subnet)
   ↓
VPC Endpoints
   ↓
AWS Services (SQS / Secrets / Logs / DynamoDB)
```

```
GitHub Actions
   ↓
ECR (Docker Images)
   ↓
VPC Endpoints (ECR API + ECR DKR + S3)
   ↓
ECS Tasks (Private Subnets)
   ↓
ALB (Public Access Layer)
   ↓
CloudFront (CDN Layer)
   ↓
Frontend Users
```

#### 💡 Key Architecture

🔒 Fully private ECS deployment

🚫 No NAT Gateway required

⚡ Faster image pulls from ECR

🛡 Secure backend communication

💰 Lower AWS cost

🏗 Production-grade DevOps setup

#### 🧠 Combined VPC Endpoint Strategy

| Category           | Endpoints            |
| ------------------ | -------------------- |
| Security & Secrets | Secrets Manager, SSM |
| Messaging          | SQS                  |
| Logging            | CloudWatch Logs      |
| Database           | DynamoDB Gateway     |
| Container System   | ECR API, ECR DKR     |
| Storage            | S3 Gateway           |


#### ⚙️ Endpoint Strategy Summary

| Service         | Type      | Purpose                   |
| --------------- | --------- | ------------------------- |
| Secrets Manager | Interface | Secure credentials access |
| SQS             | Interface | Messaging system          |
| CloudWatch Logs | Interface | Logging Lambda output     |
| DynamoDB        | Gateway   | Private DB access         |

#### ⚙️ ECS VPC Access Summary

| Component     | Requirement             |
| ------------- | ----------------------- |
| ECS Tasks     | Run in Private Subnets  |
| ECR Access    | Via Interface Endpoints |
| Image Storage | S3 Gateway Endpoint     |
| Internet/NAT  | ❌ Not required          |

#### 🔐 Security Rules

| Component     | Rule                            |
| ------------- | ------------------------------- |
| ECS SG        | Outbound HTTPS (443) allowed    |
| Endpoint SG   | Inbound HTTPS (443) from ECS SG |
| Public Access | ❌ Not required                  |
| NAT Gateway   | ❌ Not needed                    |

### 💡 Important Rules

- Always use VPC endpoints for private Lambda

- Never expose RDS directly (0.0.0.0/0 is forbidden)

- Enable Private DNS for interface endpoints

- DynamoDB must use Gateway endpoint

- Lambda must run inside private subnets

- Enables fully private container deployment

- Improves security (no internet exposure)

- Reduces cost (no NAT Gateway required)

- Required for production-grade ECS architecture

- Works with CI/CD pipelines (GitHub Actions → ECR → ECS)

### 🚨 Common Failure Points

| Issue                    | Cause                     |
| ------------------------ | ------------------------- |
| Lambda cannot access SQS | Missing SQS endpoint      |
| Secrets Manager timeout  | No interface endpoint     |
| RDS connection failed    | Wrong SG (0.0.0.0/0 used) |
| CloudWatch logs missing  | Missing logs endpoint     |
---
## 4️⃣ NAT Gateway (OPTIONAL INTERNET ACCESS FOR ECS)

### 1️⃣ NAT Gateway Architecture

| Component        | Purpose                                        |
| ---------------- | ---------------------------------------------- |
| NAT Gateway      | Provides internet access for private ECS tasks |
| Internet Gateway | Public subnet outbound connectivity            |
| Private Subnet   | ECS tasks run here (no public IP)              |
| Route Table      | Routes internet traffic via NAT Gateway        |

### 2️⃣ NAT Gateway Setup

| Parameter       | Value                |
| --------------- | -------------------- |
| Name            | `ecs-nat-gateway`    |
| Placement       | Public Subnet        |
| Elastic IP      | Required             |
| Internet Access | Via Internet Gateway |

### 3️⃣ Route Table Configuration (Critical)

#### 🔹 Private Subnet Route Table

| Destination | Target      |
| ----------- | ----------- |
| `0.0.0.0/0` | NAT Gateway |

### 4️⃣ ECS Task Networking

| Setting         | Value                      |
| --------------- | -------------------------- |
| Subnet Type     | Private Subnet             |
| Public IP       | ❌ Disabled                 |
| Outbound Access | Via NAT Gateway            |
| Security Group  | Allow HTTPS (443) outbound |

###  5️⃣ Security Group Rules

| Type                   | Protocol | Port | Destination                 |
| ---------------------- | -------- | ---- | --------------------------- |
| HTTPS                  | TCP      | 443  | `0.0.0.0/0`                 |
| (Optional Restriction) | TCP      | 443  | ECR CIDR (`52.95.255.0/24`) |

### 💡 NAT Gateway Benefits vs Limitations

| Pros                      | Cons                                 |
| ------------------------- | ------------------------------------ |
| Easy setup                | High cost (hourly + data transfer)   |
| Works immediately         | Not fully private architecture       |
| No VPC endpoints required | Not recommended for production scale |

### 🔄 Use Case Flow (NAT Based ECS)

```
ECS Task (Private Subnet)
   ↓
Route Table
   ↓
NAT Gateway (Public Subnet)
   ↓
Internet Gateway
   ↓
ECR / AWS Services
```

### ⚖️ NAT Gateway vs VPC Endpoints

| Feature           | NAT Gateway | VPC Endpoints |
| ----------------- | ----------- | ------------- |
| Cost              | ❌ High      | ✔ Low         |
| Security          | Medium      | High          |
| Performance       | Good        | Better        |
| Production Use    | Optional    | Recommended   |
| Internet Required | Yes         | No            |

### 🧠  DevOps Recommendation

- Use NAT Gateway only for quick setup/testing

- Use VPC Endpoints for production (best practice)

- Prefer private architecture (no internet dependency)

- Combine with ECR + ECS endpoints for full security

### 🚀 Final ECS Internet Access Flow

```
ECS Task (Private Subnet)
   ↓
Route Table (0.0.0.0/0)
   ↓
NAT Gateway
   ↓
Internet Gateway
   ↓
ECR / AWS Services / Internet
```
---
## 5️⃣ Cafe Database Configuration

### 1️⃣ — RDS Core Setup

#### 🔹 Infrastructure Setup

| Step | Component          | Configuration                                                                                                                                                     |
| ---- | ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1️⃣  | DB Subnet Group    | Name: `CafeRDSSubnetGroup`<br>VPC: `CafeDevVPC`<br>Subnets: Private Subnets (2 AZs)                                                                               |
| 2️⃣  | RDS Security Group | Name: `CafeRDS-SG`<br>Inbound: MySQL (3306) from `Lambda-SG`, `EC2-Web-SG`<br>Outbound: All traffic                                                               |
| 3️⃣  | RDS Instance       | Engine: MySQL/MariaDB<br>DB Name: `cafedb`<br>Username: `cafe_user`<br>Password: `StrongPassword123`<br>Public Access: ❌ Disabled<br>Security Group: `CafeRDS-SG` |
---
### 2️⃣ — AWS Secrets Manager

#### 🔹 Store Database Credentials

| Item        | Value                            |
| ----------- | -------------------------------- |
| Secret Name | `CafeDevDBSM`                    |
| Secret Type | Key/Value (Other type of secret) |
| Username    | `cafe_user`                      |
| Password    | `StrongPassword123`              |
| Host        | RDS Endpoint                     |
| DB Name     | `cafe_db`                        |

#### 🔹 Secret JSON Format

```
{
  "username": "cafe_user",
  "password": "StrongPassword123",
  "host": "your-rds-endpoint.amazonaws.com",
  "dbname": "cafe_db"
}
```

#### 🔹 Example (Real Format)

```
{
  "username": "cafe_user",
  "password": "StrongPassword123",
  "host": "cafedb.abc123xyz.us-east-1.rds.amazonaws.com",
  "dbname": "cafe_db"
}
```

#### 🔹 Secret ARN

| Item       | Value                                                                    |
| ---------- | ------------------------------------------------------------------------ |
| Secret ARN | `arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeDevDBSM-xxxxx` |
---
### 3️⃣ Run RDS Bash Script 

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

#### 💡 Important Notes

- RDS is NOT public (secure private DB)

- Only Lambda / EC2 with proper SG can access MySQL (3306)

- Secret ARN is used inside Lambda / backend code

- Credentials are never hardcoded in application

---
### 4️⃣ DynamoDB Setup

### 1️⃣ Create DynamoDB CafeMenu Table 

#### 🔹 Table Configuration

| Parameter     | Value          |
| ------------- | -------------- |
| Table Name    | `CafeMenu`     |
| Partition Key | `item`         |
| Key Type      | String         |
| Sort Key      | ❌ Not required |

#### 🔹 Capacity Settings

| Setting       | Value     |
| ------------- | --------- |
| Capacity Mode | On-Demand |

#### 💡 Why On-Demand?

| Reason               | Benefit               |
| -------------------- | --------------------- |
| No planning required | Auto scaling          |
| Cost efficient       | Free-tier friendly    |
| Ideal use case       | Learning + small apps |

#### 🔹 Default Settings (Keep As-Is)

| Setting             | Value           |
| ------------------- | --------------- |
| Encryption          | AWS Owned Key   |
| Table Class         | Standard        |
| Deletion Protection | Disabled        |
| Tags                | Optional (skip) |

#### 🔹 Table Status

| Step         | Status         |
| ------------ | -------------- |
| Create Table | Click “Create” |
| Wait Status  | `ACTIVE`       |

### 🍽️ 2️⃣ Insert Menu Items (Cafe Data)

#### 🔹 Item Structure

| Attribute | Type   |
| --------- | ------ |
| item      | String |
| price     | Number |

#### ☕ Menu Items

| Item        | JSON Format                         |
| ----------- | ----------------------------------- |
| Coffee      | `"item": "Coffee", "price": 3`      |
| Latte       | `"item": "Latte", "price": 5`       |
| Tea         | `"item": "Tea", "price": 2`         |
| Cappuccino  | `"item": "Cappuccino", "price": 8`  |
| Fresh Juice | `"item": "Fresh Juice", "price": 6` |

#### 🧾 3️⃣ JSON Item Examples

#### ☕ Coffee

You will see a JSON editor.

Replace everything with:

```
{
  "item": {
    "S": "Coffee"
  },
  "price": {
    "N": "3"
  }
}
```

- ✅ Click Create item

#### 🥛 Latte

Click Create item again:

```
{
  "item": {
    "S": "Latte"
  },
  "price": {
    "N": "5"
  }
}
```

- ✅ Click Create item

#### 🍵 Tea

Click Create item again:

```
{
  "item": {
    "S": "Tea"
  },
  "price": {
    "N": "2"
  }
}
```

- ✅ Click Create item

---

#### ☕ Cappuccino

```
{
  "item": {
    "S": "Cappuccino"
  },
  "price": {
    "N": "8"
  }
}
```

- ✅ Click Create item

---

#### 🍹 Fresh Juice

```
{
  "item": {
    "S": "Fresh Juice"
  },
  "price": {
    "N": "6"
  }
}
```

- ✅ Click Create item

#### 🔄 Data Flow

```
DynamoDB Table (CafeMenu)
   ↓
API Gateway / Lambda
   ↓
Frontend (Cafe Website)
```

### 💡 Notes

- DynamoDB uses NoSQL key-value structure

- item is the primary identifier

- On-demand mode = auto scaling

- Perfect for menu / product catalog

- No need for relational schema

### 🚀 Final Summary

| Component     | Value        |
| ------------- | ------------ |
| Database Type | DynamoDB     |
| Table Name    | CafeMenu     |
| Primary Key   | item         |
| Mode          | On-Demand    |
| Use Case      | Menu Storage |

### 2️⃣ Create DynamoDB METRICS TABLE

### 1️⃣ Create DynamoDB Table

| Parameter     | Value                 |
| ------------- | --------------------- |
| Table Name    | `CafeOrderMetrics`    |
| Partition Key | `metric`              |
| Key Type      | String                |
| Sort Key      | ❌ None                |
| Table Class   | Standard              |
| Capacity Mode | On-Demand             |
| Encryption    | Default (AWS managed) |

#### 🔹 Table Status

| Step         | Status         |
| ------------ | -------------- |
| Create Table | Click “Create” |
| Wait Status  | `ACTIVE`       |

#### 🔹 Metrics Table Data Structure

| Attribute | Type   | Purpose           |
| --------- | ------ | ----------------- |
| metric    | String | Metric identifier |
| count     | Number | Metric value      |

#### 🔹 Initial Metrics Items

| Metric Name  | Meaning                | Initial Value |
| ------------ | ---------------------- | ------------- |
| TOTAL_ORDERS | Total orders in system | 0             |
| TODAY_ORDERS | Orders for current day | 0             |

### 🧾 2️⃣ Insert Items (JSON Format)

**Click table → Explore table → Create item**

#### 🔹 TOTAL_ORDERS

```
{
  "metric": { "S": "TOTAL_ORDERS" },
  "count": { "N": "0" }
}
```

#### 🔹 TODAY_ORDERS

```
{
  "metric": { "S": "TODAY_ORDERS" },
  "count": { "N": "0" }
}
```

### 🔄 Metrics Data Flow

```
Order Placement (SQS/Lambda)
   ↓
Update Metrics Lambda
   ↓
DynamoDB (CafeOrderMetrics)
   ↓
Frontend Dashboard
```

### 💡 Notes

- Designed for real-time dashboard metrics

- Uses simple key-value structure

- Optimized for fast reads/writes

- Works with Lambda update triggers

- No relational complexity required

### 🚀 Final Summary

| Component   | Value               |
| ----------- | ------------------- |
| Table Name  | CafeOrderMetrics    |
| Type        | NoSQL Metrics Store |
| Primary Key | metric              |
| Mode        | On-Demand           |
| Use Case    | Dashboard analytics |

### 3️⃣ Create DynamoDB CafeOrders TABLE

### 1️⃣ Create Table Configuration

| Field         | Value                 |
| ------------- | --------------------- |
| Table Name    | `CafeOrders`          |
| Partition Key | `order_id`            |
| Key Type      | String                |
| Sort Key      | ❌ None                |
| Table Class   | Standard              |
| Capacity Mode | On-Demand             |
| Encryption    | Default (AWS Managed) |

#### 🔹 Table Creation Status

| Step         | Status         |
| ------------ | -------------- |
| Create Table | Click “Create” |
| Wait Time    | 1–2 minutes    |
| Final Status | `ACTIVE`       |

#### 🔑 Primary Key Verification

| Parameter     | Value      |
| ------------- | ---------- |
| Partition Key | `order_id` |
| Type          | String     |

⚠️ If not correct → STOP setup (critical dependency for system)

### 3️⃣ Order Item Structure

| Attribute      | Type   | Description           |
| -------------- | ------ | --------------------- |
| order_id       | String | Unique order ID       |
| table_number   | Number | Customer table number |
| item           | String | Menu item             |
| quantity       | Number | Quantity ordered      |
| total_amount   | Number | Total price           |
| payment_method | String | CASH / CARD           |
| payment_status | String | PENDING / PAID        |
| status         | String | Order state           |
| created_at     | String | Timestamp             |

### 4️⃣ Test Items

#### 🔹 Test Order 1 (CASH – PENDING)

```
{
  "order_id": { "S": "ORD-TEST-001" },
  "table_number": { "N": "5" },
  "item": { "S": "Coffee" },
  "quantity": { "N": "2" },
  "total_amount": { "N": "6" },
  "payment_method": { "S": "CASH" },
  "payment_status": { "S": "PENDING" },
  "status": { "S": "RECEIVED" },
  "created_at": { "S": "2026-01-14T10:30:00Z" }
}
```

#### 🔹 Test Order 2 (CARD – PENDING)

```
{
  "order_id": { "S": "ORD-TEST-002" },
  "table_number": { "N": "5" },
  "item": { "S": "Coffee" },
  "quantity": { "N": "2" },
  "total_amount": { "N": "6" },
  "payment_method": { "S": "CARD" },
  "payment_status": { "S": "PENDING" },
  "status": { "S": "RECEIVED" },
  "created_at": { "S": "2026-01-14T10:30:00Z" }
}
```

#### 🔎 Verification Checklist

| Check           | Expected Result |
| --------------- | --------------- |
| Item visible    | Yes             |
| payment_method  | CASH / CARD     |
| payment_status  | PENDING         |
| order_id unique | Yes             |

#### 🔄 Data Flow

```
Frontend Order → Lambda → SQS → Worker Lambda → DynamoDB (CafeOrders)
```

### 💡 DevOps Notes

- order_id is the primary system identifier

- DynamoDB auto-creates attributes (No schema required)

- Designed for event-driven architecture

- Works with SQS + Lambda pipeline

- Supports real-time order tracking system

### 🚀 Final Summary

| Component   | Value                   |
| ----------- | ----------------------- |
| Table Name  | CafeOrders              |
| Type        | NoSQL Orders Store      |
| Primary Key | order_id                |
| Mode        | On-Demand               |
| Use Case    | Order Management System |

### 4️⃣ Create DynamoDB CafeMenu TABLE (ITEM COST TABLE SETUP)

### 1️⃣ Create Table Configuration

#### 🔹 Basic Setup

| Field         | Value       |
| ------------- | ----------- |
| Table Name    | `CafeMenu`  |
| Partition Key | `item_name` |
| Key Type      | String (PK) |
| Sort Key      | ❌ None      |

#### 🔹 Table Settings

| Setting       | Value                 |
| ------------- | --------------------- |
| Table Class   | Standard              |
| Capacity Mode | On-Demand             |
| Encryption    | Default (AWS Managed) |
| Tags          | Optional (Skip)       |

#### ⚠️ Important Rules

| Rule          | Status                      |
| ------------- | --------------------------- |
| Sort Key      | ❌ Not allowed               |
| Key Name      | Must be `item_name` exactly |
| Capacity Mode | Must be On-Demand           |

#### 🔹 Sample Data Structure

| Attribute | Type   | Purpose         |
| --------- | ------ | --------------- |
| item_name | String | Menu item name  |
| base_cost | Number | Item base price |

#### 🔹 Insert Menu Items (Test Data)

#### 🔹 Latte

| Field     | Value |
| --------- | ----- |
| item_name | Latte |
| base_cost | 1.5   |

#### 🔹 ADD MORE ITEMS (RECOMMENDED)

**♻️ Repeat Create item for:**

2. **Cappuccino:**

```
item_name = Cappuccino
base_cost = 1.8
```

3. **Tea:**

```
item_name = Tea
base_cost = 0.6
```

4. **Coffee:**

```
item_name = Juice
base_cost = 1.2
```

5. **Juice**

```
item_name = Juice
base_cost = 1.2
```

#### 🔹 Data Flow

```
DynamoDB (CafeMenu)
   ↓
Lambda (Price Fetch)
   ↓
Order Calculation Service
   ↓
Frontend Display
```

### 💡 Notes

- CafeMenu stores price reference data

- Used for order calculation logic

- On-demand mode = auto scaling

- No schema required (NoSQL flexibility)

- Must have at least 2–3 items for testing

### 🚀 Final Summary

| Component  | Value                 |
| ---------- | --------------------- |
| Table Name | CafeMenu              |
| Key        | item_name             |
| Type       | NoSQL Pricing Table   |
| Mode       | On-Demand             |
| Use Case   | Menu Price Management |

### 5️⃣ Create DynamoDB CafeAttendance TABLE

### 1️⃣ Create Table Configuration

#### 🔹 Basic Setup

| Field              | Value                      |
| ------------------ | -------------------------- |
| Table Name         | `CafeAttendance`           |
| Partition Key      | `employee_id`              |
| Partition Key Type | String                     |
| Sort Key           | `date`                     |
| Sort Key Type      | String (YYYY-MM-DD format) |

#### 🔹 Table Design Purpose

| Feature            | Description                                     |
| ------------------ | ----------------------------------------------- |
| One record per day | Each employee has one attendance entry per date |
| Query pattern      | employee-wise + date-wise lookup                |
| Use case           | HR attendance tracking system                   |

#### 🔹 Table Settings

| Setting       | Value                   |
| ------------- | ----------------------- |
| Capacity Mode | On-Demand               |
| Table Class   | Standard                |
| Encryption    | AWS Owned Key (Default) |
| Tags          | Optional (Skip)         |

#### 🔹 Important Rules

| Rule                                 | Status                                |
| ------------------------------------ | ------------------------------------- |
| Add attributes manually              | ❌ Not allowed                         |
| Define check_in/check_out in console | ❌ Not required                        |
| DynamoDB schema                      | Schema-less (auto attribute creation) |

#### 🔹 Attendance Item Structure (Inserted via Lambda)

| Attribute   | Type   | Description                  |
| ----------- | ------ | ---------------------------- |
| employee_id | String | Employee unique ID           |
| date        | String | Attendance date (YYYY-MM-DD) |
| check_in    | String | Check-in time                |
| check_out   | String | Check-out time               |
| role        | String | Employee role                |

#### 🔹 Example Item (DynamoDB JSON Format)

```
{
  "employee_id": { "S": "101" },
  "date": { "S": "2026-02-01" },
  "check_in": { "S": "09:03" },
  "check_out": { "S": "17:11" },
  "role": { "S": "Employee" }
}
```

#### 🔹 Example Item (Lambda boto3 Format)

```
dynamo_table.put_item(
    Item={
        "employee_id": "101",
        "date": "2026-02-01",
        "check_in": "09:03",
        "check_out": "17:11",
        "role": "Employee"
    }
)
```

### 🔥 Key Design Notes

| Concept       | Explanation                             |
| ------------- | --------------------------------------- |
| Partition Key | employee_id groups data per employee    |
| Sort Key      | date ensures daily tracking             |
| Schema        | Fully dynamic (NoSQL)                   |
| Best Practice | Use Lambda for inserts                  |
| Data Format   | No manual attribute definition required |

### 🚀 Final Summary

| Component   | Value                   |
| ----------- | ----------------------- |
| Table Name  | CafeAttendance          |
| Primary Key | employee_id             |
| Sort Key    | date                    |
| Type        | NoSQL Attendance System |
| Mode        | On-Demand               |
| Use Case    | HR Tracking System      |

---
## 6️⃣ ALB & CloudFront Configuration

### ⚖️ 1️⃣ Application Load Balancer (ALB)

#### 🔹 Core Configuration

| Parameter      | Value                              |
| -------------- | ---------------------------------- |
| Name           | `charlie-cafe-alb`                 |
| Scheme         | Internet-facing                    |
| IP Type        | IPv4                               |
| VPC            | `CafeDevVPC`                       |
| Subnets        | 2+ Public Subnets (multi-AZ)       |
| Security Group | Allow HTTPS (443) from `0.0.0.0/0` |

#### 🔹 Target Group (EC2 Backend)

| Parameter    | Value                               |
| ------------ | ----------------------------------- |
| Type         | Instance                            |
| Protocol     | HTTP                                |
| Port         | 80                                  |
| Target       | EC2 Instance (`CafeDevWebServer`)   |
| Health Check | `/` or `/cafe-admin-dashboard.html` |

#### 🔹 Listeners (HTTP → HTTPS Setup - Optional)

| Listener   | Action                  |
| ---------- | ----------------------- |
| HTTP :80   | Redirect → HTTPS :443   |
| HTTPS :443 | Forward to Target Group |

#### 🔹 SSL Certificate (ACM - Optional)

| Parameter  | Value                         |
| ---------- | ----------------------------- |
| Source     | AWS Certificate Manager (ACM) |
| Type       | Public SSL Certificate        |
| Validation | DNS (recommended)             |
| Domain     | Your domain / wildcard        |

#### 🔹 ALB Output

| Item    | Value                                                         |
| ------- | ------------------------------------------------------------- |
| ALB DNS | `http(s)://charlie-cafe-alb-xxxx.us-east-1.elb.amazonaws.com` |

### ☁️ 2️⃣ CloudFront Configuration

#### 🔹 Origin (ALB Backend)

| Parameter       | Value                                               |
| --------------- | --------------------------------------------------- |
| Origin Type     | Application Load Balancer                           |
| Origin Domain   | ALB DNS (`charlie-cafe-alb-xxxx.elb.amazonaws.com`) |
| Origin Protocol | HTTP only                                           |
| Port            | 80                                                  |

#### 🔹 Default Cache Behavior

| Setting                | Value                                        |
| ---------------------- | -------------------------------------------- |
| Viewer Protocol Policy | Redirect HTTP → HTTPS                        |
| Allowed Methods        | GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE |
| Cache Policy           | CachingDisabled                              |
| Origin Request Policy  | AllViewer                                    |

#### 🔹 Key Purpose

| Feature           | Purpose                      |
| ----------------- | ---------------------------- |
| Forward Headers   | Auth (Cognito tokens)        |
| Disable Cache     | Prevent login/session issues |
| Full HTTP Methods | Support APIs + forms         |

#### 🔹 General Settings

| Parameter           | Value                       |
| ------------------- | --------------------------- |
| IPv6                | Disabled (lab setup)        |
| Default Root Object | `cafe-admin-dashboard.html` |
| Origin Path         | Empty                       |

#### 🔹 Routing Flow

```
CloudFront → ALB → EC2 → Apache → Web App
```

#### 🔹 CloudFront Domain

| Item | Value                  |
| ---- | ---------------------- |
| URL  | `xxxxx.cloudfront.net` |

### 🔄 3️⃣ CloudFront Invalidations

#### 🔹 Common Paths

| Type           | Path                         |
| -------------- | ---------------------------- |
| HTML           | `/cafe-admin-dashboard.html` |
| Full JS Folder | `/js/*`                      |
| Entire Cache   | `/*`                         |

#### 🔹 Best Practice (Recommended)

| Method            | Recommendation               |
| ----------------- | ---------------------------- |
| Versioning        | `app.v2.js` or `?v=2`        |
| Cache Bypass      | Avoid frequent invalidations |
| Full Invalidation | Use only when required       |

### ✅ BEST PRACTICE (Better Than Invalidation)

Instead of invalidating every time, use versioning:

```
/js/config.v2.js
/js/central-auth.v2.js
/js/utils.v2.js
/js/api.v2.js
/js/central-printing.v2.js
/var/www/html/js/role-guard.v2.js
```

#### Or:

```
<script src="/js/config.js?v=2"></script>
<script src="/js/central-auth.js?v=2"></script>
<script src="/js/utils.js?v=2"></script>
<script src="/js/app.js?v=2"></script>
<script src="/js/central-printing.js?v=2"></script>
<script src="/js/role-guard.js?v=2"></script>
```

### 🔐 4️⃣ Cognito Integration

| Parameter            | Value                          |
| -------------------- | ------------------------------ |
| Hosted UI Return URL | `https://xxxxx.cloudfront.net` |
| Login Flow           | ALB → CloudFront → EC2         |
| Requirement          | HTTPS mandatory                |

#### 💡 Key Notes

- ALB handles traffic routing + SSL termination

- CloudFront handles global caching + HTTPS enforcement

- Always use HTTPS (required for Cognito)

- Avoid caching API/auth responses

- Use versioning instead of frequent invalidations
---
## 7️⃣ AWS Cognito Authentication Configuration

### 🔐 1️⃣ Cognito User Pool (Core Setup)

| Parameter           | Value                            |
| ------------------- | -------------------------------- |
| User Pool Name      | `CharlieCafeAdminSPA`            |
| Application Type    | Single Page Application (SPA)    |
| Sign-in Method      | Username only                    |
| Example Users       | `admin`, `manager1`, `employee1` |
| Self Registration   | ❌ Disabled                       |
| Required Attributes | `email` only                     |

### 🔐 2️⃣ Security Configuration

| Setting          | Value                |
| ---------------- | -------------------- |
| Password Policy  | Default              |
| MFA              | ❌ Disabled (Dev/Lab) |
| Account Recovery | Email only           |
| SMS Recovery     | ❌ Disabled           |

### 🔐 3️⃣ App Client Configuration

| Parameter        | Value                        |
| ---------------- | ---------------------------- |
| Client Type      | Public Client (NO secret)    |
| App Client Name  | `CharlieCafeAdminSPA`        |
| OAuth Flow       | Authorization Code Grant     |
| Implicit Flow    | ❌ Disabled                   |
| Supported Scopes | `openid`, `email`, `profile` |

### 🔐 4️⃣ Authentication Flows

| Flow               | Status     |
| ------------------ | ---------- |
| USER_PASSWORD_AUTH | Enabled    |
| USER_SRP_AUTH      | Enabled    |
| REFRESH_TOKEN_AUTH | Enabled    |
| Others             | ❌ Disabled |

### 👥 5️⃣ User Groups (RBAC)

| Group    | Precedence | Purpose              |
| -------- | ---------- | -------------------- |
| Admin    | 1          | Full system access   |
| Manager  | 5          | Management dashboard |
| Employee | 10         | Employee portal      |

### 👤 6️⃣ User Management

| Username  | Group    | Example Password |
| --------- | -------- | ---------------- |
| cafeadmin | Admin    | `^MyH%H!A4YjD`   |
| manager1  | Manager  | `jfZvm@^3gTVE`   |
| ali       | Employee | `*KEXO^C3mjm3`   |

### 🧩 7️⃣ Custom Attributes (Employee Mapping)

| Attribute | Value                                   |
| --------- | --------------------------------------- |
| Name      | `custom:employee_id`                    |
| Type      | String                                  |
| Mutable   | Yes                                     |
| Purpose   | Link Cognito user → RDS employee record |

### 🔐 8️⃣ App Client Attribute Access

| Setting          | Value                |
| ---------------- | -------------------- |
| Read Permission  | `custom:employee_id` |
| Write Permission | `custom:employee_id` |
| Token Inclusion  | Included in JWT      |

### 🌍 9️⃣ Cognito Hosted UI

| Parameter     | Value                                                |
| ------------- | ---------------------------------------------------- |
| Domain Prefix | `charlie-cafe-auth`                                  |
| Full Domain   | `charlie-cafe-auth.auth.us-east-1.amazoncognito.com` |
| Type          | Hosted UI (OAuth2)                                   |

### 🔁 1️⃣0️⃣ OAuth Configuration

| Setting       | Value                    |
| ------------- | ------------------------ |
| Grant Type    | Authorization Code Grant |
| Implicit Flow | ❌ Disabled               |
| Scope         | openid + email + profile |

### 🔗 1️⃣1️⃣ Callback & Logout URLs

| Type          | URL                                                                     |
| ------------- | ----------------------------------------------------------------------- |
| Callback URLs | CloudFront routes (dashboard, login, order, analytics, employee portal) |
| Logout URL    | `https://YOUR_CLOUDFRONT/logout.php?loggedout=true`                     |

#### 🔗 Construct the LOGIN URL

Open browser and paste (replace values):

```
https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://yourdomain.com/login.html
```

#### 📌 Example:

```
https://charlie-cafe.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://yourdomain.com/login.html
```

- 👉 Press Enter

#### 🌐 Cognito Access Auth Code

```
https://yourdomain.com/login.html?code=ebec6a0a-54e8-49c0-a093-d68150c182b1
```

#### 🔗 Login Screen Appears

- Enter username & password

- Click Sign in

If login is successful → browser redirects to:

```
https://yourdomain.com/login.html?code=AUTH_CODE
```

Access token will only appear after your frontend exchanges the code via:

```
POST https://YOUR_DOMAIN/oauth2/token
```

### 🔐 1️⃣2️⃣ Authentication Flow Summary

| Component  | Role                        |
| ---------- | --------------------------- |
| Cognito    | Authentication + JWT tokens |
| CloudFront | Frontend hosting            |
| ALB        | Backend routing             |
| Lambda/API | Business logic              |
| RDS        | Employee + order data       |

### 🧠 1️⃣3️⃣ Token Structure (Important)

| Token Type    | Contains           |
| ------------- | ------------------ |
| ID Token      | User info + groups |
| Access Token  | API authorization  |
| Refresh Token | Session renewal    |

### 🔄 1️⃣4️⃣ Login Flow (Architecture)

```
CloudFront → Cognito Hosted UI → JWT Token → Frontend → API Gateway/Lambda → RDS
```

### 🧩 1️⃣5️⃣ Employee ID Mapping (Critical Design)

| Component         | Value                        |
| ----------------- | ---------------------------- |
| Cognito Attribute | `custom:employee_id`         |
| Purpose           | Match RDS employee table     |
| Flow              | Cognito → JWT → Lambda → RDS |

### ⚠️ 1️⃣6️⃣ Key Security Rules

| Rule                   | Status        |
| ---------------------- | ------------- |
| Self registration      | ❌ Disabled    |
| Public admin creation  | ❌ Not allowed |
| Implicit flow          | ❌ Disabled    |
| Password auth exposure | ❌ Restricted  |
| Groups-based access    | ✔ Enabled     |

### 💡 1️⃣7️⃣ Best Practices

- Use Authorization Code Flow (modern standard)

- Always enforce group-based access control

- Store no secrets in frontend

- Use custom attributes for DB mapping

- Never use implicit OAuth flow

- Always validate JWT in backend

### 🚀 Final Summary

| Layer            | Service            |
| ---------------- | ------------------ |
| Identity         | Cognito            |
| UI Auth          | Hosted UI          |
| Token            | JWT                |
| Role Control     | Cognito Groups     |
| Backend Security | Lambda/API Gateway |
| Data Layer       | RDS                |
---
## 8️⃣ ☕ Employee ID System (Cognito ↔ RDS Integration)

### 🔄 Flow Diagram (Concept)

- Employee signs up in Amazon Cognito

- Cognito generates a unique sub (User ID)

- Lambda / Admin inserts employee into RDS

- RDS stores Cognito ID as reference

- Frontend uses Cognito token → fetch employee data from RDS

### 🔄 RDS Table Structure (Employee Master Table)

| Column Name     | Data Type           | Purpose                 |
| --------------- | ------------------- | ----------------------- |
| id              | INT AUTO_INCREMENT  | Internal DB ID          |
| cognito_user_id | VARCHAR(100) UNIQUE | Links Cognito user      |
| name            | VARCHAR(100)        | Employee name           |
| job_title       | VARCHAR(50)         | Role (Barista, Manager) |
| salary          | DECIMAL(10,2)       | Salary                  |
| start_date      | DATE                | Joining date            |

### 🔄 Cognito → Employee Identity Mapping

| Cognito Attribute  | Meaning        | Usage in RDS                |
| ------------------ | -------------- | --------------------------- |
| sub                | Unique User ID | Stored as `cognito_user_id` |
| email              | Login email    | Optional mapping            |
| cognito:username   | Username       | UI reference                |
| custom:employee_id | Optional DB ID | Alternative mapping         |

### 1️⃣ Get Cognito User Info

Example Cognito user:

| Field    | Value                                  |
| -------- | -------------------------------------- |
| username | ali                                    |
| sub      | `74e8a458-a011-700d-dcdb-df9692b61962` |
| group    | Employee                               |

### 2️⃣ Insert Employee into RDS

```
INSERT INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('74e8a458-a011-700d-dcdb-df9692b61962',
 'Ali',
 'Barista',
 40000,
 '2026-03-05');
```

### 3️⃣ Verify Employee in RDS

```
SELECT * FROM employees
WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```

### 4️⃣ Batch Insert (Optional)

```
INSERT INTO employees (cognito_user_id, name, job_title, salary, start_date)
VALUES
('ID-2', 'Bob', 'Chef', 50000, '2026-03-01'),
('ID-3', 'Carol', 'Manager', 60000, '2026-02-15');
```

### 5️⃣ Integration Query (App Use Case)

```
SELECT name, job_title, salary
FROM employees
WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```

### 6️⃣ Cognito Configuration (Required Setup)

#### 🔐 App Client Settings

| Setting    | Value                    |
| ---------- | ------------------------ |
| OAuth Flow | Authorization Code Grant |
| Scope      | openid, email, profile   |

#### 🔁 Redirect URLs

| Type     | URL                                                                                                  |
| -------- | ---------------------------------------------------------------------------------------------------- |
| Callback | [https://your-cloudfront-url/employee-portal.html](https://your-cloudfront-url/employee-portal.html) |
| Logout   | [https://your-cloudfront-url/employee-login.html](https://your-cloudfront-url/employee-login.html)   |

#### 🌐 Cognito Hosted Domain

- Example: charlie-cafe-auth

- Login URL:

```
https://charlie-cafe-auth.auth.us-east-1.amazoncognito.com/login
```

### 🌐 Login Flow (Frontend)

#### 🔑 Login URL Example

```
https://charlie-cafe-auth.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://your-cloudfront-url/employee-portal.html
```

#### 🔁 After Login

Cognito returns:

```
employee-portal.html?code=xxxx
```

Frontend exchanges code → token

### 🔑 Token Verification (Frontend)

```
console.log(parseJwt(localStorage.getItem("id_token")));
```

#### ✅ Expected Token Output

```
{
  "sub": "74e8a458-a011-700d-dcdb-df9692b61962",
  "email": "ali@charliecafe.com",
  "cognito:username": "ali",
  "custom:employee_id": "5"
}
```

### 🌀 RDS ↔ Cognito Integration Logic

| Step | Action                   |
| ---- | ------------------------ |
| 1    | User logs in via Cognito |
| 2    | Get `sub` from token     |
| 3    | Use `sub` to query RDS   |
| 4    | Fetch employee record    |
| 5    | Return data to frontend  |

### 🌀 Lambda Automation (Best Practice)

#### ⚡ Auto Employee Creation (Post Confirmation Trigger)

```
INSERT INTO employees 
(cognito_user_id, name, job_title, salary, start_date)
VALUES (%s, %s, %s, %s, %s)
```

#### 🔄 Workflow:

| Event                | Action            |
| -------------------- | ----------------- |
| Cognito user created | Lambda triggered  |
| Lambda executes      | Inserts into RDS  |
| Employee ready       | Portal auto-syncs |

### ⚒ Final Verification Checklist

#### ✅ RDS Check

```
SHOW TABLES;
SELECT * FROM employees;
```

#### ✅ Cognito Check

- User pool active

- App client configured

- Hosted UI enabled

- OAuth scopes correct

#### ✅ Integration Check

- Token contains sub

- RDS stores cognito_user_id

- Query returns employee data

### 🎯 Final Result

✔ Cognito handles authentication

✔ RDS stores employee profile

✔ sub links both systems

✔ Frontend uses token to fetch employee data

✔ Lambda can automate employee creation
---
## 9️⃣ — SQS (Producer Setup)

### 1️⃣ SQS Queue Configuration

| Parameter          | Value             | Notes                    |
| ------------------ | ----------------- | ------------------------ |
| Queue Name         | `CafeOrdersQueue` | Main order queue         |
| Queue Type         | Standard          | ❌ Do NOT use FIFO        |
| Visibility Timeout | 60 seconds        | Lambda processing window |
| Message Retention  | 4 days            | Default                  |
| Max Message Size   | 256 KB            | Default                  |
| Delivery Delay     | 0 seconds         | Default                  |
| Receive Wait Time  | 0 seconds         | Default                  |
| Dead-Letter Queue  | ❌ Disabled        | Will be added later      |
| Encryption         | ❌ Disabled        | Free-tier friendly       |
| Access Policy      | Basic (default)   | Do not modify            |

### 2️⃣ Purpose & Behavior

| Component       | Role                               |
| --------------- | ---------------------------------- |
| SQS Queue       | Stores incoming orders             |
| Producer Lambda | Sends messages to queue            |
| Worker Lambda   | Processes messages + writes to RDS |
| Flow Type       | Asynchronous processing            |

### 3️⃣ Performance Design

| Setting                  | Reason                                |
| ------------------------ | ------------------------------------- |
| Visibility Timeout (60s) | Ensures Lambda completes DB insert    |
| Standard Queue           | High throughput, unordered processing |
| No DLQ (initial)         | Simpler setup for development         |

### 4️⃣ Security & Access

| Setting       | Value                                   |
| ------------- | --------------------------------------- |
| Encryption    | Disabled (dev mode)                     |
| Access Policy | Default AWS-managed                     |
| Public Access | Not applicable (SQS is private service) |

### 5️⃣ Output Values (IMPORTANT)

| Item         | Value                                 |
| ------------ | ------------------------------------- |
| Queue Status | Available                             |
| Queue URL    | Save for Lambda integration           |
| Queue ARN    | Required for IAM + Lambda permissions |

### 💡 Notes

- SQS acts as buffer between API and database

- Ensures decoupled architecture

- Prevents DB overload

- Enables scalable async processing

- Standard queue = best for event-driven systems

### 🔄 Architecture Flow

```
API → Producer Lambda → SQS Queue → Worker Lambda → RDS
```
---
### 🔟 Lambda & API Configuration 

### 1️⃣ Create Lambda Function

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

### 2️⃣ API Gateway Endpoints

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

### 3️⃣ Git Auto Deploy

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

### 🌐 Verification Test (Optional)

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

### 🌐 EC2 Docker Health (Optional)

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

#### ✅ Docker Container

Read more [verify_docker-container](./docs/Readme/verify_docker-container.md)

---
## 1️⃣1️⃣ ☁️ AWS DEVOPS UPGRADE -- ECS & ECR

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
## ☕ 4. Lab Task List (Step-by-Step)

### 🔹 Phase 1 – Setup

 Create GitHub repo

 Organize project structure

 Setup Docker (local)

### 🔹 Phase 2 – AWS Foundation

 Create VPC, subnets

 Configure Security Groups

 Launch EC2 instance

 Setup ALB

### 🔹 Phase 3 – Database

 Create RDS MySQL

 Create DynamoDB tables:

CafeMenu

CafeOrders

CafeOrderMetrics

CafeAttendance

 Store credentials in Secrets Manager

### 🔹 Phase 4 – 

 Create Lambda functions

 Connect Lambda to VPC

 Configure environment variables

 Create SQS queue

### 🔹 Phase 5 – API Layer

 Create API Gateway

 Connect endpoints to Lambda

 Enable CORS

 Add Cognito authorizer

### 🔹 Phase 6 – Authentication

 Setup Cognito User Pool

 Create users & groups

 Configure Hosted UI

### 🔹 Phase 7 – DevOps

 Create Dockerfile

 Push image to ECR

 Deploy ECS service

 Configure ALB target group

### 🔹 Phase 8 – CI/CD

 Setup GitHub Actions

 Add AWS secrets

 Automate deployment

### 🔹 Phase 9 – Advanced

 Setup Blue/Green deployment

 Configure CodeDeploy
 
 Add CloudWatch alarms