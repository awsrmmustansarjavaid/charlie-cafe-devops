locals {
name_prefix="CharlieCafe${var.name_suffix}"
common_tags=merge(var.tags,{ManagedBy="Terraform",Phase="2"})
lambda_source_dir="${path.root}/../../../application/app/backend/lambda" }
