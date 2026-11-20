# Charlie Cafe — AWS Secrets Manager Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for AWS Secrets Manager.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

# Secret Name or ARN
SECRET_ID="CafeDevDBSM"
AWS_REGION="us-east-1"


# FETCH SECRET

# ===============================

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)


# ✔ AWS Secrets Manager integration

# =============================================================
print_header "Fetching Secrets Manager Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
--secret-id "$SECRET_ID" \
--region "$AWS_REGION" \
--query SecretString \
--output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

print_success "Credentials loaded"


## PHASE 3️⃣ — Store DB Credentials in Secrets Manager


### 1️⃣ Store DB Credentials in Secrets Manager

- Go to Secrets Manager → Store a new secret

- **Type: Other type of secret → Key/Value**


| Key      | Value              |
|----------|--------------------|
| username | cafe_user          |
| password | StrongPassword123  |
| host     | RDS endpoint       |
| dbname   | cafe_db            |

- Retrieve Secret ARN for later use in the app


### ✅ JSON Key/Value

```
{
  "username": "cafe_user",
  "password": "StrongPassword123",
  "host": "your-rds-endpoint.amazonaws.com",
  "dbname": "cafe_db"
}
```


#### ✅  Replace These Values

- username → cafe_user (your DB user)

- password → StrongPassword123 (your real DB password)

- host → your RDS endpoint (example: cafedb.xxxxxx.us-east-1.rds.amazonaws.com)

- dbname → cafe_db


#### Example With Real Format

```
{
  "username": "cafe_user",
  "password": "StrongPassword123",
  "host": "cafedb.abc123xyz.us-east-1.rds.amazonaws.com",
  "dbname": "cafe_db"
}
```


### ✅ Secret Name

```
CafeDevDBSM
```


### ✅ After Creating the Secret

Copy the Secret ARN. It will look like:

```
arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeDevDBSM-xxxxx
```


#### ✅ You will use this ARN inside your AWS Lambda code to retrieve the database credentials.

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**


#### 1️⃣ — Create secret

```
aws secretsmanager create-secret \
  --name cafe-db-credentials \
  --secret-string '{
    "host":"db-endpoint",
    "user":"admin",
    "password":"secret",
    "dbname":"cafe"
  }'
```


#  - Optional Secrets Manager creation

# Secrets Manager (optional)
SECRET_NAME="cafe-db-credentials"
DB_SECRET_JSON='{
  "host":"db-endpoint",
  "user":"admin",
  "password":"secret",
  "dbname":"cafe"
}'


# PHASE 4️⃣ – OPTIONAL SECRETS MANAGER

# -----------------------------
echo "🔐 Optional: Creating Secrets Manager DB credentials"
echo "⏭ Skipped if secret already exists"

if ! aws secretsmanager describe-secret --secret-id "$SECRET_NAME" >/dev/null 2>&1; then
  aws secretsmanager create-secret \
    --name "$SECRET_NAME" \
    --secret-string "$DB_SECRET_JSON"

  echo "✅ Secret created: $SECRET_NAME"
else
  echo "ℹ️ Secret already exists: $SECRET_NAME"
fi

echo


### 3️⃣ Configure Secrets Manager

Create a secret: CafeDevDBSM


#### Key/Values:

| Key      | Value                 |
| -------- | --------------------- |
| host     | `<your-rds-endpoint>` |
| username | `<db-username>`       |
| password | `<db-password>`       |
| dbname   | cafe_db               |


#### Ensure Lambda role has SecretsManagerReadWrite permission:

```
{
    "Effect": "Allow",
    "Action": [
        "secretsmanager:GetSecretValue"
    ],
    "Resource": "*"
}
```


### ✅ Verify Secrets Manager

- Go to: 👉 AWS Console → Secrets Manager

- Check secret: CafeDevDBSM


#### It must contain JSON like:

```
{
  "host": "your-rds-endpoint",
  "username": "admin",
  "password": "yourpassword",
  "dbname": "cafe_db"
}
```

**⚠️ If any key name is wrong → Lambda will fail.**

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

#### 🔐 Credential & Secret Management

- AWS Secrets Manager


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

