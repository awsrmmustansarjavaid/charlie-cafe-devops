# Charlie Cafe — Amazon ECS Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon ECS.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

## 4️⃣ NAT Gateway (OPTIONAL INTERNET ACCESS FOR ECS)


### 1️⃣ NAT Gateway Architecture

| Component        | Purpose                                        |
| ---------------- | ---------------------------------------------- |
| NAT Gateway      | Provides internet access for private ECS tasks |
| Internet Gateway | Public subnet outbound connectivity            |
| Private Subnet   | ECS tasks run here (no public IP)              |
| Route Table      | Routes internet traffic via NAT Gateway        |


### 2️⃣ NAT Gateway Setup

| Parameter       | Value                |
| --------------- | -------------------- |
| Name            | `ecs-nat-gateway`    |
| Placement       | Public Subnet        |
| Elastic IP      | Required             |
| Internet Access | Via Internet Gateway |


### 4️⃣ ECS Task Networking

| Setting         | Value                      |
| --------------- | -------------------------- |
| Subnet Type     | Private Subnet             |
| Public IP       | ❌ Disabled                 |
| Outbound Access | Via NAT Gateway            |
| Security Group  | Allow HTTPS (443) outbound |


### 💡 NAT Gateway Benefits vs Limitations

| Pros                      | Cons                                 |
| ------------------------- | ------------------------------------ |
| Easy setup                | High cost (hourly + data transfer)   |
| Works immediately         | Not fully private architecture       |
| No VPC endpoints required | Not recommended for production scale |


### 🔄 Use Case Flow (NAT Based ECS)

```
ECS Task (Private Subnet)
   ↓
Route Table
   ↓
NAT Gateway (Public Subnet)
   ↓
Internet Gateway
   ↓
ECR / AWS Services
```


### 🧠  DevOps Recommendation

- Use NAT Gateway only for quick setup/testing

- Use VPC Endpoints for production (best practice)

- Prefer private architecture (no internet dependency)

- Combine with ECR + ECS endpoints for full security


### 🚀 Final ECS Internet Access Flow

```
ECS Task (Private Subnet)
   ↓
Route Table (0.0.0.0/0)
   ↓
NAT Gateway
   ↓
Internet Gateway
   ↓
ECR / AWS Services / Internet
```
---

## 1️⃣1️⃣ ☁️ AWS DEVOPS UPGRADE -- ECS & ECR

Read more about [Charlie Cafe - AWS DEVOPS ECS & ECR Configurations](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/AWS%20Services%20Configurations%20/Charlie-cafe_AWS-DEVOPS_ECS_ECR-Configurations.md)


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


### 🌐 Create Create Task Definition with JSON

- Go to ECS → Task Definitions → Create new Task Definition.

- Select create task with JSON

- #### ✅ charlie-task JSON [charlie-task.json](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/AWS%20Services%20Configurations%20/charlie-task%20JSON/charlie-task.json)

- ### 6️⃣  Network Connectivity

> #### NAT GW / VPC ENDPoint

Read more [“Click here for configuration.”](./charlie-cafe-devops-Network%20Connectivity.md)


#### 🔹 VPC Endpoints (Private Access)

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

- ### 7️⃣ ALB + ECS SERVICE

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


#### 2️⃣ Update ALB Listener

- Go to: EC2 → Load Balancer → Listeners

- Edit HTTP:80


#### 👉 Set default:

- Default action: Forward → charlie-blue


#### 3️⃣ Create ECS Service

- Go ECS → Cluster → charlie-cluster → Create Service

- #### Compute options

   - Launch type: Fargate

- #### Task Definition  

  - Task definition: charlie-task

  - Revision: latest

- #### Service name  

  - Service name: charlie-service
  
  - Desired tasks (Number of tasks): 1 (start small)

- #### NETWORKING

- 👉 VPC : 
  
  - Select your default VPC (or custom if you made one)

- 👉 Subnets 

> ✅ Choose ONLY:

- ✔ Public Subnets (important)


#### Example:

- subnet-xxxx (public-subnet-1)

- subnet-xxxx (public-subnet-2)


#### ❌ DO NOT choose:

- Private subnets (for now)

- Isolated subnets

- 👉 Auto-assign Public IP

- 👉 MUST SET: ENABLE

✔ This is what allows internet access

- 🔐 Security Group: Create or select default-SG:

| Type | Port | Source    |
| ---- | ---- | --------- |
| HTTP | 80   | 0.0.0.0/0 |

- #### LOAD BALANCER (OPTIONAL but recommended)

- Load Balancer: Application Load Balancer

  > Use existing ALB

- Listener: HTTP:80

- Target group: charlie-blue

- Container Mapping: charlie-container port 80

  - Container: charlie-container

  - Port: 80

✅ Click Create Service → Wait for tasks to become Running

🕓 Wait 2–5 minutes

- ### 8️⃣  Run Task in Cluster

- Go to ECS → Clusters → charlie-cluster → Tasks → Run new Task.

- Launch Type: Fargate.

- Task Definition: charlie-task:1 (latest revision).

- Cluster VPC & Subnets: select defaults or your preferred VPC.

- Security group: allow TCP 80 (HTTP) from 0.0.0.0/0 if public access needed.

- Click Run Task.

✅ Your container should start. Check Logs → CloudWatch → /ecs/charlie-task to verify the app is running.


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


