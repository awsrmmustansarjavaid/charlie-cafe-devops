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

#### ✅ add ECR permissions to your IAM role policy

> you need to add ECR permissions to your IAM role policy. Here’s a minimal example you can add to your existing role JSON:

```
{
    "Sid": "ECRAuthorizationToken",
    "Effect": "Allow",
    "Action": "ecr:GetAuthorizationToken",
    "Resource": "*"
},
{
    "Sid": "ECRRepoAccess",
    "Effect": "Allow",
    "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ecr:CreateRepository"
    ],
    "Resource": "arn:aws:ecr:us-east-1:your aws account:repository/charlie-cafe"
}
```

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

### 💡 ThroubleShooting 

#### 1- Refresh IAM credentials on the EC2 instance:

```
aws sts get-caller-identity
```

#### 2- Retry the login on EC2 instance:

```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin your aws account id.dkr.ecr.us-east-1.amazonaws.com
```

> #### Replace your aws account id with your

#### 3- Check your current directory:

```
pwd
ls -l
```

- Make sure you are in the folder where your Dockerfile is located.

- If your Dockerfile is in, for example, ~/charlie-cafe-devops/app/frontend/, navigate there:

```
cd ~/charlie-cafe-devops/app/frontend/
ls -l
```

You should see:

```
Dockerfile
login.html
charlie-cafe-link-generator.html
...
```

#### 4- Build the Docker image from that folder:

```
docker build -t charlie-cafe .
```

- -t charlie-cafe → names your image charlie-cafe.

- . → tells Docker to use the current folder for the Dockerfile and context.

#### 5- Tag and push (from the same directory):

```
docker tag charlie-cafe:latest 537236558357.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
docker push 537236558357.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
```

#### 6- Push the Docker image to ECR

```
docker push 537236558357.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
```

✅ After this, your Docker image will be in ECR, ready for ECS or Fargate deploymen

#### 7- If your Dockerfile has a different name or location:

```
docker build -t charlie-cafe -f /path/to/Dockerfile .
```

#### 8- Go to the folder with the Dockerfile

```
cd ~/charlie-cafe-devops/docker/apache-php/
```

Check the file exists:

```
ls -l Dockerfile
# should show your Dockerfile
```

#### 9- If you want to build from anywhere, you can also specify the Dockerfile path:

```
docker build -t charlie-cafe -f ~/charlie-cafe-devops/docker/apache-php/Dockerfile ~/charlie-cafe-devops/docker/apache-php/
```

This avoids having to cd into the folder.

#### 10- Clean up old images locally

```
docker images
docker rmi charlie-cafe:latest
```

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

- 👉 Go to EC2 → Target Groups → Create Target Group.

#### 🔵 Blue Target Group

- Name: charlie-blue

- Target type: IP (IMPORTANT)

> ✅ (because Fargate tasks get their own ENI and private IP in the VPC, not EC2 instances).

- Protocol / Port: HTTP / 80.

- Health check: /health.php

> ✅ (or / if your container does not have a health endpoint yet).

- VPC: Select the VPC where your ECS cluster / tasks run.

- Leave other settings default → Create.

> ✅ Important: Do NOT select EC2 instances. For Fargate, the targets are IP addresses of tasks, not EC2 machines.

#### 🟢 Green Target Group

> ✅ Repeat the same steps for the green deployment:

- Name: charlie-green

- Target Type: IP

- Protocol: HTTP / 80

- Health check: /health.php

- VPC: same as ECS tasks

- Click Create.

> ✅ This is usually used for blue/green deployments, but even if you are just testing, it’s good practice to have separate TGs.

#### ✅ Key Points

- VPC: Must match the VPC of your ECS tasks. Otherwise, the ALB cannot route traffic to the Fargate tasks.

- Do not select EC2: In Fargate, there is no EC2 host visible to the ALB. The ALB targets Fargate tasks via their private IPs automatically when ECS service registers them.

- Health Check: Make sure /health.php exists in your container. Otherwise use / or another valid endpoint.

#### ✅ Summary:

| Setting         | Value for Fargate ECS |
| --------------- | --------------------- |
| Target Type     | IP                    |
| Protocol / Port | HTTP / 80             |
| Health Check    | /health.php           |
| VPC             | Same as ECS tasks     |
| Register EC2    | ❌ Do not select     |

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

### 🌐 FINAL BASH SCRIPT (ECR + CI/CD TEST + ACCESS URL - Optional)

