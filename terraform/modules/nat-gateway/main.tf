resource "aws_eip" "nat" {
count=var.enabled ? 1 : 0
domain="vpc"
tags=merge(var.tags,{Name="${var.name_prefix}-NAT-EIP"}) }


resource "aws_nat_gateway" "this" {
count=var.enabled ? 1 : 0
allocation_id=aws_eip.nat[0].id
subnet_id=var.public_subnet_ids[0]
tags=merge(var.tags,{Name="${var.name_prefix}-NAT"})
depends_on=[aws_eip.nat] }


resource "aws_route" "private_nat" {
count=var.enabled ? length(var.private_route_table_ids) : 0
route_table_id=var.private_route_table_ids[count.index]
destination_cidr_block="0.0.0.0/0"
nat_gateway_id=aws_nat_gateway.this[0].id }
