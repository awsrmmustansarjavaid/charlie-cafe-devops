# Charlie -Cafe Bash Scripts

### ✅ Bash Script 1️⃣ charlie_cafe_devops-rds_setup_full.sh

```
#!/bin/bash

# =============================================================
# ☕ Charlie Cafe — FULL RDS CLEAN SETUP / DEVOPS SCRIPT
# =============================================================
#
# PURPOSE:
# Complete production-ready AWS RDS database setup.
#
# FEATURES:
# ✔ Deletes old messy schema
# ✔ Rebuilds tables cleanly
# ✔ Fixes duplicate/incorrect columns
# ✔ Adds missing payment_method field
# ✔ Creates proper indexes / keys
# ✔ Inserts safe sample data
# ✔ Runs verification checks
# ✔ Runs analytics tests
#
# WARNING:
# This script DROPS tables before recreating.
# Existing data will be deleted.
#
# =============================================================

set -euo pipefail

# =============================================================
# 🎨 TERMINAL COLORS
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

print_success() {
    echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
    echo -e "${RED}❌ $1${NC}\n"
}

# =============================================================
# ⚙️ CONFIGURATION
# =============================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"

print_header "☕ Charlie Cafe RDS DevOps Setup Starting"

# =============================================================
# 🔧 CHECK REQUIRED TOOLS
# =============================================================
print_header "Checking Required Packages"

command -v mysql >/dev/null 2>&1 || sudo dnf install -y mariadb105
command -v jq >/dev/null 2>&1 || sudo dnf install -y jq
command -v aws >/dev/null 2>&1 || {
    print_error "AWS CLI Missing"
    exit 1
}

print_success "All packages installed"

# =============================================================
# 🔐 GET RDS CREDENTIALS
# =============================================================
print_header "Fetching AWS Secrets"

SECRET_JSON=$(aws secretsmanager get-secret-value \
--secret-id "$SECRET_ID" \
--region "$AWS_REGION" \
--query SecretString \
--output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

print_success "Secrets Retrieved"

# =============================================================
# 🔒 TEMP MYSQL LOGIN FILE
# =============================================================
print_header "Creating Secure Temp MySQL Config"

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

print_success "Secure MySQL Temp File Ready"

# =============================================================
# 🔌 TEST DB CONNECTION
# =============================================================
print_header "Testing Database Connection"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT VERSION();"

print_success "Connected to RDS Successfully"

# =============================================================
# 🗄️ CREATE DATABASE
# =============================================================
print_header "Creating Database"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database Ready"

# =============================================================
# 🧹 CLEAN OLD TABLES
# =============================================================
print_header "Removing Old Broken Tables"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS leaves;
DROP TABLE IF EXISTS holidays;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS employees;

SET FOREIGN_KEY_CHECKS=1;

EOF

print_success "Old Tables Removed"

# =============================================================
# 🏗️ CREATE CLEAN TABLES
# =============================================================
print_header "Creating Clean Production Tables"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- Employees
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) UNIQUE,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Attendance
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE,
    checkin_time TIME,
    checkout_time TIME,
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
);

-- Leaves
CREATE TABLE leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE,
    leave_type VARCHAR(50),
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
);

-- Holidays
CREATE TABLE holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE UNIQUE,
    description VARCHAR(100)
);

-- Orders
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    table_number INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    item VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'CASH',
    total_cost DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    status VARCHAR(20) DEFAULT 'RECEIVED',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

EOF

print_success "Tables Created Successfully"

# =============================================================
# 📥 INSERT SAMPLE DATA
# =============================================================
print_header "Loading Sample Data"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

INSERT INTO employees
(cognito_user_id,name,job_title,salary,start_date)
VALUES
('emp-001','Ahmed','Barista',800,'2024-01-01'),
('emp-002','Hassan','Cashier',750,'2024-02-01');

INSERT INTO attendance
(employee_id,attendance_date,checkin_time,checkout_time)
VALUES
(1,CURDATE(),'09:00:00','17:00:00'),
(2,CURDATE(),'09:15:00','17:00:00');

INSERT INTO leaves
(employee_id,leave_date,leave_type)
VALUES
(1,'2026-03-01','Sick Leave');

INSERT INTO holidays
(holiday_date,description)
VALUES
('2026-12-25','Christmas'),
('2026-01-01','New Year');

INSERT INTO orders
(table_number,customer_name,item,quantity,payment_method,total_cost,total_amount,payment_status,status)
VALUES
(1,'Ali Khan','Espresso',2,'CASH',4.00,8.00,'PAID','COMPLETED'),
(2,'Sara Ahmed','Cappuccino',1,'CARD',3.50,3.50,'PAID','COMPLETED'),
(3,'Omar Ali','Latte',1,'CASH',3.00,3.00,'PENDING','RECEIVED');

EOF

print_success "Sample Data Inserted"

# =============================================================
# FINAL VERIFICATION
# =============================================================
print_header "RDS Verification Steps"

# 1️⃣ Verify Database Exists
echo "1️⃣ Verify Database Exists:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SHOW DATABASES LIKE '$DB_NAME';"

# 2️⃣ Verify Current Database
echo "2️⃣ Verify Current Database:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SELECT DATABASE();"

# 3️⃣ Show Tables
echo "3️⃣ Show Tables:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SHOW TABLES;"

# 4️⃣ Describe & SELECT for each table
for table in orders employees attendance holidays leaves
do
    echo "---- DESCRIBE $table ----"
    mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; DESCRIBE $table;"
    
    echo "---- SELECT * FROM $table ----"
    mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SELECT * FROM $table;"
done

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
mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "
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
# 🎉 COMPLETE
# =============================================================
print_header "☕ Charlie Cafe Setup Complete"

echo -e "${GREEN}✔ RDS Production Ready${NC}"
echo -e "${GREEN}✔ Schema Fixed${NC}"
echo -e "${GREEN}✔ Frontend Compatible${NC}"
echo -e "${GREEN}✔ Backend Compatible${NC}"
echo -e "${GREEN}✔ Analytics Ready${NC}"
echo -e "${GREEN}✔ Full RDS Verification Completed${NC}"
```

---
### ✅ Bash Script 2️⃣ charlie_cafe_full_check.sh

```
#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — FULL DevOps & Post-Deployment Verification Script
# ==========================================================
# This script performs:
#   ✅ Required tools verification
#   ✅ Docker daemon & image/container check
#   ✅ Project directory & Git check
#   ✅ AWS Secrets Manager connectivity
#   ✅ Local application health (curl)
#   ✅ RDS database connectivity & analytics
#   ✅ SSH configuration & GitHub access
#   ✅ Git repo verification & optional test commit
#   ✅ Post-deployment verification (ports, logs, restart policy)
# ==========================================================

echo "=================================================="
echo "🚀 Starting Full Environment & Deployment Verification"
echo "=================================================="

PASS_COUNT=0
FAIL_COUNT=0

# ----------------------------------------------------------
# Function: Check if command exists
# ----------------------------------------------------------
check_command() {
    if command -v $1 &> /dev/null
    then
        echo "✅ $1 is installed"
        ((PASS_COUNT++))
    else
        echo "❌ $1 is NOT installed"
        ((FAIL_COUNT++))
    fi
}

# ----------------------------------------------------------
# Step 1: Required Tools
# ----------------------------------------------------------
echo ""
echo "🔎 Step 1: Checking required tools..."
check_command aws
check_command jq
check_command mysql
check_command docker
check_command git
check_command curl
check_command ssh

# ----------------------------------------------------------
# Step 2: Version Checks
# ----------------------------------------------------------
echo ""
echo "🔎 Step 2: Checking versions..."
echo "---- Versions ----"
aws --version 2>/dev/null || echo "❌ aws failed"
jq --version 2>/dev/null || echo "❌ jq failed"
mysql --version 2>/dev/null || echo "❌ mysql failed"
docker --version 2>/dev/null || echo "❌ docker failed"
git --version 2>/dev/null || echo "❌ git failed"
curl --version 2>/dev/null || echo "❌ curl failed"
ssh -V 2>/dev/null || echo "❌ ssh failed"

# ----------------------------------------------------------
# Step 3: Docker Status
# ----------------------------------------------------------
echo ""
echo "🔎 Step 3: Checking Docker daemon..."
if sudo systemctl is-active --quiet docker
then
    echo "✅ Docker daemon is running"
    ((PASS_COUNT++))
else
    echo "❌ Docker daemon is NOT running"
    ((FAIL_COUNT++))
fi

docker info >/dev/null 2>&1 && echo "✅ docker info OK" || echo "❌ docker info failed"

# ----------------------------------------------------------
# Step 4: Project Directory & Git
# ----------------------------------------------------------
echo ""
echo "🔎 Step 4: Checking project directory..."
PROJECT_DIR="/home/ec2-user/charlie-cafe-devops"

if [ -d "$PROJECT_DIR" ]; then
    echo "✅ Project directory exists: $PROJECT_DIR"
    cd "$PROJECT_DIR" || exit

    echo ""
    echo "📂 Git Status:"
    git status 2>/dev/null || echo "❌ Not a git repo"

    echo ""
    echo "📁 Directory structure:"
    ls -la

    echo ""
    echo "🔹 Checking Git remote URL..."
    git remote -v || echo "❌ Cannot show remotes"

    echo ""
    echo "🔹 Verifying SSH connection to GitHub..."
    ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | tee /tmp/github_ssh_test.log
    if grep -q "successfully authenticated" /tmp/github_ssh_test.log; then
        echo "✅ GitHub SSH authentication successful"
        ((PASS_COUNT++))
    else
        echo "❌ GitHub SSH authentication failed"
        ((FAIL_COUNT++))
    fi

    echo ""
    echo "🔹 Checking Git status..."
    git status || echo "❌ Cannot get git status"

    # Optional test commit
    TEST_FILE="test_auto_deploy.txt"
    echo "# Test Deploy $(date)" >> $TEST_FILE
    git add $TEST_FILE
    git commit -m "Test auto-deploy $(date)" >/dev/null 2>&1 || echo "⚠️ Nothing to commit"
    git push origin main >/dev/null 2>&1 && echo "✅ Test file pushed to GitHub" || echo "⚠️ Could not push test file"
    rm -f $TEST_FILE
    git add . >/dev/null 2>&1
    git commit -m "Remove test file" >/dev/null 2>&1
    git push origin main >/dev/null 2>&1

else
    echo "❌ Project directory NOT found"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 5: SSH Verification
# ----------------------------------------------------------
echo ""
echo "🔎 Step 5: Checking SSH keys..."
echo "📂 ~/.ssh contents:"
ls -l ~/.ssh

if [ -f ~/.ssh/id_deploy ]; then
    echo "✅ Deploy private key exists"
    ((PASS_COUNT++))
else
    echo "❌ Deploy private key NOT found"
    ((FAIL_COUNT++))
fi

if [ -f ~/.ssh/id_deploy.pub ]; then
    echo "✅ Deploy public key exists"
    ((PASS_COUNT++))
else
    echo "❌ Deploy public key NOT found"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 6: AWS Secrets Manager Check
# ----------------------------------------------------------
echo ""
echo "🔎 Step 6: Fetching RDS credentials from AWS Secrets Manager..."
SECRET_NAME="CafeDevDBSM"
REGION="us-east-1"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_NAME \
  --region $REGION \
  --query SecretString \
  --output text 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "✅ Secret fetched successfully"
    DB_HOST=$(echo $SECRET_JSON | jq -r .host)
    DB_USER=$(echo $SECRET_JSON | jq -r .username)
    DB_PASS=$(echo $SECRET_JSON | jq -r .password)
    DB_NAME=$(echo $SECRET_JSON | jq -r .dbname)

    echo "📊 Database Host: $DB_HOST"
    echo "📊 Database User: $DB_USER"
    echo "📊 Database Name: $DB_NAME"
    ((PASS_COUNT++))
else
    echo "❌ Failed to fetch secret"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 7: Application Health Check
# ----------------------------------------------------------
echo ""
echo "🔎 Step 7: Checking Application Health (http://localhost)..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost)
if [ "$HTTP_STATUS" == "200" ]; then
    echo "✅ Application is UP (HTTP 200)"
    ((PASS_COUNT++))
elif [ "$HTTP_STATUS" == "000" ]; then
    echo "❌ Application is DOWN (No response)"
    ((FAIL_COUNT++))
else
    echo "⚠️ Application responded with HTTP $HTTP_STATUS"
    ((FAIL_COUNT++))
fi

# ----------------------------------------------------------
# Step 8: RDS Verification & Analytics
# ----------------------------------------------------------
echo ""
echo "🔎 Step 8: Verifying RDS database connectivity..."
if [ -n "$DB_HOST" ] && [ -n "$DB_USER" ] && [ -n "$DB_PASS" ]; then
    SQL_QUERY="SELECT NOW();"
    echo "$SQL_QUERY" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" 2>/tmp/rds_error.log
    if [ $? -eq 0 ]; then
        echo "✅ RDS database connected successfully"
        ((PASS_COUNT++))
    else
        echo "❌ Failed to connect to RDS"
        cat /tmp/rds_error.log
        ((FAIL_COUNT++))
    fi
else
    echo "❌ RDS credentials not available"
    ((FAIL_COUNT++))
fi

# ==========================================================
# Step 9: Post-Deployment Verification (Docker/Git/Health)
# ==========================================================
echo ""
echo "🔎 Step 9: Post-Deployment Verification"

DOCKER_IMAGE="charlie-cafe"
DOCKER_CONTAINER="cafe-app"
HEALTH_URL="http://localhost/health.php"

# Docker image check
docker images | grep $DOCKER_IMAGE >/dev/null 2>&1 && echo "✅ Docker image exists: $DOCKER_IMAGE" || echo "❌ Docker image NOT found"

# Docker container check
if docker ps | grep $DOCKER_CONTAINER >/dev/null 2>&1; then
    echo "✅ Container $DOCKER_CONTAINER is RUNNING"
else
    echo "❌ Container $DOCKER_CONTAINER is NOT running"
    docker ps -a | grep $DOCKER_CONTAINER
    docker logs $DOCKER_CONTAINER
fi

# Port & networking
sudo lsof -i :80 >/dev/null 2>&1 && echo "✅ Port 80 in use" || echo "❌ Port 80 not in use"
curl -f http://localhost >/dev/null 2>&1 && echo "✅ localhost reachable" || echo "❌ localhost NOT reachable"

# Health check
curl -f $HEALTH_URL >/dev/null 2>&1 && echo "✅ Health check passed" || echo "❌ Health check FAILED"

# Docker logs (last 10 lines)
docker logs --tail 10 $DOCKER_CONTAINER || echo "❌ Cannot fetch container logs"
docker exec -it $DOCKER_CONTAINER tail -n 10 /var/log/apache2/error.log || echo "❌ Cannot fetch Apache logs"

# Restart policy
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' $DOCKER_CONTAINER || echo "❌ Cannot fetch restart policy"

# ----------------------------------------------------------
# Final Result
# ----------------------------------------------------------
echo ""
echo "=================================================="
echo "📊 FINAL RESULT"
echo "=================================================="
echo "✅ Passed: $PASS_COUNT"
echo "❌ Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -eq 0 ]; then
    echo "🎉 ALL CHECKS PASSED — ENVIRONMENT READY 🚀"
else
    echo "⚠️ Some checks failed — fix issues above"
fi

echo "=================================================="
```