Only if:

- You want manual deployment from EC2

- Or GitHub Actions is down

- Or you want quick local testing

```
#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — ECR PUSH + CI/CD TEST SCRIPT
# ----------------------------------------------------------
# ✔ Login to AWS ECR
# ✔ Build Docker Image
# ✔ Tag Image
# ✔ Push to ECR
# ✔ Trigger GitHub Pipeline
# ✔ Display ALB URL
# ==========================================================

# -------------------------------
# 🔧 CONFIGURATION (EDIT THESE)
# -------------------------------
AWS_REGION="us-east-1"
ECR_URI="YOUR_ECR_URI"              # e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe
IMAGE_NAME="charlie-cafe"
IMAGE_TAG="latest"
ALB_DNS="YOUR-ALB-DNS"             # e.g. charlie-alb-123.us-east-1.elb.amazonaws.com

# -------------------------------
# 1️⃣ LOGIN TO ECR
# -------------------------------
echo "🔐 Logging into AWS ECR..."

aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $ECR_URI

if [ $? -ne 0 ]; then
  echo "❌ ECR Login Failed"
  exit 1
fi

echo "✅ ECR Login Successful"
echo "----------------------------------------"

# -------------------------------
# 2️⃣ BUILD DOCKER IMAGE
# -------------------------------
echo "🐳 Building Docker Image..."

docker build -t $IMAGE_NAME .

if [ $? -ne 0 ]; then
  echo "❌ Docker Build Failed"
  exit 1
fi

echo "✅ Docker Build Successful"
echo "----------------------------------------"

# -------------------------------
# 3️⃣ TAG DOCKER IMAGE
# -------------------------------
echo "🏷️ Tagging Image..."

docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_URI:$IMAGE_TAG

if [ $? -ne 0 ]; then
  echo "❌ Docker Tag Failed"
  exit 1
fi

echo "✅ Image Tagged Successfully"
echo "----------------------------------------"

# -------------------------------
# 4️⃣ PUSH TO ECR
# -------------------------------
echo "📤 Pushing Image to ECR..."

docker push $ECR_URI:$IMAGE_TAG

if [ $? -ne 0 ]; then
  echo "❌ Docker Push Failed"
  exit 1
fi

echo "✅ Image Pushed to ECR"
echo "----------------------------------------"

# -------------------------------
# 5️⃣ TEST CI/CD PIPELINE
# -------------------------------
echo "🔄 Triggering CI/CD Pipeline..."

git add .

git commit -m "🚀 Auto deployment test $(date +'%Y-%m-%d %H:%M:%S')" || echo "⚠️ Nothing to commit"

git push

if [ $? -ne 0 ]; then
  echo "❌ Git Push Failed"
  exit 1
fi

echo "✅ Pipeline Triggered Successfully"
echo "----------------------------------------"

# -------------------------------
# 6️⃣ ACCESS APPLICATION
# -------------------------------
echo "🌐 Application URL:"
echo "http://$ALB_DNS"

echo "----------------------------------------"
echo "🎉 ALL TASKS COMPLETED SUCCESSFULLY"
```

#### ✅ FINAL SIMPLE SCRIPT

Here is your FINAL CLEAN VERSION (NO hardcore config, auto-fetching values)

This version:

- Gets ECR automatically

- Gets ALB DNS automatically

- Minimal config

[ECR_CI-CD_TEST.sh](../infrastructure/scripts/ECR_CI-CD_TEST.sh)

#### 🧠 Important Notes (Very Important)

#### 🔹 Replace these values:

```
ECR_URI="YOUR_ECR_URI"
ALB_DNS="YOUR-ALB-DNS"
```

Example:

```
ECR_URI="123456789012.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe"
ALB_DNS="charlie-alb-123456.us-east-1.elb.amazonaws.com"
```

#### ▶️ How to Run

```
chmod +x ECR_CI-CD_TEST.sh
./ECR_CI-CD_TEST.sh
```

### 🎯 RESULT (PHASE 2 COMPLETE)

#### You now have:

✅ Dockerized app

✅ ECR storage

✅ ECS deployment

✅ ALB routing

✅ Health checks

✅ GitHub CI/CD

✅ Auto deployment
---
## 🌐 TASK 1 - (MEGA TASK) : Enterprise Zero-Downtime CI/CD Pipeline (ECS + CodeDeploy + Immutable Images)

### 🎯 GOAL

