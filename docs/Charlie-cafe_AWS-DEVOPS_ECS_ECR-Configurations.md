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

- ### 2️⃣ Create ECS Cluster

- Go to ECS → Clusters → Create Cluster.

- Select Networking Only (Fargate).

- Click Next Step.

- Name your cluster: charlie-cluster.

- Leave other defaults (VPC, subnets) for now unless you have a specific setup.

- Click Create.

Wait until the status shows Active.

✅ No need to attach EC2 instances since this is Fargate.

- ### 3️⃣ Create Task Execution Role (if not exists)

The task execution role is needed for Fargate to pull images from ECR and write logs to CloudWatch.

- Go to IAM → Roles → Create Role → AWS Service → Elastic Container Service → Task Execution Role.

- Click Next: Permissions.

- Attach AmazonECSTaskExecutionRolePolicy.

- Name it: ecsTaskExecutionRole.

- Click Create Role.

This role will be used later in the task definition.

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

```

- #### ✅ After Updated Deploy.yml

```

```

---
