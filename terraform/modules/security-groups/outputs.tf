output "alb_sg_id" {
value=aws_security_group.alb.id }

 output "ec2_sg_id" {
value=aws_security_group.ec2.id }

 output "lambda_sg_id" {
value=aws_security_group.lambda.id }

 output "ecs_sg_id" {
value=aws_security_group.ecs.id }

 output "rds_sg_id" {
value=aws_security_group.rds.id }

 output "endpoint_sg_id" {
value=aws_security_group.endpoints.id }
