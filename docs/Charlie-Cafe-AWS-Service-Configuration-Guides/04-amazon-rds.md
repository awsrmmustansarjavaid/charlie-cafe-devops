# Charlie Cafe — Amazon RDS Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon RDS.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

## ✅ Prerequisites

* AWS Account (EC2, VPC, IAM, Secrets Manager, Lambda , RDS, CloudFront, S3 )
* Basic Linux commands
* PHP + MySQL knowledge
* SSH client or Cloud9

---

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


# 3️⃣ Install PHP + MySQL Support

# 5️⃣ Install MySQL Client (MariaDB)

# LAMP Stack Quick Verification Script (Apache + PHP + MySQL client)

# ── 3. MySQL client installed? ────────────────────────────────────────
echo -n "3. MySQL client command ........................... "
if command -v mysql >/dev/null 2>&1; then
    MYSQL_VER=$(mysql --version 2>/dev/null | head -n1)
    ok "mysql client found ($MYSQL_VER)"
else
    fail "mysql client not found"
    ((FAILURES++))
fi


## 📢 SECTION 2️⃣ CAFE DATABASE CONFIGURATIONS


## PHASE 1️⃣ — Basic RDS CONFIGURATIONS


### 1️⃣ Create DB Subnet Group
AWS Console → RDS → Subnet groups → Create

- Name: CafeRDSSubnetGroup

- VPC: CafeDevVPC

- Subnets: **PRIVATE subnets (2 AZs)**

- **✔️ Create**


### 2️⃣ Create Security Group for RDS
VPC → Security Groups → Create

- Name: CafeRDS-SG

- Inbound:
  - MySQL/Aurora (3306) → Source: Lambda-SG
  - MySQL/Aurora (3306) → Source: EC2-Web-SG
- Outbound: All

- **✔️ Create**


### 3️⃣ Create RDS Instance

RDS → Databases → Create database

- Engine: MySQL (or MariaDB)

- Template: Free tier

- DB identifier: cafedb

- Username: cafe_user

- Password: StrongPassword123

- VPC: CafeDevVPC

- Subnet group: CafeRDSSubnetGroup

- Public access: ❌ No

- Security group: CafeRDS-SG

- Backup: Enabled

- **✔️ Create database ⏳**

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## PHASE 2️⃣ — Basic RDS Schema CONFIGURATIONS

Read more about Charlie Cafe RDS

[Charlie Cafe RDS](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Charlie%20Cafe%20%20RDS%20Project.md)


# ☕ AWS Charlie Café – RDS Database Setup Guide


### 1️⃣ Project Overview

This document explains how to configure the Amazon RDS MySQL database for the Charlie Café cloud system, including:

- Orders Management

- HR Management

- Attendance System

- Holiday Tracking

- Test Data for Development


### 🍽️  2️⃣ AWS RDS Initial Configuration


### 1️⃣ Install MySQL Client on EC2

```
sudo dnf install -y mariadb105
```


#### ✅ Verify Installation

```
mysql --version
```


#### ✅ Connect to AWS RDS

```
mysql -h <rds-endpoint> -u cafe_user -p
```


### 3️⃣ Create Charlie Café Database

```
CREATE DATABASE cafe_db;
```


#### ✅ Create Database User

```
CREATE USER 'cafe_user'@'%' IDENTIFIED BY 'StrongPassword123';
```


#### ✅ Grant Permissions

```
GRANT ALL PRIVILEGES ON cafe_db.* TO 'cafe_user'@'%';
```

```
FLUSH PRIVILEGES;
```


#### ✅ Use the Database

```
USE cafe_db;
```


### 🍽️ 4️⃣ Orders Management Database Schema


### 1️⃣ Simple Orders Table (Basic Version)

```sql
CREATE TABLE orders (
 id INT AUTO_INCREMENT PRIMARY KEY,
 customer_name VARCHAR(100),
 item VARCHAR(50),
 quantity INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

This is the basic table for storing orders.


### 2️⃣ Recommended Orders Table (With Table Number - Recommanded)

```
CREATE TABLE orders (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_number    INT NOT NULL,                    -- ← Added: table number (1, 2, 3, ...)
    customer_name   VARCHAR(100),
    item            VARCHAR(50),
    quantity        INT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_table_number (table_number),           -- optional: faster queries by table
    INDEX idx_created_at (created_at)                -- optional: good for time-based reports
);
```


#### Advantages:

- Track which table placed the order

- Faster table based search

- Useful for restaurant reporting


### 3️⃣ Add Advanced Order Management Columns

- Run this in AWS RDS Query Editor.

```
ALTER TABLE orders
ADD COLUMN order_id VARCHAR(50),
ADD COLUMN status VARCHAR(20) DEFAULT 'RECEIVED',
ADD COLUMN total_amount DECIMAL(10,2),
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
```


#### ✅ New Columns:

| Column       | Purpose                              |
| ------------ | ------------------------------------ |
| order_id     | Unique public order number           |
| status       | RECEIVED / PREPARING / SERVED / PAID |
| total_amount | Total bill amount                    |
| updated_at   | Track order updates                  |


### ✅ 📦 Standard Order ID Format

```
ORD-YYYYMMDD-XXXX
```


#### ✅ Example:

```
ORD-20260114-8392
```

#### 4️⃣ Add Payment and Timestamp Columns

```
ALTER TABLE orders
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
```

```
ALTER TABLE orders
ADD COLUMN payment_status VARCHAR(20) DEFAULT 'PENDING';
```


#### Payment Status:

- PENDING

- PAID

- CANCELLED


### 🍽️ Final Merged RDS Query (Recommended Production Version)

Instead of running multiple queries, you can create the complete table in one query.

```
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    order_id VARCHAR(50),
    
    table_number INT NOT NULL,
    
    customer_name VARCHAR(100),
    
    item VARCHAR(50),
    
    quantity INT NOT NULL,
    
    total_amount DECIMAL(10,2),
    
    status VARCHAR(20) DEFAULT 'RECEIVED',
    
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
    ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_table_number (table_number),
    INDEX idx_created_at (created_at),
    INDEX idx_order_id (order_id)
);
```


#### ✅ Final Table Structure

| Column         | Type              |
| -------------- | ----------------- |
| id             | INT (Primary Key) |
| order_id       | VARCHAR           |
| table_number   | INT               |
| customer_name  | VARCHAR           |
| item           | VARCHAR           |
| quantity       | INT               |
| total_amount   | DECIMAL           |
| status         | VARCHAR           |
| payment_status | VARCHAR           |
| created_at     | DATETIME          |
| updated_at     | TIMESTAMP         |


### 5️⃣ 🍽️ Charlie Café – HR Database Schema (AWS RDS)


### 1️⃣ Create employees Table

```
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```


#### ✅ Purpose of Columns

| Column          | Purpose                  |
| --------------- | ------------------------ |
| cognito_user_id | Maps to Cognito JWT user |
| employee_id     | Internal employee ID     |
| salary          | HR confidential data     |
| created_at      | Audit log                |


### 2️⃣ Create attendance Table

```
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    checkin_time TIME,
    checkout_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, attendance_date),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```


#### ✅ Key points

- UNIQUE(employee_id, attendance_date)

- Prevents double check-in per day

- checkin_time and checkout_time separated

- Foreign key ensures valid employee


### 3️⃣ Create leaves Table

```
CREATE TABLE leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE NOT NULL,
    leave_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```


### 4️⃣ Create holidays Table

```
CREATE TABLE holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```


### 6️⃣ 🍽️ Charlie Café – insert manually (CLI)


### 1️⃣ Manual Orders Test (CLI)


### 1️⃣ Simple Insert

```
INSERT INTO orders (customer_name, item, quantity)
VALUES ('CLI-Test', 'Coffee', 1);
```


### 2️⃣ Multi Order Insert

```
INSERT INTO orders (table_number, customer_name, item, quantity) 
VALUES 
(1, 'Ali Khan', 'Espresso', 2),
(1, 'Sara Ahmed', 'Cappuccino', 1),
(2, 'CLI-Test', 'Coffee', 1),
(3, NULL, 'Latte', 3),
(5, 'Ahmed Raza', 'Croissant + Tea', 1);
```


### 2️⃣ Manual HR Test (CLI)


### 1️⃣ Insert Holidays

```
INSERT INTO holidays (holiday_date, description)
VALUES
('2026-01-01', 'New Year'),
('2026-03-23', 'Pakistan Day'),
('2026-12-25', 'Christmas');
```


### 2️⃣ Insert Employees (Manual Testing)

```
INSERT INTO employees 
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('cognito-001', 'Ali Khan', 'Barista', 45000, '2025-05-01'),
('cognito-002', 'Sara Ahmed', 'Cashier', 42000, '2025-06-15'),
('cognito-003', 'Ahmed Raza', 'Manager', 65000, '2024-12-01');
```


### 3️⃣ Insert Attendance

```
INSERT INTO attendance
(employee_id, attendance_date, checkin_time)
VALUES
(1, '2026-03-05', '09:00:00'),
(2, '2026-03-05', '09:10:00'),
(3, '2026-03-05', '08:50:00');
```


### 7️⃣ Database Verification Queries

Run these queries to verify the database.


### 1️⃣ Verify Database Exists

```
SHOW DATABASES;
```


#### ✅ Expected output should include:

```
cafe_db
```


### 2️⃣ Verify Current Database

```
SELECT DATABASE();
```


#### ✅ Expected result:

```
cafe_db
```


### 3️⃣ Verify All Tables

```
SHOW TABLES;
```


#### ✅ Expected result:

```
orders
employees
attendance
leaves
holidays
```


### 4️⃣ Verify Table Structure


### 1️⃣ Orders Table

```
DESCRIBE orders;
```

or 

```
SHOW CREATE TABLE orders;
```


#### ✅ Expected result:

```
id
order_id
table_number
customer_name
item
quantity
total_amount
status
payment_status
created_at
updated_at
```


### 2️⃣ Verify Orders

```
SELECT * FROM orders;
```


### 3️⃣ Employees Table

```
DESCRIBE employees;
```


#### ✅ Expected result:

```
employee_id
cognito_user_id
name
job_title
salary
start_date
created_at
```


### 4️⃣ Verify Employees

```
SELECT * FROM employees;
```


### 5️⃣ Attendance Table

```
DESCRIBE attendance;
```


#### ✅ Expected result:

```
attendance_id
employee_id
attendance_date
checkin_time
checkout_time
created_at
```


### 6️⃣ Verify Attendance

```
SELECT * FROM attendance;
```


### 7️⃣ Verify Holidays

```
SELECT * FROM holidays;
```


#### ✅ Expected Result

You should see:

- Orders inserted successfully

- Employees listed

- Attendance records created

- Holiday data visible


### 8️⃣ Verify Foreign Keys

Check if attendance → employees relation exists.

```
SELECT
TABLE_NAME,
COLUMN_NAME,
CONSTRAINT_NAME,
REFERENCED_TABLE_NAME
FROM
information_schema.KEY_COLUMN_USAGE
WHERE
TABLE_SCHEMA = 'cafe_db'
AND REFERENCED_TABLE_NAME IS NOT NULL;
```


#### ✅ Expected Result

```
attendance.employee_id → employees.employee_id
```


### 9️⃣ Verify Indexes (Performance Check)

Indexes improve query speed in AWS RDS.

Check Orders Indexes

```
SHOW INDEX FROM orders;
```


#### ✅ Expected Result

```
PRIMARY
idx_table_number
idx_created_at
idx_order_id
```


### 🔟 Verify Row Counts (Quick Health Check)

```
SELECT
(SELECT COUNT(*) FROM orders) AS total_orders,
(SELECT COUNT(*) FROM employees) AS total_employees,
(SELECT COUNT(*) FROM attendance) AS total_attendance,
(SELECT COUNT(*) FROM holidays) AS total_holidays;
```


#### ✅ Expected Result

```
total_orders      8
total_employees   3
total_attendance  3
total_holidays    3
```


### 1️⃣1️⃣ Functional Query Tests


### 1️⃣ Orders by Table

```
SELECT table_number, COUNT(*) AS total_orders
FROM orders
GROUP BY table_number;
```


### 2️⃣ Daily Orders

```
SELECT DATE(created_at) AS order_day, COUNT(*) AS orders
FROM orders
GROUP BY order_day;
```


### 3️⃣ Employees Attendance

```
SELECT 
e.name,
a.attendance_date,
a.checkin_time
FROM attendance a
JOIN employees e
ON a.employee_id = e.employee_id;
```


### 4️⃣ Payment Verification

```
SELECT
payment_status,
COUNT(*) AS total_orders
FROM orders
GROUP BY payment_status;
```


#### ✅ Expected Result

```
PENDING 5
PAID    3
```


### 1️⃣2️⃣ Data Integrity Test

Test foreign key protection.

Run:

```
INSERT INTO attendance
(employee_id, attendance_date, checkin_time)
VALUES
(999, '2026-03-08', '09:00:00');
```


#### ✅ Expected Result

```
ERROR 1452: Cannot add or update a child row
```

Meaning foreign key works correctly.


### 1️⃣3️⃣ Database Size Verification

```
SELECT
table_schema AS "Database",
SUM(data_length + index_length) / 1024 / 1024 AS "Size_MB"
FROM information_schema.TABLES
WHERE table_schema = "cafe_db"
GROUP BY table_schema;
```


### 1️⃣4️⃣ Full System Health Check (Recommended)

```
SELECT
table_name,
table_rows
FROM information_schema.tables
WHERE table_schema = 'cafe_db';
```


#### ✅ Expected Result

```
orders       10
employees    3
attendance   3
holidays     3
leaves       0
```


### ✅ Final Verification Checklist

| Check                | Query                      |
| -------------------- | -------------------------- |
| Database exists      | `SHOW DATABASES`           |
| Tables created       | `SHOW TABLES`              |
| Table structure      | `DESCRIBE table_name`      |
| Indexes working      | `SHOW INDEX FROM table`    |
| Data inserted        | `SELECT * FROM table`      |
| Foreign keys working | `information_schema` query |
| Row counts           | `COUNT(*)` queries         |


### 💡 Pro Tip (Real AWS DevOps Practice)

Create one quick verification script:

```
SELECT 'orders' AS table_name, COUNT(*) FROM orders
UNION
SELECT 'employees', COUNT(*) FROM employees
UNION
SELECT 'attendance', COUNT(*) FROM attendance
UNION
SELECT 'holidays', COUNT(*) FROM holidays;
```

This gives instant database health summary.
---

## RDS Verification


### 1️⃣ Verify table exists

```
USE cafe_db;
```

```
SHOW TABLES;
```


#### ✅ You should see:

```
orders
employees
attendance
leaves
holidays
```

```
DESCRIBE orders;
```

```
SELECT * FROM orders;
```

```
DESCRIBE employees;
```

```
SELECT * FROM employees;
```

```
DESCRIBE attendance;
```

```
SELECT * FROM attendance;
```

```
DESCRIBE holidays;
```

```
SELECT * FROM holidays;
```

```
DESCRIBE leaves;
```

```
SELECT * FROM leaves;
```


###### ✅ If you see the row → DB is READY


### ✅ Combined RDS Verification Script (One Run)

> #### This is the best single verification script you can run from your EC2 MySQL client.

This gives a single query that verifies:

- Tables exist

- Table structure

- Row counts

- Columns

- Data types

```
USE cafe_db;

