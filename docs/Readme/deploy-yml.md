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

