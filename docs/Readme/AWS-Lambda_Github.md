# ☕ Charlie Cafe — GitHub → Lambda → API Gateway (CI/CD)

### 🧠 Your Current Architecture

```
GitHub Repo
   ↓
GitHub Actions (deploy.yml)
   ↓
AWS Lambda (multiple functions)
   ↓
API Gateway (already integrated)
   ↓
Frontend / Browser
```

#### 👉 IMPORTANT:

Y- our API Gateway is already connected to Lambda ✅

- So when Lambda updates → API auto uses new code (NO change needed)

### ✅ Difference: Paste Code vs GitHub CI/CD

This is VERY important for interviews 👇

### 🔴 1. Real Difference (Based on YOUR LAB) 

#### Manual Paste (Your Old Way)

You were doing:

```
GitHub → Copy code → AWS Lambda Console → Paste → Deploy
```

#### ❌ Problems in YOUR scenario:

- Your repo (charlie-cafe-devops) becomes useless for backend versioning

- If you break one Lambda → API Gateway breaks instantly

- No rollback if API fails

- Multiple Lambda functions = headache 😵

### 🟢 GitHub CI/CD (Your New Way)

Now you will do:

```
GitHub → Push Code → GitHub Actions → Auto Deploy → Lambda Updated
```

#### ✅ In YOUR lab:

- Each Lambda function is deployed automatically

- API Gateway endpoints stay SAME (no reconfiguration)

- Your backend becomes production-grade DevOps system

### ⚔️ Simple Comparison (Interview Ready)

| Feature           | Paste Code | GitHub → Lambda |
| ----------------- | ---------- | --------------- |
| API Stability     | ❌ Risky    | ✅ Safe          |
| Multi Lambda Mgmt | ❌ Hard     | ✅ Easy          |
| Rollback          | ❌ No       | ✅ Yes           |
| Automation        | ❌ No       | ✅ Yes 🔥        |
| DevOps Level      | ❌ Basic    | ✅ Professional  |

### 🚀 2. How to Implement (YOUR REPO STRUCTURE)

#### You already have:

```
app/backend/lambda/
   ├── order.py
   ├── menu.py
   ├── payment.py
```

👉 Each file = one Lambda function (important!)

### 🧠 3. Deployment Strategy (IMPORTANT DECISION)

#### You have 2 options:

- ✅ Option A (BEST for your lab) → Deploy ALL Lambdas in one pipeline

- ❌ Option B → Separate pipeline per Lambda (complex)

👉 You should use Option A

### 🔐 4. IAM Policy (Minimal Required)

#### Attach this to your IAM user:

```
{
  "Effect": "Allow",
  "Action": [
    "lambda:UpdateFunctionCode"
  ],
  "Resource": "*"
}
```

### 🔑 5. GitHub Secrets

#### Add in GitHub:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

#### AND (important for multi-lambda):

```
LAMBDA_MENU
LAMBDA_ORDER
LAMBDA_PAYMENT
```

### ⚙️ 6. FINAL deploy.yml (FOR YOUR LAB)

Add this inside your existing pipeline (don’t break ECS part)

```
# ==========================================================
# 🚀 Deploy ALL Lambda Functions (Charlie Cafe)
# ==========================================================

- name: 📦 Zip Lambda Code
  run: |
    cd app/backend/lambda
    zip -r lambda.zip .

- name: 🔐 Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}

# ----------------------------------------------------------
# 🍽️ Deploy Menu Lambda
# ----------------------------------------------------------
- name: 🚀 Deploy Menu Lambda
  run: |
    aws lambda update-function-code \
      --function-name ${{ secrets.LAMBDA_MENU }} \
      --zip-file fileb://app/backend/lambda/lambda.zip

# ----------------------------------------------------------
# 🧾 Deploy Order Lambda
# ----------------------------------------------------------
- name: 🚀 Deploy Order Lambda
  run: |
    aws lambda update-function-code \
      --function-name ${{ secrets.LAMBDA_ORDER }} \
      --zip-file fileb://app/backend/lambda/lambda.zip

# ----------------------------------------------------------
# 💳 Deploy Payment Lambda
# ----------------------------------------------------------
- name: 🚀 Deploy Payment Lambda
  run: |
    aws lambda update-function-code \
      --function-name ${{ secrets.LAMBDA_PAYMENT }} \
      --zip-file fileb://app/backend/lambda/lambda.zip
```

