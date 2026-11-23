output "user_pool_id" {
value=aws_cognito_user_pool.this.id }

 output "user_pool_arn" {
value=aws_cognito_user_pool.this.arn }

 output "client_id" {
value=aws_cognito_user_pool_client.spa.id }

 output "domain" {
value="https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.name}.amazoncognito.com" }

 data "aws_region" "current" {}
