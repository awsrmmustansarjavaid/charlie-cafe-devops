# GitHub Actions prerequisites

The workflows use GitHub OIDC; they do not use long-lived AWS access keys.

Create/verify the IAM OIDC provider for `https://token.actions.githubusercontent.com` in the AWS account, then create two IAM roles with trust conditions restricted to `repo:awsrmmustansarjavaid/charlie-cafe-devops:*` (and ideally the protected deployment branch/environment):

- `DEPLOY_AWS_ROLE_ARN`: allow ECR image push (`ecr:GetAuthorizationToken`, layer upload/check/put actions), `ssm:SendCommand` to the Phase 2 EC2 instance, `ecs:RegisterTaskDefinition`, `ecs:Describe*`, `ecs:UpdateService`, CodeDeploy create/get/list deployment actions, and `iam:PassRole` limited to the Terraform-created ECS execution/task roles.
- `TERRAFORM_AWS_ROLE_ARN`: allow the Terraform provider operations required by the modules in this package and read/write/lock the Phase 2 S3 state object. This role is intentionally not self-created by the application stack to avoid a circular bootstrap trust dependency.

Configure repository Actions secrets:

- `DEPLOY_AWS_ROLE_ARN`
- `TERRAFORM_AWS_ROLE_ARN`
- `TF_VAR_DB_PASSWORD`
- `EC2_INSTANCE_ID`
- `ECR_REPO` (Terraform output `ecr_repository_name`)
- `ECS_CLUSTER`
- `ECS_SERVICE`
- `CODEDEPLOY_APPLICATION`
- `CODEDEPLOY_DEPLOYMENT_GROUP`

Run `terraform/scripts/configure-phase2-app.sh` after the first Terraform apply. It fills `.github/task-definition.json` from Terraform outputs. The workflows are templates: inspect and test them in a protected branch before enabling production deployments.