Build a production-grade CI/CD pipeline that:

✅ Uses GitHub Actions

✅ Builds & pushes Docker images to ECR

✅ Uses Git SHA (immutable versioning)

✅ Deploys using CodeDeploy Blue/Green

✅ Ensures ZERO downtime

✅ Allows instant rollback

### 🧠 WHAT YOU WILL LEARN

After this, you will understand:

🔹 Difference between Rolling vs Blue/Green

🔹 How CodeDeploy controls ECS

🔹 Why immutable Docker images matter

🔹 How ALB + Target Groups work in real production

🔹 How to build real DevOps pipelines (not tutorial-level)

### 🏗 FINAL ARCHITECTURE

```
GitHub Push
   ↓
GitHub Actions (CI/CD)
   ↓
Build Docker Image (Git SHA)
   ↓
Push to ECR
   ↓
Update Task Definition
   ↓
CodeDeploy Trigger
   ↓
ECS creates NEW version (Green)
   ↓
ALB routes:
   Blue → Old
   Green → New
   ↓
Health Check
   ↓
Traffic Shift (Blue → Green)
   ↓
OLD version kept for rollback
```

### ⚡ KEY FEATURES (WHAT MAKES THIS ADVANCED)

🔥 Immutable deployments (a84d92f, not latest)

🔥 Zero downtime deployment

🔥 Automatic traffic shifting

🔥 Safe rollback

🔥 No ECS caching issues

🔥 Fully automated pipeline

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

### 🚀 deploy.yml (CLEAN + MERGED + CORRECT)

👉 This replaces your ECS section completely

👉 NO ecs update-service (CodeDeploy will handle)

```
name: ☕ Charlie Cafe — FINAL PRODUCTION PIPELINE

on:
  push:
    branches: ["main"]

jobs:
  deploy:
    runs-on: ubuntu-latest

    env:
      IMAGE_TAG: ${{ github.sha }}

    steps:

    # 1️⃣ Checkout
    - name: 📥 Checkout
      uses: actions/checkout@v3

    # 2️⃣ Short SHA
    - name: 🔤 Short SHA
      run: echo "IMAGE_TAG=${GITHUB_SHA::7}" >> $GITHUB_ENV

    # 3️⃣ AWS Login
    - name: 🔐 Configure AWS
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    # 4️⃣ Login to ECR
    - name: 🐳 Login to ECR
      run: |
        aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | \
        docker login --username AWS --password-stdin \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

    # 5️⃣ Build Image
    - name: 🏗️ Build Docker Image
      run: |
        docker build \
          -t ${{ secrets.ECR_REPO }}:$IMAGE_TAG \
          -f docker/apache-php/Dockerfile .

    # 6️⃣ Tag Image
    - name: 🏷️ Tag Image
      run: |
        docker tag \
          ${{ secrets.ECR_REPO }}:$IMAGE_TAG \
          ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG

    # 7️⃣ Push Image
    - name: 📤 Push Image
      run: |
        docker push \
          ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG

    # 8️⃣ Prepare Task Definition
    - name: 📄 Prepare Task Definition
      run: |
        cp .github/task-definition.json task-def.json

        sed -i "s|IMAGE_PLACEHOLDER|${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG|g" task-def.json

    # 9️⃣ Register Task Definition
    - name: 📦 Register Task Definition
      run: |
        TASK_DEF_ARN=$(aws ecs register-task-definition \
          --cli-input-json file://task-def.json \
          --query 'taskDefinition.taskDefinitionArn' \
          --output text)

        echo "TASK_DEF_ARN=$TASK_DEF_ARN" >> $GITHUB_ENV

    # 🔟 Inject into appspec
    - name: 🔄 Update AppSpec
      run: |
        sed -i "s|TASK_DEFINITION|$TASK_DEF_ARN|g" appspec.yaml

    # 11️⃣ Deploy via CodeDeploy
    - name: 🚀 Blue/Green Deploy
      run: |
        aws deploy create-deployment \
          --application-name charlie-ecs-app \
          --deployment-group-name charlie-ecs-deployment-group \
          --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
          --revision revisionType=AppSpecContent,appSpecContent="{\"content\": \"$(cat appspec.yaml | sed 's/\"/\\\"/g')\"}"

    # 12️⃣ Done
    - name: 🎉 Done
      run: echo "Deployment successful 🚀"
```

A full pipeline replacement is not required. The existing deploy.yml already implements an advanced CI workflow including EC2 deployment via SSM and direct ECS service updates.

