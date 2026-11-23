output "alarm_names" {
value = [aws_cloudwatch_metric_alarm.alb_5xx.alarm_name, aws_cloudwatch_metric_alarm.green_unhealthy.alarm_name] }
