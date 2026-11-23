resource "aws_api_gateway_rest_api" "this" {
name="${var.name_prefix}-CafeOrderAPI"
description="Charlie Cafe order and HR API"
endpoint_configuration {
types=["REGIONAL"] } }
locals {
routes = {
orders = {
path = "orders",
parent = "root",
method = "POST",
lambda = "CafeOrderProcessor",
auth = false }
get_order_status = {
path = "get-order-status",
parent = "root",
method = "GET",
lambda = "GetOrderStatusLambda",
auth = false }
cafe_order_status = {
path = "cafe-order-status",
parent = "root",
method = "GET",
lambda = "CafeOrderStatusLambda",
auth = false }
order_update = {
path = "order-update",
parent = "root",
method = "POST",
lambda = "CafeOrderWorkerLambda",
auth = false }
mark_paid = {
path = "mark-paid",
parent = "admin",
method = "POST",
lambda = "AdminMarkPaidLambda",
auth = true }
analytics = {
path = "analytics",
parent = "root",
method = "GET",
lambda = "CafeAnalyticsLambda",
auth = true }
attendance_checkin = {
path = "checkin",
parent = "attendance",
method = "POST",
lambda = "hr-attendance",
auth = true }
attendance_checkout = {
path = "checkout",
parent = "attendance",
method = "POST",
lambda = "hr-attendance",
auth = true }
employee_profile = {
path = "employee-profile",
parent = "root",
method = "POST",
lambda = "hr-employee-profile",
auth = true }
attendance_history = {
path = "attendance-history",
parent = "root",
method = "POST",
lambda = "hr-attendance-history",
auth = true }
leaves_holidays = {
path = "leaves-holidays",
parent = "root",
method = "POST",
lambda = "hr-leaves-holidays",
auth = true }
hr_analytics = {
path = "hr-analytics",
parent = "root",
method = "GET",
lambda = "cafe-attendance-admin-service",
auth = true }
  }
}


resource "aws_api_gateway_resource" "admin" {
rest_api_id = aws_api_gateway_rest_api.this.id
parent_id = aws_api_gateway_rest_api.this.root_resource_id
path_part = "admin"
}


resource "aws_api_gateway_resource" "attendance" {
rest_api_id = aws_api_gateway_rest_api.this.id
parent_id = aws_api_gateway_rest_api.this.root_resource_id
path_part = "attendance"
}


resource "aws_api_gateway_resource" "resource" {
for_each = local.routes
rest_api_id = aws_api_gateway_rest_api.this.id
parent_id = each.value.parent == "admin" ? aws_api_gateway_resource.admin.id : each.value.parent == "attendance" ? aws_api_gateway_resource.attendance.id : aws_api_gateway_rest_api.this.root_resource_id
path_part = each.value.path
}


resource "aws_api_gateway_method" "method" {
for_each=local.routes
rest_api_id=aws_api_gateway_rest_api.this.id
resource_id=aws_api_gateway_resource.resource[each.key].id
http_method=each.value.method
authorization=each.value.auth ? "COGNITO_USER_POOLS" : "NONE"
authorizer_id=each.value.auth ? aws_api_gateway_authorizer.cognito.id : null }


resource "aws_api_gateway_integration" "lambda" {
for_each=local.routes
rest_api_id=aws_api_gateway_rest_api.this.id
resource_id=aws_api_gateway_resource.resource[each.key].id
http_method=aws_api_gateway_method.method[each.key].http_method
integration_http_method="POST"
type="AWS_PROXY"
uri="arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_arns[each.value.lambda]}/invocations" }


data "aws_region" "current" {}


resource "aws_api_gateway_authorizer" "cognito" {
name="${var.name_prefix}-cognito-authorizer"
rest_api_id=aws_api_gateway_rest_api.this.id
type="COGNITO_USER_POOLS"
provider_arns=[var.cognito_user_pool_arn]
identity_source="method.request.header.Authorization" }


resource "aws_api_gateway_method" "options" {
for_each=local.routes
rest_api_id=aws_api_gateway_rest_api.this.id
resource_id=aws_api_gateway_resource.resource[each.key].id
http_method="OPTIONS"
authorization="NONE" }


resource "aws_api_gateway_integration" "options" {
for_each=local.routes
rest_api_id=aws_api_gateway_rest_api.this.id
resource_id=aws_api_gateway_resource.resource[each.key].id
http_method=aws_api_gateway_method.options[each.key].http_method
type="MOCK"
request_templates={"application/json"="{\"statusCode\": 200}"} }


resource "aws_api_gateway_method_response" "options" {
for_each=local.routes
rest_api_id=aws_api_gateway_rest_api.this.id
resource_id=aws_api_gateway_resource.resource[each.key].id
http_method="OPTIONS"
status_code="200"
response_parameters={"method.response.header.Access-Control-Allow-Headers"=true,"method.response.header.Access-Control-Allow-Methods"=true,"method.response.header.Access-Control-Allow-Origin"=true} }


resource "aws_api_gateway_integration_response" "options" {
for_each=local.routes
rest_api_id=aws_api_gateway_rest_api.this.id
resource_id=aws_api_gateway_resource.resource[each.key].id
http_method="OPTIONS"
status_code=aws_api_gateway_method_response.options[each.key].status_code
response_parameters={"method.response.header.Access-Control-Allow-Headers"="'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'","method.response.header.Access-Control-Allow-Methods"="'GET,POST,OPTIONS'","method.response.header.Access-Control-Allow-Origin"="'*'"} }


resource "aws_api_gateway_deployment" "this" {
rest_api_id=aws_api_gateway_rest_api.this.id
triggers={redeployment=sha1(jsonencode([aws_api_gateway_resource.resource,aws_api_gateway_method.method,aws_api_gateway_integration.lambda,aws_api_gateway_method.options,aws_api_gateway_integration.options]))}
lifecycle {
create_before_destroy=true }
depends_on=[aws_api_gateway_integration.lambda,aws_api_gateway_integration.options,aws_api_gateway_integration_response.options] }


resource "aws_api_gateway_stage" "dev" {
deployment_id=aws_api_gateway_deployment.this.id
rest_api_id=aws_api_gateway_rest_api.this.id
stage_name="dev"
tags=var.tags }



resource "aws_lambda_permission" "api_gateway" {
for_each = toset([for route in values(local.routes) : route.lambda])
statement_id = "AllowApiGateway-${replace(each.value, "-", "") }"
action = "lambda:InvokeFunction"
function_name = var.lambda_arns[each.value]
principal = "apigateway.amazonaws.com"
source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
}
