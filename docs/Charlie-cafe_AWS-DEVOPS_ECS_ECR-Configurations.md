# Charlie Cafe - AWS DEVOPS ECS & ECR Configurations

### 🚀 🎯 FINAL GOAL

- #### Every time you push code:

```
GitHub → Build Docker → Push to ECR → Deploy to ECS → Live App Updated
```
## Pre-requisites

### 🧱  — CREATE IAM USER FOR GITHUB

### ✅ 1. Go to IAM

- AWS Console → IAM → Users → Create User

### ✅ 2. Configure

- Username:

```
charlie-github-user
```

#### Enable:

✔ Programmatic access

### ✅ 3. Attach Policy

#### Attach your merged policy:

```
charlie-cafe-iam-policy
```

### ✅ 4. Create User

👉 Copy:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

---
### 1️⃣ CREATE ECR (DOCKER REGISTRY)

#### 1️⃣ Create Repository

- Go to: ECR → Create Repository

- Name: charlie-cafe

- Visibility: Private

- Keep Mutable tags (default)

- Click Create repository

#### ✅ Copy Repository URI

- ✅ Example: You should now see your repo:

```
123456789.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe
```

#### 2️⃣ Login to ECR

On your local machine (or EC2):

```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
```

#### 3️⃣ Go to the folder with the Dockerfile

```
cd ~/charlie-cafe-devops/docker/apache-php/
```

  - Check the file exists:

#### should show your Dockerfile

```
ls -l Dockerfile
```

#### 4️⃣ Build and Tag Docker Image

From your project directory (where Dockerfile is):

```
docker build -t charlie-cafe .
```

- -t charlie-cafe → names your image charlie-cafe.

- . → tells Docker to use the current folder for the Dockerfile and context.

#### 5️⃣ Tag the Docker image for ECR

```
docker tag charlie-cafe:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
```

#### 6️⃣ Push the Docker image to ECR

```
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
```

✅ After this, your Docker image will be in ECR, ready for ECS or Fargate deployment.

#### 💡 Optional tip: If you want to build from anywhere, you can also specify the Dockerfile path:

```
docker build -t charlie-cafe -f ~/charlie-cafe-devops/docker/apache-php/Dockerfile ~/charlie-cafe-devops/docker/apache-php/
```

✅ This avoids having to cd into the folder.

### 2️⃣ ECS SETUP

- ### 1️⃣ Create ECS Service-Linked IAM Role

- Go to IAM → Roles → Create Role.

- Choose AWS Service → Elastic Container Service.

- Under Use Case, select Elastic Container Service (this is for ECS itself, not tasks or EC2).

- Click Next: Permissions → You do not need to attach any extra policy (AWS adds AmazonECSServiceRolePolicy automatically).

- Name the role: AWSServiceRoleForECS.

- Click Create Role.

✅ This is the official Service-Linked Role required by ECS.

### Option B: Automatic (Easiest)

Run this CLI command in your AWS CLI:

```
aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com
```

✅ This automatically creates the required role: AWSServiceRoleForECS

> Note: This requires your IAM user/role to have iam:CreateServiceLinkedRole permission.

### ✅ Option C: Manual via IAM Console

- Go to IAM → Roles → Create Role.

- Choose AWS Service → Elastic Container Service.

- Under Use Case, select Elastic Container Service (this is for ECS itself, not tasks or EC2).

- Click Next: Permissions → You do not need to attach any extra policy (AWS adds AmazonECSServiceRolePolicy automatically).

- Name the role: AWSServiceRoleForECS.

- Click Create Role.

This is the official Service-Linked Role required by ECS.

#### Step 1 — Ensure your user/role can use ECS

Even with the service-linked role, your IAM user must be able to create ECS clusters:

- In IAM → Policies, make sure you have the following attached to your user or role:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:*",
                "iam:PassRole"
            ],
            "Resource": "*"
        }
    ]
}
```

> Your Lambda/GitHub Action IAM policies already have some ecs permissions, but ensure ecs:CreateCluster is allowed.

#### Option 2 — Give EC2 Role Permission to Create Service-Linked Role

If you want to stick with CLI on EC2, you need to temporarily attach a policy to your EC2 role:

#### Policy to allow service-linked role creation:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole",
                "iam:ListRoles"
            ],
            "Resource": "*"
        }
    ]
}
```

- Go to IAM → Roles → EC2-Cafe-Secrets-Role → Attach Policies → Create Inline Policy.

- Paste the JSON above.

- Save policy.

- Retry:

```
aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com
```

> After creation, you can remove the inline policy if you want to tighten security.


- ### 2️⃣ Create ECS Cluster

- Go to ECS → Clusters → Create Cluster.

- Select Networking Only (Fargate).

- Click Next Step.

- Name your cluster: charlie-cluster.

- Leave other defaults (VPC, subnets) for now unless you have a specific setup.

- Click Create.

Wait until the status shows Active.

✅ No need to attach EC2 instances since this is Fargate.

#### ✅ Delete the failed CloudFormation stack (Optional)

- Go to CloudFormation Console → Stacks.

- Look for stack: Infra-ECS-Cluster-charlie-cluster-00bdea46 (or similar with charlie-cluster in the name).

- Select it → Click Delete Stack.

- Wait for the stack to be fully deleted (status disappears from the console).

- Retry creating ECS cluster charlie-cluster.

✅ This is the safest approach if you want to reuse the same cluster name.

- ### 3️⃣ Create Task Execution Role (if not exists)

The task execution role is needed for Fargate to pull images from ECR and write logs to CloudWatch.

- Go to IAM → Roles → Create Role → AWS Service → Elastic Container Service → Task Execution Role.

- Click Next: Permissions.

- Attach AmazonECSTaskExecutionRolePolicy.

- Name it: ecsTaskExecutionRole.

