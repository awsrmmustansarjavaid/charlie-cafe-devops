variable "aws_region" {
type=string
default="us-east-1" }

 variable "name_suffix" {
type=string
default="-p2"
description="Unique suffix to prevent collision with Phase 1 resources" }

 variable "vpc_cidr" {
type=string
default="10.0.0.0/16" }

 variable "availability_zones" {
type=list(string)
default=["us-east-1a","us-east-1b"] }

 variable "enable_nat_gateway" {
type=bool
default=false }

 variable "ssh_cidr_blocks" {
type=list(string)
default=[]
description="Optional trusted IPv4 CIDRs for SSH; empty disables SSH ingress" }

 variable "instance_type" {
type=string
default="t2.micro" }

 variable "ec2_key_name" {
type=string
default=null }

 variable "db_name" {
type=string
default="cafe_db" }

 variable "db_username" {
type=string
default="cafe_user" }

 variable "db_password" {
type=string
sensitive=true }

 variable "db_instance_class" {
type=string
default="db.t3.micro" }

 variable "db_allocated_storage" {
type=number
default=20 }

 variable "alb_certificate_arn" {
type=string
default=null }

 variable "cognito_domain_prefix" {
type=string
default="charlie-cafe-auth-p2" }

 variable "cognito_callback_urls" {
type=list(string)
default=[] }

 variable "cognito_logout_urls" {
type=list(string)
default=[] }

 variable "tags" {
type=map(string)
default={
Environment="Phase2"
Project="CharlieCafe" } }

variable "ecs_desired_count" {
type=number
default=0
description="Keep at zero until first ECR image is pushed" }

variable "rds_initial_db_name" { type=string default="cafedb" description="Initial RDS database from the RDS setup guide; app schema is created in db_name" }