The second YAML represents a simplified deployment model using ECR + ECS Blue/Green deployment via AWS CodeDeploy.

The required changes should be treated as additive or optional architectural modifications to the current pipeline.

### ✅ 1. Architectural Decision Point

#### Current implementation includes:

- EC2 deployment via SSM (Steps 9–13)

- ECS deployment via direct update-service (Steps 15–22)

#### The proposed approach introduces:

- AWS CodeDeploy Blue/Green deployment for ECS

- Replacement of direct ECS service updates

### ⚠️ 2. Components That Should NOT Be Duplicated

The following steps already exist and must not be reintroduced:

- ECR authentication (docker login)

- Docker image build, tag, and push

- ECS task definition registration

### 🚀 3. New Components That Can Be Added

### ✅ A. AppSpec Update Step (Required for CodeDeploy)

This step is added after ECS task definition registration:

```
# 🔄 Update AppSpec for CodeDeploy
- name: 🔄 Update AppSpec
  run: |
    sed -i "s|TASK_DEFINITION|$TASK_DEF_ARN|g" appspec.yaml
```

### ✅ B. CodeDeploy Deployment Step (Core Addition)

This step should be added after AppSpec update:

```
# 🚀 Blue/Green Deployment (CodeDeploy)
- name: 🚀 Deploy via CodeDeploy
  run: |
    aws deploy create-deployment \
      --application-name charlie-ecs-app \
      --deployment-group-name charlie-ecs-deployment-group \
      --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
      --revision revisionType=AppSpecContent,appSpecContent="{\"content\": \"$(cat appspec.yaml | sed 's/\"/\\\"/g')\"}"
```

### 🔁 4. Optional Replacement (Architecture Switch)

If migration to CodeDeploy-based ECS deployment is intended:

Replace existing ECS deployment step:

#### Remove:

```
aws ecs update-service ...
```

#### Replace with:

- CodeDeploy deployment step (above)

### 🧹 5. Optional Cleanup

When fully adopting CodeDeploy:

The following steps may be removed:

- ECS update-service deployment step

- ECS service stability check (describe-services) step (optional)

#### Reason:

- CodeDeploy handles deployment orchestration and traffic shifting.

### ⚡ 6. Deployment Architecture Options

### Option A — Hybrid Model (Recommended for learning/transition)

- EC2 deployment via SSM retained

- ECS direct deployment retained

- CodeDeploy Blue/Green added

### Option B — Fully Managed Blue/Green Model

- EC2 SSM deployment removed

- ECS direct deployment removed

- CodeDeploy becomes the single deployment mechanism

### 🧠 Summary

#### Additions:

- AppSpec update step

- CodeDeploy deployment step

#### Optional Removal (if migrating fully):

- ECS update-service deployment step

### ✅ ADD THIS ONLY: 

```
    # -------------------------------------------------
    # 🔄 Update AppSpec for CodeDeploy
    # -------------------------------------------------
    - name: 🔄 Update AppSpec
      run: |
        sed -i "s|TASK_DEFINITION|$TASK_DEF_ARN|g" appspec.yaml

    # -------------------------------------------------
    # 🚀 Blue/Green Deployment (CodeDeploy)
    # -------------------------------------------------
    - name: 🚀 Deploy via CodeDeploy
      run: |
        aws deploy create-deployment \
          --application-name charlie-ecs-app \
          --deployment-group-name charlie-ecs-deployment-group \
          --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
          --revision revisionType=AppSpecContent,appSpecContent="{\"content\": \"$(cat appspec.yaml | sed 's/\"/\\\"/g')\"}"
```

### 🧭 STEP-BY-STEP

### ✅ Prerequisites

- Application Load Balancer (ALB) is configured

- Two target groups created:

  - charlie-blue

  - charlie-green

- Health check endpoint configured: /health.php

- ALB Listener (HTTP:80) is set to forward traffic to charlie-blue

> #### 👉 “ALB with blue/green target groups is already configured, with traffic currently routed to charlie-blue and health checks on /health.php.”

 👉 If not; 

#### 1️⃣ — ALB Setup

- Create 2 target groups:

- charlie-blue

- charlie-green

- Health check: /health.php

#### 2️⃣ — ALB Listener

- Go to ALB → Listener → HTTP:80

- Set:Forward → charlie-blue

### 1️⃣ — ECS SERVICE (CRITICAL)

- Go to ECS → Service