- Click Create Role.

This role will be used later in the task definition.

#### ✅ (Optional) If Using Tasks With Roles

Task Execution Role: If your ECS task needs to pull images from ECR or access secrets:

- Go to IAM → Roles → Create Role → AWS Service → ECS → Task Execution Role.

- Attach AmazonECSTaskExecutionRolePolicy.

- Assign this role when creating task definitions.

- Task Role: For your app code to call AWS services (like DynamoDB or S3):

- Go to IAM → Roles → Create Role → AWS Service → ECS → Task Role.

- Attach the needed custom policies (your DynamoDB, S3, SecretsManager policies).

- Assign this role when creating task definitions.

- ### 4️⃣ Create Task Definition

- Go to ECS → Task Definitions → Create new Task Definition.

- Select Fargate → Click Next.

- Task Definition Family: charlie-task.

- Task Role: Leave None (for now).

- Task Execution Role: Select ecsTaskExecutionRole created in Step 2.

- Network Mode: awsvpc.

- CPU: 0.5 vCPU.

- Memory: 1 GB.

- Click Next to add containers.

- ### 5️⃣ Add Container to Task

- Container Name: charlie-container.

- Image: 537236558357.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest.

- Port Mapping:

- Container Port: 80

- Protocol: TCP

- Environment Variables (optional for now):

  - DB_HOST = your-rds-endpoint

  - DB_USER = admin

  - DB_PASS = your-password

- Logging:

  - Check Enable CloudWatch Logs

  - Log group: /ecs/charlie-task

  - Region: us-east-1

  - Stream prefix: ecs

- Create log group: true

- Leave other optional settings (HealthCheck, Restart Policy, Storage) as default.

- Click Add → Click Create Task Definition.

- ### 6️⃣  Network Connectivity

> #### NAT GW / VPC ENDPoint

Read more [“Click here for configuration.”](./charlie-cafe-devops-Network%20Connectivity.md)

#### 🔹 Step 1: VPC Endpoints (Private Access)

| Endpoint                        | Type      | Notes                                            |
| ------------------------------- | --------- | ------------------------------------------------ |
| com.amazonaws.us-east-1.ecr.api | Interface | ECS tasks → ECR API                              |
| com.amazonaws.us-east-1.ecr.dkr | Interface | ECS tasks → Docker registry                      |
| com.amazonaws.us-east-1.s3      | Gateway   | Needed because ECR image layers are stored in S3 |

- Steps:

  - Go VPC → Endpoints → Create Endpoint

  - Choose service (above)

  - Attach private subnet of ECS tasks

  - Security group: allows inbound HTTPS from ECS tasks

  - Redeploy ECS service

✅ This is recommended if you want production-level private networking.

#### 🔹 Step 2: Quick Test Before Redeploy

Use a temporary EC2 instance in the same subnet as your ECS tasks:

```
# Test ECR API
curl -v https://api.ecr.us-east-1.amazonaws.com/

# Test ECR Docker registry
curl -v https://537236558357.dkr.ecr.us-east-1.amazonaws.com/v2/
```

- Timeout → network problem

- JSON / HTTP 200 → network works

#### 🔹 Step 3: Verify ECS Once Networking Works

After your tasks can access ECR:

- Go to ECS → Clusters → charlie-cluster → Services → charlie-service

- Check Tasks:

  - Status: Running

  - Last Status: RUNNING

- Go to Target Groups → charlie-blue → Targets

  - Status: Healthy

  - Should see the private IP of the Fargate task

- Open your ALB DNS in browser:

  - You should see your app page served from the container

- Logs:

  - Go to CloudWatch Logs (if configured in task definition)

  - Verify container starts without errors

- ### 7️⃣  Run Task in Cluster

- Go to ECS → Clusters → charlie-cluster → Tasks → Run new Task.

- Launch Type: Fargate.

- Task Definition: charlie-task:1 (latest revision).

- Cluster VPC & Subnets: select defaults or your preferred VPC.

- Security group: allow TCP 80 (HTTP) from 0.0.0.0/0 if public access needed.

- Click Run Task.

✅ Your container should start. Check Logs → CloudWatch → /ecs/charlie-task to verify the app is running.

- ### 8️⃣  Verify Container

- Go to ECS → Cluster → Tasks.

- Click on your task → Containers → View Logs.

- Verify container started successfully, listening on port 80.

#### ✅ Notes / Tips

- Task Role is optional unless your app inside the container needs AWS services (DynamoDB, S3, SecretsManager).

- Task Execution Role is required for Fargate to pull images and send logs.

- awsvpc network mode gives each task its own ENI, so make sure your security groups and subnets allow traffic.

- If you want environment secrets (like DB password) more securely, use Secrets Manager instead of plain text environment variables.

### 5️⃣ ALB + ECS SERVICE

> #### KEEP existing ALB and upgrade it for ECS.

#### 1️⃣ Create NEW Target Groups (for ECS)

- 👉 Go to: EC2 → Target Groups

#### 🔵 Blue Target Group

- Name: charlie-blue

- Target type: IP (IMPORTANT)

- Port: 80

- Health check: /health.php

#### 🟢 Green Target Group

- Name: charlie-green

- Same config as above

#### 2️⃣ Update ALB Listener

- Go to: EC2 → Load Balancer → Listeners

- Edit HTTP:80

#### 👉 Set default:

- Default action: Forward → charlie-blue

#### 3️⃣ Create ECS Service

- Go ECS → Cluster → charlie-cluster → Create Service

- Service Name: charlie-service

- Launch type: Fargate

- Number of tasks: 1 (start small)

- Load Balancer: Application Load Balancer

  > Use existing ALB

- Listener: HTTP:80

- Target group: charlie-blue

- Container Mapping: charlie-container port 80

  - Container: charlie-container

  - Port: 80

