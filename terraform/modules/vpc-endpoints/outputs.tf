output "interface_endpoint_ids" {
value=[for ep in aws_vpc_endpoint.interface:ep.id] }

 output "dynamodb_endpoint_id" {
value=aws_vpc_endpoint.dynamodb.id }

 output "s3_endpoint_id" {
value=aws_vpc_endpoint.s3.id }
