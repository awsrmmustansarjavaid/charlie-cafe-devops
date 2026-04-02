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