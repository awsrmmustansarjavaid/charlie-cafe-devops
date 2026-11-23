variable "name_prefix" {
type=string }

 variable "rds_secret_arn" {
type=string }

 variable "sqs_queue_arn" {
type=string }

 variable "dynamodb_table_arns" {
type=list(string) }

 variable "tags" {
type=map(string)
default={} }
