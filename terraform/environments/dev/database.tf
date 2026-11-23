module "rds" {
source="../../modules/rds"
name_prefix=local.name_prefix
private_subnet_ids=module.networking.private_subnet_ids
rds_sg_id=module.security_groups.rds_sg_id
initial_db_name=var.rds_initial_db_name
db_username=var.db_username
db_password=var.db_password
instance_class=var.db_instance_class
allocated_storage=var.db_allocated_storage
tags=local.common_tags }


module "db_secret" {
source="../../modules/secrets-manager"
name_prefix=local.name_prefix
db_username=var.db_username
db_password=var.db_password
db_host=module.rds.endpoint
db_name=var.db_name
tags=local.common_tags }


module "dynamodb" {
source="../../modules/dynamodb"
name_prefix=local.name_prefix
tags=local.common_tags }


module "sqs" {
source="../../modules/sqs"
name_prefix=local.name_prefix
tags=local.common_tags }
