# Charlie Cafe - GitHub → Auto-Deploy Setup Configurations 

## GitHub → Auto-Deploy Setup (Charlie Cafe)

- Read more here [GitHub Actions auto-deploy-EC2](./Readme/GitHub%20Actions%20auto-deploy.md)

- ### ✅ Method 1️⃣  Add GitHub Secrets for AWS Access Key (Recommanded)

#### 1️⃣ Add Keys to GitHub Secrets

- Go to your repo: 👉 Settings → Secrets → Actions → New repository secret

- #### Add: 

| Secret Name             | Value                              |
| ----------------------- | ---------------------------------- |
| `AWS_ACCESS_KEY_ID`     | (your IAM user access key ID)      |
| `AWS_SECRET_ACCESS_KEY` | (your IAM user secret access key)  |
| `AWS_REGION`            | `us-east-1` (or your region)       |
| `EC2_INSTANCE_ID`       | `i-0123456789abcdef0` (target EC2) |
| `EC2_USER`              | `ec2-user` (default username)      |

✅ Example: AWS_REGION = us-east-1

> 💡 Tip: Instead of hardcoding EC2 IP, use EC2 instance ID + AWS SSM to target instance — no SSH needed.

### 4️⃣ SSM Agent

#### ✅ 1. SSM Agent installed 

```
sudo systemctl status amazon-ssm-agent
```

If NOT running:

```
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
```

#### ✅ 2. Verify SSM Connectivity

- Go to: 👉 AWS Console → Systems Manager → Managed Instances

✅ You MUST see:

- Your EC2 instance listed

- Status: Online

### 5️⃣ Git Auto Deploy

```
nano deploy_via_ssm.sh
```

[deploy_via_ssm.sh](./../../../infrastructure/scripts/deploy_via_ssm.sh)

```
chmod +x deploy_via_ssm.sh
./deploy_via_ssm.sh
```

### 6️⃣ Verification Test 

```
nano charlie_cafe_full_check.sh
```

[charlie_cafe_full_check.sh](../infrastructure/scripts/charlie_cafe_full_check.sh)

```
chmod +x charlie_cafe_full_check.sh
./charlie_cafe_full_check.sh
```

- ### ✅ Method 2️⃣  Add GitHub Secrets for EC2 using SSH

> #### Auto-deploy from GitHub → EC2 using SSH 

### 1️⃣ Prepare EC2 for SSH Deployment

### ✅ Check if keys already exist

Run this on your EC2:

```
ls -la ~/.ssh
```

#### 🔍 What you should see:

- id_deploy → ✅ private key

- id_deploy.pub → ✅ public key

- If both exist → you’re good

- If not → you need to generate them (I’ll show below)

### ✅ Check permissions (VERY IMPORTANT)

```
ls -l ~/.ssh
```

#### Fix permissions if needed:

```
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_deploy
chmod 644 ~/.ssh/id_deploy.pub
```

#### Generate an SSH key on your EC2 instance (if you don’t already have one):

```
ssh-keygen -t ed25519 -C "ec2-auto-deploy" -f ~/.ssh/id_deploy -N ""
```

- This creates ~/.ssh/id_deploy (private) and ~/.ssh/id_deploy.pub (public).

#### Then verify again:

```
ls ~/.ssh
```

#### 🔑 Copy the public key:

```
cat ~/.ssh/id_deploy.pub
```