-- =========================
-- 1️⃣ Verify tables exist
-- =========================
SHOW TABLES;

-- =========================
-- 2️⃣ Orders table check
-- =========================
SELECT 'orders table structure' AS section;
DESCRIBE orders;

SELECT 'orders sample data' AS section;
SELECT * FROM orders LIMIT 5;

-- =========================
-- 3️⃣ Employees table check
-- =========================
SELECT 'employees table structure' AS section;
DESCRIBE employees;

SELECT 'employees sample data' AS section;
SELECT * FROM employees LIMIT 5;

-- =========================
-- 4️⃣ Attendance table check
-- =========================
SELECT 'attendance table structure' AS section;
DESCRIBE attendance;

SELECT 'attendance sample data' AS section;
SELECT * FROM attendance LIMIT 5;

-- =========================
-- 5️⃣ Holidays table check
-- =========================
SELECT 'holidays table structure' AS section;
DESCRIBE holidays;

SELECT 'holidays sample data' AS section;
SELECT * FROM holidays LIMIT 5;

-- =========================
-- 6️⃣ Leaves table check
-- =========================
SELECT 'leaves table structure' AS section;
DESCRIBE leaves;

SELECT 'leaves sample data' AS section;
SELECT * FROM leaves LIMIT 5;
```


#### ✅ Why this is better

Instead of 10–15 manual commands, you:

- paste one script

- get all verification results

- see clear section labels

- avoid dumping too much data with LIMIT 5


#### ✅ Example Output Sections

You will see results like:

```
SHOW TABLES
orders
employees
attendance
holidays
leaves
```

Then:

```
orders table structure
id
customer_name
order_total
created_at
```

Then:

```
orders sample data
1 | John | 12.50 | 2026-03-10
```


### 🚀 Pro Tip (Good for your Charlie Café DevOps documentation)

Add a comment header like:

```
-- Charlie Café RDS Verification Script
-- Used to verify database migration / deployment
-- Run from EC2 MySQL client
```

This makes your lab documentation look professional.


### 🚀 Advanced RDS Verification Query (Professional Method)

Run this from your EC2 MySQL client.

```
USE cafe_db;

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'cafe_db'
AND TABLE_NAME IN ('orders','employees','attendance','holidays','leaves')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```


#### ✅ What This Verifies

This one query checks the full schema.

Example output:

| TABLE_NAME | COLUMN_NAME   | DATA_TYPE | IS_NULLABLE | COLUMN_KEY |
| ---------- | ------------- | --------- | ----------- | ---------- |
| orders     | id            | int       | NO          | PRI        |
| orders     | customer_name | varchar   | YES         |            |
| employees  | id            | int       | NO          | PRI        |
| attendance | employee_id   | int       | NO          |            |

So you immediately confirm:

✔ tables exist

✔ column structure

✔ data types

✔ primary keys


### 🚀 Optional: Add Row Count Verification (Even Better)

Add this second quick query to verify data exists.

```
SELECT 
table_name,
table_rows
FROM information_schema.tables
WHERE table_schema='cafe_db'
AND table_name IN ('orders','employees','attendance','holidays','leaves');
```


#### Example output:

| table_name | table_rows |
| ---------- | ---------- |
| orders     | 120        |
| employees  | 8          |
| attendance | 340        |
| holidays   | 12         |
| leaves     | 6          |


### 📘 How You Can Document It in Your Lab Notebook

Example note:

```
Step: Verify RDS Database Schema

Command used:

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='cafe_db';

Expected Result:
All required Charlie Café tables appear:
orders
employees
attendance
holidays
leaves

Verification confirms database migration / deployment success.
```


### ⭐ DevOps Tip (Very Useful for Your Project)

Real engineers often run these checks after:

- RDS migration

- database deployment

- CI/CD database pipeline

Tools like:

- Flyway

- Liquibase

- GitHub Actions


### 🚀 Charlie Café – RDS Full Health Check Script

Run this once from your EC2 MySQL client.

```
USE cafe_db;

-- =====================================================
-- Charlie Café RDS Database Health Check
-- =====================================================

-- 1️⃣ Verify required tables exist
SELECT 
TABLE_NAME,
ENGINE,
TABLE_ROWS,
CREATE_TIME,
UPDATE_TIME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA='cafe_db'
AND TABLE_NAME IN ('orders','employees','attendance','holidays','leaves');


-- 2️⃣ Verify table columns and schema
SELECT 
TABLE_NAME,
COLUMN_NAME,
DATA_TYPE,
IS_NULLABLE,
COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='cafe_db'
AND TABLE_NAME IN ('orders','employees','attendance','holidays','leaves')
ORDER BY TABLE_NAME, ORDINAL_POSITION;


-- 3️⃣ Verify indexes (important for performance)
SELECT 
TABLE_NAME,
INDEX_NAME,
COLUMN_NAME,
SEQ_IN_INDEX
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA='cafe_db'
AND TABLE_NAME IN ('orders','employees','attendance','holidays','leaves');


-- 4️⃣ Verify table storage engine
SELECT 
TABLE_NAME,
ENGINE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA='cafe_db';


-- 5️⃣ Verify database size
SELECT 
table_schema AS database_name,
ROUND(SUM(data_length + index_length)/1024/1024,2) AS size_MB
FROM information_schema.tables
WHERE table_schema='cafe_db'
GROUP BY table_schema;


-- 6️⃣ Verify row counts quickly
SELECT 
TABLE_NAME,
TABLE_ROWS
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA='cafe_db'
AND TABLE_NAME IN ('orders','employees','attendance','holidays','leaves');
```


#### ✅ What This Single Script Verifies

| Check           | Purpose                     |
| --------------- | --------------------------- |
| Tables exist    | confirms deployment success |
| Table structure | columns & data types        |
| Indexes         | performance verification    |
| Storage engine  | should usually be InnoDB    |
| Row counts      | confirms data present       |
| Database size   | quick storage monitoring    |


#### 📊 Example Output

Example result from section 1️⃣:

| TABLE_NAME | ENGINE | TABLE_ROWS |
| ---------- | ------ | ---------- |
| orders     | InnoDB | 150        |
| employees  | InnoDB | 8          |
| attendance | InnoDB | 340        |
| holidays   | InnoDB | 12         |
| leaves     | InnoDB | 5          |


### 🚀 Charlie Café RDS PASS / FAIL Health Check

Run this script once from your EC2 MySQL client.

```
USE cafe_db;

SELECT 
'orders table exists' AS check_name,
CASE 
WHEN EXISTS (
SELECT 1 
FROM information_schema.tables 
WHERE table_schema='cafe_db' AND table_name='orders'
)
THEN 'PASS'
ELSE 'FAIL'
END AS status

UNION ALL

SELECT 
'employees table exists',
CASE 
WHEN EXISTS (
SELECT 1 
FROM information_schema.tables 
WHERE table_schema='cafe_db' AND table_name='employees'
)
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'attendance table exists',
CASE 
WHEN EXISTS (
SELECT 1 
FROM information_schema.tables 
WHERE table_schema='cafe_db' AND table_name='attendance'
)
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'holidays table exists',
CASE 
WHEN EXISTS (
SELECT 1 
FROM information_schema.tables 
WHERE table_schema='cafe_db' AND table_name='holidays'
)
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'leaves table exists',
CASE 
WHEN EXISTS (
SELECT 1 
FROM information_schema.tables 
WHERE table_schema='cafe_db' AND table_name='leaves'
)
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'orders table has data',
CASE 
WHEN (SELECT COUNT(*) FROM orders) > 0
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'employees table has data',
CASE 
WHEN (SELECT COUNT(*) FROM employees) > 0
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'attendance table has data',
CASE 
WHEN (SELECT COUNT(*) FROM attendance) > 0
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'holidays table has data',
CASE 
WHEN (SELECT COUNT(*) FROM holidays) > 0
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'leaves table has data',
CASE 
WHEN (SELECT COUNT(*) FROM leaves) > 0
THEN 'PASS'
ELSE 'FAIL'
END;
```


#### 📊 Example Output

| check_name                | status |
| ------------------------- | ------ |
| orders table exists       | PASS   |
| employees table exists    | PASS   |
| attendance table exists   | PASS   |
| holidays table exists     | PASS   |
| leaves table exists       | PASS   |
| orders table has data     | PASS   |
| employees table has data  | PASS   |
| attendance table has data | PASS   |
| holidays table has data   | PASS   |
| leaves table has data     | PASS   |

If something is wrong you will immediately see:

```
employees table exists | FAIL
```


### 📘 How to Write This in Your Lab Documentation

Example documentation note:

```
Step: Charlie Café RDS Deployment Verification

Executed DevOps validation script from EC2 MySQL client.

Verification checks:
• Table existence
• Data presence
• Database integrity

Result:
All health checks returned PASS confirming successful database deployment on Amazon RDS.
```


### ⭐ Why This Looks Very Professional

This type of PASS / FAIL verification is used in real pipelines with tools like:

- Jenkins

- GitHub Actions

- Terraform

Example pipeline:

```
Deploy Infrastructure
      ↓
Deploy Lambda APIs
      ↓
Run RDS health check
      ↓
PASS → Deployment Success
```


#### 🚀 If you want, I can also give you a “1 command DevOps script” (EXTREMELY COOL) that prints a Charlie Café database dashboard like this:

```
DATABASE HEALTH REPORT
----------------------
Tables: 5
Rows: 512
Indexes: OK
Engine: InnoDB
Database Size: 12 MB
Status: HEALTHY
```

This kind of database health report makes DevOps portfolios look very advanced.
---


### 1️⃣ Create Schema in RDS

- **✔️ Connect from EC2:**


### 2️⃣ — Basic RDS CONFIGURATIONS


#### 1️⃣ Verify mysql

```
mysql --version
```


#### 2️⃣ Login to MariaDB:

> **🛠️ BASH SCRIPT (Safe RDS Connection)**

> **📄 connect-rds.sh**

```
sudo nano connect-rds.sh
```

[RDS Credentials to Secrets Manager ](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/AWS%20RDS%20Bash%20Scripts/connect-rds.sh)

```
#!/bin/bash