✅ Click Create Service → Wait for tasks to become Running

#### 4️⃣ Verify Target Group

- Go EC2 → Target Groups → charlie-blue → Targets

> You should see IP addresses (Fargate tasks) and Status: Healthy

#### You should see:

- IP addresses (NOT EC2)

- Status: Healthy

#### 🌐 Access App

- Go to your ALB DNS in browser

```
http://YOUR-ALB-DNS
```

✅ It should now serve your Dockerized app

### ⚡ Notes / Pro Tips

- #### RDS Connection from Lambda / ECS

  - Make sure ECS tasks are in same VPC and security group allows traffic to RDS.

  - For Lambda: you already connected to RDS VPC.

- #### Blue/Green Deployment

  - charlie-blue is live

  - charlie-green can be used for next version, then switch ALB default to green

- #### Environment Variables Security

  - For production, use AWS Secrets Manager instead of plain text env variables.

- #### Health Checks

  - Ensure /health.php or / returns HTTP 200

  - Otherwise ALB will mark task unhealthy

### 4️⃣ GITHUB CI/CD (AUTO DEPLOY)

### 1️⃣ Add GitHub Secrets

#### ✅ REQUIRED SECRETS 

- Go to GitHub repo → Settings → Secrets and variables → Actions → Add the following secrets:

- Add each one manually:

| Secret Name             | Value Example   | Where to Get    |
| ----------------------- | --------------- | --------------- |
| `AWS_ACCESS_KEY_ID`     | AKIA...         | IAM User        |
| `AWS_SECRET_ACCESS_KEY` | xxxxx           | IAM User        |
| `AWS_REGION`            | us-east-1       | Your AWS region |
| `AWS_ACCOUNT_ID`        | 123456789012    | AWS Account     |
| `ECS_CLUSTER`           | charlie-cluster | ECS Console     |
| `ECS_SERVICE`           | charlie-service | ECS Console     |
| `ECR_REPO`              | charlie-cafe    | ECR Repo Name   |

- ECR Repository created (charlie-cafe)

- ECS Cluster and Service running

✅ Everything you mentioned is already done.

### 2️⃣ Add ECR & ECS deployment steps to your existing deploy.yml

We will append the following steps at the end of your pipeline

- #### Step 1️⃣ – Login to ECR

```
    # -------------------------------------------------
    # 20️⃣ Login to ECR
    # -------------------------------------------------
    - name: 🐳 Login to ECR
      run: |
        aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | \
        docker login --username AWS --password-stdin ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com
```

- #### Step 2️⃣ – Build Docker Image

```
    # -------------------------------------------------
    # 21️⃣ Build Docker Image
    # -------------------------------------------------
    - name: 🏗️ Build Docker Image for ECS
      run: |
        docker build -t ${{ secrets.ECR_REPO }} .
```

> You can reuse your existing Dockerfile path if needed:
docker build -t ${{ secrets.ECR_REPO }} -f docker/apache-php/Dockerfile .

- #### Step 3️⃣ – Tag Docker Image

```
    # -------------------------------------------------
    # 22️⃣ Tag Docker Image
    # -------------------------------------------------
    - name: 🏷️ Tag Docker Image
      run: |
        docker tag ${{ secrets.ECR_REPO }}:latest \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:latest
```

- #### Step 4️⃣ – Push Docker Image to ECR

```
    # -------------------------------------------------
    # 23️⃣ Push Docker Image to ECR
    # -------------------------------------------------
    - name: 📤 Push Docker Image
      run: |
        docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:latest
```

- #### Step 5️⃣ – Force ECS Service Update

```
    # -------------------------------------------------
    # 24️⃣ Update ECS Service (Deploy new image)
    # -------------------------------------------------
    - name: 🚀 Deploy to ECS
      run: |
        aws ecs update-service \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service ${{ secrets.ECS_SERVICE }} \
          --force-new-deployment
```


> This tells ECS to pull the new image from ECR and redeploy the tasks.

- #### Step 6️⃣ – Optional ECS Health Check

```
    # -------------------------------------------------
    # 25️⃣ Verify ECS Tasks
    # -------------------------------------------------
    - name: 🌐 Verify ECS Deployment
      run: |
        aws ecs list-tasks --cluster ${{ secrets.ECS_CLUSTER }} --service-name ${{ secrets.ECS_SERVICE }}
        aws ecs describe-tasks --cluster ${{ secrets.ECS_CLUSTER }} --tasks $(aws ecs list-tasks --cluster ${{ secrets.ECS_CLUSTER }} --service-name ${{ secrets.ECS_SERVICE }} --query 'taskArns[*]' --output text)
```

> This step lists the running tasks so you can see if ECS picked up the new image.

- #### Step 7️⃣ – Where to Add These Steps

- In your current deploy.yml, append after step 19 (CI/CD Pipeline Completed Successfully)
Make sure indentation matches your current YAML (two spaces per level in GitHub Actions).

-Your full pipeline now will:

    > - Build DB → Build Docker → Deploy EC2 → Push Docker → Update ECS

### 3️⃣ 📄 FINAL deploy.yml

[deploy.yml](./Readme/deploy-yml/ecs&ecr/deploy.yml)

#### ✅ Key Points

- Nothing from your current EC2/DB pipeline is removed

- Steps 20–25 handle ECR login → push → ECS deployment

- Dockerfile path is preserved (docker/apache-php/Dockerfile)

- ECS service is forced to deploy the new image automatically

### 4️⃣ Commit & Push

- Save the updated deploy.yml in .github/workflows/

- Commit & push to main

- GitHub Actions will automatically trigger

- Check Actions tab → Logs for each step

✅ If all steps succeed, your ECS service will be automatically updated whenever you push to main.

### 5️⃣ Testing the ECS Deployment

- Go to ECS → Cluster → charlie-cluster → Tasks

