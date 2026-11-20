# Charlie Cafe — Amazon VPC & Networking Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon VPC & Networking.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

### 1️⃣ Create Development VPC (us‑east‑1)

* VPC Name: `CafeDevVPC`
* CIDR: `10.0.0.0/16`


### 2️⃣ Create Public Subnet

* Name: `CafeDevPublicSubnet`
* CIDR: `10.0.1.0/24`
* Auto‑assign public IP: **Enabled**


### 4️⃣ Internet Access

* Create Internet Gateway → Attach to VPC
* Route table → Add route `0.0.0.0/0 → IGW`


### 5️⃣ Security Group and NACL


#### ✅ Open Security Group (MANDATORY)

- Default SG (for general VPC resources)

- RDS SG (for MySQL database)

- Lambda SG (for Lambdas that need RDS access)


### Security Group Overview

| Security Group | Purpose                             | Attached Resources | Inbound Rules                          | Outbound Rules               |
| -------------- | ----------------------------------- | ------------------ | -------------------------------------- | ---------------------------- |
| **Default SG** | General default security group      | RDS, EC2 (if any)  | SSH, HTTP, HTTPS, MySQL, ALL TCP       | All traffic allowed          |
| **RDS SG**     | Protect database                    | RDS instance       | MySQL only from Lambda SG + Default SG | Allow Lambda SG & Default SG |
| **Lambda SG**  | Lambda functions needing VPC access | Lambda (VPC)       | SSH, HTTP, HTTPS, allow RDS MySQL      | Allow all outbound (default) |


### 1️⃣ Default Security Group

- Name: charlie-default-sg

- Attached to: RDS, any EC2/other resources

- Inbound Rules:

| Type         | Protocol | Port Range | Source                                              |
| ------------ | -------- | ---------- | --------------------------------------------------- |
| SSH          | TCP      | 22         | 0.0.0.0/0 (or your IP)                              |
| HTTP         | TCP      | 80         | 0.0.0.0/0                                           |
| HTTPS        | TCP      | 443        | 0.0.0.0/0                                           |
| MySQL/Aurora | TCP      | 3306       | 0.0.0.0/0 (or Lambda SG + RDS SG only for security) |
| ALL TCP      | TCP      | 0-65535    | 0.0.0.0/0                                           |

- Outbound Rules:

  - All traffic allowed (default)


### 2️⃣ RDS Security Group

- Name: charlie-rds-sg

- Attached to: RDS instance

- Inbound Rules:

| Type         | Protocol | Port Range | Source                                  |
| ------------ | -------- | ---------- | --------------------------------------- |
| MySQL/Aurora | TCP      | 3306       | Lambda SG (allow only Lambda functions) |
| MySQL/Aurora | TCP      | 3306       | Default SG (if needed for admin access) |

- Outbound Rules:

  - All traffic allowed (default)

  - Can optionally restrict to Lambda SG only


#### Note: RDS SG is private, only Lambda can access 3306.


### 3️⃣ Lambda Security Group

- Name: charlie-lambda-sg

- Attached to: Lambda functions in VPC

- Inbound Rules:

| Type  | Protocol | Port Range | Source                                |
| ----- | -------- | ---------- | ------------------------------------- |
| SSH   | TCP      | 22         | Default SG (if admin needs)           |
| HTTP  | TCP      | 80         | Default SG (for API testing)          |
| HTTPS | TCP      | 443        | Default SG                            |
| MySQL | TCP      | 3306       | RDS SG (so Lambda can connect to RDS) |

- Outbound Rules:

  - All traffic allowed (default)


#### Notes:

- Lambda in VPC requires SG to allow outbound to RDS SG on 3306

- SSH/HTTP/HTTPS in inbound is optional unless you want Lambda testing/debugging


### 2️⃣ Create Security Group for RDS
VPC → Security Groups → Create

- Name: CafeRDS-SG

- Inbound:
  - MySQL/Aurora (3306) → Source: Lambda-SG
  - MySQL/Aurora (3306) → Source: EC2-Web-SG
- Outbound: All

- **✔️ Create**


### STEP 3️⃣ — SECURITY GROUP