---
### ✅ Bash Script 3️⃣ charlie-cafe-devops.sh

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — EC2 BOOTSTRAP SCRIPT (FINAL)
# ==========================================================

set -e

echo "🚀 Starting EC2 Bootstrap..."

# ----------------------------------------------------------
# 1️⃣ Update system
# ----------------------------------------------------------
dnf update -y

# ----------------------------------------------------------
# 2️⃣ Fix curl conflict (Amazon Linux 2023)
# ----------------------------------------------------------
dnf remove -y curl-minimal || true
dnf install -y curl --allowerasing

# ----------------------------------------------------------
# 3️⃣ Install base tools
# ----------------------------------------------------------
dnf install -y \
  git \
  docker \
  jq \
  unzip \
  wget \
  nano \
  vim \
  htop \
  tar \
  awscli \
  mariadb105 \
  python3 \
  python3-pip \
  zip

# ----------------------------------------------------------
# 4️⃣ Start & enable Docker
# ----------------------------------------------------------
systemctl enable docker
systemctl start docker

# ----------------------------------------------------------
# 5️⃣ Allow ec2-user to use Docker
# ----------------------------------------------------------
usermod -aG docker ec2-user

# ----------------------------------------------------------
# 6️⃣ Install Docker Compose v2
# ----------------------------------------------------------
mkdir -p /usr/local/lib/docker/cli-plugins/

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# ----------------------------------------------------------
# 7️⃣ Setup SSH known_hosts for GitHub
# ----------------------------------------------------------
mkdir -p /home/ec2-user/.ssh
ssh-keyscan github.com >> /home/ec2-user/.ssh/known_hosts
chown -R ec2-user:ec2-user /home/ec2-user/.ssh

echo "✅ EC2 Bootstrap completed"
```

---
### ✅ Bash Script 4️⃣ charlie-cafe-export-s3-to-html.sh

```
#!/bin/bash
# =========================================================
# CHARLIE CAFE ☕
# S3 TO EC2 EXPORT + PERMISSIONS SCRIPT
# Secure Version (Uses EC2 IAM Role)
# Includes HTTPD Config Export
# =========================================================

# =========================================================
# ⚙️ AWS CONFIGURATION
# =========================================================
AWS_REGION="us-east-1"
S3_BUCKET="charlie-cafe-s3-bucket"

# =========================================================
# 📂 S3 FOLDERS
# =========================================================
S3_HTML_FOLDER="Charlie Cafe Code Drive/html/"
S3_BASH_FOLDER="Charlie Cafe Code Drive/bash script/"
S3_HTTPD_FILE="Charlie Cafe Code Drive/httpd/httpd.conf"

# =========================================================
# 📂 EC2 DESTINATIONS
# =========================================================
EC2_HTML_FOLDER="/var/www/html"
EC2_BASH_FOLDER="/home/ec2-user"
EC2_HTTPD_FILE="/etc/httpd/conf/httpd.conf"

# =========================================================
# 🚀 STEP 1 — EXPORT FILES FROM S3
# =========================================================
echo "======================================================="
echo "🚀 Starting Charlie Cafe S3 Export..."
echo "Bucket: $S3_BUCKET"
echo "Region: $AWS_REGION"
echo "======================================================="

echo "📥 Syncing HTML folder from S3 to EC2..."
aws s3 sync "s3://$S3_BUCKET/$S3_HTML_FOLDER" "$EC2_HTML_FOLDER" \
--region $AWS_REGION --delete

echo "📥 Syncing Bash scripts from S3 to EC2..."
aws s3 sync "s3://$S3_BUCKET/$S3_BASH_FOLDER" "$EC2_BASH_FOLDER" \
--region $AWS_REGION --delete

echo "📥 Downloading httpd.conf from S3..."
sudo aws s3 cp "s3://$S3_BUCKET/$S3_HTTPD_FILE" "$EC2_HTTPD_FILE" --region $AWS_REGION
if [ $? -eq 0 ]; then
    echo "✅ httpd.conf successfully copied to $EC2_HTTPD_FILE"
else
    echo "⚠️ Failed to copy httpd.conf from S3!"
fi

echo "======================================================="
echo "✅ S3 Export Completed!"
echo "HTML folder → $EC2_HTML_FOLDER"
echo "Bash folder → $EC2_BASH_FOLDER"
echo "HTTPD config → $EC2_HTTPD_FILE"
echo "======================================================="

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

# Additional verification for HTTPD
if [ -f "$EC2_HTTPD_FILE" ]; then
    echo "✅ httpd.conf exists at $EC2_HTTPD_FILE"
else
    echo "⚠️ httpd.conf missing at $EC2_HTTPD_FILE"
fi

echo "---------------------------------------------"
echo "✅ Charlie Cafe Deployment Completed!"
echo "S3 files synced + permissions applied + httpd.conf verified."
echo "---------------------------------------------"
```

---
### ✅ Bash Script 5️⃣ connect-rds.sh

```
#!/bin/bash

# ===============================
# CONFIGURATION
# ===============================

# Secret Name or ARN
SECRET_ID="CafeDevDBSM"
AWS_REGION="us-east-1"

# ===============================
# FETCH SECRET
# ===============================

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

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
# CONNECT TO MYSQL (NO DB NAME)
# ===============================

echo "✅ Connecting to RDS MySQL (no database selected)..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS"
```

---
### ✅ Bash Script 6️⃣ deploy_master.sh

```
#!/bin/bash

# ============================================================
# ☕ CHARLIE CAFE — MASTER DEPLOYMENT ORCHESTRATOR
# ============================================================
#
# PURPOSE:
# This script runs ALL DevOps deployment scripts in strict order:
#
#   1️⃣ EC2 App Deployment (deploy_via_ssm.sh)
#   2️⃣ RDS Database Setup (charlie_cafe_devops-rds_setup_full.sh)
#   3️⃣ Lambda Deployment (github-aws-devops-lambda-deploy.sh)
#
# RULES:
# ✔ Each script must complete successfully before next starts
# ✔ If ANY script fails → STOP pipeline immediately
# ✔ Fully production-safe execution flow
#
# USAGE:
# Called from AWS SSM via GitHub Actions CI/CD pipeline
#
# ============================================================

