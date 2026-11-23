data "archive_file" "lambda" {
type="zip"
source_dir=var.lambda_source_dir
output_path="${path.module}/lambda_bundle.zip"
excludes=["__pycache__","*.pyc"] }



data "archive_file" "layer" {
type = "zip"
source_dir = "${path.module}/layer-build"
output_path = "${path.module}/pymysql-layer.zip"
}


resource "aws_lambda_layer_version" "pymysql" {
layer_name = "${var.name_prefix}-pymysql"
filename = data.archive_file.layer.output_path
source_code_hash = data.archive_file.layer.output_base64sha256
compatible_runtimes = ["python3.12"]
description = "PyMySQL dependency from supplied requirements.txt"
}
