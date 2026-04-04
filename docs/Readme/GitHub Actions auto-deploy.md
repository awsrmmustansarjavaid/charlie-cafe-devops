# Charlie Cafe - Auto-deploy from GitHub → EC2

### 🔑 Method 1 Auto-deploy from GitHub → EC2 using SSH (Recommanded)

> #### GitHub → GitHub Actions → EC2 → Docker → Auto Deploy

### 🌐 Make sure SSH key exists on EC2

Check if you already have an SSH key:

```
ls -al ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
```

#### ✅ If not, generate it:

### 1️⃣  Generate SSH Key on EC2 

- #### Generate a new SSH key (no passphrase):

```
ssh-keygen -t rsa -b 4096 -C "github-actions"
```

> Press Enter to accept default locations and leave passphrase empty.

- Press Enter for all prompts.

- Copy the public key:

```
cat ~/.ssh/id_rsa.pub
```

- You will get a line like:

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD...
```

This will be added to GitHub.

### 2️⃣ Add Public Key to GitHub (for SSH)

- Go to your GitHub repository → Settings → Deploy keys → Add deploy key

- Give it a Title, e.g., EC2 Auto Deploy

- Paste your EC2 public key:

```
cat ~/.ssh/id_rsa.pub
```

- Check Allow write access (so GitHub Actions can pull/push).

- Click Add SSH key ✅

- #### ✅ This allows GitHub to authenticate your EC2.

- #### Note: There is no separate "Allow write access" checkbox here. That’s only for repo-level Deploy Keys. Using your personal account SSH key allows read/write.

### 3️⃣ Now test:

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

```
ssh -T git@github.com
```

#### ✅ Expected output:

```
Hi <your-github-username>! You've successfully authenticated, but GitHub does not provide shell access.
```

#### If you still get Permission denied, it usually means:

- Public key not correctly added to GitHub

- Wrong repository (deploy keys are repo-specific)

- SSH config not applied

#### ✅ Step 4 Use the correct repository URL

Since deploy keys are repo-specific, your clone command must match the repo where the key is added:

```
git clone git@github.com:<YOUR-USERNAME>/<YOUR-REPO>.git
```

- <YOUR-USERNAME> → GitHub username or organization that owns the repo

- <YOUR-REPO> → exact repo name

If you added the key to repo charlie-cafe-devops, the command should be:

```
git clone git@github.com:YOUR-USERNAME/charlie-cafe-devops.git
```

#### ✅ Step 5 Verify permissions on the repo

- Deploy keys by default are read-only

- If you need git push from EC2 → check “Allow write access” when adding the key

#### ⚡ Quick Checklist

- ~/.ssh/id_deploy exists and has correct permissions → ✅

- ~/.ssh/config points to id_deploy → ✅

- SSH agent has key added → ✅

- Public key added to exact repo as deploy key → ✅

- Clone uses correct SSH URL → ✅

### 4️⃣ Add private key as GitHub secret

#### 🔑 Step 1 Check if you already have a private key

- Run:

```
ls -al ~/.ssh/
```

#### ✅ You should see something like:

```
id_rsa
id_rsa.pub
```

- id_rsa → private key ✅

- id_rsa.pub → public key (this is what you added to GitHub)

#### 🔑 Step 2 View your private key

> ⚠️ Important: Never share this key publicly. Keep it secret.

- Run:

```
cat ~/.ssh/id_rsa
```

#### ✅ You should see something like:

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAA...
...rest of key...
-----END OPENSSH PRIVATE KEY-----
```

- This entire block (from -----BEGIN... to -----END...) is your private key.

#### 🔑 Step 3 Add private key as GitHub secret

> you need to add each secret separately in GitHub. Each secret is a key-value pair. So for your EC2 auto-deploy setup, you’ll do 3 secrets in total:

#### ✅ Secret 1 — Private Key

    - Name: EC2_SSH_KEY

    - Value: Entire content of your ~/.ssh/id_rsa (private key)

#### ✅ Secret 2 — EC2 Host

    - Name: EC2_HOST

    - Value: Your EC2 public IP (something like 3.120.45.78)

