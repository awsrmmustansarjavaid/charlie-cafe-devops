# Charlie Cafe — Amazon ECR Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon ECR.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

#### 🔹 ECR Docker Registry Endpoint

| Parameter      | Value                               |
| -------------- | ----------------------------------- |
| Name           | `ecr-dkr-endpoint`                  |
| Service        | `com.amazonaws.us-east-1.ecr.dkr`   |
| Type           | Interface                           |
| Purpose        | Docker image pull (registry access) |
| Subnets        | Private ECS subnets                 |
| Security Group | ECS SG allowed outbound HTTPS (443) |
| Private DNS    | Enabled                             |


## 1️⃣1️⃣ ☁️ AWS DEVOPS UPGRADE -- ECS & ECR

Read more about [Charlie Cafe - AWS DEVOPS ECS & ECR Configurations](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/AWS%20Services%20Configurations%20/Charlie-cafe_AWS-DEVOPS_ECS_ECR-Configurations.md)


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


### 🌐 deploy-ecr-docker (Recommanded)

```
nano deploy-ecr-docker.sh
```

[deploy-ecr-docker](./infrastructure/scripts/deploy-ecr-docker.sh)

```
chmod +x deploy-ecr-docker.sh
./deploy-ecr-docker.sh
```

or 


#### 2️⃣ Login to ECR

On your local machine (or EC2):

```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
```


#### 3️⃣ Go to ROOT project folder

```
cd ~/charlie-cafe-devops
```


#### 4️⃣ Build using Dockerfile path

```
docker build -t charlie-cafe -f docker/apache-php/Dockerfile .
```


#### 🔥 IMPORTANT:

The dot . means:

“use FULL project root as build context”

- -t charlie-cafe → names your image charlie-cafe.

- . → tells Docker to use the current folder for the Dockerfile and context.


#### Now Docker can see:

```
app/frontend/
docker/apache-php/Dockerfile
```


#### 5️⃣ Tag image for ECR

```
docker tag charlie-cafe:latest 537236558357.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
```


#### 6️⃣ Push the Docker image to ECR

```
docker push 537236558357.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
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


### 3️⃣ Verification Test 


### 1️⃣  Verify Container

- Go to ECS → Cluster → Tasks.

- Click on your task → Containers → View Logs.

- Verify container started successfully, listening on port 80.


### 2️⃣ Verify Target Group

- Go EC2 → Target Groups → charlie-blue → Targets

> You should see IP addresses (Fargate tasks) and Status: Healthy


#### You should see:

- IP addresses (NOT EC2)

- Status: Healthy


### 2️⃣ Quick Test Before Redeploy (Optional)


# Test ECR API
curl -v https://api.ecr.us-east-1.amazonaws.com/


# Test ECR Docker registry
curl -v https://537236558357.dkr.ecr.us-east-1.amazonaws.com/v2/
```

- Timeout → network problem

- JSON / HTTP 200 → network works


#### 🔹 Step 2: Verify ECS Once Networking Works

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


#### 🔹 Step 3: Make sure AWS CLI works

```
aws sts get-caller-identity
```

If this works → IAM role is OK.


#### 🔹 Step 4: Login to ECR

```
aws ecr get-login-password --region us-east-1 \
| docker login --username AWS --password-stdin 537236558357.dkr.ecr.us-east-1.amazonaws.com
```


#### Expected success output:

```
Login Succeeded
```


#### 🔹 Step 5: Login to ECR

```
docker pull 537236558357.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
``` 


#### 🔹 Step 6: 🌐 Access App

- Go to your ALB DNS in browser

```
http://YOUR-ALB-DNS
```

✅ It should now serve your Dockerized app


### 4️⃣ GITHUB CI/CD (AUTO DEPLOY)

- ### 1️⃣ Add GitHub Secrets


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


### 5️⃣ Commit & Push

- Save the updated deploy.yml in .github/workflows/

- Commit & push to main

- GitHub Actions will automatically trigger

- Check Actions tab → Logs for each step

✅ If all steps succeed, your ECS service will be automatically updated whenever you push to main.


### 6️⃣ Testing the ECS Deployment

- Go to ECS → Cluster → charlie-cluster → Tasks