- You should see new tasks running with the latest image

- Go to ALB → Target Groups → charlie-blue → Targets

- Status should be Healthy

- Open your ALB DNS in the browser to test the live app

### ⚡ Pro Tips

- If ECS tasks don’t become healthy, check:

    - Security groups (allow ALB → ECS → RDS traffic)

    - Docker container port matches task definition

    - Health check path /health.php exists

- For faster deployments, use immutable tags instead of latest, e.g., Git commit SHA:

```
docker tag charlie-cafe:latest $ECR_REPO:$GITHUB_SHA
```

---
## 🚀 Implement Immutable Docker Image Versioning Using Git Commit SHA in GitHub CI/CD Pipeline

> Configure Unique Docker Image Tags with Git Commit SHA for Safe ECS Deployments

### 📘 Why We Do This (Explainable Reason)

- Right now your pipeline uses: :latest

- #### 🛑 Problem:


    - every deployment overwrites same image

    - ECS may cache old image

    -,rollback becomes difficult

    - impossible to know which code version is deployed

- #### ✅ Using Git Commit SHA means:

```
charlie-cafe:a34fd91
charlie-cafe:b88d112
charlie-cafe:cc91ff2
```

- Every deployment gets unique version.

- #### ✅ Benefits:


    - Immutable deployments

    - Easy rollback

    - Better debugging

    - Production best practice

    - No cache issues

### 🛠 STEP-BY-STEP GUIDE TO IMPLEMENT GIT SHA TAGGING

### 1️⃣ — Understand What Git SHA Means

- #### GitHub automatically provides: ${{ github.sha }}

- #### Example: a84d92f22c99183abf

- #### We usually shorten it: ${GITHUB_SHA::7}

- #### Output: a84d92f

This becomes Docker tag.

### 2️⃣ — Add Image Tag Environment Variable in deploy.yml

Find near top of your workflow:

- ✅ #### Current:

```
jobs:
  build-test-deploy:
    runs-on: ubuntu-latest
```

- ✅ #### Replace with:

```
jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    env:
      IMAGE_TAG: ${{ github.sha }}
```

### 3️⃣ — Update Docker Build Step

Find your ECS docker build step.

- ✅ #### Current:

```
- name: 🏗️ Build Docker Image for ECS
  run: |
    docker build -t ${{ secrets.ECR_REPO }} -f docker/apache-php/Dockerfile .
```

- ✅ #### Replace with:

```
- name: 🏗️ Build Docker Image for ECS
  run: |
    docker build \
      -t ${{ secrets.ECR_REPO }}:$IMAGE_TAG \
      -f docker/apache-php/Dockerfile .
```

### 4️⃣ — Update Docker Tag Step

- ✅ #### Current:

```
docker tag repo:latest repo:latest
```

- ✅ #### Replace with:

```
- name: 🏷️ Tag Docker Image
  run: |
    docker tag \
      ${{ secrets.ECR_REPO }}:$IMAGE_TAG \
      ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG
```

### 5️⃣ — Update Docker Push Step

- ✅ #### Current:

```
docker push repo:latest
```

- ✅ #### Replace with:

```
- name: 📤 Push Docker Image
  run: |
    docker push \
      ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG
```

### 6️⃣ — IMPORTANT ECS ISSUE (Very Important)

#### 🛑 Problem:

Your ECS task definition still points to:

```
latest
```

If ECS task definition says latest:

it won't use SHA automatically.

You MUST update ECS task definition each deployment.

### 7️⃣ — Create ECS Task Definition Template File

- #### Create file: 

```
.github/task-definition.json
```

- #### Example:

```
{
  "family": "charlie-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "charlie-container",
      "image": "IMAGE_PLACEHOLDER",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "essential": true
    }
  ]
}
```

#### 📁 Put this inside:

```
{
  "family": "charlie-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "YOUR_ECS_TASK_EXECUTION_ROLE_ARN",
  "containerDefinitions": [
    {
      "name": "charlie-container",
      "image": "IMAGE_PLACEHOLDER",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ]
    }
  ]
}
```

#### 🔥 IMPORTANT

Replace this:

```
YOUR_ECS_TASK_EXECUTION_ROLE_ARN
```

with your actual ARN.

Example:

```
arn:aws:iam::537236558357:role/ecsTaskExecutionRole
```

Find it here:

AWS Console → IAM → Roles → ecsTaskExecutionRole

### 8️⃣ — Replace Placeholder with New SHA Image During Pipeline

- #### Add step before ECS deploy:

```
- name: 🔄 Update Task Definition Image
  run: |
    sed -i "s|IMAGE_PLACEHOLDER|${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG|g" .github/task-definition.json
```

### STEP 9 — Register New ECS Task Definition

- #### Add:

```
- name: 📦 Register New Task Definition
  run: |
    aws ecs register-task-definition \
      --cli-input-json file://.github/task-definition.json
```

### STEP 10 — Update ECS Service

- #### Deploy:

```
- name: 🚀 Deploy ECS
  run: |
    aws ecs update-service \
      --cluster ${{ secrets.ECS_CLUSTER }} \
      --service ${{ secrets.ECS_SERVICE }} \
      --force-new-deployment
```

### ✅ FINAL RESULT

Every push to GitHub creates:

```
charlie-cafe:a8f22d1
charlie-cafe:9bb71e2
charlie-cafe:f22cd98
```

instead of:

```
charlie-cafe:latest
```

### 🎯 Bonus Pro Tip (Interview/Practice Explanation)

When your friends ask WHY:

Say:

> “Using Git SHA for Docker image tags ensures immutable deployments, version traceability, safer rollbacks, and prevents ECS image caching issues compared to mutable latest tags.”

That sounds like senior DevOps engineer language 😄

### ⚠ My Honest Recommendation For Tomorrow Practice

Since you're just practicing tomorrow, I recommend:

