# Charlie Cafe - deploy.yml

### 🧠 1. First: What is deploy.yml in DevOps language?

In technical terms, your file is:

👉 CI/CD Pipeline Definition (GitHub Actions Workflow)

It defines:

- Trigger (when pipeline runs)

- Jobs (what to do)

- Steps (how to do)

### 🧱 2. Core Structure (Golden Template)

Every deploy.yml follows this structure:

```
name: Project Name

on:
  push:
    branches: ["main"]

jobs:
  job-name:
    runs-on: ubuntu-latest

    steps:
      - name: Step Name
        uses: or run:
```

### 🔥 3. Golden Rules for Editing / Upgrading

- ### ✅ Rule 1 — Never break YAML structure

YAML is indentation-based (VERY IMPORTANT)

#### ❌ Wrong:

```
steps:
- name: Test
run: echo "Hello"
```

#### ✅ Correct:

```
steps:
  - name: Test
    run: echo "Hello"
```

👉 Think:

"Every level = 2 spaces"

- ### ✅ Rule 2 — Add new feature = Add new STEP (not random code)

When upgrading pipeline:

#### ❌ Wrong thinking:

    “I will modify everything”

#### ✅ Correct thinking:

    “I will ADD a new step for new functionality”

Example: Add Docker Build

```
- name: 🐳 Build Docker Image
  run: docker build -t my-app .
```

- ### ✅ Rule 3 — Group logically (DevOps standard)

Always follow flow:

```
1. Checkout code
2. Setup environment
3. Build
4. Test
5. Package (Docker)
6. Push (ECR)
7. Deploy (EC2 / ECS)
```

- ### ✅ Rule 4 — Use GitHub Secrets (Security Rule 🔐)

Never hardcode credentials:

#### ❌ Wrong:

```
run: aws configure set aws_access_key_id ABC123
```

#### ✅ Correct:

```
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
```

- ### ✅ Rule 5 — Reuse instead of rewriting (uses:)

Use prebuilt GitHub actions:

```
- uses: actions/checkout@v3
- uses: aws-actions/configure-aws-credentials@v2
```

- ### ✅ Rule 6 — Add, don’t destroy (Safe Upgrade Strategy)

When updating:

✔ Keep old working steps

✔ Add new step below

✔ Test

✔ Then optimize

### 🚀 4. Real Upgrade Example (Your Case)

Let’s say you want to upgrade your pipeline by adding:

- Docker build

- Push to ECR

- Deploy to EC2

#### 🔧 BEFORE (basic)

```
steps:
  - name: Checkout
    uses: actions/checkout@v3
```

#### 🔥 AFTER (upgraded pipeline)

```
steps:
  # 1️⃣ Checkout
  - name: 📥 Clone Repository
    uses: actions/checkout@v3

  # 2️⃣ AWS Login
  - name: 🔐 Configure AWS
    uses: aws-actions/configure-aws-credentials@v2
    with:
      aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      aws-region: us-east-1

  # 3️⃣ Login to ECR
  - name: 🐳 Login to ECR
    run: |
      aws ecr get-login-password --region us-east-1 | \
      docker login --username AWS --password-stdin ${{ secrets.ECR_REPO }}

  # 4️⃣ Build Docker
  - name: 🏗 Build Image
    run: docker build -t charlie-cafe .

  # 5️⃣ Tag Image
  - name: 🏷 Tag Image
    run: docker tag charlie-cafe:latest ${{ secrets.ECR_REPO }}:latest

  # 6️⃣ Push Image
  - name: 📤 Push to ECR
    run: docker push ${{ secrets.ECR_REPO }}:latest

  # 7️⃣ Deploy to EC2
  - name: 🚀 Deploy to EC2
    run: |
      ssh -o StrictHostKeyChecking=no ec2-user@${{ secrets.EC2_PUBLIC_IP }} "
      docker pull ${{ secrets.ECR_REPO }}:latest &&
      docker stop app || true &&
      docker rm app || true &&
      docker run -d -p 80:80 --name app ${{ secrets.ECR_REPO }}:latest
      "
```

### 🧩 5. How to Think Like a DevOps Engineer

When you want to upgrade:

Ask yourself:

#### 🔍 1. What stage am I adding?

- Build?

- Test?

- Deploy?

- Monitoring?

#### 🔍 2. Where should it go?

Example:

- Testing → before Docker build

- Deployment → last step

