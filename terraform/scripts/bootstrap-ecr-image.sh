#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TFDIR="$ROOT/terraform/environments/dev"
REGION="$(terraform -chdir="$TFDIR" output -raw aws_region)"
REPO="$(terraform -chdir="$TFDIR" output -raw ecr_repository_url)"
REPO_NAME="$(terraform -chdir="$TFDIR" output -raw ecr_repository_name)"
if aws ecr describe-images --region "$REGION" --repository-name "$REPO_NAME" --image-ids imageTag=bootstrap >/dev/null 2>&1; then
  echo "The immutable bootstrap image already exists: $REPO:bootstrap"
  exit 0
fi
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "${REPO%%/*}"
docker build -f "$ROOT/application/docker/apache-php/Dockerfile" -t "$REPO:bootstrap" "$ROOT/application"
docker push "$REPO:bootstrap"
echo "Pushed initial bootstrap image: $REPO:bootstrap"
echo "Next set ecs_desired_count = 1 in terraform/environments/dev/terraform.tfvars, then review and apply a new Terraform plan."
