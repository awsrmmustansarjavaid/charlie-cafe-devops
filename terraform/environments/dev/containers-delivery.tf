module "ecr" {
source="../../modules/ecr"
repository_name="charlie-cafe"
name_suffix=var.name_suffix
tags=local.common_tags }


module "ecs" {
source="../../modules/ecs"
name_prefix=local.name_prefix
private_subnet_ids=module.networking.private_subnet_ids
ecs_sg_id=module.security_groups.ecs_sg_id
ecr_repository_url=module.ecr.repository_url
execution_role_arn=module.iam.ecs_execution_role_arn
task_role_arn=module.iam.ecs_task_role_arn
blue_target_group_arn=module.alb.blue_target_group_arn
db_secret_arn=module.db_secret.secret_arn
db_name=var.db_name
desired_count=var.ecs_desired_count
tags=local.common_tags }


module "codedeploy" {
source="../../modules/codedeploy"
name_prefix=local.name_prefix
ecs_cluster_name=module.ecs.cluster_name
ecs_service_name=module.ecs.service_name
blue_target_group_name=split("/",module.alb.blue_target_group_arn)[1]
green_target_group_name=split("/",module.alb.green_target_group_arn)[1]
listener_arn=module.alb.listener_arn
alarm_names=module.monitoring.alarm_names
tags=local.common_tags }


module "cloudfront" {
source="../../modules/cloudfront"
name_prefix=local.name_prefix
alb_dns_name=module.alb.alb_dns_name
tags=local.common_tags }


module "monitoring" {
source="../../modules/monitoring"
name_prefix=local.name_prefix
alb_arn_suffix=module.alb.alb_arn_suffix
green_target_group_arn_suffix=module.alb.green_target_group_arn_suffix
tags=local.common_tags }