#### 🔍 3. Is it secure?

- Use secrets?

- Avoid hardcoding?

#### 🔍 4. Is it reusable?

- Use GitHub Actions or custom script?

### ⚠️ 6. Common Mistakes (VERY IMPORTANT)

❌ Breaking indentation

❌ Mixing steps order

❌ Hardcoding credentials

❌ Editing working code blindly

❌ Not testing after change

### 🏁 7. Pro DevOps Upgrade Strategy (REAL WORLD)

- Copy existing deploy.yml

- Create new branch:

```
feature/pipeline-upgrade
```

- Add ONE feature at a time

- Push → test

- Fix errors

- Merge to main

### 🎯 Final Mindset

👉 Your deploy.yml is not a file

👉 It is a living automation system

You don’t “edit it”…

You evolve it step by step
---
### ✅ deploy.yml

> #### Version: 1.0

```
name: ☕ Charlie Cafe — FULL CI/CD PIPELINE (FINAL)

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    steps:

    # -------------------------------------------------
    # 1️⃣ Checkout Repository
    # -------------------------------------------------
    - name: 📥 Checkout Code
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Configure AWS Credentials
    # (Needed for RDS + Secrets Manager)
    # -------------------------------------------------
    - name: 🔐 Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    # -------------------------------------------------
    # 3️⃣ Install Required Tools
    # -------------------------------------------------
    - name: 🧰 Install Tools
      run: |
        sudo apt-get update
        sudo apt-get install -y mysql-client jq curl

    # -------------------------------------------------
    # 4️⃣ Retrieve RDS Secret from AWS
    # -------------------------------------------------
    - name: 🗝️ Retrieve RDS Secret
      run: |
        SECRET_JSON=$(aws secretsmanager get-secret-value \
          --secret-id arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
          --region us-east-1 \
          --query SecretString \
          --output text)

        echo "DB_SECRET=$SECRET_JSON" >> $GITHUB_ENV

    # -------------------------------------------------
    # 5️⃣ Parse DB Credentials
    # -------------------------------------------------
    - name: 🧰 Parse Secret
      run: |
        echo "DB_HOST=$(echo $DB_SECRET | jq -r '.host')" >> $GITHUB_ENV
        echo "DB_USER=$(echo $DB_SECRET | jq -r '.username')" >> $GITHUB_ENV
        echo "DB_PASS=$(echo $DB_SECRET | jq -r '.password')" >> $GITHUB_ENV
        echo "DB_NAME=$(echo $DB_SECRET | jq -r '.dbname')" >> $GITHUB_ENV

    # -------------------------------------------------
    # 6️⃣ Wait for RDS Availability
    # -------------------------------------------------
    - name: ⏳ Wait for RDS
      run: |
        for i in {1..20}; do
          mysqladmin ping -h $DB_HOST -u$DB_USER -p$DB_PASS --silent && break
          echo "Waiting for RDS..."
          sleep 5
        done

    # -------------------------------------------------
    # 7️⃣ Create Database (Safe)
    # -------------------------------------------------
    - name: 🗄️ Create Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS -e "
        CREATE DATABASE IF NOT EXISTS $DB_NAME;
        "

    # -------------------------------------------------
    # 8️⃣ Apply Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # 9️⃣ Apply Sample Data
    # -------------------------------------------------
    - name: 📊 Apply Data
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/data.sql

    # -------------------------------------------------
    # 🔟 Verify Database
    # -------------------------------------------------
    - name: ✅ Verify Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # 11️⃣ Build Docker Image (CI validation)
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 12️⃣ Run Container Locally (CI test)
    # -------------------------------------------------
    - name: 🚀 Run Container (Test)
      run: |
        docker run -d -p 8080:80 --name test_app charlie-cafe
        sleep 10

    # -------------------------------------------------
    # 13️⃣ Health Check
    # -------------------------------------------------
    - name: ❤️ Test Application
      run: |
        curl -f http://localhost:8080/health.php || exit 1

    # -------------------------------------------------
    # 14️⃣ Cleanup Test Container
    # -------------------------------------------------
    - name: 🧹 Cleanup
      run: |
        docker rm -f test_app || true

    # -------------------------------------------------
    # 15️⃣ Setup SSH for EC2 Deployment
    # -------------------------------------------------
    - name: 🔑 Setup SSH
      uses: webfactory/ssh-agent@v0.8.0
      with:
        ssh-private-key: ${{ secrets.EC2_SSH_KEY }}

    # -------------------------------------------------
    # 16️⃣ Deploy to EC2 (CD Step)
    # -------------------------------------------------
    - name: 🚀 Deploy to EC2
      run: |
        ssh -o StrictHostKeyChecking=no ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} << 'EOF'

        echo "🚀 Starting Deployment on EC2..."

        # Clone repo if not exists
        cd ~/charlie-cafe-devops || git clone git@github.com:awsrmmustansarjavaid/charlie-cafe-devops.git
        cd charlie-cafe-devops

        # Pull latest changes
        git pull origin main

        # Stop & remove old container
        sudo docker rm -f cafe-app || true

        # Remove old image (optional cleanup)
        sudo docker rmi charlie-cafe || true

        # Build new image
        sudo docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

        # Run container on port 80
        sudo docker run -d -p 80:80 --name cafe-app charlie-cafe

        echo "✅ Deployment Completed!"

        EOF

    # -------------------------------------------------
    # 17️⃣ Final Success Message
    # -------------------------------------------------
    - name: 🎉 Success
      run: echo "CI/CD Pipeline Completed Successfully 🚀"
```