#### ✅ Secret 3 — EC2 User

    - Name: EC2_USER

    - Value: ec2-user (default user on Amazon Linux / Amazon Linux 2)

✅ Each secret must be added one at a time:

- Go to your GitHub repo → Settings → Secrets and Variables → Actions → New repository secret

`- Name it: EC2_SSH_KEY

`- Paste the entire private key from cat ~/.ssh/id_rsa

- Save the secret

> Now your GitHub Actions workflow can SSH into EC2 securely using this key.

#### ✅ Add EC2 connection details as GitHub secrets

- Add two more secrets:

| Name     | Value                  |
| -------- | ---------------------- |
| EC2_HOST | `<your EC2 public IP>` |
| EC2_USER | `ec2-user`             |

#### ✅ Once all 3 secrets are added, your GitHub Actions workflow can reference them like this:

```
ssh -o StrictHostKeyChecking=no ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }}
```

> These secrets will be referenced in the workflow YAML.

### 5️⃣ Update GitHub Actions Workflow

### Create a file:

```
.github/workflows/deploy.yml
```

#### ✅ Current deploy.yml

```
name: ☕ Charlie Cafe DevOps CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    steps:

    # -------------------------------------------------
    # 1️⃣ Clone Repository
    # -------------------------------------------------
    - name: 📥 Clone Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Configure AWS Credentials (REQUIRED)
    # -------------------------------------------------
    - name: 🔐 Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    # -------------------------------------------------
    # 3️⃣ Install Required Tools
    # -------------------------------------------------
    - name: 🧰 Install Tools
      run: |
        sudo apt-get update
        sudo apt-get install -y mysql-client jq

    # -------------------------------------------------
    # 4️⃣ Retrieve RDS Secret
    # -------------------------------------------------
    - name: 🗝️ Retrieve RDS Secret
      run: |
        SECRET_JSON=$(aws secretsmanager get-secret-value \
          --secret-id arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
          --region us-east-1 \
          --query SecretString \
          --output text)

        echo "DB_SECRET=$SECRET_JSON" >> $GITHUB_ENV

    # -------------------------------------------------
    # 5️⃣ Parse Secret
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
    # 7️⃣ Create Database (SAFE)
    # -------------------------------------------------
    - name: 🗄️ Create Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS -e "
        CREATE DATABASE IF NOT EXISTS $DB_NAME;
        "

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
    # 11️⃣ Build Docker Image
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 12️⃣ Run Container
    # -------------------------------------------------
    - name: 🚀 Run Container
      run: |
        docker run -d -p 8080:80 --name charlie_web \
        -e AWS_REGION=us-east-1 \
        -e RDS_SECRET_ARN=arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
        charlie-cafe

    # -------------------------------------------------
    # 13️⃣ Health Check
    # -------------------------------------------------
    - name: ❤️ Test Application
      run: |
        sleep 10
        curl -f http://localhost:8080/health.php || exit 1

    # -------------------------------------------------
    # 14️⃣ Success
    # -------------------------------------------------
    - name: 🎉 Success
      run: echo "Deployment completed successfully 🚀"
```

#### ✅ Updated With this content:

```
name: 🚀 Auto Deploy to EC2

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: 📥 Checkout Code
      uses: actions/checkout@v3

    - name: 🔑 Setup SSH
      uses: webfactory/ssh-agent@v0.8.0
      with:
        ssh-private-key: ${{ secrets.EC2_SSH_KEY }}

    - name: 🚀 Deploy to EC2
      run: |
        ssh -o StrictHostKeyChecking=no ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} << 'EOF'

        # Go to project folder or clone if not exists
        cd ~/charlie-cafe-devops || git clone git@github.com:awsrmmustansarjavaid/charlie-cafe-devops.git
        cd charlie-cafe-devops

        # Pull latest code
        git pull origin main

        # Stop & remove old Docker container/image
        sudo docker rm -f cafe-app || true
        sudo docker rmi charlie-cafe || true

        # Build & run new Docker container
        sudo docker build -t charlie-cafe -f docker/apache-php/Dockerfile .
        sudo docker run -d -p 80:80 --name cafe-app charlie-cafe

        EOF
```

✅ This workflow will auto-deploy every time you push to main.

