resource "aws_cognito_user_pool" "this" {
name="${var.name_prefix}-CharlieCafeAdminSPA"
username_attributes=["username"]
auto_verified_attributes=["email"]
mfa_configuration="OFF"
account_recovery_setting {
recovery_mechanism {
name="verified_email"
priority=1 } }
password_policy {
minimum_length=8
require_lowercase=true
require_numbers=true
require_symbols=true
require_uppercase=true }
schema {
name="employee_id"
attribute_data_type="String"
mutable=true
required=false
string_attribute_constraints {
min_length="1"
max_length="256" } }
tags=var.tags }


resource "aws_cognito_user_pool_client" "spa" {
name="${var.name_prefix}-CharlieCafeAdminSPA"
user_pool_id=aws_cognito_user_pool.this.id
generate_secret=false
explicit_auth_flows=["ALLOW_USER_PASSWORD_AUTH","ALLOW_USER_SRP_AUTH","ALLOW_REFRESH_TOKEN_AUTH"]
allowed_oauth_flows_user_pool_client=true
allowed_oauth_flows=["code"]
allowed_oauth_scopes=["openid","email","profile"]
callback_urls=var.callback_urls
logout_urls=var.logout_urls
supported_identity_providers=["COGNITO"]
read_attributes=["email","email_verified","custom:employee_id"]
write_attributes=["email","custom:employee_id"] }


resource "aws_cognito_user_pool_domain" "this" {
domain=var.domain_prefix
user_pool_id=aws_cognito_user_pool.this.id }


resource "aws_cognito_user_group" "admin" {
name="Admin"
user_pool_id=aws_cognito_user_pool.this.id
precedence=1
description="Full system access" }


resource "aws_cognito_user_group" "manager" {
name="Manager"
user_pool_id=aws_cognito_user_pool.this.id
precedence=5
description="Management dashboard" }


resource "aws_cognito_user_group" "employee" {
name="Employee"
user_pool_id=aws_cognito_user_pool.this.id
precedence=10
description="Employee portal" }
