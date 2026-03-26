# Charlie Cafe AWS DevOPS Project

> ### DevOPS Lab Project

# Charlie Cafe Project Structure

## 📁 Professional Repository Structure

### Create your repo like this:

> #### Update your repo to this (no file changes, only organization):

```
charlie-cafe-devops/
│
├── README.md
├── LICENSE
├── .gitignore
├── docker-compose.yml
│
├── app/                        # Your original code (UNCHANGED)
│   ├── frontend/
│   │   ├── *.html
│   │   ├── *.php
│   │   ├── css/
│   │   └── js/
│   │
│   └── backend/
│       └── lambda/
│           ├── *.py
│
├── infrastructure/
│   ├── rds/
│   │   └── schema.sql
│   ├── scripts/
│   │   ├── setup_lamp.sh
│   │   ├── setup_rds.sh
│   │   ├── s3_to_ec2.sh
│   │   └── ec2_to_s3.sh
│
├── docker/
│   ├── apache-php/
│   │   └── Dockerfile
│   └── mysql/
│
├── docs/
│   ├── architecture.md
│   ├── deployment.md
│   └── your-original-guide.md  ✅ (your file)
│
└── .github/
    └── workflows/
        └── deploy.yml
```

### 👉 Important:

- Your original files go inside folders as-is

- No edits needed

## Initialize GitHub Repo

### 1. Create repo on GitHub

- Go to: 👉 https://github.com  → New Repo

- Name:

```
charlie-cafe-devops
```

### 🌐 3. FINAL schema.sql (FROM YOUR SCRIPT — COMPLETE)

#### 📄 Read more here 

[Charlie Cafe Readme_RDS_schema](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/3cc7be3a035c31c2f621682ac611a5dd9c5487d3/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/Charlie%20Cafe%20DevOPS/Readme_RDS_schema.md)

#### ✅ ✅ FINAL SPLIT (PRODUCTION STYLE)

You will have:

```
schema.sql   → structure (DB + tables)
data.sql     → sample/test data
verify.sql   → testing + analytics
```

#### 👉 Create this file:

```
infrastructure/rds/schema.sql
```

```
infrastructure/rds/data.sql
```

```
infrastructure/rds/verify.sql
```

### ⚙️ HOW IT WORKS (STEP BY STEP)

### Method 1 How to run your current files in production without Docker/CI/CD

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

### Method 2 integrate schema.sql, data.sql, verify.sql into Docker + CI/CD

### Step 1 — Dockerize MySQL for local testing

### 📦 1. Create a Dockerfile

Inside your project root (charlie-cafe-devops/), create:

### ✅ Dockerfile #1 → MySQL (database with schema.sql)

```
docker/mysql/Dockerfile
```

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

### ✅ Dockerfile #2 → Apache + PHP (frontend)

```
docker/apache-php/Dockerfile
```

```
# -------------------------------------------------
# ☕ Charlie Cafe - FINAL Dockerfile (PHP + Apache)
# Production Ready | DevOps Standard
# -------------------------------------------------

# Use official PHP with Apache
FROM php:8.2-apache

# -------------------------------------------------
# Install required PHP extensions
# (For MySQL / RDS connectivity)
# -------------------------------------------------
RUN docker-php-ext-install mysqli pdo pdo_mysql

# -------------------------------------------------
# Enable Apache rewrite module (for clean URLs / routing)
# -------------------------------------------------
RUN a2enmod rewrite

# -------------------------------------------------
# Set working directory
# -------------------------------------------------
WORKDIR /var/www/html

# -------------------------------------------------
# Copy frontend code (NO modification required)
# -------------------------------------------------
COPY app/frontend/ /var/www/html/

# -------------------------------------------------
# Set proper permissions
# -------------------------------------------------
RUN chown -R www-data:www-data /var/www/html

# -------------------------------------------------
# Expose Apache port
# -------------------------------------------------
EXPOSE 80
```

### ⚙️ ✅ FINAL docker-compose.yml (FULLY CONNECTED)

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
    depends_on:
      - db
    restart: always

  db:
    build:
      context: .
      dockerfile: docker/mysql/Dockerfile
    container_name: charlie_db
    ports:
      - "3306:3306"
    restart: always
```


### 📦 2. Create .dockerignore (IMPORTANT)

This prevents junk files from going into Docker image.

```
.dockerignore
```

```
.git
node_modules
.env
*.log
```

### ⚙️ 3. Build Your Docker Image

SSH into EC2 and go to your project:

```
cd charlie-cafe-devops
```

Then run:

```
docker build -t charlie-cafe .
```

### ▶️ 4. Run Your Container

```
docker run -d -p 80:80 --name cafe-app charlie-cafe
```

### 🌐 Now test in browser:

```
http://YOUR-EC2-PUBLIC-IP
```





#### docker-compose.yml

```
version: "3.9"

services:
  mysql:
    build: ./docker/mysql
    container_name: charlie-cafe-mysql
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - mysql_data:/var/lib/mysql

  apache-php:
    build: ./docker/apache-php
    container_name: charlie-cafe-web
    ports:
      - "8080:80"
    depends_on:
      - mysql

volumes:
  mysql_data:
```

### Step 2 — Add verify.sql to CI/CD for QA

#### .github/workflows/deploy.yml

```
name: Deploy Charlie Cafe

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: rootpassword
          MYSQL_DATABASE: cafe_db
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping --silent"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3

    steps:
      - uses: actions/checkout@v3

      - name: Wait for MySQL
        run: |
          until mysqladmin ping -h 127.0.0.1 -uroot -prootpassword; do
            echo "Waiting for MySQL..."
            sleep 5
          done

      - name: Apply schema
        run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/schema.sql

      - name: Apply sample data
        run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/data.sql

      - name: Verify schema
        run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/verify.sql
```

✅ This allows automatic DB creation + QA verification in CI/CD whenever you push code.

### Step 3 — Production vs Local

- Local development: Use Docker MySQL container + schema + data.

- Production RDS: Run schema.sql only + optional verify.sql.

- No Docker is needed on production RDS — RDS is fully managed by AWS.