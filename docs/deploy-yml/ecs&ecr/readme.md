# Charlie Cafe - deploy.yml

### Step 1: Understand what you did

- You updated deploy.yml on GitHub web.

- GitHub now has the latest workflow.

- You don’t need to push it from EC2 unless you also changed local files.

#### ✅ Key point: GitHub Actions triggers from GitHub itself, not from your EC2. So the workflow runs automatically when you push to main.

### Step 2: Check for local changes on EC2

#### You ran:

```
git status
```

It shows:

```
Changes not staged for commit:
  modified: app/frontend/js/config.js
  modified: infrastructure/scripts/connect-rds.sh
Untracked files:
  app/frontend/html/charlie-cafe-link-generator.html
```

And then git pull --rebase failed because you have unstaged local changes.

### Step 2a: Decide what to do with local changes

- If you don’t need local changes, discard them:

```
git restore .
```

- If you want to keep local changes, stash them:

```
git stash
```

After either, you can pull updates safely.

### Step 3: Pull latest changes from GitHub

```
git pull origin main
```

- This will update your local EC2 repo with the latest deploy.yml and all other files from GitHub.

- After pulling, you can check:

```
git log -1
```

- You should see the latest commit you made on GitHub web.

### Step 4: Verify GitHub Actions workflow is triggered

- Go to GitHub → Your repository → Actions

- Check if a new workflow run for deploy.yml has started after you pushed the update.

- You should see the job build-test-deploy running.

#### ✅ If you see running / queued jobs, your workflow is recognized by GitHub.

### Step 5: Monitor workflow logs step by step

- Click on the workflow run → Jobs → build-test-deploy → Steps

- Check each step:

    - Checkout ✅

    - Configure AWS credentials ✅

    - Install tools ✅

    - RDS secret ✅

    - Docker build ✅

    - Push to ECR ✅

    - ECS update ✅

- If any step fails, GitHub Actions shows error logs.

> This is the real verification that your deploy.yml works — you don’t run it manually on EC2.

### Step 6: Optional — Test ECS & ECR manually (if needed)

If you want to double-check ECS task can pull the image, do this from EC2:

```
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 537236558357.dkr.ecr.us-east-1.amazonaws.com

# Pull the latest image manually
docker pull 537236558357.dkr.ecr.us-east-1.amazonaws.com/charlie-cafe:latest
```

✅ If the pull works, ECS will also pull successfully.

❌ If it fails → networking issue (NAT / VPC endpoint).


### Step 7: Verify ECS service after workflow runs

- Go to ECS → Clusters → charlie-cluster → Services → charlie-service

- Check Tasks: Status should be Running

- Go to Target Groups → charlie-blue → Targets

- Status: Healthy

- Should see private IPs of tasks

- Open ALB DNS in browser:

- You should see your web app

### Step 8: If you want to check logs from ECS tasks

```
aws logs describe-log-groups
aws logs describe-log-streams --log-group-name /ecs/charlie-cluster
aws logs get-log-events --log-group-name /ecs/charlie-cluster --log-stream-name <stream-name>
```

- This helps debug if ECS tasks fail to start.

### Step 9: Next push workflow

After you’ve verified the workflow works:

- Make local changes on EC2 or GitHub

- Commit & push to main

- Workflow triggers automatically → updates ECS & ECR

#### ✅ You never manually run deploy.yml on EC2. GitHub Actions does it. EC2 is just the target for SSM or ECS tasks.

### ✅ Summary of what to do now

- Decide what to do with local changes:

```
git restore .   # discard
# or
git stash       # save for later
```

- Pull latest from GitHub:

```
git pull origin main
```


- Go to GitHub Actions → Actions tab → watch deploy.yml run

- Monitor logs for build → push → ECS update

- Check ECS service → Tasks → Running

- Verify ALB → web app is working

---
### Step 1: Fix GitHub Secrets

- Go to your repo → Settings → Secrets and Variables → Actions → Repository secrets

- Check if you have:

| Secret Name           | Value Example                |
| --------------------- | ---------------------------- |
| AWS_ACCESS_KEY_ID     | `AKIA...`                    |
| AWS_SECRET_ACCESS_KEY | `xxxx`                       |
| AWS_REGION            | `us-east-1` (or your region) |
| RDS_SECRET_ARN        | `arn:aws:secretsmanager:...` |
| AWS_ACCOUNT_ID        | `123456789012`               |
| ECR_REPO              | `charlie-cafe`               |
| ECS_CLUSTER           | `charlie`                    |
| ECS_SERVICE           | `charlie-service`            |
| EC2_INSTANCE_ID       | `i-0123456789abcdef0`        |

> If AWS_REGION is missing, add it exactly as your AWS region string (e.g., us-east-1).

### Step 2: Trigger Workflow Again

- After fixing secrets, go to Actions tab → click Run workflow → main branch

- The workflow should start and proceed past Step 2.

### Step 3: Verify Step-by-Step

Step 2 ✅ Configure AWS credentials

Step 3 ✅ Install tools

Step 4 ✅ Retrieve RDS secret

Step 5 ✅ Parse DB credentials

Step 6 ⏳ Wait for RDS

Step 11 🐳 Build Docker image

Step 20 🐳 Login to ECR

Step 24 🚀 Update ECS service

- Watch any step that fails.

- If Step 24 ECS deployment fails, check ECS logs for task errors.

### Step 4: Optional EC2 Pull

You don’t need to pull deploy.yml to EC2 — GitHub Actions runs independently.

- The only thing EC2 sees is the SSM command in Step 15 (deploy_via_ssm.sh)

---


