resource "aws_sqs_queue" "orders" {
name="${var.name_prefix}-CafeOrdersQueue"
visibility_timeout_seconds=60
message_retention_seconds=345600
max_message_size=262144
delay_seconds=0
receive_wait_time_seconds=0
sqs_managed_sse_enabled=false
tags=var.tags }