- Keep current latest version first

    - because it's simpler.

    - Then after basic ECS works:

- Upgrade to SHA tagging.

    - Because SHA tagging adds task-definition complexity.

### ✅ Deploy.yml

- #### ⚠️ Before Deploy.yml

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
        sudo apt-get install -y mysql-client jq curl zip python3-pip

    # -------------------------------------------------
    # 4️⃣ Retrieve RDS Secret
    # -------------------------------------------------
    - name: 🗝️ Retrieve RDS Secret
      run: |
        SECRET_JSON=$(aws secretsmanager get-secret-value \
          --secret-id "${{ secrets.RDS_SECRET_ARN }}" \
          --query SecretString --output text)
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
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

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
    # 🔟 Verify Database
    # -------------------------------------------------
    - name: ✅ Verify Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # 11️⃣ Build Docker Image (Fixed)
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: |
        cd $GITHUB_WORKSPACE
        echo "Building Docker image from $GITHUB_WORKSPACE/docker/apache-php/Dockerfile"
        docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 12️⃣ Run Container (CI Test)
    # -------------------------------------------------
    - name: 🚀 Run Container (CI)
      run: |
        docker rm -f test_app || true
        docker run -d -p 80:80 --name test_app charlie-cafe
        sleep 10

    # -------------------------------------------------
    # 13️⃣ Local Health Check (CI)
    # -------------------------------------------------
    - name: ❤️ Test Application (CI)
      run: |
        curl -f http://localhost/ || exit 1

    # -------------------------------------------------
    # 14️⃣ Cleanup Test Container
    # -------------------------------------------------
    - name: 🧹 Cleanup
      run: |
        docker rm -f test_app || true

    # =================================================
    # 🔥 EC2 DEPLOYMENT
    # =================================================

    # -------------------------------------------------
    # 15️⃣ Deploy to EC2 via SSM
    # -------------------------------------------------
    - name: 🚀 Deploy to EC2
      run: |
        aws ssm send-command \
          --targets "Key=InstanceIds,Values=${{ secrets.EC2_INSTANCE_ID }}" \
          --document-name "AWS-RunShellScript" \
          --parameters commands=["/home/ec2-user/charlie-cafe-devops/deploy_via_ssm.sh"] \
          --region ${{ secrets.AWS_REGION }}

    # -------------------------------------------------
    # 16️⃣ Wait for Deployment
    # -------------------------------------------------
    - name: ⏳ Wait for EC2 Deployment
      run: sleep 30

    # -------------------------------------------------
    # 17️⃣ Get EC2 Public IP
    # -------------------------------------------------
    - name: 🌐 Get EC2 IP
      run: |
        INSTANCE_IP=$(aws ec2 describe-instances \
          --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
          --query "Reservations[0].Instances[0].PublicIpAddress" \
          --output text)

        echo "INSTANCE_IP=$INSTANCE_IP" >> $GITHUB_ENV

    # -------------------------------------------------
    # 18️⃣ Remote Health Check (CD)
    # -------------------------------------------------
    - name: 🌐 Test Application (EC2)
      run: |
        curl -f http://$INSTANCE_IP/ || exit 1

    # -------------------------------------------------
    # 19️⃣ Success
    # -------------------------------------------------
    - name: 🎉 Success
      run: echo "CI/CD Pipeline Completed Successfully 🚀"

    # =================================================
    # ⚡ ECR & ECS DEPLOYMENT
    # =================================================

    # -------------------------------------------------
    # 20️⃣ Login to ECR
    # -------------------------------------------------
    - name: 🐳 Login to ECR
      run: |
        aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | \
        docker login --username AWS --password-stdin ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

    # -------------------------------------------------
    # 21️⃣ Build Docker Image for ECS
    # -------------------------------------------------
    - name: 🏗️ Build Docker Image for ECS
      run: |
        docker build -t ${{ secrets.ECR_REPO }} -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 22️⃣ Tag Docker Image
    # -------------------------------------------------
    - name: 🏷️ Tag Docker Image
      run: |
        docker tag ${{ secrets.ECR_REPO }}:latest \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:latest

    # -------------------------------------------------
    # 23️⃣ Push Docker Image to ECR
    # -------------------------------------------------
    - name: 📤 Push Docker Image
      run: |
        docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:latest

    # -------------------------------------------------
    # 24️⃣ Update ECS Service (Deploy new image)
    # -------------------------------------------------
    - name: 🚀 Deploy to ECS
      run: |
        aws ecs update-service \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service ${{ secrets.ECS_SERVICE }} \
          --force-new-deployment

    # -------------------------------------------------
    # 25️⃣ Verify ECS Tasks
    # -------------------------------------------------
    - name: 🌐 Verify ECS Deployment
      run: |
        aws ecs list-tasks --cluster ${{ secrets.ECS_CLUSTER }} --service-name ${{ secrets.ECS_SERVICE }}
        aws ecs describe-tasks --cluster ${{ secrets.ECS_CLUSTER }} --tasks $(aws ecs list-tasks --cluster ${{ secrets.ECS_CLUSTER }} --service-name ${{ secrets.ECS_SERVICE }} --query 'taskArns[*]' --output text)
```

- #### ✅ After FULL ENTERPRISE deploy.yml (UPDATED)

Replace ONLY your ECR/ECS section with this upgraded version.

Your EC2/RDS/DB/Testing stays SAME.

```
name: ☕ Charlie Cafe — FULL CI/CD PIPELINE (FINAL)