set -euo pipefail   # 🚨 STRICT MODE (VERY IMPORTANT)

# ============================================================
# 🎨 COLORS FOR LOGGING
# ============================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}======================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}======================================================${NC}\n"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
  echo -e "${RED}❌ $1${NC}\n"
}

print_step() {
  echo -e "${YELLOW}🚀 $1${NC}\n"
}

# ============================================================
# 📁 BASE PATH CONFIGURATION
# ============================================================
BASE_DIR="/home/ec2-user/charlie-cafe-devops"

EC2_SCRIPT="$BASE_DIR/deploy_via_ssm.sh"
RDS_SCRIPT="$BASE_DIR/charlie_cafe_devops-rds_setup_full.sh"
LAMBDA_SCRIPT="$BASE_DIR/github-aws-devops-lambda-deploy.sh"

print_header "☕ CHARLIE CAFE MASTER DEPLOYMENT STARTED"

# ============================================================
# 1️⃣ STEP 1 - EC2 DEPLOYMENT
# ============================================================
print_step "STEP 1: Running EC2 Deployment Script"

if [ ! -f "$EC2_SCRIPT" ]; then
  print_error "EC2 script not found: $EC2_SCRIPT"
  exit 1
fi

chmod +x "$EC2_SCRIPT"

bash "$EC2_SCRIPT"

print_success "STEP 1 COMPLETED: EC2 Deployment Successful"

# ============================================================
# 2️⃣ STEP 2 - RDS SETUP
# ============================================================
print_step "STEP 2: Running RDS Setup Script"

if [ ! -f "$RDS_SCRIPT" ]; then
  print_error "RDS script not found: $RDS_SCRIPT"
  exit 1
fi

chmod +x "$RDS_SCRIPT"

bash "$RDS_SCRIPT"

print_success "STEP 2 COMPLETED: RDS Setup Successful"

# ============================================================
# 3️⃣ STEP 3 - LAMBDA DEPLOYMENT
# ============================================================
print_step "STEP 3: Running Lambda Deployment Script"

if [ ! -f "$LAMBDA_SCRIPT" ]; then
  print_error "Lambda script not found: $LAMBDA_SCRIPT"
  exit 1
fi

chmod +x "$LAMBDA_SCRIPT"

bash "$LAMBDA_SCRIPT"

print_success "STEP 3 COMPLETED: Lambda Deployment Successful"

# ============================================================
# 🎉 FINAL SUCCESS
# ============================================================
print_header "☕ ALL DEPLOYMENTS COMPLETED SUCCESSFULLY"

echo -e "${GREEN}✔ EC2 Deployment Done${NC}"
echo -e "${GREEN}✔ RDS Setup Done${NC}"
echo -e "${GREEN}✔ Lambda Deployment Done${NC}"

echo -e "\n${GREEN}🚀 CHARLIE CAFE FULL SYSTEM IS NOW PRODUCTION READY!${NC}\n"
```

---
### ✅ Bash Script 7️⃣ deploy_via_ssm.sh

```
#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — Auto Deployment Script via SSM
# ----------------------------------------------------------
# This script is intended to run via AWS SSM or manually on EC2.
# It uses git pull, builds docker, and redeploys container.
# Compatible with GitHub Actions CI/CD using AWS Access Keys.
# ==========================================================

# -----------------------------
# 0️⃣ Variables (edit as needed)
# -----------------------------
APP_DIR="/home/ec2-user/charlie-cafe-devops"
DOCKER_IMAGE="charlie-cafe"
DOCKER_CONTAINER="cafe-app"
GIT_BRANCH="main"

# -----------------------------
# 1️⃣ Ensure app directory exists
# -----------------------------
if [ ! -d "$APP_DIR" ]; then
    echo "📥 App directory not found, cloning repository..."
    git clone -b $GIT_BRANCH https://github.com/YOUR_USERNAME/charlie-cafe-devops.git "$APP_DIR"
else
    echo "✅ App directory exists, pulling latest changes..."
    cd "$APP_DIR" || exit
    git fetch origin $GIT_BRANCH
    git reset --hard origin/$GIT_BRANCH
fi

# -----------------------------
# 2️⃣ Enter app directory
# -----------------------------
cd "$APP_DIR" || exit

# -----------------------------
# 3️⃣ Build Docker Image
# -----------------------------
echo "🐳 Building Docker image..."
docker build -t $DOCKER_IMAGE -f docker/apache-php/Dockerfile .

# -----------------------------
# 4️⃣ Stop & Remove Existing Container
# -----------------------------
echo "🛑 Stopping old container (if exists)..."
docker rm -f $DOCKER_CONTAINER || true

# -----------------------------
# 5️⃣ Run New Container
# -----------------------------
echo "🚀 Running new container..."
docker run -d -p 80:80 --name $DOCKER_CONTAINER $DOCKER_IMAGE

# -----------------------------
# 6️⃣ Health Check
# -----------------------------
echo "❤️ Running health check..."
if curl -f http://localhost/health.php >/dev/null 2>&1; then
    echo "✅ Health check passed"
else
    echo "❌ Health check FAILED"
    exit 1
fi

# -----------------------------
# 7️⃣ Success
# -----------------------------
echo "🎉 Deployment completed successfully!"
```

---
### ✅ Bash Script 8️⃣ ec2_docker_health.sh

```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — EC2 Docker & Apache Health Check
# ==========================================================
# This script:
#   1️⃣ Checks Docker is running
#   2️⃣ Navigates to the repo root
#   3️⃣ Builds Docker image
#   4️⃣ Removes old container
#   5️⃣ Runs new container
#   6️⃣ Performs local health check
# ==========================================================

set -e  # Exit immediately on error

# ----------------------------
# Colors for output
# ----------------------------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; }

# ----------------------------
# 1️⃣ Check Docker is running
# ----------------------------
systemctl is-active --quiet docker && pass "Docker running" || { fail "Docker not running"; exit 1; }

# ----------------------------
# 2️⃣ Navigate to repo root
# ----------------------------
REPO_DIR=~/charlie-cafe-devops
if [ ! -d "$REPO_DIR" ]; then
    fail "Repo directory $REPO_DIR not found!"
    exit 1
fi
cd "$REPO_DIR"
pass "Navigated to repo: $REPO_DIR"

# ----------------------------
# 3️⃣ Build Docker image
# ----------------------------
DOCKERFILE_DIR="$REPO_DIR/docker/apache-php"
if [ ! -f "$DOCKERFILE_DIR/Dockerfile" ]; then
    fail "Dockerfile not found in $DOCKERFILE_DIR"
    exit 1
fi

docker build -t charlie-cafe -f "$DOCKERFILE_DIR/Dockerfile" "$REPO_DIR" && pass "Docker image built successfully" || { fail "Docker build failed"; exit 1; }

# ----------------------------
# 4️⃣ Remove old container
# ----------------------------
docker rm -f charlie-cafe || true

# ----------------------------
# 5️⃣ Run new container
# ----------------------------
docker run -d -p 80:80 --name charlie-cafe charlie-cafe && pass "Container started" || { fail "Container failed"; exit 1; }

# ----------------------------
# 6️⃣ Wait a few seconds
# ----------------------------
sleep 10

# ----------------------------
# 7️⃣ Test Apache container
# ----------------------------
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$HTTP_STATUS" == "200" ]; then
    pass "Apache container responding on localhost"
else
    fail "Apache container NOT responding, HTTP $HTTP_STATUS"
    echo "Showing last 20 lines of container logs:"
    docker logs charlie-cafe | tail -n 20
    exit 1
fi
```

---
### ✅ Bash Script 9️⃣ ec2_git_auto_deploy.sh

```
#!/bin/bash

# ===============================
# ☕ Charlie Cafe — Git Auto Push
# ===============================

# Set variables
# GitHub repository SSH URL (example)
REPO="git@github.com:your github username/charlie-cafe-devops.git"
DIR="/home/ec2-user/charlie-cafe-devops"   # ⚠️ Use absolute path
COMMIT_MSG="${1:-Auto-deploy update}"

# -------------------------------------------------
# 0️⃣ Start ssh-agent and add deploy key
# -------------------------------------------------
eval "$(ssh-agent -s)" > /dev/null
ssh-add /home/ec2-user/.ssh/id_deploy > /dev/null 2>&1

# -------------------------------------------------
# 1️⃣ Clone repo if it doesn't exist
# -------------------------------------------------
if [ ! -d "$DIR/.git" ]; then
    echo "📥 Cloning repository..."
    git clone "$REPO" "$DIR"
else
    echo "✅ Repository already exists. Pulling latest changes..."
    cd "$DIR" || exit
    git pull origin main
fi

# -------------------------------------------------
# 2️⃣ Enter repo
# -------------------------------------------------
cd "$DIR" || exit

# -------------------------------------------------
# 3️⃣ Add, commit, push changes
# -------------------------------------------------
git add .
git commit -m "$COMMIT_MSG" || echo "⚠️ Nothing to commit."
git push origin main

echo "🚀 Auto-deploy complete!"
```

---
### ✅ Bash Script 🔟 ec2-cleanup.sh

```
#!/bin/bash

# ==========================================================
# 🧹 Charlie Cafe — Full EC2 Cleanup Script (Final Safe Version)
# ----------------------------------------------------------
# This script will remove:
#   ✅ Docker containers, images, volumes, networks
#   ✅ Docker & Docker Compose
#   ✅ MariaDB (MySQL client) and database files
#   ✅ Git
#   ✅ Optional DevOps tools (htop, nano, awscli, etc.)
#   ✅ Project folder charlie-cafe-devops
# ==========================================================

set -e  # Exit immediately if a command fails
echo "🚀 Starting full cleanup of EC2 environment..."

# ==========================================================
# 1️⃣ Stop and Remove Docker Containers
# ==========================================================
echo -e "\n🔹 Stopping all running Docker containers..."
docker ps -q | xargs -r docker stop

echo "🔹 Removing all Docker containers..."
docker ps -a -q | xargs -r docker rm -f

# ==========================================================
# 2️⃣ Remove Docker Images, Volumes, Networks
# ==========================================================
echo -e "\n🔹 Listing Docker images (optional check)..."
docker images -a

echo "🔹 Removing all Docker images..."
docker images -a -q | xargs -r docker rmi -f

echo "🔹 Removing all Docker volumes..."
docker volume ls -q | xargs -r docker volume rm

echo "🔹 Removing all Docker networks..."
docker network ls -q | xargs -r docker network rm

# ==========================================================
# 3️⃣ Uninstall Docker & Docker Compose
# ==========================================================
echo -e "\n🔹 Stopping Docker service..."
sudo systemctl stop docker || true
sudo systemctl disable docker || true

echo "🔹 Removing Docker packages..."
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine || true

echo "🔹 Removing Docker Compose binary..."
sudo rm -f /usr/local/lib/docker/cli-plugins/docker-compose

