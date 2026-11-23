variable "vpc_id" { type=string }

variable "name_prefix" {
type=string }

 variable "public_subnet_ids" {
type=list(string) }

 variable "alb_sg_id" {
type=string }

 variable "certificate_arn" {
type=string
default=null }

 variable "ec2_instance_id" {
type=string }

 variable "tags" {
type=map(string)
default={} }
