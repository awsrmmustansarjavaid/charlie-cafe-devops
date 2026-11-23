# Lambda module

Deploys all 13 Python files present in the supplied repository, packages them as Lambda code, and attaches a PyMySQL layer. Before Terraform plan/apply run `bash terraform/scripts/package-lambda-layer.sh` from repository root. The Lambda layer is generated locally and is not committed.
