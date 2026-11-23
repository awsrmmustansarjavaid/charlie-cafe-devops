output "vpc_id" {
value=module.networking.vpc_id }

 output "public_subnet_ids" {
value=module.networking.public_subnet_ids }

 output "private_subnet_ids" {
value=module.networking.private_subnet_ids }

 output "ec2_instance_id" {
value=module.ec2.instance_id }

 output "ec2_public_ip" {
value=module.ec2.public_ip }

 output "rds_endpoint" {
value=module.rds.endpoint }

 output "rds_secret_arn" {
value=module.db_secret.secret_arn }

 output "dynamodb_tables" {
value=module.dynamodb.table_names }

 output "sqs_queue_url" {
value=module.sqs.queue_url }

 output "lambda_function_names" {
value=module.lambda.function_names }

 output "api_invoke_url" {
value=module.api_gateway.invoke_url }

 output "cognito_user_pool_id" {
value=module.cognito.user_pool_id }

 output "cognito_client_id" {
value=module.cognito.client_id }

 output "cognito_domain" {
value=module.cognito.domain }

 output "ecr_repository_url" {
value=module.ecr.repository_url }

 output "ecs_cluster_name" {
value=module.ecs.cluster_name }

 output "ecs_service_name" {
value=module.ecs.service_name }

 output "codedeploy_application" {
value=module.codedeploy.application_name }

 output "codedeploy_deployment_group" {
value=module.codedeploy.deployment_group_name }

 output "alb_dns_name" {
value=module.alb.alb_dns_name }

 output "cloudfront_url" {
value=module.cloudfront.url }

 output "cloudfront_distribution_id" {
value=module.cloudfront.distribution_id }



output "ecs_execution_role_arn" {
value=module.iam.ecs_execution_role_arn }


output "ecs_task_role_arn" {
value=module.iam.ecs_task_role_arn }


output "db_secret_name" {
value=module.db_secret.secret_name }


output "ecs_task_family" {
value=module.ecs.task_family }

output "ecs_log_group_name" {
value=module.ecs.log_group_name }


output "db_name" {
value=var.db_name }


output "aws_region" {
value=var.aws_region }


output "ecr_repository_name" {
value=module.ecr.repository_name }
