module "cognito" {
source="../../modules/cognito"
name_prefix=local.name_prefix
domain_prefix=var.cognito_domain_prefix
callback_urls=concat(var.cognito_callback_urls,["${module.cloudfront.url}/login.html","${module.cloudfront.url}/employee-portal.html"])
logout_urls=concat(var.cognito_logout_urls,["${module.cloudfront.url}/logout.php?loggedout=true","${module.cloudfront.url}/employee-login.html"])
tags=local.common_tags }


module "lambda" {
source="../../modules/lambda"
name_prefix=local.name_prefix
lambda_source_dir=local.lambda_source_dir
lambda_role_arn=module.iam.lambda_role_arn
private_subnet_ids=module.networking.private_subnet_ids
lambda_sg_id=module.security_groups.lambda_sg_id
secret_arn=module.db_secret.secret_arn
secret_name=module.db_secret.secret_name
queue_url=module.sqs.queue_url
table_names=module.dynamodb.table_names
tags=local.common_tags }


module "api_gateway" {
source="../../modules/api-gateway"
name_prefix=local.name_prefix
lambda_arns=module.lambda.function_arns
cognito_user_pool_arn=module.cognito.user_pool_arn
tags=local.common_tags }
