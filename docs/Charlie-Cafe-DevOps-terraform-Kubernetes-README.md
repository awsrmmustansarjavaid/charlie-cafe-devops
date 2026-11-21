# ☕ Charlie Cafe DevOps Project

## End-to-End AWS, Terraform, CloudFormation, Docker, Kubernetes, and CI/CD Implementation

> **Project approach:** Preserve the existing AWS implementation, introduce Infrastructure as Code with Terraform first, learn CloudFormation through a separate implementation track, and deploy the same containerized application to local Kubernetes and Amazon EKS.

**Project:** Charlie Cafe DevOps  
**Repository:** `charlie-cafe-devops`  
**Primary cloud:** Amazon Web Services (AWS)  
**Primary IaC:** Terraform  
**Secondary IaC:** AWS CloudFormation  
**Container platform:** Docker  
**Orchestration platforms:** Amazon ECS and Kubernetes (local + Amazon EKS)  
**CI/CD:** GitHub Actions  
**Architecture style:** Cloud-native, event-driven, containerized, and serverless  
**AWS region used in the original lab guide:** `us-east-1` (configurable)

---

# 📚 Table of Contents

1. [Project Overview](#-project-overview)
2. [Business Requirements](#-business-requirements)
3. [Project Goals](#-project-goals)
4. [Implementation Status and Scope](#-implementation-status-and-scope)
5. [Existing AWS Architecture](#-existing-aws-architecture)
6. [Application and AWS Service Responsibilities](#-application-and-aws-service-responsibilities)
7. [Target DevOps Architecture](#-target-devops-architecture)
8. [Repository Architecture](#-repository-architecture)
9. [Technology Stack](#-technology-stack)
10. [Environment and Naming Strategy](#-environment-and-naming-strategy)
11. [AWS Network Configuration Baseline](#-aws-network-configuration-baseline)
12. [Security and IAM Standards](#-security-and-iam-standards)
13. [Terraform Implementation Blueprint](#-terraform-implementation-blueprint)
14. [Terraform State and Backend Configuration](#-terraform-state-and-backend-configuration)
15. [CloudFormation Implementation Blueprint](#-cloudformation-implementation-blueprint)
16. [Docker and Container Image Strategy](#-docker-and-container-image-strategy)
17. [Kubernetes Learning and Deployment Blueprint](#-kubernetes-learning-and-deployment-blueprint)
18. [Amazon EKS Architecture](#-amazon-eks-architecture)
19. [CI/CD and GitHub Actions](#-cicd-and-github-actions)
20. [Observability and Monitoring](#-observability-and-monitoring)
21. [Testing and Validation Strategy](#-testing-and-validation-strategy)
22. [Cost Management and Cleanup](#-cost-management-and-cleanup)
23. [Implementation Roadmap](#-implementation-roadmap)
24. [Getting Started](#-getting-started)
25. [Operational Runbooks](#-operational-runbooks)
26. [Project Completion Checklist](#-project-completion-checklist)
27. [Documentation and Contribution](#-documentation-and-contribution)

---

# ☕ Project Overview

Charlie Cafe is an end-to-end cloud-native café ordering platform designed as a practical DevOps learning and implementation project. The application supports online menu browsing and ordering, employee/admin operations, secure authentication, order processing, and order status tracking.

The original project guide documents an AWS implementation built from AWS Console configuration, application code, scripts, Docker, AWS managed services, and GitHub Actions. This repository will retain that implementation as the baseline and add repeatable infrastructure and deployment tracks.

The project will demonstrate how one application can be delivered using multiple infrastructure and orchestration approaches:

- **Manual AWS deployment:** the original hands-on AWS lab and configuration reference.
- **Terraform:** the primary Infrastructure as Code implementation for repeatable AWS environments.
- **CloudFormation:** a secondary AWS-native IaC implementation for learning and comparison.
- **Docker:** consistent application packaging.
- **Amazon ECS:** retain the existing ECS-based container deployment.
- **Kubernetes:** deploy the application locally first, then to Amazon EKS.
- **GitHub Actions:** automate validation, infrastructure plans, image builds, and deployments.
- **Observability:** collect logs, metrics, health information, and deployment signals.

## Project principles

1. Keep the existing working application and AWS deployment as the reference baseline.
2. Do not replace the original implementation while introducing new technologies.
3. Use Terraform as the primary source of truth for newly managed AWS infrastructure.
4. Keep CloudFormation in its own directory and avoid managing the same live resource with Terraform and CloudFormation at the same time.
5. Use Kubernetes for application workloads, not as a replacement for every AWS managed service.
6. Start Kubernetes on a local cluster before creating an EKS environment.
7. Make infrastructure changes reviewable through plans, pull requests, and approvals.
8. Keep secrets, private keys, state files, and credentials out of Git.
9. Design development environments to be inexpensive and easy to destroy.
10. Document every implementation track with prerequisites, commands, expected results, and cleanup steps.

---

# 🧾 Business Requirements

## Client

**Charlie Cafe**

## Functional requirements

- Online café menu and ordering experience.
- Secure customer login.
- Employee and administrator dashboard.
- Employee management capabilities.
- Order creation and order status tracking.
- Payment status tracking for cash/card workflows.
- Menu and order data management.
- Asynchronous order processing.
- Image/static asset delivery.

## Performance and availability requirements

- Support multiple orders at the same time.
- Keep customer-facing response times reasonable.
- Scale application tasks based on demand.
- Avoid exposing database services directly to the internet.
- Use health checks and service recovery.
- Support repeatable deployments and rollback procedures.

## Security requirements

- No public database access.
- Use Amazon Cognito for supported authentication flows.
- Store database credentials and application secrets in AWS Secrets Manager or an appropriate secret store.
- Use IAM roles and least-privilege policies.
- Restrict administrative access.
- Encrypt data in transit and at rest where supported.
- Keep credentials out of source code, Docker images, logs, and Terraform state wherever possible.
- Use GitHub Actions OIDC instead of long-lived AWS access keys.

---

# 🎯 Project Goals

## AWS and cloud engineering

- Understand VPCs, subnets, route tables, gateways, security groups, and VPC endpoints.
- Deploy and connect compute, storage, database, identity, and messaging services.
- Understand public/private application tiers.
- Build secure AWS service-to-service access.

## Infrastructure as Code

- Convert the documented AWS infrastructure into reusable Terraform modules.
- Separate development, staging, and production configuration.
- Store Terraform state remotely and securely.
- Run `fmt`, `validate`, and `plan` in CI.
- Require an explicit approval before production changes.
- Learn CloudFormation templates, parameters, outputs, stacks, and drift detection.

## Containers and orchestration

- Build and run application containers locally.
- Publish versioned images to Amazon ECR.
- Preserve the current ECS deployment path.
- Learn Kubernetes resources locally.
- Deploy the application to Amazon EKS after local validation.

## DevOps automation

- Implement CI/CD workflows using GitHub Actions.
- Use OIDC role assumption for AWS access.
- Scan dependencies and container images.
- Add deployment verification and rollback guidance.
- Introduce GitOps as a later enhancement.

---

# 📌 Implementation Status and Scope

This README defines the target repository architecture and implementation plan. It is not a claim that every new Terraform module, CloudFormation stack, Kubernetes manifest, or GitHub Actions workflow has already been created or deployed.

| Track | Status in this project plan | Purpose |
|---|---|---|
| Original AWS Console implementation | Existing baseline documented in the supplied project guide | Preserve the original lab and reference configuration |
| Docker / ECR / ECS | Existing architecture documented | Keep the current container deployment path |
| Terraform | First implementation track | Rebuild and manage AWS infrastructure as code |
| CloudFormation | Planned secondary track | Learn AWS-native IaC and compare approaches |
| Local Kubernetes | Planned | Learn and test Kubernetes without AWS cluster costs |
| Amazon EKS | Planned after local Kubernetes | Run Kubernetes workloads on AWS |
| GitHub Actions improvements | Existing CI/CD direction; workflows to be organized and hardened | Automate checks, plans, image publishing, and deployments |
| Monitoring and security automation | Planned enhancements | Improve reliability and operational visibility |

**Important migration rule:** Before importing or recreating an existing AWS resource, identify whether it is already managed manually or by another IaC tool. Do not create duplicate VPCs, databases, buckets, queues, or load balancers accidentally.

---

# 🏗️ Existing AWS Architecture

The original Charlie Cafe guide describes a cloud-native architecture using a combination of AWS managed services, serverless components, and containers.

## Existing architecture components

### Network foundation

- Amazon VPC.
- Public and private subnets.
- Route tables.
- Internet Gateway.
- Security groups.
- VPC endpoints for selected AWS services.
- Private placement for backend and data resources.

### Compute and application delivery

- Amazon EC2 for the original web/LAMP lab and administration/testing use cases.
- AWS Lambda for serverless backend functions.
- Amazon ECS for containerized application workloads.
- Amazon ECR for container image storage.
- Application Load Balancer for application ingress.
- Amazon CloudFront for content delivery.

### Data and messaging

- Amazon RDS for MySQL relational data.
- Amazon DynamoDB for application data and order/menu use cases.
- Amazon SQS for asynchronous order processing.
- Amazon S3 for application assets and object storage.

### Identity and secrets

- Amazon Cognito for authentication.
- AWS Secrets Manager for database/application secrets.
- AWS IAM roles and policies for service permissions.

### API and operations

- Amazon API Gateway for API entry points.
- Amazon CloudWatch Logs and monitoring.
- GitHub Actions for CI/CD automation.

## Existing high-level request flow

1. A customer opens the café application through the public application delivery layer.
2. Static content can be delivered through CloudFront and S3 where configured.
3. Containerized application services are packaged with Docker and stored in ECR.
4. ECS runs the container workloads; the ALB provides the application entry point.
5. API Gateway exposes configured backend API routes.
6. Lambda functions handle serverless application operations.
7. Cognito provides supported user authentication.
8. Application data is stored in RDS MySQL and/or DynamoDB according to the existing application component.
9. Order events can be sent to SQS for asynchronous processing.
10. Application services retrieve secrets from Secrets Manager using IAM roles.
11. CloudWatch receives configured application and service logs.

The exact routing between every frontend, API, Lambda, database, and queue must follow the application code and deployed AWS configuration. Do not assume that every service is connected to every other service simply because it exists in the architecture.

## Existing network baseline from the supplied guide

The original development network configuration uses:

| Resource | Name | Configuration |
|---|---|---|
| VPC | `CafeDevVPC` | `10.0.0.0/16` |
| Public subnet | `CafeDevPublicSubnet` | `10.0.1.0/24` |
| Private subnet 1 | `CafeDevPrivateSubnet1` | `10.0.2.0/24` |
| Private subnet 2 | `CafeDevPrivateSubnet2` | `10.0.3.0/24` |
| Region | — | `us-east-1` in the original lab guide |

The original guide also documents an Internet Gateway and public route to `0.0.0.0/0`. Private subnet routing and VPC endpoint configuration must be verified against the actual deployed environment before Terraform migration.

## Important network security correction

The original lab notes include broad example inbound rules in a default security group, including public SSH, MySQL, and all-TCP access. These are not suitable as production defaults.

For the IaC implementation:

- Do not open SSH (`22`) to `0.0.0.0/0`.
- Do not expose MySQL (`3306`) publicly.
- Do not use `ALL TCP` inbound rules as a general access pattern.
- Do not attach the default VPC security group to application resources as a shortcut.
- Permit application traffic only from the required upstream security group or trusted CIDR.
- Permit database port `3306` only from the specific application/Lambda security group that needs it.
- Prefer Systems Manager Session Manager over public SSH where practical.
- Keep RDS in private subnets and set public accessibility to disabled.

The Terraform implementation should use dedicated security groups for ALB, ECS tasks, Lambda, EKS nodes/pods where applicable, and RDS.

---

# 🧩 Application and AWS Service Responsibilities

| Component | Intended responsibility |
|---|---|
| CloudFront | Edge delivery and caching for supported frontend/static content |
| S3 | Static assets, uploads, and object storage |
| ALB | HTTP/HTTPS ingress to ECS or an appropriately configured Kubernetes ingress target |
| ECS | Existing container orchestration deployment |
| ECR | Container image registry |
| Lambda | Serverless backend functions and event handlers |
| API Gateway | Managed API entry point for configured Lambda/API integrations |
| Cognito | User authentication and identity |
| RDS MySQL | Relational application data |
| DynamoDB | Key-value/document access patterns used by application features |
| SQS | Decoupled asynchronous order processing |
| Secrets Manager | Database credentials and application secrets |
| IAM | Identity and permission boundaries for AWS resources |
| CloudWatch | Logs, metrics, alarms, and operational monitoring |
| VPC endpoints | Private connectivity to supported AWS services without requiring public internet egress for those service paths |
| Terraform | Provision and update AWS infrastructure |
| CloudFormation | Separate AWS-native infrastructure template track |
| Kubernetes | Schedule and operate application containers |
| GitHub Actions | Continuous integration and delivery automation |

**Architecture decision:** Kubernetes will manage containerized application workloads. Managed services such as RDS, DynamoDB, SQS, Lambda, API Gateway, Cognito, S3, and Secrets Manager remain AWS services unless there is a specific, justified reason to change that design.

---

# 🧭 Target DevOps Architecture

The project will have three complementary deployment paths.

## Path A — Existing ECS deployment

```text
Developer
   |
   v
GitHub Repository
   |
   v
GitHub Actions
   |
   +--> Test / Build
   |
   +--> Docker Build
   |
   +--> Push Image to Amazon ECR
   |
   v
Amazon ECS Service
   |
   v
Application Load Balancer
   |
   v
Charlie Cafe Application
```

This path preserves the existing ECS-based container platform.

## Path B — Terraform-managed AWS infrastructure

```text
Developer
   |
   v
GitHub Repository
   |
   v
Terraform Configuration
   |
   +--> fmt / validate
   |
   +--> terraform plan
   |
   +--> Review / Approval
   |
   v
AWS Provider
   |
   +--> VPC / Subnets / Routes / Endpoints
   +--> IAM / Security Groups
   +--> RDS / DynamoDB / SQS / S3
   +--> Lambda / API Gateway / Cognito
   +--> ECR / ECS / ALB / CloudFront
   +--> EKS (later phase)
```

Terraform becomes the primary infrastructure management path for resources migrated into its state.

## Path C — Kubernetes deployment

```text
Developer
   |
   v
GitHub Repository
   |
   v
Docker Build and Test
   |
   v
Container Registry
   |
   +--> Local Registry / Local Cluster
   |
   +--> Amazon ECR
             |
             v
       Amazon EKS
             |
             +--> Namespace
             +--> Deployment
             +--> Service
             +--> Ingress
             +--> ConfigMap
             +--> Secret integration
             +--> HPA (later)
```

Local Kubernetes is the learning and validation environment. EKS is the later AWS-hosted environment.

---

# 📁 Repository Architecture

## Repository strategy

**Decision: use the same existing GitHub repository.**

The existing application and AWS lab remain in the repository. New infrastructure and deployment technologies are added in dedicated top-level directories.

This prevents the project from becoming a collection of disconnected repositories and keeps application code, infrastructure definitions, deployment manifests, and documentation together.

## Proposed directory structure

```text
charlie-cafe-devops/
│
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── SECURITY.md
├── CHANGELOG.md
├── .gitignore
├── .editorconfig
├── Makefile
│
├── app/
│   ├── frontend/
│   │   ├── src/
│   │   ├── public/
│   │   ├── tests/
│   │   └── README.md
│   │
│   ├── backend/
│   │   ├── src/
│   │   ├── tests/
│   │   └── README.md
│   │
│   └── README.md
│
├── manual-deployment/
│   ├── network/
│   ├── iam/
│   ├── compute/
│   ├── database/
│   ├── serverless/
│   ├── containers/
│   ├── storage/
│   ├── scripts/
│   └── README.md
│
├── docker/
│   ├── frontend/
│   │   └── Dockerfile
│   ├── backend/
│   │   └── Dockerfile
│   ├── compose/
│   │   └── compose.yaml
│   ├── .dockerignore
│   └── README.md
│
├── terraform/
│   ├── versions.tf
│   ├── providers.tf
│   ├── locals.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── README.md
│   │
│   ├── modules/
│   │   ├── networking/
│   │   ├── security-groups/
│   │   ├── iam/
│   │   ├── vpc-endpoints/
│   │   ├── ec2/
│   │   ├── rds/
│   │   ├── dynamodb/
│   │   ├── s3/
│   │   ├── sqs/
│   │   ├── secrets-manager/
│   │   ├── cognito/
│   │   ├── lambda/
│   │   ├── api-gateway/
│   │   ├── ecr/
│   │   ├── ecs/
│   │   ├── alb/
│   │   ├── cloudfront/
│   │   └── eks/
│   │
│   ├── bootstrap/
│   │   ├── state-backend/
│   │   └── README.md
│   │
│   └── environments/
│       ├── dev/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── terraform.tfvars.example
│       │   └── backend.hcl.example
│       ├── staging/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── terraform.tfvars.example
│       └── production/
│           ├── main.tf
│           ├── variables.tf
│           └── terraform.tfvars.example
│
├── cloudformation/
│   ├── templates/
│   │   ├── networking.yaml
│   │   ├── security.yaml
│   │   ├── storage.yaml
│   │   ├── messaging.yaml
│   │   └── application.yaml
│   ├── parameters/
│   │   ├── dev.json
│   │   └── staging.json
│   ├── scripts/
│   └── README.md
│
├── kubernetes/
│   ├── base/
│   │   ├── namespace.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-service.yaml
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   └── kustomization.yaml
│   │
│   ├── overlays/
│   │   ├── local/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── production/
│   │
│   ├── ingress/
│   ├── config/
│   ├── policies/
│   ├── helm/
│   │   └── charlie-cafe/
│   ├── kind/
│   ├── minikube/
│   ├── eks/
│   └── README.md
│
├── scripts/
│   ├── setup/
│   ├── validate/
│   ├── deploy/
│   ├── cleanup/
│   └── README.md
│
├── .github/
│   ├── workflows/
│   │   ├── app-ci.yml
│   │   ├── docker-build.yml
│   │   ├── terraform-check.yml
│   │   ├── terraform-plan.yml
│   │   ├── terraform-apply.yml
│   │   ├── cloudformation-validate.yml
│   │   ├── ecs-deploy.yml
│   │   ├── kubernetes-local-check.yml
│   │   ├── eks-deploy.yml
│   │   └── security-scan.yml
│   └── dependabot.yml
│
└── docs/
    ├── architecture/
    │   ├── existing-aws-architecture.md
    │   ├── target-devops-architecture.md
    │   ├── network-architecture.md
    │   └── application-data-flow.md
    │
    ├── decisions/
    │   ├── 0001-repository-strategy.md
    │   ├── 0002-terraform-primary-iac.md
    │   ├── 0003-ecs-and-eks-coexistence.md
    │   └── 0004-managed-aws-services.md
    │
    ├── runbooks/
    ├── security/
    ├── terraform/
    ├── cloudformation/
    ├── docker/
    ├── kubernetes/
    └── troubleshooting/
```

## Directory responsibilities

### `app/`

Contains the actual Charlie Cafe application source code. Infrastructure changes must not unnecessarily restructure or rewrite application functionality.

### `manual-deployment/`

Stores the original AWS Console procedure, reference scripts, and manual lab documentation. This is the learning baseline and comparison reference.

### `docker/`

Contains Dockerfiles, Compose configuration for local development, and container build documentation.

### `terraform/`

Contains reusable Terraform modules, environment compositions, provider configuration, outputs, and backend bootstrap configuration.

### `cloudformation/`

Contains independent CloudFormation templates and parameter files. A CloudFormation stack must not attempt to own a resource already managed by Terraform.

### `kubernetes/`

Contains Kubernetes base manifests, environment overlays, Helm chart, local cluster configuration, and EKS-specific configuration.

### `.github/workflows/`

Contains independent CI/CD workflows. Application validation, Terraform validation, infrastructure deployment, and container deployment should not be mixed into one unreviewable workflow.

### `docs/`

Contains architecture diagrams, design decisions, operational runbooks, security documentation, and technology-specific guides.

## Repository architecture rules

- Keep reusable Terraform code inside `terraform/modules/`.
- Keep environment-specific values inside `terraform/environments/`.
- Do not commit real `.tfvars`, credentials, kubeconfig files, state files, or generated plans.
- Keep Kubernetes base manifests environment-neutral.
- Put environment-specific image tags, replica counts, and ingress configuration in overlays.
- Keep CloudFormation templates independent from Terraform modules.
- Keep the original manual guide available; do not delete it during migration.
- Add a README to each major technology directory with prerequisites, setup, deployment, validation, and cleanup instructions.

---

# 🧰 Technology Stack

| Area | Technology | Usage |
|---|---|---|
| Cloud | AWS | Hosting and managed infrastructure |
| IaC primary | Terraform | Reusable and repeatable AWS provisioning |
| IaC secondary | CloudFormation | AWS-native template learning track |
| Containers | Docker | Build application images |
| Local orchestration | Kind or Minikube | Kubernetes learning and testing |
| AWS orchestration | Amazon EKS | Managed Kubernetes |
| Existing orchestration | Amazon ECS | Preserve existing ECS deployment |
| Registry | Amazon ECR | Store application images |
| CI/CD | GitHub Actions | Build, test, validate, and deploy |
| Application ingress | ALB / Kubernetes ingress | Route external application traffic |
| Monitoring | CloudWatch | AWS logs, metrics, and alarms |
| Kubernetes monitoring | Prometheus and Grafana (later phase) | Cluster and workload visibility |
| GitOps (later phase) | Argo CD | Declarative Kubernetes delivery |
| Security scanning | Trivy and dependency scanners | Image and dependency scanning |

Pin tool and provider versions in project configuration. Upgrade versions intentionally through pull requests and validation.

---

# 🌍 Environment and Naming Strategy

## Environments

- `dev`: daily development, experiments, and initial Terraform migration.
- `staging`: pre-production validation with production-like configuration.
- `production`: controlled deployment with approvals, backups, and stricter policies.

Do not create all three environments at the beginning. Start with `dev`, validate the architecture, and add staging/production only after the deployment and cleanup process is reliable.

## Naming convention

Use a consistent naming pattern:

```text
charlie-cafe-<environment>-<service>-<resource>
```

Examples:

```text
charlie-cafe-dev-vpc
charlie-cafe-dev-rds
charlie-cafe-dev-orders-queue
charlie-cafe-dev-frontend
charlie-cafe-dev-eks
```

AWS resource naming constraints vary by service. Terraform should generate names that comply with each service's length and character restrictions.

## Terraform tags

Apply common tags to supported resources:

```hcl
common_tags = {
  Project     = "CharlieCafe"
  Environment = var.environment
  ManagedBy   = "Terraform"
  Owner       = "CharlieCafeDevOps"
}
```

---

# 🌐 AWS Network Configuration Baseline

The original lab's network values are the starting reference. They must be checked against the live AWS account before importing or creating resources.

## Development VPC

```text
VPC Name: CafeDevVPC
CIDR:     10.0.0.0/16
Region:   us-east-1 (original lab default)
```

## Subnets

```text
Public subnet:
  Name: CafeDevPublicSubnet
  CIDR: 10.0.1.0/24

Private subnet 1:
  Name: CafeDevPrivateSubnet1
  CIDR: 10.0.2.0/24

Private subnet 2:
  Name: CafeDevPrivateSubnet2
  CIDR: 10.0.3.0/24
```

For production-grade multi-AZ resources, use private subnets in at least two Availability Zones. Confirm subnet/AZ mapping in the target region instead of hardcoding assumptions that may not apply to every account.

## Routing model

```text
Internet
   |
   v
Internet Gateway
   |
   v
Public Route Table
   |
   +--> Public subnet / internet-facing ALB

Private Route Table(s)
   |
   +--> Private application subnets
   +--> Private data subnets
   +--> VPC endpoints where required
```

The original guide documents VPC endpoints for services including Secrets Manager, SQS, CloudWatch Logs, DynamoDB, ECR API/registry, and S3. Endpoint type, subnet placement, endpoint policies, DNS settings, and security group rules must be verified for each service.

A VPC endpoint can provide private access to supported AWS services; it does not automatically provide general internet access to every destination. If private workloads need external package downloads or third-party APIs, explicitly design the required egress path.

## Security group model

| Security group | Attach to | Inbound policy |
|---|---|---|
| `charlie-cafe-dev-alb-sg` | Public ALB | HTTPS from approved public sources; HTTP only if redirecting to HTTPS |
| `charlie-cafe-dev-ecs-sg` | ECS tasks | Application port only from ALB security group |
| `charlie-cafe-dev-lambda-sg` | VPC-attached Lambda | No inbound rules required for ordinary Lambda invocation |
| `charlie-cafe-dev-rds-sg` | RDS | MySQL `3306` only from authorized application security groups |
| `charlie-cafe-dev-eks-node-sg` | EKS worker nodes | Only required cluster/node/application traffic |
| `charlie-cafe-dev-endpoint-sg` | Interface VPC endpoints | HTTPS `443` from authorized VPC workloads |

Security groups are stateful. Design both ingress and egress deliberately. Do not add SSH, MySQL, or all-TCP inbound rules to a general-purpose default group.

---

# 🔐 Security and IAM Standards

## IAM role separation

Create separate roles for separate workloads and deployment responsibilities:

- EC2 instance role, only if EC2 requires AWS API access.
- Lambda execution role per function or function group.
- ECS task execution role.
- ECS task role for application permissions.
- GitHub Actions deployment role assumed through OIDC.
- EKS cluster role.
- EKS node group role.
- Kubernetes workload roles using EKS Pod Identity or IAM Roles for Service Accounts where appropriate.

Do not use one broad policy for every workload.

## Least privilege

- Scope actions to the required AWS services.
- Scope resources to specific ARNs whenever supported.
- Avoid `Action: "*"` and broad service wildcards in application roles.
- Restrict `iam:PassRole` to exact role ARNs and required services.
- Separate read-only access from deployment permissions.
- Review permissions before production deployment.

The original guide includes broad example policies and account-specific ARNs. Treat those as historical lab material, not production-ready policy templates. Rebuild permissions from the actual Lambda, ECS, and CI/CD operations.

## Secrets

- Do not store database passwords in source code.
- Do not commit `.env` files containing real credentials.
- Do not bake secrets into Docker images.
- Do not output secrets in Terraform outputs or CI logs.
- Use AWS Secrets Manager or an approved secret-management mechanism.
- Use Kubernetes Secrets only with appropriate encryption, access control, and preferably an external secret integration for AWS-hosted workloads.

## GitHub Actions AWS authentication

Use GitHub OIDC federation to assume a dedicated AWS IAM role. Avoid long-lived IAM user access keys in GitHub repository secrets.

Restrict the role trust policy to the intended GitHub organization/repository and branch or deployment environment.

## Terraform state security

Terraform state may contain sensitive resource attributes. Treat it as confidential:

- Use a private S3 bucket.
- Enable bucket versioning.
- Enable server-side encryption.
- Block public access.
- Restrict access with IAM.
- Use state locking.
- Never commit state files or plan files to Git.
- Do not expose state through public artifacts.

---

# 🏗️ Terraform Implementation Blueprint

Terraform is the **first implementation track** and the primary IaC system for this repository.

## Terraform objectives

- Recreate the existing AWS architecture in a controlled development environment.
- Convert repeated resource definitions into reusable modules.
- Separate reusable infrastructure logic from environment-specific values.
- Use remote state and state locking.
- Validate all changes before applying.
- Migrate existing resources safely rather than duplicating them.

## Terraform module design

Each module should have a consistent structure:

```text
module-name/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md
```

### Module responsibilities

| Module | Resources / responsibility |
|---|---|
| `networking` | VPC, subnets, route tables, Internet Gateway, NAT only if required |
| `security-groups` | ALB, ECS, Lambda, RDS, endpoint, and EKS security groups |
| `iam` | Workload roles and scoped policies |
| `vpc-endpoints` | Gateway and interface endpoints |
| `ec2` | Optional EC2 lab/admin host |
| `rds` | DB subnet group, RDS instance, parameter/option configuration as required |
| `dynamodb` | Tables, indexes, TTL, point-in-time recovery options |
| `s3` | Buckets, encryption, versioning, public access blocks, lifecycle |
| `sqs` | Queues, dead-letter queue, redrive policy, encryption |
| `secrets-manager` | Secret metadata and access policies; secret values supplied securely |
| `cognito` | User pool, app client, and supported identity configuration |
| `lambda` | Functions, execution roles, log groups, event sources |
| `api-gateway` | API resources/routes, integrations, stages, permissions |
| `ecr` | Repositories, lifecycle policies, image scanning configuration |
| `ecs` | Cluster, task definitions, services, capacity configuration |
| `alb` | Load balancer, listeners, target groups, health checks |
| `cloudfront` | Distribution and origins for configured frontend delivery |
| `eks` | EKS cluster, node groups, access configuration, add-ons |

Keep modules focused. Do not create a single enormous module that provisions the entire platform.

## Recommended Terraform implementation order

### Phase 1 — Tooling and project skeleton

Install and verify:

- Terraform CLI.
- AWS CLI.
- Git.
- An editor with Terraform support.
- Docker.
- `kubectl` later in the Kubernetes phase.

Verify:

```bash
terraform version
aws --version
git --version
docker --version
```

Configure AWS credentials using a supported profile or role-based authentication. Do not paste credentials into `.tf` files.

### Phase 2 — AWS account and region verification

```bash
aws sts get-caller-identity
aws configure list
aws ec2 describe-availability-zones --region us-east-1
```

Confirm the account and region before any plan or apply operation.

### Phase 3 — Terraform bootstrap

Create a dedicated state bucket and configure versioning, encryption, public access blocking, and state locking. Bootstrap resources should be managed carefully because they are required by the rest of the Terraform deployment.

### Phase 4 — Network module

Implement in this order:

1. VPC.
2. Public subnet(s).
3. Private application subnet(s).
4. Private data subnet(s), if separated.
5. Internet Gateway.
6. Route tables and associations.
7. NAT or VPC endpoints based on the actual egress requirements.
8. Security groups.
9. Outputs for VPC and subnet IDs.

Validate CIDR ranges and avoid overlap with existing networks.

### Phase 5 — IAM and security foundation

Create the minimum roles required for the next service being migrated. Do not provision broad access policies just to make deployment succeed.

### Phase 6 — Data and messaging services

Migrate one service at a time:

1. S3 buckets.
2. DynamoDB tables and indexes.
3. SQS queue and dead-letter queue.
4. Secrets Manager secret metadata and policies.
5. RDS subnet group, security group, and database configuration.

For databases, confirm backups, retention, encryption, deletion protection, and migration/data preservation requirements before applying changes.

### Phase 7 — Serverless services

Implement:

1. Lambda execution roles.
2. CloudWatch log groups and retention.
3. Lambda functions and environment configuration.
4. Event source mappings and permissions.
5. API Gateway integrations and routes.
6. Cognito configuration where required by the application.

### Phase 8 — Container infrastructure

Implement:

1. ECR repositories.
2. ECS cluster.
3. ECS task execution role and task role.
4. Task definitions.
5. ALB and target groups.
6. ECS service and health checks.
7. CloudFront configuration if required by the existing frontend design.

### Phase 9 — EKS foundation

Do this only after Terraform fundamentals and the existing AWS environment are stable. EKS is a separate environment and should not be created simply to replace ECS before the Kubernetes workload has been tested locally.

## Terraform environment composition

The `terraform/environments/dev/` directory should compose modules:

```hcl
module "networking" {
  source      = "../../modules/networking"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}
```

This is a structural example. Module inputs and outputs must be defined in the actual module before running Terraform.

Use `terraform.tfvars.example` as a safe template. Keep actual account-specific values and sensitive inputs outside version control.

## Terraform workflow

Run commands from the relevant environment directory:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

Review the plan carefully. Apply only after confirming the intended account, region, resources, and change set:

```bash
terraform apply
```

For destructive changes, stop and investigate. Do not use `-auto-approve` as the default workflow.

## Existing resource migration

There are two valid strategies:

1. **Rebuild in a separate development environment:** safest for initial learning and validation.
2. **Import existing resources into Terraform:** appropriate only after inventorying the live resource, writing matching configuration, and preparing a state backup and import plan.

Do not create a Terraform resource block for an existing resource and apply it as if the resource did not exist. Use Terraform import workflows and verify that the resulting plan does not replace or destroy the resource.

---

# 🗄️ Terraform State and Backend Configuration

Use a remote S3 backend for shared environments.

## Backend requirements

- Dedicated S3 bucket.
- Bucket versioning enabled.
- Server-side encryption.
- Block public access.
- IAM access restricted to the required operators and CI role.
- State locking enabled.
- Separate state keys for separate environments and independently managed stacks.

Example backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket       = "REPLACE_WITH_TERRAFORM_STATE_BUCKET"
    key          = "charlie-cafe/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

The bucket must exist before this backend can initialize. Create it through a separate bootstrap procedure and protect it from accidental deletion.

Do not commit real backend configuration containing account-specific infrastructure details if the repository policy treats those values as private. A `backend.hcl.example` file may be committed as a template.

---

# ☁️ CloudFormation Implementation Blueprint

CloudFormation is the **secondary IaC track**.

The objective is to understand AWS-native infrastructure templates and compare their lifecycle with Terraform. It is not necessary to duplicate every Terraform module in CloudFormation.

## Suggested CloudFormation scope

Start with small, independent stacks:

1. Networking stack for a learning environment.
2. Security group stack.
3. S3 storage stack.
4. SQS messaging stack.
5. A small application-support stack.

Only create CloudFormation resources in a separate test environment or for resources that CloudFormation explicitly owns.

## CloudFormation template concepts

Learn and document:

- `AWSTemplateFormatVersion`
- `Description`
- `Parameters`
- `Mappings`
- `Conditions`
- `Resources`
- `Outputs`
- Intrinsic functions such as `Ref`, `GetAtt`, `Sub`, and `If`
- Stack updates and rollback
- Change sets
- Drift detection

## Validation workflow

Use the AWS CLI to validate a template:

```bash
aws cloudformation validate-template \
  --template-body file://cloudformation/templates/networking.yaml
```

Review change sets before executing stack updates. Document stack outputs and cleanup procedures.

---

# 🐳 Docker and Container Image Strategy

Docker packages the Charlie Cafe application consistently for local development, ECS, and Kubernetes.

## Container objectives

- Build frontend and backend images from maintained Dockerfiles.
- Use `.dockerignore`.
- Use supported base images and pin versions.
- Run as a non-root user where practical.
- Avoid embedding credentials in images.
- Keep image sizes reasonable.
- Tag images with immutable commit identifiers in CI.
- Scan images before deployment.

## Local development

A Compose file can provide a repeatable local application environment. It should use development-only configuration and must not contain production credentials.

Example commands:

```bash
docker compose -f docker/compose/compose.yaml config
docker compose -f docker/compose/compose.yaml build
docker compose -f docker/compose/compose.yaml up -d
docker compose -f docker/compose/compose.yaml ps
docker compose -f docker/compose/compose.yaml logs -f
docker compose -f docker/compose/compose.yaml down
```

The actual service names, ports, health checks, and environment variables must match the application.

## ECR image publishing

The CI workflow should:

1. Run application tests.
2. Build the image.
3. Scan the image.
4. Authenticate to AWS using OIDC.
5. Push a commit-specific tag to ECR.
6. Record the image digest.
7. Deploy that exact image digest to ECS or EKS.

Avoid using only the mutable `latest` tag for release deployments.

---

# ☸️ Kubernetes Learning and Deployment Blueprint

The Kubernetes target is **both local Kubernetes and Amazon EKS**.

## Stage 1 — Local cluster

Choose one local cluster tool initially:

- Kind, or
- Minikube.

Do not try to learn both at the same time. Use the selected tool to deploy the Charlie Cafe application locally.

## Stage 2 — Kubernetes fundamentals

Learn and implement:

1. Cluster and node concepts.
2. Namespaces.
3. Pods.
4. Deployments.
5. ReplicaSets.
6. Services.
7. ConfigMaps.
8. Secrets.
9. Liveness and readiness probes.
10. Resource requests and limits.
11. PersistentVolumes and PersistentVolumeClaims where stateful storage is actually needed.
12. Ingress.
13. NetworkPolicies.
14. Horizontal Pod Autoscaler.

## Stage 3 — Initial application manifests

Create manifests for:

- Namespace.
- Frontend Deployment.
- Frontend Service.
- Backend Deployment.
- Backend Service.
- ConfigMaps for non-sensitive configuration.
- Secret integration for sensitive values.
- Ingress for local access.
- Resource requests/limits and health probes.

Use the application's real container ports and health endpoints. Do not invent ports or endpoints without checking the source code.

## Stage 4 — Environment management

Use Kustomize overlays or Helm values to manage differences between local, development, staging, and production.

Examples of environment-specific values:

- Image tag or digest.
- Replica count.
- Resource limits.
- Ingress hostname.
- Application environment variables.
- Secret references.
- Autoscaling thresholds.

## Stage 5 — Helm

Package the application into a Helm chart after the basic manifests work. Document:

```bash
helm lint kubernetes/helm/charlie-cafe
helm template charlie-cafe kubernetes/helm/charlie-cafe
```

## Stage 6 — Local validation

Typical commands:

```bash
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
kubectl apply -k kubernetes/overlays/local
kubectl get deployments -n charlie-cafe
kubectl get pods -n charlie-cafe
kubectl get services -n charlie-cafe
kubectl describe pods -n charlie-cafe
kubectl logs -n charlie-cafe deployment/charlie-cafe-backend
```

Use the namespace and deployment names defined in the manifests.

---

# ☸️ Amazon EKS Architecture

EKS is the later AWS Kubernetes phase.

## EKS responsibilities

- Terraform provisions the EKS cluster and supporting AWS infrastructure.
- ECR stores the container images.
- Kubernetes manifests or Helm deploy application workloads.
- AWS Load Balancer Controller can provision and manage ALB ingress resources when configured.
- IAM workload identity provides controlled access to AWS APIs.
- CloudWatch or an approved observability stack collects logs and metrics.

## EKS high-level layout

```text
Internet
   |
   v
Application Load Balancer
   |
   v
Kubernetes Ingress
   |
   v
Kubernetes Service
   |
   v
Frontend / Backend Pods
   |
   +--> RDS MySQL (private)
   +--> DynamoDB
   +--> SQS
   +--> Secrets Manager
   +--> S3
```

The exact network and service integration must be designed and tested. Do not expose database endpoints publicly.

## EKS implementation sequence

1. Confirm local Kubernetes deployment works.
2. Create a dedicated EKS development environment.
3. Provision cluster networking and IAM using Terraform.
4. Configure cluster access and `kubectl`.
5. Install required EKS add-ons.
6. Configure ECR image pull access.
7. Install and configure AWS Load Balancer Controller if ALB ingress is required.
8. Deploy the Charlie Cafe namespace and workloads.
9. Integrate AWS services with workload identity.
10. Add resource requests/limits, probes, autoscaling, and disruption controls.
11. Configure logs, metrics, and alarms.
12. Test upgrades and rollback.
13. Document cleanup and cost controls.

## ECS and EKS coexistence

ECS and EKS are both valid container orchestration options. This project keeps ECS as the existing AWS-native deployment path and adds EKS as a Kubernetes learning and deployment path.

They should not both serve production traffic by default. Use separate development environments or a deliberate migration plan to avoid unnecessary cost and operational duplication.

---

# 🔁 CI/CD and GitHub Actions

Organize workflows by responsibility.

## Proposed workflows

| Workflow | Responsibility |
|---|---|
| `app-ci.yml` | Lint and test application code |
| `docker-build.yml` | Build and scan Docker images |
| `terraform-check.yml` | Terraform formatting and validation |
| `terraform-plan.yml` | Generate and publish reviewed plan output |
| `terraform-apply.yml` | Apply approved infrastructure changes |
| `cloudformation-validate.yml` | Validate CloudFormation templates |
| `ecs-deploy.yml` | Deploy a new image to ECS |
| `kubernetes-local-check.yml` | Validate Kubernetes manifests |
| `eks-deploy.yml` | Deploy approved images/manifests to EKS |
| `security-scan.yml` | Run dependency, IaC, and image security checks |

## Terraform CI sequence

```text
Pull Request
   |
   v
terraform fmt -check
   |
   v
terraform init
   |
   v
terraform validate
   |
   v
terraform plan
   |
   v
Review plan
   |
   v
Approval
   |
   v
terraform apply
```

Use GitHub Environments and required reviewers for sensitive deployment environments.

## AWS authentication

Configure GitHub OIDC federation and a dedicated deployment role. Restrict the role to the intended repository, branch, and environment. Do not use permanent AWS access keys as the normal deployment method.

## Deployment safety

- Never run production apply automatically on every push.
- Keep Terraform plan and apply associated with the same reviewed commit and state.
- Restrict workflow permissions to the minimum required.
- Protect the default branch.
- Use concurrency controls to prevent simultaneous applies to the same state.
- Store deployment artifacts without exposing secrets.
- Record image digest and deployment version.

---

# 📈 Observability and Monitoring

## AWS monitoring

Use CloudWatch for:

- Lambda logs and errors.
- ECS service/task logs and metrics.
- ALB request count, target health, and latency.
- RDS CPU, storage, connections, and health.
- SQS queue depth and message age.
- API Gateway errors and latency.
- Application-specific metrics where instrumented.

Create alarms for meaningful operational conditions. Avoid creating noisy alarms without an action plan.

## Kubernetes monitoring

Start with:

- `kubectl` health inspection.
- Container logs.
- Kubernetes events.
- Readiness and liveness probes.
- Resource usage and capacity.

Later add:

- Prometheus.
- Grafana.
- Alertmanager.
- Centralized log collection.
- Distributed tracing if the application architecture supports it.

---

# 🧪 Testing and Validation Strategy

## Application tests

- Unit tests.
- Integration tests.
- API tests.
- Authentication flow tests.
- Order creation and order status tests.
- Database connectivity tests.
- Error handling and retry tests.

## Infrastructure tests

- Terraform formatting and validation.
- Terraform plan review.
- CloudFormation template validation.
- Security group and IAM review.
- Network reachability checks.
- Backup and recovery checks.
- Drift checks where applicable.

## Container tests

- Docker build succeeds.
- Container starts successfully.
- Health endpoint responds.
- Image scan is reviewed.
- Container runs with the intended permissions.

## Kubernetes tests

- Manifest rendering succeeds.
- Pods become Ready.
- Services resolve.
- Ingress routes correctly.
- Configuration and secrets are mounted or referenced correctly.
- Rolling update and rollback are tested.

---

# 💰 Cost Management and Cleanup

AWS services such as NAT Gateways, RDS, ALB, EKS, and continuously running compute can create ongoing charges.

## Cost controls

- Start with one development environment.
- Use small, suitable development resource sizes.
- Avoid creating EKS until local Kubernetes is working.
- Stop or destroy temporary resources after testing.
- Review NAT Gateway and VPC endpoint costs before choosing an egress design.
- Set budgets and billing alerts.
- Use lifecycle policies for old container images and object data.
- Configure log retention.
- Review unused load balancers, addresses, volumes, snapshots, and endpoints.

## Cleanup rules

Before deleting infrastructure:

1. Confirm the target AWS account and region.
2. Confirm the environment is not serving users.
3. Back up data that must be retained.
4. Check dependencies and deletion protection.
5. Review the Terraform destroy plan or CloudFormation deletion impact.
6. Remove resources in the correct dependency order.
7. Verify that billable resources have been removed.

Never run `terraform destroy` against a shared or production environment as a routine cleanup shortcut.

---

# 🗺️ Implementation Roadmap

## Phase 0 — Repository preparation

- [ ] Preserve the original README and manual deployment notes.
- [ ] Create the agreed top-level directory structure.
- [ ] Add `.gitignore`, `SECURITY.md`, and contribution guidance.
- [ ] Inventory existing AWS resources.
- [ ] Record current account, region, resource IDs, and dependencies securely.
- [ ] Create architecture and data-flow diagrams.
- [ ] Identify any resources that must not be replaced or deleted.

**Deliverable:** clean repository structure and verified current-state inventory.

## Phase 1 — Terraform foundations

- [ ] Install Terraform and AWS CLI.
- [ ] Configure secure AWS authentication.
- [ ] Create Terraform bootstrap state resources.
- [ ] Configure S3 backend and locking.
- [ ] Add provider/version constraints.
- [ ] Build the first VPC module.
- [ ] Validate and plan the development network.

**Deliverable:** reproducible Terraform-managed development network.

## Phase 2 — Terraform AWS services

- [ ] Security groups and IAM roles.
- [ ] VPC endpoints and routing.
- [ ] S3 and DynamoDB.
- [ ] SQS and dead-letter queue.
- [ ] Secrets Manager.
- [ ] RDS.
- [ ] Lambda and API Gateway.
- [ ] Cognito.
- [ ] ECR, ECS, ALB, and CloudFront as required.

**Deliverable:** application infrastructure represented in Terraform and validated in development.

## Phase 3 — Terraform CI/CD

- [ ] GitHub OIDC trust.
- [ ] Terraform formatting and validation workflow.
- [ ] Terraform plan workflow.
- [ ] Approval-gated apply workflow.
- [ ] Environment protection and concurrency.
- [ ] Security scanning.

**Deliverable:** controlled infrastructure delivery pipeline.

## Phase 4 — CloudFormation learning track

- [ ] Create a small networking or storage template.
- [ ] Validate template.
- [ ] Deploy to a separate learning stack.
- [ ] Review change sets.
- [ ] Test drift detection.
- [ ] Document Terraform vs CloudFormation differences.

**Deliverable:** independent CloudFormation learning implementation.

## Phase 5 — Docker standardization

- [ ] Review frontend/backend Dockerfiles.
- [ ] Add local Compose configuration.
- [ ] Build and test images.
- [ ] Add image scanning.
- [ ] Publish immutable image tags to ECR.
- [ ] Keep ECS deployment working.

**Deliverable:** reproducible container build and ECS release.

## Phase 6 — Local Kubernetes

- [ ] Install Kind or Minikube.
- [ ] Deploy namespace and workloads.
- [ ] Add Services and Ingress.
- [ ] Add ConfigMaps and secure secret references.
- [ ] Add probes and resource limits.
- [ ] Add Kustomize overlays or Helm.
- [ ] Test rollout and rollback.

**Deliverable:** working local Kubernetes deployment.

## Phase 7 — Amazon EKS

- [ ] Provision EKS through Terraform.
- [ ] Configure cluster access and add-ons.
- [ ] Connect ECR.
- [ ] Configure ingress.
- [ ] Deploy the application.
- [ ] Integrate AWS services securely.
- [ ] Configure monitoring and autoscaling.
- [ ] Test upgrades and cleanup.

**Deliverable:** working Charlie Cafe development deployment on EKS.

## Phase 8 — Advanced DevOps

- [ ] GitOps with Argo CD.
- [ ] Prometheus and Grafana.
- [ ] Centralized logs and alerting.
- [ ] Policy-as-code.
- [ ] Automated image and dependency scanning.
- [ ] Blue/green or canary deployment experiments.
- [ ] Disaster recovery and restore exercises.

**Deliverable:** advanced, observable, secure, and repeatable DevOps platform.

---

# 🚀 Getting Started

## 1. Clone the repository

```bash
git clone https://github.com/awsrmmustansarjavaid/charlie-cafe-devops.git
cd charlie-cafe-devops
```

## 2. Review the project structure

```bash
ls
```

Review the application, manual deployment documentation, and architecture diagrams before changing infrastructure.

## 3. Verify local tools

```bash
git --version
docker --version
aws --version
terraform version
```

Kubernetes tools such as `kubectl`, Kind/Minikube, and Helm are required only when starting the Kubernetes phases.

## 4. Verify AWS identity

```bash
aws sts get-caller-identity
```

Confirm the AWS account and region before running any provisioning command.

## 5. Start with Terraform development

Follow the instructions in:

```text
terraform/README.md
terraform/bootstrap/README.md
terraform/environments/dev/
```

Do not run Terraform against an existing production account until the resource inventory, backend, state strategy, and migration plan have been reviewed.

---

# 🛠️ Operational Runbooks

Every major infrastructure component should eventually have a runbook that includes:

1. Purpose and architecture.
2. Prerequisites and required permissions.
3. Configuration values.
4. Deployment commands.
5. Validation commands.
6. Expected healthy state.
7. Common failures and troubleshooting.
8. Rollback procedure.
9. Cleanup procedure.
10. Cost and security considerations.

Suggested runbooks:

- VPC and subnet deployment.
- Security group review.
- Terraform state recovery.
- RDS backup and restore.
- Lambda troubleshooting.
- SQS dead-letter queue processing.
- ECS deployment rollback.
- EKS cluster access.
- Kubernetes workload rollback.
- Secret rotation.
- GitHub Actions OIDC troubleshooting.

---

# ✅ Project Completion Checklist

## Repository

- [ ] Existing application and manual documentation preserved.
- [ ] New directories created with clear ownership.
- [ ] README files added to technology directories.
- [ ] Architecture diagrams updated.
- [ ] No credentials or generated state committed.

## Terraform

- [ ] Provider versions pinned.
- [ ] Remote state configured.
- [ ] State locking enabled.
- [ ] Modules documented.
- [ ] Dev environment validated.
- [ ] Plans reviewed before apply.
- [ ] Existing resource migration tested safely.

## CloudFormation

- [ ] Templates validated.
- [ ] Stacks deployed in a separate learning scope.
- [ ] Change sets reviewed.
- [ ] Drift detection documented.

## Docker and ECS

- [ ] Images build reproducibly.
- [ ] Images scanned.
- [ ] ECR publishing works.
- [ ] ECS deployment and rollback verified.

## Kubernetes and EKS

- [ ] Local cluster deployment works.
- [ ] Probes and resource limits configured.
- [ ] Environment overlays or Helm chart work.
- [ ] EKS provisioned through Terraform.
- [ ] ECR image deployment works.
- [ ] Ingress, AWS access, and monitoring verified.

## CI/CD and security

- [ ] GitHub OIDC configured.
- [ ] No long-lived AWS keys required for routine workflows.
- [ ] Pull request checks work.
- [ ] Production apply is approval-gated.
- [ ] IAM and security groups reviewed.
- [ ] Logs and alerts configured.

---

# 📖 Documentation and Contribution

This repository is both a working application and a learning lab. Contributions should keep the implementation understandable, repeatable, and secure.

Before submitting a change:

- Explain what the change does.
- Identify the affected environment.
- Include validation commands and results.
- Update the relevant README or runbook.
- Include diagrams when architecture changes.
- Never include real credentials, secrets, state files, or private keys.
- For infrastructure changes, include a reviewed Terraform plan or CloudFormation change-set summary where appropriate.

## Suggested documentation files

- `terraform/README.md` — Terraform installation, backend, modules, environments, and deployment.
- `cloudformation/README.md` — template structure, validation, stacks, and drift.
- `docker/README.md` — image builds, local Compose, and ECR publishing.
- `kubernetes/README.md` — local cluster, manifests, Helm/Kustomize, and EKS.
- `manual-deployment/README.md` — original AWS Console-based lab.
- `docs/architecture/` — current and target architecture.
- `docs/runbooks/` — operational procedures.

---

# ☕ Final Project Direction

Charlie Cafe will evolve in a controlled sequence:

**Existing AWS implementation → Repository architecture → Terraform → Terraform CI/CD → CloudFormation learning track → Docker standardization → Local Kubernetes → Amazon EKS → GitOps and observability.**

The first engineering milestone is not to deploy every technology at once. It is to establish the repository structure, inventory the current AWS resources, and build a safe Terraform development foundation. This keeps the existing Charlie Cafe project intact while making each new DevOps capability independently understandable, testable, and maintainable.
