variable "aws_region" {
type = string
default = "us-east-1" }

 variable "state_bucket_name" {
type = string
description = "Globally unique S3 bucket name for Terraform state" }

 variable "tags" {
type = map(string)
default = {
Project = "CharlieCafe"
Environment = "Phase2"
ManagedBy = "Terraform" } }
