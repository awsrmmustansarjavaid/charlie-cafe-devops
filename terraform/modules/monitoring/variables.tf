variable "name_prefix" {
type=string }

 variable "alb_arn_suffix" {
type=string }

 variable "tags" {
type=map(string)
default={} }

variable "green_target_group_arn_suffix" {
type=string }