### 🌐 Fully Final deploy.yml

```
name: 🚀 Charlie Cafe Auto Deploy

# Trigger auto-deploy on push to main branch
on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:

    # -------------------------------------------------
    # 1️⃣ Checkout Code
    # -------------------------------------------------
    - name: 📥 Checkout Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Setup SSH to EC2
    # -------------------------------------------------
    - name: 🔑 Setup SSH
      uses: webfactory/ssh-agent@v0.8.0
      with:
        ssh-private-key: ${{ secrets.EC2_SSH_KEY }}

    # -------------------------------------------------
    # 3️⃣ Deploy via Bash Script on EC2
    # -------------------------------------------------
    - name: 🚀 SSH & Run Deployment Script
      run: |
        ssh -o StrictHostKeyChecking=no ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} << 'EOF'

        # Go to project folder
        cd ~/charlie-cafe-devops || git clone git@github.com:awsrmmustansarjavaid/charlie-cafe-devops.git
        cd charlie-cafe-devops

        # Ensure bash script is executable
        chmod +x charlie-cafe-devops.sh

        # Run deployment
        ./charlie-cafe-devops.sh

        EOF

    # -------------------------------------------------
    # 4️⃣ Success Notification
    # -------------------------------------------------
    - name: 🎉 Deployment Success
      run: echo "Charlie Cafe deployed successfully via SSH to EC2 🚀"
```

### ✅ Fully final latest Deploy.yml

```
name: ☕ Charlie Cafe — FULL CI/CD PIPELINE (FINAL)

on:
  push:
    branches: [ "main" ]

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
    # (Needed for RDS + Secrets Manager)
    # -------------------------------------------------
    - name: 🔐 Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    # -------------------------------------------------
    # 3️⃣ Install Required Tools
    # -------------------------------------------------
    - name: 🧰 Install Tools
      run: |
        sudo apt-get update
        sudo apt-get install -y mysql-client jq curl

    # -------------------------------------------------
    # 4️⃣ Retrieve RDS Secret from AWS
    # -------------------------------------------------
    - name: 🗝️ Retrieve RDS Secret
      run: |
        SECRET_JSON=$(aws secretsmanager get-secret-value \
          --secret-id arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
          --region us-east-1 \
          --query SecretString \
          --output text)

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
    # 6️⃣ Wait for RDS Availability
    # -------------------------------------------------
    - name: ⏳ Wait for RDS
      run: |
        for i in {1..20}; do
          mysqladmin ping -h $DB_HOST -u$DB_USER -p$DB_PASS --silent && break
          echo "Waiting for RDS..."
          sleep 5
        done

    # -------------------------------------------------
    # 7️⃣ Create Database (Safe)
    # -------------------------------------------------
    - name: 🗄️ Create Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS -e "
        CREATE DATABASE IF NOT EXISTS $DB_NAME;
        "

    # -------------------------------------------------
    # 8️⃣ Apply Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # 9️⃣ Apply Sample Data
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
    # 11️⃣ Build Docker Image (CI validation)
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 12️⃣ Run Container Locally (CI test)
    # -------------------------------------------------
    - name: 🚀 Run Container (Test)
      run: |
        docker run -d -p 8080:80 --name test_app charlie-cafe
        sleep 10

    # -------------------------------------------------
    # 13️⃣ Health Check
    # -------------------------------------------------
    - name: ❤️ Test Application
      run: |
        curl -f http://localhost:8080/health.php || exit 1

    # -------------------------------------------------
    # 14️⃣ Cleanup Test Container
    # -------------------------------------------------
    - name: 🧹 Cleanup
      run: |
        docker rm -f test_app || true

    # -------------------------------------------------
    # 15️⃣ Setup SSH for EC2 Deployment
    # -------------------------------------------------
    - name: 🔑 Setup SSH
      uses: webfactory/ssh-agent@v0.8.0
      with:
        ssh-private-key: ${{ secrets.EC2_SSH_KEY }}

    # -------------------------------------------------
    # 16️⃣ Deploy to EC2 (CD Step)
    # -------------------------------------------------
    - name: 🚀 Deploy to EC2
      run: |
        ssh -o StrictHostKeyChecking=no ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} << 'EOF'

        echo "🚀 Starting Deployment on EC2..."

        # Clone repo if not exists
        cd ~/charlie-cafe-devops || git clone git@github.com:awsrmmustansarjavaid/charlie-cafe-devops.git
        cd charlie-cafe-devops

        # Pull latest changes
        git pull origin main

        # Stop & remove old container
        sudo docker rm -f cafe-app || true

        # Remove old image (optional cleanup)
        sudo docker rmi charlie-cafe || true

        # Build new image
        sudo docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

        # Run container on port 80
        sudo docker run -d -p 80:80 --name cafe-app charlie-cafe

        echo "✅ Deployment Completed!"

        EOF

    # -------------------------------------------------
    # 17️⃣ Final Success Message
    # -------------------------------------------------
    - name: 🎉 Success
      run: echo "CI/CD Pipeline Completed Successfully 🚀"
```