#### Output looks like:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... ec2-auto-deploy
```

You will add this to GitHub as a deploy key.

### 2️⃣ Add EC2 SSH Key to GitHub

- Go to your GitHub repo → Settings → Deploy keys → Add deploy key.

- Paste the public key from EC2.

- Check Allow write access (so it can pull/push if needed).

- Click Add key.

✅ Now your EC2 can authenticate with GitHub without a token.

### 3️⃣ Add EC2 Details as GitHub Secrets

#### 🔑 Copy the private key

> ⚠️ Important: Never share this key publicly. Keep it secret.

```
cat ~/.ssh/id_deploy
```

#### ✅ Verify UserName

```
whoami
```

- Go to your GitHub repo → Settings → Secrets → Actions → New repository secret:

| Secret Name   | Value                                      |
| ------------- | ------------------------------------------ |
| `EC2_SSH_KEY` | Paste **private key** (`~/.ssh/id_deploy`) |
| `EC2_USER`    | `ec2-user`                                 |
| `EC2_HOST`    | Your EC2 public IP or DNS                  |

> These secrets will be used by GitHub Actions to SSH into EC2 securely.

### 4️⃣ Keep Your Bash Script on EC2

- Upload your charlie-cafe-devops.sh to EC2 (e.g., ~/charlie-cafe-devops/charlie-cafe-devops.sh).

- Ensure it’s executable:

```
chmod +x ~/charlie-cafe-devops/charlie-cafe-devops.sh
```

✅ This avoids duplicating Docker, DB, git commands in GitHub Actions.

### 5️⃣ Now test:

```
ssh -T git@github.com
```

#### ✅ You should get:

```
Hi awsrmmustansarjavaid! You've successfully authenticated, but GitHub does not provide shell access.
```

✅ Perfect — SSH is working.

#### ✅ Fix host key verification

#### ✅ When you see:

```
The authenticity of host 'github.com (140.82.114.3)' can't be established.
```

- #### ✅ Add GitHub to known hosts:

> #### GitHub is asking if it can trust the server. To fix permanently:

```
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

- This adds GitHub’s public host key to your EC2 so it won’t ask again.

#### ✅ Now test:

```
ssh -T git@github.com
```

#### ✅ Step 1 Create SSH config for GitHub

```
nano ~/.ssh/config
```

#### Paste exactly:

```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_deploy
  IdentitiesOnly yes
```

Save and exit (CTRL+O, ENTER, CTRL+X)

> This tells SSH to always use id_deploy when connecting to GitHub.

#### ✅ Step 2  Start the SSH agent and add the key

```
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_deploy
```
-  You should see something like: Identity added: /home/ec2-user/.ssh/id_deploy (ec2-auto-deploy)

#### ✅ Step 3  Test connection to GitHub

Hardcode the identity file in SSH command in the script

If you want the script to always work with sudo:

Replace:

```
ssh -T git@github.com
```

With:

```
ssh -i /home/ec2-user/.ssh/id_deploy -o IdentitiesOnly=yes -T git@github.com
```

#### ✅ Expected output:

```
Hi <your-github-username>! You've successfully authenticated, but GitHub does not provide shell access.
```

#### If you still get Permission denied, it usually means:

- Public key not correctly added to GitHub

- Wrong repository (deploy keys are repo-specific)

- SSH config not applied

### 6️⃣ Git Auto Deploy

```
nano ec2_git_auto_deploy.sh
```

[ec2_git_auto_deploy.sh](../infrastructure/scripts/ec2_git_auto_deploy.sh)

```
chmod +x ec2_git_auto_deploy.sh
./ec2_git_auto_deploy.sh
```

- Go to GitHub → Actions → Check the workflow logs.

- #### On EC2, verify Docker:

```
sudo docker ps
```

- You should see your container cafe-app running.

- Open your EC2 public IP in the browser — your app should be live.

### 🚀 ✅ COMPLETE VERIFICATION SCRIPT

Save this as:

```
nano verify-devops-env.sh
```

[verify-devops-env.sh](../infrastructure/scripts/verify-devops-env.sh)

```
chmod +x verify-devops-env.sh
./verify-devops-env.sh
```

### 🌐 Now test in browser:

```
http://YOUR-EC2-PUBLIC-IP
```

### 🚀 After Any Change on EC2

- #### 1️⃣ Go to your project directory

```
cd ~/charlie-cafe-devops
```

- #### 2️⃣ Fix file ownership (if you ever used sudo accidentally)

```
sudo chown -R ec2-user:ec2-user ~/charlie-cafe-devops
```

This ensures Git can write files.

- #### 3️⃣ Pull latest remote changes

Before committing your changes, make sure your branch is up-to-date:

```
git pull --rebase origin main
```

> If you prefer merge instead of rebase:

```
git pull origin main
```

This resolves divergent branches safely.

- ####  4️⃣ Make your changes

Edit files, add new ones, etc.

- #### 5️⃣ Stage changes

```
git add .
```

- #### 6️⃣ Commit changes

```
git commit -m "Describe your change here"
```

- #### 7️⃣ Push to GitHub

```
git push origin main
```

