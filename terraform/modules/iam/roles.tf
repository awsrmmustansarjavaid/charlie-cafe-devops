data "aws_iam_policy_document" "assume_ec2" {
statement {
actions=["sts:AssumeRole"]
principals {
type="Service"
identifiers=["ec2.amazonaws.com"] } } }


resource "aws_iam_role" "ec2" {
name="${var.name_prefix}-EC2-Cafe-Secrets-Role"
assume_role_policy=data.aws_iam_policy_document.assume_ec2.json
tags=var.tags }


resource "aws_iam_role_policy_attachment" "ec2_ssm" {
role=aws_iam_role.ec2.name
policy_arn="arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" }


resource "aws_iam_role_policy" "ec2_secret" {
name="${var.name_prefix}-read-db-secret"
role=aws_iam_role.ec2.id
policy=jsonencode({Version="2012-10-17",Statement=[{Effect="Allow",Action=["secretsmanager:GetSecretValue"],Resource=[var.rds_secret_arn]}]}) }


data "aws_iam_policy_document" "assume_lambda" {
statement {
actions=["sts:AssumeRole"]
principals {
type="Service"
identifiers=["lambda.amazonaws.com"] } } }


resource "aws_iam_role" "lambda" {
name="${var.name_prefix}-Lambda-Cafe-Order-Role"
assume_role_policy=data.aws_iam_policy_document.assume_lambda.json
tags=var.tags }


resource "aws_iam_role_policy_attachment" "lambda_basic" {
role=aws_iam_role.lambda.name
policy_arn="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" }


resource "aws_iam_role_policy_attachment" "lambda_vpc" {
role=aws_iam_role.lambda.name
policy_arn="arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole" }


resource "aws_iam_role_policy" "lambda_app" {
name="${var.name_prefix}-lambda-app-access"
role=aws_iam_role.lambda.id
policy=jsonencode({Version="2012-10-17",Statement=[{Effect="Allow",Action=["secretsmanager:GetSecretValue"],Resource=[var.rds_secret_arn]},{Effect="Allow",Action=["sqs:SendMessage"],Resource=[var.sqs_queue_arn]},{Effect="Allow",Action=["dynamodb:GetItem","dynamodb:PutItem","dynamodb:UpdateItem","dynamodb:Query","dynamodb:Scan"],Resource=concat(var.dynamodb_table_arns,[for a in var.dynamodb_table_arns:"${a}/index/*"])}]}) }


data "aws_iam_policy_document" "assume_ecs" {
statement {
actions=["sts:AssumeRole"]
principals {
type="Service"
identifiers=["ecs-tasks.amazonaws.com"] } } }


resource "aws_iam_role" "ecs_execution" {
name="${var.name_prefix}-ecsTaskExecutionRole"
assume_role_policy=data.aws_iam_policy_document.assume_ecs.json
tags=var.tags }


resource "aws_iam_role_policy_attachment" "ecs_execution" {
role=aws_iam_role.ecs_execution.name
policy_arn="arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" }


resource "aws_iam_role_policy" "ecs_secret" {
name="${var.name_prefix}-ecs-read-db-secret"
role=aws_iam_role.ecs_execution.id
policy=jsonencode({Version="2012-10-17",Statement=[{Effect="Allow",Action=["secretsmanager:GetSecretValue"],Resource=[var.rds_secret_arn]}]}) }


resource "aws_iam_role" "ecs_task" {
name="${var.name_prefix}-ecsTaskRole"
assume_role_policy=data.aws_iam_policy_document.assume_ecs.json
tags=var.tags }


resource "aws_iam_role_policy" "ecs_task_access" {
name="${var.name_prefix}-ecs-task-access"
role=aws_iam_role.ecs_task.id
policy=jsonencode({Version="2012-10-17",Statement=[{Effect="Allow",Action=["dynamodb:GetItem","dynamodb:PutItem","dynamodb:UpdateItem","dynamodb:Query","dynamodb:Scan"],Resource=var.dynamodb_table_arns}]}) }
