# Charlie Cafe — Terraform Phase 2 (AWS us-east-1)

This is the complete Terraform implementation package based on the supplied **AWS DevOps Charlie Cafe Project.md**, the 12 service configuration guides, and the uploaded application repository. Application PHP/HTML/JS, Lambda source, Bash operations scripts, Docker assets, SQL scripts, the master guide, and all service guides are included. A small set of environment-variable configuration adaptations is documented in `SOURCE-INVENTORY.md`.

## Safety / deployment boundary

- **No AWS resources are created, imported, changed, or destroyed by generating this ZIP.**
- Your Phase 1 stack is treated as live and protected. Do not run `terraform apply` until the plan has been reviewed and you explicitly decide to deploy Phase 2.
- This is a parallel Phase 2 deployment, not an import/adoption of Phase 1. Resources with account/global unique names use a configurable `name_suffix` (default `-p2`) to avoid collisions.
- `terraform destroy` is intentionally guarded by a confirmation variable and is not called by any workflow.
- The configuration creates fresh resources. It does not migrate RDS contents or existing Cognito users. Database schema/data initialization, data migration, and identity migration are separate cutover tasks. The included `terraform/scripts/bootstrap-rds-schema.sh` is an explicit manual operation and must only be run against the new empty Phase 2 database.

## Architecture

`terraform/environments/dev` composes independent service modules: VPC (2 public + 2 private AZ subnets), security groups, optional single-AZ NAT, VPC endpoints, IAM, EC2, RDS + Secrets Manager, four DynamoDB tables, SQS, the 12 documented Lambda functions, REST API Gateway, Cognito, ECR, ECS Fargate, ALB with EC2 + blue/green target groups, CodeDeploy ECS blue/green, CloudFront, and CloudWatch alarms/log groups. ECS desired count is initially zero so an empty ECR repository does not cause failed task launches; push the first image, then raise desired count to one in the environment configuration.

Every AWS service has its own module directory. Each module splits resource concerns into separate `.tf` files (networking, endpoints, Lambda functions/layers/permissions, API resources/integrations, etc.).

## Requirements

- Terraform >= 1.11.0
- AWS CLI v2 authenticated to the intended account
- AWS account permissions for the services in this stack
- An S3 bucket for remote state (created in the separate bootstrap stack)
- For HTTPS ALB / Cognito Hosted UI, supply a validated ACM certificate ARN and your own callback/logout URLs/domain configuration. Certificate DNS validation is not automated because the domain's DNS provider/zone is not specified.

## First-time setup (safe sequence)

1. Review `reference-guides/` and `terraform/environments/dev/terraform.tfvars.example`. If adding this package to your existing GitHub project, run `bash terraform/scripts/sync-application-to-repo.sh` from the project root to copy the included app snapshot into the repository’s canonical `app/`, `infrastructure/`, and `docker/` folders; inspect `git diff`, then commit and push the merged package before creating EC2 so its bootstrap clone receives the Phase 2 scripts and application updates.
2. Set a unique `name_suffix` so Phase 2 resources can coexist with Phase 1. The default is `-p2`.
3. Set a strong database password via `TF_VAR_db_password` or a securely injected Terraform variable; do not commit it. No sample plaintext password is embedded.
4. Configure `terraform/bootstrap/terraform.tfvars` (bucket name must be globally unique), then run `terraform init`, `terraform plan`, and `terraform apply` **only for the bootstrap stack** to create encrypted/versioned remote-state storage. The bootstrap state starts locally; keep its `terraform.tfstate` backed up securely and never commit it.
5. Copy `backend.hcl.example` to `backend.hcl`, set the bucket, then run `terraform init -backend-config=backend.hcl`. Commit the generated `.terraform.lock.hcl` after initialization.
6. Run `bash terraform/scripts/package-lambda-layer.sh` (requires pip/network), then `terraform fmt -recursive`, `terraform validate`, and `terraform plan -out=phase2.tfplan`. Review every resource and confirm no Phase 1 resource is targeted.
7. Apply only after a separate explicit approval. The included GitHub Terraform workflow is manual-dispatch only; apply requires manual dispatch with `confirm_apply=true`.
8. Run `bash terraform/scripts/configure-phase2-app.sh`. Initialize the new RDS database explicitly by running `bash terraform/scripts/run-rds-bootstrap-via-ssm.sh`. This sends the included schema/data initialization script to the Phase 2 EC2 instance through SSM, so your repo must contain the Terraform package on the EC2 clone. It runs the supplied SQL, and `schema.sql` drops/recreates tables; use it only once against the empty Phase 2 DB. Then run `bash terraform/scripts/bootstrap-ecr-image.sh`.
9. Set `ecs_desired_count = 1` in `terraform/environments/dev/terraform.tfvars`, review a fresh plan, and apply it.
10. Add the required GitHub OIDC/deployment secrets, commit the generated frontend config and task definition, then run the application deployment workflow.

## Application integration / post-apply