echo "🔹 Removing leftover Docker folders..."
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# ==========================================================
# 4️⃣ Uninstall MariaDB (MySQL client)
# ==========================================================
echo -e "\n🔹 Stopping MariaDB service..."
sudo systemctl stop mariadb || true
sudo systemctl disable mariadb || true

echo "🔹 Removing MariaDB packages..."
sudo dnf remove -y mariadb105 mariadb105-server mariadb105-libs mariadb105-common || true

echo "🔹 Removing leftover database files..."
sudo rm -rf /var/lib/mysql
sudo rm -rf /etc/my.cnf.d

# ==========================================================
# 5️⃣ Uninstall Git
# ==========================================================
echo -e "\n🔹 Removing Git..."
sudo dnf remove -y git || true

# ==========================================================
# 6️⃣ Remove Other DevOps Tools (optional)
# ==========================================================
echo -e "\n🔹 Removing DevOps tools..."
# curl-minimal is protected, so we remove only non-protected curl packages
sudo dnf remove -y htop unzip wget nano vim tar awscli curl || true

# ==========================================================
# 7️⃣ Remove Project Folder
# ==========================================================
echo -e "\n🔹 Removing Charlie Cafe project folder..."
rm -rf ~/charlie-cafe-devops

# ==========================================================
# ✅ Cleanup Completed
# ==========================================================
echo -e "\n🎉 EC2 cleanup completed successfully!"
echo "You now have a fresh environment ready for DevOps scripts."
```

---
### ✅ Bash Script 1️⃣1️⃣ ec2-export-s3.sh

```
#!/bin/bash
# =========================================================
# Upload HTML + Bash Scripts to S3 (Folder + ZIP) - Fully Final
# =========================================================
# Features:
# - Automatically creates folder structure in S3
# - Uploads both folder and ZIP archive
# - Handles spaces and special characters in filenames
# - Works even if script runs via sudo
# - Verifies all uploads
# - Generates final report
# =========================================================

set -euo pipefail

# =========================
# CONFIGURATION
# =========================
LOCAL_HTML_DIR="/var/www/html"                      # Local html folder to upload
EC2_USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")   # Correct home directory even if run with sudo
LOCAL_BASH_DIR="$EC2_USER_HOME"                     # Local directory containing .sh scripts
S3_BUCKET="charlie-cafe-s3-bucket"                 # Your S3 bucket name
S3_ROOT_FOLDER="charlie-cafe-web-drive"            # Virtual folder in S3

# HTML targets
S3_HTML_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html"
S3_HTML_ZIP="s3://$S3_BUCKET/$S3_ROOT_FOLDER/html.zip"

# Bash script targets
S3_BASH_FOLDER="s3://$S3_BUCKET/$S3_ROOT_FOLDER/bash script"
S3_BASH_ZIP="s3://$S3_BUCKET/$S3_ROOT_FOLDER/bash_script.zip"

# Temporary ZIP files
ZIP_HTML_FILE="/tmp/html_$(date +%Y%m%d%H%M%S).zip"
ZIP_BASH_FILE="/tmp/bash_$(date +%Y%m%d%H%M%S).zip"

# =========================
# 1️⃣ Upload HTML folder + ZIP
# =========================
echo "📥 Uploading HTML folder to S3..."
aws s3 cp "$LOCAL_HTML_DIR" "$S3_HTML_FOLDER/" --recursive
echo "✅ HTML folder uploaded."

echo "📦 Creating ZIP archive of HTML..."
zip -r -q "$ZIP_HTML_FILE" "$LOCAL_HTML_DIR"
aws s3 cp "$ZIP_HTML_FILE" "$S3_HTML_ZIP"
echo "✅ HTML ZIP uploaded."

# =========================
# 2️⃣ Upload Bash scripts folder + ZIP
# =========================
echo "📥 Uploading all .sh files from $LOCAL_BASH_DIR to S3..."

# Find all .sh files in home directory
mapfile -t SH_FILES < <(find "$LOCAL_BASH_DIR" -maxdepth 1 -type f -name "*.sh")

