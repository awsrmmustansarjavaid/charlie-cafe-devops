variable "name_prefix" {
type=string }

 variable "lambda_arns" {
type=map(string) }

 variable "cognito_user_pool_arn" {
type=string }

 variable "tags" {
type=map(string)
default={} }
