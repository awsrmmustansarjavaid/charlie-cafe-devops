# Charlie Cafe — Amazon SQS Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon SQS.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

## PHASE 1️⃣ — SQS/LAMBDA (Producer)


### 1️⃣ Create SQS Queue

- **SQS → Create queue**

- **Queue Type:** Standard

    ⚠️ Do NOT select FIFO

- **Name:** CafeOrdersQueue

**Configuration:**

- **Visibility timeout:** 60

> **💡 Why: Worker Lambda must finish DB insert within this time**

- **Message retention:** 4 days **(Leave default)**

- **Maximum message size:** 256 KB **(Leave default)**

- **Delivery delay:** 0 seconds **(Leave default)**

- **Receive message wait time:** 0 seconds **(Leave default)**

- **Dead-letter queue:** ❌ Disable for now **(we’ll add later)**

- **Encryption:** Select: Disabled **(Free tier friendly)**

- **Access Policy:** Leave Basic **(Do NOT change)**

**✔️ Click Create queue**


### ✅ Verify

- Queue status should be Available

- Copy Queue ARN

- Copy Queue URL (IMPORTANT — save it)


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

#### 📍 How to get Queue URL:

- Open SQS

- Click CafeOrdersQueue

- Copy Queue URL

**✔️ Click Save**

**✔️ Everything else remains same.**


#### Inside your SQS CafeOrderProcessor, after DB insert:

```
metrics_table.update_item(
    Key={"metric": "TOTAL_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)
```


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


### 2️⃣ API Gateway Endpoints


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


### 3️⃣ Update Frontend Configuration (config.js)


#### 📍 File Location
`/app/frontend/js/config.js`

---


#### 🧩 Purpose
This file contains all the **environment-specific configuration values** required for the frontend application to communicate with AWS backend services such as API Gateway, CloudFront, and Cognito.

---


#### ⚙️ Required Configuration Parameters

Update the following values in `config.js`:

| Parameter                | Description |
|-------------------------|-------------|
| `CLOUDFRONT_URL`        | CloudFront distribution URL for frontend access |
| `API_BASE_URL`          | API Gateway endpoint for backend APIs |
| `COGNITO_DOMAIN`        | Cognito Hosted UI domain |
| `COGNITO_USER_POOL_ID`  | Cognito User Pool ID |
| `COGNITO_CLIENT_ID`     | Cognito App Client ID |

> ⚠️ **Important:** Never expose sensitive data such as client secrets in frontend code.

---


#### 🧾 Example Configuration

```javascript
const CONFIG = {
  CLOUDFRONT_URL: "https://d123abcxyz.cloudfront.net",

  API_BASE_URL: "https://abc123.execute-api.us-east-1.amazonaws.com/prod",

  COGNITO_DOMAIN: "https://charlie-cafe-auth.auth.us-east-1.amazoncognito.com",

  COGNITO_USER_POOL_ID: "us-east-1_AbCdEf123",

  COGNITO_CLIENT_ID: "4h5k6l7m8n9opqrs123456"
};
```


#### 🔐 Security Best Practices

- ❌ **Do NOT store Cognito Client Secret in frontend code**

- ✅ Use **Authorization Code Flow (OAuth2)** instead

- ✅ Store sensitive data in **backend services or environment variables**

- ✅ Always use **HTTPS endpoints** for secure communication

---


#### 💡 Tips

- Use versioning for config updates (e.g., `config.v2.js`)

- Avoid hardcoding environment values in production (use environment-based configs)

- Test all endpoints after updating configuration


### 4️⃣ Git Auto Deploy


#### 📄 deploy_via_ssm.sh

```
nano deploy_via_ssm.sh
```

[deploy_via_ssm.sh](./infrastructure/scripts/deploy_via_ssm.sh)


#### 💡 What you only need to provide:

```
GITHUB_REPO_URL="https://github.com/YOUR_USERNAME/YOUR_REPO.git"
```

```
chmod +x deploy_via_ssm.sh
./deploy_via_ssm.sh
```


#### 📄 github-aws-devops-lambda-deploy.sh

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


#### ✅ Docker Container Read more [verify_docker-container](./docs/Readme/verify_docker-container.md)

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

---

