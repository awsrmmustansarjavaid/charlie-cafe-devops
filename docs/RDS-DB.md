# Charlie Cafe - RDS Database

### ✅ use:

- AWS RDS (your real database)

- Your app container connects to RDS

### 🔥 ARCHITECTURE

```
Browser → Apache/PHP (Docker) → AWS RDS (MySQL)
```

### ✅ ✅ FINAL SPLIT (PRODUCTION STYLE)

You will have:

```
schema.sql   → structure (DB + tables)
data.sql     → sample/test data
verify.sql   → testing + analytics
```

### 1. What is schema.sql (Simple Explanation)

#### 👉 A schema.sql file is:

A pure SQL file that defines your database structure (DB + tables + relationships)

### ✅ Why it’s important

| Without schema.sql      | With schema.sql   |
| ----------------------- | ----------------- |
| Manual setup            | One command setup |
| Hard to reuse           | Easy reuse        |
| Not DevOps friendly     | Industry standard |
| Hidden logic in scripts | Clean separation  |

### 🔥 2. Difference: Bash Script vs schema.sql

#### Your Bash script:

- Connects to AWS

- Fetches secrets

- Runs SQL

#### 👉 But DevOps best practice:

- Bash = automation

- SQL file = database definition

### 📁 1. schema.sql (STRUCTURE ONLY)

- Creates database if not exists → safe for repeated runs

- Creates all tables with proper primary keys

- Creates foreign keys for relationships (attendance, leaves)

- Uses IF NOT EXISTS → prevents errors if re-run

- Sets UTF8MB4 charset → supports emojis and special chars

#### 👉 This is the MOST IMPORTANT file

```
-- ==========================================================
-- ☕ Charlie Cafe — DATABASE SCHEMA
-- Purpose: Create DB + Tables + Relationships
-- Safe: YES (uses IF NOT EXISTS)
-- ==========================================================

-- =============================
-- CREATE DATABASE
-- =============================
CREATE DATABASE IF NOT EXISTS cafe_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE cafe_db;

-- =============================
-- EMPLOYEES TABLE
-- =============================
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) UNIQUE,
    name VARCHAR(100),
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================
-- ATTENDANCE TABLE
-- =============================
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    attendance_date DATE,
    checkin_time TIME,
    checkout_time TIME,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- =============================
-- LEAVES TABLE
-- =============================
CREATE TABLE IF NOT EXISTS leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    leave_date DATE,
    leave_type VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- =============================
-- HOLIDAYS TABLE
-- =============================
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE UNIQUE,
    description VARCHAR(100)
);

-- =============================
-- ORDERS TABLE
-- =============================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_number INT,
    customer_name VARCHAR(100),
    item VARCHAR(100),
    quantity INT,
    total_cost DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_status VARCHAR(20),
    status VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 📁 2. data.sql (SAMPLE DATA)

- Seeding test/sample data for QA or demo

- Can run safely without breaking schema (INSERT IGNORE)

```
-- ==========================================================
-- ☕ Charlie Cafe — SAMPLE DATA
-- Purpose: Insert test data
-- Safe: YES (uses INSERT IGNORE)
-- ==========================================================

USE cafe_db;

-- =============================
-- EMPLOYEES
-- =============================
INSERT IGNORE INTO employees
(cognito_user_id,name,job_title,salary,start_date)
VALUES
('emp-001','Ahmed','Barista',800,'2024-01-01'),
('emp-002','Hassan','Cashier',750,'2024-02-01');

-- =============================
-- ATTENDANCE
-- =============================
INSERT IGNORE INTO attendance
(employee_id,attendance_date,checkin_time,checkout_time)
VALUES
(1,CURDATE(),'09:00:00','17:00:00'),
(2,CURDATE(),'09:15:00','17:00:00');

-- =============================
-- LEAVES
-- =============================
INSERT IGNORE INTO leaves
(employee_id,leave_date,leave_type)
VALUES
(1,'2026-03-01','Sick Leave');

-- =============================
-- HOLIDAYS
-- =============================
INSERT IGNORE INTO holidays
(holiday_date,description)
VALUES
('2026-12-25','Christmas'),
('2026-01-01','New Year');

-- =============================
-- ORDERS
-- =============================
INSERT IGNORE INTO orders
(table_number,customer_name,item,quantity,total_cost,total_amount,payment_status,status)
VALUES
(1,'Ali Khan','Espresso',2,4.00,8.00,'PAID','COMPLETED'),
(2,'Sara Ahmed','Cappuccino',1,3.50,5.00,'PAID','COMPLETED'),
(3,'Omar Ali','Latte',1,3.00,5.00,'PENDING','RECEIVED');
```

### 📁 3. verify.sql (TESTING + ANALYTICS)

- Verification after deployment

- Checks: tables, relationships, indexes, row counts, analytics (today/week/month sales)

```
-- ==========================================================
-- ☕ Charlie Cafe — VERIFICATION & ANALYTICS
-- ==========================================================

USE cafe_db;

-- =============================
-- CHECK DATABASE
-- =============================
SELECT DATABASE();

