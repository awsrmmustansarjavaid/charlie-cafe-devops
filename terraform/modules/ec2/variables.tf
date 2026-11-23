variable "name_prefix" {
type=string }

 variable "subnet_id" {
type=string }

 variable "security_group_id" {
type=string }

 variable "instance_profile_name" {
type=string }

 variable "instance_type" {
type=string
default="t2.micro" }

 variable "key_name" {
type=string
default=null }

 variable "tags" {
type=map(string)
default={} }


variable "repository_url" {
type=string
default="https://github.com/awsrmmustansarjavaid/charlie-cafe-devops.git" }


variable "db_secret_name" {
type=string }