# CONNECT TO MYSQL (NO DB NAME)

# ===============================

echo "✅ Connecting to RDS MySQL (no database selected)..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS"
```

```
sudo chmod +x connect-rds.sh
```

```
sudo ./connect-rds.sh
```


### 3️⃣ Create cafe_db & Tables


#### ✅ Charlie Cafe – Order Processing & HR Schema Setup + Verification

> **File name: setup_charlie_cafe_db_full.sh**

✔️ Pulls DB creds from AWS Secrets Manager

✔️ Connects to RDS MySQL

✔️ Creates database

✔️ Creates orders + HR tables

✔️ Adds indexes

✔️ Inserts test data

✔️ Is idempotent (safe to re-run)

✔️ Ends with clear verification output

```
sudo nano setup_charlie_cafe_db_full.sh
```

[Order Processing & HR Schema Setup + Verification ](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/AWS%20RDS%20Bash%20Scripts/Charlie-Cafe_RDS-Full.sh)

```
#!/bin/bash

# ☕ Charlie Cafe — FULL RDS Setup & Verification Script

# ✔ Secure temporary MySQL config

# ✔ Creates database

# =============================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"

print_header "☕ Charlie Cafe RDS Setup Starting"


# FETCH RDS CREDENTIALS

# CREATE TEMP MYSQL CONFIG

# =============================================================
print_header "Testing RDS Connection"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT VERSION();"
print_success "RDS connection successful"


# CREATE DATABASE

# =============================================================
print_header "Ensuring Database Exists"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database verified"


# 1️⃣ Verify Database Exists
echo "1️⃣ Verify Database Exists:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SHOW DATABASES LIKE '$DB_NAME';"


# 2️⃣ Verify Current Database
echo "2️⃣ Verify Current Database:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SELECT DATABASE();"


# 4️⃣ Describe & SELECT for each table
for table in orders employees attendance holidays leaves
do
    echo "---- DESCRIBE $table ----"
    mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; DESCRIBE $table;"
    
    echo "---- SELECT * FROM $table ----"
    mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SELECT * FROM $table;"
done


# =============================================================
print_header "☕ Charlie Cafe RDS Setup Completed Successfully"

echo -e "${GREEN}✔ RDS Connection Successful${NC}"
echo -e "${GREEN}✔ Database Created/Verified${NC}"
echo -e "${GREEN}✔ Tables Created${NC}"
echo -e "${GREEN}✔ Sample Data Inserted${NC}"
echo -e "${GREEN}✔ order_id & payment_method Columns Added${NC}"
echo -e "${GREEN}✔ Schemas Verified${NC}"
echo -e "${GREEN}✔ Row Counts Verified${NC}"
echo -e "${GREEN}✔ Analytics Queries Successful${NC}"
echo -e "${GREEN}✔ Full RDS Verification Completed${NC}"
```


### 4️⃣ Verify table exists

[AWS Charlie Cafe RDS Verification](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Charlie%20Cafe%20%20RDS%20Project.md#rds-verification)


#### Exit MySQL:

```
EXIT;
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---

## 📢 SECTION 2️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---

## 📢 SECTION 3️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---

#### 🌐 Configuration for Insert Data in EC2 MariaDB server / RDS DB ( Recommanded)


## 📢 SECTION 3️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---`

### 5️⃣ Lambda Payload Code (INSERT INTO MariaDB)

Paste THIS EXACT CODE ⬇️