-- =============================
-- SHOW TABLES
-- =============================
SHOW TABLES;

-- =============================
-- DESCRIBE TABLES
-- =============================
DESCRIBE employees;
DESCRIBE attendance;
DESCRIBE leaves;
DESCRIBE holidays;
DESCRIBE orders;

-- =============================
-- VIEW DATA
-- =============================
SELECT * FROM employees;
SELECT * FROM attendance;
SELECT * FROM leaves;
SELECT * FROM holidays;
SELECT * FROM orders;

-- =============================
-- FOREIGN KEYS CHECK
-- =============================
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'cafe_db'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- =============================
-- INDEX CHECK
-- =============================
SHOW INDEX FROM orders;

-- =============================
-- ROW COUNT CHECK
-- =============================
SELECT
(SELECT COUNT(*) FROM orders) AS total_orders,
(SELECT COUNT(*) FROM employees) AS total_employees,
(SELECT COUNT(*) FROM attendance) AS total_attendance,
(SELECT COUNT(*) FROM holidays) AS total_holidays;

-- =============================
-- ANALYTICS
-- =============================

-- Paid Orders
SELECT COUNT(*) AS paid_orders
FROM orders
WHERE payment_status='PAID';

-- Today Sales
SELECT COUNT(*) AS today_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= CURDATE();

-- Week Sales
SELECT COUNT(*) AS week_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= NOW() - INTERVAL 7 DAY;

-- Month Sales
SELECT COUNT(*) AS month_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= DATE_FORMAT(NOW(),'%Y-%m-01');
```

### 🎯 WHY schema.sql IS IMPORTANT (VERY IMPORTANT)

#### Think like DevOps:

| File       | Purpose                                       |
| ---------- | --------------------------------------------- |
| schema.sql | Structure (like building foundation of house) |
| data.sql   | Furniture (test/sample data)                  |
| verify.sql | Inspection (QA/testing)                       |

### ⚙️ HOW IT WORKS (STEP BY STEP)

### ✅ Step 1 — Create schema

```
mysql -h <host> -u <user> -p < schema.sql
```

#### 👉 Creates:

- database

- tables

- relationships

### ✅ Step 2 — Insert data

```
mysql -h <host> -u <user> -p < data.sql
```

### ✅ Step 3 — Verify

```
mysql -h <host> -u <user> -p < verify.sql
```

### 🔥 PRO TIP (IMPORTANT FOR YOU)

#### You can now simplify your bash script like this:

```
mysql --defaults-extra-file="$CREDENTIALS_FILE" < schema.sql
mysql --defaults-extra-file="$CREDENTIALS_FILE" < data.sql
mysql --defaults-extra-file="$CREDENTIALS_FILE" < verify.sql
```

### 🚀 REAL-WORLD BENEFITS

This is why companies do this:

#### ✅ 1. Version Control (GitHub)

- Track DB changes like code

#### ✅ 2. Easy Deployment

#### Run same schema on:

- Dev

- Staging

- Production

#### ✅ 3. Debugging

Fix errors like:

- Unknown column 'payment_method'

👉 by editing schema.sql only

#### ✅ 4. Automation (CI/CD)

Used in:

- AWS CodePipeline

- Terraform

- Docker

### ⚠️ IMPORTANT OBSERVATION (FROM YOUR ERROR)

You got:

```
Unknown column 'payment_method'
```

#### 👉 That means:

- Your Lambda expects column

- But schema.sql doesn't have it

If needed, we can upgrade schema.sql safely (next step).


### 🌐 How to run your current files in production without Docker/CI/CD

```
# Connect to RDS
mysql -h <RDS_HOST> -u <USER> -p < schema.sql    # Create DB and tables
mysql -h <RDS_HOST> -u <USER> -p < data.sql      # Optional: seed data
mysql -h <RDS_HOST> -u <USER> -p < verify.sql    # QA check
```

✅ This is safe and works now.

### 🌐 How to integrate schema.sql, data.sql, verify.sql into Docker + CI/CD

Since you already have:

```
charlie-cafe-devops/
├── docker/
│   └── mysql/
│       └── Dockerfile
├── docker-compose.yml
└── .github/workflows/deploy.yml
```

Here’s the common production-ready pattern:

### Step 1 — Dockerize MySQL for local testing

#### docker/mysql/Dockerfile

```
# -------------------------------------------------
# ☕ Charlie Cafe - MySQL Dockerfile (FINAL)
# Auto DB + Schema + Data Setup
# -------------------------------------------------

FROM mysql:8.0

# -------------------------------------------------
# Environment Variables
# -------------------------------------------------
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=cafe_db

# -------------------------------------------------
# Auto-run SQL files on container startup
# (Executed in alphabetical order)
# -------------------------------------------------
COPY infrastructure/rds/schema.sql /docker-entrypoint-initdb.d/01-schema.sql
COPY infrastructure/rds/data.sql /docker-entrypoint-initdb.d/02-data.sql

# -------------------------------------------------
# Expose MySQL port
# -------------------------------------------------
EXPOSE 3306
```

- MySQL image runs the scripts automatically on first container startup.

- verify.sql is not copied — you run it manually or via CI/CD test.


### 🧱 docker-compose.yml (VERY IMPORTANT)

```
version: "3.8"

