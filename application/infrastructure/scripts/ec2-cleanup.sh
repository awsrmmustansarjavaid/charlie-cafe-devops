#!/bin/bash

# ==========================================================
# 🧹 Charlie Cafe — Full EC2 Cleanup Script (Final Safe Version)
# ----------------------------------------------------------
# This script will remove:
#   ✅ Docker containers, images, volumes, networks
#   ✅ Docker & Docker Compose
#   ✅ MariaDB (MySQL client) and database files
#   ✅ Git
#   ✅ Optional DevOps tools (htop, nano, awscli, etc.)
#   ✅ Project folder charlie-cafe-devops
# ==========================================================

set -e  # Exit immediately if a command fails
echo "🚀 Starting full cleanup of EC2 environment..."

# ==========================================================
# 1️⃣ Stop and Remove Docker Containers
# ==========================================================
echo -e "\n🔹 Stopping all running Docker containers..."
docker ps -q | xargs -r docker stop

echo "🔹 Removing all Docker containers..."
docker ps -a -q | xargs -r docker rm -f

# ==========================================================
# 2️⃣ Remove Docker Images, Volumes, Networks
# ==========================================================
echo -e "\n🔹 Listing Docker images (optional check)..."
docker images -a

echo "🔹 Removing all Docker images..."
docker images -a -q | xargs -r docker rmi -f

echo "🔹 Removing all Docker volumes..."
docker volume ls -q | xargs -r docker volume rm

echo "🔹 Removing all Docker networks..."
docker network ls -q | xargs -r docker network rm

# ==========================================================
# 3️⃣ Uninstall Docker & Docker Compose
# ==========================================================
echo -e "\n🔹 Stopping Docker service..."
sudo systemctl stop docker || true
sudo systemctl disable docker || true

echo "🔹 Removing Docker packages..."
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine || true

echo "🔹 Removing Docker Compose binary..."
sudo rm -f /usr/local/lib/docker/cli-plugins/docker-compose

echo "🔹 Removing leftover Docker folders..."
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# ==========================================================
# 4️⃣ Uninstall MariaDB (MySQL client)
# ==========================================================
echo -e "\n🔹 Stopping MariaDB service..."
sudo systemctl stop mariadb || true
sudo systemctl disable mariadb || true

echo "🔹 Removing MariaDB packages..."
sudo dnf remove -y mariadb105 mariadb105-server mariadb105-libs mariadb105-common || true

echo "🔹 Removing leftover database files..."
sudo rm -rf /var/lib/mysql
sudo rm -rf /etc/my.cnf.d

# ==========================================================
# 5️⃣ Uninstall Git
# ==========================================================
echo -e "\n🔹 Removing Git..."
sudo dnf remove -y git || true

# ==========================================================
# 6️⃣ Remove Other DevOps Tools (optional)
# ==========================================================
echo -e "\n🔹 Removing DevOps tools..."
# curl-minimal is protected, so we remove only non-protected curl packages
sudo dnf remove -y htop unzip wget nano vim tar awscli curl || true

# ==========================================================
# 7️⃣ Remove Project Folder
# ==========================================================
echo -e "\n🔹 Removing Charlie Cafe project folder..."
rm -rf ~/charlie-cafe-devops

# ==========================================================
# ✅ Cleanup Completed
# ==========================================================
echo -e "\n🎉 EC2 cleanup completed successfully!"
echo "You now have a fresh environment ready for DevOps scripts."