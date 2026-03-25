#!/bin/bash
# --------------------------------------------
# EC2 User Data Script (Amazon Linux 2023)
# LAMP + MySQL Client + Docker + Git
# --------------------------------------------

set -e

echo "🚀 Starting EC2 setup..."

# 1️⃣ Update OS
dnf update -y

# 2️⃣ Install Apache (httpd)
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

# 3️⃣ Install PHP + MySQL Support
dnf install -y \
php \
php-mysqlnd \
php-cli \
php-common \
php-mbstring \
php-xml

# 4️⃣ Fix Web Directory Permissions
chown -R apache:apache /var/www
chmod -R 755 /var/www

# 5️⃣ Install MySQL Client (MariaDB)
dnf install -y mariadb105

# 6️⃣ Install Git
dnf install -y git

# 7️⃣ Install Docker
dnf install -y docker

# Enable & Start Docker
systemctl enable docker
systemctl start docker

# Allow ec2-user to run Docker without sudo
usermod -aG docker ec2-user

# 8️⃣ Install AWS CLI (already v2 in AL2023 but safe)
dnf install -y awscli

# 9️⃣ Create PHP Info Page (Optional)
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# 🔟 Restart Apache
systemctl restart httpd

echo "✅ EC2 setup completed successfully!"