# Charlie Cafe -- Github Logs

### 🌐 View Github logs

### Step 1️⃣ Install GitHub CLI (gh) on Amazon Linux 2023

- Enable the GitHub CLI repo:

```
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
```

- Install gh:

```
sudo dnf install -y gh
```

- Verify installation:

```
gh --version
```

#### ✅ You should see something like:

```
gh version 3.x.x (2026-xx-xx)
```

### Step 2️⃣ Authenticate GitHub CLI

You need to authenticate so gh can access your repos:

```
gh auth login
```

  - Select GitHub.com

  - Choose SSH for Git operations (matches your deploy key)

  - Follow the prompts to authenticate (may open a browser link or use a token)

### Step 3️⃣ Github Personal Access Token (PAT)

- Go to GitHub Tokens Page → Personal Access Tokens → classic tokens

- Token name: Github-logs

- Click Generate new token

- Set the repository access to your repo awsrmmustansarjavaid/charlie-cafe-devops

- Minimum scopes for gh SSH login:

  - repo (full access to repository)

  - read:org (required by GitHub CLI even if you don’t use orgs)

  - admin:public_key (to upload SSH keys)

- Generate token → copy it


### Step 4️⃣ Check authentication:

```
gh auth status
```

### Step 5️⃣ View GitHub Actions logs

List workflows for your repo:

```
gh workflow list
```

#### ✅ Output example:

```
NAME                                    STATE    ID
☕ Charlie Cafe — FULL CI/CD PIPELINE    active   1234567
```

#### 🧱 View runs for a workflow:

```
gh run list
```

#### ✅ This will show the latest runs:

```
STATUS  NAME                                  BRANCH  EVENT    ID
✔       FULL CI/CD PIPELINE (FINAL)          main    push     173
✔       FULL CI/CD PIPELINE (FINAL)          main    push     172
```

#### 🧱 View logs of a specific run:

```
gh run view 173 --log
```

- Replace 173 with the run ID you want.
- You’ll see the full step-by-step logs, just like GitHub Actions on the web.

### Step 6️⃣ Optional: Stream logs live

You can also watch the workflow logs in real-time:

```
gh run watch 173
```

✅ Now you can monitor CI/CD directly from EC2, no need to open GitHub web UI every time.

### Capture GitHub Actions logs

### Step 1️⃣ Make sure gh is installed and authenticated

Check:

```
gh --version
gh auth status
```

You must be authenticated with GitHub CLI, otherwise you won’t be able to fetch logs.

### Step 2️⃣ List your workflow runs

Navigate to your project folder (or anywhere you like):

```
cd ~/charlie-cafe-devops
```

Then list workflow runs:

```
gh run list
```

#### ✅ You’ll see output like:

```
STATUS  NAME                                  BRANCH  EVENT    ID
✔       FULL CI/CD PIPELINE (FINAL)          main    push     173
✔       FULL CI/CD PIPELINE (FINAL)          main    push     172
```

> Note the ID of the run you want to save. Let’s say it’s 173.

```
gh run list --limit 100
```

- --limit 100 fetches the latest 100 runs.

### Step 3️⃣ View logs (optional preview)

```
gh run view 173 --log
```

This shows logs directly in the terminal.

### Step 4️⃣ Save logs to a file

You can redirect logs to a file using >:

```
gh run view 173 --log > github_logs.txt
```

This creates a file github_logs.txt in your current directory with all the logs.

### Step 5️⃣ Verify the file

```
ls -la github_logs.txt
cat github_logs.txt | less
```

- less lets you scroll through the logs easily.

- You can also use nano github_logs.txt or vim github_logs.txt to open it.

### Step 6️⃣ Optional: Include timestamp in filename

```
gh run view 173 --log > github_logs_$(date +%Y%m%d_%H%M%S).txt
```

This creates a new file like:

```
github_logs_20260402_151230.txt
```

