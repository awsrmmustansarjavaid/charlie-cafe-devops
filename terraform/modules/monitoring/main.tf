resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
alarm_name = "${var.name_prefix}-charlie-health-alarm"
comparison_operator = "GreaterThanThreshold"
evaluation_periods = 2
metric_name = "HTTPCode_ELB_5XX_Count"
namespace = "AWS/ApplicationELB"
period = 60
statistic = "Sum"
threshold = 10
alarm_description = "ALB generated 5xx errors"
treat_missing_data = "notBreaching"
dimensions = {
LoadBalancer = var.alb_arn_suffix }
tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "green_unhealthy" {
alarm_name = "${var.name_prefix}-charlie-green-unhealthy-alarm"
comparison_operator = "GreaterThanThreshold"
evaluation_periods = 2
metric_name = "UnHealthyHostCount"
namespace = "AWS/ApplicationELB"
period = 60
statistic = "Average"
threshold = 0
alarm_description = "Unhealthy targets in the green ECS target group"
treat_missing_data = "notBreaching"
dimensions = {
LoadBalancer = var.alb_arn_suffix,
TargetGroup = var.green_target_group_arn_suffix }
tags = var.tags
}
