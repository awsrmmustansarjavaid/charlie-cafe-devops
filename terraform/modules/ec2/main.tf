data "aws_ssm_parameter" "al2023" {
name="/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" }


resource "aws_instance" "web" {
ami=data.aws_ssm_parameter.al2023.value
instance_type=var.instance_type
subnet_id=var.subnet_id
vpc_security_group_ids=[var.security_group_id]
iam_instance_profile=var.instance_profile_name
key_name=var.key_name
associate_public_ip_address=true
user_data= <<-EOF
#!/bin/bash
set -euxo pipefail
dnf update -y
dnf install -y git
if [ ! -d /opt/charlie-cafe/.git ]; then git clone "${var.repository_url}" /opt/charlie-cafe; fi
bash /opt/charlie-cafe/infrastructure/scripts/charlie-cafe-devops.sh
bash "/opt/charlie-cafe/infrastructure/scripts/Lamp Server Script.sh"
mkdir -p /var/www/html
cp -a /opt/charlie-cafe/app/frontend/html/. /var/www/html/ 2>/dev/null || true
cp -a /opt/charlie-cafe/app/frontend/php/. /var/www/html/ 2>/dev/null || true
cp -a /opt/charlie-cafe/app/frontend/css /var/www/html/ 2>/dev/null || true
cp -a /opt/charlie-cafe/app/frontend/js /var/www/html/ 2>/dev/null || true
cat >/etc/httpd/conf.d/charlie-cafe-phase2.conf <<'APACHE'
SetEnv DB_SECRET_NAME ${var.db_secret_name}
APACHE
chown -R apache:apache /var/www/html
systemctl enable --now amazon-ssm-agent || true
systemctl restart httpd
EOF
user_data_replace_on_change=false
root_block_device {
encrypted=true
volume_type="gp3"
volume_size=12 }
tags=merge(var.tags,{Name="${var.name_prefix}-CafeDevWebServer"})
lifecycle {
ignore_changes=[ami,user_data] } }
