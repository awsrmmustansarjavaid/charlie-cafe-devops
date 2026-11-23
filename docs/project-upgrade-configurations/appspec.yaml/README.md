# AWS CodeDeploy AppSpec Configuration

## Overview

This directory contains the AWS CodeDeploy Application Specification (AppSpec) configuration files for the Charlie Cafe AWS DevOps project.

The AppSpec file defines the ECS service deployment configuration used by AWS CodeDeploy during ECS blue/green deployments.

It specifies the target ECS service, task definition, and load balancer container configuration required during deployment.

This directory maintains two versions of the AppSpec configuration:

1. **Legacy Version:** Original configuration used before Terraform integration.
2. **Terraform Version:** Updated configuration designed for the Terraform-based infrastructure and deployment workflow.

---

## Directory Structure

```text
docs/
└──project-upgrade-configurations/
    └── appspec.yaml/
          │
          ├── legacy/
          │   └── appspec.yaml
          │
          ├── terraform/
          │   └── appspec.yaml
          │
          └── README.md
```

### Directory Description

| Directory | Description |
|---|---|
| `legacy/` | Contains the original AppSpec configuration used before Terraform implementation. |
| `terraform/` | Contains the updated AppSpec configuration for the Terraform-based deployment workflow. |
| `README.md` | Documents the purpose, configuration versions, differences, and deployment workflow. |

---

## 1. Legacy AppSpec Configuration (Before Terraform)

**File Location:**

`legacy/appspec.yaml`

### Configuration

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

### Explanation

This is the original AppSpec configuration created before introducing Terraform into the project.

It explicitly references the ECS task definition family name instead of using a dynamic CodeDeploy placeholder.

### Key Configuration Details

| Property | Value | Description |
|---|---|---|
| `version` | `1` | Specifies the AppSpec file format version. |
| `Resources` | `TargetService` | Identifies the ECS service deployment resource. |
| `Type` | `AWS::ECS::Service` | Defines the deployment resource as an ECS service. |
| `TaskDefinition` | `charlie-task` | References the ECS task definition family name. |
| `ContainerName` | `charlie-container` | Identifies the container configured in the ECS task definition. |
| `ContainerPort` | `80` | Specifies the container port used by the load balancer. |

### Original Deployment Approach

The original configuration explicitly referenced the task definition:

```yaml
TaskDefinition: "charlie-task"
```

This was part of the pre-Terraform deployment configuration.

---

## 2. Terraform AppSpec Configuration (After Terraform)

**File Location:**

`terraform/appspec.yaml`

### Configuration

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

### Explanation

This is the updated AppSpec configuration intended for the Terraform-based infrastructure and AWS CodeDeploy ECS blue/green deployment workflow.

The main change is the replacement of the explicitly specified task definition family name with the CodeDeploy-provided placeholder:

```yaml
TaskDefinition: <TASK_DEFINITION>
```

### Why Was This Changed?

The `<TASK_DEFINITION>` placeholder allows AWS CodeDeploy to use the task definition revision supplied as part of the deployment AppSpec configuration.

This supports deployments using newly registered ECS task definition revisions instead of relying on a fixed task definition reference.

### Key Configuration Details

| Property | Value | Description |
|---|---|---|
| `version` | `1` | Specifies the AppSpec file format version. |
| `Resources` | `TargetService` | Identifies the ECS service deployment resource. |
| `Type` | `AWS::ECS::Service` | Defines the deployment resource as an ECS service. |
| `TaskDefinition` | `<TASK_DEFINITION>` | CodeDeploy placeholder for the task definition reference supplied during deployment. |
| `ContainerName` | `charlie-container` | Identifies the container configured in the ECS task definition. |
| `ContainerPort` | `80` | Specifies the container port used by the load balancer. |

---

## 3. Updated Final AppSpec Configuration

The following is the finalized Terraform-compatible AppSpec configuration, including comments explaining the differences from the original version.

