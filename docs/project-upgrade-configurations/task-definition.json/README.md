# ECS Task Definition – Charlie Cafe Project

## 1. Overview

This directory contains the Amazon Elastic Container Service (Amazon ECS) task definition configurations for the Charlie Cafe DevOps project.

The project maintains two versions of the ECS task definition:

- **Legacy Version:** The original ECS task definition used in the manual AWS implementation.
- **Terraform Version:** The updated ECS task definition designed for Infrastructure as Code (IaC) implementation using Terraform.

Both versions are maintained separately to preserve the original configuration and support the migration from manually configured AWS infrastructure to Terraform-managed infrastructure.

## 2. Directory Structure

```text
docs/
└── project-upgrade-configurations/    
    │
    └── task-definitions/
        ├── README.md
        ├── legacy/
        │   └── task-definition.json
        │
        └── terraform/
            └── task-definition.json
```

### Directory Description

| Directory | Purpose |
|---|---|
| `README.md` | Main documentation for ECS task definition configurations. |
| `legacy/` | Contains the original ECS task definition used in the manual AWS setup. |
| `terraform/` | Contains the updated ECS task definition configuration for Terraform implementation. |

## 3. Legacy Task Definition

**Location:** `legacy/task-definition.json`

The legacy version represents the original ECS Fargate task definition created during the initial manual AWS infrastructure setup.

### Configuration Details

- ECS Task Family: `charlie-task`
- Network Mode: `awsvpc`
- Launch Compatibility: `FARGATE`
- CPU: `512` (0.5 vCPU)
- Memory: `1024` (1 GB)
- Container Name: `charlie-container`
- Container Port: `80`
- Execution Role: `ecsTaskExecutionRole`
- Container Image: `IMAGE_PLACEHOLDER`

### Characteristics

- Uses a predefined IAM execution role ARN.
- Uses an image placeholder for container image configuration.
- Does not define a separate ECS task role.
- Does not configure database environment variables or Secrets Manager integration.
- Does not include CloudWatch Logs configuration.

This version is preserved for historical reference and comparison with the Terraform implementation.

## 4. Terraform Task Definition

**Location:** `terraform/task-definition.json`

The Terraform version introduces an improved and more complete ECS task definition configuration.

It is designed to integrate with the Terraform-managed AWS infrastructure.

### Configuration Details

- ECS Task Family: `charlie-task`
- Network Mode: `awsvpc`
- Launch Compatibility: `FARGATE`
- CPU: `512` (0.5 vCPU)
- Memory: `1024` (1 GB)
- Container Name: `charlie-container`
- Container Port: `80`
- Database Name: `cafedb`
- Logging Driver: `awslogs`
- CloudWatch Log Group: `/ecs/charlie-task`
- AWS Region: `us-east-1`

### Terraform Integration

The Terraform version uses placeholders for dynamically generated AWS resource values.

| Configuration | Placeholder | Purpose |
|---|---|---|
| Execution Role | `REPLACE_WITH_TERRAFORM_ECS_EXECUTION_ROLE_ARN` | IAM execution role ARN managed by Terraform. |
| Task Role | `REPLACE_WITH_TERRAFORM_ECS_TASK_ROLE_ARN` | IAM task role ARN managed by Terraform. |
| Container Image | `REPLACE_WITH_ECR_IMAGE_URI` | Amazon ECR container image URI. |
| Database Secret | `REPLACE_WITH_DB_SECRET_ARN` | AWS Secrets Manager secret ARN. |

These placeholders must be replaced with actual values before registering the ECS task definition.

In the final Terraform implementation, resource references and Terraform expressions should supply these values dynamically rather than relying on manually hardcoded AWS ARNs.

## 5. Key Improvements in the Terraform Version

| Feature | Legacy Version | Terraform Version |
|---|---|---|
| ECS Fargate | Yes | Yes |
| IAM Execution Role | Yes | Yes |
| IAM Task Role | No | Yes |
| ECR Image Integration | Placeholder | Terraform-managed value |
| Database Environment Variable | No | Yes |
| Secrets Manager Integration | No | Yes |
| CloudWatch Logging | No | Yes |
| Terraform Integration | No | Yes |

### 5.1 IAM Execution Role

The execution role allows Amazon ECS to perform tasks required to start containers, including retrieving container images from Amazon ECR and sending logs to CloudWatch.

### 5.2 IAM Task Role

The task role provides AWS permissions to the application running inside the ECS container.

It is maintained separately from the execution role to follow AWS IAM least-privilege principles.

### 5.3 Database Configuration

The Terraform version defines the database name through an environment variable:

- `DB_NAME=cafedb`

Database connection information is supplied through AWS Secrets Manager.

The following secret values are configured:

- `DB_HOST`
- `DB_USER`
- `DB_PASS`

This approach avoids directly storing database credentials inside the task definition.

### 5.4 CloudWatch Logging

The Terraform version enables the AWS Logs driver.

Configuration:

- Log Group: `/ecs/charlie-task`
- AWS Region: `us-east-1`
- Stream Prefix: `ecs`

This allows container logs to be collected and monitored through Amazon CloudWatch Logs.

**Important:** The CloudWatch log group must exist before the ECS task starts unless automatic log group creation is explicitly configured with the necessary permissions.

## 6. Terraform Implementation Requirements

Before deploying the Terraform task definition, ensure that the following AWS resources are available or managed by Terraform:

1. ECS Task Execution IAM Role.
2. ECS Task IAM Role.
3. Amazon ECR Repository and container image.
4. AWS Secrets Manager database secret.
5. CloudWatch Log Group.
6. ECS Cluster.
7. ECS Service.
8. VPC and appropriate networking configuration.

The ECS execution role must have the necessary permissions to retrieve secrets and access the ECR image and CloudWatch Logs.

The ECS task role should contain only the permissions required by the application.

The ECS task networking configuration must also allow connectivity to the database and required AWS services.

## 7. Important Notes

- The `legacy/` directory must remain unchanged to preserve the original manual implementation.
- The `terraform/` directory contains the updated configuration for Infrastructure as Code.
- Do not use the legacy configuration for the new Terraform deployment.
- Do not commit actual database passwords or other sensitive credentials to GitHub.
- Use Terraform-managed resource references instead of manually copying AWS resource ARNs.
- Ensure the ECS execution role has permission to retrieve the required Secrets Manager values.
- Ensure the Secrets Manager secret JSON keys match `host`, `username`, and `password`.
- Keep the AWS region consistent across Terraform resources and ECS logging configuration.

## 8. Recommended Usage

| Implementation | Configuration to Use |
|---|---|
| Original manual AWS deployment | `legacy/task-definition.json` |
| New Terraform implementation | `terraform/task-definition.json` |

The Terraform implementation should be the primary configuration going forward.

## 9. Project Documentation Purpose

This directory is part of the Charlie Cafe AWS DevOps project documentation.

Its purpose is to maintain a clear separation between the original manually configured AWS infrastructure and the new Terraform-based Infrastructure as Code implementation.

Maintaining both configurations provides historical reference, improves traceability, and makes it easier to understand the infrastructure migration process.

---

**Project:** Charlie Cafe AWS DevOps Project  
**AWS Service:** Amazon Elastic Container Service (ECS)  
**Deployment Platform:** AWS Fargate  
**Infrastructure as Code:** Terraform  
**Configuration Type:** ECS Task Definition (JSON)