module "iam" {
source="../../modules/iam"
name_prefix=local.name_prefix
rds_secret_arn=module.db_secret.secret_arn
sqs_queue_arn=module.sqs.queue_arn
dynamodb_table_arns=module.dynamodb.table_arns
tags=local.common_tags }
