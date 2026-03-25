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

