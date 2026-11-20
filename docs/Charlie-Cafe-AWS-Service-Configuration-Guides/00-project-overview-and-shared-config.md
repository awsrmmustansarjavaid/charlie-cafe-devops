# Charlie Cafe — Project Overview & Shared Configuration

Project goals, architecture context, prerequisites, general deployment notes, and sections that could not be reliably assigned to one AWS service.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

# ☕ Charlie Cafe DevOps Project — End-to-End AWS Cloud DevOps Project (Production-Grade Architecture)


## ☕ Project Goal


### 🎯 Primary Goal

Build a scalable, secure, cloud-native café ordering system using modern DevOps practices.


### 🎯 Business Goal

- Real-time order processing

- Secure employee/admin system

- Scalable system for future growth


### ☕ Client Business Requirements

> ### 🧑‍💼 Client: Charlie Cafe


### 📌 What client wants:

- Online café ordering system

-  dashboard

- Employee management system

- Secure login system

- Real-time order tracking

- Payment tracking (cash/card)


### 📌 Performance Requirements:

- Handle multiple orders simultaneously

- Fast response time

- High availability


### 📌 Security Requirements:

- No public database access

- Secure authentication (Cognito)

- Secrets not hardcoded


### 📌 Scalability:

- System should grow with business

- Handle peak traffic (rush hours)


## ☕ Charlie Cafe —  End-to-End Architecture Diagram

![End-to-End Architecture Diagram](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/965fab6e-51fe-41b8-83cb-097b995fc64e.png)

> #### ☕ Charlie Cafe Data Flow


##### [☕ Charlie Cafe Data Flow](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/Charlie-Cafe_Architecture-Diagram/Charlie-Cafe_Data-Flow.md)


### 🔹 Overview



# ☕ AWS Café Lab — Complete Zero-to-Production Master Guide

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe


#### Full-stack cloud-based cafe ordering system using:


### 🔹 AWS Deployment

- **Refer:** [AWS Charlie Cafe Project](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/1eec632562867d778e7f490f9e0efcfc57027b6f/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20%28Dev%20%2B%20Prod%29/AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project.md)

---

## 📢 SECTION 1️⃣ CAFE BASIC CONFIGURATIONS


## PHASE 1️⃣ — NETWORK & COMPUTE (FOUNDATION)


### 3️⃣ Create TWO private subnets:

- CafeDevPrivateSubnet1 → 10.0.2.0/24 (AZ-a)
- CafeDevPrivateSubnet2 → 10.0.3.0/24 (AZ-b)


# =========================================================

# =========================================================

set -e  # Stop on error

echo "🚀 Starting EC2 Setup..."


# ---------------------------------------------------------

# 1️⃣ Update OS (MANDATORY)

# ---------------------------------------------------------
dnf update -y


# ---------------------------------------------------------

# 2️⃣ Install Apache (httpd)

# ---------------------------------------------------------
dnf install -y httpd
systemctl enable httpd
systemctl start httpd


# ---------------------------------------------------------

# ---------------------------------------------------------
dnf install -y \
php \
php-mysqlnd \
php-cli \
php-common \
php-mbstring \
php-xml


# ---------------------------------------------------------

# 4️⃣ Fix Web Directory Permissions

# ---------------------------------------------------------
chown -R apache:apache /var/www
chmod -R 755 /var/www


# ---------------------------------------------------------

# ---------------------------------------------------------
dnf install -y mariadb105


# ---------------------------------------------------------

# 6️⃣ Install Docker

# ---------------------------------------------------------
dnf install -y docker

systemctl enable docker
systemctl start docker


# ---------------------------------------------------------

# 7️⃣ Install Docker Compose (v2)

# ---------------------------------------------------------
mkdir -p /usr/local/lib/docker/cli-plugins/

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
-o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose


# Verify
docker compose version


# ---------------------------------------------------------

# 8️⃣ Install Git

# ---------------------------------------------------------
dnf install -y git


# ---------------------------------------------------------

# 9️⃣ Install Useful DevOps Tools

# ---------------------------------------------------------
dnf install -y \
htop \
unzip \
curl \
wget \
nano \
vim \
tar


# ---------------------------------------------------------

# 🔟 Install AWS CLI (already included in AL2023 but ensure)

# ---------------------------------------------------------
dnf install -y awscli


# ---------------------------------------------------------

# 1️⃣1️⃣ Create PHP Info Page (Optional)

# ---------------------------------------------------------
echo "<?php phpinfo(); ?>" > /var/www/html/info.php


# ---------------------------------------------------------

# 1️⃣2️⃣ Restart Apache

# ---------------------------------------------------------
systemctl restart httpd


# ---------------------------------------------------------

# ✅ Done

