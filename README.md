# Charlie Cafe AWS DevOPS Project

> ### DevOPS Lab Project

## Charlie Cafe Project Structure

### Create your repo like this:

```
charlie-cafe/
│
├── README.md
├── .gitignore
├── docker-compose.yml
│
├── frontend/
│   ├── html/
│   ├── css/
│   ├── js/
│   └── php/
│
├── backend/
│   └── lambda/
│       ├── cafe_order_processor.py
│       ├── admin_mark_paid.py
│       └── other_lambda_files.py
│
├── database/
│   ├── rds-schema.sql
│   └── mysql-init/
│
├── scripts/
│   ├── setup_lamp.sh
│   ├── setup_rds.sh
│   ├── s3_to_ec2.sh
│   ├── ec2_to_s3.sh
│   └── lambda_layer.sh
│
├── docker/
│   ├── apache-php/
│   │   └── Dockerfile
│   ├── mysql/
│   │   └── Dockerfile (optional)
│   └── lambda/
│       └── Dockerfile
│
└── docs/
    └── architecture.md
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