on:
  push:
    branches: ["main"]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    env:
      IMAGE_TAG: ${{ github.sha }}

    steps:

    # Existing ALL YOUR OLD STEPS HERE (1–19 remain unchanged)

    # =================================================
    # ⚡ ECR & ECS DEPLOYMENT (IMMUTABLE VERSION)
    # =================================================

    # -------------------------------------------------
    # 20️⃣ Login to ECR
    # -------------------------------------------------
    - name: 🐳 Login to ECR
      run: |
        aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | \
        docker login --username AWS --password-stdin \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

    # -------------------------------------------------
    # 21️⃣ Build Docker Image with Git SHA
    # -------------------------------------------------
    - name: 🏗️ Build Docker Image for ECS
      run: |
        docker build \
          -t ${{ secrets.ECR_REPO }}:$IMAGE_TAG \
          -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 22️⃣ Tag Docker Image
    # -------------------------------------------------
    - name: 🏷️ Tag Docker Image
      run: |
        docker tag \
          ${{ secrets.ECR_REPO }}:$IMAGE_TAG \
          ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG

    # -------------------------------------------------
    # 23️⃣ Push Docker Image
    # -------------------------------------------------
    - name: 📤 Push Docker Image
      run: |
        docker push \
          ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG

    # -------------------------------------------------
    # 24️⃣ Inject New Image into Task Definition
    # -------------------------------------------------
    - name: 🔄 Update Task Definition Image
      run: |
        sed -i "s|IMAGE_PLACEHOLDER|${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG|g" .github/task-definition.json

    # -------------------------------------------------
    # 25️⃣ Register New ECS Task Definition
    # -------------------------------------------------
    - name: 📦 Register New Task Definition
      run: |
        aws ecs register-task-definition \
          --cli-input-json file://.github/task-definition.json

    # -------------------------------------------------
    # 26️⃣ Deploy to ECS
    # -------------------------------------------------
    - name: 🚀 Deploy ECS
      run: |
        aws ecs update-service \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service ${{ secrets.ECS_SERVICE }} \
          --force-new-deployment

    # -------------------------------------------------
    # 27️⃣ Verify ECS Deployment
    # -------------------------------------------------
    - name: 🌐 Verify ECS Deployment
      run: |
        aws ecs list-tasks \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service-name ${{ secrets.ECS_SERVICE }}

        aws ecs describe-tasks \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --tasks $(aws ecs list-tasks \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service-name ${{ secrets.ECS_SERVICE }} \
          --query 'taskArns[*]' \
          --output text)
```

### ✅ Fully Final deploy.yml

#### ✅ Changes Made Only in Requested Areas

- Added Short SHA step after checkout

- Uses copied rendered task definition file instead of modifying original

- Captures TASK_DEF_ARN from ECS register

- Deploys ECS using latest registered revision ARN

#### ✅ FINAL FIXED DEPLOY.YML

```
name: ☕ Charlie Cafe — FULL CI/CD PIPELINE (FINAL)

