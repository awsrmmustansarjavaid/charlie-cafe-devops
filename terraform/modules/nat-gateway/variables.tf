variable "enabled" {
type=bool
default=false }

 variable "name_prefix" {
type=string }

 variable "public_subnet_ids" {
type=list(string) }

 variable "private_route_table_ids" {
type=list(string) }

 variable "tags" {
type=map(string)
default={} }
