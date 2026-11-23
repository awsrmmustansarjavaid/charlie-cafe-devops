data "aws_iam_policy_document" "assume" {
statement {
actions=["sts:AssumeRole"]
principals {
type="Service"
identifiers=["codedeploy.amazonaws.com"] } } }


resource "aws_iam_role" "this" {
name="${var.name_prefix}-charlie-codedeploy-role"
assume_role_policy=data.aws_iam_policy_document.assume.json
tags=var.tags }


resource "aws_iam_role_policy_attachment" "this" {
role=aws_iam_role.this.name
policy_arn="arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS" }


resource "aws_codedeploy_app" "this" {
name="${var.name_prefix}-charlie-ecs-app"
compute_platform="ECS" }


resource "aws_codedeploy_deployment_group" "this" {
app_name=aws_codedeploy_app.this.name
deployment_group_name="${var.name_prefix}-charlie-ecs-deployment-group"
service_role_arn=aws_iam_role.this.arn
deployment_config_name="CodeDeployDefault.ECSCanary10Percent5Minutes"
deployment_style {
deployment_type="BLUE_GREEN"
deployment_option="WITH_TRAFFIC_CONTROL" }
auto_rollback_configuration {
enabled=true
events=["DEPLOYMENT_FAILURE","DEPLOYMENT_STOP_ON_ALARM"] }
blue_green_deployment_config {
deployment_ready_option {
action_on_timeout="CONTINUE_DEPLOYMENT"
wait_time_in_minutes=0 }
terminate_blue_instances_on_deployment_success {
action="TERMINATE"
termination_wait_time_in_minutes=5 } }
ecs_service {
cluster_name=var.ecs_cluster_name
service_name=var.ecs_service_name }
load_balancer_info {
target_group_pair_info {
prod_traffic_route {
listener_arns=[var.listener_arn] }
target_group {
name=var.blue_target_group_name }
target_group {
name=var.green_target_group_name } } }
tags=var.tags
depends_on=[aws_iam_role_policy_attachment.this]
alarm_configuration {
enabled = length(var.alarm_names) > 0
ignore_poll_alarm_failure = true
dynamic "alarms" {
for_each = var.alarm_names
content {
name = alarms.value }
  }
}
 }