- Click Update

- Change:

  ❌ Rolling update

  ✅ Blue/Green (CodeDeploy)

### 2️⃣ — CREATE CODEDEPLOY APP

- Name: charlie-ecs-app

- Platform: ECS

### 3️⃣ — CREATE DEPLOYMENT GROUP

- Name: charlie-ecs-deployment-group

- Cluster: charlie-cluster

- Service: charlie-service

- Attach:

  - ALB

  - Blue TG

  - Green TG

  - Listener: HTTP:80

### 4️⃣ — IAM ROLE (ALready Done)

- Existing role:

```
charlie-cafe-iam-Role
```

- Attach policy:

```
AWSCodeDeployRoleForECS
```
> #### ### ⚠️ The required IAM policy has already been added to the existing custom IAM policy

#### ✅ Required IAM Policy (Add This to Your Existing Role)

Add this JSON block into your merged policy:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### ⚠️ Important Notes (Don’t Skip)

#### 1. iam:PassRole is CRITICAL

- Without this:

  ❌ CodeDeploy cannot switch traffic between blue/green

#### 2. Principle of Least Privilege (Advanced)

Later (production), you should restrict:

- ECS resources

- Target groups

- Specific roles

But for your lab / DevOps project, * is fine ✅

#### 3. Trust Relationship (VERY IMPORTANT)

Make sure your IAM role trust policy allows:

```
{
  "Effect": "Allow",
  "Principal": {
    "Service": "codedeploy.amazonaws.com"
  },
  "Action": "sts:AssumeRole"
}
```

👉 Without this:

❌ CodeDeploy cannot assume your role

### 5️⃣ — ECS TASK EXECUTION ROLE

- Use:

```
ecsTaskExecutionRole
```

- Put ARN in:

```
task-definition.json
```

### 6️⃣ — GITHUB SECRETS

- Add:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
AWS_ACCOUNT_ID
ECR_REPO
ECS_CLUSTER
ECS_SERVICE
```

### 7️⃣ — PUSH CODE

```
git add .
git commit -m "final pipeline"
git push origin main
```

### 🔥 WHAT HAPPENS AFTER PUSH

- Docker image built → a84d92f

- Image pushed to ECR

- New task definition created

- CodeDeploy starts deployment

- ECS launches GREEN version

- Health checks run

- Traffic shifts: BLUE → GREEN
 
### Old version kept

### 🚨 CRITICAL RULES (DON’T BREAK THESE)

❌ NEVER use: aws ecs update-service

✅ ALWAYS use: CodeDeploy

### 🎯 FINAL RESULT (YOU REACH THIS LEVEL)

You now have:

✅ Enterprise CI/CD

✅ Zero downtime deployments

✅ Immutable versioning

✅ Safe rollback system

✅ Real DevOps architecture

### 💬 My honest advice (important for YOU)

You tried to combine everything at once — that’s why confusion happened.

Now:

👉 Follow THIS exact order

👉 Don’t mix old ECS rolling config

👉 Don’t use latest anymore

---
## 🌐 TASK 2 — CANARY + AUTO ROLLBACK + MONITORING

### ✅ Enable Canary Deployment

#### Use:

```
CodeDeployDefault.ECSCanary10Percent5Minutes
```

### ✅ Enable Auto Rollback

#### Enable:

Deployment failure

Alarm triggered

### ✅ Create CloudWatch Alarm

Metric: UnHealthyHostCount

Target group: charlie-green

Threshold: >= 1

### ✅ Attach Alarm to CodeDeploy

Add alarm: charlie-health-alarm

### 🧪 FINAL FLOW

```
Push Code →
Build →
Push ECR →
Deploy →
10% Traffic →
Health Check →
✅ Success → 100%
❌ Failure → Auto Rollback
```

### 🧠 FINAL UNDERSTANDING

#### You now built a real production-grade DevOps system:

✅ CI/CD automation

✅ Containerized deployment

✅ Load balancing

✅ Zero downtime deployment

✅ Canary releases

✅ Auto rollback

✅ Monitoring

### 🚨 COMMON MISTAKES (FIXED)

❌ Using Instance target type → Use IP

❌ Using old EC2 target group → Ignore it

❌ Missing /health.php → Required

❌ Duplicate ALB configs → Now removed


## ✅ Charlie Cafe cleanup

[ec2-cleanup.sh](../infrastructure/scripts/ec2-cleanup.sh)

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

---