# ☕ Charlie Cafe Data Flow

## ☕ Charlie Cafe Business Data Flow

> #### “Charlie Cafe uses a serverless event-driven architecture where API Gateway triggers Lambda functions, SQS decouples processing, and DynamoDB/RDS handle real-time and relational data storage, enabling scalable and real-time order management.”




















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

