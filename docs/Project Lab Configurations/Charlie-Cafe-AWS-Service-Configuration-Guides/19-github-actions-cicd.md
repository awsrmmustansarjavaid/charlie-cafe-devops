# Charlie Cafe — GitHub Actions & CI/CD Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for GitHub Actions & CI/CD.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

### 🎯 Technical Goals

- Implement serverless backend (Lambda + API Gateway)

- Use event-driven architecture (SQS)

- Deploy containerized frontend (Docker → ECS)

- Build CI/CD pipeline (GitHub Actions)

- Ensure secure architecture (VPC + Secrets Manager + Cognito)


#### 🔹 0. GITHUB

- Github Account

- Github Repo

- Github Repository secrets


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

#### 🔄 Workflow:

| Event                | Action            |
| -------------------- | ----------------- |
| Cognito user created | Lambda triggered  |
| Lambda executes      | Inserts into RDS  |
| Employee ready       | Portal auto-syncs |


#### 📄 github-aws-devops-lambda-deploy.sh

```
nano github-aws-devops-lambda-deploy.sh
```

[github-aws-devops-lambda-deploy.sh](./infrastructure/scripts/github-aws-devops-lambda-deploy.sh)


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