services:

  web:
    build:
      context: .
      dockerfile: docker/apache-php/Dockerfile
    container_name: charlie_web
    ports:
      - "8080:80"
    volumes:
      - ./app/frontend:/var/www/html
    environment:
      DB_HOST: your-rds-endpoint.amazonaws.com
      DB_USER: cafe_user
      DB_PASS: StrongPassword123
      DB_NAME: cafe_db
    restart: always
```

### PHP CONNECTION (VERY IMPORTANT)

#### In your PHP files (example: db.php):

```
<?php

$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$pass = getenv('DB_PASS');
$db   = getenv('DB_NAME');

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
```

### 🧱 3. APPLY YOUR SQL FILES TO RDS (ONE TIME)

👉 Use your existing files — no change needed

### ✅ Step 1 — Run schema.sql

```
mysql -h your-rds-endpoint.amazonaws.com -u cafe_user -p < schema.sql
```

### ✅ Step 2 — Run data.sql (optional)

```
mysql -h your-rds-endpoint.amazonaws.com -u cafe_user -p < data.sql
```

### ✅ Step 3 — Verify

```
mysql -h your-rds-endpoint.amazonaws.com -u cafe_user -p < verify.sql
```

### Step 2 — Add verify.sql to CI/CD for QA

#### .github/workflows/deploy.yml

```
name: ☕ Charlie Cafe DevOps CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    # -------------------------------------------------
    # MySQL Service (for testing DB schema)
    # -------------------------------------------------
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: rootpassword
          MYSQL_DATABASE: cafe_db
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping -h localhost -uroot -prootpassword --silent"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

    steps:

    # -------------------------------------------------
    # Checkout Code
    # -------------------------------------------------
    - name: 📥 Checkout Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # Install MySQL Client
    # -------------------------------------------------
    - name: 🧰 Install MySQL Client
      run: sudo apt-get update && sudo apt-get install -y mysql-client

    # -------------------------------------------------
    # Wait for MySQL to be ready
    # -------------------------------------------------
    - name: ⏳ Wait for MySQL
      run: |
        until mysqladmin ping -h 127.0.0.1 -uroot -prootpassword --silent; do
          echo "Waiting for MySQL..."
          sleep 5
        done

    # -------------------------------------------------
    # Apply Database Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # Apply Sample Data
    # -------------------------------------------------
    - name: 📊 Apply Sample Data
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/data.sql

    # -------------------------------------------------
    # Run Verification Tests (QA)
    # -------------------------------------------------
    - name: ✅ Run DB Verification
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # Build Docker Image (PHP + Apache)
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # Run Container (Test)
    # -------------------------------------------------
    - name: 🚀 Run Docker Container
      run: docker run -d -p 8080:80 charlie-cafe

    # -------------------------------------------------
    # Basic Health Check
    # -------------------------------------------------
    - name: 🌐 Test Web Server
      run: |
        sleep 10
        curl -I http://localhost:8080 || exit 1

    # -------------------------------------------------
    # Success
    # -------------------------------------------------
    - name: 🎉 Deployment Success
      run: echo "Charlie Cafe CI/CD Pipeline Successful 🚀"
```

### 🧠 IMPORTANT: YOUR SQL FILES STATUS

### 👉 GOOD NEWS:

Your files are already correct and production-ready ✅
No modification required.

### ⚠️ BUT ONE CRITICAL FIX (VERY IMPORTANT)

You previously got:

```
Unknown column 'payment_method'
```

👉 If your app/Lambda uses it → update schema:

### ✅ MODIFY orders table

```
ALTER TABLE orders
ADD COLUMN payment_method VARCHAR(20);
```

OR update schema.sql permanently:

```
payment_method VARCHAR(20),
```

### 🔐 4. SECURITY CHECK (VERY IMPORTANT)

In your RDS Security Group:

#### ✅ Allow:

```
Port: 3306
Source: EC2-Web-SG
Source: Lambda-SG
```

#### ❌ DO NOT allow:

```
0.0.0.0/0   ❌ (public access)
```

### 🧪 5. TEST FULL FLOW

- Step 1

```
docker-compose up -d
```

- Step 2

`- Open:

```
http://localhost:8080
```

- Step 3

  - Trigger:

    - Order page

    - API

    - Lambda

👉 Data should go to RDS

### 🧠 HOW EVERYTHING WORKS (IMPORTANT)

#### 🔹 Docker Flow

- Start MySQL container

- MySQL auto-runs:

    - schema.sql

    - data.sql

- Database ready

####  🔹CI/CD Flow

- GitHub push

- MySQL container starts

- schema.sql runs

- data.sql runs

- verify.sql tests everything

### 🏆 FINAL RESULT

You now have:

✅ Production-style schema

✅ Docker local environment

✅ Auto DB setup

✅ CI/CD validation

✅ Clean DevOps structure

✅ Docker for app only

✅ AWS RDS as database

✅ Clean production architecture

✅ Secure connection

✅ Reusable SQL schema