### 🔥 WHAT YOU JUST BUILT (VERY IMPORTANT)

This is now a REAL INDUSTRY PIPELINE:

#### ✅ CI (GitHub Actions)

- Build Docker

- Test app

- Validate DB

#### ✅ CD (Auto Deploy)

- SSH → EC2

- Pull latest code

- Rebuild container

- Restart app

### 🔐 REQUIRED SECRETS (FINAL CHECK)

Make sure you added:

| Secret                  | Value           |
| ----------------------- | --------------- |
| `AWS_ACCESS_KEY_ID`     | ✅               |
| `AWS_SECRET_ACCESS_KEY` | ✅               |
| `EC2_SSH_KEY`           | ✅ (private key) |
| `EC2_HOST`              | ✅               |
| `EC2_USER`              | ec2-user        |

### 🚀 FINAL RESULT

Now when you run:

```
git push origin main
```

#### 👉 Automatically:

- CI runs (build + test)

- If success → deploy to EC2

- App updates live 🚀

### 🧠 DEVOPS LEVEL YOU REACHED

You are now doing:

✅ CI/CD pipelines

✅ AWS Secrets Manager integration

✅ SSH-based secure deployment

✅ Docker automation

👉 This is mid-level DevOps Engineer skillset

### 7️⃣ Clone your repository first

Navigate to a folder where you want your repo, e.g.:

```
cd ~
git clone git@github.com:awsrmmustansarjavaid/charlie-cafe-devops.git
```

This will create a folder charlie-cafe-devops with a .git inside.

### 8️⃣ Enter the repo

```
cd charlie-cafe-devops
```

### 9️⃣ Make changes, add, commit, push

```
# Make your changes in this folder
git add .
git commit -m "Test auto-deploy"
git push origin main
```

#### ⚡ Important Notes

- git add / git commit / git push must always be run inside a Git repo (a folder that has a .git folder).

- If you run them outside, Git has no idea what repository you mean → you get that error.

- Your SSH key is already fine — GitHub will accept the push now.

#### ✅ Update your GitHub Actions workflow

Since you added your EC2 key to GitHub, use it as the secret EC2_SSH_KEY in your workflow. The workflow will SSH from GitHub Actions into your EC2 securely.


### 🔑 Method 2 Auto deploy from GitHub → EC2 using Token

### 1️⃣ Create GitHub Token

- Go to: 👉 https://github.com/settings/tokens

- Click: 👉 Generate new token (classic)

- Select permissions:

✔ repo

✔ workflow

- Click: 👉 Generate token

- Copy token (example):

```
ghp_abc123xyz456...
```

### 2️⃣ Export in EC2 (SAFE)

```
export GITHUB_TOKEN="your_token_here"
```

### 3️⃣ Use in Script

We modify git remote:

```
https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git
```

### 3️⃣ Initialize DEVOPS SCRIPT

#### 📁 Read More [Charlie Cafe DEVOPS](/docs/charlie-cafe-devops.md)

```
nano charlie-cafe-devops.sh
```

[charlie-cafe-devops.sh](../infrastructure/scripts/charlie-cafe-devops.sh)

### Option 1 — GitHub Actions auto-deploy

Your deploy.yml workflow in GitHub SSHes into your EC2 and runs the commands (or your bash script).

