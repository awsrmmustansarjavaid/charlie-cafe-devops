# ☕ Charlie Cafe — Data Flow Architecture

---

## ☕ 1. Business Data Flow Overview

> *“Charlie Cafe uses a serverless event-driven architecture where API Gateway triggers Lambda functions, SQS decouples processing, and DynamoDB/RDS handle real-time and relational data storage, enabling scalable and real-time order management.”*

---
## ☕ 2. High-Level System Flow

```
Customer places order
        ↓
Frontend sends request
        ↓
API Gateway
        ↓
Lambda (Order Processor)
        ↓
SQS Queue (buffer)
        ↓
Worker Lambda
        ↓
--------------------------------
| Store Data                   |
| → DynamoDB (orders)         |
| → RDS (payments/employees)  |
--------------------------------
        ↓
Update Metrics (DynamoDB)
        ↓
Frontend Dashboard (Live Data)
```

# ☕ 3. System Architecture Breakdown

---

## ☕ 3.1 Client Layer (Order Placement)

### 👤 Customer Interaction

- Customer places order via frontend application  
- Frontend sends HTTP request to backend API  

---

## ☕ 3.2 API Gateway Layer

### 🚪 Entry Point

Amazon API Gateway receives all incoming requests and acts as:

- Secure API entry point  
- Request router  
- Traffic controller  

---

## ☕ 3.3 Serverless Processing Layer

### ⚙️ Lambda — Order Processor

Triggered by Amazon API Gateway.

#### Responsibilities:
- Validate incoming order  
- Process business logic  
- Forward request to queue (SQS)  

---

## ☕ 3.4 Decoupling Layer (Message Queue)

### 📦 Amazon SQS

Stores order messages temporarily and ensures:

- High scalability  
- Fault tolerance  
- Asynchronous processing  

---

## ☕ 3.5 Background Worker Layer

### 🤖 Worker Lambda

Consumes messages from SQS and executes backend workflows:

- Order confirmation  
- Payment processing logic  
- Data transformation for storage  

---

## ☕ 3.6 Data Persistence Layer

### 🗄️ Storage Systems

---

### 📊 Amazon DynamoDB

Stores:

- Live orders  
- Real-time status updates  
- Dashboard metrics  

✔ Optimized for fast reads and writes  

---

### 🗃️ Amazon RDS (MySQL)

Stores structured relational data:

- Payments  
- Employee records  
- Financial transactions  

---

## ☕ 3.7 Metrics & Analytics Layer

### 📈 Real-Time Insights

Order status updates stored in DynamoDB enable:

- Live tracking dashboard  
- Sales analytics  
- Operational monitoring  

---

## ☕ 3.8 Frontend Dashboard Layer

### 🖥️ Live UI System

Frontend continuously fetches updated data and displays:

- Live order status  
- Sales performance metrics  
- Operational updates  
- Real-time cafe activity  

---

## ☕ 4. Key Architecture Principles

---

### ⚡ Scalability

- SQS + Lambda enables horizontal scaling  

---

### 🔄 Decoupling

- Independent services reduce system dependency  

---

### 📡 Real-Time Processing

- DynamoDB enables instant updates  

---

### 🧩 Microservices Approach

- Each Lambda handles a single responsibility  

---
---
---
# ☕ Charlie Cafe — Complete Architecture Data Flow Diagram

---

## ☕ System Architecture Overview

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

# ☕ Charlie Cafe — System Architecture Layers

---

## ☕ 1. User Interaction Layer

### 👤 Client Access Layer

- Users access the system via **Browser or Mobile Application**
- All requests originate from the frontend (UI layer)
- This is the **entry point of the entire system**

---

## ☕ 2. Content Delivery & Security Layer

### 🌐 Amazon CloudFront (CDN)

CloudFront handles:

- ⚡ Low latency content delivery  
- 🔒 HTTPS security enforcement  
- 🌍 Global caching for faster response  

✔ Improves performance and reduces backend load

---

## ☕ 3. Traffic Management Layer

### 🚦 Application Load Balancer (ALB)

ALB is responsible for:

- Distributing incoming traffic across services  
- Ensuring high availability  
- Providing fault tolerance  

✔ Acts as a smart traffic controller

---

## ☕ 4. Frontend Hosting Layer

### 🖥️ Frontend Application Layer

ALB forwards requests to frontend hosted on:

- 🟧 Amazon EC2 instances OR  
- 🐳 Amazon ECS Docker containers  

### Responsibilities:
- UI rendering  
- User interaction handling  
- Sending API requests to backend  

---

## ☕ 5. API Layer (Backend Entry Point)

### 🚪 Amazon API Gateway

API Gateway acts as:

- Secure API entry point  
- Request validator  
- Routing layer to backend services  

✔ Ensures controlled access to backend systems

---

## ☕ 6. Serverless Processing Layer

### ⚙️ AWS Lambda Functions

Triggered by Amazon API Gateway.

### Responsibilities:
- Business logic execution  
- Request processing  
- Event-driven operations  

✔ Fully serverless and auto-scaling

---

## ☕ 7. Backend Data & Messaging Layer

---

### 📦 Amazon SQS (Order Queue)

**Features:**
- Asynchronous order processing  
- System decoupling  
- Scalability under high load  

---

### 📊 Amazon DynamoDB (NoSQL Database)

**Stores:**
- Menu data  
- Orders  
- Real-time metrics  

✔ Optimized for fast read/write operations

---

### 🗃️ Amazon RDS MySQL (Relational Database)

**Stores structured business data:**
- Payments  
- Customer records  
- Employee information  

✔ Ensures relational consistency and transactional safety

---

### 🔐 AWS Secrets Manager

**Secures:**
- Database credentials  
- API keys  
- Sensitive configuration data  

✔ Prevents hardcoding of secrets in code

---

## ☕ 8. Monitoring & Logging Layer

### 📡 Amazon CloudWatch

CloudWatch collects and monitors:

- Logs  
- Metrics  
- System performance data  

### Used for:
- Debugging issues  
- System health monitoring  
- Alerts and alarms  

---

## ☕ 9. Key Architecture Principles

---

### ⚡ Scalability
- SQS + Lambda enables automatic horizontal scaling  

---

### 🔄 Decoupling
- Each service operates independently  

---

### 📡 Real-Time Processing
- DynamoDB enables instant updates for live dashboards  

---

### 🧩 Microservices Approach
- Each Lambda function handles a single responsibility  

---

### 🔐 Security First Design
- Secrets Manager protects sensitive credentials  
- CloudFront + HTTPS ensures secure communication  

---

## ☕ Final Summary

Charlie Cafe is a **modern cloud-native serverless architecture** designed with:

- High scalability  
- Real-time processing  
- Secure API communication  
- Event-driven microservices  
- Production-grade AWS DevOps design  

----
----
----