- Terraform outputs include API URL, CloudFront URL, ALB DNS, EC2 instance ID, ECR URI, ECS cluster/service, Cognito IDs/domain, and RDS secret ARN. After apply, run `bash terraform/scripts/configure-phase2-app.sh` to write the generated API/Cognito/CloudFront values into the included frontend `config.js` and update `.github/task-definition.json` with the Terraform-created role ARNs, secret ARN, log group and task family.
- Lambda package archive includes the supplied Lambda Python files. Runtime is Python 3.12. Terraform provisions the 12 Lambda functions listed in the service guide. The 13th `CafeOrderProcessingLambda.py` source file is retained in the application snapshot but not provisioned: it is not listed in the guide and its `CafeMenu` key/attribute expectations (`item_name`/`base_cost`) differ from the documented table schema (`item`/`price`).
- The master/RDS guide and SQL files contain both `cafedb` and `cafe_db`. This package preserves both meanings: RDS initial database name defaults to `cafedb` (`rds_initial_db_name`), while the application secret `dbname` and ECS `DB_NAME` default to `cafe_db` (`db_name`), matching the supplied `schema.sql`, `data.sql`, and Lambda code. Run the supplied schema/data scripts only against the new empty Phase 2 database; `schema.sql` drops and recreates tables.
- DynamoDB table keys are based on service guide and source inspection: CafeMenu(item), CafeOrders(order_id), CafeOrderMetrics(metric), CafeAttendance(employee_id,date). CafeOrders and CafeAttendance schemas are grounded in the supplied Lambda and DynamoDB guide.
- The supplied RDS `schema.sql` declares `orders.order_id` as an auto-increment integer, while `CafeOrderProcessor.py` generates an `ORD-YYYYMMDD-XXXX` string and explicitly inserts it. Resolve this source-level schema/handler mismatch before testing order creation; Terraform intentionally does not rewrite the supplied business schema.
- The SQS queue has 60-second visibility timeout and 4-day retention. DLQ is omitted to match the guide. The supplied `CafeOrderProcessor` sends messages to SQS, but `CafeOrderWorkerLambda` expects an API Gateway `body` rather than SQS `Records`; therefore this package creates the queue and producer permission but deliberately does not attach an event-source mapping that would fail at runtime. Add a dedicated SQS consumer or adapt the handler after confirming the intended message-processing logic.
- ECS task definition uses Terraform-created roles and Secrets Manager references; it does not carry forward the old hard-coded account ID or plaintext DB password from the sample task definition.

## Existing Bash scripts

Terraform replaces AWS resource provisioning only. Existing Bash scripts remain available for LAMP bootstrap, RDS schema/data setup, Lambda layer packaging, ECR build/push, SSM deploy, verification, exports, and operations. Review each script before execution; `ec2-cleanup.sh` is destructive and is not invoked by Terraform or CI.

## Known manual inputs / limitations

- `db_password` is required and intentionally has no default.
- `alb_certificate_arn` is optional; without it, the ALB exposes HTTP:80 and CloudFront uses HTTP to the ALB origin. CloudFront’s default distribution domain provides HTTPS for the automatically configured Cognito callback/logout URLs. Add any custom callback/logout URLs as HTTPS values in the environment variables.
- CloudFront uses the ALB as origin and disables caching to support dynamic PHP/auth/API traffic, consistent with the guide.
- Cognito users/groups are provisioned as groups only. The example usernames/emails in the guide are not created because initial passwords and user ownership require a secure operational process.
- The original guide mentions IAM role/policy documents. The included application ZIP contains policy JSON; Terraform policies here use scoped generated ARNs where practical, but review them against your production least-privilege standard.
- The source guide describes both optional NAT and endpoint-only private networking. NAT is configurable (`enable_nat_gateway=false` by default); VPC endpoints are provisioned for the listed AWS services.
- No Terraform provider binary was available in the build environment, so this package is structurally reviewed but must be validated with Terraform >=1.11 in your environment before apply. The GitHub workflows use OIDC and require `DEPLOY_AWS_ROLE_ARN`, `TERRAFORM_AWS_ROLE_ARN`, and `TF_VAR_DB_PASSWORD` secrets plus the deployment identifiers (`EC2_INSTANCE_ID`, `ECR_REPO`, `ECS_CLUSTER`, `ECS_SERVICE`, `CODEDEPLOY_APPLICATION`, `CODEDEPLOY_DEPLOYMENT_GROUP`). Create/verify the GitHub OIDC provider and IAM trust policies for `awsrmmustansarjavaid/charlie-cafe-devops` before enabling the workflows. The PyMySQL layer must be packaged with the included script before Terraform validation/plan.

## Directory map

- `terraform/bootstrap`: isolated state bucket bootstrap.
- `terraform/environments/dev`: integrated Phase 2 root.
- `terraform/modules/*`: one module per AWS service.
- `terraform/scripts`: safe fmt/validate/plan/apply/destroy wrappers.
- .github/workflows: manual Terraform workflow and application deployment workflow template.
- `application/`: supplied app code, scripts, Docker assets, SQL and IAM policy references.
- `reference-guides/`: supplied service guides and master guide.