- You should see new tasks running with the latest image

- Go to ALB → Target Groups → charlie-blue → Targets

- Status should be Healthy

- Open your ALB DNS in the browser to test the live app


#### 🔍 Open:

```
http://YOUR-ALB-DNS
```

---

## 🚀 Enterprise Zero-Downtime CI/CD Pipeline (ECS + CodeDeploy + Immutable Images)


### ✅ Prerequisites

- Application Load Balancer (ALB) is configured

- Two target groups created:

  - charlie-blue

  - charlie-green

- Health check endpoint configured: /health.php

- ALB Listener (HTTP:80) is set to forward traffic to charlie-blue

> #### 👉 “ALB with blue/green target groups is already configured, with traffic currently routed to charlie-blue and health checks on /health.php.”


### 📁 REQUIRED FILES (VERY IMPORTANT)

You need 2 files in repo:


### ✅ 1. appspec.yaml

```
version: 1
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "charlie-task"
        LoadBalancerInfo:
          ContainerName: "charlie-container"
          ContainerPort: 80
```


### ✅ 2. .github/task-definition.json

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


### ✅ IAM ROle for CodeDeploy

- Go to IAM role → create iam role 

- Select Trusted Entity: AWS service

- Use case: CodeDeploy


#### You will see 3 options:

- CodeDeploy

- CodeDeploy for Lambda

- ✅ CodeDeploy for ECS ← SELECT THIS

- AWS will automatically attach: 👉 AWSCodeDeployRoleForECS

- Role Name: charlie-codedeploy-role

👉 Click Create role


### 1️⃣ — CREATE CODEDEPLOY APP

- Go to AWS CODEDEPLOY → Applications → Click Create application

- Application name: charlie-ecs-app

- Compute platform: ECS

- ✅ Click Create


### 2️⃣ — CREATE DEPLOYMENT GROUP

👉 Now inside that app: Click Create deployment group

- Name: charlie-ecs-deployment-group

- Service role: 👉 Select your role: charlie-codedeploy-role

- Deployment type: Blue/Green


### Environment configuration:

- Cluster: charlie-cluster

- Service: charlie-service


### Load balancer:

- Select: Application Load Balancer

- Choose: charlie-cafe-alb


#### Target groups:

- Blue → charlie-blue

- Green → charlie-green


#### Deployment settings:

- Traffic shifting: All at once

👉 Click Create deployment group


### 2️⃣ — ECS SERVICE (CRITICAL)

- Go to ECS → Clusters → charlie-cluster → Services → charlie-service

- Top right → Click Update

> Now scroll slowly 👇

- Look for:

   👉 Deployment configuration

   👉 Deployment controller

- CHANGE CONTROLLER: 

👉 Scroll to: Deployment options → Deployment controller type

- ❌ Current: ❌ ECS

- ✅ Change to: ✅ CodeDeploy

- Deployment strategy:

> #### You will see something like:

   > - Rolling update (default)

   > - External (CodeDeploy)

- ❌ Current: ❌ Rolling update

- ✅ Change to: ✅ Blue/Green (CodeDeploy)

- Service role: 👉 Select your role: charlie-codedeploy-role

- Load Balancing → Blue/Green config: 

- Choose: charlie-cafe-alb

- Target groups:

   - Blue → charlie-blue

   - Green → charlie-green

- Click Update 


#### ⚠️ VERY IMPORTANT BEHAVIOR

👉 The moment you select CodeDeploy:

👉 Sometimes it shows as:

```
Deployment controller: CodeDeploy
```

You will see UI changes like:

- Blue target group field becomes active

- Green target group field becomes selectable ✅

- ALB config becomes mandatory


### 4️⃣ — ECS TASK EXECUTION ROLE

- Use:

```
ecsTaskExecutionRole
```

- Put ARN in:

```
task-definition.json
```


### 5️⃣ — PUSH CODE

```
git add .
git commit -m "final pipeline"
git push origin main
```

---

## ☁️ CHARLIE CAFE — PRODUCTION BLUE/GREEN CANARY DEPLOYMENT WITH AUTO ROLLBACK & MONITORING


### 1️⃣ — Enable Canary Deployment

In deployment group:


#### Deployment config:

```
CodeDeployDefault.ECSCanary10Percent5Minutes
```


### 2️⃣ — Enable Auto Rollback


#### Enable:

✔ Rollback on:

- Deployment failure

- Alarm trigger


### 3️⃣ — Create CloudWatch Alarm


#### Create alarm:

- Name: charlie-health-alarm

- Metric: UnHealthyHostCount

- Target Group: charlie-green

- Condition: >= 1


### 🧭 STEP-BY-STEP UPGRADE


### 2️⃣ — ENABLE AUTO ROLLBACK

Inside SAME deployment group:


#### Turn ON:

```
✔ Rollback when deployment fails
✔ Rollback when CloudWatch alarm triggers
```


### 3️⃣ — CREATE CLOUDWATCH ALARM

- Go to: 👉 CloudWatch → Alarms → Create Alarm


### 📊 ALARM 1 (CRITICAL)

- Name: charlie-green-unhealthy-alarm

- Metric: ApplicationELB → UnHealthyHostCount

- Target Group: charlie-green

- Condition: >= 1 for 1 minute


### 5️⃣ GitHub → Auto-Deploy Setup (Charlie Cafe)

> #### Optional Task 

- Read more here [GitHub Auto-Deploy Config](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/Github%20Tasks%20Configurations/GitHub_Auto-Deploy_Config.md)


### ✅ TRIGGER deploy.yml (VERY IMPORTANT)

- You DO NOT run deploy.yml manually ❌

- GitHub Actions runs it automatically ✅


#### 🔹 METHOD 1 — Trigger via Push (RECOMMENDED)

Run this on your local machine or EC2:

```
cd ~/charlie-cafe-devops

git add .
git commit -m "🚀 trigger deployment"
git push origin main
```


#### 👉 This will:

- Trigger GitHub Actions

- Start your CI/CD pipeline automatically


#### 🔹 METHOD 2 — Manual Trigger (Optional)

If your workflow supports it:

- Go to GitHub repo

- Click Actions tab

- Select workflow

- Click Run workflow


### 6️⃣ — VERIFY ECS + ALB BEHAVIOR

After deployment:

You will see:


#### Phase 1:

- 10% users → GREEN


#### Phase 2:

CloudWatch monitors health


#### Phase 3:

If OK → 100% traffic to GREEN


#### Phase 4:

If FAIL → rollback to BLUE
---

## ✅ 🔥 BEST ALTERNATIVES (WITHOUT CodeDeploy)


### 🚀 ECS Rolling Deployment (NO CodeDeploy, FREE, ZERO DOWNTIME)

```
nano ecs_zero_downtime_deploy.sh
```

[ecs_zero_downtime_deploy.sh](./infrastructure/scripts/ecs_zero_downtime_deploy.sh)


### 🔥 MAKE FILE EXECUTABLE & RUN IT


#### After saving:

```
chmod +x ecs_zero_downtime_deploy.sh
./ecs_zero_downtime_deploy.sh
```


### 🔍 VERIFY TEST


### 1️⃣ VERIFY ECS DEPLOYMENT

- Go here: ECS → Your Cluster → charlie-cluster


#### 📊 WHAT YOU SHOULD SEE HERE

- Inside cluster:

✔ Service name: charlie-service

✔ Status: ACTIVE

✔ Running tasks: 1 (or more depending on your config)

- go to charlie-service → Now go into Service details page

- Go to Check DEPLOYMENTS TAB → Scroll to → Deployments section 

✔ EXPECTED OUTPUT YOU SHOULD SEE

You should see something like:

| Field           | Value                      |
| --------------- | -------------------------- |
| Primary         | YES                        |
| Status          | **COMPLETED**              |
| Task Definition | charlie-task:4 (or latest) |
| Desired Count   | 1                          |
| Running Count   | 1                          |


👉 If you see:

```
PRIMARY = YES
STATUS = COMPLETED
```

✔ That means rolling update succeeded


### 2️⃣ Verify EVENTS TAB

- Click tab: Events

✔ EXPECTED SUCCESS EVENTS

You should see messages like:

```
service charlie-service has started 1 tasks
service charlie-service has stopped 1 running tasks
service reached steady state
```