[CafeOrderProcessor.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project//☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Charlie%20Cafe%20-%20Order%20Backend%20Code/CafeOrderProcessor/CafeOrderProcessor.py)

Save Lambda

Click Deploy (top right)
---- 


### 2️⃣ Add this AFTER successful RDS insert

⚠️ Place it AFTER cursor.execute(...) and commit()


#### Inside your SQS CafeOrderProcessor, after DB insert:

```
metrics_table.update_item(
    Key={"metric": "TOTAL_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)
```


#### 📢 your current CafeOrderWorker does NOT update CafeOrderMetrics yet.

Right now it only updates:

```
menu_table = dynamodb.Table(DYNAMODB_TABLE)  # CafeMenu
```

It does NOT reference:

```
CafeOrderMetrics
```


#### 2️⃣ Inside the loop, after the RDS insert, add:

```

### 🧑‍💻 STEP 1 — MODIFY DATABASE (ONE TIME)


#### 1️⃣ Open RDS → Query Editor (or MySQL client)

Connect to your cafe database.


#### 2️⃣ Verify Columns

```
DESCRIBE orders;
```


#### You MUST see:

- order_id

- status

- total_amount

- updated_at


### 🧩 STEP 1 — DATABASE (VERIFY ONLY)


#### 1️⃣ Open RDS → Query Editor (or MySQL client)


#### 2️⃣ Run:

```
use cafe_db;
```

```
DESCRIBE orders;
```

❌ Do NOT drop or modify existing columns

✅ Only verify these exist


#### Required columns in orders table

```
order_id        VARCHAR(40) PRIMARY KEY
customer_name  VARCHAR(100)
table_number   INT
item            VARCHAR(50)
quantity        INT
total_amount   DECIMAL(10,2)
status          VARCHAR(20)
created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

✔ If these already exist → DO NOTHING

✔ If order_id exists → must be unique


### 1️⃣ DynamoDB / RDS (Order Table)
> **UPDATE DATABASE (VERY IMPORTANT)**


#### 1️⃣ If you are using DynamoDB


#### 🔹 Step 1.1 — Create the CafeOrders Table

- AWS Console → DynamoDB → Tables → CafeOrders

- Fill EXACTLY like this

| Field         | Value        |
| ------------- | ------------ |
| Table name    | `CafeOrders` |
| Partition key | `order_id`   |
| Type          | `String`     |
| Sort key      | ❌ NONE       |
| Table class   | Standard     |
| Capacity mode | On-demand    |
| Encryption    | Default      |


- Click Create table.

**🕐 Wait 1-2 minutes until status shows Active.**


#### 🔹 Step 1.2 — Confirm Primary Key

- Your table must have:

```
Partition Key: order_id (String)
```

**⚠️ If not, STOP — this lab assumes order_id is the key.**


#### 🔹 Step 1.3 — Add Attributes (NO MIGRATION NEEDED)


#### Basic test item (CASH payment – PENDING)

```
{
  "order_id": { "S": "ORD-TEST-001" },
  "table_number": { "N": "5" },
  "item": { "S": "Coffee" },
  "quantity": { "N": "2" },
  "total_amount": { "N": "6" },

  "payment_method": { "S": "CASH" },
  "payment_status": { "S": "PENDING" },

  "status": { "S": "RECEIVED" },
  "created_at": { "S": "2026-01-14T10:30:00Z" }
}
```


#### Another test item (CARD payment – PAID)

```
{
  "order_id": { "S": "ORD-TEST-002" },
  "table_number": { "N": "5" },
  "item": { "S": "Coffee" },
  "quantity": { "N": "2" },
  "total_amount": { "N": "6" },

  "payment_method": { "S": "CARD" },
  "payment_status": { "S": "PENDING" },

  "status": { "S": "RECEIVED" },
  "created_at": { "S": "2026-01-14T10:30:00Z" }
}
```

#### 🔎 VERIFY STEP 1.3 WORKED

Click the item → you should see:

```
payment_method: CASH
payment_status: PENDING
```

✅ That’s it

✅ Nothing else to configure here

✅ DynamoDB auto-creates attributes

❌ No further DB action needed


#### 2️⃣ If you are using RDS (MySQL)


#### Run this ONCE:

```
ALTER TABLE orders
ADD payment_method VARCHAR(10),
ADD payment_status VARCHAR(10);
```


#### verify

```
use cafe_db;
```

```
DESCRIBE orders;
```


#### 💻 MODERN CAFE-STYLE orders.php (Frontend Only Modified)

[orders.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---


## PHASE 1️⃣ – RDS 


### 1️⃣ Verify RDS Database Table Schema

```
SHOW DATABASES;
```

**⚠️ Make sure your database (example: cafe_db) exists.**

```
USE cafe_db;
```

```
SHOW TABLES;
```


#### ✅ You MUST see:

```
orders
```


#### 2️⃣ Verify Required Columns Exist


#### Your Lambda uses these columns:

```
item
quantity
total_amount
total_cost
payment_status
created_at
```


#### So check table structure:

```
DESCRIBE orders;
```


#### ✅ You must see something like:

| Field          | Type     |
| -------------- | -------- |
| id             | int      |
| item           | varchar  |
| quantity       | int      |
| total_amount   | decimal  |
| total_cost     | decimal  |
| payment_status | varchar  |
| created_at     | datetime |


### ❗ If created_at is missing


#### Your Lambda filters using:

```
AND created_at >= %s
```


#### If missing, add it:

```
ALTER TABLE orders
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
```


### ❗ If payment_status is missing


#### Add it:

```
ALTER TABLE orders
ADD COLUMN payment_status VARCHAR(20) DEFAULT 'PENDING';
```


### 3️⃣ Verify Data Is Correct


#### Run:

```
SELECT * FROM orders LIMIT 5;
```


#### ✅ Check:

- payment_status should contain PAID

- created_at should have real timestamps

- total_amount should have numbers

- total_cost should have numbers


### 4️⃣ Verify PAID Orders Exist


#### Your Lambda ONLY reads:

```
WHERE payment_status = 'PAID'
```


#### So test:

```
SELECT COUNT(*) FROM orders
WHERE payment_status = 'PAID';
```

If result = 0
👉 Your analytics will show ZERO sales.


### 5️⃣ Verify Date Filtering Works


#### 🔎 Test manually:


#### 1️⃣ Today:

```
SELECT COUNT(*) FROM orders
WHERE payment_status = 'PAID'
AND created_at >= CURDATE();
```


#### 2️⃣ Week:

```
SELECT COUNT(*) FROM orders
WHERE payment_status = 'PAID'
AND created_at >= NOW() - INTERVAL 7 DAY;
```


#### 3️⃣ Month:

```
SELECT COUNT(*) FROM orders
WHERE payment_status = 'PAID'
AND created_at >= DATE_FORMAT(NOW(), '%Y-%m-01');
```

If these return correct data → Lambda will work perfectly.



#### Ensure columns:

- order_id, table_number, customer_name, item, quantity, item_cost, total_cost, total_amount, payment_method, payment_status, status, created_at, updated_at

- Matches the schema in your final Lambda.


### 2️⃣ Insert Sample Data (optional):

```
INSERT INTO orders (order_id, table_number, customer_name, item, quantity, total_cost, total_amount, payment_method, payment_status, status)
VALUES ('ORD-20260302-9999', 1, 'Alice', 'Latte', 2, 4.0, 6.0, 'CASH', 'PAID', 'RECEIVED');
```


### 3️⃣ Configure Secrets Manager

Create a secret: CafeDevDBSM


#### Key/Values:

| Key      | Value                 |
| -------- | --------------------- |
| host     | `<your-rds-endpoint>` |
| username | `<db-username>`       |
| password | `<db-password>`       |
| dbname   | cafe_db               |


### ✅ Verify Secrets Manager

- Go to: 👉 AWS Console → Secrets Manager

- Check secret: CafeDevDBSM


#### It must contain JSON like:

```
{
  "host": "your-rds-endpoint",
  "username": "admin",
  "password": "yourpassword",
  "dbname": "cafe_db"
}
```

**⚠️ If any key name is wrong → Lambda will fail.**

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

### ✅ Update Lambda to Use RDS Only

Use the final Analytics Lambda code I provided.


#### Key changes:

```

# SQL query
sql = """
    SELECT item,
           quantity,
           total_amount,
           total_cost
    FROM orders
    WHERE payment_status = 'PAID'
    AND created_at >= %s
"""
```

✅ Removes status = 'COMPLETED'

✅ Aggregates all PAID orders

- Environment variable in Lambda: SECRET_NAME = CafeDevDBSM


### 1️⃣ Create Cafe Analytics Lambda

- **AWS Console → Lambda → Create function**



#### 1️⃣ Lambda configurations

```
Function name: CafeAnalyticsLambda
Runtime: Python 3.10
Execution role: Create new role
```

### 2️⃣ DEPLOY CODE

**FULL CafeAnalyticsLambda PYTHON CODE (COPY-PASTE)**


#### ✅ FINAL ANALYTICS LAMBDA (WITH COMMENTS ONLY)

🔒 Logic unchanged

🧠 Architecture unchanged

📝 Only comments added

🌱 Environment variable usage clarified

[CafeAnalyticsLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)



### 3️⃣ 🔐 Environment Variable Required

- Open Lambda → Your Function

- Go to Configuration → Environment variables

- Click Edit → Add environment variable

| Variable          | Example    |                                     |
| ----------------- | ---------- | ----------------------------------- |
| ORDERS_TABLE_NAME | CafeOrders |                                     |
| AWS_REGION        | us-east-1  | *(optional, defaults to us-east-1)* |


👉 Click Save


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


## PHASE 3️⃣  – API GATEWAY


### 1️⃣ – API GATEWAY CONFIGURATION


####  1️⃣ Create Resource

- **Go to API Gateway → Your Existing API → Resources → Create Resource**

```
Resource Name: analytics
Resource Path: /analytics
```


####  2️⃣ CREATE METHOD

```
Create Method → GET
Integration: Lambda Proxy
Lambda: CafeAnalyticsLambda
```


#### Confirm:

```
GET, OPTIONS
```


####  4️⃣ QUERY STRING PARAMETERS


#### 1️⃣ Find URL Query String Parameters

> **You will see sections like:**

- Authorization

- Request Validator

- URL Query String Parameters

- HTTP Request Headers


#### 👉 Find this section:

```
URL Query String Parameters
```


#### 2️⃣ ADD period PARAMETER (EXACT)

- Click Edit (top right)

- Under URL Query String Parameters

- Click Add query string

- **Enter:**

```
Name: period
Required: ❌ NO (leave unchecked)
```

#### Set Allowed Values for period Parameter

- After adding the query string period (Required = ❌ No), click on it.

- Look for “Request Validator / Model” or “Validation” (depends on API Gateway type).

- Under Allowed Values / Enum (if using REST API Request Validator with Model):

```
today
week
month
```

- **Click Save**


#### ⚠️ Important Notes

- ⚠️ If you skip this, API Gateway will accept any value and Lambda must handle invalid ones.

- ⚠️ Do NOT mark it required

- ⚠️ Required = unchecked,  You don’t need to mark as required — Lambda already checks for invalid or missing values.


#### In short:

| Parameter | Required | Allowed Values     |
| --------- | -------- | ------------------ |
| period    | No       | today, week, month |


**That’s it — this is all you need for allowed values configuration.**



#### 3️⃣ VERIFY

> **You must now see:**

```
URL Query String Parameters
--------------------------------
period   false
```

**⚠️ If you don’t see this → it was NOT saved.


#### 4️⃣ DO NOTHING ELSE HERE

✅ Do NOT add mapping templates

✅ Do NOT add models

✅ Do NOT add validators

✅ Do NOT touch headers

**⚠️  Because: ✔ Lambda Proxy Integration already passes query parameters automatically**


####  5️⃣ DEPLOY API

> **If you skip this → nothing works**

- Click Actions

- Click Deploy API

- **Choose:**

```
Stage: prod
```

(or your existing stage)

- **Click Deploy**


#### 6️⃣ FINAL API URL FORMAT (CONFIRM)

Your final URL MUST look like this:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/analytics?period=today
```


#### Examples:

```
?period=today
?period=week
?period=month
```


#### 🧠 HOW THIS CONNECTS TO YOUR LAMBDA

API Gateway sends this to Lambda automatically:

```
{
  "queryStringParameters": {
    "period": "today"
  }
}
```

Which your Lambda reads as:

```
event['queryStringParameters']['period']
```

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## PHASE 4️⃣  BOOTSTRAP ANALYTICS UI


### ✅ Update Frontend Analytics Button

Endpoint: /analytics?period=today

Fetch example:

```
async function loadAnalytics(period = 'today') {
    const url = `${window.CHARLIE_CONFIG.apiBase}/analytics?period=${period}`;
    const response = await fetch(url);
    const data = await response.json();
    console.log("Analytics:", data);
}
```


#### Button:

```
<button onclick="loadAnalytics('today')">Load Today's Analytics</button>
```

**⚠️ Already Analytics.html Updated... Skip it**


### 1️⃣ Create analytics.html

```
sudo nano /var/www/html/analytics.html
```


### 2️⃣ analytics.html (FULL CODE)

[analytics.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-%20Sales%20Analytics/analytics.html)


### 3️⃣ File PERMISSIONS (MANDATORY)

```
sudo chown -R apache:apache /var/www
```

```
sudo chmod -R 755 /var/www
```



### 4️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

**✅ PHASE 4 STATUS**

> **🟢 PHASE 4 COMPLETE & VERIFIED**
---

## PHASE 5️⃣  MODIFY ORDER STATUS PAGE


#### 1️⃣ – IDENTIFY ORDER STATUS PAGE FILE

**⚠️ All these changes have already been made in all the admin files, so there is no need to follow these steps.**

[order-status.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)


### 2️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```
---


### 🧭 REPLACEMENT GUIDE

> **🔁 Replace ONLY these values**

| What                               | Replace                            |
| ---------------------------------- | ---------------------------------- |
| `REPLACE_WITH_YOUR_COGNITO_DOMAIN` | Cognito → App Integration → Domain |
| `REPLACE_WITH_YOUR_APP_CLIENT_ID`  | Cognito → App clients              |
| `REPLACE_WITH_YOUR_REDIRECT_URL`   | CloudFront / S3 URL                |
| `YOUR_API_ID`                      | API Gateway ID                     |
| `us-east-1`                        | Your region (if different)         |

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---

## PHASE 6️⃣  EXACT LAMBDA RESPONSE FORMAT FOR ANALYTICS


### 1️⃣ Required DynamoDB Attributes (Orders Table)


#### 1️⃣ Open DynamoDB Table

- AWS Console → DynamoDB

- Click Tables

- Open table:

```
CafeOrders
```


#### 2️⃣ Verify Table Keys


#### Confirm:

| Setting       | Value               |
| ------------- | ------------------- |
| Partition Key | `order_id` (String) |
| GSI           | `order_date-index`  |


**📢 If GSI does not exist, STOP and create it before continuing.**


#### 3️⃣ Verify Required Attributes (CRITICAL)

Click Explore table items

Open at least ONE COMPLETED order

It MUST contain ALL attributes below:

```
{
  "order_id": "ORD123",
  "order_date": "2026-01-17",
  "order_timestamp": 1705488000,
  "item_name": "Latte",
  "quantity": 2,
  "item_cost": 1.5,
  "item_price": 3.0,
  "order_status": "COMPLETED"
}
```
❌ If ANY field is missing → fix order-creation Lambda first

✔ Do NOT continue until this is correct


### 2️⃣ – VERIFY GSI WORKS (NO CODE YET)


#### Test GSI in Console

- DynamoDB → Explore table items

- Switch Query

- Select index:

```
order_date-index
```

- Query condition:

```
order_date BETWEEN 2026-01-01 AND 2026-01-31
```

- Click Run

✔ If items return → GSI works

❌ If empty → fix dates or index


### 3️⃣ – CREATE ANALYTICS LAMBDA


#### 1️⃣ Create Lambda

- **AWS Console → Lambda → Create function**

| Field          | Value                 |
| -------------- | --------------------- |
| Function name  | `CafeAnalyticsLambda` |
| Runtime        | Python 3.10           |
| Execution role | Create new role       |

- Click Create function


#### 2️⃣ Attach IAM Permissions

= **Lambda → Configuration → Permissions**

- **Click Role → Attach policies**

- **Attach:**

```
AmazonDynamoDBReadOnlyAccess
CloudWatchLogsFullAccess
```

- ✔ Save


### 4️⃣ – PASTE FINAL ANALYTICS CODE (NO CHANGES)


#### 1️⃣ Open Code Editor

- Lambda → Code tab

    - Delete ALL existing code


#### 2️⃣ Paste THIS CODE (COPY EXACTLY)

[CafeAnalyticsLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)

- Click Deploy


### 🧪 5️⃣ – Analytics Lambda Using Environment Variables (Production-Ready)

- **Go to: Lambda → Configuration → Environment variables → Edit**


#### Add EXACTLY these:

| Key                 | Value              |
| ------------------- | ------------------ |
| `ORDERS_TABLE_NAME` | `CafeOrders`       |
| `ORDERS_GSI_NAME`   | `order_date-index` |
| `ALLOWED_ORIGIN`    | `*`                |

✅ Save changes

✅ No code hard-coding remains


### 🧪 5️⃣ – TEST LAMBDA IN CONSOLE (MANDATORY)

- **Lambda → Test → Configure test event**


#### 1️⃣ Create Monthly Analytics Test Event

- **Name:**

```
Analytics_Month
```

- **JSON:**

```
{
  "queryStringParameters": {
    "period": "month"
  }
}
```

- Click Save


#### 2️⃣ Run Test

- Click Test


#### ✅ Expected Result (Structure MUST match)

```
{
  "statusCode": 200,
  "body": {
    "period": "month",
    "total_sales": <number>,
    "total_cost": <number>,
    "profit": <number>,
    "orders_count": <number>,
    "profit_per_item": [
      {
        "item": "<string>",
        "quantity": <number>,
        "sales": <number>,
        "cost": <number>,
        "profit": <number>
      }
    ],
    "daily_sales": [
      {
        "date": "YYYY-MM-DD",
        "sales": <number>
      }
    ]
  }
}
```

✔ **Status code: 200**

✔ **Response body MUST look like:**


#### 2️⃣ Create Weekly Analytics Test Event

- **Name:**

```
Analytics_Week
```

- **JSON:**

```
{
  "queryStringParameters": {
    "period": "week"
  }
}
```

- Click Save


#### 2️⃣ Run Test

- Click Test


#### ✅ Expected Result (Structure MUST match)

```
{
  "statusCode": 200,
  "body": {
    "period": "week",
    "total_sales": <number>,
    "total_cost": <number>,
    "profit": <number>,
    "orders_count": <number>,
    "profit_per_item": [],
    "daily_sales": []
  }
}
```

📌 If last 7 days have data → arrays populated

📌 If not → empty arrays (this is correct behavior)


#### 3️⃣ Create Missing Parameter (ERROR CASE) Test Event

- **Name:**

```
Analytics_MissingPeriod
```

- **JSON:**

```
{
  "queryStringParameters": {}
}
```

- Click Save


#### 2️⃣ Run Test

- Click Test


#### ❌ Expected Result (Structure MUST match)

```
{
  "statusCode": 400,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "\"Missing period parameter\""
}
```


#### 📌 Note:

- Body is a JSON string

- Quotes are expected because of json.dumps()


#### 3️⃣ Create Invalid Period Value (ERROR CASE) Test Event

- **Name:**

```
Analytics_InvalidPeriod
```

- **JSON:**

```
{
  "queryStringParameters": {
    "period": "year"
  }
}
```

- Click Save


#### 2️⃣ Run Test

- Click Test


#### ❌ Expected Result (Structure MUST match)

```
{
  "statusCode": 400,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "\"Invalid period value\""
}
```


#### 📌 This confirms:

- Input validation works

- Lambda fails safely

- No DynamoDB call happens


### 🧪 6️⃣ – TEST THROUGH API GATEWAY


#### 1️⃣  API Gateway Setup (IF NOT DONE)

```
GET /analytics
→ Lambda Proxy → CafeAnalyticsLambda
```

- Deploy API


#### 2️⃣  Browser Test


#### Open browser:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/analytics?period=month
```

✔ JSON shown

✔ No CORS error

✔ Correct totals



### ✅ PHASE 9 COMPLETION CHECKLIST

| Item                         | Status |
| ---------------------------- | ------ |
| DynamoDB attributes verified | ✅      |
| GSI tested                   | ✅      |
| Lambda created               | ✅      |
| IAM correct                  | ✅      |
| Console test passed          | ✅      |
| API test passed              | ✅      |
| Response format EXACT        | ✅      |


### ⛔ DO NOT MOVE FORWARD UNTIL

✔ You see correct JSON

✔ Numbers match DynamoDB

✔ No CloudWatch errors

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---


## PHASE 7️⃣  COST AUTO-CALCULATION USING CafeMenu TABLE

> **(MANDATORY BEFORE PROFIT / ANALYTICS / PDF)**


### 1️⃣ — CREATE ITEM COST TABLE (CafeMenu)


#### 1️⃣ OPEN DYNAMODB CONSOLE

- Login to AWS Console

- Search DynamoDB

- Click DynamoDB

- Click Tables

- Click Create table


#### 2️⃣ TABLE BASIC CONFIGURATION

- ➡️ **Table name:**

```
CafeMenu
``` 

- ➡️ **Partition key (Primary Key)**

| Field     | Type        |
| --------- | ----------- |
| item_name | String (PK) |
| base_cost | Number      |

✔ Keep as-is

**⚠️ DO NOT add sort key**


#### 3️⃣ TABLE SETTINGS (VERY IMPORTANT)

- Click Customize settings

- Leave Table class → Standard

- Leave Capacity mode → On-demand

- Encryption → Default

- Tags → Optional (skip)

- Click Create table

**✅ Wait until Status = Active**


### 2️⃣ — INSERT ITEM COST DATA (MANUAL TEST DATA)

> **This step is MANDATORY for testing.**


#### 1️⃣ OPEN TABLE ITEMS

- Open CafeMenu

- Click Explore table items

- Click Create item


#### 2️⃣ ADD FIRST ITEM (Latte)

| Attribute name | Type   | Value |
| -------------- | ------ | ----- |
| item_name      | String | Latte |
| base_cost      | Number | 1.5   |

- Click Save


#### 3️⃣ ADD MORE ITEMS (RECOMMENDED)

**♻️ Repeat Create item for:**

2. **Cappuccino:**

```
item_name = Cappuccino
base_cost = 1.8
```

3. **Tea:**

```
item_name = Tea
base_cost = 0.6
```

4. **Coffee:**

```
item_name = Juice
base_cost = 1.2
```

5. **Juice**

```
item_name = Juice
base_cost = 1.2
```

**✅ At least 2–3 items must exist for testing**


### 3️⃣ — VERIFY CafeMenu TABLE (VERY IMPORTANT)


#### Confirm:

    - item_name exists

    - base_cost exists

    - base_cost is Number, not String

**❌ If base_cost is String → DELETE ITEM → RECREATE**


### 4️⃣ — UPDATE CafeOrderProcessor RDS orders TABLE (MANDATORY)


#### 1️⃣ YOUR CURRENT TABLE (CONFIRMED)

> **You currently have this table:**

```
CREATE TABLE orders (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_number    INT NOT NULL,
    customer_name   VARCHAR(100),
    item            VARCHAR(50),
    quantity        INT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_table_number (table_number),
    INDEX idx_created_at (created_at)
);
```

✅ This is valid

❌ It is missing cost columns

> **🔴 You MUST add cost columns in MySQL**


#### 2️⃣ CONNECT TO RDS

> **You must connect to your MySQL database using ONE of these:**

```
mysql -h <RDS-ENDPOINT> -u <USERNAME> -p
```


#### After login:

```
USE <your_database_name>;
```


#### 3️⃣ RUN THE ALTER COMMAND (COPY–PASTE)


#### ⚠️ Run this EXACTLY once

```
ALTER TABLE orders
ADD COLUMN item_cost DECIMAL(6,2) AFTER quantity,
ADD COLUMN total_cost DECIMAL(6,2) AFTER item_cost;
```

#### Why this is safe

✔ Does NOT delete data

✔ Does NOT change existing rows

✔ Just adds two new columns


#### 4️⃣ VERIFY COLUMNS EXIST (MANDATORY)

Immediately run:

```
DESCRIBE orders;
```

#### You MUST see:

```
item_cost   decimal(6,2)
total_cost  decimal(6,2)
```

**⚠️ If you do NOT see them → STOP and tell me.**


#### 5️⃣ TEST MANUAL INSERT (OPTIONAL BUT SAFE)

Run this test insert:

```
INSERT INTO orders
(table_number, customer_name, item, quantity, item_cost, total_cost)
VALUES
(1, 'Test User', 'Latte', 2, 1.50, 3.00);
```


#### Then verify:

```
SELECT * FROM orders ORDER BY id DESC LIMIT 1;
```

✔ If row inserted → DB is READY

✔ If error → do NOT continue


#### 🧾 FINAL UPDATED TABLE STRUCTURE (REFERENCE ONLY)

> **❗ You do NOT re-create the table**
> **This is only to show how it now looks**

```
CREATE TABLE orders (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_number    INT NOT NULL,
    customer_name   VARCHAR(100),
    item            VARCHAR(50),
    quantity        INT NOT NULL,

    -- ✅ NEW COLUMNS
    item_cost       DECIMAL(6,2),
    total_cost      DECIMAL(6,2),

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_table_number (table_number),
    INDEX idx_created_at (created_at)
);
```


#### 🟢 FINAL CONFIRMATION CHECKLIST (VERY IMPORTANT)

> **❌ Do NOT move forward until ALL are true:**

✔ DESCRIBE orders; shows item_cost

✔ DESCRIBE orders; shows total_cost

✔ Manual INSERT works

✔ No SQL errors


#### ✅ STEP 4️⃣ STATUS

🟢 RDS TABLE UPDATED

🟢 SAFE

🟢 VERIFIED

🟢 READY FOR LAMBDA TEST


### 5️⃣ — OPEN ORDER PROCESSING LAMBDA


#### 1️⃣ OPEN LAMBDA

- Go to AWS Lambda

- Click Functions

- Click your Order Processing Lambda

- Example name:

```
CafeOrderProcessingLambda
```


#### 2️⃣ VERIFY IAM PERMISSIONS (NO SKIP)

- Click Configuration

- Click Permissions

- Click Execution role

- Ensure this policy exists:

```
AmazonDynamoDBReadOnlyAccess
AWSSecretsManagerReadWrite
```


#### ❌ If missing:

- Click Add permissions

- Attach policy

- Save


### 5️⃣ — CONNECT CafeMenu TABLE IN LAMBDA

[CafeOrderProcessingLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderProcessor/CafeOrderProcessingLambda.py)


#### 2️⃣ — DEPLOY LAMBDA (DO NOT SKIP)

- Click Deploy

- Wait for success message


#### 3️⃣ — ADD ENVIRONMENT VARIABLES (MANDATORY)

- **Go to: Configuration → Environment variables → Edit**


#### Add:

| Key             | Value      |
| --------------- | ---------- |
| MENU_TABLE_NAME | CafeMenu   |
| AWS_REGION      | ap-south-1 |

- Save


### 9️⃣ — TEST THIS PHASE (MANDATORY)


#### ❌ DO NOT CONTINUE WITHOUT TESTING


#### 1️⃣ CREATE TEST EVENT

- Click Test → Configure test event

- Test JSON

```
{
  "body": "{\"item_name\":\"Latte\",\"quantity\":2,\"price\":3.0}"
}
```


#### 2️⃣ RUN TEST

- Click Test


#### Confirm:

    - StatusCode = 200

    - No exception


#### 3️⃣ VERIFY DYNAMODB OUTPUT

- Open CafeOrders

- Open latest item

- Confirm these fields exist:

```
item_cost
total_cost
```


#### Example:

```
item_cost = 1.5
total_cost = 3.0
```

**❌ If missing → STOP and fix Lambda**

**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**
---

## PHASE 8️⃣  PROFIT PER ITEM (ALREADY INCLUDED)


### 1️⃣ PREREQUISITE CHECK (DO NOT SKIP)


#### 1️⃣ – Verify DynamoDB Order Item Structure

- Open DynamoDB → Tables → CafeOrders → Explore table

- Confirm EACH ORDER ITEM contains ALL of these attributes:

```
order_id        (String)
order_date      (String)   e.g. "2026-01-17"
order_timestamp (Number)
item_name       (String)
quantity        (Number)
item_price      (Number)   ← selling price
item_cost       (Number)   ← base cost
order_status    (String)   ← COMPLETED
```

❌ If item_cost does NOT exist → STOP

✔ Fix order-processing Lambda FIRST


#### 2️⃣ – Verify Only COMPLETED Orders Are Counted

- **Profit must NOT include:**

```
PENDING
CANCELLED
FAILED
```


#### Confirm in DynamoDB that:

```
order_status = "COMPLETED"
```


### 2️⃣ – PROFIT CALCULATION LOGIC (CLEAR MATH)


#### For each order item:

```
item_sales = item_price × quantity
item_cost  = item_cost × quantity
item_profit = item_sales - item_cost
```

**📢 For same item_name, values must be aggregated.**


### 3️⃣ – MODIFY ANALYTICS LAMBDA (EXACT LOCATION)

- **Open CafeAnalyticsLambda**

[CafeAnalyticsLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)


### 4️⃣ CONFIGURE LAMBDA ENVIRONMENT VARIABLES (MANDATORY)

- **Go to:**

```
AWS Console → Lambda → Your Analytics Lambda
→ Configuration → Environment variables → Edit
```


#### 1️⃣ Add EXACTLY these variables

| Key                   | Value        | Notes                      |
| --------------------- | ------------ | -------------------------- |
| `DYNAMODB_TABLE_NAME` | `CafeOrders` | ✅ Your DynamoDB table name |
| `AWS_REGION`          | `ap-south-1` | ✅ Same region as DynamoDB  |

👉 Click Save

❗ DO NOT add quotes

❗ Key names must match exactly


#### 2️⃣ DEPLOY LAMBDA

- **Click Deploy**

- **🕐 Wait for: Successfully deployed**


### 5️⃣ Lambda Test Event

> ** (DO NOT CONTINUE WITHOUT THIS)**


#### 1️⃣ TEST PHASE 11 + 12 (REQUIRED - Recommanded)


#### 1️⃣ ✅ Test as ADMIN (SUCCESS)


#### Lambda Test Event

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  },
  "queryStringParameters": {
    "period": "month"
  }
}
```

✔ StatusCode: 200

✔ Returns:

- total_sales

- total_cost

- profit

- profit_per_item[]


#### 2️⃣ ❌ Test as STAFF (BLOCKED)

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Staff"
      }
    }
  }
}
```

✔ StatusCode: 403

✔ Message: "Access denied"


#### 2️⃣ TEST PHASE 11 (PROFIT PER ITEM)


#### 1️⃣ – Lambda Test Event

In Lambda → Test, use:

- **Lambda Test Event - 1: (Recommanded)**

```
{
  "queryStringParameters": {
    "period": "month"
  },
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  }
}
```



### ✅ EXPECTED OUTPUT:

```
{
  "total_sales": 120,
  "total_cost": 70,
  "profit": 50,
  "profit_per_item": [
    {
      "item": "Latte",
      "quantity": 10,
      "sales": 50,
      "cost": 30,
      "profit": 20
    }
  ]
}
```


- **Lambda Test Event - 2:**

```
{
  "queryStringParameters": {
    "period": "month"
  }
}
```


#### 2️⃣ – VERIFY RESPONSE (STRICT)

Response MUST include:

```
"profit_per_item": [
  {
    "item": "Latte",
    "quantity": 12,
    "sales": 36,
    "cost": 18,
    "profit": 18
  }
]
```

✔ Profit math correct

✔ Aggregated per item

❌ Missing field = STOP

❌ Wrong math = STOP


### ✅ PHASE 8️⃣ COMPLETION CHECKLIST

✔ DynamoDB has item_cost

✔ Lambda aggregates correctly

✔ profit_per_item returned

✔ Math verified manually

✔ No UI used yet (backend verified first)

**✅ PHASE 8️⃣ STATUS**

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**
---


## PHASE 9️⃣  ROLE-BASED ACCESS (ADMIN VS STAFF)


### 🔗 1️⃣ – VERIFY GROUP CLAIM IN TOKEN


#### 1️⃣ – Login as Admin

- Login via Hosted UI

- Open browser DevTools

- Copy access_token


#### 2️⃣ – Decode JWT (jwt.io)

Confirm this exists:

```
"cognito:groups": ["Admin"]
```

**❌ If missing → group assignment failed**


### 🧠 2️⃣ – ENFORCE ROLE IN ANALYTICS LAMBDA


#### 1️⃣ – Extract Claims (EXACT CODE)

Add TOP of lambda_handler:

```
claims = event['requestContext']['authorizer']['claims']
groups = claims.get('cognito:groups', '')
```


#### 2️⃣ – Enforce Admin-Only Access

Add IMMEDIATELY AFTER:

```
if 'Admin' not in groups:
    return response(403, "Access denied")
