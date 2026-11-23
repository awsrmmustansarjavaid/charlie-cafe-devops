locals {
interface_services=["secretsmanager","sqs","logs","ecr.api","ecr.dkr","ssm","ssmmessages","ec2messages"] }


resource "aws_vpc_endpoint" "interface" {
for_each=toset(local.interface_services)
vpc_id=var.vpc_id
service_name="com.amazonaws.${var.region}.${each.value}"
vpc_endpoint_type="Interface"
subnet_ids=var.private_subnet_ids
security_group_ids=[var.endpoint_sg_id]
private_dns_enabled=true
tags=merge(var.tags,{Name="${var.name_prefix}-${replace(each.value,".","-")}-INT-EP"}) }


resource "aws_vpc_endpoint" "dynamodb" {
vpc_id=var.vpc_id
service_name="com.amazonaws.${var.region}.dynamodb"
vpc_endpoint_type="Gateway"
route_table_ids=var.private_route_table_ids
tags=merge(var.tags,{Name="${var.name_prefix}-dynamodb-GW-EP"}) }


resource "aws_vpc_endpoint" "s3" {
vpc_id=var.vpc_id
service_name="com.amazonaws.${var.region}.s3"
vpc_endpoint_type="Gateway"
route_table_ids=var.private_route_table_ids
tags=merge(var.tags,{Name="${var.name_prefix}-s3-ecr-GW-EP"}) }
