# Charlie Cafe - IAM Roles & Policies

### 1️⃣ IAM Role for EC2 (Secrets Access)

#### 1️⃣ IAM Role Name:

```
EC2-Cafe-Secrets-Role
```

#### 2️⃣ Service You Must Select

When creating the IAM role:

- Trusted Entity Type : AWS Service

- Use Case / Service : ✅ EC2

> **This allows the EC2 instance to assume the role and use the permissions defined in your policy.**

#### ✅ Complete IAM Role Creation Steps:

- Go to: AWS Console → IAM → Roles

- Click: Create Role

- Select: Trusted entity type → AWS Service

- Then select: Use case → EC2

- Click: Next

- Attach your custom policy: EC2-Cafe-Secrets-Role

- Role name example: Cafe-EC2-Secrets-Role

- (Optional description): 

```
Role for EC2 to access Lambda, RDS, Secrets Manager, S3 and other services
```

- Click: Create Role

#### ✅ COPY-PASTE READY POLICY JSON

You can paste this directly into IAM → Policies → Create policy → JSON

[EC2-Cafe-Secrets-Role](./Charlie%20Cafe%20IAm%20Policies/EC2-Cafe-Secrets-Role.json)

**⚠️ Attach role to EC2 (NO reboot).**

- **✔️ Click Create IAM ROLE**

### 2️⃣ IAM Role for Charlie Cafe

- **IAM Role Name:**

```
charlie-cafe-iam-Role
```

- Trusted entity type: AWS service

- Service: Lambda

- Click Next

- **Description:**

```
This IAM role is designed to support the backend services of the Charlie Cafe system by providing controlled access to AWS resources required for logging, database operations, message queue processing, secrets management, and file storage.
```

#### ✅ COPY-PASTE READY POLICY JSON

**👉 Paste into IAM → Policies → Create policy → JSON**

- Policy Name: charlie-cafe-iam-policy

- Region: us-east-1

- Account: Your AWS_Account_ID

- **Description:**

```
This IAM policy is designed to support the backend services of the Charlie Cafe system by providing controlled access to AWS resources required for logging, database operations, message queue processing, secrets management, and file storage.
```

You can paste this directly into IAM → Policies → Create policy → JSON

[charlie-cafe-iam-policy](./Charlie%20Cafe%20IAm%20Policies/charlie-cafe-iam-policy.json)

**⚠️ JUST Replace 123456789012 with your real AWS account ID. with your own account ID**

#### ✅ WHY THIS POLICY IS SAFE & CORRECT

✔ No duplicate invalid statements

✔ No conflicting ARNs

✔ Correct AWS service actions

✔ Passes IAM JSON validation

✔ Works for Lambda + DynamoDB + RDS + SQS + S3 + Secrets Manager

✔ Can be attached to Lambda execution roles

**✔️ Click Create policy**

- **✔️ Click Create IAM ROLE**

### 3️⃣ IAM Role for Charlie Cafe

