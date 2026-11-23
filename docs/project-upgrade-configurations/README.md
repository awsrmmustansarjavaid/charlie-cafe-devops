# Charlie Cafe – Project Upgrade Configurations

![Project](https://img.shields.io/badge/Project-Charlie%20Cafe-orange)
![Cloud](https://img.shields.io/badge/Cloud-AWS-orange)
![Infrastructure](https://img.shields.io/badge/Infrastructure-Terraform-844FBA)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF)
![Deployment](https://img.shields.io/badge/Deployment-EC2%20%7C%20ECS-blue)
![Status](https://img.shields.io/badge/Documentation-Project%20Upgrade-success)

## 1. Overview

The `project-upgrade-configurations` directory contains the documentation and configuration references for the Charlie Cafe AWS DevOps project upgrade.

This directory maintains the original (Legacy) deployment configurations alongside their updated Terraform-compatible versions.

The primary objective is to document the transition from the original manually configured AWS deployment architecture toward a more structured, automated, secure, and Infrastructure as Code (IaC)-driven deployment architecture.

The configurations are organized into three major components:

1. **ECS Task Definitions** – Defines the container configuration, execution roles, task roles, environment variables, secrets, and logging settings.
2. **AWS CodeDeploy AppSpec** – Defines the ECS blue/green deployment configuration, target service, task definition reference, and load balancer container settings.
3. **GitHub Actions Workflows** – Defines the CI/CD automation responsible for application deployment, Docker image publishing, AWS authentication, and ECS/EC2 deployment.

Each component maintains two versions:

- **Legacy:** Original configuration from the initial AWS implementation.
- **Terraform:** Updated configuration designed for integration with Terraform-managed AWS infrastructure.

This separation provides a historical reference, makes configuration changes traceable, and establishes a clear foundation for future infrastructure and deployment improvements.

---

## 2. Directory Structure

The directory is organized as follows:

```text
docs/
└── project-upgrade-configurations/
    │
    ├── README.md
    │
    ├── task-definitions/
    │   ├── README.md
    │   ├── legacy/
    │   │   └── task-definition.json
    │   └── terraform/
    │       └── task-definition.json
    │
    ├── appspec/
    │   ├── README.md
    │   ├── legacy/
    │   │   └── appspec.yaml
    │   └── terraform/
    │       └── appspec.yaml
    │
    └── github-workflows/
        ├── README.md
        ├── legacy/
        │   └── deploy.yml
        └── terraform/
            └── deploy.yml
```

### Directory Description

| Directory | Description |
|---|---|
| `task-definitions/` | Contains legacy and Terraform-compatible Amazon ECS task definitions. |
| `task-definitions/legacy/` | Preserves the original ECS task definition. |
| `task-definitions/terraform/` | Contains the updated ECS task definition with Terraform integration placeholders. |
| `appspec/` | Contains AWS CodeDeploy AppSpec configuration files. |
| `appspec/legacy/` | Preserves the original ECS deployment AppSpec configuration. |
| `appspec/terraform/` | Contains the updated AppSpec configuration using the CodeDeploy task definition placeholder. |
| `github-workflows/` | Contains the original and updated GitHub Actions CI/CD workflows. |
| `github-workflows/legacy/` | Preserves the original production CI/CD workflow. |
| `github-workflows/terraform/` | Contains the updated deployment workflow using GitHub OIDC and Terraform-compatible configuration. |
| `README.md` | Provides the main documentation, upgrade overview, architecture, and configuration references. |

---

## 3. Project Upgrade Objectives

The upgrade focuses on improving the existing Charlie Cafe AWS DevOps implementation.

The major objectives include:

### 3.1 Infrastructure as Code Integration

- Introduce Terraform for AWS infrastructure provisioning and management.
- Maintain reusable and maintainable infrastructure configurations.
- Reduce dependence on manually configured AWS resources.
- Improve infrastructure consistency across environments.
- Support infrastructure changes through version-controlled Terraform configurations.

### 3.2 Improved AWS Authentication

- Introduce GitHub Actions OpenID Connect (OIDC) authentication.
- Use AWS IAM roles instead of permanently stored AWS access keys in the Terraform deployment workflow.
- Apply least-privilege IAM permissions.
- Improve AWS deployment authentication and auditing.

### 3.3 Improved ECS Deployment

- Maintain Amazon ECS Fargate as the container deployment platform.
- Integrate Amazon ECR for Docker image storage.
- Use Git commit SHA-based image tagging.
- Register updated ECS task definition revisions.
- Integrate AWS CodeDeploy for ECS blue/green deployments.
- Support improved application deployment and rollback management through CodeDeploy configuration.

### 3.4 Improved CI/CD Automation

- Maintain the original CI/CD workflow for historical reference.
- Introduce a reusable deployment workflow.
- Support manual and reusable workflow execution.
- Support configurable EC2 and ECS deployment targets.
- Improve deployment configuration validation.
- Improve deployment status verification.

---

## 4. Configuration Component 1 – ECS Task Definitions

**Directory:** `task-definitions/`

Amazon ECS task definitions describe how application containers should run.

They specify container images, compute resources, networking, IAM roles, environment variables, secrets, port mappings, and logging configuration.

The Charlie Cafe project maintains two task definition versions.

### 4.1 Legacy Task Definition

**File:**

`task-definitions/legacy/task-definition.json`

The legacy configuration represents the original ECS task definition used during the initial manual AWS implementation.

Key configuration:

| Configuration | Value |
|---|---|
| Task Family | `charlie-task` |
| Network Mode | `awsvpc` |
| Launch Type Compatibility | `FARGATE` |
| CPU | `512` |
| Memory | `1024` |
| Container Name | `charlie-container` |
| Container Port | `80` |
| Execution Role | `ecsTaskExecutionRole` |
| Container Image | `IMAGE_PLACEHOLDER` |

Characteristics:

- Uses an explicitly configured ECS execution role ARN.
- Uses a placeholder for the container image.
- Does not define a separate ECS task role.
- Does not configure Secrets Manager integration.
- Does not configure CloudWatch container logging.

This version is preserved for historical reference.

### 4.2 Terraform Task Definition

**File:**

`task-definitions/terraform/task-definition.json`

The Terraform version introduces an improved ECS task definition intended for integration with Terraform-managed AWS infrastructure.

Key configuration:

| Configuration | Value |
|---|---|
| Task Family | `charlie-task` |
| Network Mode | `awsvpc` |
| Launch Type Compatibility | `FARGATE` |
| CPU | `512` |
| Memory | `1024` |
| Container Name | `charlie-container` |
| Container Port | `80` |
| Database Name | `cafedb` |
| Logging Driver | `awslogs` |
| CloudWatch Log Group | `/ecs/charlie-task` |
| AWS Region | `us-east-1` |

Key improvements:

1. Separate ECS task execution role and task role.
2. Terraform-managed IAM role references.
3. Amazon ECR container image integration.
4. Database environment variable configuration.
5. AWS Secrets Manager integration.
6. CloudWatch Logs integration.
7. Improved configuration management.

### 4.3 Terraform Integration Placeholders

The Terraform task definition currently contains placeholders for infrastructure-generated values.

| Placeholder | Purpose |
|---|---|
| `REPLACE_WITH_TERRAFORM_ECS_EXECUTION_ROLE_ARN` | ECS task execution role ARN. |
| `REPLACE_WITH_TERRAFORM_ECS_TASK_ROLE_ARN` | ECS task role ARN. |
| `REPLACE_WITH_ECR_IMAGE_URI` | Amazon ECR container image URI. |
| `REPLACE_WITH_DB_SECRET_ARN` | AWS Secrets Manager secret ARN. |

These placeholders must be populated with valid infrastructure values before registering the task definition.

The final deployment implementation should use Terraform outputs or an equivalent deployment-time rendering process rather than committing environment-specific resource ARNs.

### 4.4 Recommended Configuration

| Implementation | Configuration |
|---|---|
| Original manual AWS implementation | `task-definitions/legacy/task-definition.json` |
| Terraform-based implementation | `task-definitions/terraform/task-definition.json` |

**Recommended:** Use the Terraform version as the primary configuration for the upgraded infrastructure.

For more details, see [`task-definitions/README.md`](task-definitions/README.md).

---

## 5. Configuration Component 2 – AWS CodeDeploy AppSpec

**Directory:** `appspec/`

The AWS CodeDeploy Application Specification (AppSpec) file defines the ECS service deployment configuration used during CodeDeploy blue/green deployments.

It identifies the target ECS service, task definition reference, and load balancer container configuration.

The Charlie Cafe project maintains two AppSpec versions.

### 5.1 Legacy AppSpec Configuration

**File:**

`appspec/legacy/appspec.yaml`

The original configuration explicitly references the ECS task definition family:

```yaml
version: 1

Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "charlie-task"
        LoadBalancerInfo:
          ContainerName: "charlie-container"
          ContainerPort: 80
```

Characteristics:

- Uses the original ECS task definition reference.
- Defines `charlie-container` as the load balancer container.
- Uses container port `80`.
- Represents the original deployment configuration.

### 5.2 Terraform AppSpec Configuration

**File:**

`appspec/terraform/appspec.yaml`

The updated configuration uses the CodeDeploy task definition placeholder:

```yaml
version: 1

Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: <TASK_DEFINITION>
        LoadBalancerInfo:
          ContainerName: charlie-container
          ContainerPort: 80
```

Key improvement:

The original fixed task definition reference:

```yaml
TaskDefinition: "charlie-task"
```

is replaced with:

```yaml
TaskDefinition: <TASK_DEFINITION>
```

This allows the deployment process to provide the task definition revision associated with the deployment.

### 5.3 AppSpec Configuration Comparison

| Configuration | Legacy | Terraform |
|---|---|---|
| AppSpec Version | `1` | `1` |
| Deployment Resource | `AWS::ECS::Service` | `AWS::ECS::Service` |
| Task Definition | `charlie-task` | `<TASK_DEFINITION>` |
| Container Name | `charlie-container` | `charlie-container` |
| Container Port | `80` | `80` |
| Deployment Type | ECS | ECS blue/green |

### 5.4 Recommended Configuration

| Implementation | Configuration |
|---|---|
| Original manual AWS implementation | `appspec/legacy/appspec.yaml` |
| Terraform-based implementation | `appspec/terraform/appspec.yaml` |

**Recommended:** Use the Terraform-compatible AppSpec configuration with the ECS CodeDeploy deployment process.

For more details, see [`appspec/README.md`](appspec/README.md).

---

## 6. Configuration Component 3 – GitHub Actions Workflows

**Directory:** `github-workflows/`

GitHub Actions provides the CI/CD automation used to build, validate, and deploy Charlie Cafe applications to AWS.

The project maintains two deployment workflow versions.

### 6.1 Legacy GitHub Actions Workflow

**File:**

`github-workflows/legacy/deploy.yml`

The legacy workflow represents the original production CI/CD pipeline.

**Workflow trigger:**

```yaml
on:
  push:
    branches: ["main"]
```

The original pipeline automatically starts when changes are pushed to the `main` branch.

Major workflow capabilities:

1. Repository checkout.
2. Git commit SHA generation.
3. AWS authentication using stored access key secrets.
4. Required CI tool installation.
5. Docker image build.
6. Local container execution.
7. Application health check.
8. EC2 deployment through AWS Systems Manager.
9. EC2 deployment status verification.
10. EC2 public IP retrieval.
11. EC2 application health check.
12. Amazon ECR authentication.
13. ECS Docker image build.
14. Docker image tagging and publishing.
15. ECS task definition rendering.
16. ECS task definition registration.
17. AppSpec preparation.
18. AWS CodeDeploy deployment.

The legacy implementation is retained to preserve the original production deployment approach and provide a comparison reference.

### 6.2 Terraform GitHub Actions Workflow

**File:**

`github-workflows/terraform/deploy.yml`

The Terraform-compatible workflow introduces a more configurable deployment architecture.

Its primary objective is to support deployment to existing AWS infrastructure using GitHub Actions OIDC authentication and Terraform-compatible configuration files.

**Workflow triggers:**

```yaml
on:
  workflow_dispatch:
  workflow_call:
```

The workflow supports both manual execution and reuse from other GitHub Actions workflows.

### Deployment Targets

The updated workflow supports three deployment modes:

| Deployment Target | Description |
|---|---|
| `ec2` | Deploy the existing application to an EC2 instance using AWS Systems Manager. |
| `ecs` | Build and push a Docker image to Amazon ECR and deploy it to Amazon ECS through CodeDeploy. |
| `both` | Execute both EC2 and ECS deployment processes. |

### Major Improvements

**1. GitHub OIDC Authentication**

Uses GitHub Actions OIDC to assume an AWS IAM deployment role.

This avoids requiring long-lived AWS access keys in the Terraform deployment workflow.

**2. Deployment Configuration Validation**

Validates required configuration values and deployment files before proceeding.

**3. EC2 Deployment Through SSM**

- Sends deployment commands to the configured EC2 instance.
- Updates the existing application.
- Reloads the Apache HTTP server.
- Waits for command execution.
- Verifies the final SSM execution status.

**4. Amazon ECR Integration**

- Authenticates with Amazon ECR.
- Builds the Docker image.
- Uses the full Git commit SHA as the image tag.
- Pushes the image to the configured ECR repository.

**5. ECS Task Definition Rendering**

Uses the AWS ECS render task definition action to replace the container image in the task definition.

**6. CodeDeploy Blue/Green Deployment**

Uses the AWS ECS deployment action with the CodeDeploy AppSpec configuration and deployment group.

**7. Deployment Verification**

Waits for the ECS deployment and service stability before reporting success.

**8. Deployment Concurrency**

Prevents overlapping deployments within the same workflow concurrency group.

### 6.3 Required GitHub Secrets

The Terraform deployment workflow uses the following GitHub repository secrets:

| Secret | Purpose |
|---|---|
| `DEPLOY_AWS_ROLE_ARN` | AWS IAM role ARN used for GitHub OIDC authentication. |
| `EC2_INSTANCE_ID` | Target EC2 instance ID. |
| `ECR_REPO` | Amazon ECR repository name. |
| `ECS_CLUSTER` | ECS cluster name. |
| `ECS_SERVICE` | ECS service name. |
| `CODEDEPLOY_APPLICATION` | AWS CodeDeploy application name. |
| `CODEDEPLOY_DEPLOYMENT_GROUP` | AWS CodeDeploy deployment group name. |

Configuration can also be supplied through supported workflow inputs.

EC2 configuration is required for EC2 deployment, while ECR, ECS, and CodeDeploy configuration is required for ECS deployment.

### 6.4 Recommended Workflow

| Implementation | Workflow |
|---|---|
| Original production CI/CD implementation | `github-workflows/legacy/deploy.yml` |
| Updated Terraform-compatible deployment | `github-workflows/terraform/deploy.yml` |

**Recommended:** Use the Terraform-compatible workflow as the primary deployment workflow going forward.

For more details, see [`github-workflows/README.md`](github-workflows/README.md).

---

## 7. Overall Deployment Architecture

The three configuration components work together to support the Charlie Cafe deployment process.

### 7.1 Terraform-Based ECS Deployment Flow

```text
                 Developer
                     |
                     |
              GitHub Repository
                     |
                     |
              GitHub Actions
                     |
                     |
              AWS OIDC Login
                     |
                     |
              Build Docker Image
                     |
                     |
              Amazon ECR
                     |
                     |
             Render Task Definition
                     |
                     |
             Register ECS Revision
                     |
                     |
             Prepare AppSpec
                     |
                     |
             AWS CodeDeploy
                     |
                     |
              ECS Blue/Green
                     |
                     |
             Traffic Transition
                     |
                     |
              Deployment Check
                     |
                     |
               Deployment
                 Complete
```

### 7.2 Configuration Relationships

| Component | Responsibility | Integration |
|---|---|---|
| Terraform Infrastructure | Provisions and manages AWS resources. | AWS IAM, VPC, ECS, ECR, CodeDeploy and supporting services. |
| ECS Task Definition | Defines the container runtime configuration. | ECS and Amazon ECR. |
| AppSpec | Defines the ECS deployment specification. | AWS CodeDeploy and ECS. |
| GitHub Actions | Automates build and deployment operations. | GitHub, AWS OIDC, ECR, ECS, SSM and CodeDeploy. |

### 7.3 EC2 Deployment Flow

The updated workflow also supports deployment to the existing EC2 application environment.

```text
GitHub Repository
       |
       |
GitHub Actions
       |
       |
AWS OIDC Authentication
       |
       |
AWS Systems Manager
       |
       |
Target EC2 Instance
       |
       |
Update Application Files
       |
       |
Reload Apache
       |
       |
Verify SSM Execution
       |
       |
Deployment Complete
```

---

## 8. Legacy vs Terraform Upgrade Comparison

The following table summarizes the main differences between the original implementation and the upgraded configuration.

| Feature | Legacy Implementation | Terraform-Compatible Implementation |
|---|---|---|
| Infrastructure Management | Original manually configured AWS resources | Terraform-managed infrastructure integration |
| ECS Task Definition | Original static configuration | Updated configuration with infrastructure placeholders |
| ECS Execution Role | Explicitly configured role ARN | Terraform-managed role reference |
| ECS Task Role | Not defined | Separate task role reference |
| Container Image | Image placeholder | ECR image URI placeholder |
| Database Configuration | Not configured | Database environment variable |
| Database Secrets | Not configured | AWS Secrets Manager integration |
| Container Logging | Not configured | CloudWatch Logs integration |
| AppSpec Task Definition | Fixed task definition family reference | CodeDeploy task definition placeholder |
| GitHub Workflow | Push to `main` | Manual and reusable execution |
| AWS Authentication | Stored AWS access key secrets | GitHub OIDC |
| EC2 Deployment | SSM | SSM with command completion verification |
| ECS Deployment | ECR and CodeDeploy | ECR and CodeDeploy blue/green |
| Docker Image Tag | Short Git SHA | Full Git commit SHA |
| Deployment Configuration | Primarily static | Configurable workflow inputs and secrets |

**Important:** This comparison documents the configurations currently maintained in this directory. It does not imply that all AWS resources have already been migrated or deployed through Terraform.

---

## 9. Important AWS Infrastructure Requirements

Before using the Terraform-compatible configurations, verify that the necessary AWS infrastructure exists and is correctly configured.

### 9.1 IAM Requirements

- GitHub Actions OIDC identity provider.
- AWS IAM deployment role.
- ECS task execution role.
- ECS task role.
- CodeDeploy service role.
- Appropriate EC2 SSM instance permissions.
- Least-privilege permissions for deployment operations.

### 9.2 Amazon ECS Requirements

- ECS cluster.
- ECS Fargate service.
- Correct task definition family.
- Correct container name.
- Correct container port.
- Appropriate VPC and subnet configuration.
- Appropriate security group rules.

### 9.3 Amazon ECR Requirements

- ECR repository.
- Appropriate image push permissions.
- ECS image pull permissions.
- Valid Docker image URI.

### 9.4 AWS CodeDeploy Requirements

- CodeDeploy application.
- ECS deployment group.
- ECS deployment controller configured as `CODE_DEPLOY`.
- Appropriate CodeDeploy service role.
- Application load balancer.
- Production and test listeners where required.
- Blue and green target groups.
- Appropriate traffic shifting and rollback configuration.

### 9.5 Secrets Manager Requirements

The Terraform task definition references database secret values.

The relevant secret must contain the expected keys:

- `host`
- `username`
- `password`

The ECS task execution role must have the required permissions to retrieve the secret.

### 9.6 CloudWatch Requirements

The Terraform task definition uses:

- Log Group: `/ecs/charlie-task`
- Region: `us-east-1`
- Stream Prefix: `ecs`

Ensure the log group exists or that automatic creation is configured with the necessary IAM permissions.

---

## 10. Important Configuration and Deployment Notes

### 10.1 Legacy Configuration Preservation

The `legacy/` directories are maintained for historical reference.

- Do not overwrite legacy configuration files with Terraform versions.
- Preserve the original deployment implementation.
- Use the Terraform directories for the upgraded implementation.

### 10.2 Terraform Configuration Integration

The Terraform task definition contains placeholder values.

These must be replaced or dynamically rendered before registering the task definition.

Do not commit actual environment-specific credentials, passwords, or sensitive values.

### 10.3 GitHub Workflow File Paths

The documentation configurations are stored under:

```text
docs/project-upgrade-configurations/
```

However, the Terraform deployment workflow currently validates and references these application-level files:

```text
.github/task-definition.json
appspec.yaml
docker/apache-php/Dockerfile
```

The documentation files under `docs/project-upgrade-configurations/` are configuration references, not automatic replacements for these runtime files.

Ensure the active deployment files are maintained at the paths expected by the workflow, or update the workflow to render and consume the documentation configurations explicitly.

### 10.4 AWS Account and Environment Configuration

- Keep AWS account-specific values out of reusable configuration templates.
- Use Terraform outputs for dynamically generated infrastructure identifiers.
- Use GitHub Secrets or protected GitHub Environments for sensitive deployment configuration.
- Keep AWS region configuration consistent across Terraform, ECS, ECR, CodeDeploy and CloudWatch.

### 10.5 Production Deployment Safety

Before production deployment:

1. Validate Terraform configuration.
2. Verify IAM permissions.
3. Validate ECS task definitions.
4. Validate AppSpec configuration.
5. Verify CodeDeploy deployment group settings.
6. Validate Docker image availability.
7. Confirm application health checks.
8. Verify deployment and rollback behavior.

---

## 11. Recommended Upgrade Implementation Sequence

The following sequence provides a structured approach for completing the Charlie Cafe infrastructure and deployment upgrade.

| Phase | Implementation | Status Tracking |
|---|---|---|
| 01 | Preserve legacy configurations | Documented |
| 02 | Prepare Terraform-compatible ECS task definition | Configuration maintained |
| 03 | Prepare Terraform-compatible AppSpec | Configuration maintained |
| 04 | Prepare Terraform-compatible GitHub Actions workflow | Configuration maintained |
| 05 | Implement Terraform AWS infrastructure | Track in Terraform project |
| 06 | Configure GitHub OIDC and AWS IAM roles | Infrastructure requirement |
| 07 | Configure Amazon ECR and ECS | Infrastructure requirement |
| 08 | Configure CodeDeploy blue/green deployment | Infrastructure requirement |
| 09 | Integrate deployment workflow with Terraform outputs | Implementation requirement |
| 10 | Execute staging deployment and validation | Pending deployment verification |
| 11 | Execute production deployment | Pending deployment verification |
| 12 | Document final production architecture | Future documentation update |

---

## 12. Documentation Index

Each component has its own detailed README.

| Documentation | Description |
|---|---|
| [ECS Task Definitions](task-definitions/README.md) | Legacy and Terraform task definition configurations, improvements, and requirements. |
| [AWS CodeDeploy AppSpec](appspec/README.md) | AppSpec configurations, task definition references, and ECS blue/green deployment integration. |
| [GitHub Actions Workflows](github-workflows/README.md) | Legacy and Terraform-compatible CI/CD workflows, triggers, AWS authentication, and deployment procedures. |

---

## 13. Configuration Selection Guide

Use the following guide when selecting configuration files.

| Component | Legacy Version | Recommended Upgraded Version |
|---|---|---|
| ECS Task Definition | `task-definitions/legacy/task-definition.json` | `task-definitions/terraform/task-definition.json` |
| CodeDeploy AppSpec | `appspec/legacy/appspec.yaml` | `appspec/terraform/appspec.yaml` |
| GitHub Actions Workflow | `github-workflows/legacy/deploy.yml` | `github-workflows/terraform/deploy.yml` |

The Terraform-compatible versions are the intended primary configurations for the upgraded deployment architecture.

The legacy versions remain available for comparison, troubleshooting, and historical reference.

---

## 14. Project Maintenance Guidelines

To maintain a professional and consistent configuration repository:

1. Keep the directory structure consistent.
2. Maintain separate legacy and Terraform configurations.
3. Update component-level README files whenever configurations change.
4. Document changes to task definition properties.
5. Document changes to deployment workflow behavior.
6. Keep AWS resource identifiers environment-specific.
7. Never commit database credentials or AWS access keys.
8. Use meaningful Git commit messages.
9. Review configuration changes before production deployment.
10. Keep the main README updated when new deployment components are introduced.

---

## 15. Final Project Summary

The `project-upgrade-configurations` directory serves as the central documentation and configuration reference for the Charlie Cafe AWS DevOps project upgrade.

It maintains three important configuration areas:

- **ECS Task Definitions:** Container runtime and application configuration.
- **AWS CodeDeploy AppSpec:** ECS blue/green deployment specification.
- **GitHub Actions Workflows:** Automated application build and deployment processes.

By maintaining both legacy and Terraform-compatible configurations, the project provides a clear migration history and a structured foundation for Infrastructure as Code, secure AWS authentication, containerized application deployment, and automated CI/CD.

The intended long-term direction is to use Terraform-managed AWS infrastructure with GitHub Actions OIDC authentication, Amazon ECR image publishing, Amazon ECS Fargate, and AWS CodeDeploy blue/green deployments.

---

**Project:** Charlie Cafe AWS DevOps Project  
**Documentation Directory:** `docs/project-upgrade-configurations/`  
**Cloud Provider:** Amazon Web Services (AWS)  
**Infrastructure as Code:** Terraform  
**CI/CD Platform:** GitHub Actions  
**Container Registry:** Amazon ECR  
**Container Platform:** Amazon ECS Fargate  
**Application Deployment:** AWS CodeDeploy  
**EC2 Management:** AWS Systems Manager (SSM)  
**Configuration Versions:** Legacy and Terraform

**Maintained as part of the Charlie Cafe DevOps Infrastructure Upgrade Documentation.**