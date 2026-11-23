resource "aws_dynamodb_table_item" "menu" {
for_each = {
Coffee = 3
Latte = 5
Tea = 2
Cappuccino = 8
    "Fresh Juice" = 6
  }
table_name = aws_dynamodb_table.menu.name
hash_key = aws_dynamodb_table.menu.hash_key
item = jsonencode({ item = { S = each.key }, price = { N = tostring(each.value) } })
}

resource "aws_dynamodb_table_item" "metrics" {
for_each = toset(["TOTAL_ORDERS", "TODAY_ORDERS"])
table_name = aws_dynamodb_table.metrics.name
hash_key = aws_dynamodb_table.metrics.hash_key
item = jsonencode({ metric = { S = each.value }, count = { N = "0" } })
}
