output "table_arns" {
value=[aws_dynamodb_table.menu.arn,aws_dynamodb_table.orders.arn,aws_dynamodb_table.metrics.arn,aws_dynamodb_table.attendance.arn] }

 output "table_names" {
value={menu=aws_dynamodb_table.menu.name,orders=aws_dynamodb_table.orders.name,metrics=aws_dynamodb_table.metrics.name,attendance=aws_dynamodb_table.attendance.name} }
