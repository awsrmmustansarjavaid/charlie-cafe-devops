resource "aws_cloudwatch_log_group" "ecs" {
name="/ecs/${var.name_prefix}-charlie-task"
retention_in_days=30
tags=var.tags }


resource "aws_ecs_cluster" "this" {
name="${var.name_prefix}-charlie-cluster"
setting {
name="containerInsights"
value="enabled" }
tags=var.tags }


resource "aws_ecs_task_definition" "this" {
family="${var.name_prefix}-charlie-task"
requires_compatibilities=["FARGATE"]
network_mode="awsvpc"
cpu="512"
memory="1024"
execution_role_arn=var.execution_role_arn
task_role_arn=var.task_role_arn
runtime_platform {
operating_system_family="LINUX"
cpu_architecture="X86_64" }
container_definitions=jsonencode([{name="charlie-container",image="${var.ecr_repository_url}:bootstrap",essential=true,portMappings=[{containerPort=80,hostPort=80,protocol="tcp"}],secrets=[{name="DB_HOST",valueFrom="${var.db_secret_arn}:host::"},{name="DB_USER",valueFrom="${var.db_secret_arn}:username::"},{name="DB_PASS",valueFrom="${var.db_secret_arn}:password::"}],environment=[{name="DB_NAME",value=var.db_name}],logConfiguration={logDriver="awslogs",options={"awslogs-group"=aws_cloudwatch_log_group.ecs.name,"awslogs-region"=data.aws_region.current.name,"awslogs-stream-prefix"="ecs"}}}])
tags=var.tags }


data "aws_region" "current" {}


resource "aws_ecs_service" "this" {
name="${var.name_prefix}-charlie-service"
cluster=aws_ecs_cluster.this.id
task_definition=aws_ecs_task_definition.this.arn
desired_count=var.desired_count
launch_type="FARGATE"
deployment_controller {
type="CODE_DEPLOY" }
network_configuration {
subnets=var.private_subnet_ids
security_groups=[var.ecs_sg_id]
assign_public_ip=false }
load_balancer {
target_group_arn=var.blue_target_group_arn
container_name="charlie-container"
container_port=80 }
lifecycle {
ignore_changes=[task_definition,load_balancer] }
depends_on=[aws_cloudwatch_log_group.ecs]
tags=var.tags }