# ---------------------------------------------------------
echo "✅ EC2 Setup Completed Successfully!"
```


# Run as root or with sudo

set -u
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================================="
echo "     LAMP STACK VERIFICATION - $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================="
echo


# Helper functions
ok()    { echo -e "${GREEN}✓ OK${NC} - $1"; }
fail()  { echo -e "${RED}✗ FAILED${NC} - $1"; ((FAILURES++)); }
warn()  { echo -e "${YELLOW}! $1${NC}"; }
check() { [ $? -eq 0 ] && ok "$1" || fail "$1"; }

FAILURES=0
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "not-detected")

echo "1. Basic system information"
echo "   • OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "   • Public IP (from metadata): ${PUBLIC_IP:-not detected}"
echo


# ── 1. Apache Web Test ───────────────────────────────────────────────
echo "1. Apache Web Server - http://localhost"
curl -s -m 5 http://localhost -o /tmp/curl-test.html 2>/dev/null

if grep -qi "It works!" /tmp/curl-test.html 2>/dev/null; then
    ok "Apache serves 'It works!' on port 80"
else
    fail "Apache default page not found"
    if [ -s /tmp/curl-test.html ]; then
        echo "   → Got something but not expected:"
        head -n 5 /tmp/curl-test.html | sed 's/^/      /'
    else
        echo "   → Connection refused / timeout"
    fi
fi
rm -f /tmp/curl-test.html


# ── 2. PHP via web (info.php) ─────────────────────────────────────────
echo -n "2. PHP info page (info.php) ...................... "
if curl -s -m 7 http://localhost/info.php 2>/dev/null | grep -qi "phpinfo"; then
    ok "info.php returns phpinfo() content"
else
    fail "info.php not working"
    warn "→ Expected: http://<IP>/info.php shows PHP info page"
fi


# ── 4. Apache service status ──────────────────────────────────────────
echo -n "4. httpd/apache2 service status ................... "
if systemctl is-active --quiet httpd 2>/dev/null; then
    ok "httpd is active (running)"
elif systemctl is-active --quiet apache2 2>/dev/null; then
    ok "apache2 is active (running)"
else
    fail "httpd/apache2 service not running"
    systemctl status httpd --no-pager 2>/dev/null || systemctl status apache2 --no-pager 2>/dev/null
fi


# ── 5. Apache version ─────────────────────────────────────────────────
echo -n "5. Apache version ................................. "
if httpd -v >/dev/null 2>&1; then
    ok "$(httpd -v | head -n1)"
elif apache2 -v >/dev/null 2>&1; then
    ok "$(apache2 -v | head -n1)"
else
    fail "Cannot run httpd -v / apache2 -v"
fi


# ── 6. PHP CLI version ────────────────────────────────────────────────
echo -n "6. PHP CLI version ................................ "
if command -v php >/dev/null 2>&1; then
    ok "$(php -v | head -n1)"
else
    fail "php command not found"
fi


# ── 7. PHP modules - mysqlnd ──────────────────────────────────────────
echo -n "7. PHP mysqlnd extension .......................... "
if php -m 2>/dev/null | grep -qi mysqlnd; then
    ok "mysqlnd loaded"
else
    fail "mysqlnd NOT loaded in PHP"
    php -m | grep -i mysql 2>/dev/null | sed 's/^/      /'
fi


## 📢 SECTION 1️⃣ CAFE BASIC CONFIGURATIONS COMPLETE ✅
---

# ===============================

# CONFIGURATION

# ===============================


# ===============================

# ===============================

# PARSE VALUES

# ===============================

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')


# ===============================

# VALIDATION

# ===============================

if [[ -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_HOST" ]]; then
  echo "❌ Failed to retrieve database credentials"
  exit 1
fi


# ===============================

# =============================================================

# Version: 8.1 (Production Ready)

#

# Features

# ✔ Colored output

# ✔ Creates all tables

# ✔ Inserts sample data for ALL tables

# ✔ Adds order_id and payment_method columns with defaults

# ✔ Shows schema of each table

# ✔ Verifies table counts

# ✔ Verifies foreign keys

# ✔ Verifies indexes

# ✔ Runs analytics tests

# ✔ Safe to run multiple times

# =============================================================

set -euo pipefail


# =============================================================

# COLOR DEFINITIONS

# =============================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}========================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
    echo -e "${RED}❌ $1${NC}\n"
}


# =============================================================

# CONFIGURATION

# =============================================================

# CHECK REQUIRED TOOLS

# =============================================================
print_header "Checking Required Tools"

command -v mysql >/dev/null 2>&1 || sudo dnf install -y mariadb105
command -v jq >/dev/null 2>&1 || sudo dnf install -y jq
command -v aws >/dev/null 2>&1 || { print_error "AWS CLI not installed"; exit 1; }

print_success "All tools ready"


# =============================================================

# =============================================================

# =============================================================
print_header "Creating Secure MySQL Config"

CREDENTIALS_FILE=$(mktemp /tmp/cafe-db.XXXX)
chmod 600 "$CREDENTIALS_FILE"

cat > "$CREDENTIALS_FILE" <<EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
EOF

trap 'rm -f "$CREDENTIALS_FILE"' EXIT

print_success "Temporary config created"


# =============================================================

# TEST CONNECTION

# =============================================================

# =============================================================

# CREATE TABLES

# =============================================================
print_header "Creating Tables"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) UNIQUE,
    name VARCHAR(100),
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    attendance_date DATE,
    checkin_time TIME,
    checkout_time TIME,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE IF NOT EXISTS leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    leave_date DATE,
    leave_type VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE UNIQUE,
    description VARCHAR(100)
);

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
EOF

print_success "Tables created"


# =============================================================

# INSERT SAMPLE DATA

# =============================================================
print_header "Inserting Sample Data"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
INSERT IGNORE INTO employees
(cognito_user_id,name,job_title,salary,start_date)
VALUES
('emp-001','Ahmed','Barista',800,'2024-01-01'),
('emp-002','Hassan','Cashier',750,'2024-02-01');

INSERT IGNORE INTO attendance
(employee_id,attendance_date,checkin_time,checkout_time)
VALUES
(1,CURDATE(),'09:00:00','17:00:00'),
(2,CURDATE(),'09:15:00','17:00:00');

INSERT IGNORE INTO leaves
(employee_id,leave_date,leave_type)
VALUES
(1,'2026-03-01','Sick Leave');

INSERT IGNORE INTO holidays
(holiday_date,description)
VALUES
('2026-12-25','Christmas'),
('2026-01-01','New Year');

INSERT IGNORE INTO orders
(table_number,customer_name,item,quantity,total_cost,total_amount,payment_status,status)
VALUES
(1,'Ali Khan','Espresso',2,4.00,8.00,'PAID','COMPLETED'),
(2,'Sara Ahmed','Cappuccino',1,3.50,5.00,'PAID','COMPLETED'),
(3,'Omar Ali','Latte',1,3.00,5.00,'PENDING','RECEIVED');
EOF

print_success "Sample data inserted"


# =============================================================

# ADD order_id AND payment_method COLUMNS

# =============================================================
print_header "Adding order_id and payment_method Columns"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- 1️⃣ Add nullable order_id column first
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS order_id VARCHAR(20) NULL AFTER id;

-- 2️⃣ Generate order IDs for existing rows
UPDATE orders
SET order_id = CONCAT('ORD-', DATE_FORMAT(created_at, '%Y%m%d'), '-', LPAD(id,4,'0'))
WHERE order_id IS NULL;

-- 3️⃣ Make order_id NOT NULL and UNIQUE
ALTER TABLE orders
MODIFY COLUMN order_id VARCHAR(20) NOT NULL UNIQUE;

-- 4️⃣ Add payment_method column with default CASH
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS payment_method VARCHAR(20) DEFAULT 'CASH' AFTER status;
EOF

print_success "order_id and payment_method columns added and populated"


# =============================================================

# FINAL VERIFICATION

# =============================================================
print_header "RDS Verification Steps"


# 3️⃣ Show Tables
echo "3️⃣ Show Tables:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SHOW TABLES;"


# 5️⃣ Verify Foreign Keys
echo "5️⃣ Verify Foreign Keys:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM
    information_schema.KEY_COLUMN_USAGE
WHERE
    TABLE_SCHEMA = '$DB_NAME'
    AND REFERENCED_TABLE_NAME IS NOT NULL;
"


# 6️⃣ Verify Indexes (example on orders)
echo "6️⃣ Verify Indexes on orders:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SHOW INDEX FROM orders;"


# 7️⃣ Row Count Verification
echo "7️⃣ Verify Row Counts:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
SELECT
(SELECT COUNT(*) FROM orders) AS total_orders,
(SELECT COUNT(*) FROM employees) AS total_employees,
(SELECT COUNT(*) FROM attendance) AS total_attendance,
(SELECT COUNT(*) FROM holidays) AS total_holidays;
"


# =============================================================

# ANALYTICS TESTS

# =============================================================
print_header "Running Analytics Tests"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
SELECT 'Paid Orders' AS section;
SELECT COUNT(*) FROM orders WHERE payment_status='PAID';

SELECT 'Today Sales' AS section;
SELECT COUNT(*) FROM orders
WHERE payment_status='PAID'
AND created_at >= CURDATE();

SELECT 'Week Sales' AS section;
SELECT COUNT(*) FROM orders
WHERE payment_status='PAID'
AND created_at >= NOW() - INTERVAL 7 DAY;

SELECT 'Month Sales' AS section;
SELECT COUNT(*) FROM orders
WHERE payment_status='PAID'
AND created_at >= DATE_FORMAT(NOW(),'%Y-%m-01');
EOF

print_success "Analytics verification completed"


# =============================================================

# FINAL SUCCESS REPORT

#### ▶️ Run

```
sudo chmod +x setup_charlie_cafe_db_full.sh
```

```
sudo ./setup_charlie_cafe_db_full.sh
```


## 📢 SECTION 3️⃣ CAFE File Sharing


# ============================================================

# Charlie Cafe ☕

# Author: You

# Purpose:

#  - Auto-attach to all Lambdas

#  - Optional Docker parity build

# ============================================================

set -e  # Exit immediately if any command fails


# -----------------------------

# CONFIGURATION (EDIT THESE)

# -----------------------------
LAYER_NAME="pymysql-layer"
PYTHON_RUNTIMES="python3.9 python3.10 python3.11"
WORKDIR="$HOME/pymysql-layer"
REGION="$(aws configure get region)"


# -----------------------------

# PHASE 0️⃣ – PREREQUISITES

# -----------------------------
echo "🔍 Verifying prerequisites..."

aws --version
python3 --version || sudo dnf install -y python3
pip3 --version || sudo dnf install -y python3-pip
zip -v >/dev/null || sudo dnf install -y zip

echo "✅ Prerequisites OK"
echo


# -----------------------------

# PHASE 1️⃣ – BUILD PYMYSQL LAYER

# Clean old directory if exists
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR/python"
cd "$WORKDIR"

echo "📥 Installing pymysql into python/ directory..."
pip3 install pymysql -t python/

echo "📂 Verifying installation..."
ls python/

echo "🗜 Creating ZIP archive..."
zip -r pymysql-layer.zip python >/dev/null

echo "📏 ZIP size:"
ls -lh pymysql-layer.zip
echo


# -----------------------------

# PHASE 1️⃣ – PUBLISH LAYER

# -----------------------------

# PHASE 2️⃣ – AUTO-ATTACH TO ALL LAMBDAS

# -----------------------------

# PHASE 3️⃣ – OPTIONAL DOCKER BUILD

# -----------------------------

# -----------------------------

# CLEANUP (OPTIONAL)

# -----------------------------
echo "🧹 Cleanup local build files (optional)"
echo "⏭ Comment out next line if you want to keep files"
rm -rf "$WORKDIR"

echo
echo "🎉 ALL DONE!"
echo "Layer ARN: $LAYER_ARN"
echo "Region: $REGION"
echo "Charlie Cafe ☕ infrastructure ready."
```


