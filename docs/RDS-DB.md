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






