variable "name_prefix" {
type=string }

 variable "private_subnet_ids" {
type=list(string) }

 variable "rds_sg_id" {
type=string }

 variable "initial_db_name" {
type=string
default="cafedb" }

 variable "db_username" {
type=string
default="cafe_user" }

 variable "db_password" {
type=string
sensitive=true }

 variable "instance_class" {
type=string
default="db.t3.micro" }

 variable "allocated_storage" {
type=number
default=20 }

 variable "tags" {
type=map(string)
default={} }
