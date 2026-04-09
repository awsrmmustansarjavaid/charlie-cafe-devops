#!/bin/bash
# =============================================================
# ☕ Charlie Cafe — FULL RDS Setup & Verification Script
# FINAL PRODUCTION VERSION
#
# ✅ Proper order_id handling
# ✅ Safe table creation
# ✅ Sample data insertion
# ✅ Analytics checks
# =============================================================

set -euo pipefail  # Fail on errors, unset vars, or pipeline failures

# =============================================================
# 🎨 COLORS FOR OUTPUT
# =============================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}========================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================================${NC}\n"
}

print_success() { echo -e "${GREEN}✅ $1${NC}\n"; }
print_error()   { echo -e "${RED}❌ $1${NC}\n"; }

# =============================================================
# ⚙️ CONFIGURATION
# =============================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"

print_header "☕ Charlie Cafe RDS Setup Starting"

# =============================================================
# 🔧 CHECK REQUIRED TOOLS
# =============================================================
print_header "Checking Required Tools"

command -v mysql >/dev/null 2>&1 || sudo dnf install -y mariadb105
command -v jq >/dev/null 2>&1 || sudo dnf install -y jq
command -v aws >/dev/null 2>&1 || { print_error "AWS CLI not installed"; exit 1; }

print_success "All tools ready"

# =============================================================
# 🔐 FETCH DB CREDENTIALS FROM AWS SECRETS MANAGER
# =============================================================
print_header "Fetching Secrets Manager Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
--secret-id "$SECRET_ID" \
--region "$AWS_REGION" \
--query SecretString \
--output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

print_success "Credentials loaded securely"

# =============================================================
# 🔒 CREATE TEMP MYSQL CONFIG (SECURE LOGIN)
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
print_success "Temporary secure config created"

# =============================================================
# 🔌 TEST CONNECTION
# =============================================================
print_header "Testing RDS Connection"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT VERSION();"
print_success "RDS connection successful"

# =============================================================
# 🗄️ CREATE DATABASE
# =============================================================
print_header "Ensuring Database Exists"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"
print_success "Database verified"

# =============================================================
# 📊 CREATE TABLES WITH PROPER ORDER_ID
# =============================================================
print_header "Creating Tables"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- Employees table
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) UNIQUE,
    name VARCHAR(100),
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Attendance table
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    attendance_date DATE,
    checkin_time TIME,
    checkout_time TIME,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Leaves table
CREATE TABLE IF NOT EXISTS leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    leave_date DATE,
    leave_type VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Holidays table
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE UNIQUE,
    description VARCHAR(100)
);

-- Orders table with proper auto-increment
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
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
# 📥 INSERT SAMPLE DATA
# =============================================================
print_header "Inserting Sample Data"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- Employees
INSERT IGNORE INTO employees
(cognito_user_id,name,job_title,salary,start_date)
VALUES
('emp-001','Ahmed','Barista',800,'2024-01-01'),
('emp-002','Hassan','Cashier',750,'2024-02-01');

-- Attendance
INSERT IGNORE INTO attendance
(employee_id,attendance_date,checkin_time,checkout_time)
VALUES
(1,CURDATE(),'09:00:00','17:00:00'),
(2,CURDATE(),'09:15:00','17:00:00');

-- Leaves
INSERT IGNORE INTO leaves
(employee_id,leave_date,leave_type)
VALUES
(1,'2026-03-01','Sick Leave');

-- Holidays
INSERT IGNORE INTO holidays
(holiday_date,description)
VALUES
('2026-12-25','Christmas'),
('2026-01-01','New Year');

-- Orders (total_amount = total_cost * quantity)
INSERT INTO orders
(table_number,customer_name,item,quantity,total_cost,total_amount,payment_status,status)
VALUES
(1,'Ali Khan','Espresso',2,4.00,2*4.00,'PAID','COMPLETED'),
(2,'Sara Ahmed','Cappuccino',1,3.50,1*3.50,'PAID','COMPLETED'),
(3,'Omar Ali','Latte',1,3.00,1*3.00,'PENDING','RECEIVED');

EOF

print_success "Sample data inserted"

# =============================================================
# 🔍 FINAL VERIFICATION
# =============================================================
print_header "RDS Verification"

echo "1️⃣ Database Check:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SHOW DATABASES LIKE '$DB_NAME';"

echo "2️⃣ Tables:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "SHOW TABLES;"

echo "3️⃣ Row Counts:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "
SELECT
(SELECT COUNT(*) FROM orders) AS total_orders,
(SELECT COUNT(*) FROM employees) AS total_employees,
(SELECT COUNT(*) FROM attendance) AS total_attendance,
(SELECT COUNT(*) FROM holidays) AS total_holidays;
"

echo "4️⃣ Foreign Keys:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
SELECT TABLE_NAME,COLUMN_NAME,REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA='$DB_NAME'
AND REFERENCED_TABLE_NAME IS NOT NULL;
"

echo "5️⃣ Index Check:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "SHOW INDEX FROM orders;"

# =============================================================
# 📈 ANALYTICS TESTS
# =============================================================
print_header "Running Analytics"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

SELECT 'Paid Orders';
SELECT COUNT(*) FROM orders WHERE payment_status='PAID';

SELECT 'Today Sales';
SELECT COUNT(*) FROM orders
WHERE payment_status='PAID'
AND created_at >= CURDATE();

SELECT 'Weekly Sales';
SELECT COUNT(*) FROM orders
WHERE payment_status='PAID'
AND created_at >= NOW() - INTERVAL 7 DAY;

EOF

print_success "Analytics successful"

# =============================================================
# 🎉 FINAL STATUS
# =============================================================
print_header "☕ Charlie Cafe Setup Completed"

echo -e "${GREEN}✔ RDS Ready${NC}"
echo -e "${GREEN}✔ Database Ready${NC}"
echo -e "${GREEN}✔ Tables Ready${NC}"
echo -e "${GREEN}✔ Data Loaded${NC}"
echo -e "${GREEN}✔ Verification Passed${NC}"
echo -e "${GREEN}✔ Analytics Working${NC}"
