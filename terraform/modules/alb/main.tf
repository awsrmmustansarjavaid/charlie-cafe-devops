resource "aws_lb" "this" {
name=substr(lower(replace("${var.name_prefix}-alb","_","-")),0,32)
internal=false
load_balancer_type="application"
security_groups=[var.alb_sg_id]
subnets=var.public_subnet_ids
enable_deletion_protection=true
tags=var.tags }


resource "aws_lb_target_group" "ec2" {
name=substr(lower(replace("${var.name_prefix}-ec2","_","-")),0,32)
port=80
protocol="HTTP"
vpc_id=var.vpc_id
target_type="instance"
health_check {
path="/"
matcher="200-399" }
tags=var.tags }


resource "aws_lb_target_group_attachment" "ec2" {
target_group_arn=aws_lb_target_group.ec2.arn
target_id=var.ec2_instance_id
port=80 }


resource "aws_lb_target_group" "blue" {
name=substr(lower(replace("${var.name_prefix}-blue","_","-")),0,32)
port=80
protocol="HTTP"
vpc_id=var.vpc_id
target_type="ip"
health_check {
path="/"
matcher="200-399" }
tags=var.tags }


resource "aws_lb_target_group" "green" {
name=substr(lower(replace("${var.name_prefix}-green","_","-")),0,32)
port=80
protocol="HTTP"
vpc_id=var.vpc_id
target_type="ip"
health_check {
path="/"
matcher="200-399" }
tags=var.tags }


resource "aws_lb_listener" "http" {
load_balancer_arn=aws_lb.this.arn
port=80
protocol="HTTP"
default_action {
type="forward"
target_group_arn=aws_lb_target_group.ec2.arn } }


resource "aws_lb_listener" "https" {
count=var.certificate_arn==null ? 0 : 1
load_balancer_arn=aws_lb.this.arn
port=443
protocol="HTTPS"
certificate_arn=var.certificate_arn
ssl_policy="ELBSecurityPolicy-TLS13-1-2-2021-06"
default_action {
type="forward"
target_group_arn=aws_lb_target_group.ec2.arn } }
