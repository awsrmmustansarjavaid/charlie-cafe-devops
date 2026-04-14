# ☕ Charlie Cafe Data Flow

## ☕ Charlie Cafe Business Data Flow

> #### “Charlie Cafe uses a serverless event-driven architecture where API Gateway triggers Lambda functions, SQS decouples processing, and DynamoDB/RDS handle real-time and relational data storage, enabling scalable and real-time order management.”

### ☕ Business Data Flow

```

```

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

## ☕ AWS Official Architecture Diagram

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

## ☕ Full System Flow (END-TO-END)

```
User
 ↓
CloudFront
 ↓
ALB
 ↓
ECS (Docker Container - Frontend)
 ↓
API Gateway
 ↓
Lambda
 ↓
SQS → Worker Lambda
 ↓
RDS (Orders DB)
 ↓
DynamoDB (Menu / Metrics)
 ↓
Response to User
```

#### 💡 Add:

- Cognito (Auth)

- Secrets Manager  

## ☕ Serverless Microservices Data Flow

```
User → CloudFront → ALB → ECS/EC2 → API Gateway → Lambda
                                      ↓
                          SQS → Worker Lambda
                                      ↓
                         DynamoDB + RDS
```
## ☕ DevOps Data Flow

```
Developer
   ↓
GitHub Repo
   ↓
GitHub Actions (CI/CD)
   ↓
Build Docker Image
   ↓
Push to ECR
   ↓
Deploy to ECS / Lambda
   ↓
ALB
   ↓
CloudFront
   ↓
Users
```

#### 💡 Add:

- CloudWatch (logs)

- CodeDeploy (blue/green)

## ☕ CI/CD Pipeline Flow

```
Developer Push Code
   ↓
GitHub
   ↓
GitHub Actions Trigger
   ↓
Build Docker Image
   ↓
Run Tests
   ↓
Push to ECR
   ↓
Update ECS Task Definition
   ↓
Deploy via CodeDeploy
   ↓
Traffic Shift (Blue → Green)
   ↓
Live Application
```

## ☕ AWS ↔ GitHub CI/CD Flow

```
GitHub Actions
   ↓ (IAM Access Keys)
AWS CLI
   ↓
ECR (Push Image)
   ↓
ECS (Pull Image)
   ↓
CodeDeploy
   ↓
ALB Traffic Switch
```

## ☕ Frontend ↔ Backend Data Flow

```
User (Browser)
   ↓
CloudFront (CDN)
   ↓
ALB (Load Balancer)
   ↓
EC2 (Frontend - PHP/JS)
   ↓
API Gateway
   ↓
Lambda (Backend Logic)
   ↓
RDS (MySQL)
   ↓
Response → Frontend → User
```

#### 💡 Also include:

- DynamoDB (menu / orders)

- SQS (async processing)

## ☕ Backend Data Flow

```
Frontend → API Gateway → Lambda → SQS → Worker Lambda → DB
```

## ☕ Authentication Flow (Cognito) 🔐 Data Flow

```
User
 ↓
CloudFront (Frontend)
 ↓
Redirect to Cognito Hosted UI
 ↓
User Login
 ↓
Cognito returns JWT Token
 ↓
Frontend stores token
 ↓
API Gateway (Authorization Header)
 ↓
Lambda validates JWT
 ↓
Access granted → RDS / DynamoDB
```

## ☕ API Flow (Frontend → Lambda → DB) 

```
Frontend (JS / PHP)
   ↓
API Gateway
   ↓
Lambda Function
   ↓
Secrets Manager (DB credentials)
   ↓
RDS (MySQL)
   ↓
DynamoDB (optional)
   ↓
Response → Frontend
```

## ☕ Async Order Processing (SQS Flow)

```
User places order
   ↓
API Gateway
   ↓
Producer Lambda
   ↓
SQS Queue
   ↓
Worker Lambda
   ↓
RDS Database
   ↓
Update Order Status
```

## ☕ VPC + Private Architecture Flow

```
Internet
 ↓
CloudFront
 ↓
ALB (Public Subnet)
 ↓
ECS Tasks (Private Subnet)
 ↓
Lambda (Private Subnet)
 ↓
RDS (Private Subnet)
 ↓
VPC Endpoints → AWS Services
```

## ☕ Blue/Green Deployment Flow

```
User Traffic
   ↓
ALB
   ↓
Blue (Current Version)
   ↓
Green (New Version)
   ↓
10% Traffic → Green
   ↓
Health Check
   ↓
100% Switch OR Rollback
```

## ☕ ECS + ECR Flow

```
Docker → ECR → ECS → ALB → User
```

## ☕ RDS Order Flow

```
User (Frontend)
   ↓
CloudFront
   ↓
API Gateway
   ↓
Lambda (Order Processor)
   ↓
Secrets Manager (DB credentials)
   ↓
RDS MySQL (Orders Table)
   ↓
Response → Frontend
```

## ☕ Main Order + HR Flow

```
User (Frontend)
   ↓
CloudFront
   ↓
API Gateway
   ↓
Lambda
   ↓
Secrets Manager (DB credentials)
   ↓
RDS (cafe_db)
   ↓
Tables:
   ├── orders
   ├── employees
   ├── attendance
   ├── leaves
   └── holidays
   ↓
Response → Frontend
```

## ☕ Advanced Flow (WITH SQS + Analytics)

```
User places order
   ↓
API Gateway
   ↓
Lambda (Order Processor)
   ↓
SQS Queue
   ↓
Worker Lambda
   ↓
RDS (orders table)
   ↓
Analytics Queries (SQL)
   ↓
Dashboard (Admin Panel)
```

