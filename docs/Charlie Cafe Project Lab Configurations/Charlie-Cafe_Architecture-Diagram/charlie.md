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
SQS Queue (Buffer / Decoupling Layer)
        ↓
Worker Lambda
        ↓
────────────────────────────────────
| Data Storage Layer              |
| → DynamoDB (Orders / Metrics)   |
| → RDS MySQL (Payments / Users)  |
────────────────────────────────────
        ↓
Real-time Metrics Update (DynamoDB)
        ↓
Frontend Dashboard (Live Data View)
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