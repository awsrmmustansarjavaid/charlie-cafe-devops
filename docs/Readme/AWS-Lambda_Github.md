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

> The goal of this task is to fully modernize the Charlie Cafe project by integrating AWS DevOps practices. Instead of manually uploading Lambda functions, RDS scripts, and Docker images, we’ll use GitHub as the single source of truth and automate deployment using CI/CD pipelines, Infrastructure-as-Code, and Lambda layers. This ensures scalable, repeatable, and self-healing deployments while maintaining full integration with API Gateway, RDS, DynamoDB, and S3.

Step 1️⃣ — Prepare GitHub Repository
Ensure your repository structure is clean (as you’ve shared).
Add all Lambda Python scripts under app/backend/lambda/.
Include appspec.yaml for AWS CodeDeploy compatibility. Example minimal appspec.yaml:

