# ☕ Charlie Cafe Data Flow

## ☕ Charlie Cafe Business Data Flow

> #### “Charlie Cafe uses a serverless event-driven architecture where API Gateway triggers Lambda functions, SQS decouples processing, and DynamoDB/RDS handle real-time and relational data storage, enabling scalable and real-time order management.”






















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