#### Allow:

```
HTTPS 443  0.0.0.0/0
```


### 6️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**


## PHASE 5️⃣ — VPC ENDPOINTS (THIS IS WHERE MOST FAIL)


### 1️⃣ Fix Security Groups (MANDATORY)

**A) RDS Security Group**


#### Inbound rule:

| Type         | Port | Source        |
| ------------ | ---- | ------------- |
| MySQL/Aurora | 3306 | **Lambda-SG** |


❌ NOT 0.0.0.0/0

✅ MUST be Lambda SG

**B) Lambda Security Group**


#### Outbound rule (default usually OK):

| Type        | Destination |
| ----------- | ----------- |
| All traffic | 0.0.0.0/0   |



### 2️⃣ Create Secrets Manager Endpoint

- **AWS Console → VPC → Endpoints → Create endpoint**

- **Endpoint Name:** secretsmanager-INT-EP

- **Service category:** AWS services

- **Service name:** com.amazonaws.us-east-1.secretsmanager

- **Type:** Interface

- **VPC:** Select VPC 

- **Subnets:**

**✔ Select the SAME private subnets used by Lambda**

- **Security Group:**

**Allow HTTPS (443) inbound from Lambda SG**

Create endpoint ✅


### 3️⃣ Create SQS Interface Endpoint

**VPC → Endpoints → Create endpoint**

| Field          | Value                         |
| -------------- | ----------------------------- |
| Name           | sqs-INT-EP                    |
| Service        | `com.amazonaws.us-east-1.sqs` |
| Type           | Interface                     |
| VPC            | Same VPC                      |
| Subnets        | Same private subnets          |
| Security group | Lambda-SG                     |
| Private DNS    | ✅ ENABLE                      |


### 4️⃣ Create CloudWatch Logs Interface Endpoint

- **Name:**

```
cloudwatch-INT-EP 
```

- **Service:**

```
com.amazonaws.us-east-1.logs
```

Same settings as above

Private DNS ✅


### 5️⃣ Create DynamoDB Gateway Endpoint (VERY IMPORTANT)

- **Name:**

```
dynamodb-GW-EP 
```


- **Service:**

```
com.amazonaws.us-east-1.dynamodb
```

- **Type:** Gateway

- **Attach to:**

  - ALL private route tables

Click Create


### 6️⃣ Verify Secrets Manager Keys (VERY IMPORTANT)

Your secret must contain EXACT keys:

```
{
  "host": "your-rds-endpoint",
  "username": "cafe_user",
  "password": "********",
  "dbname": "cafe_db"
}
```

❌ If even ONE key name differs → connection fails silently


### 7️⃣ Add DEBUG LOGS (TEMPORARY - Optional)

Update your Lambda code temporarily:

```
print("DEBUG: Lambda invoked")
print("DEBUG: Event =", event)

secret = get_db_secret()
print("DEBUG: Secret fetched")

connection = pymysql.connect(
    host=secret["host"],
    user=secret["username"],
    password=secret["password"],
    database=secret["dbname"],
    connect_timeout=5
)

print("DEBUG: RDS connected")
```

This lets us see exactly where it stops.

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---

### 4️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**


### 4️⃣ — Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**


### 3️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**    


### 4️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**    


### 4️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**    


#### ✅ Add VPC Configuration (CRITICAL)

- Lambda → Configuration → VPC

- VPC: same VPC as RDS

- Subnets: private subnets used by RDS

- Security group: Lambda SG that allows RDS access

- Click Save


#### 🌐 Networking Services

- VPC (Virtual Private Cloud)

- Security Groups

- VPC Endpoints

- NAT Gateway

- Internet Gateway (IGW)

- Application Load Balancer (ALB)

- EC2 (Elastic Compute Cloud)

- CloudFront


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


#### 🔹 NACL

| Component | Rule                             |
| --------- | -------------------------------- |
| NACL      | Allow all inbound/outbound (Dev) |


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

#### 🔹 VPC Endpoints (Private Access)

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

- ### 7️⃣ ALB + ECS SERVICE

> #### KEEP existing ALB and upgrade it for ECS.