if [ ${#SH_FILES[@]} -eq 0 ]; then
    echo "⚠️ No .sh files found in $LOCAL_BASH_DIR"
else
    # Create temp folder for .sh upload
    TMP_BASH_DIR="/tmp/bash_upload_$(date +%s)"
    mkdir -p "$TMP_BASH_DIR"

    # Copy .sh files to temp folder
    for f in "${SH_FILES[@]}"; do
        cp "$f" "$TMP_BASH_DIR/"
    done

    # Upload folder to S3
    aws s3 cp "$TMP_BASH_DIR" "$S3_BASH_FOLDER/" --recursive
    echo "✅ Bash scripts folder uploaded."

    # Create ZIP and upload
    zip -r -q "$ZIP_BASH_FILE" "$TMP_BASH_DIR"
    aws s3 cp "$ZIP_BASH_FILE" "$S3_BASH_ZIP"
    echo "✅ Bash scripts ZIP uploaded."

    # Cleanup temp files
    rm -rf "$TMP_BASH_DIR" "$ZIP_BASH_FILE"
fi

# Cleanup HTML ZIP
rm -f "$ZIP_HTML_FILE"

# =========================
# 3️⃣ Verification
# =========================
echo "🔍 Verifying uploads..."

# HTML folder
HTML_S3_FILES=$(aws s3 ls "$S3_HTML_FOLDER/" --recursive | awk '{$1=$2=$3=""; print substr($0,4)}')
echo "📁 HTML files in S3:"
echo "$HTML_S3_FILES"

# Bash folder
BASH_S3_FILES=$(aws s3 ls "$S3_BASH_FOLDER/" --recursive | awk '{$1=$2=$3=""; print substr($0,4)}')
echo "📁 Bash scripts in S3:"
echo "$BASH_S3_FILES"

# ZIP files
echo "🔹 Checking ZIP files existence..."
aws s3 ls "$S3_HTML_ZIP" > /dev/null && echo "✅ HTML ZIP exists in S3." || echo "⚠️ HTML ZIP missing!"
aws s3 ls "$S3_BASH_ZIP" > /dev/null && echo "✅ Bash ZIP exists in S3." || echo "⚠️ Bash ZIP missing!"

echo "✅ Charlie Cafe S3 upload completed successfully!"
```

---
### ✅ Bash Script 1️⃣2️⃣ ECR_CI-CD_TEST.sh

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — SIMPLE DEVOPS HELPER SCRIPT
# ----------------------------------------------------------
# ✔ Auto Detect ECR URI
# ✔ Auto Detect ALB DNS
# ✔ Push Code to Trigger CI/CD
# ==========================================================

echo "🚀 Starting Simple DevOps Helper..."

# -------------------------------
# 🔧 AUTO CONFIG
# -------------------------------
AWS_REGION=$(aws configure get region)

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Get ECR Repo (first repo)
ECR_REPO=$(aws ecr describe-repositories \
  --query "repositories[0].repositoryName" \
  --output text)

ECR_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO"

# Get ALB DNS
ALB_DNS=$(aws elbv2 describe-load-balancers \
  --query "LoadBalancers[0].DNSName" \
  --output text)

echo "----------------------------------------"
echo "📦 ECR URI: $ECR_URI"
echo "🌐 ALB DNS: $ALB_DNS"
echo "----------------------------------------"

# -------------------------------
# 🚀 TRIGGER CI/CD
# -------------------------------
echo "🔄 Triggering GitHub Pipeline..."

git add .

git commit -m "🚀 Auto Deploy $(date +'%Y-%m-%d %H:%M:%S')" || echo "⚠️ Nothing to commit"

git push

if [ $? -ne 0 ]; then
  echo "❌ Git Push Failed"
  exit 1
fi

# -------------------------------
# ✅ DONE
# -------------------------------
echo "----------------------------------------"
echo "✅ CI/CD Triggered Successfully"
echo "🌐 App URL: http://$ALB_DNS"
echo "----------------------------------------"
```

---
### ✅ Bash Script 1️⃣3️⃣ github_logs_setup_capture.sh

```
#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — GitHub CLI Setup & Capture Logs
# ==========================================================
# This script:
#   1️⃣ Installs GitHub CLI (gh)
#   2️⃣ Authenticates CLI with your deploy key / PAT
#   3️⃣ Lists workflows & workflow runs
#   4️⃣ Captures logs to timestamped files
# ==========================================================

set -e

REPO_DIR=~/charlie-cafe-devops
LOG_DIR=$REPO_DIR/github_logs
LIMIT=100  # Number of workflow runs to fetch

echo "=================================================="
echo "🚀 Starting GitHub CLI setup & log capture"
echo "=================================================="

# ----------------------------------------------------------
# Step 1: Install GitHub CLI
# ----------------------------------------------------------
echo "🌐 Step 1: Installing GitHub CLI..."

if ! command -v gh &>/dev/null; then
    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install -y gh
else
    echo "✅ gh already installed"
fi

gh --version

# ----------------------------------------------------------
# Step 2: Authenticate GitHub CLI
# ----------------------------------------------------------
echo ""
echo "🌐 Step 2: Authenticate GitHub CLI"
echo "Please login via SSH (matches your deploy key) or token"
echo "Follow prompts in terminal or browser if needed..."
gh auth login
gh auth status

# ----------------------------------------------------------
# Step 3: Prepare log directory
# ----------------------------------------------------------
mkdir -p "$LOG_DIR"
echo "📂 Logs will be saved in: $LOG_DIR"

# ----------------------------------------------------------
# Step 4: Navigate to repo
# ----------------------------------------------------------
cd "$REPO_DIR" || { echo "❌ Repo directory not found!"; exit 1; }

echo ""
echo "📁 Repository: $(pwd)"
ls -la

# Check remote URL
echo ""
echo "🔗 Git remote URL:"
git remote -v

# Check Git status
echo ""
echo "📄 Git status:"
git status

# ----------------------------------------------------------
# Step 5: List workflows
# ----------------------------------------------------------
echo ""
echo "🔎 Listing workflows..."
gh workflow list

# ----------------------------------------------------------
# Step 6: List latest workflow runs
# ----------------------------------------------------------
echo ""
echo "🔎 Listing latest $LIMIT workflow runs..."
gh run list --limit $LIMIT

# ----------------------------------------------------------
# Step 7: Capture logs for all workflow runs
# ----------------------------------------------------------
echo ""
echo "📥 Capturing logs for workflow runs..."

for run_id in $(gh run list --limit $LIMIT --json databaseId -q '.[].databaseId'); do
    created=$(gh run view $run_id --json createdAt -q '.createdAt' | tr -d '"')
    timestamp=$(date -d "$created" +%Y%m%d_%H%M%S)
    filename="$LOG_DIR/github_logs_${run_id}_$timestamp.txt"
    
    echo "📄 Saving logs for run $run_id -> $filename"
    gh run view $run_id --log > "$filename"
done

echo "✅ All logs saved successfully!"

# ----------------------------------------------------------
# Step 8: Optional: Live streaming instructions
# ----------------------------------------------------------
echo ""
echo "📡 To stream logs live for a workflow run:"
echo "gh run watch <run_id>"
echo "Replace <run_id> with your workflow run ID"

echo "=================================================="
echo "🎉 GitHub CLI setup & log capture complete!"
echo "=================================================="
```

---
### ✅ Bash Script 1️⃣4️⃣ github-aws-devops-lambda-deploy.sh

```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — Fully Automated Lambda Deployment
# ==========================================================
# Features:
# 1. Pull latest code from GitHub
# 2. Build and publish PyMySQL Lambda layer
# 3. Update existing Lambda functions code safely
# 4. Attach PyMySQL layer to all Lambdas
# 5. Waits properly to avoid ResourceConflictException
# ==========================================================

set -euo pipefail

# -------------------------------
# CONFIGURATION
# -------------------------------
AWS_REGION="${AWS_REGION:-us-east-1}"
GITHUB_REPO="https://github.com/your github username /charlie-cafe-devops.git"
LOCAL_REPO="charlie-cafe-devops"
LAMBDA_SUBDIR="app/backend/lambda"
LAYER_NAME="pymysql-layer"
LAYER_PACKAGE="pymysql-layer.zip"
PYTHON_RUNTIME="python3.10"

LAMBDAS=(
  "CafeOrderProcessor:CafeOrderProcessor.py"
  "CafeMenuLambda:CafeMenuLambda.py"
  "CafeOrderStatusLambda:CafeOrderStatusLambda.py"
  "GetOrderStatusLambda:GetOrderStatusLambda.py"
  "CafeOrderWorkerLambda:CafeOrderWorkerLambda.py"
  "AdminMarkPaidLambda:AdminMarkPaidLambda.py"
  "CafeAnalyticsLambda:CafeAnalyticsLambda.py"
  "hr-attendance:hr-attendance.py"
  "hr-employee-profile:hr-employee-profile.py"
  "hr-attendance-history:hr-attendance-history.py"
  "hr-leaves-holidays:hr-leaves-holidays.py"
  "cafe-attendance-admin-service:cafe-attendance-admin-service.py"
)

# -------------------------------
# FETCH AWS ACCOUNT ID
# -------------------------------
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"

# -------------------------------
# CLONE OR UPDATE GITHUB
# -------------------------------
if [[ -d "$LOCAL_REPO" ]]; then
  echo "📦 Updating repo..."
  cd "$LOCAL_REPO"
  git reset --hard
  git pull origin main
  cd ..
else
  echo "📦 Cloning repo..."
  git clone "$GITHUB_REPO"
fi
echo "✅ Repo ready"

# -------------------------------
# BUILD PYMYSQL LAYER
# -------------------------------
echo "🏗️ Building PyMySQL Lambda Layer..."
rm -rf python "$LAYER_PACKAGE"
mkdir python
pip3 install pymysql -t python/ --no-cache-dir > /dev/null
zip -r "$LAYER_PACKAGE" python > /dev/null
rm -rf python
echo "✅ Layer packaged"

# -------------------------------
# PUBLISH LAYER
# -------------------------------
LAYER_ARN=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --zip-file fileb://"$LAYER_PACKAGE" \
  --compatible-runtimes python3.10 python3.11 python3.12 \
  --query 'LayerVersionArn' --output text)
echo "✅ Layer published: $LAYER_ARN"

# -------------------------------
# STEP 1: UPDATE ALL LAMBDA CODES
# -------------------------------
echo "🚀 Updating Lambda codes..."
for FUNC in "${LAMBDAS[@]}"; do
  FUNC_NAME="${FUNC%%:*}"
  FILE_NAME="${FUNC##*:}"
  ZIP_FILE="${FUNC_NAME}.zip"

  zip -j "$ZIP_FILE" "$LOCAL_REPO/$LAMBDA_SUBDIR/$FILE_NAME" > /dev/null

  echo "🔄 Updating code for $FUNC_NAME..."
  aws lambda update-function-code --function-name "$FUNC_NAME" --zip-file fileb://"$ZIP_FILE"
  aws lambda wait function-updated --function-name "$FUNC_NAME"  # WAIT until update finishes

  rm -f "$ZIP_FILE"
  echo "✅ Code updated: $FUNC_NAME"
done

# -------------------------------
# STEP 2: ATTACH LAYER TO ALL LAMBDAS
# -------------------------------
echo "🔗 Attaching PyMySQL Layer to all Lambdas..."
for FUNC in "${LAMBDAS[@]}"; do
  FUNC_NAME="${FUNC%%:*}"
  echo "🔄 Updating configuration for $FUNC_NAME..."
  aws lambda update-function-configuration --function-name "$FUNC_NAME" --layers "$LAYER_ARN"
  aws lambda wait function-updated --function-name "$FUNC_NAME"
  echo "✅ Layer attached: $FUNC_NAME"
done

echo "🎉 All Lambda functions updated and layer attached successfully!"
```

---
---
### ✅ Bash Script 1️⃣5️⃣ Lamp Server Script.sh

```
#!/bin/bash
# =========================================================
# ☕ Charlie Cafe — EC2 Bootstrap Script (Production Ready)
# Amazon Linux 2023
# LAMP + Docker + DevOps Tools
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
# 3️⃣ Install PHP + MySQL Support
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
# 5️⃣ Install MySQL Client (MariaDB)
# ---------------------------------------------------------
dnf install -y mariadb105

# ---------------------------------------------------------
# 6️⃣ Install Docker
# ---------------------------------------------------------
dnf install -y docker

systemctl enable docker
systemctl start docker

# Allow ec2-user to run docker without sudo
usermod -aG docker ec2-user

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

---
---
### ✅ Bash Script 1️⃣6️⃣ lamp-verify.sh

```
#!/bin/bash
# LAMP Stack Quick Verification Script (Apache + PHP + MySQL client)
# Amazon Linux 2 / 2023 edition friendly
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

# ── 3. MySQL client installed? ────────────────────────────────────────
echo -n "3. MySQL client command ........................... "
if command -v mysql >/dev/null 2>&1; then
    MYSQL_VER=$(mysql --version 2>/dev/null | head -n1)
    ok "mysql client found ($MYSQL_VER)"
else
    fail "mysql client not found"
    ((FAILURES++))
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

# ── 8. Important directories permissions ──────────────────────────────
echo "8. Web root permissions check (/var/www/html)"
for dir in /var/www /var/www/html; do
    if [ -d "$dir" ]; then
        STAT=$(stat -c "%A %U:%G" "$dir")
        if [[ $STAT == drwxr-xr-x*apache* || $STAT == drwxr-xr-x*httpd* || $STAT == drwxr-xr-x*www-data* ]]; then
            ok "$dir → $STAT"
        else
            fail "$dir → $STAT"
            warn "Recommended: sudo chown -R apache:apache /var/www && sudo chmod -R 755 /var/www"
        fi
    else
        warn "Directory not found: $dir"
    fi
done

echo
echo "============================================================="
echo -n "               FINAL RESULT:  "

if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}ALL IMPORTANT CHECKS PASSED ✓${NC}"
else
    echo -e "${RED}$FAILURES failure(s) detected${NC}"
    echo "Review the ${RED}✗${NC} lines above"
fi
echo "============================================================="
echo

if [ $FAILURES -gt 0 ]; then
    echo "Quick fix suggestions:"
    echo "  • Apache not running → sudo systemctl start httpd"
    echo "  • PHP not loading    → sudo dnf/yum install php php-mysqlnd"
    echo "  • Wrong permissions  → sudo chown -R apache:apache /var/www"
    echo "                       → sudo chmod -R 755 /var/www"
    echo
fi
```

---
---
### ✅ Bash Script 1️⃣7️⃣ setup_charlie_cafe_db_full.sh

```
#!/bin/bash
# =============================================================
# ☕ Charlie Cafe — FULL RDS Setup & Verification Script
# Version: 8.0 (Production Ready)
#
# Features
# ✔ Colored output
# ✔ AWS Secrets Manager integration
# ✔ Secure temporary MySQL config
# ✔ Creates database
# ✔ Creates all tables
# ✔ Inserts sample data for ALL tables
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
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"

print_header "☕ Charlie Cafe RDS Setup Starting"

# =============================================================
# CHECK REQUIRED TOOLS
# =============================================================
print_header "Checking Required Tools"

command -v mysql >/dev/null 2>&1 || sudo dnf install -y mariadb105
command -v jq >/dev/null 2>&1 || sudo dnf install -y jq
command -v aws >/dev/null 2>&1 || { print_error "AWS CLI not installed"; exit 1; }

print_success "All tools ready"

# =============================================================
# FETCH RDS CREDENTIALS
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

print_success "Credentials loaded"

# =============================================================
# CREATE TEMP MYSQL CONFIG
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
print_header "Testing RDS Connection"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT VERSION();"
print_success "RDS connection successful"

# =============================================================
# CREATE DATABASE
# =============================================================
print_header "Ensuring Database Exists"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database verified"

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
# FINAL VERIFICATION
# =============================================================
print_header "RDS Verification Steps"

# 1️⃣ Verify Database Exists
echo "1️⃣ Verify Database Exists:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SHOW DATABASES LIKE '$DB_NAME';"

# 2️⃣ Verify Current Database
echo "2️⃣ Verify Current Database:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SELECT DATABASE();"

# 3️⃣ Show Tables
echo "3️⃣ Show Tables:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SHOW TABLES;"

# 4️⃣ Describe & SELECT for each table
for table in orders employees attendance holidays leaves
do
    echo "---- DESCRIBE $table ----"
    mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; DESCRIBE $table;"
    
    echo "---- SELECT * FROM $table ----"
    mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SELECT * FROM $table;"
done

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
# =============================================================
print_header "☕ Charlie Cafe RDS Setup Completed Successfully"

echo -e "${GREEN}✔ RDS Connection Successful${NC}"
echo -e "${GREEN}✔ Database Created/Verified${NC}"
echo -e "${GREEN}✔ Tables Created${NC}"
echo -e "${GREEN}✔ Sample Data Inserted${NC}"
echo -e "${GREEN}✔ Schemas Verified${NC}"
echo -e "${GREEN}✔ Row Counts Verified${NC}"
echo -e "${GREEN}✔ Analytics Queries Successful${NC}"
echo -e "${GREEN}✔ Full RDS Verification Completed${NC}"
```

---
### ✅ Bash Script 1️⃣8️⃣ upload-pymysql-layer.sh

```
#!/bin/bash
# =========================================
# Bash Script: Create PyMySQL Lambda Layer
# Correct Structure for AWS Lambda
# =========================================

set -e  # Exit on error

# -------- CONFIGURATION --------
AWS_DEFAULT_REGION="us-east-1"

S3_BUCKET="charlie-cafe-s3-bucket"
S3_KEY="layers/pymysql-layer.zip"

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

# -------- STEP 2: Create Correct Folder Structure --------
echo "📁 Creating Lambda layer structure..."
mkdir -p "$PYTHON_DIR"

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

# -------- STEP 6: Upload to S3 --------
echo "☁️ Uploading to S3..."
aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$S3_KEY" --region "$AWS_DEFAULT_REGION"

echo "✅ DONE!"
echo "Attach this layer to Lambda (Python 3.9 / 3.10 / 3.11)"
```

---
### ✅ Bash Script 1️⃣9️⃣ verify-devops-env.sh

```
#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — COMPLETE DevOps & AWS/GitHub Verification + Auto Sync
# ==========================================================
# This script performs all environment verifications:
#   ✅ Required tools
#   ✅ Versions
#   ✅ Docker status & test container
#   ✅ Project directory & Git
#   ✅ SSH & GitHub authentication
#   ✅ Git commit & push test
#   ✅ GitHub clone test
#   ✅ Network check
#   ✅ AWS Secrets & RDS
#   ✅ AWS CLI verification
#   ✅ GitHub repo verification
#   ✅ Auto-sync project with GitHub
#   ✅ ECR repository verification
# ==========================================================

# ---------------- VARIABLES ----------------
# Replace these with your own details
AWS_ACCESS_KEY_ID="your access id"
AWS_SECRET_ACCESS_KEY="your access key"
AWS_REGION="us-east-1"
GITHUB_USERNAME="your-github-username"
GITHUB_PASSWORD="your-github-token"
GITHUB_REPO="charlie-cafe-devops"
ECR_REPO="your-ecr-repo-name"          # Optional
SECRET_NAME="CafeDevDBSM"

# ---------------- PROJECT DIRECTORIES ----------------
# Add all possible paths to check
PROJECT_DIRS=(
  "/home/ec2-user/charlie-cafe-devops"
  "/root/charlie-cafe-devops"
)

PROJECT_DIR_FOUND=""
for DIR in "${PROJECT_DIRS[@]}"; do
    if [ -d "$DIR/.git" ]; then
        PROJECT_DIR_FOUND="$DIR"
        break
    fi
done

if [ -z "$PROJECT_DIR_FOUND" ]; then
    PROJECT_DIR="${PROJECT_DIRS[0]}"  # fallback to first path for cloning
else
    PROJECT_DIR="$PROJECT_DIR_FOUND"
fi

# ---------------- COLORS ----------------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

pass() { echo -e "${GREEN}✅ $1${NC}"; ((PASS_COUNT++)); }
fail() { echo -e "${RED}❌ $1${NC}"; ((FAIL_COUNT++)); }
warn() { echo -e "${YELLOW}⚠️ $1${NC}"; }

section() {
  echo ""
  echo -e "${BLUE}==================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}==================================================${NC}"
}

echo -e "${BLUE}🚀 Starting Full Environment Verification + AWS/GitHub Sync${NC}"

# ==========================================================
# 1️⃣ REQUIRED TOOLS
# ==========================================================
section "🔎 Step 1: Required Tools"

for cmd in aws jq mysql docker git curl ssh; do
    command -v $cmd &>/dev/null && pass "$cmd installed" || fail "$cmd NOT installed"
done

# ==========================================================
# 2️⃣ VERSION CHECKS
# ==========================================================
section "📦 Step 2: Versions"

aws --version 2>/dev/null
jq --version 2>/dev/null
mysql --version 2>/dev/null
docker --version 2>/dev/null
git --version 2>/dev/null
curl --version 2>/dev/null
ssh -V 2>/dev/null

# ==========================================================
# 3️⃣ DOCKER STATUS + DETAILS
# ==========================================================
section "🐳 Step 3: Docker Verification"

if systemctl is-active --quiet docker; then
    pass "Docker running"
else
    fail "Docker NOT running"
    sudo systemctl start docker
fi

docker info &>/dev/null && pass "Docker info OK" || fail "Docker info failed"

echo "🔹 Docker Images:"
docker images

echo "🔹 Running Containers:"
docker ps

echo "🔹 All Containers:"
docker ps -a

# ==========================================================
# 4️⃣ APACHE TEST CONTAINER
# ==========================================================
section "🌐 Step 4: Apache Container Test"

TEST_CONTAINER="verify-apache-test"
docker rm -f $TEST_CONTAINER >/dev/null 2>&1

docker run -d --name $TEST_CONTAINER -p 8080:80 httpd:latest >/dev/null
sleep 5

curl -s http://localhost:8080 >/dev/null && pass "Apache 8080 OK" || fail "Apache 8080 failed"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)

[ "$HTTP_STATUS" == "200" ] && pass "App running on port 80" || warn "App not on port 80"

echo "🔹 Container Logs:"
docker logs $TEST_CONTAINER | head -n 5

docker rm -f $TEST_CONTAINER >/dev/null

# ==========================================================
# 5️⃣ PROJECT + GIT
# ==========================================================
section "📂 Step 5: Project & Git"

if [ -d "$PROJECT_DIR" ]; then
    pass "Project directory exists at $PROJECT_DIR"
    cd "$PROJECT_DIR" || exit

    git status &>/dev/null && pass "Git repo OK" || fail "Not a git repo"

    echo "🔹 Directory:"
    ls -la

    echo "🔹 Git Remote:"
    git remote -v

else
    fail "Project directory missing"
fi

# ==========================================================
# 6️⃣ SSH + GITHUB AUTH
# ==========================================================
section "🔐 Step 6: SSH & GitHub"

ls -l ~/.ssh

[ -f ~/.ssh/id_deploy ] && pass "Private key exists" || fail "Private key missing"
[ -f ~/.ssh/id_deploy.pub ] && pass "Public key exists" || fail "Public key missing"

ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated"

[ $? -eq 0 ] && pass "GitHub SSH OK" || fail "GitHub SSH failed"

# ==========================================================
# 7️⃣ GIT TEST (COMMIT + PUSH)
# ==========================================================
section "🧪 Step 7: Git Push Test"

TEST_FILE="test_auto_deploy.txt"

echo "# Test $(date)" >> $TEST_FILE
git add $TEST_FILE
git commit -m "Test commit $(date)" >/dev/null 2>&1

if git push origin main >/dev/null 2>&1; then
    pass "Git push successful"
else
    fail "Git push failed"
fi

rm -f $TEST_FILE
git add . >/dev/null 2>&1
git commit -m "Cleanup test file" >/dev/null 2>&1
git push origin main >/dev/null 2>&1

# ==========================================================
# 8️⃣ GITHUB CLONE TEST
# ==========================================================
section "🌍 Step 8: GitHub Clone Test"

TEST_DIR="$HOME/github_test_repo"
rm -rf $TEST_DIR

if git clone https://github.com/octocat/Hello-World.git $TEST_DIR; then
    pass "GitHub clone OK"
    cd $TEST_DIR
    git pull
    git log -1 --oneline
else
    fail "GitHub clone failed"
fi

# ==========================================================
# 9️⃣ NETWORK CHECK
# ==========================================================
section "🌐 Step 9: Network"

ping -c 2 github.com >/dev/null 2>&1 && pass "Internet OK" || fail "No Internet"

# ==========================================================
# 🔟 AWS + RDS
# ==========================================================
section "🗄️ Step 10: AWS + RDS"

export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_NAME \
  --region $AWS_REGION \
  --query SecretString \
  --output text 2>/dev/null)

