# Charlie Cafe — Amazon EC2 Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon EC2.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

## ✅ Prerequisites

* AWS Account (EC2, VPC, IAM, Secrets Manager, Lambda , RDS, CloudFront, S3 )
* Basic Linux commands
* PHP + MySQL knowledge
* SSH client or Cloud9

---

### 6️⃣ EC2 Instance (Amazon Linux 2023)

 * EC2 Name : 
``` 
CafeDevWebServer
```

* AMI: Amazon Linux 2023
* Type: `t2.micro`
* VPC/Subnet: Dev VPC + Public subnet
* Security Group:

  * SSH (22) → Your IP
  * HTTP (80) → 0.0.0.0/0*


### 7️⃣ EC2 USER DATA


### 1️⃣ LAMP Server USER DATA
> **📍 File Location: AWS-LAMP Server-Bash-Script.md**

[AWS-LAMP Server Bash-Script](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/Linux%20Lamp%20Server/Lamp%20Server%20Script.sh)

```
#!/bin/bash

# ☕ Charlie Cafe — EC2 Bootstrap Script (Production Ready)

# Amazon Linux 2023

# LAMP + Docker + DevOps Tools

# Allow ec2-user to run docker without sudo
usermod -aG docker ec2-user


### 8️⃣ Development and Delopment LAMP Server 


### 1️⃣ Launch EC2 Instance (Amazon Linux 2023)

```
chmod 400 CafeDevKey.pem
ssh -i CafeDevKey.pem ec2-user@<PUBLIC-IP>
```


### 2️⃣ VERIFY EC2 User Data


#### 1️⃣ VERIFY LAMP + MySQL CLIENT (Amazon Linux 2023)

```
sudo nano lamp-verify.sh
```

[VERIFY LAMP + MySQL CLIENT](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/Linux%20Lamp%20Server/lamp-verify.sh)

```
#!/bin/bash

# LAMP Stack Quick Verification Script (Apache + PHP + MySQL client)

# Amazon Linux 2 / 2023 edition friendly

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

```
sudo chmod +x lamp-verify.sh
```

```
sudo ./lamp-verify.sh
```

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**


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

#### Run on EC2 / CloudShell / Amazon Linux / Linux

[charlie-cafe-pymysql-layer.sh](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/charlie-cafe-pymysql-layer.sh)

```
#!/bin/bash

# S3 TO EC2 EXPORT + PERMISSIONS SCRIPT

# 📂 EC2 DESTINATIONS

### STEP 4️⃣ — Target Group Configuration (for EC2 registration)


| Setting                  | Value / Selection                          | Notes / Requirement                                      |
|--------------------------|--------------------------------------------|----------------------------------------------------------|
| **Type**                 | Instance                                   | Standard for registering EC2 instances by ID             |
| **Protocol**             | HTTP                                       | Matches your web server on EC2 (use HTTPS only if EC2 already has SSL) |
| **Port**                 | 80                                         | Default HTTP port your web server listens on             |
| **Target registration**  | Register your EC2 instance                 | Select your EC2 instance by name/ID (not IP)             |
| **Health check path**    | / (or /cafe-admin-dashboard.html)                  | Path ALB uses to check if instance is healthy            |


#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/checkin.html
```


#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/employee-portal.html
```


#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/Cognito-Tester.html
```


#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/cafe-admin-dashboard.html
```


### 4️⃣ EC2 Configuration

| Parameter      | Value                   |
| -------------- | ----------------------- |
| Name           | `CafeDevWebServer`      |
| AMI            | Amazon Linux 2023       |
| Instance Type  | `t2.micro`              |
| VPC / Subnet   | Dev VPC / Public Subnet |
| Security Group | `default-sg`            |
| IAM Role       | `EC2-Cafe-Secrets-Role` |


#### 🔹 EC2 User Data

| Item        | Details                          |
| ----------- | -------------------------------- |
| Script Name | `charlie-cafe-devops.sh`         |
| Purpose     | Install and configure LAMP stack |
| Location    | GitHub (User Data script)        |


#### 🌐 EC2 User Data Script

[charlie-cafe-devops.sh](./infrastructure/scripts/charlie-cafe-devops.sh)


### 5️⃣ EC2 Access & Setup


#### 🔹 Connect to EC2

| Step           | Command                                      |
| -------------- | -------------------------------------------- |
| Set Permission | `chmod 400 CafeDevKey.pem`                   |
| SSH Login      | `ssh -i CafeDevKey.pem ec2-user@<PUBLIC-IP>` |


#### 🔹 Verify User Data Execution

| Step            | Command                                            |
| --------------- | -------------------------------------------------- |
| Open Script     | `sudo nano charlie-cafe-full-devops-verify.sh`     |
| Make Executable | `sudo chmod +x charlie-cafe-full-devops-verify.sh` |
| Run Script      | `sudo ./charlie-cafe-full-devops-verify.sh`        |


#### 🌐 EC2 Verify Script

[charlie-cafe-full-devops-verify.sh](./infrastructure/scripts/charlie-cafe-full-devops-verify.sh)


#### 💡 Notes

- EC2 instance uses Amazon Linux 2023

- Prerequisite setup is automated using a User Data script

- The verification script ensures that the environment is properly configured and ready
---

### 🌐 EC2 Docker Health (Optional)


#### ✅ Docker Container Read more [verify_docker-container](./docs/Readme/verify_docker-container.md)

```
nano ec2_docker_health.sh
```

[ec2_docker_health.sh](./infrastructure/scripts/ec2_docker_health.sh)


#### 🔹 Usage

```
chmod +x ec2_docker_health.sh
./ec2_docker_health.sh
```

✅ This will work every time on EC2, no matter where you run it from, as long as the repo is cloned in ~/charlie-cafe-devops.

---

#### 🔹 Step 1: Use a temporary EC2 instance in the same subnet as your ECS tasks:

```