on:
  push:
    branches: ["main"]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    env:
      IMAGE_TAG: ${{ github.sha }}

    steps:

    # -------------------------------------------------
    # 1️⃣ Checkout Repository
    # -------------------------------------------------
    - name: 📥 Checkout Code
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 1.5️⃣ Shorten Git SHA
    # -------------------------------------------------
    - name: 🔤 Shorten Git SHA
      run: echo "IMAGE_TAG=${GITHUB_SHA::7}" >> $GITHUB_ENV

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
        sudo apt-get install -y mysql-client jq curl zip python3-pip

    # -------------------------------------------------
    # 4️⃣ Retrieve RDS Secret
    # -------------------------------------------------
    - name: 🗝️ Retrieve RDS Secret
      run: |
        SECRET_JSON=$(aws secretsmanager get-secret-value \
          --secret-id "${{ secrets.RDS_SECRET_ARN }}" \
          --query SecretString --output text)
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
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

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
    # 🔟 Verify Database
    # -------------------------------------------------
    - name: ✅ Verify Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # 11️⃣ Build Docker Image (Fixed)
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: |
        cd $GITHUB_WORKSPACE
        echo "Building Docker image from $GITHUB_WORKSPACE/docker/apache-php/Dockerfile"
        docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 12️⃣ Run Container (CI Test)
    # -------------------------------------------------
    - name: 🚀 Run Container (CI)
      run: |
        docker rm -f test_app || true
        docker run -d -p 80:80 --name test_app charlie-cafe
        sleep 10

    # -------------------------------------------------
    # 13️⃣ Local Health Check (CI)
    # -------------------------------------------------
    - name: ❤️ Test Application (CI)
      run: |
        curl -f http://localhost/ || exit 1

    # -------------------------------------------------
    # 14️⃣ Cleanup Test Container
    # -------------------------------------------------
    - name: 🧹 Cleanup
      run: |
        docker rm -f test_app || true

    # =================================================
    # 🔥 EC2 DEPLOYMENT
    # =================================================

    # -------------------------------------------------
    # 15️⃣ Deploy to EC2 via SSM
    # -------------------------------------------------
    - name: 🚀 Deploy to EC2
      run: |
        aws ssm send-command \
          --targets "Key=InstanceIds,Values=${{ secrets.EC2_INSTANCE_ID }}" \
          --document-name "AWS-RunShellScript" \
          --parameters commands=["/home/ec2-user/charlie-cafe-devops/deploy_via_ssm.sh"] \
          --region ${{ secrets.AWS_REGION }}

    # -------------------------------------------------
    # 16️⃣ Wait for Deployment
    # -------------------------------------------------
    - name: ⏳ Wait for EC2 Deployment
      run: sleep 30

    # -------------------------------------------------
    # 17️⃣ Get EC2 Public IP
    # -------------------------------------------------
    - name: 🌐 Get EC2 IP
      run: |
        INSTANCE_IP=$(aws ec2 describe-instances \
          --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
          --query "Reservations[0].Instances[0].PublicIpAddress" \
          --output text)

        echo "INSTANCE_IP=$INSTANCE_IP" >> $GITHUB_ENV

    # -------------------------------------------------
    # 18️⃣ Remote Health Check (CD)
    # -------------------------------------------------
    - name: 🌐 Test Application (EC2)
      run: |
        curl -f http://$INSTANCE_IP/ || exit 1

    # -------------------------------------------------
    # 19️⃣ Success
    # -------------------------------------------------
    - name: 🎉 Success
      run: echo "CI/CD Pipeline Completed Successfully 🚀"

    # =================================================
    # ⚡ ECR & ECS DEPLOYMENT (IMMUTABLE VERSION)
    # =================================================

    # -------------------------------------------------
    # 20️⃣ Login to ECR
    # -------------------------------------------------
    - name: 🐳 Login to ECR
      run: |
        aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | \
        docker login --username AWS --password-stdin \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

    # -------------------------------------------------
    # 21️⃣ Build Docker Image with Git SHA
    # -------------------------------------------------
    - name: 🏗️ Build Docker Image for ECS
      run: |
        docker build \
          -t ${{ secrets.ECR_REPO }}:$IMAGE_TAG \
          -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 22️⃣ Tag Docker Image
    # -------------------------------------------------
    - name: 🏷️ Tag Docker Image
      run: |
        docker tag \
          ${{ secrets.ECR_REPO }}:$IMAGE_TAG \
          ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG

    # -------------------------------------------------
    # 23️⃣ Push Docker Image
    # -------------------------------------------------
    - name: 📤 Push Docker Image
      run: |
        docker push \
          ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG

    # -------------------------------------------------
    # 24️⃣ Copy Task Definition Template
    # -------------------------------------------------
    - name: 📄 Copy Task Definition Template
      run: |
        cp .github/task-definition.json .github/task-definition-rendered.json

    # -------------------------------------------------
    # 25️⃣ Inject New Image into Rendered Task Definition
    # -------------------------------------------------
    - name: 🔄 Update Task Definition Image
      run: |
        sed -i "s|IMAGE_PLACEHOLDER|${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG|g" .github/task-definition-rendered.json

    # -------------------------------------------------
    # 26️⃣ Register New ECS Task Definition
    # -------------------------------------------------
    - name: 📦 Register New Task Definition
      run: |
        TASK_DEF_ARN=$(aws ecs register-task-definition \
          --cli-input-json file://.github/task-definition-rendered.json \
          --query 'taskDefinition.taskDefinitionArn' \
          --output text)

        echo "TASK_DEF_ARN=$TASK_DEF_ARN" >> $GITHUB_ENV

    # -------------------------------------------------
    # 27️⃣ Deploy to ECS
    # -------------------------------------------------
    - name: 🚀 Deploy ECS
      run: |
        aws ecs update-service \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service ${{ secrets.ECS_SERVICE }} \
          --task-definition $TASK_DEF_ARN \
          --force-new-deployment

    # -------------------------------------------------
    # 28️⃣ Verify ECS Deployment
    # -------------------------------------------------
    - name: 🌐 Verify ECS Deployment
      run: |
        aws ecs list-tasks \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service-name ${{ secrets.ECS_SERVICE }}

        aws ecs describe-tasks \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --tasks $(aws ecs list-tasks \
          --cluster ${{ secrets.ECS_CLUSTER }} \
          --service-name ${{ secrets.ECS_SERVICE }} \
          --query 'taskArns[*]' \
          --output text)
```

#### ✅ Final Result

Your pipeline is now:

- Production Grade

- Immutable deployments ✅

- Safe task definition rendering ✅

- Guaranteed latest ECS revision deploy ✅

- Clean short Docker tags ✅

#### ✅ My Small Professional Note

You still technically have:

```
env:
  IMAGE_TAG: ${{ github.sha }}
```

at top AND override later with short SHA.

That is perfectly valid because GitHub ENV later overwrites it.

#### 🚀 🔥 IMPORTANT REQUIRED GITHUB SECRETS

Ensure these exist:

| Secret                | Example         |
| --------------------- | --------------- |
| AWS_ACCESS_KEY_ID     | AKIAxxxxx       |
| AWS_SECRET_ACCESS_KEY | xxxxx           |
| AWS_REGION            | us-east-1       |
| AWS_ACCOUNT_ID        | 537236558357    |
| ECS_CLUSTER           | charlie-cluster |
| ECS_SERVICE           | charlie-service |
| ECR_REPO              | charlie-cafe    |

### 🚀 HOW THIS WORKS NOW

1. Every push:

Example:

```
commit:
a84d92f
```

2. Pipeline creates:

```
charlie-cafe:a84d92f
```

3. Pushes to ECR:

```
537236558357.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:a84d92f
```

Then ECS deploys that exact version.

### 🚀 BENEFITS YOU GET

#### Before:

```
latest
latest
latest
```

#### Problem:

- overwritten every deploy

- no rollback

- cache issue

#### After:

```
v1 = a84d92f
v2 = c91f223
v3 = 7ab8821
```

#### Benefits:

- track every version

- rollback easily

- immutable deployment

- professional DevOps

### 🚨 VERY IMPORTANT WARNING

Your ECS service MUST use:

```
Task Definition Family:
charlie-task
```

Because we used:

```
"family": "charlie-task"
```

Make sure it EXACTLY matches ECS.

### 🎯 FINAL RESULT FLOW

Your pipeline becomes:

```
Git Push
   ↓
Run DB Migration
   ↓
Build/Test Docker
   ↓
Deploy EC2
   ↓
Push SHA Image to ECR
   ↓
Register New Task Definition
   ↓