if [ $? -eq 0 ]; then
    pass "AWS Secret fetched"

    DB_HOST=$(echo $SECRET_JSON | jq -r .host)
    DB_USER=$(echo $SECRET_JSON | jq -r .username)
    DB_PASS=$(echo $SECRET_JSON | jq -r .password)

else
    fail "AWS Secret failed"
fi

if [ -n "$DB_HOST" ]; then
    echo "SELECT NOW();" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" &>/dev/null \
        && pass "RDS connection OK" \
        || fail "RDS connection failed"
fi

# ==========================================================
# 11️⃣ AWS CLI VERIFICATION
# ==========================================================
section "☁️ Step 11: AWS CLI Verification"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text 2>/dev/null || echo "")
if [[ -z "$AWS_ACCOUNT_ID" ]]; then
    fail "Unable to fetch AWS Account ID"
else
    pass "AWS Account ID: $AWS_ACCOUNT_ID"
fi

# ==========================================================
# 12️⃣ GITHUB REPO VERIFICATION + AUTO SYNC
# ==========================================================
section "🔄 Step 12: GitHub Repo Verification & Auto Sync"

GITHUB_API_URL="https://api.github.com/repos/$GITHUB_USERNAME/$GITHUB_REPO"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -u "$GITHUB_USERNAME:$GITHUB_PASSWORD" $GITHUB_API_URL)

if [[ "$HTTP_STATUS" -eq 200 ]]; then
    pass "GitHub repository is accessible"
else
    fail "Cannot access GitHub repository. HTTP status: $HTTP_STATUS"
fi

echo "Syncing local project directory: $PROJECT_DIR"

if [[ ! -d "$PROJECT_DIR/.git" ]]; then
    echo "Repo not found locally. Cloning..."
    git clone "https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com/$GITHUB_USERNAME/$GITHUB_REPO.git" "$PROJECT_DIR"
else
    echo "Repo exists. Pulling latest changes..."
    cd "$PROJECT_DIR"
    git pull origin main
fi

cd "$PROJECT_DIR"

if [[ -n "$(git status --porcelain)" ]]; then
    echo "Detected local changes. Committing and pushing..."
    git add .
    git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
    pass "Local changes pushed to GitHub"
else
    pass "No local changes detected. Nothing to push."
fi

# ==========================================================
# 13️⃣ AWS ECR REPOSITORY VERIFICATION (OPTIONAL)
# ==========================================================
section "📦 Step 13: AWS ECR Verification"

if [[ -n "$ECR_REPO" ]]; then
    aws ecr describe-repositories --repository-names "$ECR_REPO" --region "$AWS_REGION" >/dev/null 2>&1 \
        && pass "ECR repository exists" \
        || warn "ECR repository does not exist or cannot access"
fi

# ==========================================================
# FINAL RESULT
# ==========================================================
section "📊 FINAL RESULT"

TOTAL=$((PASS_COUNT + FAIL_COUNT))
SUCCESS=$((PASS_COUNT * 100 / TOTAL))

echo -e "Total Checks : $TOTAL"
echo -e "${GREEN}Passed       : $PASS_COUNT${NC}"
echo -e "${RED}Failed       : $FAIL_COUNT${NC}"
echo -e "${YELLOW}Success Rate : $SUCCESS%${NC}"

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL CHECKS PASSED — READY 🚀${NC}"
elif [ $SUCCESS -ge 70 ]; then
    echo -e "${YELLOW}⚠️ PARTIAL SUCCESS — NEED FIXES${NC}"
