# Source inventory and implementation notes

The package was assembled from the uploaded application archive and the uploaded guide archive. Original application assets are preserved in `application/`. The 12 service guides and main master guide are retained in `reference-guides/`.

| Source | How used |
|---|---|
| Master `AWS DevOps Charlie Cafe Project.md` | Architecture, names, workflows, network/service relationships |
| `1. vpc.md` | VPC CIDR, 2 public + 2 private subnets, IGW, security intent |
| `2. ec2.md` | Amazon Linux 2023, t2.micro lab default, web server, EC2 role |
| `3. vpc endpoints.md` | Secrets Manager, SQS, Logs, DynamoDB, ECR API/DKR, S3 and SSM endpoints |
| `4. NAT.md` | Optional NAT gateway behavior |
| `5. RDS.md` | MySQL, private subnet group, cafedb, cafe_user, CafeDevDBSM |
| `6. DynamoDB.md` | Four tables and key schema; on-demand billing |
| `7. ALB.md` | internet-facing ALB, EC2 target, optional HTTPS |
| `8. CloudFront.md` | ALB origin, disabled cache, HTTPS viewer policy |
| `9. AWS Cognito.md` | SPA, groups, custom employee_id, authorization-code flow |
| `10. Lambda&API-GW.md` | 12 named Lambda functions and REST paths; 13th source file retained but not deployed pending confirmation of schema/handler mismatch |
| `11. SQS.md` | CafeOrdersQueue standard queue, 60s visibility, 4d retention |
| `12. ECS & ECR.md` | charlie-cafe ECR, Fargate task/service, CodeDeploy blue/green |

Differences were not silently hidden: docs conflict on DB name (`cafedb` vs `cafe_db`), and the guide has 12 Lambda rows while the code archive has 13 Python files. The implementation exposes DB name as a variable, uses `cafedb` by default because that is the RDS core setup value, and provisions all 13 code files as functions. Verify application expectations before production cutover.


## Minimal application adjustments in the packaged copy

To permit Phase 2 resources to coexist with Phase 1 using suffixed resource names, the packaged Lambda source reads Secrets Manager and DynamoDB names from environment variables (with the original Phase 1 names retained as fallbacks). The PHP health endpoint reads `DB_SECRET_NAME` from the Apache environment and no longer includes the old hard-coded DB password/host fallback. `terraform/scripts/configure-phase2-app.sh` generates frontend Cognito/API/CloudFront configuration from Terraform outputs. These are configuration adaptations, not business-logic redesigns.


## SQS integration discrepancy

The service guide describes an SQS worker flow, but the uploaded `CafeOrderWorkerLambda.py` reads `event.body` (API Gateway proxy format) and does not consume `event.Records`. The Terraform stack therefore provisions the standard queue and producer send permission but does not create an SQS event-source mapping. Creating that mapping without a consumer handler would cause processing failures.


## RDS order ID mismatch

The uploaded SQL schema declares `orders.order_id` as `INT AUTO_INCREMENT`, while the uploaded `CafeOrderProcessor.py` generates an `ORD-YYYYMMDD-XXXX` string and inserts it explicitly. This package preserves the supplied SQL and application logic rather than silently changing business behavior; resolve this mismatch before the first order test.
