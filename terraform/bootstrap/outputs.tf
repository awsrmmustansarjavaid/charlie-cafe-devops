output "state_bucket_name" {
value = aws_s3_bucket.state.id }

 output "state_key_example" {
value = "charlie-cafe/phase2/dev/terraform.tfstate" }
