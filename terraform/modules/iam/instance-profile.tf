resource "aws_iam_instance_profile" "ec2" {
name="${var.name_prefix}-ec2-instance-profile"
role=aws_iam_role.ec2.name }
