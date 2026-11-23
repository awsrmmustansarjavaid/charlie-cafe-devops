variable "name_prefix" {
type=string }

 variable "ecs_cluster_name" {
type=string }

 variable "ecs_service_name" {
type=string }

 variable "blue_target_group_name" {
type=string }

 variable "green_target_group_name" {
type=string }

 variable "listener_arn" {
type=string }

 variable "tags" {
type=map(string)
default={} }

variable "alarm_names" {
type=list(string)
default=[] }
