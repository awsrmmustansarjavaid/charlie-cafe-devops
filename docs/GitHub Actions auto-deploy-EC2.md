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

### 7️⃣ Push & Test

#### Commit & push the workflow:

```
git add .github/workflows/deploy.yml
git commit -m "Add auto-deploy workflow"
git push origin main
```

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