#### You can either:

- Copy all the commands from your bash script directly into the deploy.yml (inline), or

- Keep the bash script on EC2 (recommended) and just call it in the workflow:

```
- name: 🚀 Deploy via Bash Script
  run: |
    ssh -o StrictHostKeyChecking=no ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} 'bash ~/charlie-cafe-devops/charlie-cafe-devops.sh'
```

- This way, every push to main automatically triggers deployment.

- ✅ No need for GitHub token, no manual intervention.

### Option 2 — Manual run

You could still SSH into EC2 and run the bash script manually:

```
chmod +x charlie-cafe-devops.sh
./charlie-cafe-devops.sh
```

✅ This works but defeats the purpose of automated deploy.

#### Recommendation

- Keep the bash script on EC2.

- GitHub Actions should call the bash script via SSH.

- This keeps your workflow clean and avoids duplicating Docker, DB setup, or git commands in the workflow YAML.

#### ⚠️ root privileges

```
sudo chmod +x charlie-cafe-devops.sh
sudo ./charlie-cafe-devops.sh
```

#### ⚠️ FINAL THINGS YOU MUST EDIT BEFORE RUN

🔴 1. GitHub Username

```
GITHUB_USERNAME="YOUR_USERNAME"
```

🔴 2. AWS Secret ARN

```
SECRET_ARN="your-real-secret-arn"
```

🔴 3. Project Folder Name

```
PROJECT_DIR="charlie-cafe"
```

👉 Make sure your folder name matches EXACTLY

🔴 4. (Optional) Port

```
PORT="80"
```

🔴 5. EC2 Security Group

Make sure port is open:

- HTTP → 80

- Or 8080 if changed

### ⚠️ Curl issue 

#### ✅ ✅ BEST FIX (Recommended)

Run this command:

```
sudo dnf install curl --allowerasing -y
sudo dnf install -y unzip wget nano vim-enhanced tar
```

#### ✅ Notes & Best Practices

- Do not duplicate commands: Docker build/run, DB setup, git pull, etc., are already in your bash script. GitHub Actions just triggers it.

- Token-free deployment: Using SSH keys is more secure than using GitHub tokens.

- Auto-update: Every push to main triggers the workflow automatically.

- Debugging: Check logs in GitHub Actions if deployment fails; your bash script prints colored logs, so it’s easy to track.

----
## Method 2- GitHub → EC2 Auto-Deploy via AWS Access Keys (Charlie Cafe)

### Tech Concept:

> This is called “GitHub Actions → AWS CLI → EC2 Deployment using IAM credentials”.

> Instead of SSH keys, we use AWS IAM user credentials with programmatic access. GitHub will authenticate via AWS Access Key ID & Secret Key, and execute commands on EC2 using SSM (AWS Systems Manager) or AWS CLI.

### ✅ Recommended when:

- You want centralized AWS authentication

- Avoid managing SSH keys per instance

- Enable multi-instance deployment

- Keep CI/CD fully cloud-native

### 1️⃣ Prepare EC2 for AWS Access Key Deployment

- Check if EC2 IAM Role exists

  - If you attach an IAM role to EC2 with AmazonEC2FullAccess or custom policy, your GitHub Actions can deploy without SSH.

  - Otherwise, you can use AWS Access Key in GitHub secrets.

- Install AWS CLI on EC2 (if not installed)

```
sudo apt update && sudo apt install -y awscli   # Ubuntu/Debian
sudo yum install -y aws-cli                     # Amazon Linux
aws --version
```

- Optional: Configure default AWS profile (for testing only)

```
aws configure
# Enter AWS_ACCESS_KEY_ID
# Enter AWS_SECRET_ACCESS_KEY
# Default region: us-east-1 (or your region)
```

### 2️⃣ Create IAM User for GitHub Actions

- Go to AWS → IAM → Users → Add user

  - UserName: github-ci-cd-user

  - ✅ Select:

```
Provide user access to the AWS Management Console → ❌ UNCHECK
```

- #### 👉 IMPORTANT:

  - You only need programmatic access (API)

  - NOT console login