- 8️⃣ Verify push

```
git status
git log -1
```

- git status should show nothing to commit, working tree clean.

- git log -1 shows your last commit pushed.

### ⚠️ Important Notes

- Never run Git commands with sudo inside ~/charlie-cafe-devops.

- Always make sure your branch is synced (git pull --rebase) before pushing.

- If you see "Permission denied" errors, check your SSH deploy key and ssh-agent:

```
ssh-add -l        # lists loaded keys
ssh -T git@github.com
```

---
## 🚀 Task: How to Trigger GitHub Actions CI/CD Pipeline (deploy.yml) from GitHub Web UI and EC2 (Manual + Automated Ways)

What you are asking is called in DevOps:

“Pipeline Triggering Methods” or “CI/CD Pipeline Execution Strategies”

Your deploy.yml already runs on:

```
on:
  push:
    branches: ["main"]
```

So it is event-driven (automatic trigger) by default.

Now let’s cover ALL ways to run it properly.

### ✅ METHOD 1 — Run from GitHub Web (Manual Trigger)

#### ✔ Step 1: Go to GitHub Repository

- Open: Your repo → charlie-cafe-devops

#### ✔ Step 2: Open Actions Tab

- Click: Actions → ☕ Charlie Cafe — FULL CI/CD PIPELINE

#### ✔ Step 3: Select Workflow

- Choose your workflow: FULL CI/CD PIPELINE (FINAL)

#### ✔ Step 4: Click “Run workflow”

- You will see:

```
Run workflow ▼
Branch: main
```

#### ✔ Step 5: Click Green Button

- 👉 Click: Run workflow

#### 🎯 Result GitHub will:

- Start pipeline instantly

- Run deploy.yml steps

- Deploy EC2 + ECS automatically

### ✅ METHOD 2 — Automatic Trigger (What you already have)

#### How it works:

Whenever you do:

```
git add .
git commit -m "update"
git push origin main
```

👉 GitHub automatically triggers:

```
deploy.yml
```

#### 🎯 This is called:

- Git-based CI/CD trigger (Git push trigger)

### ✅ METHOD 3 — Trigger from EC2 (NOT DIRECT, BUT POSSIBLE)

#### ⚠️ Important truth:

- EC2 cannot directly run GitHub Actions workflow.

- But you CAN trigger it indirectly.

### ✔ OPTION A — Git push from EC2 (MOST COMMON)

#### Step 1: SSH into EC2

```
ssh ec2-user@your-ec2-ip
```

#### Step 2: Go to project folder

```
cd charlie-cafe-devops
```

#### Step 3: Make a small change OR pull latest

```
git pull origin main
```

#### Step 4: Push from EC2

If repo is connected:

```
git add .
git commit -m "trigger pipeline from EC2"
git push origin main
```

### 🎯 Result:

- This triggers GitHub Actions automatically.

### ✔ OPTION B — GitHub API Trigger (ADVANCED)

You can manually trigger workflow using API:

```
curl -X POST \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/OWNER/REPO/actions/workflows/deploy.yml/dispatches \
  -d '{"ref":"main"}'
```

### 🎯 This is called:

> Workflow Dispatch API Trigger

### ✅ METHOD 4 — Add Manual Button in YAML (BEST PRACTICE)

If you want a button inside GitHub Actions:

Modify your deploy.yml:

```
on:
  push:
    branches: ["main"]

  workflow_dispatch:
```


### 🎯 Now you get:

✔ Run on push

✔ Run manually from GitHub UI

✔ Best DevOps practice

### 🚀 FINAL SUMMARY (VERY IMPORTANT)

| Method       | Where        | Name                     |
| ------------ | ------------ | ------------------------ |
| Push code    | GitHub       | Git Push Trigger         |
| GitHub UI    | Actions tab  | Manual Workflow Dispatch |
| EC2 git push | EC2 terminal | Indirect Trigger         |
| API call     | curl/Postman | Workflow Dispatch API    |

### ⚡ SIMPLE DEVOPS EXPLANATION

👉 Your pipeline is NOT something you “run like a script”

It is:

> Event-driven automation pipeline

#### Meaning:

- Git push → runs automatically

- GitHub button → manual run

- API → remote trigger

- EC2 → indirectly triggers via git or API

---

