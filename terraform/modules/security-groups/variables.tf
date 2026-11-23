variable "name_prefix" {
type=string }

 variable "vpc_id" {
type=string }

 variable "ssh_cidr_blocks" {
type=list(string)
default=[] }

 variable "tags" {
type=map(string)
default={} }

variable "enable_https" {
type=bool
default=false }
