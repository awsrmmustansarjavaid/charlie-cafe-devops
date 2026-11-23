resource "aws_dynamodb_table" "menu" {
name="${var.name_prefix}-CafeMenu"
billing_mode="PAY_PER_REQUEST"
hash_key="item"
attribute {
name="item"
type="S" }
tags=var.tags }


resource "aws_dynamodb_table" "orders" {
name="${var.name_prefix}-CafeOrders"
billing_mode="PAY_PER_REQUEST"
hash_key="order_id"
attribute {
name="order_id"
type="S" }
tags=var.tags }


resource "aws_dynamodb_table" "metrics" {
name="${var.name_prefix}-CafeOrderMetrics"
billing_mode="PAY_PER_REQUEST"
hash_key="metric"
attribute {
name="metric"
type="S" }
tags=var.tags }


resource "aws_dynamodb_table" "attendance" {
name="${var.name_prefix}-CafeAttendance"
billing_mode="PAY_PER_REQUEST"
hash_key="employee_id"
range_key="date"
attribute {
name="employee_id"
type="S" }
attribute {
name="date"
type="S" }
tags=var.tags }
