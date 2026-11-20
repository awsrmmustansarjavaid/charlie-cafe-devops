# Charlie Cafe — AWS CodeDeploy Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for AWS CodeDeploy.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

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


### 2️⃣ — CREATE DEPLOYMENT GROUP

👉 Now inside that app: Click Create deployment group

- Name: charlie-ecs-deployment-group

- Service role: 👉 Select your role: charlie-codedeploy-role

- Deployment type: Blue/Green


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


### 4️⃣ — Attach Alarm to CodeDeploy

In deployment group:

- Attach: charlie-health-alarm


### 🧭 STEP-BY-STEP UPGRADE


### 1️⃣ — UPDATE CODEDEPLOY (MOST IMPORTANT)

- Go to: 👉 AWS CodeDeploy → Deployment Group


#### 🔧 CHANGE THIS:

- ❌ Old config: CodeDeployDefault.ECSAllAtOnce

- ✅ NEW CONFIG (CANARY): CodeDeployDefault.ECSCanary10Percent5Minutes


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


### 4️⃣ — ATTACH ALARM TO CODEDEPLOY

- Go to: 👉 CodeDeploy Deployment Group

- Add: charlie-green-unhealthy-alarm


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