### 🧠 7. IMPORTANT CONCEPT (Most People Miss This)

#### ❗ You are deploying SAME zip to ALL Lambdas

👉 That means:

Each Lambda must use correct handler

Example:

| Lambda Name    | Handler Setting          |
| -------------- | ------------------------ |
| menu-function  | `menu.lambda_handler`    |
| order-function | `order.lambda_handler`   |
| payment        | `payment.lambda_handler` |

👉 This is configured in AWS Lambda (not GitHub)

### 🔗 8. API Gateway — DO YOU NEED CHANGE?

#### 👉 ❌ NO CHANGE REQUIRED

Because:

- API Gateway → already linked to Lambda

- Lambda code updates automatically reflect

### 🧪 9. Optional (But Powerful)

Add testing before deploy:

```
- name: ✅ Test Lambda Code
  run: |
    python -m unittest discover app/backend/lambda
```

### 🔥 10. Final DevOps Flow (Your Lab)

```
Developer (You)
   ↓
Git Push
   ↓
GitHub Actions
   ↓
Zip Lambda Code
   ↓
Update Multiple Lambdas
   ↓
API Gateway (auto updated)
   ↓
Frontend calls API 🚀
```

### 💡 PRO TIP (VERY IMPORTANT FOR YOUR CAREER)

#### Right now your architecture becomes:

✅ ECS (containers)

✅ EC2 (LAMP)

✅ Lambda (serverless)

✅ API Gateway

✅ GitHub CI/CD

👉 This is FULL HYBRID AWS ARCHITECTURE

💥 This is what companies ask for (DevOps + Cloud Engineer role)

### ❓ If You Want Next Level Upgrade

#### I can help you add:

✅ Lambda versioning + rollback

✅ Dev / Stage / Prod environments

✅ Auto API testing after deploy

✅ CloudWatch monitoring integration

✅ Terraform (infra as code)

---
## ☕ Charlie Cafe Full AWS DevOps Upgrade from GitHub

> This project upgrades the existing Charlie Cafe application into a fully automated AWS DevOps workflow using GitHub, CI/CD, and AWS services. The goal is to have automatic deployment for Lambda functions, API Gateway, RDS, DynamoDB, and LAMP components via GitHub Actions and scripts, ensuring version control, testing, and zero manual deployment steps. This setup allows you to maintain all Lambda code in your GitHub repo and deploy updates seamlessly across all integrated AWS services.

### 🔥 First — What You MUST Understand (Very Important)

Before touching anything, keep these rules in mind:

- ### 1️⃣ Lambda code SHOULD be inside GitHub (✔ already done)

You already have:

```
app/backend/lambda/*.py
```

✅ Perfect — DO NOT move them

- ### 2️⃣ Each Lambda = separate deployment unit

Every file like:

CafeOrderProcessor.py
hr-attendance.py

👉 is a separate Lambda function in AWS

So:

❌ You cannot deploy all in one command

✅ You must update each Lambda individually

- ### 3️⃣ Two deployment methods (choose one)

| Method          | Use case                      |
| --------------- | ----------------------------- |
| ZIP upload      | ✅ BEST for your current setup |
| Container (ECR) | advanced (skip for now)       |

👉 We will use ZIP method (simple + professional)

### 🧠 Answer to Your Main Question

should i add lambda .py inside deploy.yml?

👉 ❌ NO (not directly inside YAML)

👉 ✅ Instead:

- Keep .py files in repo ✔

- Use deploy.yml to:

- Zip them

- Upload to AWS Lambda

### 🚀 FULL STEP-BY-STEP AWS DevOps Configuration Guide

### 🌐 Prerequisites

- AWS Account with permissions: EC2, Lambda, API Gateway, DynamoDB, RDS, IAM, S3, CloudWatch, CloudFormation.

