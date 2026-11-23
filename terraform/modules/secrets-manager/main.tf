resource "aws_secretsmanager_secret" "db" {
name="${var.name_prefix}-CafeDevDBSM"
description="Charlie Cafe database credentials"
recovery_window_in_days=7
tags=var.tags }


resource "aws_secretsmanager_secret_version" "db" {
secret_id=aws_secretsmanager_secret.db.id
secret_string=jsonencode({username=var.db_username,password=var.db_password,host=var.db_host,dbname=var.db_name,port=var.db_port}) }
