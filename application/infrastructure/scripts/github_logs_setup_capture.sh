#!/bin/bash

# ==========================================================
# ☕ Charlie Cafe — GitHub CLI Setup & Capture Logs
# ==========================================================
# This script:
#   1️⃣ Installs GitHub CLI (gh)
#   2️⃣ Authenticates CLI with your deploy key / PAT
#   3️⃣ Lists workflows & workflow runs
#   4️⃣ Captures logs to timestamped files
# ==========================================================

set -e

REPO_DIR=~/charlie-cafe-devops
LOG_DIR=$REPO_DIR/github_logs
LIMIT=100  # Number of workflow runs to fetch

echo "=================================================="
echo "🚀 Starting GitHub CLI setup & log capture"
echo "=================================================="

# ----------------------------------------------------------
# Step 1: Install GitHub CLI
# ----------------------------------------------------------
echo "🌐 Step 1: Installing GitHub CLI..."

if ! command -v gh &>/dev/null; then
    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install -y gh
else
    echo "✅ gh already installed"
fi

gh --version

# ----------------------------------------------------------
# Step 2: Authenticate GitHub CLI
# ----------------------------------------------------------
echo ""
echo "🌐 Step 2: Authenticate GitHub CLI"
echo "Please login via SSH (matches your deploy key) or token"
echo "Follow prompts in terminal or browser if needed..."
gh auth login
gh auth status

# ----------------------------------------------------------
# Step 3: Prepare log directory
# ----------------------------------------------------------
mkdir -p "$LOG_DIR"
echo "📂 Logs will be saved in: $LOG_DIR"

# ----------------------------------------------------------
# Step 4: Navigate to repo
# ----------------------------------------------------------
cd "$REPO_DIR" || { echo "❌ Repo directory not found!"; exit 1; }

echo ""
echo "📁 Repository: $(pwd)"
ls -la

# Check remote URL
echo ""
echo "🔗 Git remote URL:"
git remote -v

# Check Git status
echo ""
echo "📄 Git status:"
git status

# ----------------------------------------------------------
# Step 5: List workflows
# ----------------------------------------------------------
echo ""
echo "🔎 Listing workflows..."
gh workflow list

# ----------------------------------------------------------
# Step 6: List latest workflow runs
# ----------------------------------------------------------
echo ""
echo "🔎 Listing latest $LIMIT workflow runs..."
gh run list --limit $LIMIT

# ----------------------------------------------------------
# Step 7: Capture logs for all workflow runs
# ----------------------------------------------------------
echo ""
echo "📥 Capturing logs for workflow runs..."

for run_id in $(gh run list --limit $LIMIT --json databaseId -q '.[].databaseId'); do
    created=$(gh run view $run_id --json createdAt -q '.createdAt' | tr -d '"')
    timestamp=$(date -d "$created" +%Y%m%d_%H%M%S)
    filename="$LOG_DIR/github_logs_${run_id}_$timestamp.txt"
    
    echo "📄 Saving logs for run $run_id -> $filename"
    gh run view $run_id --log > "$filename"
done

echo "✅ All logs saved successfully!"

# ----------------------------------------------------------
# Step 8: Optional: Live streaming instructions
# ----------------------------------------------------------
echo ""
echo "📡 To stream logs live for a workflow run:"
echo "gh run watch <run_id>"
echo "Replace <run_id> with your workflow run ID"

echo "=================================================="
echo "🎉 GitHub CLI setup & log capture complete!"
echo "=================================================="