else
    echo -e "${RED}❌ SYSTEM NOT READY${NC}"
fi

echo "=================================================="
```

---
### ✅ Bash Script 2️⃣0️⃣ verify-docker-git-env.sh

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — DOCKER + GIT ENV VERIFICATION
# File: verify-docker-git-env.sh
# Purpose: Verify Docker, Apache, Git, and GitHub connectivity
# ==========================================================

set -e

echo "=================================================="
echo "☕ Charlie Cafe — Full Environment Verification"
echo "=================================================="

# ----------------------------------------------------------
# 1️⃣ Check Docker Installation
# ----------------------------------------------------------
echo "🔹 Checking Docker installation..."
if command -v docker >/dev/null 2>&1; then
    echo "✅ Docker is installed"
else
    echo "❌ Docker is NOT installed"
    exit 1
fi

# ----------------------------------------------------------
# 2️⃣ Check Docker Service
# ----------------------------------------------------------
echo "🔹 Checking Docker service..."
if systemctl is-active --quiet docker; then
    echo "✅ Docker service is running"
else
    echo "⚠️ Docker not running, starting..."
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "✅ Docker started"
fi

# ----------------------------------------------------------
# 3️⃣ Docker Version Info
# ----------------------------------------------------------
echo "🔹 Docker version:"
docker --version

echo "🔹 Docker system info:"
docker info | head -n 10

# ----------------------------------------------------------
# 4️⃣ List Docker Images
# ----------------------------------------------------------
echo "🔹 Listing Docker images..."
docker images || echo "⚠️ No Docker images found"

# ----------------------------------------------------------
# 5️⃣ List Running Containers
# ----------------------------------------------------------
echo "🔹 Listing running containers..."
docker ps || echo "⚠️ No running containers"

# ----------------------------------------------------------
# 6️⃣ List All Containers (including stopped)
# ----------------------------------------------------------
echo "🔹 Listing ALL containers..."
docker ps -a

# ----------------------------------------------------------
# 7️⃣ Apache Container Test (Temporary)
# ----------------------------------------------------------
APACHE_CONTAINER="verify-apache-test"

# Remove old container if exists
if [ "$(docker ps -aq -f name=$APACHE_CONTAINER)" ]; then
    echo "⚠️ Removing existing test container..."
    docker rm -f $APACHE_CONTAINER
fi

echo "🔹 Starting Apache test container on port 8080..."
docker run -d --name $APACHE_CONTAINER -p 8080:80 httpd:latest

sleep 5

# ----------------------------------------------------------
# 8️⃣ Test Apache (Localhost 8080)
# ----------------------------------------------------------
echo "🔹 Testing Apache on localhost:8080..."
if curl -s http://localhost:8080 >/dev/null; then
    echo "✅ Apache is running on port 8080"
else
    echo "❌ Apache test failed on port 8080"
fi

# ----------------------------------------------------------
# 9️⃣ Test Apache (Port 80 if any app running)
# ----------------------------------------------------------
echo "🔹 Testing Apache on localhost:80..."
if curl -s http://localhost/ >/dev/null; then
    echo "✅ Service detected on port 80"
else
    echo "⚠️ No service running on port 80"
fi

# ----------------------------------------------------------
# 🔟 Show Container Logs
# ----------------------------------------------------------
echo "🔹 Showing Apache container logs..."
docker logs $APACHE_CONTAINER | head -n 5

# ----------------------------------------------------------
# 11️⃣ Git Installation Check
# ----------------------------------------------------------
echo "🔹 Checking Git installation..."
if command -v git >/dev/null 2>&1; then
    echo "✅ Git is installed"
    git --version
else
    echo "❌ Git is NOT installed"
    exit 1
fi

# ----------------------------------------------------------
# 12️⃣ Git Configuration Check
# ----------------------------------------------------------
echo "🔹 Git global config:"
git config --global --list || echo "⚠️ No global git config found"

# ----------------------------------------------------------
# 13️⃣ GitHub Connectivity Test
# ----------------------------------------------------------
GITHUB_TEST_DIR="$HOME/github_test_repo"
GITHUB_REPO="https://github.com/octocat/Hello-World.git"

# Cleanup old repo
if [ -d "$GITHUB_TEST_DIR" ]; then
    echo "⚠️ Removing old GitHub test repo..."
    rm -rf "$GITHUB_TEST_DIR"
fi

echo "🔹 Cloning GitHub repository..."
if git clone $GITHUB_REPO $GITHUB_TEST_DIR; then
    echo "✅ GitHub clone successful"

    cd $GITHUB_TEST_DIR

    echo "🔹 Running git pull..."
    git pull

    echo "🔹 Latest commit:"
    git log -1 --oneline

    echo "✅ GitHub working perfectly"
else
    echo "❌ GitHub connection failed"
fi

# ----------------------------------------------------------
# 14️⃣ Network Check
# ----------------------------------------------------------
echo "🔹 Checking internet connectivity..."
if ping -c 2 github.com >/dev/null 2>&1; then
    echo "✅ Internet access OK"
else
    echo "❌ No internet connectivity"
fi

# ----------------------------------------------------------
# 15️⃣ Cleanup
# ----------------------------------------------------------
echo "🔹 Cleaning up test container..."
docker rm -f $APACHE_CONTAINER >/dev/null

echo "=================================================="
echo "🎉 ALL CHECKS COMPLETED SUCCESSFULLY"
echo "=================================================="
```

---
### ✅ Bash Script 2️⃣1️⃣ apache_permissions.sh

```
#!/bin/bash

# ---------------------------------------------
# Charlie Cafe - Set Permissions Script
# ---------------------------------------------

# List of files
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
)

# List of directories
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

echo "---------------------------------------------"
echo "Verifying permissions..."
for file in "${FILES[@]}"; do
    perms=$(ls -l "$file" | awk '{print $1}')
    owner=$(ls -l "$file" | awk '{print $3":"$4}')
    echo "$file : $owner : $perms"
done

for dir in "${DIRS[@]}"; do
    perms=$(ls -ld "$dir" | awk '{print $1}')
    owner=$(ls -ld "$dir" | awk '{print $3":"$4}')
    echo "$dir : $owner : $perms"
done

echo "---------------------------------------------"
echo "All permissions set and verified!"
```

---
### ✅ Bash Script 2️⃣2️⃣  S3 TO EC2 EXPORT SCRIPT.sh

```
#!/bin/bash
# =========================================================
# S3 TO EC2 EXPORT SCRIPT
# =========================================================

# =========================
# ⚙️ CONFIGURATION
# =========================
AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_HERE"
AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY_HERE"
AWS_REGION="us-east-1"           # Replace with your bucket region
S3_BUCKET="charlie-cafe-s3-bucket"     # Replace with your S3 bucket name

# =========================
# FOLDERS TO SYNC
# =========================
S3_HTML_FOLDER="Charlie Cafe Code Drive/html/"
EC2_HTML_FOLDER="/var/www/html"

S3_BASH_FOLDER="Charlie Cafe Code Drive/bash script/"
EC2_BASH_FOLDER="/home/download"

# =========================
# EXPORT LOGIC
# =========================
echo "======================================================="
echo "Starting S3 to EC2 export..."
echo "Bucket: $S3_BUCKET"
echo "Region: $AWS_REGION"
echo "======================================================="

# Export HTML folder to /var/www/html
echo "Syncing HTML folder..."
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
aws s3 sync "s3://$S3_BUCKET/$S3_HTML_FOLDER" "$EC2_HTML_FOLDER" --region $AWS_REGION --delete

# Export bash script folder to /home/download
echo "Syncing bash scripts folder..."
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
aws s3 sync "s3://$S3_BUCKET/$S3_BASH_FOLDER" "$EC2_BASH_FOLDER" --region $AWS_REGION --delete

echo "======================================================="
echo "S3 export completed successfully!"
echo "HTML folder -> $EC2_HTML_FOLDER"
echo "Bash scripts folder -> $EC2_BASH_FOLDER"
echo "======================================================="
```

---
### ✅ Bash Script 2️⃣3️⃣ export_bash_output_s3.sh