## ☕ RDS ARCHITECTURE DIAGRAM

```
                ┌───────────────┐
                │   User        │
                └──────┬────────┘
                       ↓
                ┌───────────────┐
                │ CloudFront    │
                └──────┬────────┘
                       ↓
                ┌───────────────┐
                │ API Gateway   │
                └──────┬────────┘
                       ↓
                ┌───────────────┐
                │ Lambda        │
                └──────┬────────┘
                       ↓
          ┌────────────────────────────┐
          │ Secrets Manager            │
          └──────────┬─────────────────┘
                     ↓
        ┌──────────────────────────────┐
        │ RDS MySQL (Private Subnet)   │
        │                              │
        │ cafe_db                      │
        │ ├── orders                  │
        │ ├── employees               │
        │ ├── attendance              │
        │ ├── leaves                  │
        │ └── holidays                │
        └──────────────────────────────┘
```

## ☕ ER DIAGRAM (DATABASE DESIGN)

#### 1. employees (MAIN TABLE)

```
employees
---------
employee_id (PK)
cognito_user_id (UNIQUE)
name
job_title
salary
start_date
created_at
```

#### 2. attendance

```
attendance
---------
attendance_id (PK)
employee_id (FK)
attendance_date
checkin_time
checkout_time
```

#### 3. leaves

```
leaves
---------
leave_id (PK)
employee_id (FK)
leave_date
leave_type
```

#### 4. holidays

```
holidays
---------
holiday_id (PK)
holiday_date (UNIQUE)
description
```

#### 5. orders

```
orders
---------
order_id (PK)
table_number
customer_name
item
quantity
payment_method
total_cost
total_amount
payment_status
status
created_at
```

### 🔗 RELATIONSHIPS

```
employees (1)
   ↓
attendance (many)

employees (1)
   ↓
leaves (many)
```

#### 👉 This means:

- One employee → many attendance records

- One employee → many leave records

## ☕ ER DIAGRAM STRUCTURE

```
           ┌───────────────┐
           │  employees    │
           │───────────────│
           │ employee_id PK│
           │ name          │
           │ job_title     │
           └──────┬────────┘
                  │
        ┌─────────┴─────────┐
        ↓                   ↓

┌───────────────┐   ┌───────────────┐
│  attendance   │   │    leaves     │
│───────────────│   │───────────────│
│ attendance_id │   │ leave_id      │
│ employee_id FK│   │ employee_id FK│
│ checkin_time  │   │ leave_date    │
└───────────────┘   └───────────────┘


┌───────────────┐
│   holidays    │
└───────────────┘

┌───────────────┐
│    orders     │
└───────────────┘
```

## ☕ FULL DATA FLOW (RDS + SYSTEM

```
User
 ↓
CloudFront
 ↓
Frontend (EC2 / ECS)
 ↓
API Gateway
 ↓
Lambda
 ↓
 ├── DynamoDB (menu / metrics)
 └── RDS (orders + employees + HR)
 ↓
Response
```

## ☕ DynamoDB Menu Flow

```
Frontend
   ↓
API Gateway
   ↓
Lambda
   ↓
DynamoDB (CafeMenu)
   ↓
Return Menu Data
```

## ☕ DynamoDB Order Tracking Flow

```
Order Created
   ↓
Lambda
   ↓
DynamoDB (CafeOrders)
   ↓
Frontend (Live Status)
```

## ☕ DynamoDB Metrics Flow

```
Order Completed
   ↓
Worker Lambda
   ↓
DynamoDB (Metrics Table)
   ↓
Dashboard (Admin Panel)
```

## ☕ RDS & DynamoDB (COMPARISON FLOW)

```
Frontend
   ↓
API Gateway
   ↓
Lambda
   ↓        ↓
RDS       DynamoDB
(Order DB)   (Menu / Metrics)
   ↓            ↓
Response ← Combined Data
```

## ☕ RDS & DynamoDB (ADVANCED)

```
User places order
   ↓
API Gateway
   ↓
Lambda (validate + price from DynamoDB)
   ↓
Send to SQS
   ↓
Worker Lambda
   ↓
Store in RDS
   ↓
Update DynamoDB (status + metrics)
   ↓
Frontend fetches live status
```

## ☕ DB END-2-END DATA FLOW

```
User
 ↓
CloudFront
 ↓
ALB / API Gateway
 ↓
Lambda
 ↓
 ├── DynamoDB (Menu / Metrics / Orders)
 └── SQS → Worker Lambda → RDS (Final Orders)
 ↓
Response to User
```

## ☕ Secure RDS Access Flow

```
Lambda
   ↓
VPC (Private Subnet)
   ↓
Secrets Manager
   ↓
RDS (Private DB)
```

### ☕ Database Diagrams

### 🗄️ RDS (Relational Database)

```
employees
---------
id (PK)
cognito_user_id (UNIQUE)
name
job_title
salary
start_date
```

#### Relationship:
- Cognito sub → cognito_user_id

### ⚡ DynamoDB Tables

#### 1. CafeOrders

```
PK: order_id

Attributes:
- table_number
- item
- quantity
- total_amount
- payment_method
- payment_status
- status
- created_at
```

#### 2. CafeMenu

```
PK: item_name

Attributes:
- base_cost
```

#### 3. CafeOrderMetrics

```
PK: metric

Attributes:
- count
```

#### 4. CafeAttendance

```
PK: employee_id
SK: date

Attributes:
- check_in
- check_out
- role
```
