resource "aws_route_table" "public" {
vpc_id=aws_vpc.this.id
route {
cidr_block="0.0.0.0/0"
gateway_id=aws_internet_gateway.this.id }
tags=merge(var.tags,{Name="${var.name_prefix}-CafeDevPublicRT"}) }


resource "aws_route_table_association" "public" {
count=2
subnet_id=aws_subnet.public[count.index].id
route_table_id=aws_route_table.public.id }


resource "aws_route_table" "private" {
count=2
vpc_id=aws_vpc.this.id
tags=merge(var.tags,{Name="${var.name_prefix}-CafeDevPrivateRT${count.index+1}"}) }


resource "aws_route_table_association" "private" {
count=2
subnet_id=aws_subnet.private[count.index].id
route_table_id=aws_route_table.private[count.index].id }
