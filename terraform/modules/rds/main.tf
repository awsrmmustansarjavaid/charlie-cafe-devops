resource "aws_db_subnet_group" "this" {
name=lower("${var.name_prefix}-rds-subnets")
subnet_ids=var.private_subnet_ids
tags=merge(var.tags,{Name="${var.name_prefix}-CafeRDSSubnetGroup"}) }


resource "aws_db_instance" "this" {
identifier=lower(replace("${var.name_prefix}-cafedb","_","-"))
engine="mysql"
instance_class=var.instance_class
allocated_storage=var.allocated_storage
storage_type="gp3"
db_name=var.initial_db_name
username=var.db_username
password=var.db_password
db_subnet_group_name=aws_db_subnet_group.this.name
vpc_security_group_ids=[var.rds_sg_id]
publicly_accessible=false
multi_az=false
storage_encrypted=true
backup_retention_period=7
auto_minor_version_upgrade=true
deletion_protection=true
skip_final_snapshot=false
final_snapshot_identifier="${lower(replace(var.name_prefix,"_","-"))}-rds-final"
apply_immediately=false
tags=var.tags
lifecycle {
prevent_destroy=true } }
