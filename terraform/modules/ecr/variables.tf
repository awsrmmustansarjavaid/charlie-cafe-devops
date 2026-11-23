variable "repository_name" {
type=string
default="charlie-cafe" }

 variable "name_suffix" {
type=string
default="-p2" }

 variable "tags" {
type=map(string)
default={} }