```

✔ This blocks Staff

✔ This secures Analytics & PDF


#### 3️⃣ COPY THIS FULL FINAL CODE (Recommanded)

> **(PHASE 11 + PHASE 12 INCLUDED)**

- **Open CafeAnalyticsLambda**

[CafeAnalyticsLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)


#### 4️⃣ CONFIGURE LAMBDA ENVIRONMENT VARIABLES (MANDATORY)

- **Go to:**

```
AWS Console → Lambda → Your Analytics Lambda
→ Configuration → Environment variables → Edit
```


#### 1️⃣ Add EXACTLY these variables

| Key                   | Value        | Notes                      |
| --------------------- | ------------ | -------------------------- |
| `DYNAMODB_TABLE_NAME` | `CafeOrders` | ✅ Your DynamoDB table name |
| `AWS_REGION`          | `ap-south-1` | ✅ Same region as DynamoDB  |

👉 Click Save

❗ DO NOT add quotes

❗ Key names must match exactly


#### 2️⃣ DEPLOY LAMBDA

- **Click Deploy**

- **🕐 Wait for: Successfully deployed**


### 3️⃣ Lambda Test Event

> ** (DO NOT CONTINUE WITHOUT THIS)**


#### 1️⃣ TEST PHASE 11 + 12 (REQUIRED - Recommanded)


#### 1️⃣ ✅ Test as ADMIN (SUCCESS)


#### Lambda Test Event

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  },
  "queryStringParameters": {
    "period": "month"
  }
}
```

