#!/bin/bash

# ==========================================================
# 🚀 CHARLIE CAFE — EC2 BOOTSTRAP SCRIPT (FINAL)
# ==========================================================

set -e

echo "🚀 Starting EC2 Bootstrap..."

# ----------------------------------------------------------
# 1️⃣ Update system
# ----------------------------------------------------------
dnf update -y

# ----------------------------------------------------------
# 2️⃣ Fix curl conflict (Amazon Linux 2023)
# ----------------------------------------------------------
dnf remove -y curl-minimal || true
dnf install -y curl --allowerasing

# ----------------------------------------------------------
# 3️⃣ Install base tools
# ----------------------------------------------------------
dnf install -y \
  git \
  docker \
  jq \
  unzip \
  wget \
  nano \
  vim \
  htop \
  tar \
  awscli \
  mariadb105 \
  python3 \
  python3-pip \
  zip

# ----------------------------------------------------------
# 4️⃣ Start & enable Docker
# ----------------------------------------------------------
systemctl enable docker
systemctl start docker

# ----------------------------------------------------------
# 5️⃣ Allow ec2-user to use Docker
# ----------------------------------------------------------
usermod -aG docker ec2-user

# ----------------------------------------------------------
# 6️⃣ Install Docker Compose v2
# ----------------------------------------------------------
mkdir -p /usr/local/lib/docker/cli-plugins/

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# ----------------------------------------------------------
# 7️⃣ Setup SSH known_hosts for GitHub
# ----------------------------------------------------------
mkdir -p /home/ec2-user/.ssh
ssh-keyscan github.com >> /home/ec2-user/.ssh/known_hosts
chown -R ec2-user:ec2-user /home/ec2-user/.ssh

echo "✅ EC2 Bootstrap completed"
