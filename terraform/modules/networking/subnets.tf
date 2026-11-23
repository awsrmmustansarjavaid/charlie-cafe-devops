resource "aws_subnet" "public" {
count=2
vpc_id=aws_vpc.this.id
cidr_block=var.public_subnet_cidrs[count.index]
availability_zone=var.availability_zones[count.index]
map_public_ip_on_launch=true
tags=merge(var.tags,{Name="${var.name_prefix}-CafeDevPublicSubnet${count.index+1}",Tier="public"}) }


resource "aws_subnet" "private" {
count=2
vpc_id=aws_vpc.this.id
cidr_block=var.private_subnet_cidrs[count.index]
availability_zone=var.availability_zones[count.index]
map_public_ip_on_launch=false
tags=merge(var.tags,{Name="${var.name_prefix}-CafeDevPrivateSubnet${count.index+1}",Tier="private"}) }
