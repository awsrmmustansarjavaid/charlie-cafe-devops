# Charlie Cafe - AWS Lambda & Github 


### ✅ Difference: Paste Code vs GitHub CI/CD

This is VERY important for interviews 👇

### 🔴 1. Manual Paste (Bad for DevOps)

👉 You copy code → paste into AWS Lambda console

#### ❌ Problems:

- No version control

- No history

- Easy to break production

- No automation

- Not scalable

- No team collaboration

👉 This is NOT DevOps

### 🟢 2. GitHub → Lambda (CI/CD) (Professional Way)

👉 Code lives in GitHub → pipeline deploys automatically

#### ✅ Benefits:

- Version control (Git)

- Automatic deployment

- Rollback possible

- Team collaboration

- Production-safe

- Real DevOps workflow

### ⚔️ Quick Comparison

| Feature         | Paste Code | GitHub CI/CD |
| --------------- | ---------- | ------------ |
| Version control | ❌          | ✅            |
| Automation      | ❌          | ✅            |
| Rollback        | ❌          | ✅            |
| Team work       | ❌          | ✅            |
| Professional    | ❌          | ✅🔥          |

### ✅ How to Deploy AWS Lambda from GitHub (CI/CD)

Instead of copy-paste in AWS Lambda console, you’ll auto-deploy from GitHub → Lambda using GitHub Actions.

### 🧠 Concept Flow

```
GitHub Repo → GitHub Actions → Zip Code → AWS Lambda Update
```

### ✅ Step 1 — Prepare Your Lambda Code

Your structure already looks good:

```
app/backend/lambda/
    ├── handler.py
    ├── utils.py
```

👉 Make sure your main file has a handler like:

```
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "Hello from Charlie Cafe Lambda 🚀"
    }
```

### ✅ Step 2 — Create IAM User for GitHub

- In AWS: 👉 Go to IAM → Users → Create user

- Attach policy:

```
{
  "Effect": "Allow",
  "Action": [
    "lambda:UpdateFunctionCode",
    "lambda:GetFunction"
  ],
  "Resource": "*"
}
```

#### 👉 Save:

- AWS_ACCESS_KEY_ID

- AWS_SECRET_ACCESS_KEY

### ✅ Step 3 — Add GitHub Secrets

- In your repo: 👉 Settings → Secrets → Actions → Add:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
LAMBDA_FUNCTION_NAME
```

### ✅ Step 4 — Update deploy.yml

Add a new job OR step inside your existing pipeline:

```
# ==========================================================
# 🚀 Deploy Lambda Function (Charlie Cafe)
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

- name: 🚀 Deploy to AWS Lambda
  run: |
    aws lambda update-function-code \
      --function-name ${{ secrets.LAMBDA_FUNCTION_NAME }} \
      --zip-file fileb://app/backend/lambda/lambda.zip
```

### ✅ Step 5 — Push Code

```
git add .
git commit -m "Deploy Lambda via CI/CD"
git push origin main
```

👉 DONE — Lambda auto updates 🎉

### ✅ Step 6 — Add Lambda Layers

#### For dependencies:

```
requests/
numpy/
```

### ✅ Step 7 — Add Testing Before Deploy

```
- name: ✅ Run Tests
  run: |
    python -m unittest discover
```

### ✅ Step 8 — Deploy Different Environments

```
dev → staging → production
```