👉 Most important line:

```
service reached steady state
```

✔ This confirms ZERO downtime deployment completed


### 3️⃣ Check TASKS (RUNNING CONTAINERS)

- Go to: Tasks tab

✔ EXPECTED OUTPUT

You should see:

- Task status = RUNNING

- Launch type = FARGATE / EC2 (your setup)

- Health = HEALTHY

- Task definition = latest revision (e.g. charlie-task:4)


### 4️⃣ VERIFY NEW IMAGE IS RUNNING

- Click the running task → open details

- Check: Container image

✔ EXPECTED:

```
537236558357.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
```

👉 If it matches your latest push = SUCCESS


### 5️⃣ VERIFY APPLICATION (REAL TEST)

- Open ALB URL:

```
http://<your-alb-dns>/health.php
```

✔ EXPECTED OUTPUT:

```
OK
```

OR:

```
200 OK
```


### 📊 FINAL “PRO DEVOPS CHECKLIST”

If ALL below are true → deployment is PERFECT:

✔ Service = ACTIVE

✔ Deployment = COMPLETED

✔ Running tasks = 1

✔ Events = "steady state reached"

✔ Task = latest revision

✔ ALB health = OK



### 7️⃣ Charlie Cafe cleanup

[ec2-cleanup.sh](./infrastructure/scripts/ec2-cleanup.sh)


#### How to use:

- Save this as ec2-cleanup.sh on your EC2.

```
nano ec2-cleanup.sh
```

- Make it executable:

```
chmod +x ec2-cleanup.sh
```

- Run it:

```
./ec2-cleanup.sh
```


### 8️⃣ Charlie Cafe -- Github Logs

[Charlie Cafe -- Github Logs](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/Github%20Tasks%20Configurations/Charlie-cafe_github-logs.md)

```
nano ~/github_logs_setup_capture.sh
```

[github_logs_setup_capture](./infrastructure/scripts/github_logs_setup_capture.sh)

```
chmod +x ~/github_logs_setup_capture.sh
~/github_logs_setup_capture.sh
```

- #### Check logs:

```
ls -la ~/charlie-cafe-devops/github_logs
less ~/charlie-cafe-devops/github_logs/github_logs_173_20260402_151230.txt
```
---

## ☕ 4. Lab Task List (Step-by-Step)


### 🔹 Phase 1 – Setup

⬜️ Create GitHub repo

⬜️ Organize project structure

⬜️ Setup Docker (local)


### 🔹 Phase 2 – AWS Foundation

⬜️ Create VPC, subnets

⬜️ Configure Security Groups

⬜️ Launch EC2 instance

⬜️ Setup ALB


### 🔹 Phase 3 – Database

⬜️ Create RDS MySQL

⬜️ Create DynamoDB tables:

⬜️ CafeMenu

⬜️ CafeOrders

⬜️ CafeOrderMetrics

⬜️ CafeAttendance

⬜️ Store credentials in Secrets Manager


### 🔹 Phase 4 – Lambda + SQS 

⬜️ Create Lambda functions

⬜️ Connect Lambda to VPC

⬜️ Configure environment variables

⬜️ Create SQS queue


### 🔹 Phase 5 – API Layer

⬜️ Create API Gateway

⬜️ Connect endpoints to Lambda

⬜️ Enable CORS

⬜️ Add Cognito authorizer


### 🔹 Phase 6 – Authentication

⬜️ Setup Cognito User Pool

⬜️ Create users & groups

⬜️ Configure Hosted UI


### 🔹 Phase 7 – DevOps

⬜️ Create Dockerfile

⬜️ Push image to ECR

⬜️ Deploy ECS service

⬜️ Configure ALB target group


### 🔹 Phase 8 – CI/CD

⬜️ Setup GitHub Actions

⬜️ Add AWS secrets

⬜️ Automate deployment


### 🔹 Phase 9 – Advanced

⬜️ Setup Blue/Green deployment

⬜️ Configure CodeDeploy

⬜️ Add CloudWatch alarms

----

## 📑 Important Charlie Cafe DOC

1. [Charlie Cafe DEVOPS Cheatsheet](./docs/Charlie-Cafe-DEVOPS-Cheatsheet.md)