- GitHub repository already containing your project structure (as listed).

- AWS CLI installed locally or in your CI/CD runner.

- Docker installed if using Lambda layers or containerized deployment.

- AWS IAM user with programmatic access (Access Key & Secret Key) for GitHub Actions.

### 1️⃣ Add Lambda Function Names (IMPORTANT)

You must know exact AWS Lambda names.

Example mapping:

| File                  | Lambda Name in AWS |
| --------------------- | ------------------ |
| CafeOrderProcessor.py | CafeOrderProcessor |
| CafeMenuLambda.py     | CafeMenuLambda     |

👉 These names MUST match AWS exactly

### 2️⃣ GitHub Repository Setup

- Ensure your repo structure matches the one you shared.

- Add .gitignore for:

```
__pycache__/
*.pyc
.env
.aws/
```

- Add .dockerignore in Docker folder to exclude unnecessary files.

### 3️⃣ Prepare AWS IAM Roles and Policies

#### Add IAM Permission

Your GitHub IAM user MUST have:

```
{
  "Effect": "Allow",
  "Action": [
    "lambda:UpdateFunctionCode",
    "lambda:GetFunction",
    "lambda:ListFunctions"
  ],
  "Resource": "*"
}
```

#### Read more about [Charlie Cafe DevOps IAM Policy](https://github.dev/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/ee4f9cc434fe3a6d5598db09d452667efb16daa2/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20%28Dev%20%2B%20Prod%29/AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20AWS%20IAM%20Policy%20JSON%20Script/Readme/Charlie%20Cafe%20DevOps.md)

- #### Lambda Execution Role

   - Attach policies: AWSLambdaFullAccess, AmazonDynamoDBFullAccess, AmazonRDSFullAccess, AmazonS3FullAccess, CloudWatchLogsFullAccess.

- #### GitHub CI/CD Role (for GitHub Actions)

   - Policy allowing: lambda:UpdateFunctionCode, apigateway:*, s3:*, ec2:*, ecs:*.

- Save Access Key & Secret Key securely (for GitHub Secrets).

