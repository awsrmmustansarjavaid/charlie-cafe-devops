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


### 📄 3. FINAL schema.sql (FROM YOUR SCRIPT — COMPLETE)

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

#### docker/mysql/Dockerfile

```
FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=cafe_db

# Copy schema and data
COPY ../../infrastructure/rds/schema.sql /docker-entrypoint-initdb.d/01-schema.sql
COPY ../../infrastructure/rds/data.sql /docker-entrypoint-initdb.d/02-data.sql
```

- MySQL image runs the scripts automatically on first container startup.

- verify.sql is not copied — you run it manually or via CI/CD test.

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