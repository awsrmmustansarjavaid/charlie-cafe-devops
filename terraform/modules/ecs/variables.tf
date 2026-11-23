variable "name_prefix" {
type=string }

 variable "private_subnet_ids" {
type=list(string) }

 variable "ecs_sg_id" {
type=string }

 variable "ecr_repository_url" {
type=string }

 variable "execution_role_arn" {
type=string }

 variable "task_role_arn" {
type=string }

 variable "blue_target_group_arn" {
type=string }

   variable "db_secret_arn" {
type=string }

 variable "db_name" {
type=string }

 variable "tags" {
type=map(string)
default={} }


variable "desired_count" {
type=number
default=0 }