✔ StatusCode: 200

✔ Returns:

- total_sales

- total_cost

- profit

- profit_per_item[]


#### 2️⃣ ❌ Test as STAFF (BLOCKED)

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Staff"
      }
    }
  }
}
```

✔ StatusCode: 403

✔ Message: "Access denied"


#### 2️⃣ TEST PHASE 12 (ROLE SECURITY)


#### 1️⃣ ❌ STAFF TEST

Change test event to:

```
"cognito:groups": "Staff"
```


#### EXPECTED:

```
403 Access denied
```

✔ Security works


#### 3️⃣ – TEST ROLE ACCESS (MANDATORY)


#### 1️⃣ – STAFF USER

- Login as Staff

- Open Analytics

- Expected result:

```
403 Access denied
```

**✔ PASS**


#### 2️⃣ – ADMIN USER

- Login as Admin

- Open Analytics

- Expected result:

✔ Data loads

✔ PDF downloads


### ✅ PHASE 12 COMPLETION CHECKLIST

✔ Cognito groups created

✔ Users assigned correctly

✔ Token contains cognito:groups

✔ Lambda enforces role

✔ Staff blocked

✔ Admin allowed


**✅ PHASE 9️⃣ STATUS**

> **🟢 PHASE 9️⃣ COMPLETE & VERIFIED**


## ☕ Charlie Café PHASE 1️⃣ — Database Layer (RDS) Configuration


#### 📢 Goal: Prepare database objects so Lambda can store and read attendance, employees, leaves, holidays.


### 🔹 Assumptions (Based on Your Existing Lab)

You already have:

✅ RDS instance running

✅ Database name: cafedb

✅ RDS security group already allows Lambda access

✅ Lambda already has DB credentials (or Secrets Manager)

✅ You can connect to RDS via:

    - EC2 (mysql / psql client) OR

    - RDS Query Editor


### 1️⃣ Connect to Existing cafedb


#### 1️⃣ Option A: From EC2 (recommended) 

```
mysql -h <RDS-ENDPOINT> -u <DB-USER> -p cafedb
```

> **Enter password when prompted.**


#### 1️⃣ Option B: RDS Query Editor

- Open Amazon RDS

- Databases → Your RDS instance

- Query Editor → Connect to cafedb


### 2️⃣ Method - 1 HR & Attendance System Create Tables

> **This table links Cognito users with café employees.**


#### 1️⃣ Create employees Table

```
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```


### Why each column exists

- cognito_user_id → maps Cognito JWT sub

- employee_id → internal café ID

- salary → HR-only field

- created_at → audit trail


#### 2️⃣ Create attendance Table

```
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    checkin_time TIME,
    checkout_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, attendance_date),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```


#### Key points

UNIQUE(employee_id, attendance_date)

Prevents double check-in per day

checkin_time and checkout_time separated

Foreign key ensures valid employee


#### 3️⃣ Create leaves Table

```
CREATE TABLE leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE NOT NULL,
    leave_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```


#### 4️⃣ Create holidays Table

```
CREATE TABLE holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3️⃣ Insert Test Data (Required for Frontend Testing)


#### 1️⃣ Insert Holidays

```
INSERT INTO holidays (holiday_date, description)
VALUES
('2026-01-01', 'New Year'),
('2026-03-23', 'Pakistan Day');
```


#### 2️⃣ Insert Test Employee (TEMP)


### ✅ Quick Multi-Table Creation ( Recommanded)

You can create all 4 tables in one SQL script. Copy-paste this inside MySQL prompt:

```
-- 1️⃣ employees table
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2️⃣ attendance table
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    checkin_time TIME,
    checkout_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, attendance_date),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 3️⃣ leaves table
CREATE TABLE IF NOT EXISTS leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE NOT NULL,
    leave_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 4️⃣ holidays table
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```


### 4️⃣ Method - 2 HR & Attendance System Create Tables Bash Script 


#### 1️⃣ Create File

```
sudo nano setup_cafe_hr_attendance.sh
```


#### 2️⃣ Bash Script 

[setup_cafe_hr_attendance.sh](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/setup_cafe_hr_attendance/setup_cafe_hr_attendance.sh)


#### 3️⃣ Make the Script Executable

```
sudo chmod +x setup_cafe_hr_attendance.sh
```


#### 4️⃣ Run the Script

```
sudo ./setup_cafe_hr_attendance.sh
```

> **We will later auto-create employees via Cognito, but this helps now.**


### 3️⃣ Create Employee ID


### 1️⃣ create an employee record in your RDS database


#### Step 1: Identify the Cognito User ID

From Cognito, you have the employee details:

- User name: ali

- Sub (User ID): 74e8a458-a011-700d-dcdb-df9692b61962

- Group: Employee

- Other info → job_title, salary, start_date (you decide or get from HR)

The sub is the unique Cognito user ID, which we will use in RDS to link the Cognito account to your employees table.


#### Step 2: Insert Employee Record

Assuming your employees table has the following columns:

```
employees(
    id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) UNIQUE,
    name VARCHAR(100),
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE
)
```


#### ✅ You can insert the employee like this:

- Replace the TEMP-COGNITO-ID with the real Cognito sub for ali, and other fields as appropriate.

```
INSERT INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('TEMP-COGNITO-ID', 'Alice', 'Barista', 40000, '2025-12-01');
```


### ✅ Insert Test Data

```
INSERT INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('74e8a458-a011-700d-dcdb-df9692b61962', 'Ali', 'Barista', 40000, '2026-03-05');
```


#### Explanation:

- cognito_user_id → Cognito sub

- name → Employee full name

- job_title → Employee position

- salary → Employee salary

- start_date → Employment start date

✅ Tip: 

- Always keep cognito_user_id unique so it maps exactly to a Cognito user.

- Make sure the employees table allows these columns (run DESCRIBE employees; to verify).



### ✅ Insert Test Data in One Go

```
-- Insert test holidays
INSERT INTO holidays (holiday_date, description)
VALUES
('2026-01-01', 'New Year'),
('2026-03-23', 'Pakistan Day');

-- Insert temporary test employee
INSERT INTO employees (cognito_user_id, name, job_title, salary, start_date)
VALUES
('TEMP-COGNITO-ID', 'Alice', 'Barista', 40000, '2025-12-01');
```


#### Step 3: Verify Employee Record

After insertion, check that the record exists:

```
SELECT * FROM employees
WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```


#### ✅ Expected output:

| id | cognito_user_id                      | name | job_title | salary | start_date |
| -- | ------------------------------------ | ---- | --------- | ------ | ---------- |
| 1  | 74e8a458-a011-700d-dcdb-df9692b61962 | Ali  | Barista   | 40000  | 2026-03-05 |


#### Optional: Check all employees:

```
SELECT * FROM employees;
```


#### Check if employee is linked to group (if applicable):

If you have a groups table or employee_groups table, make sure the employee is assigned correctly:

```
SELECT * FROM employee_groups
WHERE employee_id = (
    SELECT id FROM employees WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962'
);
```


#### Testing Integration (Optional)

If your app uses cognito_user_id to fetch employee data:

```
SELECT name, job_title, salary 
FROM employees
WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```

- If the query returns data correctly, your Cognito → RDS mapping works.

- You can now create your app logic to fetch employee info by Cognito login.


#### Step 4: Insert Multiple Employees (Optional)

You can batch insert more employees from Cognito:

```
INSERT INTO employees (cognito_user_id, name, job_title, salary, start_date)
VALUES
('ID-2', 'Bob', 'Chef', 50000, '2026-03-01'),
('ID-3', 'Carol', 'Manager', 60000, '2026-02-15');
```


#### Step 5: Optional — Verify via Employee Portal

If your employee-portal.html fetches employees by cognito_user_id, you can now login as Ali in Cognito and check if the portal shows this employee.


#### Step 6: Automate Future Insertions

Later, you can auto-create employees whenever a new Cognito user is added. The general workflow:

- Lambda triggers on Cognito PostConfirmation event

- Lambda inserts a new employee in RDS using the sub as cognito_user_id

- Employee portal automatically shows new employees

Sample Lambda pseudo-query:

```
sql = """
INSERT INTO employees (cognito_user_id, name, job_title, salary, start_date)
VALUES (%s, %s, %s, %s, %s)
"""
cursor.execute(sql, (user_sub, full_name, 'Unknown', 0, today))
```


### ✅ Quick Verification

- Table structure is correct → DESCRIBE employees;

- Record inserted → SELECT * FROM employees WHERE cognito_user_id = '...';

- Linked correctly to any group → SELECT * FROM employee_groups WHERE employee_id = ...;

- App/API can fetch employee using Cognito sub.


#### ✅ Run these commands to confirm everything is working:

```
-- Check tables
SHOW TABLES;

-- Preview employees
SELECT * FROM employees;

-- Preview holidays
SELECT * FROM holidays;
```

If you see your inserted rows and table names, your RDS configuration is fully functional. ✅


### 2️⃣  Verify Employee ID on RDS

```
SELECT * FROM employees;
```

This must match the employee_id in your RDS employees table.


#### Example RDS:

```
employee_id | name | job_title
--------------------------------
5           | Ali  | Barista
```


### 3️⃣ Logout and Login Again

Clear old token:

```
localStorage.clear()
```

Then login again.

Now your console log will show:

```
Decoded Token:
{
 "custom:employee_id": "5",
 "email": "...",
 "cognito:username": "ali"
}
```

Now the portal will work.


### ✅ Another Small Improvement (Recommended)

Update your code to ensure number:

```
const employeeId = parseInt(
decoded["custom:employee_id"] ||
decoded["employee_id"] ||
decoded["cognito:username"]
)
```

Because your Lambda requires numeric employee_id.


### ✅ Verify Cognito Configuration 


### 1️⃣ Configure App Client (VERY IMPORTANT)

- Go to: User Pool → App clients

- Select your App Client

- Open Edit Hosted UI configuration


#### Enable OAuth Flow

- ✔ Authorization code grant


#### Enable  OAuth Scopes

```
openid
email
profile
```

openid is required to receive ID token.


### 2️⃣ Configure Redirect URLs

Add your portal URL.


#### Example:

```
https://d3hg4gkyr2w5ay.cloudfront.net/employee-portal.html
```

Also add logout URL:

```
https://d3hg4gkyr2w5ay.cloudfront.net/employee-login.html
```


### 3️⃣ Configure Domain

- Go to: User Pool → Domain


### Example domain:

```
charlie-cafe-auth
```


#### Your login URL becomes:

```
https://charlie-cafe-auth.auth.us-east-1.amazoncognito.com/login
```


### 4️⃣ Login URL Example

Your Login Button should redirect to:

```
https://charlie-cafe-auth.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://d3hg4gkyr2w5ay.cloudfront.net/employee-portal.html
```

After login Cognito redirects to:

```
employee-portal.html?code=xxxx
```

Your portal then exchanges the code → id_token.


### 5️⃣ Verify Token Contains Employee ID

After login open Chrome Console:

```
console.log(parseJwt(localStorage.getItem("id_token")))
```


#### Expected output:

```
{
 "sub": "abc123",
 "email": "ali@charliecafe.com",
 "custom:employee_id": "5"
}
```

Now your portal will read:

```
employeeId = decoded["custom:employee_id"]
```

And call:

```
GET /employee/profile?employee_id=5
```

Which triggers your AWS Lambda to query Amazon RDS.


### ✅ Final Flow (Complete Architecture)

```
Employee Login
      │
      ▼
Amazon Cognito
      │
      ▼
Returns id_token (JWT)
      │
      ▼
Employee Portal HTML
      │
      ▼
Extract custom:employee_id
      │
      ▼
API Gateway
      │
      ▼
AWS Lambda
      │
      ▼
Amazon RDS
      │
      ▼
Employee Data
```

