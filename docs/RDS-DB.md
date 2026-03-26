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






