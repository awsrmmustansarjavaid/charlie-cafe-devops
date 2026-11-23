module "networking" {
source="../../modules/networking"
name_prefix=local.name_prefix
vpc_cidr=var.vpc_cidr
availability_zones=var.availability_zones
tags=local.common_tags }


module "nat_gateway" {
source="../../modules/nat-gateway"
name_prefix=local.name_prefix
enabled=var.enable_nat_gateway
public_subnet_ids=module.networking.public_subnet_ids
private_route_table_ids=module.networking.private_route_table_ids
tags=local.common_tags }


module "security_groups" {
source="../../modules/security-groups"
name_prefix=local.name_prefix
vpc_id=module.networking.vpc_id
ssh_cidr_blocks=var.ssh_cidr_blocks
enable_https=var.alb_certificate_arn!=null
tags=local.common_tags }


module "vpc_endpoints" {
source="../../modules/vpc-endpoints"
name_prefix=local.name_prefix
vpc_id=module.networking.vpc_id
region=var.aws_region
private_subnet_ids=module.networking.private_subnet_ids
private_route_table_ids=module.networking.private_route_table_ids
endpoint_sg_id=module.security_groups.endpoint_sg_id
tags=local.common_tags }