[Charlie Cafe DevOps IAM Policy](https://github.dev/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/ee4f9cc434fe3a6d5598db09d452667efb16daa2/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20%28Dev%20%2B%20Prod%29/AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20AWS%20IAM%20Policy%20JSON%20Script/Charlie%20Cafe%20DevOps.json)

### 4️⃣ Configure AWS Secrets in GitHub

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

### 5️⃣ Lambda Deployment Preparation

- Ensure each Lambda function has a requirements.txt if using Python dependencies.

- If using Lambda layers, place shared dependencies in a lambda_layer.sh script for automation.

- Optional: Containerize Lambda for advanced CI/CD:

```
docker build -t lambda-name ./app/backend/lambda/
```

### 6️⃣ API Gateway Configuration

- Each Lambda already has an API Gateway.

- For CI/CD:

   - Create a script to deploy/update API Gateway:

```
aws apigateway get-rest-apis
aws apigateway import-rest-api --parameters endpointConfigurationTypes=REGIONAL --body 'swagger.json'
```

- This allows API Gateway to auto-update whenever Lambda code changes.

### 7️⃣ RDS & DynamoDB Integration

- #### RDS

   - Keep schema.sql, data.sql, verify.sql under infrastructure/rds/.

   - Add a CI/CD step to initialize or test RDS with:

```
mysql -h <RDS_ENDPOINT> -u <user> -p <password> < schema.sql
```

- #### DynamoDB

- Use aws dynamodb put-item scripts to seed or verify tables.

- Integrate in GitHub Actions for testing.

### 8️⃣ Docker & LAMP Setup

- Apache-PHP Dockerfile: Ensure all your PHP & HTML code runs inside.

- MySQL Dockerfile: Ensure it uses schema.sql & data.sql.

- docker-compose.yml: Make services linkable and networked.

- CI/CD Step: Build and push Docker images to ECR:

```
docker build -t charlie-cafe ./docker/apache-php
docker tag charlie-cafe:latest <ECR_URI>:latest
docker push <ECR_URI>:latest
```

### 9️⃣ GitHub Actions — deploy.yml

Your deploy.yml should include:

- Trigger: On push to main.

- #### Steps:

   - Checkout repo

   - Configure AWS credentials

   - Build & push Docker images

   - Deploy Lambda functions:

```
aws lambda update-function-code \
    --function-name AdminMarkPaidLambda \
    --zip-file fileb://app/backend/lambda/AdminMarkPaidLambda.zip
```

- Update API Gateway

- Run RDS/DynamoDB tests

- Optional: Restart EC2 LAMP containers or ECS service

> This ensures every push automatically updates Lambda, APIs, and backend infrastructure.

- #### ✳️ Modify deploy.yml

👉 Add this NEW section after step 14️⃣ Cleanup

- #### ✳️ PACKAGE LAMBDA CODE

```
    # -------------------------------------------------
    # 15️⃣ Package Lambda Functions
    # -------------------------------------------------
    - name: 📦 Package Lambda Functions
      run: |
        mkdir lambda_zips

        for file in app/backend/lambda/*.py; do
          fname=$(basename "$file" .py)
          zip lambda_zips/$fname.zip "$file"
        done
```

- #### ✳️ DEPLOY LAMBDAS

```
    # -------------------------------------------------
    # 16️⃣ Deploy Lambda Functions
    # -------------------------------------------------
    - name: 🚀 Deploy Lambdas
      run: |
        for zip in lambda_zips/*.zip; do
          fname=$(basename "$zip" .zip)

          echo "Deploying $fname..."

          aws lambda update-function-code \
            --function-name "$fname" \
            --zip-file "fileb://$zip"
        done
```

#### ⚠️ IMPORTANT RULE

👉 Your Lambda name MUST match filename:

Example:

```
CafeOrderProcessor.py → Lambda name = CafeOrderProcessor
```

If not → deployment FAIL ❌

- #### ✳️ KEEP YOUR EXISTING STEPS

After Lambda deployment:

You already have:

```
15️⃣ Deploy to EC2 via SSM
16️⃣ Health Check
17️⃣ Success
```

👉 Keep them as-is 👍


### 1️⃣0️⃣ Health Check & Monitoring

- Add a monitoring script (e.g., health.php or Lambda) for:

   - Lambda status

   - API response

   - RDS connection

   - DynamoDB access

- Integrate with CloudWatch Alarms for auto-restart / notifications.

- #### Add Lambda Health Check

```
    - name: 🧪 Test Lambda
      run: |
        aws lambda invoke \
          --function-name CafeOrderProcessor \
          --payload '{}' response.json

        cat response.json
```


### 1️⃣1️⃣ Verification

- Push a test commit to main.

- Observe GitHub Actions run all steps.

- Validate:

   - Lambda updated

   - API Gateway endpoints respond

   - RDS / DynamoDB data is accessible

   - Docker LAMP services are running

### ⚠️ COMMON MISTAKES (VERY IMPORTANT)

- ### ❌ Mistake 1: Dependencies missing

If your Lambda uses:

- requests

- pymysql

👉 This method will FAIL

👉 Then you need:

- Lambda Layer OR

- package dependencies inside zip

- ### ❌ Mistake 2: Wrong handler

Example:

```
file: CafeOrderProcessor.py
function: lambda_handler
```

AWS expects:

```
CafeOrderProcessor.lambda_handler
```

- ### ❌ Mistake 3: Wrong region

Ensure:

```
AWS_REGION = same as Lambda region
```

### 🧠 FINAL ARCHITECTURE AFTER THIS

You will have:

```
GitHub Push →
   CI/CD →
      ✔ RDS setup
      ✔ Docker test
      ✔ Lambda auto deploy 🔥
      ✔ EC2 deploy
      ✔ Health check
```

👉 This becomes a REAL DevOps project (interview-level strong)

### 💬 FINAL ADVICE (IMPORTANT FOR YOUR CAREER)

You are now combining:

- DevOps ✅

- Backend (Lambda) ✅

- Database ✅

- CI/CD ✅

👉 This is way stronger than basic frontend path

---