### 🧪 HOW TO USE

```
sudo nano charlie-cafe-pymysql-layer.sh
```


#### Paste script → save → then:

```
sudo chmod +x charlie-cafe-pymysql-layer.sh
```
```
sudo ./charlie-cafe-pymysql-layer.sh
```


# =========================================

# =========================================

set -e  # Exit on error


# Local build folders
BUILD_DIR="lambda-layer"
PYTHON_DIR="$BUILD_DIR/python"
ZIP_FILE="pymysql-layer.zip"


# -------- STEP 1: Prepare Environment --------
echo "✅ Installing Python & Pip (if missing)..."
sudo dnf install -y python3 python3-pip zip


# Clean old builds
echo "🧹 Cleaning old build files..."
rm -rf "$BUILD_DIR" "$ZIP_FILE"


# -------- STEP 3: Install PyMySQL --------
echo "📦 Installing PyMySQL into python/ folder..."
pip3 install pymysql -t "$PYTHON_DIR" --no-cache-dir


# -------- STEP 4: Zip ONLY python/ --------
echo "🗜️ Zipping layer (correct structure)..."
cd "$BUILD_DIR"
zip -r "../$ZIP_FILE" python
cd ..


# -------- STEP 5: Verify ZIP CONTENT --------
echo "🔍 Verifying ZIP structure..."
unzip -l "$ZIP_FILE"