- #### ✅ Set Permissions (VERY IMPORTANT)

  - Choose: 👉 Attach policies directly

  For your Charlie Cafe lab (minimum working policy):

  You can either:

    - #### ✅ Option A (Simple - for learning)

    Attach: AdministratorAccess (easy but not secure)

    > 👉 Good for lab only

    - #### ✅ Option B (Recommended - Professional)

    Click Create policy → Use this:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode",
        "lambda:GetFunction",
        "ec2:DescribeInstances",
        "ssm:SendCommand",
        "ssm:GetCommandInvocation"
      ],
      "Resource": "*"
    }
  ]
}
```

    - #### ✅ Option c ( Professional)

    Click Create policy → Use this:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ssm:SendCommand",
        "ssm:ListCommandInvocations",
        "ssm:GetCommandInvocation",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "*"
    }
  ]
}
```

- Policy Name: GitHub-Actions

- 👉 Then attach this policy to your user

### 🔐 Create IAM User Access Key for GitHub

#### 🧠 What You Are Doing (Concept)

You are creating:

✅ IAM User with Programmatic Access
→ Used by GitHub Actions to access AWS (Lambda, EC2, ECS, etc.)

This is called:

👉 “Machine-to-Machine Authentication using IAM Access Keys”

- ### 1️⃣ Create Access Key 🔑

- Go to AWS → IAM → Users → your user

- Go to Security credentials → Access keys → Create Access key

- #### Choose Use Case:

  Select: 👉 Command Line Interface (CLI)

- Click Next → Create

- ### 2️⃣ Save Keys (VERY IMPORTANT)

You will get:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

#### ⚠️ You will NOT see secret again!

👉 Save it safely OR download .csv

### 3️⃣ Add GitHub Secrets for AWS Access Key

- Go to GitHub Repo → Settings → Secrets → Actions → New repository secret:

- #### Add: 

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

✅ Example: AWS_REGION = us-east-1

#### ✅ Use in GitHub Actions

In your deploy.yml:

```
- name: 🔐 Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}
```

### 🔥 Important Security Concepts

#### ❗ Access Key = Password

Treat it like:

```
Root password ❌ DO NOT SHARE
```

#### ❗ Never do this:

❌ Don’t push keys to GitHub code

❌ Don’t store in .env in repo

❌ Don’t share in screenshots

#### ✅ Best Practice (Pro Level)

Later upgrade to:

- IAM Roles + OIDC (no keys needed)

- Temporary credentials

### ⚔️ SSH vs AWS Access Key (Your Case)

| Feature        | SSH Key (EC2)   | AWS Access Key        |
| -------------- | --------------- | --------------------- |
| Use Case       | Server login    | AWS API access        |
| Used For       | EC2 deploy      | Lambda, EC2, ECS      |
| GitHub Usage   | SSH into server | AWS CLI               |
| Security Level | Medium          | High (IAM controlled) |

### 💡 Final Understanding (VERY IMPORTANT)

👉 Your setup now:

```
GitHub Actions
   ↓ (Access Key)
AWS API
   ↓
Lambda / EC2 / ECS
```

### ✅ More Professional and aviod EC2 SSH 

| Secret Name             | Value                              |
| ----------------------- | ---------------------------------- |
| `AWS_ACCESS_KEY_ID`     | (your IAM user access key ID)      |
| `AWS_SECRET_ACCESS_KEY` | (your IAM user secret access key)  |
| `AWS_REGION`            | `us-east-1` (or your region)       |
| `EC2_INSTANCE_ID`       | `i-0123456789abcdef0` (target EC2) |
| `EC2_USER`              | `ec2-user` (default username)      |

> 💡 Tip: Instead of hardcoding EC2 IP, use EC2 instance ID + AWS SSM to target instance — no SSH needed.

### 4️⃣ Keep Deployment Script on EC2

Place your charlie-cafe-devops.sh in EC2:

```
mkdir -p ~/charlie-cafe-devops
nano ~/charlie-cafe-devops/charlie-cafe-devops.sh
chmod +x ~/charlie-cafe-devops/charlie-cafe-devops.sh
```

#### Script can contain:

- git pull (if repo cloned)

- docker-compose up -d

- service restart commands