```yaml
version: 1

Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:

        # OLD (Before Terraform):
        # TaskDefinition: "charlie-task"
        #
        # NEW (Terraform):
        # Uses the CodeDeploy placeholder to supply
        # the task definition revision during deployment.
        TaskDefinition: <TASK_DEFINITION>

        LoadBalancerInfo:
          # Container name remains unchanged.
          # Only the quotation marks were removed.
          ContainerName: charlie-container

          # Container port remains unchanged.
          ContainerPort: 80
```

### Important Configuration Differences

| Property | Legacy Version | Terraform Version |
|---|---|---|
| `TaskDefinition` | `"charlie-task"` | `<TASK_DEFINITION>` |
| `ContainerName` | `"charlie-container"` | `charlie-container` |
| `ContainerPort` | `80` | `80` |

### Summary of Changes

**1. Task Definition Reference**

Old:

```yaml
TaskDefinition: "charlie-task"
```

New:

```yaml
TaskDefinition: <TASK_DEFINITION>
```

The updated configuration uses the CodeDeploy placeholder to support the task definition revision supplied during deployment.

**2. Container Name**

Old:

```yaml
ContainerName: "charlie-container"
```

New:

```yaml
ContainerName: charlie-container
```

The value remains unchanged. Only the quotation marks were removed.

**3. Container Port**

Old:

```yaml
ContainerPort: 80
```

New:

```yaml
ContainerPort: 80
```

No changes were required because the application continues to use container port `80`.

---

## 4. ECS Blue/Green Deployment Workflow

The Terraform-compatible AppSpec file is intended to be used as part of the AWS ECS blue/green deployment process.

### General Deployment Workflow

1. **Terraform Infrastructure Provisioning:** Terraform provisions and manages the required AWS infrastructure.
2. **Docker Image Build:** The application Docker image is built.
3. **Amazon ECR:** The Docker image is pushed to Amazon Elastic Container Registry (ECR).
4. **ECS Task Definition:** A new ECS task definition revision is registered.
5. **AppSpec Configuration:** The deployment process prepares the AppSpec configuration with the appropriate task definition reference.
6. **AWS CodeDeploy:** CodeDeploy receives the deployment AppSpec and deploys the new task definition to the ECS service.
7. **Blue/Green Deployment:** CodeDeploy manages the replacement task set and traffic shifting between the existing and replacement environments.

---

## 5. Important Notes

- Keep the legacy AppSpec configuration for historical reference and comparison.
- Use the Terraform-compatible AppSpec configuration for the updated deployment workflow.
- Keep the container name consistent with the container definition in the ECS task definition.
- Ensure the container port matches the application container port and the ECS load balancer configuration.
- The `<TASK_DEFINITION>` placeholder must be replaced with a valid task definition reference through the deployment process before CodeDeploy processes the deployment.
- The AppSpec file does not provision AWS infrastructure. Terraform manages the infrastructure separately.
- The Terraform directory name identifies the intended workflow; it does not mean Terraform automatically replaces the CodeDeploy placeholder.

**Important:** For ECS blue/green deployments, ensure that your deployment pipeline or deployment tooling supplies the correct task definition ARN or revision in the AppSpec content. Do not assume that the placeholder is automatically resolved simply because Terraform is managing the infrastructure.

---

## 6. Final Configuration Reference

| Version | File Path | Purpose |
|---|---|---|
| Legacy | `legacy/appspec.yaml` | Original AppSpec configuration used before Terraform integration. |
| Terraform | `terraform/appspec.yaml` | Updated AppSpec configuration for the Terraform-based deployment workflow. |

---

## Conclusion

The Charlie Cafe project maintains separate legacy and Terraform-compatible AppSpec configurations to preserve deployment history and support the updated infrastructure-as-code workflow.

The updated configuration introduces the `<TASK_DEFINITION>` placeholder, allowing the deployment process to supply the appropriate ECS task definition reference dynamically.

Both configurations retain the same ECS service resource, container name, and container port settings, ensuring consistency across the two deployment approaches.

This structure provides clear documentation, configuration history, and a maintainable foundation for the Charlie Cafe AWS DevOps project.