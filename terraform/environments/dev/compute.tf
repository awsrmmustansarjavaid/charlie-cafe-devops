module "ec2" {
source="../../modules/ec2"
name_prefix=local.name_prefix
subnet_id=module.networking.public_subnet_ids[0]
security_group_id=module.security_groups.ec2_sg_id
instance_profile_name=module.iam.ec2_instance_profile_name
instance_type=var.instance_type
key_name=var.ec2_key_name
repository_url="https://github.com/awsrmmustansarjavaid/charlie-cafe-devops.git"
db_secret_name=module.db_secret.secret_name
tags=local.common_tags }


module "alb" {
source="../../modules/alb"
name_prefix=local.name_prefix
vpc_id=module.networking.vpc_id
public_subnet_ids=module.networking.public_subnet_ids
alb_sg_id=module.security_groups.alb_sg_id
certificate_arn=var.alb_certificate_arn
ec2_instance_id=module.ec2.instance_id
tags=local.common_tags }
