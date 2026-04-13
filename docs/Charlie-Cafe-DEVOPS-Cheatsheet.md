# ☕ Charlie Cafe — DevOps Command Cheat Sheet

## 📦 1. GIT / GITHUB COMMANDS

### 🔹 Clone Repository

```
git clone https://github.com/<username>/<repo>.git
```

👉 Purpose: Download project from GitHub

### 🔹 Check Status

```
git status
```

👉 Purpose: See modified/untracked files

### 🔹 Add Files

```
git add .
```

👉 Purpose: Stage all changes

### 🔹 Commit Changes

```
git commit -m "your message"
```

👉 Purpose: Save changes locally

### 🔹 Push to GitHub

```
git push origin main
```

👉 Purpose: Upload code to GitHub

### 🔹 Pull Latest Code

```
git pull origin main
```

👉 Purpose: Get latest updates from GitHub

### 🔹 Reset Local Code (DANGER)

```
git reset --hard origin/main
```

👉 Purpose: Force sync with GitHub (deletes local changes)

### 🔹 View Logs

```
git log --oneline
```

👉 Purpose: Show commit history

---
## 🐳 2. DOCKER COMMANDS

### 🔹 Build Docker Image

```
docker build -t charlie-cafe -f docker/apache-php/Dockerfile .
```

👉 Purpose: Create Docker image from Dockerfile

### 🔹 Build Without Cache

```
docker build --no-cache -t charlie-cafe -f docker/apache-php/Dockerfile .
```

👉 Purpose: Force rebuild everything

### 🔹 List Images

```
docker images
```

👉 Purpose: Show available images

### 🔹 Run Container

```
docker run -d -p 80:80 --name cafe-app charlie-cafe
```

👉 Purpose: Start app container

### 🔹 List Running Containers

```
docker ps
```

👉 Purpose: Show active containers

### 🔹 Enter Container

```
docker exec -it cafe-app bash
```

👉 Purpose: Access container shell

### 🔹 View Logs

```
docker logs cafe-app
```

👉 Purpose: Debug container issues

### 🔹 Stop Container

```
docker stop cafe-app
```

### 🔹 Remove Container

```
docker rm cafe-app
```

### 🔹 Remove Image

```
docker rmi charlie-cafe
```

---
## 📦 3. AMAZON ECR COMMANDS

### 🔹 Login to ECR

```
aws ecr get-login-password --region us-east-1 \
| docker login --username AWS --password-stdin <account_id>.dkr.ecr.us-east-1.amazonaws.com
```

👉 Purpose: Authenticate Docker with AWS ECR

### 🔹 Tag Image

```
docker tag charlie-cafe:latest <account_id>.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
```

### 🔹 Push Image

```
docker push <account_id>.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
```

👉 Purpose: Upload image to AWS registry

### 🔹 List ECR Images

```
aws ecr list-images --repository-name charlie-cafe
```

---
## 🚀 4. AWS ECS COMMANDS

### 🔹 Update Service (Deploy New Version)

```
aws ecs update-service \
  --cluster charlie-cluster \
  --service charlie-service \
  --force-new-deployment
```

👉 Purpose: Restart tasks with latest image

### 🔹 Update with Task Definition

```
aws ecs update-service \
  --cluster charlie-cluster \
  --service charlie-service \
  --task-definition charlie-task:8 \
  --force-new-deployment
```

### 🔹 Describe Service

```
aws ecs describe-services \
  --cluster charlie-cluster \
  --service charlie-service
```

👉 Purpose: Check running status

### 🔹 List Tasks

```
aws ecs list-tasks --cluster charlie-cluster
```

### 🔹 Describe Tasks

```
aws ecs describe-tasks \
  --cluster charlie-cluster \
  --tasks <task_id>
```

### 🔹 Register Task Definition

```
aws ecs register-task-definition \
  --cli-input-json file://task-definition.json
```

### 🔹 View Task Definition Image

```
aws ecs describe-task-definition \
  --task-definition charlie-task:8
```

---
## 🔐 5. AWS SECRETS MANAGER

### 🔹 Get Secret Value

```
aws secretsmanager get-secret-value \
  --secret-id CafeDevDBSM
```

### 🔹 Debug Secret Output

```
aws secretsmanager get-secret-value \
  --secret-id CafeDevDBSM \
  --query SecretString --output text
```

---
## 🧪 6. EC2 / SERVER COMMANDS

### 🔹 Check Docker Containers

```
docker ps
```

### 🔹 Inspect Container

```
docker exec -it cafe-app bash
```

### 🔹 Find Files

```
find /var/www -name "health.php"
```

### 🔹 Search inside files

```
grep -R "cafe_db" /var/www/html
```

### 🔹 Restart Docker Container

```
docker restart cafe-app
```

---
## 🔄 7. FULL CI/CD FLOW (IMPORTANT)

### 🚀 Step 1: Pull Latest Code

```
git pull origin main
```

### 🐳 Step 2: Build Docker Image

```
docker build -t charlie-cafe -f docker/apache-php/Dockerfile .
```

### 📦 Step 3: Tag Image

```
docker tag charlie-cafe:latest <ECR_URL>:latest
```

### ⬆️ Step 4: Push to ECR

```
docker push <ECR_URL>:latest
```

### 🚀 Step 5: Deploy to ECS

```
aws ecs update-service \
  --cluster charlie-cluster \
  --service charlie-service \
  --force-new-deployment
```

---
## 🔥 8. DEBUGGING COMMANDS (VERY IMPORTANT)

### 🔹 Check logs

```
docker logs cafe-app
```

### 🔹 Enter running container

```
docker exec -it cafe-app bash
```

### 🔹 Verify file inside container

```
cat /var/www/html/php/health.php
```

### 🔹 Check running ECS tasks

```
aws ecs describe-services \
  --cluster charlie-cluster \
  --service charlie-service
```
---
### 🎯 END RESULT FLOW

```
GitHub → EC2 → Docker Build → ECR → ECS → ALB → User
```

---