Handy for keeping multiple log snapshots.

### 💡 Tip: If you want to automate fetching latest workflow logs, you can combine:

```
LATEST_ID=$(gh run list --limit 1 --json databaseId -q '.[0].databaseId')
gh run view $LATEST_ID --log > github_logs_latest.txt
```

This automatically fetches the latest run logs into github_logs_latest.txt.

### Step 7️⃣ Save all logs in separate files

We can loop over all run IDs and save each log to a separate file:

```
mkdir -p github_logs

for run_id in $(gh run list --limit 100 --json databaseId -q '.[].databaseId'); do
    echo "Saving logs for run $run_id..."
    gh run view $run_id --log > github_logs/github_logs_$run_id.txt
done
```

#### ✅ This will create a folder github_logs and save each workflow run log as:

```
github_logs_173.txt
github_logs_172.txt
github_logs_171.txt
...
```

### Step 8️⃣ Verify saved logs

```
ls -la github_logs
```

Open any log:

```
less github_logs/github_logs_173.txt
```

### Step 9️⃣ Optional: Add timestamps to filenames

If you want the file names to include the run time:

```
mkdir -p github_logs

for run_id in $(gh run list --limit 100 --json databaseId,createdAt -q '.[].databaseId'); do
    created=$(gh run view $run_id --json createdAt -q '.createdAt' | tr -d '"')
    filename="github_logs/github_logs_${run_id}_$(date -d $created +%Y%m%d_%H%M%S).txt"
    echo "Saving logs for run $run_id to $filename..."
    gh run view $run_id --log > "$filename"
done
```

- Each file now has both the run ID and timestamp.

### 💡 Tip: You can wrap this into a Bash script save_all_github_logs.sh and just run it whenever you want to archive all workflow logs.

### Step 🔟 capture_github_logs

```
#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — Capture GitHub Actions Logs
# ==========================================================
# Saves logs of all workflow runs into timestamped files
# ==========================================================

# -----------------------------
# Config
# -----------------------------
REPO_DIR=~/charlie-cafe-devops
LOG_DIR=$REPO_DIR/github_logs
LIMIT=100  # Number of latest workflow runs to fetch

# -----------------------------
# Create log folder
# -----------------------------
mkdir -p "$LOG_DIR"
echo "📂 Logs will be saved in: $LOG_DIR"

# -----------------------------
# Navigate to repo
# -----------------------------
cd "$REPO_DIR" || { echo "❌ Repo directory not found!"; exit 1; }

# -----------------------------
# Loop over workflow runs
# -----------------------------
echo "🔎 Fetching last $LIMIT workflow runs..."

for run_id in $(gh run list --limit $LIMIT --json databaseId,createdAt -q '.[].databaseId'); do
    # Get created timestamp
    created=$(gh run view $run_id --json createdAt -q '.createdAt' | tr -d '"')
    timestamp=$(date -d "$created" +%Y%m%d_%H%M%S)
    
    # File name
    filename="$LOG_DIR/github_logs_${run_id}_$timestamp.txt"
    
    echo "📥 Saving logs for run $run_id -> $filename..."
    
    # Capture logs
    gh run view $run_id --log > "$filename"
done

echo "✅ All logs saved successfully!"
echo "=================================================="
```

### ✅ How to use

- ### Save the script:

```
nano ~/capture_github_logs.sh
```

- #### Make it executable:

```
chmod +x ~/capture_github_logs.sh
```

- #### Run it:

```
~/capture_github_logs.sh
```

- #### Check logs:

```
ls -la ~/charlie-cafe-devops/github_logs
less ~/charlie-cafe-devops/github_logs/github_logs_173_20260402_151230.txt
```

### 💡 Tip:

You can run this anytime to fetch logs of latest runs.
The folder will keep all logs, separated by run ID and timestamp.
Perfect for auditing or debugging CI/CD pipelines directly from EC2.
