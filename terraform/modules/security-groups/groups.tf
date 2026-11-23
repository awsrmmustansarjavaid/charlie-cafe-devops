resource "aws_security_group" "alb" {
name="${var.name_prefix}-alb-sg"
description="Public ALB ingress"
vpc_id=var.vpc_id
ingress {
from_port=80
to_port=80
protocol="tcp"
cidr_blocks=["0.0.0.0/0"] }
dynamic "ingress" {
for_each=var.enable_https ? [1] : []
content {
from_port=443
to_port=443
protocol="tcp"
cidr_blocks=["0.0.0.0/0"] } }
egress {
from_port=0
to_port=0
protocol="-1"
cidr_blocks=["0.0.0.0/0"] }
tags=merge(var.tags,{Name="${var.name_prefix}-alb-sg"}) }


resource "aws_security_group" "ec2" {
name="${var.name_prefix}-ec2-sg"
description="Web tier"
vpc_id=var.vpc_id
ingress {
from_port=80
to_port=80
protocol="tcp"
security_groups=[aws_security_group.alb.id] }
dynamic "ingress" {
for_each=var.ssh_cidr_blocks
content {
from_port=22
to_port=22
protocol="tcp"
cidr_blocks=[ingress.value] } }
egress {
from_port=0
to_port=0
protocol="-1"
cidr_blocks=["0.0.0.0/0"] }
tags=merge(var.tags,{Name="${var.name_prefix}-ec2-sg"}) }


resource "aws_security_group" "lambda" {
name="${var.name_prefix}-lambda-sg"
description="Lambda VPC egress"
vpc_id=var.vpc_id
egress {
from_port=0
to_port=0
protocol="-1"
cidr_blocks=["0.0.0.0/0"] }
tags=merge(var.tags,{Name="${var.name_prefix}-lambda-sg"}) }


resource "aws_security_group" "ecs" {
name="${var.name_prefix}-ecs-sg"
description="ECS task ingress from ALB"
vpc_id=var.vpc_id
ingress {
from_port=80
to_port=80
protocol="tcp"
security_groups=[aws_security_group.alb.id] }
egress {
from_port=0
to_port=0
protocol="-1"
cidr_blocks=["0.0.0.0/0"] }
tags=merge(var.tags,{Name="${var.name_prefix}-ecs-sg"}) }


resource "aws_security_group" "rds" {
name="${var.name_prefix}-rds-sg"
description="MySQL from application tiers"
vpc_id=var.vpc_id
ingress {
from_port=3306
to_port=3306
protocol="tcp"
security_groups=[aws_security_group.lambda.id,aws_security_group.ec2.id,aws_security_group.ecs.id] }
egress {
from_port=0
to_port=0
protocol="-1"
cidr_blocks=["0.0.0.0/0"] }
tags=merge(var.tags,{Name="${var.name_prefix}-rds-sg"}) }


resource "aws_security_group" "endpoints" {
name="${var.name_prefix}-vpce-sg"
description="HTTPS from private workloads"
vpc_id=var.vpc_id
ingress {
from_port=443
to_port=443
protocol="tcp"
security_groups=[aws_security_group.lambda.id,aws_security_group.ecs.id] }
egress {
from_port=0
to_port=0
protocol="-1"
cidr_blocks=["0.0.0.0/0"] }
tags=merge(var.tags,{Name="${var.name_prefix}-vpce-sg"}) }