### ✅ Add GitHub Secrets for AWS Access Key (Recommanded)

> #### 👉 “GitHub Actions → AWS SSM Remote Deployment Pipeline”

This means:

- GitHub triggers pipeline

- AWS credentials authenticate

- SSM sends command to EC2

- EC2 runs deployment (no SSH keys needed)

### 🔐 2. Required GitHub Secrets (You Already Listed 👍)

Inside GitHub:


| Secret Name             | Value                              |
| ----------------------- | ---------------------------------- |
| `AWS_ACCESS_KEY_ID`     | (your IAM user access key ID)      |
| `AWS_SECRET_ACCESS_KEY` | (your IAM user secret access key)  |
| `AWS_REGION`            | `us-east-1` (or your region)       |
| `EC2_INSTANCE_ID`       | `i-0123456789abcdef0` (target EC2) |
| `EC2_USER`              | `ec2-user` (default username)      |

### ⚙️ 3. Add This to Your deploy.yml

👉 This is the clean production-ready block you can insert

✅ Step: Configure AWS + Use SSM

```
# -------------------------------------------------
# 🔐 Configure AWS Credentials
# -------------------------------------------------
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}

# -------------------------------------------------
# 🚀 Deploy to EC2 using AWS SSM (NO SSH)
# -------------------------------------------------
- name: 🚀 Deploy via SSM
  run: |
    aws ssm send-command \
      --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
      --document-name "AWS-RunShellScript" \
      --comment "Deploy Charlie Cafe App" \
      --parameters 'commands=[
        "cd /home/ec2-user/charlie-cafe",
        "git pull origin main",
        "docker stop app || true",
        "docker rm app || true",
        "docker build -t charlie-cafe .",
        "docker run -d -p 80:80 --name app charlie-cafe"
      ]' \
      --region ${{ secrets.AWS_REGION }}
```

### 🔥 4. What This Script Actually Does (Step-by-Step)

- ### 🧩 Inside EC2 (automatically):

```
cd /home/ec2-user/charlie-cafe
git pull origin main
docker stop app || true
docker rm app || true
docker build -t charlie-cafe .
docker run -d -p 80:80 --name app charlie-cafe
```

### ⚠️ 5. VERY IMPORTANT REQUIREMENTS (SSM Setup)

Before this works, your EC2 must have:

- ### ✅ 1. IAM Role attached to EC2

    - Policy required: AmazonSSMManagedInstanceCore

- ### ✅ 2. SSM Agent installed

For Amazon Linux:

✔ Already installed (usually)

Check:

```
sudo systemctl status amazon-ssm-agent
```

- ### ✅ 3. Instance must appear in SSM

    - Go to: 👉 AWS Console → Systems Manager → Managed Instances

### 🚫 Why This is BETTER than SSH

| SSH Method ❌      | SSM Method ✅     |
| ----------------- | ---------------- |
| Requires key pair | No keys needed   |
| Security risk     | Fully secure IAM |
| Port 22 open      | No open ports    |
| Hard to scale     | Easy automation  |

### 🧠 6. Pro Upgrade (Next Level DevOps)

Later you can enhance:

#### 🔹 Add Docker pull from ECR instead of build:

```
docker pull <your-ecr-image>
```