Deploy ECS New Version
```

---
## 🌐 Implement Blue/Green Deployment in Amazon ECS Using Application Load Balancer (Zero Downtime Deployment Strategy)

### 🧠 FIRST — YOUR CONFUSION (CLEAR EXPLANATION)

You already created:


- charlie-blue target group

- charlie-green target group

👉 Good, BUT THIS IS ONLY HALF OF THE SYSTEM

### 🔴 What you currently have (IMPORTANT)

Right now you configured:

- ALB → forwards traffic ONLY to blue

- ECS service → also uses blue target group

So:

```
ALB → Blue (active)
Green → NOT USED yet
```

👉 Green is just sitting idle

### 🟢 What Blue/Green REALLY means (REAL DEVOPS)

| Concept | Meaning                         |
| ------- | ------------------------------- |
| Blue    | Current live production version |
| Green   | New version being deployed      |
| Switch  | Traffic shift from Blue → Green |
| Goal    | Zero downtime deployment        |

### ⚠ IMPORTANT MISUNDERSTANDING

You said:

> I already created blue & green target groups

✔ That is correct

BUT ❌ that alone does NOT make blue/green deployment

👉 ECS must be configured to use deployment controller = CODE_DEPLOY

### 🚀 FINAL ARCHITECTURE (PRO LEVEL)

```
                ┌──────────────┐
                │     ALB      │
                └──────┬───────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
   Blue Target Group           Green Target Group
   (v1 - live)                (v2 - new version)
```

BUT:

👉 ECS will NOT manually switch this

👉 AWS CodeDeploy does it automatically

### 🚀 STEP-BY-STEP GUIDE

### 1️⃣ — VERIFY YOUR TARGET GROUPS (YOU ALREADY DID)

You should have:

#### ✅ STEP 1 — Blue

- name: charlie-blue

- type: IP

- health: /health.php

#### ✅ STEP 2 — Green

- name: charlie-green

- type: IP

- health: /health.php

✔ Perfect

### 2️⃣ — UPDATE ALB LISTENER (IMPORTANT FIX)

- Go to: 👉 EC2 → Load Balancers → Listeners → HTTP:80

You MUST change default action to:

```
Forward → charlie-blue
```

✔ This means production traffic goes to BLUE first

### 3️⃣ — CHANGE ECS SERVICE (VERY IMPORTANT)

- Go to: 👉 ECS → Cluster → charlie-cluster → Services → charlie-service

- Click: 👉 Update Service

- Find: Deployment type

- Change from: 

```
Rolling update ❌
```

- To:

```
Blue/Green deployment (CODE_DEPLOY) ✅
```

### 4️⃣ — CREATE CODEDEPLOY APPLICATION

- Go to: 👉 AWS CodeDeploy → Applications → Create Application

- Fill:

| Field            | Value           |
| ---------------- | --------------- |
| Application Name | charlie-ecs-app |
| Compute Platform | ECS             |

### 5️⃣ — CREATE DEPLOYMENT GROUP

- Inside CodeDeploy App:

- Click: 👉 Create Deployment Group

- Fill:

- Basic settings

 | Field        | Value                                |
| ------------ | ------------------------------------ |
| Name         | charlie-ecs-deployment-group         |
| Service Role | create new or select CodeDeploy role |

- Environment settings:

| Field       | Value           |
| ----------- | --------------- |
| ECS Cluster | charlie-cluster |
| ECS Service | charlie-service |

- Load Balancer settings:

    - Select: Application Load Balancer

- Then choose:

    - Target Group 1 → charlie-blue

    - Target Group 2 → charlie-green

    - Production listener → HTTP:80

### 6️⃣ — CREATE APPSPEC FILE (CRITICAL)

- Inside your repo create:

```
appspec.yaml
```

- Paste this:

```
version: 1
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "TASK_DEFINITION"
        LoadBalancerInfo:
          ContainerName: "charlie-container"
          ContainerPort: 80
```

### 7️⃣ — UPDATE ECS TASK DEFINITIONS FOR BLUE/GREEN

Now ECS will create:

new task definition version per deployment

👉 You DO NOT manually switch traffic

👉 CodeDeploy handles switching

### 8️⃣ — UPDATE ECS SERVICE (FINAL CONFIG)

- Go to ECS Service → Update:

- Set:

```
Deployment controller:
   AWS CodeDeploy
```

NOT:

```
ECS rolling update ❌
```

### 9️⃣ — UPDATE YOUR GITHUB ACTION (IMPORTANT)

- Instead of:

```
aws ecs update-service --force-new-deployment
```

You will now use:

```
aws deploy create-deployment \
  --application-name charlie-ecs-app \
  --deployment-group-name charlie-ecs-deployment-group \
  --revision revisionType=AppSpecContent,appSpecContent="{...}"
```

👉 (I can simplify this later for you if you want)

### 🔟 — HOW DEPLOYMENT NOW WORKS

Every push:

#### Phase 1

- New task created

#### Phase 2

- Green target group gets new version

#### Phase 3

- Health checks run

#### Phase 4

- Traffic shifts:

- Blue → Green

#### Phase 5

- Old version kept for rollback

### 🔥 FINAL DIFFERENCE (VERY IMPORTANT)

#### ❌ Your current setup

- ALB → Blue only

- ECS rolling update

- Old version replaced

👉 This is NOT blue/green

#### ✅ True Blue/Green setup

- ALB → Blue + Green

- CodeDeploy controls traffic shift

- Zero downtime

- Instant rollback possible

### 🎯 SIMPLE WAY TO REMEMBER

| Type           | Meaning               |
| -------------- | --------------------- |
| Blue/Green TGs | Just infrastructure   |
| CodeDeploy     | Traffic switch engine |
| ECS Service    | Runs containers       |
| ALB            | Routes traffic        |

### 🚨 MY HONEST RECOMMENDATION

Since you're practicing:

#### Phase 1 (NOW)

✔ Keep your current ECS + latest deploy working

#### Phase 2 (NEXT STEP)

✔ Add Git SHA versioning

#### Phase 3 (ADVANCED)

✔ Add CodeDeploy Blue/Green (this guide)
---