### 5️⃣ Update GitHub Actions (deploy.yml)

Use AWS CLI + SSM to execute commands on EC2:

```
# ==========================================================
# 🚀 GitHub → EC2 Deployment (AWS Access Key)
# ==========================================================
jobs:
  deploy-ec2:
    runs-on: ubuntu-latest
    steps:

      # 1️⃣ Configure AWS Credentials
      - name: 🔐 Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      # 2️⃣ Run Deployment Script on EC2 via SSM
      - name: 🚀 Deploy to EC2
        run: |
          aws ssm send-command \
            --targets "Key=instanceIds,Values=${{ secrets.EC2_INSTANCE_ID }}" \
            --document-name "AWS-RunShellScript" \
            --comment "Deploy Charlie Cafe" \
            --parameters 'commands=["cd ~/charlie-cafe-devops && ./charlie-cafe-devops.sh"]' \
            --region ${{ secrets.AWS_REGION }}
```

#### ✅ Explanation:

- aws-actions/configure-aws-credentials → allows GitHub to authenticate to AWS

- aws ssm send-command → executes bash script remotely on EC2

- No SSH key needed

- Works on multiple EC2 instances by adding more IDs in Values=...

### ⚠️ What This Script Actually Does (Step-by-Step)

#### 🧩 Inside EC2 (automatically):

```
cd /home/ec2-user/charlie-cafe
git pull origin main
docker stop app || true
docker rm app || true
docker build -t charlie-cafe .
docker run -d -p 80:80 --name app charlie-cafe
```

### ⚠️ VERY IMPORTANT REQUIREMENTS (SSM Setup)

Before this works, your EC2 must have:

#### ✅ 1. IAM Role attached to EC2

- Go to: EC2 → Instances → Select your instance → Actions → Security → Modify IAM Role

- 👉 Attach role with this policy required: AmazonSSMManagedInstanceCore:

- Use this:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SSMDeploy",
      "Effect": "Allow",
      "Action": [
        "ssm:SendCommand",
        "ssm:GetCommandInvocation",
        "ssm:ListCommandInvocations"
      ],
      "Resource": "*"
    },
    {
      "Sid": "EC2Describe",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

#### ✔ This allows:

- SSM connection

- RunCommand execution

- Instance visibility in Systems Manager

#### ✅ 2. SSM Agent installed

- For Amazon Linux: ✔ Already installed (usually)

- Check:

```
sudo systemctl status amazon-ssm-agent
```

If NOT running:

```
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
```

#### ✅ 3. Verify SSM Connectivity

✅ Instance must appear in SSM

- Go to: 👉 AWS Console → Systems Manager → Managed Instances

✅ You MUST see:

- Your EC2 instance listed

- Status: Online

❌ If NOT:

#### 🔴 1️⃣ Fix ssm agent

```
sudo systemctl restart amazon-ssm-agent
```

#### 🔴 2️⃣ Fix Your IAM Policy (Missing Permission ⚠️)

Your pipeline uses:

```
aws ssm send-command
```

But sometimes it silently fails without this:

👉 Add this to your IAM policy:

```
{
  "Sid": "SSMExtras",
  "Effect": "Allow",
  "Action": [
    "ssm:DescribeInstanceInformation"
  ],
  "Resource": "*"
}
```

#### 🔴 3️⃣ Secrets Manager Permission (YOU MISSED THIS ❗)

Your pipeline uses:

```
aws secretsmanager get-secret-value
```

But your IAM policy DOES NOT allow it.

👉 Add this:

```
{
  "Sid": "SecretsAccess",
  "Effect": "Allow",
  "Action": [
    "secretsmanager:GetSecretValue"
  ],
  "Resource": "*"
}
```

#### 🔴 4️⃣ Docker Must Be Installed on EC2

SSH into EC2 and confirm:

```
docker --version
```

If not:

```
sudo yum install docker -y
sudo systemctl start docker
sudo usermod -aG docker ec2-user
```

#### 🔴 5️⃣ Git Must Be Installed on EC2

```
git --version
```

If not:

```
sudo yum install git -y
```

#### 🔴 6️⃣ Repo Must Exist on EC2 (VERY COMMON MISTAKE)

Your script runs:

```
cd /home/ec2-user/charlie-cafe-devops
git pull origin main
```

👉 You must already clone it:

```
cd /home/ec2-user
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git charlie-cafe-devops
```

#### 🔴 7️⃣ Security Group (Port 80 Open)

- EC2 → Security Group

- Allow:

```
HTTP (80) → 0.0.0.0/0
```

#### 🔴 8️⃣ Fix Hardcoded Secrets ARN

Your pipeline has:

```
arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123
```

⚠️ Replace:

- Account ID

- Secret name

### 🧠 6. Pro Upgrade (Next Level DevOps)

Later you can enhance:

#### 🔹 Add Docker pull from ECR instead of build:

```
docker pull <your-ecr-image>
```

#### 🔹 Add health check:

```
curl -f http://localhost || exit 1
```

#### 🔹 Add rollback logic

### 6️⃣ Test Deployment

```
aws ssm list-command-invocations --region us-east-1
```

- Check if script executed successfully

- Output logs available in AWS → Systems Manager → Run Command

### 7️⃣ Key Concepts (Interview-Friendly)

| Concept            | Old SSH Key Method     | New AWS Access Key Method       |
| ------------------ | ---------------------- | ------------------------------- |
| Authentication     | SSH private/public key | IAM Access Key + Secret Key     |
| Security           | Keys on EC2            | IAM managed & auditable         |
| Scalability        | Manual per server      | Multi-EC2 via SSM               |
| GitHub Integration | Deploy key + SSH       | GitHub Secrets + AWS CLI        |
| CI/CD DevOps Level | Medium                 | Full professional, cloud-native |
| Rollback & Logs    | Manual                 | CloudWatch + SSM logs           |

### ✅ Summary

- You replace SSH key authentication with AWS IAM credentials.

- Use AWS SSM to run scripts remotely → no open SSH ports required.

- GitHub Actions uses secrets (AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY) to authenticate.

- Multi-instance deployments become easy & secure.

- Works for your Charlie Cafe lab without major architecture changes.

### ✅ PART 2 — What You Can Do NEXT (REAL DEVOPS UPGRADE)

Now comes the important career-building part 🔥

### 🚀 LEVEL 1 — Make Pipeline Production Ready

### ✅ 1. Use ECR Instead of Local Docker Build

Instead of building on EC2:

```
docker build
```

#### 👉 Do this:

- Build in GitHub Actions

- Push to ECR

- Pull in EC2

#### ✔ Benefits:

- Faster deploy

- Version control

- Scalable

### ✅ 2. Add Deployment Status Tracking

After SSM:

```
aws ssm list-command-invocations
```

Add wait + status check → ensures deployment success

### ✅ 3. Add Health Check After Deployment

```
curl http://YOUR_EC2_PUBLIC_IP/health.php
```

### ✅ 4. Add Rollback (IMPORTANT)

If deploy fails:

```
docker run previous_image
```

### 🚀 LEVEL 2 — Move to REAL DevOps Architecture

This is where your project becomes job-ready

### 🔥 Option A: Move to ECS (BEST STEP)

Replace EC2 Docker with:

- ECS Fargate

- ALB

- Auto scaling

You already planned this — DO IT NEXT.

### 🔥 Option B: Add CloudWatch Monitoring

Track:

- Logs

- CPU

- Memory

- Errors

### 🔥 Option C: Add CI/CD Stages

Split pipeline:

```
Build → Test → Security Scan → Deploy
```

### 🔥 Option D: Add Terraform (BIG CAREER BOOST)

Convert manual AWS setup into code:

- VPC

- EC2

- RDS

- IAM

### 🚀 LEVEL 3 — Advanced (Top 10% DevOps)

- Blue/Green Deployment

- Canary Deployment

- Auto rollback

- Multi-region deployment

- Observability stack (Prometheus + Grafana)

### 🎯 FINAL REALITY CHECK

Your current setup is already:

✔ Real CI/CD

✔ Uses GitHub Actions

✔ Uses AWS SSM

✔ Uses Secrets Manager

✔ Uses Docker

✔ Uses RDS

👉 This is INTERMEDIATE DevOps level already


---