#### 🔹 Add health check:

```
curl -f http://localhost || exit 1
```

#### 🔹 Add rollback logic

### 🏁 7. Final DevOps Thinking

👉 You are not writing commands

👉 You are building remote-controlled infrastructure

### ✅ Fully Final Deploy.yml

```
name: ☕ Charlie Cafe — FULL CI/CD PIPELINE (FINAL)

on:
  push:
    branches: ["main"]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    steps:

    # -------------------------------------------------
    # 1️⃣ Checkout Repository
    # -------------------------------------------------
    - name: 📥 Checkout Code
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Configure AWS Credentials
    # -------------------------------------------------
    - name: 🔐 Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    # -------------------------------------------------
    # 3️⃣ Install Required Tools
    # -------------------------------------------------
    - name: 🧰 Install Tools
      run: |
        sudo apt-get update
        sudo apt-get install -y mysql-client jq curl

    # -------------------------------------------------
    # 4️⃣ Retrieve RDS Secret
    # -------------------------------------------------
    - name: 🗝️ Retrieve RDS Secret
      run: |
        SECRET_JSON=$(aws secretsmanager get-secret-value \
          --secret-id arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
          --query SecretString \
          --output text)

        echo "DB_SECRET=$SECRET_JSON" >> $GITHUB_ENV

    # -------------------------------------------------
    # 5️⃣ Parse DB Credentials
    # -------------------------------------------------
    - name: 🧰 Parse Secret
      run: |
        echo "DB_HOST=$(echo $DB_SECRET | jq -r '.host')" >> $GITHUB_ENV
        echo "DB_USER=$(echo $DB_SECRET | jq -r '.username')" >> $GITHUB_ENV
        echo "DB_PASS=$(echo $DB_SECRET | jq -r '.password')" >> $GITHUB_ENV
        echo "DB_NAME=$(echo $DB_SECRET | jq -r '.dbname')" >> $GITHUB_ENV

    # -------------------------------------------------
    # 6️⃣ Wait for RDS
    # -------------------------------------------------
    - name: ⏳ Wait for RDS
      run: |
        for i in {1..20}; do
          mysqladmin ping -h $DB_HOST -u$DB_USER -p$DB_PASS --silent && break
          echo "Waiting for RDS..."
          sleep 5
        done

    # -------------------------------------------------
    # 7️⃣ Create Database
    # -------------------------------------------------
    - name: 🗄️ Create Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS -e "
        CREATE DATABASE IF NOT EXISTS $DB_NAME;
        "

    # -------------------------------------------------
    # 8️⃣ Apply Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # 9️⃣ Apply Data
    # -------------------------------------------------
    - name: 📊 Apply Data
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/data.sql

    # -------------------------------------------------
    # 🔟 Verify DB
    # -------------------------------------------------
    - name: ✅ Verify Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # 11️⃣ Build Docker Image
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 12️⃣ Run Container (Test)
    # -------------------------------------------------
    - name: 🚀 Run Container (Test)
      run: |
        docker run -d -p 8080:80 --name test_app charlie-cafe
        sleep 10

    # -------------------------------------------------
    # 13️⃣ Health Check
    # -------------------------------------------------
    - name: ❤️ Test Application
      run: |
        curl -f http://localhost:8080/health.php || exit 1

    # -------------------------------------------------
    # 14️⃣ Cleanup
    # -------------------------------------------------
    - name: 🧹 Cleanup
      run: |
        docker rm -f test_app || true

    # -------------------------------------------------
    # 15️⃣ Deploy via SSM (FINAL STEP)
    # -------------------------------------------------
    - name: 🚀 Deploy via AWS SSM
      run: |
        aws ssm send-command \
          --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
          --document-name "AWS-RunShellScript" \
          --comment "Deploy Charlie Cafe App" \
          --parameters 'commands=[
            "cd /home/ec2-user/charlie-cafe-devops",
            "git pull origin main",
            "docker rm -f cafe-app || true",
            "docker build -t charlie-cafe -f docker/apache-php/Dockerfile .",
            "docker run -d -p 80:80 --name cafe-app charlie-cafe"
          ]' \
          --region ${{ secrets.AWS_REGION }}

    # -------------------------------------------------
    # 16️⃣ Success
    # -------------------------------------------------
    - name: 🎉 Success
      run: echo "CI/CD Pipeline Completed Successfully 🚀"
```

---
