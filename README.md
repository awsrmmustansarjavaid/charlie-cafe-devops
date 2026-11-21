# ☕ Charlie Cafe DevOps Project
## End-to-End AWS Cloud, DevOps, Infrastructure as Code & Kubernetes Platform

<p align="center">
  <strong>Building a Secure, Scalable and Cloud-Native Cafe Ordering Platform</strong>
</p>

<p align="center">
  <em>From Application Development to Automated Cloud Infrastructure, CI/CD and Container Orchestration</em>
</p>

---

## 📌 Table of Contents

1. [Project Overview](#-project-overview)
2. [Business Requirements](#-business-requirements)
3. [Project Objectives](#-project-objectives)
4. [Key Features](#-key-features)
5. [System Architecture](#-system-architecture)
6. [Application Architecture](#-application-architecture)
7. [Technology Stack](#-technology-stack)
8. [AWS Cloud Infrastructure](#-aws-cloud-infrastructure)
9. [Networking Architecture](#-networking-architecture)
10. [Database Architecture](#-database-architecture)
11. [Serverless Architecture](#-serverless-architecture)
12. [Containerization](#-containerization)
13. [CI/CD Pipeline](#-cicd-pipeline)
14. [Infrastructure as Code](#-infrastructure-as-code)
15. [Kubernetes Architecture](#-kubernetes-architecture)
16. [Security Architecture](#-security-architecture)
17. [Monitoring and Logging](#-monitoring-and-logging)
18. [Repository Structure](#-repository-structure)
19. [Prerequisites](#-prerequisites)
20. [Local Development Setup](#-local-development-setup)
21. [AWS Deployment](#-aws-deployment)
22. [Testing and Validation](#-testing-and-validation)
23. [High Availability and Scalability](#-high-availability-and-scalability)
24. [Cost Optimization](#-cost-optimization)
25. [Documentation](#-documentation)
26. [Implementation Roadmap](#-implementation-roadmap)
27. [Troubleshooting](#-troubleshooting)
28. [Security Best Practices](#-security-best-practices)
29. [Contributing](#-contributing)
30. [License](#-license)

---

# ☕ Project Overview

**Charlie Cafe DevOps Project** is an end-to-end cloud and DevOps engineering project designed to build, deploy, automate, secure and manage a modern online cafe ordering platform using Amazon Web Services (AWS) and industry-standard DevOps technologies.

The project simulates a real-world business environment in which a cafe requires a reliable digital ordering platform, employee management system, administrative dashboard, secure authentication and real-time order processing.

The objective is to implement a complete DevOps lifecycle covering:

- Application deployment and management.
- Cloud infrastructure provisioning.
- Infrastructure as Code (IaC).
- Containerization and orchestration.
- Automated CI/CD pipelines.
- Cloud networking and security.
- Serverless application architecture.
- Database management.
- Monitoring, logging and troubleshooting.
- High availability and scalability.

The project starts with traditional AWS infrastructure and progressively evolves toward automated, containerized and Kubernetes-based cloud-native deployment.

## 🎯 Primary Goal

Build a production-oriented, scalable and secure cafe ordering platform using modern cloud and DevOps engineering practices.

## 🏢 Business Scenario

**Client:** Charlie Cafe

Charlie Cafe wants to modernize its business operations by introducing an online ordering and management platform.

The platform should allow customers to interact with the cafe digitally while providing employees and administrators with tools to manage orders, payments, menus and business operations.

---

# 📋 Business Requirements

## 1. Customer Requirements

- Online cafe ordering system.
- Browse available food and beverages.
- View menu and product information.
- Place orders online.
- Track order processing status.
- View payment information.
- Access the ordering platform securely.

## 2. Employee Requirements

- Secure employee authentication.
- Employee management system.
- Order management dashboard.
- Order processing and status updates.
- Customer order information.
- Payment tracking.
- Cafe operational management.

## 3. Administrator Requirements

- Secure administrator login.
- Administrative dashboard.
- Employee management.
- Menu and product management.
- Order monitoring.
- Payment monitoring.
- System administration.

## 4. Performance Requirements

- Handle multiple simultaneous customer orders.
- Maintain responsive application performance.
- Support increased traffic during peak hours.
- Provide reliable application availability.
- Scale application components as demand increases.

## 5. Security Requirements

- No publicly accessible database.
- Secure authentication and authorization.
- AWS IAM role-based access.
- Secure application secrets.
- Private database connectivity.
- Restricted network access.
- Encrypted communication using HTTPS.
- Secure CI/CD deployment credentials.

## 6. Scalability Requirements

- Horizontal application scaling.
- Containerized application deployment.
- Event-driven order processing.
- Database scalability.
- Kubernetes deployment support.
- Multi-environment infrastructure management.

---

# 🎯 Project Objectives

The project is organized around the following engineering objectives.

| Area | Objective |
|---|---|
| Application | Build and deploy a cafe ordering platform |
| AWS | Implement cloud infrastructure |
| Networking | Design secure VPC architecture |
| Database | Deploy and manage application databases |
| Serverless | Implement Lambda-based backend services |
| Messaging | Implement asynchronous processing using SQS |
| Containers | Package applications using Docker |
| Registry | Store images in Amazon ECR |
| Compute | Deploy workloads using Amazon ECS |
| CI/CD | Automate build, test and deployment |
| IaC | Provision infrastructure using Terraform |
| CloudFormation | Maintain AWS native infrastructure templates |
| Kubernetes | Deploy workloads to local Kubernetes and Amazon EKS |
| Security | Implement IAM, Cognito and Secrets Manager |
| Monitoring | Monitor infrastructure and application health |

---

# 🚀 Key Features

## Application Features

- Online cafe ordering.
- Customer-facing frontend.
- Administrative dashboard.
- Employee management.
- Secure login and authentication.
- Order management.
- Payment tracking.
- Order status monitoring.

## AWS Cloud Features

- Custom Amazon VPC.
- Public and private subnets.
- Internet Gateway.
- NAT Gateway where required.
- Security Groups.
- VPC Endpoints.
- Amazon EC2.
- Application Load Balancer.
- Amazon CloudFront.
- Amazon RDS.
- Amazon DynamoDB.
- AWS Lambda.
- Amazon API Gateway.
- Amazon SQS.
- Amazon Cognito.
- AWS Secrets Manager.
- Amazon CloudWatch.

## DevOps Features

- Git-based version control.
- Docker containerization.
- Docker Compose local environment.
- Amazon ECR image management.
- Amazon ECS deployment.
- GitHub Actions automation.
- Automated deployment.
- Health checks.
- Rolling deployment.
- Blue/green deployment.
- Deployment rollback.

## Future Platform Engineering Features

- Terraform modules.
- Reusable infrastructure components.
- Environment-specific Terraform configurations.
- Remote Terraform state management.
- Kubernetes manifests.
- Helm-based deployments.
- Local Kubernetes development.
- Amazon EKS deployment.
- Kubernetes scaling and health management.

---

# 🏗️ System Architecture

The Charlie Cafe platform follows a layered cloud architecture.

## High-Level Architecture

![Charlie Cafe End-to-End AWS Architecture](./docs/Project%20Lab%20Configurations/965fab6e-51fe-41b8-83cb-097b995fc64e.png)

## Architecture Layers

| Layer | Components | Responsibility |
|---|---|---|
| Presentation | HTML, CSS, JavaScript, PHP | User interface |
| CDN | CloudFront | Content delivery |
| Load Balancing | Application Load Balancer | Traffic distribution |
| Compute | EC2, ECS, EKS | Application execution |
| API | API Gateway | API management |
| Serverless | Lambda | Backend processing |
| Messaging | SQS | Asynchronous processing |
| Database | RDS, DynamoDB | Data persistence |
| Authentication | Cognito | User identity |
| Secrets | Secrets Manager | Credential management |
| Storage | Amazon S3 | Object storage |
| Monitoring | CloudWatch | Logs and metrics |
| Automation | GitHub Actions | CI/CD |
| IaC | Terraform, CloudFormation | Infrastructure provisioning |

## Architecture Design Principles

- Separation of application and infrastructure.
- Private database access.
- Least-privilege permissions.
- Automated deployment.
- Reusable infrastructure.
- Event-driven processing.
- Containerized workloads.
- Environment isolation.
- Monitoring and observability.

## Data Flow Documentation

Detailed application data flow:

[Charlie Cafe Data Flow Architecture](./docs/Project%20Lab%20Configurations/Charlie-Cafe_Architecture-Diagram/Charlie-Cafe_Data-Flow.md)

---

# 🖥️ Application Architecture

The application consists of frontend and backend components.

## Frontend

The frontend provides the customer and administrative interfaces.

Technologies:

- HTML5
- CSS3
- JavaScript
- PHP
- Apache HTTP Server

Responsibilities:

- Customer ordering interface.
- Menu presentation.
- Employee interface.
- Administrative dashboard.
- API communication.
- Order status presentation.

## Backend

The backend handles application business logic and data processing.

Responsibilities:

- Order creation.
- Order processing.
- Customer management.
- Employee management.
- Payment tracking.
- Database operations.
- API request processing.
- Event-driven execution.

## Backend Architecture

The project uses AWS Lambda and API Gateway for serverless backend capabilities.

Amazon SQS provides asynchronous messaging for decoupled processing.

---

# 🛠️ Technology Stack

## Programming and Application Technologies

| Technology | Purpose |
|---|---|
| PHP | Backend application development |
| Python | AWS Lambda functions and automation |
| HTML5 | Frontend structure |
| CSS3 | Frontend styling |
| JavaScript | Frontend interaction |
| SQL | Database operations |
| Bash | Linux automation |

## Cloud Platform

| AWS Service | Purpose |
|---|---|
| Amazon VPC | Network isolation |
| Amazon EC2 | Virtual compute |
| Amazon ECS | Container orchestration |
| Amazon ECR | Container image registry |
| Amazon EKS | Managed Kubernetes |
| AWS Lambda | Serverless execution |
| API Gateway | API management |
| Amazon SQS | Message queuing |
| Amazon RDS | Relational database |
| Amazon DynamoDB | NoSQL database |
| Amazon S3 | Object storage |
| Amazon CloudFront | CDN |
| Application Load Balancer | Traffic distribution |
| Amazon Cognito | Authentication |
| AWS Secrets Manager | Secrets management |
| Amazon CloudWatch | Monitoring and logging |
| AWS CodeDeploy | Deployment automation |

## DevOps Tools

| Tool | Purpose |
|---|---|
| Git | Version control |
| GitHub | Source code management |
| GitHub Actions | CI/CD |
| Docker | Containerization |
| Docker Compose | Local multi-container environment |
| Terraform | Infrastructure as Code |
| AWS CloudFormation | AWS native IaC |
| Kubernetes | Container orchestration |
| Helm | Kubernetes package management |
| kubectl | Kubernetes management |
| AWS CLI | AWS resource management |
| Linux | Server administration |

---

# ☁️ AWS Cloud Infrastructure

The AWS infrastructure provides the foundation for hosting the Charlie Cafe platform.

## 1. Networking

- Custom VPC.
- Public subnets.
- Private application subnets.
- Private database subnets.
- Internet Gateway.
- NAT Gateway when required.
- Public and private route tables.
- Network ACLs.
- Security Groups.
- VPC Endpoints.

## 2. Compute

- Amazon EC2.
- Amazon ECS.
- AWS Fargate or EC2 launch type where appropriate.
- AWS Lambda.
- Amazon EKS.

## 3. Load Balancing

Application Load Balancer provides traffic distribution and health checking for supported application deployments.

## 4. Content Delivery

Amazon CloudFront provides CDN functionality for supported frontend delivery and static content.

## 5. Storage

Amazon S3 supports object storage and other application storage requirements.

## 6. Infrastructure Naming

Example resource naming convention:

| Resource | Example Name |
|---|---|
| VPC | CafeDevVPC |
| EC2 | CafeDevWebServer |
| RDS | CafeRDS |
| ECS Cluster | charlie-cluster |
| ECS Service | charlie-service |
| ECR Repository | charlie-cafe |
| Lambda | charlie-cafe-order-function |
| SQS Queue | charlie-cafe-orders |
| Security Group | CafeRDS-SG |

Actual resource names can vary between environments.

---

# 🌐 Networking Architecture

The project uses a VPC-based architecture to separate public-facing components from private application and database workloads.

## Network Design

| Component | Example CIDR |
|---|---|
| VPC | 10.0.0.0/16 |
| Public Subnet | 10.0.1.0/24 |
| Private Subnet 1 | 10.0.2.0/24 |
| Private Subnet 2 | 10.0.3.0/24 |

These are example development CIDRs and should be adjusted to avoid address conflicts.

## Public Subnets

Used for components that require controlled public connectivity, such as:

- Application Load Balancer.
- NAT Gateway.
- Internet-facing infrastructure.

## Private Subnets

Used for:

- Application workloads.
- ECS tasks.
- Lambda network connectivity where required.
- Internal services.

## Database Subnets

RDS should be deployed in private database subnets with public accessibility disabled.

## VPC Endpoints

The architecture supports private AWS service communication through:

- Secrets Manager Interface Endpoint.
- SQS Interface Endpoint.
- CloudWatch Logs Interface Endpoint.
- ECR API Interface Endpoint.
- ECR Docker Interface Endpoint.
- S3 Gateway Endpoint.
- DynamoDB Gateway Endpoint.

VPC endpoint availability and routing must be configured according to each workload's actual network requirements.

---

# 🗄️ Database Architecture

The project uses relational and NoSQL database technologies.

## Amazon RDS

Amazon RDS provides relational database storage.

Example database:

`cafedb`

Example database responsibilities:

- Customer records.
- Employee information.
- Menu information.
- Order records.
- Payment records.

## Amazon DynamoDB

DynamoDB provides scalable NoSQL storage for workloads requiring key-value or document-oriented access.

Example logical tables:

| Table | Purpose |
|---|---|
| CafeMenu | Menu information |
| CafeOrders | Order information |
| CafeOrderMetrics | Order metrics |
| CafeAttendance | Employee attendance |

## Database Security

- Disable public database access.
- Use private database subnets.
- Restrict port 3306 to authorized security groups.
- Store database credentials in Secrets Manager.
- Enable encryption at rest.
- Use TLS for supported database connections.
- Apply least-privilege database permissions.
- Configure backups and recovery.

## SQL Documentation

Database configuration and SQL files are maintained under the infrastructure documentation and database directories.

---

# ⚡ Serverless Architecture

The project uses AWS Lambda and API Gateway to support serverless backend processing.

## AWS Lambda

Lambda functions handle application operations such as:

- Order processing.
- Backend business logic.
- Database integration.
- Event processing.
- Application automation.

## Amazon API Gateway

API Gateway exposes backend functionality through managed HTTP APIs.

Responsibilities:

- API endpoint management.
- Request routing.
- Integration with Lambda.
- Authentication integration.
- Request validation and throttling where configured.

## Amazon SQS

SQS provides asynchronous communication between application components.

Example order flow:

```text
Customer
   |
   v
Frontend Application
   |
   v
API Gateway
   |
   v
Order Lambda
   |
   v
Amazon SQS
   |
   v
Order Processing Lambda
   |
   v
Database
   |
   v
Order Status Update
```

This design helps separate customer requests from background processing.

For reliable event processing, configure retry behavior, visibility timeouts, dead-letter queues and idempotent consumers.

---

# 🐳 Containerization

Docker is used to package the application and its runtime dependencies.

## Docker Architecture

The project uses Docker to package the PHP and Apache application environment.

Main files:

- `docker/apache-php/Dockerfile`
- `docker-compose.yml`
- `.dockerignore`

## Local Container Environment

Docker Compose can be used to run the supported application and database services locally.

Example:

```bash
docker compose up -d --build
```

Check running containers:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs -f
```

Stop containers:

```bash
docker compose down
```

## Amazon ECR

Amazon Elastic Container Registry stores application container images.

Example image workflow:

```text
Application Source
       |
       v
Docker Build
       |
       v
Container Image
       |
       v
Amazon ECR
       |
       v
Amazon ECS
```

Use immutable image tags for deployment traceability rather than relying exclusively on `latest`.

---

# 🚀 Amazon ECS Deployment

Amazon ECS is used to run containerized application workloads.

## ECS Components

- ECS Cluster.
- ECS Service.
- Task Definition.
- Container Image.
- Application Load Balancer.
- Target Groups.
- Task Execution Role.
- Task IAM Role.
- CloudWatch Log Groups.

## Deployment Architecture

```text
GitHub Repository
       |
       v
GitHub Actions
       |
       v
Docker Build
       |
       v
Amazon ECR
       |
       v
ECS Task Definition
       |
       v
ECS Service
       |
       v
Application Load Balancer
       |
       v
Charlie Cafe Application
```

## Deployment Strategies

### Rolling Deployment

Gradually replaces existing application tasks with updated tasks.

### Blue/Green Deployment

Uses separate blue and green deployment environments to support controlled traffic switching.

### Canary Deployment

Introduces a new version to a small portion of traffic before increasing exposure.

### Automatic Rollback

Deployment failures and configured CloudWatch alarms can trigger rollback when the deployment strategy supports it.

---

# 🔄 CI/CD Pipeline

GitHub Actions automates application build, validation and deployment.

## Pipeline Objectives

- Automated source checkout.
- Application validation.
- Docker image building.
- Container image tagging.
- Amazon ECR authentication.
- Image publishing.
- Deployment initiation.
- Deployment verification.
- Failure reporting.

## CI/CD Workflow

```text
Developer
    |
    v
Git Push
    |
    v
GitHub Repository
    |
    v
GitHub Actions
    |
    v
Source Validation
    |
    v
Docker Build
    |
    v
Amazon ECR
    |
    v
ECS Deployment
    |
    v
Health Checks
    |
    v
Deployment Success
```

## GitHub Actions

Workflow directory:

`.github/workflows/`

Deployment workflow:

`deploy.yml`

## Example Development Workflow

```bash
git add .
git commit -m "Update Charlie Cafe application"
git push origin main
```

GitHub Actions executes automatically when the workflow's configured trigger matches the push.

## CI/CD Security

Prefer GitHub Actions OpenID Connect (OIDC) with AWS IAM role assumption instead of long-lived AWS access keys.

Use:

- Restricted IAM permissions.
- Protected deployment branches.
- GitHub environment approvals.
- Encrypted secrets where needed.
- Deployment health checks.
- Versioned container images.

---

# 🏗️ Infrastructure as Code (IaC)

Infrastructure as Code is a major evolution of the Charlie Cafe project.

The existing AWS architecture will progressively move toward reusable and automated infrastructure provisioning.

## IaC Strategy

The project uses two complementary infrastructure technologies:

| Technology | Role |
|---|---|
| Terraform | Primary infrastructure provisioning approach |
| AWS CloudFormation | AWS-native infrastructure templates |

### 1. Terraform — Primary Implementation

Terraform is the first implementation priority for infrastructure automation.

Objectives:

- Provision AWS infrastructure using code.
- Create reusable Terraform modules.
- Separate environments.
- Manage infrastructure state.
- Automate infrastructure deployment.
- Support repeatable infrastructure provisioning.
- Reduce manual AWS configuration.

Planned Terraform modules:

| Module | Responsibility |
|---|---|
| VPC | Networking infrastructure |
| Subnets | Public and private networking |
| Security Groups | Network access control |
| IAM | Roles and policies |
| EC2 | Virtual machine infrastructure |
| ALB | Load balancing |
| RDS | Relational database |
| DynamoDB | NoSQL database |
| S3 | Object storage |
| Lambda | Serverless functions |
| API Gateway | API infrastructure |
| SQS | Messaging |
| Cognito | Authentication |
| ECR | Container registry |
| ECS | Container services |
| CloudWatch | Monitoring |

### Terraform Environment Strategy

Planned environment separation:

```text
terraform/
│
├── modules/
│   ├── vpc/
│   ├── iam/
│   ├── ec2/
│   ├── alb/
│   ├── rds/
│   ├── dynamodb/
│   ├── lambda/
│   ├── api-gateway/
│   ├── sqs/
│   ├── cognito/
│   ├── ecr/
│   ├── ecs/
│   └── cloudwatch/
│
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
│
├── backend/
│
├── versions.tf
├── providers.tf
└── README.md
```

This is the planned Terraform architecture; it does not imply that all modules or environments have already been implemented.

### Terraform Workflow

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

For infrastructure removal:

```bash
terraform plan -destroy
terraform destroy
```

Review every plan before applying changes.

### Terraform State Management

The intended remote-state architecture uses:

- Amazon S3 for Terraform state.
- State locking supported by the selected Terraform backend configuration.
- Encryption at rest.
- Restricted IAM access.
- State versioning and recovery.
- Separate state files for independent environments.

Never commit Terraform state files, state backups or sensitive variable files to Git.

### 2. AWS CloudFormation

The repository already includes a `cloudformation/` directory.

CloudFormation is retained as the AWS-native IaC implementation.

Its role includes:

- AWS infrastructure templates.
- Stack-based resource management.
- Parameterized deployments.
- Infrastructure repeatability.
- AWS-native deployment workflows.

Terraform remains the first implementation priority.

---

# ☸️ Kubernetes Architecture

Kubernetes is the next major container orchestration objective.

The project targets both local Kubernetes environments and Amazon Elastic Kubernetes Service (EKS).

## Kubernetes Objectives

- Deploy containerized Charlie Cafe workloads.
- Manage application pods.
- Configure Kubernetes services.
- Manage application configuration.
- Implement health probes.
- Configure resource requests and limits.
- Support horizontal scaling.
- Manage deployments and rollbacks.
- Integrate Kubernetes with CI/CD.

## 1. Local Kubernetes

The local Kubernetes environment will provide a development and testing platform.

Supported implementation targets may include:

- Minikube.
- kind.
- Docker Desktop Kubernetes.

## 2. Amazon EKS

Amazon EKS will provide managed Kubernetes infrastructure on AWS.

Planned components:

- EKS Cluster.
- Managed Node Groups or supported compute alternatives.
- Kubernetes Deployments.
- Services.
- Ingress.
- AWS Load Balancer Controller.
- ConfigMaps.
- Secrets.
- Horizontal Pod Autoscaler.
- Cluster monitoring.

## Kubernetes Application Flow

```text
GitHub Repository
       |
       v
GitHub Actions
       |
       v
Docker Build
       |
       v
Amazon ECR
       |
       v
Kubernetes Deployment
       |
       v
Kubernetes Service
       |
       v
Ingress / Load Balancer
       |
       v
Charlie Cafe Application
```

## Kubernetes Deployment Structure

Planned directory:

```text
kubernetes/
│
├── base/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── ingress.yaml
│   └── hpa.yaml
│
├── overlays/
│   ├── local/
│   └── eks/
│
└── README.md
```

Kubernetes manifests and environment overlays will be introduced during the Kubernetes implementation phase.

---

# 🔐 Security Architecture

Security is a core design requirement.

## Identity and Access Management

AWS IAM provides identity-based access control.

Implementation objectives:

- Least-privilege IAM policies.
- EC2 instance roles.
- Lambda execution roles.
- ECS task execution roles.
- ECS task roles.
- GitHub Actions deployment roles.
- EKS workload IAM integration where required.

## Authentication

Amazon Cognito provides customer and employee authentication capabilities.

## Secrets Management

AWS Secrets Manager stores sensitive application credentials.

Examples:

- Database credentials.
- API credentials.
- Application secrets.

Never hardcode credentials in source code or Docker images.

## Network Security

- Private database subnets.
- Restricted Security Groups.
- No public database access.
- HTTPS communication.
- VPC Endpoints where appropriate.
- Restricted administrative access.

## Container Security

- Trusted base images.
- Minimal container images.
- Image vulnerability scanning.
- Non-root containers where supported.
- No secrets embedded in images.
- Restricted container permissions.

## Infrastructure Security

- Encrypted Terraform state.
- Restricted state access.
- Protected GitHub branches.
- Secret scanning.
- IAM policy reviews.
- Infrastructure change reviews.

---

# 📊 Monitoring and Logging

Amazon CloudWatch provides infrastructure and application observability.

## Monitoring Objectives

- EC2 health.
- ECS service health.
- Container CPU and memory.
- Lambda execution metrics.
- Lambda errors.
- SQS queue depth.
- RDS database metrics.
- ALB request metrics.
- Target group health.
- Deployment status.

## Logging

CloudWatch Logs can collect logs from:

- Lambda functions.
- ECS containers.
- Application components.
- Supported deployment processes.

## Alerting

Planned monitoring includes:

- CloudWatch Alarms.
- Unhealthy target monitoring.
- Lambda error alarms.
- Resource utilization alarms.
- Application health monitoring.
- Deployment failure notifications.

---

# 📁 Repository Structure

The project maintains one main GitHub repository.

Repository:

https://github.com/awsrmmustansarjavaid/charlie-cafe-devops

## Current Repository Layout

The following reflects the major top-level directories and files currently present in the repository:

```text
charlie-cafe-devops/
│
├── README.md
├── .gitignore
├── .dockerignore
├── appspec.yaml
├── docker-compose.yml
│
├── app/
│   ├── frontend/
│   └── backend/
│       └── lambda/
│
├── cloudformation/
│
├── docker/
│   └── apache-php/
│       └── Dockerfile
│
├── infrastructure/
│   ├── rds/
│   └── scripts/
│
├── docs/
│   └── Charlie Cafe Project Lab Configurations/
│
└── .github/
    └── workflows/
        └── deploy.yml
```

## Planned Extended Repository Architecture

As Terraform and Kubernetes are implemented, the repository will progressively evolve toward:

```text
charlie-cafe-devops/
│
├── README.md
├── LICENSE
├── .gitignore
├── .dockerignore
├── docker-compose.yml
├── appspec.yaml
│
├── app/
│   ├── frontend/
│   └── backend/
│       └── lambda/
│
├── docker/
│   └── apache-php/
│       └── Dockerfile
│
├── infrastructure/
│   │
│   ├── terraform/
│   │   ├── modules/
│   │   ├── environments/
│   │   ├── backend/
│   │   └── README.md
│   │
│   ├── cloudformation/
│   │
│   ├── rds/
│   │   ├── schema.sql
│   │   ├── data.sql
│   │   └── verify.sql
│   │
│   └── scripts/
│
├── kubernetes/
│   ├── base/
│   ├── overlays/
│   │   ├── local/
│   │   └── eks/
│   └── README.md
│
├── helm/
│
├── tests/
│   ├── application/
│   ├── infrastructure/
│   └── deployment/
│
├── docs/
│   ├── architecture/
│   ├── deployment/
│   ├── terraform/
│   ├── kubernetes/
│   ├── security/
│   └── Charlie Cafe Project Lab Configurations/
│
└── .github/
    └── workflows/
        ├── deploy.yml
        ├── terraform.yml
        ├── docker.yml
        └── kubernetes.yml
```

The extended layout is a target architecture, not a statement that every directory already exists.

**Repository strategy:** Continue developing the existing repository without splitting the project into separate repositories.

---

# 📦 Prerequisites

## 1. Accounts

- GitHub account.
- AWS account.

## 2. Development Environment

- Linux, Windows or macOS.
- Git.
- Docker.
- Docker Compose.
- AWS CLI.
- Terraform.
- Python.
- PHP.
- MySQL client.

## 3. AWS Knowledge

Recommended knowledge:

- IAM.
- VPC.
- EC2.
- Security Groups.
- RDS.
- S3.
- Lambda.
- API Gateway.
- SQS.
- ECS.
- ECR.
- CloudWatch.

## 4. Kubernetes Tools

Required during Kubernetes implementation:

- kubectl.
- Helm.
- Local Kubernetes runtime.
- AWS CLI.
- eksctl where required.

---

# 💻 Local Development Setup

## 1. Clone Repository

```bash
git clone https://github.com/awsrmmustansarjavaid/charlie-cafe-devops.git

cd charlie-cafe-devops
```

## 2. Review Project Structure

```bash
ls -la
```

## 3. Build Docker Environment

```bash
docker compose build
```

## 4. Start Application

```bash
docker compose up -d
```

## 5. Check Container Status

```bash
docker compose ps
```

## 6. View Logs

```bash
docker compose logs -f
```

## 7. Stop Application

```bash
docker compose down
```

Configure environment-specific application variables and database credentials before starting services.

---

# ☁️ AWS Deployment

The AWS deployment is organized into logical implementation phases.

## Phase 1: AWS Foundation

- Create AWS networking.
- Configure VPC.
- Create public and private subnets.
- Configure route tables.
- Create Security Groups.
- Configure IAM roles.

## Phase 2: Compute Infrastructure

- Launch EC2 where required.
- Configure application hosting.
- Install required dependencies.
- Configure application health checks.

## Phase 3: Database Infrastructure

- Create RDS database.
- Configure database subnet group.
- Create database Security Group.
- Configure Secrets Manager.
- Deploy database schema.
- Validate connectivity.

## Phase 4: Serverless Backend

- Create Lambda functions.
- Configure Lambda execution roles.
- Configure VPC connectivity where required.
- Create SQS queues.
- Integrate API Gateway.
- Configure authentication.

## Phase 5: Container Infrastructure

- Create ECR repository.
- Build Docker image.
- Push image to ECR.
- Create ECS cluster.
- Configure task definitions.
- Create ECS service.
- Configure ALB.

## Phase 6: CI/CD

- Configure GitHub Actions.
- Configure AWS deployment authentication.
- Add required GitHub secrets and variables.
- Configure deployment workflow.
- Test automated deployments.

## Phase 7: Advanced Deployment

- Configure blue/green deployment where applicable.
- Configure health checks.
- Configure CloudWatch alarms.
- Configure rollback.
- Validate deployment behavior.

## Phase 8: Infrastructure as Code

- Implement Terraform modules.
- Configure remote state.
- Provision development infrastructure.
- Validate infrastructure plans.
- Introduce additional environments.

## Phase 9: Kubernetes

- Configure local Kubernetes.
- Deploy Charlie Cafe workloads locally.
- Configure application services.
- Implement Kubernetes health probes.
- Provision Amazon EKS.
- Deploy application to EKS.
- Integrate Kubernetes with CI/CD.

**Detailed manual AWS configuration:** See the project configuration documentation in `docs/Charlie Cafe Project Lab Configurations/`.

---

# 🧪 Testing and Validation

Testing is required at every layer.

## Application Testing

- Frontend availability.
- Backend functionality.
- API responses.
- Authentication.
- Order processing.
- Database connectivity.

## Infrastructure Testing

- VPC connectivity.
- Subnet routing.
- Security Group rules.
- IAM permissions.
- RDS connectivity.
- VPC Endpoint connectivity.

## Container Testing

- Docker image builds.
- Container startup.
- Application health checks.
- Container logs.
- Environment configuration.

## CI/CD Testing

- Workflow execution.
- Build validation.
- Image publishing.
- Deployment success.
- Health verification.
- Rollback testing.

## Terraform Testing

- Terraform formatting.
- Terraform validation.
- Terraform plan review.
- Infrastructure deployment.
- Infrastructure drift checks.

## Kubernetes Testing

- Pod status.
- Deployment status.
- Service connectivity.
- Ingress availability.
- Readiness probes.
- Liveness probes.
- Horizontal scaling.
- Rollback validation.

---

# 📈 High Availability and Scalability

The architecture is designed to support future business growth.

## Application Availability

- Multiple application tasks where required.
- Load balancing.
- Health checks.
- Automated replacement of unhealthy tasks.
- Deployment rollback.

## Database Availability

- Private database networking.
- Automated backups.
- Multi-AZ deployment where required.
- Recovery planning.

## Application Scalability

- ECS service scaling.
- Lambda concurrency configuration.
- SQS-based decoupling.
- Kubernetes Horizontal Pod Autoscaler.
- Load-balanced application services.

## Traffic Management

- Application Load Balancer.
- CloudFront.
- API Gateway throttling.
- Application-level rate limiting.

---

# 💰 Cost Optimization

AWS infrastructure costs must be considered throughout development.

## Cost Optimization Strategies

- Use appropriate EC2 instance sizes.
- Stop unused development resources.
- Avoid unnecessary NAT Gateways.
- Use VPC Endpoints where economically appropriate.
- Monitor data transfer costs.
- Configure ECS task sizing.
- Use Lambda for suitable event-driven workloads.
- Configure CloudWatch log retention.
- Review RDS sizing and storage.
- Use budgets and cost alerts.

## Important AWS Cost Considerations

Some AWS services incur charges even when application traffic is low.

Pay particular attention to:

- NAT Gateway.
- Application Load Balancer.
- RDS instances.
- EKS control plane.
- EC2 instances.
- VPC Interface Endpoints.
- Data transfer.
- CloudWatch ingestion and retention.

**Recommendation:** Use development-sized infrastructure and destroy temporary resources when they are no longer required.

---

# 📚 Documentation

The repository contains implementation guides and supporting technical documentation.

## Main Documentation

| Documentation | Description |
|---|---|
| Main README | Project overview and architecture |
| AWS Charlie Cafe Project | AWS project configuration |
| Charlie Cafe Data Flow | Application data flow |
| DevOps Cheatsheet | DevOps reference commands |
| Docker Configuration | Container setup |
| AWS IAM Documentation | IAM roles and policies |
| Infrastructure Scripts | Deployment and automation scripts |

## Documentation Location

```text
docs/
│
└── Project Lab Configurations/
```

For detailed AWS setup instructions, refer to the existing configuration guides in that directory.

---

# 🗺️ Implementation Roadmap

The project will evolve through the following stages.

## Phase 1 — Application and Repository Foundation

- [x] Establish Charlie Cafe GitHub repository.
- [x] Organize core application and DevOps components.
- [x] Add Docker configuration.
- [x] Add Docker Compose configuration.
- [x] Add AWS deployment documentation.
- [ ] Standardize application tests.

## Phase 2 — AWS Cloud Foundation

- [x] Document VPC architecture.
- [x] Document EC2 configuration.
- [x] Document database configuration.
- [x] Document IAM roles and policies.
- [ ] Standardize infrastructure validation.
- [ ] Complete automated infrastructure provisioning.

## Phase 3 — Serverless Architecture

- [x] Document Lambda architecture.
- [x] Document API Gateway integration.
- [x] Document SQS architecture.
- [ ] Complete automated serverless testing.
- [ ] Validate asynchronous processing and failure handling.

## Phase 4 — Docker and ECS

- [x] Add Docker application configuration.
- [x] Add Docker Compose.
- [x] Document ECR.
- [x] Document ECS deployment.
- [x] Document advanced deployment strategies.
- [ ] Standardize container security scanning.

## Phase 5 — CI/CD Automation

- [x] Add GitHub Actions deployment workflow.
- [x] Document automated deployment.
- [x] Document ECS deployment integration.
- [ ] Implement stronger automated testing.
- [ ] Integrate secure OIDC authentication.
- [ ] Standardize deployment approvals and rollback validation.

## Phase 6 — Terraform Implementation

- [ ] Design Terraform repository architecture.
- [ ] Configure Terraform providers.
- [ ] Configure remote state.
- [ ] Implement reusable modules.
- [ ] Implement VPC module.
- [ ] Implement IAM module.
- [ ] Implement database modules.
- [ ] Implement Lambda and API Gateway modules.
- [ ] Implement SQS module.
- [ ] Implement ECS and ECR modules.
- [ ] Implement CloudWatch module.
- [ ] Configure development environment.
- [ ] Integrate Terraform with GitHub Actions.

## Phase 7 — CloudFormation

- [x] Establish CloudFormation repository area.
- [ ] Standardize reusable CloudFormation templates.
- [ ] Validate stack deployment.
- [ ] Document template parameters and outputs.

## Phase 8 — Local Kubernetes

- [ ] Configure local Kubernetes environment.
- [ ] Create namespace.
- [ ] Create application Deployment.
- [ ] Create Kubernetes Service.
- [ ] Configure ConfigMaps.
- [ ] Configure Secrets.
- [ ] Implement health probes.
- [ ] Implement resource requests and limits.
- [ ] Configure autoscaling.
- [ ] Test deployment and rollback.

## Phase 9 — Amazon EKS

- [ ] Design EKS architecture.
- [ ] Provision EKS infrastructure.
- [ ] Configure cluster access.
- [ ] Configure managed compute.
- [ ] Integrate Amazon ECR.
- [ ] Deploy Charlie Cafe workloads.
- [ ] Configure ingress and load balancing.
- [ ] Configure workload IAM.
- [ ] Implement monitoring.
- [ ] Integrate EKS with GitHub Actions.

## Phase 10 — Production Readiness

- [ ] Complete security reviews.
- [ ] Complete infrastructure validation.
- [ ] Complete application testing.
- [ ] Configure backup and recovery.
- [ ] Configure monitoring and alerting.
- [ ] Validate scaling.
- [ ] Validate disaster recovery.
- [ ] Document operational procedures.

---

# 🔧 Troubleshooting

| Problem | Possible Cause | Recommended Action |
|---|---|---|
| EC2 SSH failure | Incorrect Security Group or key permissions | Validate SSH access |
| RDS connection failure | Incorrect routing or Security Group | Check private networking |
| Lambda timeout | Missing permissions or connectivity | Review Lambda logs and VPC |
| SQS processing failure | Incorrect IAM permissions | Validate queue permissions |
| Docker build failure | Invalid Dockerfile or dependencies | Review build logs |
| ECR authentication failure | Missing IAM permissions | Validate ECR access |
| ECS task failure | Image, networking or configuration issue | Inspect ECS events |
| ALB unhealthy targets | Incorrect health check or application port | Validate target group |
| GitHub Actions failure | Incorrect workflow configuration | Inspect workflow logs |
| Terraform failure | Invalid configuration or state issue | Run validation and review state |
| Kubernetes pod failure | Image, configuration or resource issue | Inspect pod events and logs |

---

# 🔒 Security Best Practices

The following practices should be followed throughout development and deployment:

1. Never commit AWS credentials.
2. Never expose database ports publicly.
3. Prefer IAM roles over static credentials.
4. Use GitHub OIDC for AWS authentication.
5. Store secrets in AWS Secrets Manager.
6. Use private subnets for internal workloads.
7. Restrict inbound Security Group rules.
8. Encrypt sensitive data.
9. Enable appropriate logging and monitoring.
10. Use container image scanning.
11. Protect production deployment workflows.
12. Review Terraform plans before applying changes.
13. Protect remote Terraform state.
14. Use Kubernetes RBAC.
15. Avoid storing sensitive information in container images or Git repositories.

---

# ☕ Charlie Cafe Lab Configurations

This section provides a comprehensive, step-by-step configuration guide for implementing the **Charlie Cafe AWS DevOps Project** end to end.

Follow the manual configuration instructions to set up, configure, and deploy all required AWS and DevOps components.

## Phase 1	Manually created AWS infrastructure, Bash automation, Docker and application deployment

**Project Configuration Guide:** [AWS DevOps Charlie Cafe Project](./docs/project_configurations_guide/AWS%20DevOps%20Charlie%20Cafe%20Project.md)


---

# 🤝 Contributing

Contributions and suggestions are welcome.

Recommended contribution workflow:

```bash
git clone https://github.com/awsrmmustansarjavaid/charlie-cafe-devops.git

cd charlie-cafe-devops

git checkout -b feature/your-feature

git add .

git commit -m "Add your feature"

git push origin feature/your-feature
```

Open a Pull Request for review.

Please follow these guidelines:

- Keep code clean and maintainable.
- Document infrastructure changes.
- Avoid committing credentials.
- Test configuration changes.
- Follow consistent naming conventions.
- Keep deployment instructions updated.

---

# 📄 License

This project is maintained in the Charlie Cafe DevOps GitHub repository.

See the repository's [LICENSE](./LICENSE) file for licensing information.

---

# 👨‍💻 Project Repository

**Project:** Charlie Cafe DevOps

**Repository:**  
https://github.com/awsrmmustansarjavaid/charlie-cafe-devops

**Primary Cloud Platform:** Amazon Web Services (AWS)

**Infrastructure as Code:** Terraform and CloudFormation

**Containerization:** Docker

**Container Orchestration:** Amazon ECS and Kubernetes (local and Amazon EKS)

**CI/CD:** GitHub Actions

---

# ☕ Final Project Vision

Charlie Cafe DevOps is designed to demonstrate how a traditional application can evolve into a modern cloud-native platform through the adoption of professional DevOps engineering practices.

The project brings together:

- Application development.
- AWS cloud architecture.
- Cloud networking.
- Serverless computing.
- Database engineering.
- Docker containerization.
- Automated CI/CD.
- Infrastructure as Code.
- Kubernetes orchestration.
- Cloud security.
- Monitoring and observability.

The long-term objective is to build a reusable, automated and scalable cloud platform that demonstrates the complete DevOps lifecycle, from source code to production deployment.

**Build. Automate. Secure. Deploy. Scale.**

### ☕ Charlie Cafe DevOps Project