```
#!/bin/bash
# =============================================================================
# ☕ Charlie Café — Enterprise Test & Verification Export System
#
# FEATURES:
# - ASCII company logo
# - Colorized PASS / FAIL (terminal-safe)
# - One PDF per service
# - One MASTER PDF
# - Header & footer (lab name + author + page no)
# - TXT / CSV / PDF → S3
#
# PLATFORM : Amazon Linux 2023
# PDF CORE : enscript + ghostscript (ROCK SOLID)
# =============================================================================

set -Eeuo pipefail

# -----------------------------------------------------------------------------
# LAB IDENTITY
# -----------------------------------------------------------------------------
LAB_NAME="Charlie Café ☕ — Test & Verification Lab"
AUTHOR_NAME="IT Charlie"
ENVIRONMENT="Amazon Linux 2023 (EC2)"

# -----------------------------------------------------------------------------
# AWS CONFIG
# -----------------------------------------------------------------------------
AWS_REGION="us-east-1"
S3_BUCKET="charlie-cafe-s3-bucket"
S3_PREFIX="Charlie-Cafe/Test-Verification"

# -----------------------------------------------------------------------------
# TEST SCRIPTS (SERVICE LEVEL)
# -----------------------------------------------------------------------------
TEST_SCRIPTS=(
  "./charlie_cafe_lab_test_verify.sh"
  # "./api_gateway_test.sh"
  # "./lambda_test.sh"
)

# -----------------------------------------------------------------------------
# COLORS (TERMINAL ONLY)
# -----------------------------------------------------------------------------
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# -----------------------------------------------------------------------------
# TIMESTAMP & WORKSPACE
# -----------------------------------------------------------------------------
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
BASE_DIR="/tmp/charlie-cafe-$TIMESTAMP"
MASTER_TXT="$BASE_DIR/master_report.txt"
mkdir -p "$BASE_DIR"

# -----------------------------------------------------------------------------
# ASCII LOGO
# -----------------------------------------------------------------------------
read -r -d '' ASCII_LOGO <<'EOF'
   ██████╗██╗  ██╗ █████╗ ██████╗ ██╗     ██╗███████╗
  ██╔════╝██║  ██║██╔══██╗██╔══██╗██║     ██║██╔════╝
  ██║     ███████║███████║██████╔╝██║     ██║█████╗
  ██║     ██╔══██║██╔══██║██╔══██╗██║     ██║██╔══╝
  ╚██████╗██║  ██║██║  ██║██║  ██║███████╗██║███████╗
   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝
                    ☕ CHARLIE CAFÉ
EOF

# -----------------------------------------------------------------------------
# INSTALL DEPENDENCIES
# -----------------------------------------------------------------------------
echo "📦 Installing prerequisites..."
sudo dnf install -y awscli enscript ghostscript coreutils util-linux
export AWS_DEFAULT_REGION="$AWS_REGION"
echo "✅ Ready"

# -----------------------------------------------------------------------------
# MASTER REPORT HEADER
# -----------------------------------------------------------------------------
{
  echo "$ASCII_LOGO"
  echo
  echo "$LAB_NAME"
  echo "Prepared by : $AUTHOR_NAME"
  echo "Environment : $ENVIRONMENT"
  echo "Generated   : $(date)"
  echo "============================================================"
  echo
} > "$MASTER_TXT"

TOTAL=0
PASSED=0
FAILED=0

# -----------------------------------------------------------------------------
# RUN TESTS (PER SERVICE)
# -----------------------------------------------------------------------------
for SCRIPT in "${TEST_SCRIPTS[@]}"; do
  ((TOTAL++))
  SERVICE_NAME="$(basename "$SCRIPT" .sh)"
  SERVICE_DIR="$BASE_DIR/$SERVICE_NAME"
  mkdir -p "$SERVICE_DIR"

  SERVICE_TXT="$SERVICE_DIR/${SERVICE_NAME}.txt"
  SERVICE_PS="$SERVICE_DIR/${SERVICE_NAME}.ps"
  SERVICE_PDF="$SERVICE_DIR/${SERVICE_NAME}.pdf"

  {
    echo "$ASCII_LOGO"
    echo
    echo "SERVICE REPORT: $SERVICE_NAME"
    echo "Started at: $(date)"
    echo "------------------------------------------------------------"
  } > "$SERVICE_TXT"

  START=$(date +%s)

  if [[ -x "$SCRIPT" ]]; then
    if bash "$SCRIPT" >> "$SERVICE_TXT" 2>&1; then
      RESULT="PASS"
      ((PASSED++))
      echo -e "${GREEN}[PASS]${RESET} $SERVICE_NAME"
    else
      RESULT="FAIL"
      ((FAILED++))
      echo -e "${RED}[FAIL]${RESET} $SERVICE_NAME"
    fi
  else
    RESULT="FAIL (Not Executable)"
    ((FAILED++))
    echo -e "${RED}[FAIL]${RESET} $SERVICE_NAME (not executable)"
  fi

  END=$(date +%s)
  DURATION=$((END - START))

  {
    echo
    echo "------------------------------------------------------------"
    echo "Result        : [$RESULT]"
    echo "Execution Time: ${DURATION}s"
    echo "Completed at  : $(date)"
    echo
  } >> "$SERVICE_TXT"

  # Append to MASTER
  cat "$SERVICE_TXT" >> "$MASTER_TXT"

  # Generate SERVICE PDF
  enscript "$SERVICE_TXT" \
    --font=Courier10 \
    --word-wrap \
    --header="$LAB_NAME" \
    --footer="Prepared by: $AUTHOR_NAME | Page \$%" \
    --no-job-header \
    -p "$SERVICE_PS"

  ps2pdf "$SERVICE_PS" "$SERVICE_PDF"

  aws s3 cp "$SERVICE_PDF" "s3://$S3_BUCKET/$S3_PREFIX/services/$SERVICE_NAME.pdf"
done

# -----------------------------------------------------------------------------
# MASTER SUMMARY
# -----------------------------------------------------------------------------
{
  echo "============================================================"
  echo "📊 MASTER SUMMARY"
  echo "Total Services : $TOTAL"
  echo "Passed         : $PASSED"
  echo "Failed         : $FAILED"
  echo "============================================================"
} >> "$MASTER_TXT"

# -----------------------------------------------------------------------------
# MASTER PDF
# -----------------------------------------------------------------------------
MASTER_PS="$BASE_DIR/master.ps"
MASTER_PDF="$BASE_DIR/Charlie-Cafe-Master-Report_$TIMESTAMP.pdf"

enscript "$MASTER_TXT" \
  --font=Courier10 \
  --word-wrap \
  --header="$LAB_NAME" \
  --footer="Prepared by: $AUTHOR_NAME | Page \$%" \
  --no-job-header \
  -p "$MASTER_PS"

ps2pdf "$MASTER_PS" "$MASTER_PDF"

aws s3 cp "$MASTER_PDF" "s3://$S3_BUCKET/$S3_PREFIX/master/$(basename "$MASTER_PDF")"

# -----------------------------------------------------------------------------
# DONE
# -----------------------------------------------------------------------------
echo "============================================================"
echo -e "🎉 ${GREEN}EXPORT COMPLETE${RESET}"
echo "📄 Master PDF uploaded"
echo "☁️ S3 Bucket: s3://$S3_BUCKET/$S3_PREFIX/"
echo "============================================================"
```

---
### ✅ Bash Script 2️⃣4️⃣ charlie-cafe-full-devops-verify.sh

> #### Merged Bash Scripts = (charlie_cafe_full_check.sh + verify-devops-env.sh + verify-docker-git-env.sh)

```
#!/bin/bash

# ==========================================================
# ☕ CHARLIE CAFE — MASTER DEVOPS VERIFICATION SCRIPT
# ==========================================================
# Combines:
#   ✅ Environment verification
#   ✅ Docker + Apache test
#   ✅ Git & GitHub validation
#   ✅ AWS + RDS + Secrets
#   ✅ Auto sync repo
#   ✅ Post-deployment checks
# ==========================================================

set -e

# ---------------- CONFIG ----------------
AWS_REGION="us-east-1"
SECRET_NAME="CafeDevDBSM"
GITHUB_USERNAME="your-username"
GITHUB_TOKEN="your-token"
GITHUB_REPO="charlie-cafe-devops"
PROJECT_DIR="/home/ec2-user/charlie-cafe-devops"
ECR_REPO="your-ecr-repo"

# ---------------- COLORS ----------------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0

pass(){ echo -e "${GREEN}✅ $1${NC}"; ((PASS++)); }
fail(){ echo -e "${RED}❌ $1${NC}"; ((FAIL++)); }
warn(){ echo -e "${YELLOW}⚠️ $1${NC}"; }

section(){
echo ""
echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}$1${NC}"
echo -e "${BLUE}==================================================${NC}"
}

echo -e "${BLUE}🚀 STARTING MASTER VERIFICATION${NC}"

# ==========================================================
# 1. REQUIRED TOOLS
# ==========================================================
section "🔎 Required Tools"

for cmd in aws jq mysql docker git curl ssh; do
 command -v $cmd >/dev/null && pass "$cmd installed" || fail "$cmd missing"
done

# ==========================================================
# 2. DOCKER CHECK
# ==========================================================
section "🐳 Docker Check"

if systemctl is-active --quiet docker; then
 pass "Docker running"
else
 warn "Docker not running → starting"
 sudo systemctl start docker
fi

docker info >/dev/null && pass "Docker OK" || fail "Docker issue"

docker images
docker ps

# ==========================================================
# 3. APACHE TEST CONTAINER
# ==========================================================
section "🌐 Apache Test"

docker rm -f verify-apache >/dev/null 2>&1 || true
docker run -d --name verify-apache -p 8080:80 httpd:latest >/dev/null

sleep 5

curl -s http://localhost:8080 >/dev/null && pass "Apache OK (8080)" || fail "Apache failed"

docker logs verify-apache | head -n 5
docker rm -f verify-apache >/dev/null

# ==========================================================
# 4. PROJECT + GIT
# ==========================================================
section "📂 Git Project"

if [ -d "$PROJECT_DIR/.git" ]; then
 pass "Project exists"
 cd "$PROJECT_DIR"

 git status >/dev/null && pass "Git OK" || fail "Git issue"

 git remote -v
else
 fail "Project missing"
fi

# ==========================================================
# 5. SSH + GITHUB
# ==========================================================
section "🔐 SSH & GitHub"

[ -f ~/.ssh/id_deploy ] && pass "SSH key exists" || fail "SSH key missing"

ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated" \
 && pass "GitHub SSH OK" || fail "GitHub SSH failed"

# ==========================================================
# 6. GIT PUSH TEST
# ==========================================================
section "🧪 Git Push Test"

cd "$PROJECT_DIR"

echo "test $(date)" > test.txt
git add test.txt
git commit -m "test commit" >/dev/null 2>&1 || true

git push origin main >/dev/null 2>&1 && pass "Git push OK" || fail "Git push failed"

rm -f test.txt

# ==========================================================
# 7. NETWORK
# ==========================================================
section "🌐 Network"

ping -c 2 github.com >/dev/null && pass "Internet OK" || fail "No internet"

# ==========================================================
# 8. AWS + SECRETS + RDS
# ==========================================================
section "🗄️ AWS + RDS"

SECRET=$(aws secretsmanager get-secret-value \
 --secret-id $SECRET_NAME \
 --region $AWS_REGION \
 --query SecretString \
 --output text 2>/dev/null)

if [ $? -eq 0 ]; then
 pass "Secret fetched"

 DB_HOST=$(echo $SECRET | jq -r .host)
 DB_USER=$(echo $SECRET | jq -r .username)
 DB_PASS=$(echo $SECRET | jq -r .password)
else
 fail "Secret fetch failed"
fi

if [ -n "$DB_HOST" ]; then
 echo "SELECT 1;" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" \
  && pass "RDS OK" || fail "RDS failed"
fi

# ==========================================================
# 9. AWS ACCOUNT
# ==========================================================
section "☁️ AWS Identity"

ACC=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

[ -n "$ACC" ] && pass "AWS Account: $ACC" || fail "AWS not working"

# ==========================================================
# 10. GITHUB AUTO SYNC
# ==========================================================
section "🔄 Auto Sync"

cd "$PROJECT_DIR"

git pull origin main

if [[ -n "$(git status --porcelain)" ]]; then
 git add .
 git commit -m "auto-sync $(date)"
 git push origin main
 pass "Changes synced"
else
 pass "No changes"
fi

# ==========================================================
# 11. POST DEPLOY CHECK
# ==========================================================
section "🚀 Post Deployment"

docker ps

curl -s http://localhost >/dev/null && pass "App running" || fail "App not running"

# ==========================================================
# FINAL RESULT
# ==========================================================
section "📊 RESULT"

TOTAL=$((PASS+FAIL))
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ $FAIL -eq 0 ]; then
 echo -e "${GREEN}🎉 ALL GOOD 🚀${NC}"
else
 echo -e "${YELLOW}⚠️ Fix issues${NC}"
fi
```

---
### ✅ Bash Script 2️⃣5️⃣ export_bash_output_s3.sh

```

```

---
### ✅ Bash Script 2️⃣6️⃣ export_bash_output_s3.sh

```

```

---
### ✅ Bash Script 2️⃣7️⃣ export_bash_output_s3.sh

```

```

---
### ✅ Bash Script 2️⃣8️⃣ export_bash_output_s3.sh

```

```

---