Everything will work.


### ✅ Most Common Mistakes

❌ Employee ID not added to Cognito user

❌ openid scope missing

❌ Wrong redirect URL

❌ Using employee_id instead of custom:employee_id

❌ Token exchange not implemented


### 🌐 Final End  – What You Have Now

✅ Database schema ready

✅ Linked to Cognito via cognito_user_id

✅ Safe for production-style usage

✅ No change to existing infrastructure


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---


### 1️⃣ — DATABASE (NO CHANGE, JUST VERIFY)

Run this ONCE in RDS:

```
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_attendance_employee ON attendance(employee_id);
```

**✅ Done. Move on.**


#### 🗄️ Database Services

- RDS (Relational Database Service)

- DynamoDB


### Create your repo like this:

> #### Update your repo to this (no file changes, only organization):

```
charlie-cafe-devops/
│
├── README.md
├── appspec.yaml              ✅ (NEW - REQUIRED)
├── LICENSE
├── .gitignore
├── .dockerignore                
├── docker-compose.yml
│
├── app/                         # Your original code (UNCHANGED)
│   ├── frontend/
│   │   ├── *.html/
│   │   ├── *.php/
│   │   ├── css/
│   │   └── js/
│   │
│   └── backend/
│       └── lambda/
│           ├── *.py
│
├── infrastructure/
│   ├── rds/
│   │   ├── schema.sql          
│   │   ├── data.sql            ✅ (separate data)
│   │   └── verify.sql          ✅ (for CI/CD testing)
│   │
│   ├── scripts/
│   │   ├── setup_lamp.sh
│   │   ├── setup_rds.sh
│   │   ├── s3_to_ec2.sh
│   │   ├── ec2_to_s3.sh
│   │   └── lambda_layer.sh     
│
├── docker/
│   ├── apache-php/
│   │   └── Dockerfile          
│   │
│   └── mysql/
│       └── Dockerfile          
│
├── docs/
│   ├── architecture.md
│   ├── deployment.md
│   ├── docker.md               
│   └── AWS Charlie Cafe Project.md
│
└── .github/
    └── workflows/
        └── deploy.yml          
```


#### 🔹 Overview

| SG Name      | Purpose       | Attached To  | Inbound (Key)                    | Outbound  |
| ------------ | ------------- | ------------ | -------------------------------- | --------- |
| `default-sg` | General use   | EC2, RDS     | SSH, HTTP, HTTPS, MySQL, ALL TCP | Allow All |
| `rds-sg`     | DB protection | RDS          | MySQL (from Lambda + Default SG) | Allow All |
| `lambda-sg`  | Lambda access | Lambda (VPC) | HTTP/HTTPS, MySQL to RDS         | Allow All |


#### 🔹 Rules 

| SG Name    | Port   | Protocol | Source / Destination   | Purpose           |
| ---------- | ------ | -------- | ---------------------- | ----------------- |
| default-sg | 22     | TCP      | 0.0.0.0/0 (or your IP) | SSH access        |
| default-sg | 80     | TCP      | 0.0.0.0/0              | Web (HTTP)        |
| default-sg | 443    | TCP      | 0.0.0.0/0              | Web (HTTPS)       |
| default-sg | 3306   | TCP      | Open / restricted      | MySQL access      |
| rds-sg     | 3306   | TCP      | lambda-sg, default-sg  | DB access control |
| lambda-sg  | 3306   | TCP      | rds-sg                 | Connect to RDS    |
| lambda-sg  | 80/443 | TCP      | default-sg (optional)  | API testing       |


#### 💡 Important Notes 

🔒 RDS should NOT be public → only accessible via lambda-sg

⚡ Lambda needs outbound 3306 → RDS

🚫 Avoid 0.0.0.0/0 for MySQL in production

🧪 SSH/HTTP in Lambda SG = optional (debug only)


## 5️⃣ Cafe Database Configuration


### 1️⃣ — RDS Core Setup


#### 🔹 Infrastructure Setup

| Step | Component          | Configuration                                                                                                                                                     |
| ---- | ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1️⃣  | DB Subnet Group    | Name: `CafeRDSSubnetGroup`<br>VPC: `CafeDevVPC`<br>Subnets: Private Subnets (2 AZs)                                                                               |
| 2️⃣  | RDS Security Group | Name: `CafeRDS-SG`<br>Inbound: MySQL (3306) from `Lambda-SG`, `EC2-Web-SG`<br>Outbound: All traffic                                                               |
| 3️⃣  | RDS Instance       | Engine: MySQL/MariaDB<br>DB Name: `cafedb`<br>Username: `cafe_user`<br>Password: `StrongPassword123`<br>Public Access: ❌ Disabled<br>Security Group: `CafeRDS-SG` |
---

### 2️⃣ — AWS Secrets Manager


#### 🔹 Store Database Credentials

| Item        | Value                            |
| ----------- | -------------------------------- |
| Secret Name | `CafeDevDBSM`                    |
| Secret Type | Key/Value (Other type of secret) |
| Username    | `cafe_user`                      |
| Password    | `StrongPassword123`              |
| Host        | RDS Endpoint                     |
| DB Name     | `cafe_db`                        |


#### 🔹 Example (Real Format)

```
{
  "username": "cafe_user",
  "password": "StrongPassword123",
  "host": "cafedb.abc123xyz.us-east-1.rds.amazonaws.com",
  "dbname": "cafe_db"
}
```


### 3️⃣ Run RDS Bash Script 

```
nano charlie_cafe_devops-rds_setup_full.sh
```
[charlie_cafe_devops-rds_setup_full.sh](./infrastructure/scripts/charlie_cafe_devops-rds_setup_full.sh)


#### 🧪 HOW TO USE


#### 1️⃣ Give permission

```
chmod +x charlie_cafe_devops-rds_setup_full.sh
```


#### 2️⃣ Run

```
./charlie_cafe_devops-rds_setup_full.sh
```


#### 💡 Important Notes

- RDS is NOT public (secure private DB)

- Only Lambda / EC2 with proper SG can access MySQL (3306)

- Secret ARN is used inside Lambda / backend code

- Credentials are never hardcoded in application

---

### 4️⃣ DynamoDB Setup


### 1️⃣ Create DynamoDB CafeMenu Table 


#### 🔹 Table Configuration

| Parameter     | Value          |
| ------------- | -------------- |
| Table Name    | `CafeMenu`     |
| Partition Key | `item`         |
| Key Type      | String         |
| Sort Key      | ❌ Not required |


#### 🔹 Capacity Settings

| Setting       | Value     |
| ------------- | --------- |
| Capacity Mode | On-Demand |


#### 💡 Why On-Demand?

| Reason               | Benefit               |
| -------------------- | --------------------- |
| No planning required | Auto scaling          |
| Cost efficient       | Free-tier friendly    |
| Ideal use case       | Learning + small apps |


#### 🔹 Default Settings (Keep As-Is)

| Setting             | Value           |
| ------------------- | --------------- |
| Encryption          | AWS Owned Key   |
| Table Class         | Standard        |
| Deletion Protection | Disabled        |
| Tags                | Optional (skip) |


#### 🔹 Table Status

| Step         | Status         |
| ------------ | -------------- |
| Create Table | Click “Create” |
| Wait Status  | `ACTIVE`       |


### 🍽️ 2️⃣ Insert Menu Items (Cafe Data)


#### 🔹 Item Structure

| Attribute | Type   |
| --------- | ------ |
| item      | String |
| price     | Number |


#### ☕ Menu Items

| Item        | JSON Format                         |
| ----------- | ----------------------------------- |
| Coffee      | `"item": "Coffee", "price": 3`      |
| Latte       | `"item": "Latte", "price": 5`       |
| Tea         | `"item": "Tea", "price": 2`         |
| Cappuccino  | `"item": "Cappuccino", "price": 8`  |
| Fresh Juice | `"item": "Fresh Juice", "price": 6` |


#### 🧾 3️⃣ JSON Item Examples


#### ☕ Coffee

You will see a JSON editor.

Replace everything with:

```
{
  "item": {
    "S": "Coffee"
  },
  "price": {
    "N": "3"
  }
}
```

- ✅ Click Create item


#### 🥛 Latte

Click Create item again:

```
{
  "item": {
    "S": "Latte"
  },
  "price": {
    "N": "5"
  }
}
```

- ✅ Click Create item


#### 🍵 Tea

Click Create item again:

```
{
  "item": {
    "S": "Tea"
  },
  "price": {
    "N": "2"
  }
}
```

- ✅ Click Create item

---


#### ☕ Cappuccino

```
{
  "item": {
    "S": "Cappuccino"
  },
  "price": {
    "N": "8"
  }
}
```

- ✅ Click Create item

---


#### 🍹 Fresh Juice

```
{
  "item": {
    "S": "Fresh Juice"
  },
  "price": {
    "N": "6"
  }
}
```

- ✅ Click Create item


#### 🔄 Data Flow

```
DynamoDB Table (CafeMenu)
   ↓
API Gateway / Lambda
   ↓
Frontend (Cafe Website)
```


### 💡 Notes

- DynamoDB uses NoSQL key-value structure

- item is the primary identifier

- On-demand mode = auto scaling

- Perfect for menu / product catalog

- No need for relational schema


### 🚀 Final Summary

| Component     | Value        |
| ------------- | ------------ |
| Database Type | DynamoDB     |
| Table Name    | CafeMenu     |
| Primary Key   | item         |
| Mode          | On-Demand    |
| Use Case      | Menu Storage |


### 2️⃣ Create DynamoDB METRICS TABLE


### 1️⃣ Create DynamoDB Table

| Parameter     | Value                 |
| ------------- | --------------------- |
| Table Name    | `CafeOrderMetrics`    |
| Partition Key | `metric`              |
| Key Type      | String                |
| Sort Key      | ❌ None                |
| Table Class   | Standard              |
| Capacity Mode | On-Demand             |
| Encryption    | Default (AWS managed) |


#### 🔹 Table Status

| Step         | Status         |
| ------------ | -------------- |
| Create Table | Click “Create” |
| Wait Status  | `ACTIVE`       |


#### 🔹 Metrics Table Data Structure

| Attribute | Type   | Purpose           |
| --------- | ------ | ----------------- |
| metric    | String | Metric identifier |
| count     | Number | Metric value      |


#### 🔹 Initial Metrics Items

| Metric Name  | Meaning                | Initial Value |
| ------------ | ---------------------- | ------------- |
| TOTAL_ORDERS | Total orders in system | 0             |
| TODAY_ORDERS | Orders for current day | 0             |


### 🧾 2️⃣ Insert Items (JSON Format)

**Click table → Explore table → Create item**


#### 🔹 TOTAL_ORDERS

```
{
  "metric": { "S": "TOTAL_ORDERS" },
  "count": { "N": "0" }
}
```


#### 🔹 TODAY_ORDERS

```
{
  "metric": { "S": "TODAY_ORDERS" },
  "count": { "N": "0" }
}
```


### 🔄 Metrics Data Flow

```
Order Placement (SQS/Lambda)
   ↓
Update Metrics Lambda
   ↓
DynamoDB (CafeOrderMetrics)
   ↓
Frontend Dashboard
```


### 💡 Notes

- Designed for real-time dashboard metrics

- Uses simple key-value structure

- Optimized for fast reads/writes

- Works with Lambda update triggers

- No relational complexity required


### 🚀 Final Summary

| Component   | Value               |
| ----------- | ------------------- |
| Table Name  | CafeOrderMetrics    |
| Type        | NoSQL Metrics Store |
| Primary Key | metric              |
| Mode        | On-Demand           |
| Use Case    | Dashboard analytics |


### 3️⃣ Create DynamoDB CafeOrders TABLE


### 1️⃣ Create Table Configuration

| Field         | Value                 |
| ------------- | --------------------- |
| Table Name    | `CafeOrders`          |
| Partition Key | `order_id`            |
| Key Type      | String                |
| Sort Key      | ❌ None                |
| Table Class   | Standard              |
| Capacity Mode | On-Demand             |
| Encryption    | Default (AWS Managed) |


#### 🔹 Table Creation Status

| Step         | Status         |
| ------------ | -------------- |
| Create Table | Click “Create” |
| Wait Time    | 1–2 minutes    |
| Final Status | `ACTIVE`       |


#### 🔑 Primary Key Verification

| Parameter     | Value      |
| ------------- | ---------- |
| Partition Key | `order_id` |
| Type          | String     |

