# ☕ Charlie Cafe Data Flow

## ☕ Charlie Cafe Business Data Flow

> #### “Charlie Cafe uses a serverless event-driven architecture where API Gateway triggers Lambda functions, SQS decouples processing, and DynamoDB/RDS handle real-time and relational data storage, enabling scalable and real-time order management.”






















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
