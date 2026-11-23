locals {
functions={
CafeOrderProcessor={file="CafeOrderProcessor",handler="CafeOrderProcessor.lambda_handler",vpc=true,timeout=30}
CafeMenuLambda={file="CafeMenuLambda",handler="CafeMenuLambda.lambda_handler",vpc=false,timeout=15}
CafeOrderStatusLambda={file="CafeOrderStatusLambda",handler="CafeOrderStatusLambda.lambda_handler",vpc=true,timeout=30}
GetOrderStatusLambda={file="GetOrderStatusLambda",handler="GetOrderStatusLambda.lambda_handler",vpc=true,timeout=30}
CafeOrderWorkerLambda={file="CafeOrderWorkerLambda",handler="CafeOrderWorkerLambda.lambda_handler",vpc=true,timeout=30}
AdminMarkPaidLambda={file="AdminMarkPaidLambda",handler="AdminMarkPaidLambda.lambda_handler",vpc=true,timeout=30}
CafeAnalyticsLambda={file="CafeAnalyticsLambda",handler="CafeAnalyticsLambda.lambda_handler",vpc=true,timeout=30}
"hr-attendance"={file="hr-attendance",handler="hr-attendance.lambda_handler",vpc=true,timeout=30}
"hr-employee-profile"={file="hr-employee-profile",handler="hr-employee-profile.lambda_handler",vpc=true,timeout=30}
"hr-attendance-history"={file="hr-attendance-history",handler="hr-attendance-history.lambda_handler",vpc=true,timeout=30}
"hr-leaves-holidays"={file="hr-leaves-holidays",handler="hr-leaves-holidays.lambda_handler",vpc=true,timeout=30}
"cafe-attendance-admin-service"={file="cafe-attendance-admin-service",handler="cafe-attendance-admin-service.lambda_handler",vpc=true,timeout=30}
} }


resource "aws_cloudwatch_log_group" "lambda" {
for_each=local.functions
name="/aws/lambda/${var.name_prefix}-${each.key}"
retention_in_days=30
tags=var.tags }


resource "aws_lambda_function" "this" {
for_each=local.functions
function_name="${var.name_prefix}-${each.key}"
role=var.lambda_role_arn
runtime="python3.12"
handler=each.value.handler
filename=data.archive_file.lambda.output_path
source_code_hash=data.archive_file.lambda.output_base64sha256
timeout=each.value.timeout
memory_size=256
architectures=["x86_64"]
layers=[aws_lambda_layer_version.pymysql.arn]
dynamic "vpc_config" {
for_each=each.value.vpc ? [1] : []
content {
subnet_ids=var.private_subnet_ids
security_group_ids=[var.lambda_sg_id] } }
environment {
variables={SECRET_NAME=var.secret_name,DB_SECRET_ARN=var.secret_arn,SQS_QUEUE_URL=var.queue_url,DYNAMODB_TABLE=var.table_names.attendance,MENU_TABLE_NAME=var.table_names.menu,METRICS_TABLE_NAME=var.table_names.metrics,ORDERS_TABLE_NAME=var.table_names.orders} }
depends_on=[aws_cloudwatch_log_group.lambda]
tags=var.tags }