⚠️ If not correct → STOP setup (critical dependency for system)


### 3️⃣ Order Item Structure

| Attribute      | Type   | Description           |
| -------------- | ------ | --------------------- |
| order_id       | String | Unique order ID       |
| table_number   | Number | Customer table number |
| item           | String | Menu item             |
| quantity       | Number | Quantity ordered      |
| total_amount   | Number | Total price           |
| payment_method | String | CASH / CARD           |
| payment_status | String | PENDING / PAID        |
| status         | String | Order state           |
| created_at     | String | Timestamp             |


### 4️⃣ Test Items


#### 🔹 Test Order 1 (CASH – PENDING)

```
{
  "order_id": { "S": "ORD-TEST-001" },
  "table_number": { "N": "5" },
  "item": { "S": "Coffee" },
  "quantity": { "N": "2" },
  "total_amount": { "N": "6" },
  "payment_method": { "S": "CASH" },
  "payment_status": { "S": "PENDING" },
  "status": { "S": "RECEIVED" },
  "created_at": { "S": "2026-01-14T10:30:00Z" }
}
```


#### 🔹 Test Order 2 (CARD – PENDING)

```
{
  "order_id": { "S": "ORD-TEST-002" },
  "table_number": { "N": "5" },
  "item": { "S": "Coffee" },
  "quantity": { "N": "2" },
  "total_amount": { "N": "6" },
  "payment_method": { "S": "CARD" },
  "payment_status": { "S": "PENDING" },
  "status": { "S": "RECEIVED" },
  "created_at": { "S": "2026-01-14T10:30:00Z" }
}
```


#### 🔎 Verification Checklist

| Check           | Expected Result |
| --------------- | --------------- |
| Item visible    | Yes             |
| payment_method  | CASH / CARD     |
| payment_status  | PENDING         |
| order_id unique | Yes             |


#### 🔄 Data Flow

```
Frontend Order → Lambda → SQS → Worker Lambda → DynamoDB (CafeOrders)
```


### 💡 DevOps Notes

- order_id is the primary system identifier

- DynamoDB auto-creates attributes (No schema required)

- Designed for event-driven architecture

- Works with SQS + Lambda pipeline

- Supports real-time order tracking system


### 🚀 Final Summary

| Component   | Value                   |
| ----------- | ----------------------- |
| Table Name  | CafeOrders              |
| Type        | NoSQL Orders Store      |
| Primary Key | order_id                |
| Mode        | On-Demand               |
| Use Case    | Order Management System |


### 4️⃣ CREATE GSI

- AWS Console → DynamoDB → CafeOrders

- Click Indexes tab → Create index

- Configure Index

| Setting       | Value            |
| ------------- | ---------------- |
| Partition Key | order_date       |
| Type          | String           |
| Sort Key      | ❌ None           |
| Index Name    | order_date-index |

- Projection Type: ALL | Capacity Mode: On-demand (default) | Action: Click Create Index | Status: ACTIVE (wait 1–2 min)


#### 📦 REQUIRED TABLE STRUCTURE

> #### 🧾 DynamoDB GSI Configuration (CafeOrders)

| Parameter       | Value                        |
| --------------- | ---------------------------- |
| Table Name      | CafeOrders                   |
| Index Name      | order_date-index             |
| Index Type      | Global Secondary Index (GSI) |
| Partition Key   | order_date (String)          |
| Sort Key        | None                         |
| Projection Type | ALL                          |
| Capacity Mode   | On-Demand                    |
| Status          | ACTIVE                       |


#### 📦 REQUIRED TABLE STRUCTURE (IMPORTANT)

> #### 🧾 Orders Table Schema

| Parameter       | Value                        |
| --------------- | ---------------------------- |
| Table Name      | CafeOrders                   |
| Index Name      | order_date-index             |
| Index Type      | Global Secondary Index (GSI) |
| Partition Key   | order_date (String)          |
| Sort Key        | None                         |
| Projection Type | ALL                          |
| Capacity Mode   | On-Demand                    |
| Status          | ACTIVE                       |


### 2️⃣ Verify Required Attributes (CRITICAL)

Click Explore table items

Open at least ONE COMPLETED order

It MUST contain ALL attributes below:

```
{
  "order_id": "ORD123",
  "order_date": "2026-01-17",
  "order_timestamp": 1705488000,
  "item_name": "Latte",
  "quantity": 2,
  "item_cost": 1.5,
  "item_price": 3.0,
  "order_status": "COMPLETED"
}
```
❌ If ANY field is missing → fix order-creation Lambda first

✔ Do NOT continue until this is correct


### 2️⃣ TEST GSI

- Go to: Explore table items → Change: Scan → Query

- Select index: order_date-index


#### ✔ Query Example:

| Field      | Value      |
| ---------- | ---------- |
| order_date | 2026-01-17 |

> #### - OR range: BETWEEN 2026-01-01 AND 2026-01-31

✔ If items return → GSI works

❌ If empty → fix dates or index


### 5️⃣ Create DynamoDB CafeAttendance TABLE


### 1️⃣ Create Table Configuration


#### 🔹 Basic Setup

| Field              | Value                      |
| ------------------ | -------------------------- |
| Table Name         | `CafeAttendance`           |
| Partition Key      | `employee_id`              |
| Partition Key Type | String                     |
| Sort Key           | `date`                     |
| Sort Key Type      | String (YYYY-MM-DD format) |


#### 🔹 Table Design Purpose

| Feature            | Description                                     |
| ------------------ | ----------------------------------------------- |
| One record per day | Each employee has one attendance entry per date |
| Query pattern      | employee-wise + date-wise lookup                |
| Use case           | HR attendance tracking system                   |


#### 🔹 Table Settings

| Setting       | Value                   |
| ------------- | ----------------------- |
| Capacity Mode | On-Demand               |
| Table Class   | Standard                |
| Encryption    | AWS Owned Key (Default) |
| Tags          | Optional (Skip)         |


#### 🔹 Important Rules

| Rule                                 | Status                                |
| ------------------------------------ | ------------------------------------- |
| Add attributes manually              | ❌ Not allowed                         |
| Define check_in/check_out in console | ❌ Not required                        |
| DynamoDB schema                      | Schema-less (auto attribute creation) |


#### 🔹 Attendance Item Structure (Inserted via Lambda)

| Attribute   | Type   | Description                  |
| ----------- | ------ | ---------------------------- |
| employee_id | String | Employee unique ID           |
| date        | String | Attendance date (YYYY-MM-DD) |
| check_in    | String | Check-in time                |
| check_out   | String | Check-out time               |
| role        | String | Employee role                |


#### 🔹 Example Item (DynamoDB JSON Format)

```
{
  "employee_id": { "S": "101" },
  "date": { "S": "2026-02-01" },
  "check_in": { "S": "09:03" },
  "check_out": { "S": "17:11" },
  "role": { "S": "Employee" }
}
```


### 🔥 Key Design Notes

| Concept       | Explanation                             |
| ------------- | --------------------------------------- |
| Partition Key | employee_id groups data per employee    |
| Sort Key      | date ensures daily tracking             |
| Schema        | Fully dynamic (NoSQL)                   |
| Best Practice | Use Lambda for inserts                  |
| Data Format   | No manual attribute definition required |


### 🚀 Final Summary

| Component   | Value                   |
| ----------- | ----------------------- |
| Table Name  | CafeAttendance          |
| Primary Key | employee_id             |
| Sort Key    | date                    |
| Type        | NoSQL Attendance System |
| Mode        | On-Demand               |
| Use Case    | HR Tracking System      |

---

## 8️⃣ ☕ Employee ID System (Cognito ↔ RDS Integration)


### 🔄 Flow Diagram (Concept)

- Employee signs up in Amazon Cognito

- Cognito generates a unique sub (User ID)

- Lambda / Admin inserts employee into RDS

- RDS stores Cognito ID as reference

- Frontend uses Cognito token → fetch employee data from RDS


### 🔄 RDS Table Structure (Employee Master Table)

| Column Name     | Data Type           | Purpose                 |
| --------------- | ------------------- | ----------------------- |
| id              | INT AUTO_INCREMENT  | Internal DB ID          |
| cognito_user_id | VARCHAR(100) UNIQUE | Links Cognito user      |
| name            | VARCHAR(100)        | Employee name           |
| job_title       | VARCHAR(50)         | Role (Barista, Manager) |
| salary          | DECIMAL(10,2)       | Salary                  |
| start_date      | DATE                | Joining date            |


### 🔄 Cognito → Employee Identity Mapping

| Cognito Attribute  | Meaning        | Usage in RDS                |
| ------------------ | -------------- | --------------------------- |
| sub                | Unique User ID | Stored as `cognito_user_id` |
| email              | Login email    | Optional mapping            |
| cognito:username   | Username       | UI reference                |
| custom:employee_id | Optional DB ID | Alternative mapping         |


### 1️⃣ Get Cognito User Info

Example Cognito user:

| Field    | Value                                  |
| -------- | -------------------------------------- |
| username | ali                                    |
| sub      | `74e8a458-a011-700d-dcdb-df9692b61962` |
| group    | Employee                               |


### 2️⃣ Insert Employee into RDS

```
INSERT INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('74e8a458-a011-700d-dcdb-df9692b61962',
 'Ali',
 'Barista',
 40000,
 '2026-03-05');
```


### 3️⃣ Verify Employee in RDS

```
SELECT * FROM employees
WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```


### 4️⃣ Batch Insert (Optional)

```
INSERT INTO employees (cognito_user_id, name, job_title, salary, start_date)
VALUES
('ID-2', 'Bob', 'Chef', 50000, '2026-03-01'),
('ID-3', 'Carol', 'Manager', 60000, '2026-02-15');
```


### 5️⃣ Integration Query (App Use Case)

```
SELECT name, job_title, salary
FROM employees
WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```


### 6️⃣ Cognito Configuration (Required Setup)


#### 🔐 App Client Settings

| Setting    | Value                    |
| ---------- | ------------------------ |
| OAuth Flow | Authorization Code Grant |
| Scope      | openid, email, profile   |


#### 🔁 Redirect URLs

| Type     | URL                                                                                                  |
| -------- | ---------------------------------------------------------------------------------------------------- |
| Callback | [https://your-cloudfront-url/employee-portal.html](https://your-cloudfront-url/employee-portal.html) |
| Logout   | [https://your-cloudfront-url/employee-login.html](https://your-cloudfront-url/employee-login.html)   |


#### 🌐 Cognito Hosted Domain

- Example: charlie-cafe-auth

- Login URL:

```
https://charlie-cafe-auth.auth.us-east-1.amazoncognito.com/login
```


### 🌐 Login Flow (Frontend)


#### 🔑 Login URL Example

```
https://charlie-cafe-auth.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://your-cloudfront-url/employee-portal.html
```


#### 🔁 After Login

Cognito returns:

```
employee-portal.html?code=xxxx
```

Frontend exchanges code → token


### 🔑 Token Verification (Frontend)

```
console.log(parseJwt(localStorage.getItem("id_token")));
```


#### ✅ Expected Token Output

```
{
  "sub": "74e8a458-a011-700d-dcdb-df9692b61962",
  "email": "ali@charliecafe.com",
  "cognito:username": "ali",
  "custom:employee_id": "5"
}
```


### 🌀 RDS ↔ Cognito Integration Logic

| Step | Action                   |
| ---- | ------------------------ |
| 1    | User logs in via Cognito |
| 2    | Get `sub` from token     |
| 3    | Use `sub` to query RDS   |
| 4    | Fetch employee record    |
| 5    | Return data to frontend  |


### 🌀 Lambda Automation (Best Practice)


#### ⚡ Auto Employee Creation (Post Confirmation Trigger)

```
INSERT INTO employees 
(cognito_user_id, name, job_title, salary, start_date)
VALUES (%s, %s, %s, %s, %s)
```


#### 🔄 Workflow:

| Event                | Action            |
| -------------------- | ----------------- |
| Cognito user created | Lambda triggered  |
| Lambda executes      | Inserts into RDS  |
| Employee ready       | Portal auto-syncs |


### ⚒ Final Verification Checklist


#### ✅ RDS Check

```
SHOW TABLES;
SELECT * FROM employees;
```


#### ✅ Cognito Check

- User pool active

- App client configured

- Hosted UI enabled

- OAuth scopes correct


#### ✅ Integration Check

- Token contains sub

- RDS stores cognito_user_id

- Query returns employee data


### 🎯 Final Result

✔ Cognito handles authentication

✔ RDS stores employee profile

✔ sub links both systems

✔ Frontend uses token to fetch employee data

✔ Lambda can automate employee creation
---