# Charlie Cafe - FrontEnd Development & Deployment


## 1️⃣ ☕ Charlie Cafe - JS & CSS File 


### 1️⃣ Create config.js (NO LOGIC HERE)
> **This file will be reused across all pages.**

This replaces hardcoded config from your old file.

- 📍 Place this in /js/config.js


#### 1️⃣ Command to create the js directory

```
sudo mkdir -p /var/www/html/js
```


#### 2️⃣ Command to create the .js file

```
sudo nano /var/www/html/js/config.js
```


#### 3️⃣ Copy & Paste Script

[config.js](../../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/config.js)


### 2️⃣ Create utils.js (Shared Helpers)

Move all generic helpers here.

```
sudo nano /var/www/html/js/utils.js
```

[utils.js](../../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/utils.js)




### 4️⃣ Create api.js (PUBLIC + PROTECTED FETCH)

This file handles API logic only.

```
sudo nano /var/www/html/js/api.js
```

[api.js](../../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/api.js)


### 5️⃣ Create central-printing.js

```
sudo nano /var/www/html/js/central-printing.js
```

[central-printing.js](../../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-printing.js)


### 6️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/js/*
```
```
sudo chmod 644 /var/www/html/js/*
```

---


### 2️⃣ Create the shared Central-cafe-style (IMPORTANT)


#### 1️⃣ Command to create the css directory

```
sudo mkdir -p /var/www/html/css
```


#### 2️⃣ Create Central-cafe-style

```
sudo nano /var/www/html/css/central_cafe_style.css
```


#### 3️⃣ Copy & Paste CSS

[central_cafe_style.css](../../☕%20AWS%20CAFE%20—%20Central%20Style%20Css/central_cafe_style.css)


#### 3️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/css/*
```
```
sudo chmod 644 /var/www/html/css/*
```

## 2️⃣ ☕ Charlie Cafe - FrontEnd Web Pages


### 1️⃣ Charlie Cafe - index.php (IMPORTANT)
> **File Name: index.php**


#### 1️⃣ Create index.php

```
sudo nano /var/www/html/index.php
```


#### 2️⃣ Paste this clean landing page code:

[index.php](../Charlie-Cafe%20-Index.php/Index.php)

**⚠️ Replace S3_IMAGE_URL_HERE later (next phase)**


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```
---


### 2️⃣ Charlie Cafe Admin Dashboard Page (IMPORTANT)
> **File Name: cafe-admin-dashboard.html**


### 1️⃣ Create index.php

```
sudo nano /var/www/html/cafe-admin-dashboard.html
```


### 2️⃣ Paste this clean landing page code:

[cafe-admin-dashboard.html](../Charlie-Cafe-%20Admin%20Dashboard%20(Order%2BHR)/cafe-admin-dashboard.html)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---

### 3️⃣ Charlie Cafe orders.php (IMPORTANT)
> **File Name: orders.php**


###  Modify orders.php (Automation)

* Remove direct DB insert
* Send POST JSON to API Gateway


#### 1️⃣ Create orders.php

```
sudo nano /var/www/html/orders.php
```

#### 2️⃣ MODERN CAFE-STYLE orders.php (Frontend Only Modified)

[orders.php](../Charlie-Cafe%20-order.php/orders.php)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---

### 4️⃣ Charlie Cafe order-status.html  (IMPORTANT)
> **File Name: order-status.html**


#### 1️⃣ Create File

```
sudo nano /var/www/html/order-status.html
```


#### 2️⃣ CODE


#### 🚨 IMPORTANT:


#### Replace this line ONLY:

```
fetch("https://API_ID.execute-api.region.amazonaws.com/prod/order-status")
```


#### With your real API:

```
fetch("https://abcd1234.execute-api.us-east-1.amazonaws.com/admin/order-status")
```

[order-status.html](../Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```
---

### 5️⃣ Charlie Cafe order-status.php  (IMPORTANT)
> **File Name: order-status.php**


#### ☕ FINAL order-receipt.php with print button (CAFE STYLED - Recommanded)


#### 1️⃣ Create File

```
sudo nano /var/www/html/order-receipt.php
```


#### 2️⃣ code

[order-receipt.php](../Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT_single%20order/order-receipt.php)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---


### 6️⃣ Charlie Cafe admin-orders.html  (IMPORTANT)
> **File Name: admin-orders.html**


#### 1️⃣ Create File

```
sudo nano /var/www/html/admin-orders.html
```


#### 2️⃣ code

[admin-orders.html](../admin-orders/admin-orders.html)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---

### 7️⃣ Charlie Cafe payment-status.php  (IMPORTANT)
> **File Name: payment-status.php**


#### 1️⃣ Create File

```
sudo nano /var/www/html/payment-status.php
```


#### 2️⃣ code

[payment-status.php](../payment-status.php/)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---

### 8️⃣ Charlie Cafe Dedicated Printing HTML  (IMPORTANT)
> **File Name: central-print.html**


#### 1️⃣ Create File

```
sudo nano /var/www/html/central-print.html
```


#### 2️⃣ code

[central-print.html](../☕%20AWS%20CAFE%20—%20Printing%20System/central-print.html)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```
---

### 9️⃣ Charlie Cafe analytics.html  (IMPORTANT)
> **File Name: analytics.html**


#### 1️⃣ Create File

```
sudo nano /var/www/html/analytics.html
```


#### 2️⃣ code

[analytics.html](../Charlie-Cafe%20-%20Sales%20Analytics/analytics.html)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 🔟 login.html


#### 1️⃣ Create File

```
sudo nano /var/www/html/login.html
```


#### 2️⃣ code

[login.html](../Cognito%20Hosted%20UI/login.html)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```


### 1️⃣1️⃣ price-list.html



#### 1️⃣ Create File

```
sudo nano /var/www/html/price-list.html
```


#### 2️⃣ code

[price-list.html](../Charlie-Cafe%20-order.php/price-list.html)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```


### 1️⃣2️⃣ logout.php



#### 1️⃣ Create File

```
sudo nano /var/www/html/logout.php
```


#### 2️⃣ code

[logout.php](../Cognito%20Hosted%20UI/logout.php)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```


### 1️⃣3️⃣ employee-login.html


#### 1️⃣ Create File

```
sudo nano /var/www/html/employee-login.html
```


#### 2️⃣ code

[employee-login.html](../Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/employee-login.html)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```


### 1️⃣4️⃣ employee-portal.html


#### 1️⃣ Create File

```
sudo nano /var/www/html/employee-portal.html
```


#### 2️⃣ code

[employee-portal.html](../Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/employee-portal.html)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```


### 1️⃣5️⃣ hr-attendance.html


#### 1️⃣ Create File

```
sudo nano /var/www/html/hr-attendance.html
```


#### 2️⃣ code

[hr-attendance.html](../Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/hr-attendance.html)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```


### 1️⃣6️⃣ checkin.html


#### 1️⃣ Create File

```
sudo nano /var/www/html/checkin.html
```


#### 2️⃣ code

[checkin.html](../Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/checkin.html)


#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---

[Download & Upload Html Directory ](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cafe_FrontEnd_Config/Cafe%20Code%20Drive/)


# =========================================================

# CHARLIE CAFE ☕

# Includes HTTPD Config Export

# =========================================================


# =========================================================

# ⚙️ AWS CONFIGURATION

# =========================================================

# =========================================================
S3_HTML_FOLDER="Charlie Cafe Code Drive/html/"
S3_BASH_FOLDER="Charlie Cafe Code Drive/bash script/"
S3_HTTPD_FILE="Charlie Cafe Code Drive/httpd/httpd.conf"


# =========================================================

# =========================================================
EC2_HTML_FOLDER="/var/www/html"
EC2_BASH_FOLDER="/home/ec2-user"
EC2_HTTPD_FILE="/etc/httpd/conf/httpd.conf"


# =========================================================

# =========================================================

# 🔐 STEP 2 — SET APACHE PERMISSIONS

# =========================================================

echo ""
echo "🔐 Setting Apache permissions..."


# ---------------------------------------------------------

# List of files

# ---------------------------------------------------------
FILES=(
"/var/www/html/index.php"
"/var/www/html/cafe-admin-dashboard.html"
"/var/www/html/orders.php"
"/var/www/html/order-status.html"
"/var/www/html/order-receipt.php"
"/var/www/html/admin-orders.html"
"/var/www/html/payment-status.php"
"/var/www/html/central-print.html"
"/var/www/html/analytics.html"
"/var/www/html/login.html"
"/var/www/html/logout.php"
"/var/www/html/price-list.html"
"/var/www/html/employee-login.html"
"/var/www/html/employee-portal.html"
"/var/www/html/hr-attendance.html"
"/var/www/html/checkin.html"
"/var/www/html/js/config.js"
"/var/www/html/js/central-auth.js"
"/var/www/html/js/utils.js"
"/var/www/html/js/api.js"
"/var/www/html/js/central-printing.js"
"/var/www/html/js/role-guard.js"
"/var/www/html/css/central_cafe_style.css"
"$EC2_HTTPD_FILE"
)


# ---------------------------------------------------------

# List of directories

# ---------------------------------------------------------
DIRS=(
"/var/www/html/js"
"/var/www/html/css"
)

echo "---------------------------------------------"
echo "Setting ownership to apache:apache..."
sudo chown apache:apache "${FILES[@]}"
sudo chown -R apache:apache "${DIRS[@]}"

echo "---------------------------------------------"
echo "Setting directory permissions to 755..."
for dir in "${DIRS[@]}"; do
    sudo chmod 755 "$dir"
done

echo "---------------------------------------------"
echo "Setting file permissions to 644..."
for file in "${FILES[@]}"; do
    sudo chmod 644 "$file"
done


# =========================================================

# 🔎 STEP 3 — VERIFY PERMISSIONS & HTTPD CONFIG

# =========================================================
echo "---------------------------------------------"
echo "Verifying permissions and httpd.conf existence..."

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        perms=$(ls -l "$file" | awk '{print $1}')
        owner=$(ls -l "$file" | awk '{print $3":"$4}')
        echo "$file : $owner : $perms"
    else
        echo "⚠️ File missing: $file"
    fi
done

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        perms=$(ls -ld "$dir" | awk '{print $1}')
        owner=$(ls -ld "$dir" | awk '{print $3":"$4}')
        echo "$dir : $owner : $perms"
    else
        echo "⚠️ Directory missing: $dir"
    fi
done


### 3️⃣ ALLOW /var/www/html/js IN APACHE


#### ⚠️ Skip this step because alread done

Open Apache main config:

```
sudo nano /etc/httpd/conf/httpd.conf
```

Find this block (or similar):

```
<Directory "/var/www/html">
    AllowOverride None
    Require all denied
</Directory>
```

🔥 CHANGE IT TO:

```
<Directory "/var/www/html">
    AllowOverride All
    Require all granted
</Directory>
```


### 4️⃣ EXPLICITLY ALLOW JS DIRECTORY (BEST PRACTICE)

Add this at the bottom of the file:

```
<Directory "/var/www/html/js">
    Require all granted
</Directory>
```


### 5️⃣ SET PROPER MIME TYPE FOR JS

Still in the same file, add (or ensure exists):

```
AddType application/javascript .js
```


### 6️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## 🔐 PHASE 2️⃣ — Set Up Automatic HTTP → HTTPS Redirection

> **✅ EASY & CORRECT METHOD (RECOMMENDED FOR LAB)**


### 1️⃣  — HTTPS REQUIREMENT (CRITICAL)

**⚠️ Cognito does NOT allow HTTP except localhost.**

So we must add HTTPS.

You have TWO EASY OPTIONS


### 2️⃣ — CLOUD FRONT


### 🚨 GET, HEAD, OPTIONS is NOT enough

You MUST change it to:

```
GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
```

**⚠️ (or at minimum include POST)**


#### This ensures:

Authorization headers

Query strings

Cookies
are forwarded correctly.

👉 SAVE

⏳ Wait 5–10 minutes for deployment.

```
Status = Deployed
```


#### You’ll get:

```
xxxxx.cloudfront.net
```


### 1️⃣ ⚙️ General Configuration

- **Configure the following settings in CloudFront → Distribution → General.**


#### 1️⃣ IPv6

- **Turn OFF IPv6**

✅ Recommended for learning & labs

🔁 Can be enabled later in production


### 2️⃣ Default Root Object (Optional but Recommended)

```
cafe-admin-dashboard.html
```

**⚠️ Do NOT add /order-status.html to Origin Path**
**Origin Path must remain empty.**


### Common Mistakes (Avoid These)

❌ Invalidating:

```
cafe-admin-dashboard.html
```

(missing leading /)

❌ Invalidating wrong file name

❌ Forgetting invalidation after JS changes


### 🔍 Validation Checklist


#### 1️⃣ Distribution Status

Status must be:

```
Deployed
```

**⚠️ If status is In Progress, wait 5–10 minutes.**


## SECTION 4️⃣ Secure Admin Order Dashboard


### READ Me About

[☕ CC- 2 —Secure Charlie Cafe Dashboard System](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%201%20—Secure%20Charlie%20Cafe%20Dashboard%20System.md)


## SECTION 4️⃣ Secure Admin Order Dashboard COMPLETE ✅
---

## SECTION 5️⃣ Cafe Order Processor


## PHASE 4️⃣ — Frontend Development Code


### 💻 MODERN CAFE-STYLE orders.php (Frontend Only Modified)

[orders.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)

**🔁 Replace with your real API Gateway URL**

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---

## PHASE 6️⃣ — Test & Verification ( Must)

_ **Please refer to the Test & Verification documentation for detailed procedures.**

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**


## 🟢 SECTION 5️⃣ COMPLETE & VERIFIED
---

## SECTION 6️⃣ — AWS Cafe Menu + Cache Layer


## PHASE 2️⃣ — CafeMenuLambda

# 🟢 SECTION 6️⃣ COMPLETE & VERIFIED
---

# SECTION 7️⃣ — ORDER STATUS DASHBOARD


## PHASE 2️⃣ — VERIFICATION (MANDATORY)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**


###  2️⃣ UPDATE Update CafeOrderProcessor


### 1️⃣ Add this code at the TOP

```
metrics_table = dynamodb.Table("CafeOrderMetrics")
```


### ✅ What You Need To Add 


#### 1️⃣ Add this near your constants:

```
METRICS_TABLE = "CafeOrderMetrics"
metrics_table = dynamodb.Table(METRICS_TABLE)
```


# ---------- UPDATE TOTAL ORDERS ----------
metrics_table.update_item(
    Key={"metric": "TOTAL_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)


# ---------- UPDATE TODAY ORDERS ----------
metrics_table.update_item(
    Key={"metric": "TODAY_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)
```


#### ✅ Place it right after:

```
cursor.execute(...)
```


### 4️⃣ VERIFY THIS STEP

1️⃣ Place one new order

2️⃣ Go to DynamoDB → CafeOrderMetrics

3️⃣ Open TOTAL_ORDERS

✔ Count increased by 1


**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## PHASE 6️⃣ — FRONTEND ORDER STATUS PAGE

[order-status.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)

**🔁 Replace with your real API Gateway URL**

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---


## PHASE 7️⃣ — FEATURE VERIFICATION (IMPORTANT)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**


# 🟢 SECTION 7️⃣ COMPLETE & VERIFIED
---

# ☕ SECTION 8️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)


## 🔔 PHASE 1️⃣ — Customer Order Tracking (Read-Only Backend, Zero-Risk)


### 2️⃣ — ADD PyMySQL LAYER

- Lambda → Layers → Add layer

- Custom layers

- Select PyMySQLLayer

- Latest version

- Click Add


### 7️⃣ — TEST API (CRITICAL)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**


### 8️⃣ — CREATE order-status.php

This file is frontend-only and SAFE

[order-receipt.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT_single%20order/order-receipt.php)


#### ✅ WHAT YOU NEED TO REPLACE (VERY CLEAR)

Inside the PHP file, ONLY replace this line:

```
$apiUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/cafe-order-status?order_id=$orderId";
```

**🔁 Replace with your real API Gateway URL**


### 9️⃣ — END-TO-END TEST

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---

## 🔄 PHASE 3️⃣ — Real Order State Machine (RECEIVED → PREPARING → READY → COMPLETED)


### 🧠 ORDER ID FORMAT (STANDARD)

```
ORD-YYYYMMDD-XXXX
```


#### Example:

```
ORD-20260114-8392
```


### 🧑‍💻 STEP 2 — TEST ORDER CREATION

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**


### 🧪 STEP 6 — TEST STATUS FLOW (MANDATORY)


#### 1️⃣ RECEIVED → PREPARING

```
{
  "order_id": "ORD-XXXX",
  "status": "PREPARING"
}
```


#### 2️⃣ PREPARING → READY


#### 3️⃣ READY → COMPLETED

❌ Try skipping → must fail


### 🧑‍💻 STEP 8 — order-receipt.php


#### Add billing & live status:


#### 📌 Requirement: Your backend must expose a GET order status API like:

```
GET https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/cafe-order-status?order_id=ORD-XXXX
```


#### 📁 WHERE THIS FILE BELONGS

```
/web
 ├── order.php
 ├── order-receipt.php   ✅ (THIS FILE)
 └── index.html
```


#### Code order-receipt.php

```
<p><strong>Total:</strong> $<?= $data['order']['total_amount'] ?></p>
<p><strong>Status:</strong>
<span class="badge bg-success"><?= $data['order']['status'] ?></span>
</p>
```

**Print button already exists ✅**

**⚠️ STEP 8 is ALREADY implemented in your order-receipt.php.You do NOT need structural changes.**

[order-receipt.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT_single%20order/order-receipt.php)

**☕ You now have a REAL SaaS-LEVEL CUSTOMER ORDER TRACKING SYSTEM**

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## 🔔 PHASE 4️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)


### 🧩 STEP 2 — BACKEND API (READ-ONLY)


#### Endpoint

```
GET /order-receipt.php?order_id=ORD-XXXX
```


#### Expected JSON response (MANDATORY)

```
{
  "order": {
    "order_id": "ORD-20260114-8392",
    "customer_name": "John",
    "table_number": 4,
    "item": "Latte",
    "quantity": 2,
    "total_amount": 8.00,
    "status": "PREPARING",
    "created_at": "2026-01-14 10:42:00"
  }
}
```

✔ If this API already exists → DO NOTHING

✔ If not → create a new Lambda (read-only)


### 🧩 STEP 3 — ORDER PAGE (MINIMAL CHANGE)


#### File: order.php

After successful order placement, backend already returns order_id.


#### Add this line ONLY (no other change):

```
echo "<a class='btn btn-success mt-2'
      href='order-status.php?order_id={$order_id}'>
      📦 Track Your Order
      </a>";
```

✔ Existing order logic untouched

✔ This only adds a link

**⚠️ STEP 3 is ALREADY implemented in your order.php.You do NOT need structural changes.**

[order.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)


### 🧩 STEP 4 — CREATE CUSTOMER TRACKING PAGE


#### File name (NEW)

```
order-receipt.php
```


#### Location

```
/web/order-receipt.php
```


### 🧩 STEP 5 — FINAL order-receipt.php (LATEST VERSION)

**⚠️ STEP 5 is ALREADY implemented in your order-receipt.php.You do NOT need structural changes.**

[order-receipt.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT_single%20order/order-receipt.php)

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**


# 🟢 SECTION 8️⃣ COMPLETE & VERIFIED
---

# SECTION 9️⃣ ☕ Charlie Café – Order Payment System


## ☕ CHARLIE CAFÉ PHASE 1️⃣ Cach Payment System 


## ☕ CHARLIE CAFÉ PHASE 2️⃣ Admin marks a CASH order as PAID


### 6️⃣ — CREATE ADMIN API ENDPOINT


#### 🔹 4.2 Create Resource

- Select your API → Actions → Create Resource

```
/admin
   └── /mark-paid
```


#### Steps:

- Select /

- Create Resource

- Resource name: admin

- Create sub-resource → mark-paid

> **Resource Name: admin → Create Sub-resource mark-paid**

This creates endpoint /admin/mark-paid


#### 🔹 4.5 Deploy API

- Actions → Deploy API

- Stage: prod

- Deploy

📌 Endpoint URL:

```
POST https://xxxx.execute-api.us-east-1.amazonaws.com/prod/admin/mark-paid
```


### 7️⃣ — admin-orders.html

[admin-orders.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/admin-orders/admin-orders.html)

**🔁 Replace with your real API Gateway URL**

```
sudo systemctl restart httpd
```

**✅ Admin feature COMPLETE**

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---

## ☕ CHARLIE CAFÉ PHASE 3️⃣ Order status page understands CARD vs CASH


### 🧠 WHAT THIS PAGE MUST DO

Based on DB values:

| Condition      | Show               |
| -------------- | ------------------ |
| CARD + PAID    | “Payment received” |
| CASH + PENDING | “Pay at counter”   |
| CASH + PAID    | “Cash received”    |


### 🟦 STEP 6 — ORDER STATUS API MUST RETURN FIELDS

Your existing Order Status API must return:

```
{
  "order_id": "ORD-123",
  "payment_method": "CASH",
  "payment_status": "PENDING"
}
```

**⚠️ If missing, update backend first.**


### 🟦 STEP 7 — UPDATE payment-status.php


#### ✅ FULL UPDATED FILE (WITH COMMENTS)

[payment-status.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/payment-status.php/payment-status.php)

**🔁 Replace with your real API Gateway URL**

```
sudo systemctl restart httpd
```

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---


## ☕ CHARLIE CAFÉ PHASE 4️⃣ 🔁 REDIRECTING TO payment-status.php


### 🟦 STEP 1 — REDIRECT FROM order.php (CARD + CASH)


#### 🔁 1️⃣ Change destination page (VERY IMPORTANT)


### ✅ FINAL payment-status.php (CLEAN + PRINT REDIRECT)

Below is a clean, correct version aligned with your flow.


#### 📄 payment-status.php

[payment-status.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/payment-status.php/payment-status.php)

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**


# 🟢 SECTION 9️⃣ COMPLETE & VERIFIED
---

# SECTION 🔟 SALES ANALYTICS & REPORTING SYSTEM


# SECTION 🔟 SALES ANALYTICS & REPORTING SYSTEM COMPLETE & VERIFIED ✅
---

# ☕ Charlie Café SECTION 1️⃣1️⃣ - Attendance System


## ☕ Charlie Café PHASE 4️⃣ — Frontend Pages for HR System

We will create 3 main pages:

- Employee Check-In / Check-Out Page (Tablet / Employee)

- Employee Portal Page (Desktop / Employee)

- Admin Dashboard Page (Desktop / HR/Admin)


### 1️⃣ Employee Check-In / Check-Out Page (Tablet Friendly)
> **📄 checkin.html**


#### 2️⃣ checkin.html Code

[checkin.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/checkin.html)

✅ This page allows employees to check in and check out and confirms success/failure messages.


### 2️⃣ Employee Portal Page
> **📄 employee-portal.html**


#### 2️⃣ employee-portal.html Code

[employee-portal.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/employee-portal.html)

✅ Employees can view profile, attendance, leaves, and holidays.


### 4️⃣ ☕ FINAL ADMIN DASHBOARD (CAFÉ THEME)
> **📄 cafe-admin-dashboard.html**


#### 2️⃣ cafe-admin-dashboard.html Code

[cafe-admin-dashboard.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script//Charlie-Cafe-%20Admin%20Dashboard%20(Order%2BHR)/cafe-admin-dashboard.html)


#### 3️⃣ Set permissions:

```
sudo chown apache:apache *.html
```

```
sudo chmod 644 *.html
```


**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---

## ☕ Charlie Café PHASE 5️⃣ — Cafe Attendance Admin Service


### 🌐 Environment Variables

| Key              | Value            |
|------------------|------------------|
| DYNAMODB_TABLE   | CafeAttendance   |



## ☕ Charlie Café PHASE 8️⃣ — HR Attendance Dashboard


### 1️⃣ — FRONTEND HR ATTENDANCE DASHBOARD


#### 🔹 STEP 1 — Create Folder & File


#### 📁 Create file:

```
sudo nano /var/www/html/hr-attendance.html
```

[hr-attendance.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Secure%20HR%20%26%20Attendance%20System/hr-attendance.html)


### 2️⃣ BACKEND — HR ATTENDANCE DASHBOARD


#### TABLE SETTINGS


#### Capacity mode

- Select: On-demand (recommended)

👉 No billing surprises

👉 Best for learning & small projects


#### Table class

- Leave default (Standard)


#### Encryption

- Leave default (AWS owned key)


#### Tags

- Optional → Skip for now


#### CLICK “CREATE TABLE”

- Scroll down

- Click Create table

**⏳ Wait ~10–20 seconds**

Status will change from Creating → Active


#### ✅ Table is now created


#### ✅ DO NOT CREATE “OTHER ATTRIBUTES” MANUALLY ❗❗❗

This is where beginners get confused.


#### ❌ You do NOT add:

- check_in

- check_out

- role

inside table settings.


### 🔥 Important (VERY IMPORTANT)


### 💡 Bonus Tip (for your HR system)

Later your Lambda will insert like this:

```
dynamo_table.put_item(
    Item={
        "employee_id": "101",
        "date": "2026-02-01",
        "check_in": "09:03",
        "check_out": "17:11",
        "role": "Employee"
    }
)
```

No typed JSON needed ✅


### ✅ Summary

| Issue               | Fix                     |
| ------------------- | ----------------------- |
| Error: Expected '{' | Using wrong JSON format |
| Solution 1          | Switch to Simple JSON   |
| Solution 2          | Use `"S"` typed format  |



**✅ PHASE 8️⃣ STATUS**

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**


# 🟢 SECTION 1️⃣1️⃣ COMPLETE & VERIFIED
---

## SECTION 1️⃣2️⃣ - Charlie Cafe Project Lab Verification

1. [☕ Charlie CAFE BASIC CONFIGURATIONS](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕%20Charlie%20CAFE%20BASIC%20CONFIGURATIONS.md)

2. [Secure Charlie Cafe Dashboard System](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%202%20—%20Order_Async_Processing_Tracking_System%20.md)

3. [☕ CC- 3 —SALES ANALYTICS & REPORTING SYSTEM](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%203%20—SALES%20ANALYTICS%20%26%20REPORTING%20SYSTEM.md)

4. [☕ CC- 4 —Secure HR & Attendance System](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%204%20—Secure%20HR%20%26%20Attendance%20System.md)

---


### 🚀 1. Final DevOps Architecture (Your Project Now)


### ✅ Prerequisites


#### 🔹 1. AWS Account

- Active AWS account with proper IAM permissions


#### 🔹 2. AWS Services Knowledge


#### 🔑 Authentication & Authorization

- Amazon Cognito


#### ⚡ Serverless Services

- AWS Lambda

- API Gateway


#### 🚀 DevOps & Container Services

- ECS (Elastic Container Service)

- ECR (Elastic Container Registry)


#### 🔹 3. Technical Skills

- Basic Linux commands

- Basic networking concepts (optional but recommended)

- PHP and MySQL fundamentals


#### 🔹 4. Tools & Access

- SSH client (e.g., PuTTY, Terminal) or AWS Cloud9

- Git & GitHub basics


## 📁 Professional Repository Structure


### 👉 Important:

- Your original files go inside folders as-is

- No edits needed


### 📝 Create DEVOPS Files


#### 📑 1. [Dockerfile](./docker/apache-php/Dockerfile)


#### 📑 2. [docker-compose.yml](./docker-compose.yml)


# ☕ Charlie Cafe Lab Configurations


## 2️⃣ Initialize AWS 


### 2️⃣ Network & Compute (Foundation)


### 3️⃣ Security Groups (Quick View)


