output "alb_arn" {
value=aws_lb.this.arn }

 output "alb_dns_name" {
value=aws_lb.this.dns_name }

 output "alb_zone_id" {
value=aws_lb.this.zone_id }

 output "ec2_target_group_arn" {
value=aws_lb_target_group.ec2.arn }

 output "blue_target_group_arn" {
value=aws_lb_target_group.blue.arn }

 output "green_target_group_arn" {
value=aws_lb_target_group.green.arn }

 output "listener_arn" {
value=aws_lb_listener.http.arn }

 output "https_listener_arn" {
value=try(aws_lb_listener.https[0].arn,null) }


output "alb_arn_suffix" {
value=aws_lb.this.arn_suffix }


output "green_target_group_arn_suffix" {
value=aws_lb_target_group.green.arn_suffix }
