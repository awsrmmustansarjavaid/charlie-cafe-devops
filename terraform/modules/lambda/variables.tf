variable "name_prefix" {
type=string }

 variable "lambda_source_dir" {
type=string }

 variable "lambda_role_arn" {
type=string }

 variable "private_subnet_ids" {
type=list(string) }

 variable "lambda_sg_id" {
type=string }

 variable "secret_arn" {
type=string }

 variable "queue_url" {
type=string }

 variable "table_names" {
type=map(string) }

 variable "tags" {
type=map(string)
default={} }



variable "secret_name" {
type=string }

