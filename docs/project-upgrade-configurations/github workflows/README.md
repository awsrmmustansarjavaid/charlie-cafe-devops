# GitHub Actions Workflows – Charlie Cafe DevOps Project

## 1. Overview

This directory contains the GitHub Actions CI/CD workflow configurations for the Charlie Cafe AWS DevOps project.

The project maintains two versions of its GitHub Actions workflows:

- **Legacy Version:** The original production CI/CD pipeline used during the initial manual AWS infrastructure implementation.
- **Terraform Version:** The updated CI/CD workflow designed to integrate with Terraform-managed AWS infrastructure and modern AWS authentication practices.

Both workflow versions are maintained separately to preserve the original deployment implementation and document the transition toward a more secure, reusable, and Infrastructure as Code (IaC) driven CI/CD architecture.

The main objective of this directory is to maintain deployment history, document workflow improvements, and provide a clear reference for the GitHub Actions migration.

## 2. Directory Structure

```text
docs/
└──project-upgrade-configurations/
    └── Github workflows/
        ├── README.md
        │
        ├── legacy/
        │   └── [legacy-workflow-file].yml
        │
        └── terraform/
            └── [terraform-workflow-file].yml
```

### Directory Description

| Directory | Purpose |
|---|---|
| `README.md` | Main documentation for GitHub Actions CI/CD workflows. |
| `legacy/` | Contains the original production CI/CD workflow. |
| `terraform/` | Contains the updated Terraform-compatible CI/CD workflow. |

## 3. Legacy GitHub Actions Workflow

**Location:** `legacy/`

The legacy workflow represents the original Charlie Cafe production CI/CD pipeline.

It was designed to automate application testing, EC2 deployment, Docker image publishing, ECS task definition registration, and production deployment through AWS CodeDeploy.

### Code

```
name: ☕ Charlie Cafe — PRODUCTION CI/CD PIPELINE (FINAL)

on:
  push:
    branches: ["main"]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    # -------------------------------------------------
    # 🌍 GLOBAL ENV VARIABLES (SAFE)
    # -------------------------------------------------
    env:
      IMAGE_TAG: ${{ github.sha }}   # Will be overridden with short SHA

    steps:

    # =================================================
    # 1️⃣ SOURCE CODE
    # =================================================
    - name: 📥 Checkout Code
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 🔤 Convert Git SHA to short version (7 chars)
    # -------------------------------------------------
    - name: 🔤 Short SHA
      run: echo "IMAGE_TAG=${GITHUB_SHA::7}" >> $GITHUB_ENV

    # =================================================
    # 2️⃣ AWS CONFIGURATION
    # =================================================
    - name: 🔐 Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    # =================================================
    # 3️⃣ CI ENV SETUP
    # =================================================
    - name: 🧰 Install Required Tools
      run: |
        sudo apt-get update
        sudo apt-get install -y jq curl zip python3-pip mysql-client

    # =================================================
    # 4️⃣ CI TEST (LOCAL DOCKER BUILD)
    # =================================================
    - name: 🐳 Build Docker Image (CI)
      run: |
        docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # Run container locally for testing
    # -------------------------------------------------
    - name: 🚀 Run Container (CI Test)
      run: |
        docker rm -f test_app || true
        docker run -d -p 80:80 --name test_app charlie-cafe
        sleep 10

    # -------------------------------------------------
    # Health check for CI validation
    # -------------------------------------------------
    - name: ❤️ Health Check (CI)
      run: curl -f http://localhost/health.php || exit 1

    # -------------------------------------------------
    # Cleanup CI container
    # -------------------------------------------------
    - name: 🧹 Cleanup CI Container
      run: docker rm -f test_app || true

    # =================================================
    # 🚀 EC2 DEPLOYMENT (SSM - DEV/STAGE)
    # =================================================
    - name: 🚀 Deploy to EC2 via SSM
      run: |
        COMMAND_ID=$(aws ssm send-command \
          --targets "Key=InstanceIds,Values=${{ secrets.EC2_INSTANCE_ID }}" \
          --document-name "AWS-RunShellScript" \
          --parameters commands=["bash /home/ec2-user/charlie-cafe-devops/deploy_master.sh"] \
          --query "Command.CommandId" \
          --output text)

        echo "COMMAND_ID=$COMMAND_ID" >> $GITHUB_ENV

    # -------------------------------------------------
    # Wait for EC2 deployment completion
    # -------------------------------------------------
    - name: ⏳ Wait for EC2 Deployment
      run: |
        aws ssm wait command-executed \
          --command-id $COMMAND_ID \
          --instance-id ${{ secrets.EC2_INSTANCE_ID }}

    # -------------------------------------------------
    # Verify EC2 deployment status
    # -------------------------------------------------
    - name: 🔍 Verify EC2 Deployment Status
      run: |
        STATUS=$(aws ssm get-command-invocation \
          --command-id $COMMAND_ID \
          --instance-id ${{ secrets.EC2_INSTANCE_ID }} \
          --query "Status" \
          --output text)

        echo "EC2 STATUS = $STATUS"

        if [ "$STATUS" != "Success" ]; then
          echo "❌ EC2 deployment failed"
          exit 1
        fi

    # -------------------------------------------------
    # Get EC2 public IP
    # -------------------------------------------------
    - name: 🌐 Get EC2 Public IP
      run: |
        INSTANCE_IP=$(aws ec2 describe-instances \
          --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
          --query "Reservations[0].Instances[0].PublicIpAddress" \
          --output text)

        echo "INSTANCE_IP=$INSTANCE_IP" >> $GITHUB_ENV

    # -------------------------------------------------
    # EC2 application verification
    # -------------------------------------------------
    - name: 🌐 EC2 App Health Check
      run: curl -f http://$INSTANCE_IP/health.php || exit 1

    # =================================================
    # 🎉 EC2 SUCCESS
    # =================================================
    - name: 🎉 EC2 Deployment Success
      run: echo "EC2 Deployment Completed Successfully 🚀"

    # =================================================
    # ⚡ ECS DEPLOYMENT (PRODUCTION)
    # =================================================

    # -------------------------------------------------
    # 5️⃣ Login to Amazon ECR
    # -------------------------------------------------
    - name: 🐳 Login to Amazon ECR
      run: |
        aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | \
        docker login --username AWS --password-stdin \
        ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

    # -------------------------------------------------
    # 6️⃣ Build ECS Image with Git SHA
    # -------------------------------------------------
    - name: 🏗️ Build ECS Image
      run: |
        docker build \
          -t ${{ secrets.ECR_REPO }}:$IMAGE_TAG \
          -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 7️⃣ Tag ECS Image
    # -------------------------------------------------
    - name: 🏷️ Tag ECS Image
      run: |
        docker tag \
          ${{ secrets.ECR_REPO }}:$IMAGE_TAG \
          ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG

    # -------------------------------------------------
    # 8️⃣ Push ECS Image
    # -------------------------------------------------
    - name: 📤 Push ECS Image
      run: |
        docker push \
          ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG

    # =================================================
    # 📦 TASK DEFINITION (SAFE RENDER)
    # =================================================
    - name: 📄 Render Task Definition
      run: |
        cp .github/task-definition.json task-def.json

        sed -i "s#IMAGE_PLACEHOLDER#${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPO }}:$IMAGE_TAG#g" task-def.json

    # -------------------------------------------------
    # Register ECS Task Definition
    # -------------------------------------------------
    - name: 📦 Register ECS Task Definition
      run: |
        TASK_DEF_ARN=$(aws ecs register-task-definition \
          --cli-input-json file://task-def.json \
          --query 'taskDefinition.taskDefinitionArn' \
          --output text)

        echo "TASK_DEF_ARN=$TASK_DEF_ARN" >> $GITHUB_ENV

    # =================================================
    # 🔄 APPSPEC (SAFE RENDER)
    # =================================================
    - name: 📄 Prepare AppSpec
      run: |
        cp appspec.yaml appspec-rendered.yaml
        sed -i "s#TASK_DEFINITION#${TASK_DEF_ARN}#g" appspec-rendered.yaml

    # =================================================
    # 🚀 CODEDEPLOY (CANARY DEPLOYMENT)
    # =================================================
    - name: 🚀 Deploy via AWS CodeDeploy
      run: |
        DEPLOYMENT_ID=$(aws deploy create-deployment \
          --application-name charlie-ecs-app \
          --deployment-group-name charlie-ecs-deployment-group \
          --deployment-config-name CodeDeployDefault.ECSCanary10Percent5Minutes \
          --revision revisionType=AppSpecContent,appSpecContent="{\"content\": \"$(cat appspec-rendered.yaml | sed 's/\"/\\\"/g')\"}" \
          --query "deploymentId" \
          --output text)

        echo "DEPLOYMENT_ID=$DEPLOYMENT_ID" >> $GITHUB_ENV
        echo "🚀 Deployment ID: $DEPLOYMENT_ID"

    # -------------------------------------------------
    # Wait for deployment to complete
    # -------------------------------------------------
    - name: ⏳ Wait for CodeDeploy
      run: |
        aws deploy wait deployment-successful --deployment-id $DEPLOYMENT_ID

    # =================================================
    # 🎉 FINAL SUCCESS
    # =================================================
    - name: 🎉 Full Pipeline Success
      run: echo "🎉 Charlie Cafe FULL CI/CD Pipeline Completed Successfully 🚀"
```

### 3.1 Workflow Trigger

The legacy workflow automatically executes whenever changes are pushed to the `main` branch.

```yaml
on:
  push:
    branches: ["main"]
```

This provides automatic continuous integration and continuous deployment whenever new code is merged or pushed to the production branch.

### 3.2 Pipeline Architecture

The legacy workflow contains the following major stages:

**Stage 1 – Source Code Checkout**

- Checks out the latest repository source code.
- Generates a shortened seven-character Git commit SHA.
- Uses the shortened SHA as the Docker image tag.

**Stage 2 – AWS Configuration**

- Configures AWS credentials through GitHub Secrets.
- Uses AWS access key and secret access key authentication.
- Retrieves the AWS region from repository secrets.

**Stage 3 – CI Environment Setup**

Installs the required tools:

- jq
- curl
- zip
- Python pip
- MySQL client

**Stage 4 – Docker Build and Local Testing**

- Builds the Docker image using `docker/apache-php/Dockerfile`.
- Runs the container locally.
- Exposes application port 80.
- Performs an application health check through `health.php`.
- Removes the temporary testing container.

**Stage 5 – EC2 Deployment Through AWS Systems Manager**

- Sends deployment commands through AWS Systems Manager (SSM).
- Executes the existing `deploy_master.sh` deployment script.
- Waits for the SSM command to complete.
- Verifies the EC2 deployment status.
- Retrieves the EC2 public IP address.
- Performs an application health check against the deployed EC2 application.

**Stage 6 – Amazon ECR Image Publishing**

- Authenticates Docker with Amazon ECR.
- Builds the production Docker image.
- Tags the image using the shortened Git SHA.
- Pushes the image to the configured ECR repository.

**Stage 7 – ECS Task Definition Registration**

- Copies the original ECS task definition.
- Replaces `IMAGE_PLACEHOLDER` with the actual ECR image URI.
- Registers a new ECS task definition revision through AWS CLI.
- Retrieves the registered task definition ARN.

**Stage 8 – AWS CodeDeploy Preparation**

- Copies the original `appspec.yaml`.
- Replaces the task definition placeholder with the newly registered task definition ARN.
- Generates a deployment-ready AppSpec file.

**Stage 9 – Amazon ECS Production Deployment**

- Creates a CodeDeploy deployment using AWS CLI.
- Uses the `charlie-ecs-app` CodeDeploy application.
- Uses the `charlie-ecs-deployment-group` deployment group.
- Explicitly selects the canary deployment configuration:

`CodeDeployDefault.ECSCanary10Percent5Minutes`

- Waits for the CodeDeploy deployment to complete.

**Stage 10 – Pipeline Completion**

Reports successful completion of the Charlie Cafe CI/CD pipeline.

### 3.3 Legacy Workflow Characteristics

- Automatically triggered by pushes to `main`.
- Uses long-lived AWS credentials stored in GitHub Secrets.
- Performs local Docker testing before deployment.
- Supports EC2 deployment through AWS SSM.
- Performs EC2 deployment verification and application health checks.
- Publishes Docker images to Amazon ECR.
- Manually renders and registers ECS task definitions using AWS CLI.
- Deploys ECS applications through AWS CodeDeploy.
- Uses an explicitly configured canary deployment strategy.

### 3.4 Legacy AWS Authentication

The legacy workflow uses:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

These values are stored as GitHub repository secrets.

Although this authentication approach works, it requires maintaining long-lived AWS credentials.

The legacy implementation is retained for historical reference and comparison.

## 4. Terraform GitHub Actions Workflow

**Location:** `terraform/`

The Terraform workflow represents the updated CI/CD implementation designed for the Charlie Cafe Infrastructure as Code architecture.

Its primary objective is to improve AWS authentication security, support reusable deployment workflows, and simplify ECS deployment using official AWS GitHub Actions.

Unlike the legacy workflow, the new implementation uses AWS IAM OpenID Connect (OIDC) authentication.

### Code

```

# ==============================================================================
# Charlie Cafe - Application Deployment Pipeline
# ==============================================================================
#
# Purpose:
#   Automate the deployment of Charlie Cafe to AWS infrastructure.
#
# Supported deployment targets:
#   1. EC2  - Deploy the existing application using AWS Systems Manager (SSM).
#   2. ECS  - Build a Docker image, publish it to Amazon ECR, and deploy it
#             to Amazon ECS using AWS CodeDeploy blue/green deployments.
#   3. Both - Execute both deployment strategies.
#
# Security:
#   - Uses GitHub Actions OIDC authentication.
#   - Does not require permanent AWS access keys.
#   - Uses minimum GitHub token permissions.
#   - Keeps deployment configuration in GitHub Secrets or workflow inputs.
#
# Triggers:
#   - Manual execution through workflow_dispatch.
#   - Reusable execution through workflow_call.
#
# ==============================================================================

name: Charlie Cafe Application Deploy

# ------------------------------------------------------------------------------
# Workflow Triggers
# ------------------------------------------------------------------------------
on:

  # Allow authorized users to start deployments manually from GitHub Actions.
  workflow_dispatch:
    inputs:

      deployment_target:
        description: "Select the AWS deployment target."
        required: true
        type: choice
        default: both
        options:
          - ec2
          - ecs
          - both

      aws_region:
        description: "AWS deployment region."
        required: true
        type: string
        default: us-east-1

      ec2_instance_id:
        description: "EC2 instance ID (optional; falls back to GitHub Secret)."
        required: false
        type: string

      ecr_repository:
        description: "Amazon ECR repository name."
        required: false
        type: string

      ecs_cluster:
        description: "Amazon ECS cluster name."
        required: false
        type: string

      ecs_service:
        description: "Amazon ECS service name."
        required: false
        type: string

      codedeploy_application:
        description: "AWS CodeDeploy application name."
        required: false
        type: string

      codedeploy_deployment_group:
        description: "AWS CodeDeploy deployment group."
        required: false
        type: string

  # Allow other GitHub Actions workflows to reuse this deployment pipeline.
  workflow_call:
    inputs:

      deployment_target:
        description: "Deployment target: ec2, ecs, or both."
        required: false
        type: string
        default: both

      aws_region:
        description: "AWS deployment region."
        required: false
        type: string
        default: us-east-1

      ec2_instance_id:
        description: "EC2 instance ID."
        required: false
        type: string

      ecr_repository:
        description: "Amazon ECR repository name."
        required: false
        type: string

      ecs_cluster:
        description: "Amazon ECS cluster name."
        required: false
        type: string

      ecs_service:
        description: "Amazon ECS service name."
        required: false
        type: string

      codedeploy_application:
        description: "AWS CodeDeploy application name."
        required: false
        type: string

      codedeploy_deployment_group:
        description: "AWS CodeDeploy deployment group."
        required: false
        type: string

# ------------------------------------------------------------------------------
# GitHub Token Permissions
# ------------------------------------------------------------------------------
# contents: read  - Allows the workflow to check out the repository.
# id-token: write - Allows GitHub to request an OIDC token for AWS IAM.
#
# AWS access is granted through the IAM role assumed by the workflow.
# ------------------------------------------------------------------------------

permissions:
  contents: read
  id-token: write

# ------------------------------------------------------------------------------
# Deployment Concurrency
# ------------------------------------------------------------------------------
# Prevent overlapping deployments for the same branch or environment.
# Existing deployments are not automatically cancelled.
# ------------------------------------------------------------------------------

concurrency:
  group: charlie-cafe-deploy-${{ github.ref }}
  cancel-in-progress: false

# ------------------------------------------------------------------------------
# Deployment Job
# ------------------------------------------------------------------------------

jobs:

  deploy:

    name: Deploy Charlie Cafe to AWS

    runs-on: ubuntu-latest

    # Maximum execution time for the complete deployment job.
    timeout-minutes: 60

    # --------------------------------------------------------------------------
    # Environment Variables
    # --------------------------------------------------------------------------

    env:

      # AWS region supplied through workflow input.
      AWS_REGION: ${{ inputs.aws_region || 'us-east-1' }}

      # Selected deployment target.
      DEPLOYMENT_TARGET: ${{ inputs.deployment_target || 'both' }}

      # Deployment configuration with workflow-input and secret fallback.
      EC2_INSTANCE_ID: ${{ inputs.ec2_instance_id || secrets.EC2_INSTANCE_ID }}

      ECR_REPOSITORY: ${{ inputs.ecr_repository || secrets.ECR_REPO }}

      ECS_CLUSTER: ${{ inputs.ecs_cluster || secrets.ECS_CLUSTER }}

      ECS_SERVICE: ${{ inputs.ecs_service || secrets.ECS_SERVICE }}

      CODEDEPLOY_APPLICATION: ${{ inputs.codedeploy_application || secrets.CODEDEPLOY_APPLICATION }}

      CODEDEPLOY_DEPLOYMENT_GROUP: ${{ inputs.codedeploy_deployment_group || secrets.CODEDEPLOY_DEPLOYMENT_GROUP }}

      # Immutable Docker image tag based on the Git commit SHA.
      IMAGE_TAG: ${{ github.sha }}

    steps:

      # ========================================================================
      # STEP 1 - Checkout Repository
      # ========================================================================

      - name: Checkout Charlie Cafe Repository

        uses: actions/checkout@v4

        with:

          # Do not persist the GitHub token in the local Git configuration.
          persist-credentials: false

      # ========================================================================
      # STEP 2 - Validate Deployment Configuration
      # ========================================================================

      - name: Validate Deployment Configuration

        shell: bash

        run: |

          set -euo pipefail

          echo "============================================"
          echo " Charlie Cafe Deployment Configuration"
          echo "============================================"

          # Validate the selected deployment target.
          case "$DEPLOYMENT_TARGET" in
            ec2|ecs|both)
              echo "Deployment target: $DEPLOYMENT_TARGET"
              ;;
            *)
              echo "::error::Invalid deployment target: $DEPLOYMENT_TARGET"
              exit 1
              ;;
          esac

          # AWS region must be supplied.
          if [[ -z "$AWS_REGION" ]]; then
            echo "::error::AWS_REGION is required."
            exit 1
          fi

          # Validate configuration required for EC2 deployments.
          if [[ "$DEPLOYMENT_TARGET" == "ec2" || "$DEPLOYMENT_TARGET" == "both" ]]; then

            if [[ -z "$EC2_INSTANCE_ID" ]]; then
              echo "::error::EC2_INSTANCE_ID is required for EC2 deployment."
              exit 1
            fi

          fi

          # Validate configuration required for ECS deployments.
          if [[ "$DEPLOYMENT_TARGET" == "ecs" || "$DEPLOYMENT_TARGET" == "both" ]]; then

            [[ -n "$ECR_REPOSITORY" ]] || {
              echo "::error::ECR_REPO is required."
              exit 1
            }

            [[ -n "$ECS_CLUSTER" ]] || {
              echo "::error::ECS_CLUSTER is required."
              exit 1
            }

            [[ -n "$ECS_SERVICE" ]] || {
              echo "::error::ECS_SERVICE is required."
              exit 1
            }

            [[ -n "$CODEDEPLOY_APPLICATION" ]] || {
              echo "::error::CODEDEPLOY_APPLICATION is required."
              exit 1
            }

            [[ -n "$CODEDEPLOY_DEPLOYMENT_GROUP" ]] || {
              echo "::error::CODEDEPLOY_DEPLOYMENT_GROUP is required."
              exit 1
            }

            # Ensure all required deployment files exist.
            [[ -f ".github/task-definition.json" ]] || {
              echo "::error::ECS task definition file not found."
              exit 1
            }

            [[ -f "appspec.yaml" ]] || {
              echo "::error::AWS CodeDeploy appspec.yaml not found."
              exit 1
            }

            [[ -f "docker/apache-php/Dockerfile" ]] || {
              echo "::error::Dockerfile not found."
              exit 1
            }

          fi

          echo "Deployment configuration validation completed."

      # ========================================================================
      # STEP 3 - Configure AWS Authentication Using GitHub OIDC
      # ========================================================================

      - name: Configure AWS Credentials

        uses: aws-actions/configure-aws-credentials@v4

        with:

          # IAM role trusted by the GitHub Actions OIDC identity provider.
          role-to-assume: ${{ secrets.DEPLOY_AWS_ROLE_ARN }}

          # AWS deployment region.
          aws-region: ${{ env.AWS_REGION }}

          # Identify the deployment session in AWS CloudTrail.
          role-session-name: CharlieCafeGitHubDeployment

          # Limit the lifetime of the assumed role credentials.
          role-duration-seconds: 3600

      # ========================================================================
      # STEP 4 - Verify AWS Authentication
      # ========================================================================

      - name: Verify AWS Identity

        shell: bash

        run: |

          set -euo pipefail

          echo "Verifying AWS deployment identity..."

          aws sts get-caller-identity

          echo "AWS authentication successful."

      # ========================================================================
      # EC2 DEPLOYMENT
      # ========================================================================
      # This section runs only when the selected deployment target includes EC2.
      # Application files are updated through AWS Systems Manager.
      # ========================================================================

      # ========================================================================
      # STEP 5 - Deploy Application to EC2 Using SSM
      # ========================================================================

      - name: Deploy Existing Application to EC2 via SSM

        if: ${{ env.DEPLOYMENT_TARGET == 'ec2' || env.DEPLOYMENT_TARGET == 'both' }}

        shell: bash

        env:

          INSTANCE_ID: ${{ env.EC2_INSTANCE_ID }}

        run: |

          set -euo pipefail

          echo "Starting Charlie Cafe EC2 deployment..."

          # Execute the existing application deployment on the EC2 instance.
          # The command is static and passed as a JSON parameter to avoid
          # unsafe shell interpolation of workflow input values.
          COMMAND='set -euo pipefail
          cd /opt/charlie-cafe
          git pull --ff-only
          cp -a app/frontend/html/. /var/www/html/
          cp -a app/frontend/php/. /var/www/html/
          cp -a app/frontend/css app/frontend/js /var/www/html/
          systemctl reload httpd'

          # Convert the command into valid JSON for the SSM API.
          PARAMETERS=$(jq -cn --arg command "sudo bash -lc $(printf '%q' "$COMMAND")" \
            '{commands: [$command]}')

          # Submit the remote deployment command and capture its command ID.
          COMMAND_ID=$(aws ssm send-command \
            --instance-ids "$INSTANCE_ID" \
            --document-name "AWS-RunShellScript" \
            --parameters "$PARAMETERS" \
            --comment "Charlie Cafe application deployment - ${GITHUB_SHA}" \
            --query "Command.CommandId" \
            --output text)

          if [[ -z "$COMMAND_ID" || "$COMMAND_ID" == "None" ]]; then
            echo "::error::Failed to submit EC2 deployment command."
            exit 1
          fi

          echo "SSM Command ID: $COMMAND_ID"

          # Wait for the SSM command to finish.
          # The waiter returns a non-zero status if the command fails.
          set +e

          aws ssm wait command-executed \
            --command-id "$COMMAND_ID" \
            --instance-id "$INSTANCE_ID"

          WAITER_STATUS=$?

          set -e

          # Retrieve the final execution status and remote output.
          INVOCATION=$(aws ssm get-command-invocation \
            --command-id "$COMMAND_ID" \
            --instance-id "$INSTANCE_ID" \
            --output json)

          STATUS=$(echo "$INVOCATION" | jq -r '.Status // "Unknown"')

          echo "EC2 deployment status: $STATUS"

          # Display remote command output for troubleshooting.
          echo "$INVOCATION" | jq -r '.StandardOutputContent // empty'

          # Display remote errors when present.
          echo "$INVOCATION" | jq -r '.StandardErrorContent // empty'

          # Do not report success when SSM execution failed or timed out.
          if [[ "$WAITER_STATUS" -ne 0 || "$STATUS" != "Success" ]]; then
            echo "::error::EC2 deployment failed. Final SSM status: $STATUS"
            exit 1
          fi

          echo "EC2 application deployment completed successfully."

      # ========================================================================
      # ECS DEPLOYMENT
      # ========================================================================
      # This section runs only when the selected deployment target includes ECS.
      #
      # Deployment sequence:
      #   1. Authenticate with Amazon ECR.
      #   2. Build Docker image.
      #   3. Push image to ECR.
      #   4. Render ECS task definition.
      #   5. Deploy using CodeDeploy blue/green.
      # ========================================================================

      # ========================================================================
      # STEP 6 - Authenticate with Amazon ECR
      # ========================================================================

      - name: Login to Amazon ECR

        if: ${{ env.DEPLOYMENT_TARGET == 'ecs' || env.DEPLOYMENT_TARGET == 'both' }}

        id: login-ecr

        uses: aws-actions/amazon-ecr-login@v2

      # ========================================================================
      # STEP 7 - Build and Push Docker Image
      # ========================================================================

      - name: Build and Push Charlie Cafe Docker Image

        if: ${{ env.DEPLOYMENT_TARGET == 'ecs' || env.DEPLOYMENT_TARGET == 'both' }}

        id: build-image

        shell: bash

        env:

          # Registry URL generated by the ECR login action.
          REGISTRY: ${{ steps.login-ecr.outputs.registry }}

          # Target ECR repository.
          REPOSITORY: ${{ env.ECR_REPOSITORY }}

          # Unique image tag based on the source commit.
          IMAGE_TAG: ${{ env.IMAGE_TAG }}

        run: |

          set -euo pipefail

          echo "Building Charlie Cafe Docker image..."

          IMAGE_URI="$REGISTRY/$REPOSITORY:$IMAGE_TAG"

          # Build the application container using the project Dockerfile.
          docker build \
            --pull \
            --file docker/apache-php/Dockerfile \
            --tag "$IMAGE_URI" \
            .

          # Push the immutable image tag to Amazon ECR.
          docker push "$IMAGE_URI"

          # Export the image URI for subsequent deployment steps.
          echo "image=$IMAGE_URI" >> "$GITHUB_OUTPUT"

          echo "Docker image successfully published: $IMAGE_URI"

      # ========================================================================
      # STEP 8 - Render ECS Task Definition
      # ========================================================================

      - name: Render ECS Task Definition

        if: ${{ env.DEPLOYMENT_TARGET == 'ecs' || env.DEPLOYMENT_TARGET == 'both' }}

        id: render-task-definition

        uses: aws-actions/amazon-ecs-render-task-definition@v1

        with:

          # Existing task definition maintained in source control.
          task-definition: .github/task-definition.json

          # Container name must match the name in task-definition.json.
          container-name: charlie-container

          # Replace the existing container image with the newly built image.
          image: ${{ steps.build-image.outputs.image }}

      # ========================================================================
      # STEP 9 - Deploy ECS Using AWS CodeDeploy Blue/Green
      # ========================================================================

      - name: Deploy ECS Application Using CodeDeploy Blue Green

        if: ${{ env.DEPLOYMENT_TARGET == 'ecs' || env.DEPLOYMENT_TARGET == 'both' }}

        uses: aws-actions/amazon-ecs-deploy-task-definition@v2

        with:

          # Task definition generated in the previous step.
          task-definition: ${{ steps.render-task-definition.outputs.task-definition }}

          # Target ECS service and cluster.
          service: ${{ env.ECS_SERVICE }}

          cluster: ${{ env.ECS_CLUSTER }}

          # AWS CodeDeploy AppSpec file.
          codedeploy-appspec: appspec.yaml

          # Existing CodeDeploy application.
          codedeploy-application: ${{ env.CODEDEPLOY_APPLICATION }}

          # Existing CodeDeploy deployment group.
          codedeploy-deployment-group: ${{ env.CODEDEPLOY_DEPLOYMENT_GROUP }}

          # Wait for deployment completion and service stability.
          wait-for-service-stability: true

          # Use a consistent polling interval.
          wait-max-delay-seconds: 15

      # ========================================================================
      # STEP 10 - Deployment Summary
      # ========================================================================

      - name: Charlie Cafe Deployment Summary

        if: ${{ success() }}

        shell: bash

        run: |

          set -euo pipefail

          echo "================================================"
          echo " Charlie Cafe Deployment Completed Successfully"
          echo "================================================"

          echo "Deployment Target : $DEPLOYMENT_TARGET"
          echo "AWS Region        : $AWS_REGION"
          echo "Git Commit        : $GITHUB_SHA"
          echo "Git Branch        : $GITHUB_REF_NAME"

          if [[ "$DEPLOYMENT_TARGET" == "ec2" || "$DEPLOYMENT_TARGET" == "both" ]]; then
            echo "EC2 Instance      : $EC2_INSTANCE_ID"
          fi

          if [[ "$DEPLOYMENT_TARGET" == "ecs" || "$DEPLOYMENT_TARGET" == "both" ]]; then
            echo "ECS Cluster       : $ECS_CLUSTER"
            echo "ECS Service       : $ECS_SERVICE"
            echo "ECR Repository    : $ECR_REPOSITORY"
            echo "Docker Image Tag  : $IMAGE_TAG"
          fi

          echo "================================================"

```

### 4.1 Workflow Triggers

The Terraform workflow supports two triggers:

**Manual Execution**

```yaml
on:
  workflow_dispatch:
```

Allows authorized users to manually start the deployment from GitHub Actions.

**Reusable Workflow**

```yaml
workflow_call:
  inputs:
    ec2_instance_id:
      required: false
      type: string
    ecr_repository:
      required: false
      type: string
    ecs_cluster:
      required: false
      type: string
    ecs_service:
      required: false
      type: string
    codedeploy_application:
      required: false
      type: string
    codedeploy_deployment_group:
      required: false
      type: string
```

Allows another GitHub Actions workflow to call this deployment workflow and supply deployment configuration through inputs.

**Important:** The workflow does not currently define an automatic `push` trigger. Automatic deployment requires a separate calling workflow or an additional push trigger.

### 4.2 Pipeline Architecture

The Terraform workflow contains the following major stages:

**Stage 1 – Source Code Checkout**

- Uses `actions/checkout@v4`.
- Retrieves the repository source code.
- Prepares the GitHub Actions execution environment.

**Stage 2 – AWS Authentication Through OIDC**

- Uses `aws-actions/configure-aws-credentials@v4`.
- Assumes an AWS IAM role through GitHub OIDC.
- Uses the `DEPLOY_AWS_ROLE_ARN` GitHub Secret.
- Uses the configured AWS region.

This removes the requirement to store long-lived AWS access keys in GitHub Secrets.

**Stage 3 – Deployment Input Validation**

Validates the required EC2 instance ID and ECR repository configuration.

Supports deployment values from either workflow inputs or GitHub Secrets.

**Stage 4 – EC2 Deployment Through AWS SSM**

- Connects to the existing EC2 instance using AWS Systems Manager.
- Executes deployment commands remotely.
- Pulls the latest application source code.
- Copies frontend HTML, PHP, CSS, and JavaScript files into the Apache document root.
- Reloads the Apache HTTP server.

This stage uses inline deployment commands rather than the legacy `deploy_master.sh` script.

**Stage 5 – Amazon ECR Authentication**

- Uses `aws-actions/amazon-ecr-login@v2`.
- Authenticates Docker with Amazon ECR.
- Retrieves the ECR registry address.

**Stage 6 – Docker Image Build and Push**

- Builds the application Docker image.
- Uses `docker/apache-php/Dockerfile`.
- Tags the image with the complete Git commit SHA.
- Pushes the image to the configured Amazon ECR repository.

**Stage 7 – ECS Task Definition Rendering**

Uses:

`aws-actions/amazon-ecs-render-task-definition@v1`

This action:

- Reads the ECS task definition JSON.
- Identifies the `charlie-container` container.
- Replaces the container image with the newly published ECR image.
- Generates a rendered ECS task definition for deployment.

**Stage 8 – ECS Deployment Through CodeDeploy**

Uses:

`aws-actions/amazon-ecs-deploy-task-definition@v2`

This action:

- Deploys the rendered ECS task definition.
- Uses the configured ECS cluster.
- Uses the configured ECS service.
- Integrates with the AWS CodeDeploy application.
- Uses the configured CodeDeploy deployment group.
- References `appspec.yaml`.
- Waits for ECS service stability.

The deployment strategy is determined by the CodeDeploy deployment group configuration.

**Stage 9 – Deployment Completion**

The deployment action waits for service stability before completing the workflow.

### 4.3 Terraform Workflow Characteristics

- Supports manual workflow execution.
- Supports reusable workflow execution.
- Uses AWS IAM OIDC authentication.
- Avoids long-lived AWS access keys.
- Supports dynamic deployment inputs.
- Builds and publishes Docker images to Amazon ECR.
- Uses the complete Git commit SHA for image versioning.
- Uses the official AWS ECS task definition rendering action.
- Uses the official AWS ECS deployment action.
- Integrates ECS deployment with AWS CodeDeploy.
- Supports Terraform-managed AWS resource configurations.

## 5. Major Improvements: Legacy vs Terraform

The following table highlights the major differences between the two implementations.

| Feature | Legacy | Terraform |
|---|---|---|
| Workflow Trigger | Push to main | Manual / Reusable |
| Source Checkout | actions/checkout@v3 | actions/checkout@v4 |
| AWS Credentials | Access Keys | OIDC |
| AWS Credentials Action | v2 | v4 |
| Local Docker Build | Yes | Yes |
| Local Docker Health Check | Yes | No |
| EC2 Deployment | SSM | SSM |
| EC2 Deployment Script | deploy_master.sh | Inline commands |
| SSM Completion Verification | Yes | Not implemented |
| EC2 Public IP Health Check | Yes | No |
| ECR Authentication | AWS CLI | Official ECR Login Action |
| Docker Image Tag | Short Git SHA | Full Git SHA |
| ECS Task Definition Rendering | sed | Official AWS Action |
| ECS Task Registration | AWS CLI | ECS Deploy Action |
| AppSpec Preparation | Manual rendering | Deploy Action |
| CodeDeploy Integration | AWS CLI | Official ECS Deploy Action |
| Deployment Configuration | Explicit canary | Deployment group |
| Reusable Workflow | No | Yes |
| Terraform Resource Integration | Not designed for it | Designed for it |

## 6. AWS Authentication Improvements

One of the most important improvements in the Terraform workflow is the migration from static AWS credentials to OpenID Connect.

### Legacy Authentication

The legacy implementation requires:

- AWS Access Key ID.
- AWS Secret Access Key.

These credentials must be maintained in GitHub Secrets and rotated when necessary.

### Terraform Authentication

The new implementation uses GitHub OIDC with AWS IAM role assumption.

Required GitHub Secret:

`DEPLOY_AWS_ROLE_ARN`

Required workflow permission:

```yaml
permissions:
  contents: read
  id-token: write
```

The AWS IAM role must have:

1. A properly configured GitHub OIDC trust relationship.
2. Permission to be assumed by the intended GitHub repository and branch or workflow identity.
3. Appropriate permissions for SSM, EC2, ECR, ECS, CodeDeploy, IAM PassRole, and other required AWS operations.

The role should follow the principle of least privilege.

This approach eliminates the need to maintain permanent AWS access keys for the deployment workflow.

## 7. Terraform Workflow Integration Requirements

Before using the Terraform workflow for deployment, ensure the following requirements are satisfied.

### 7.1 AWS Infrastructure

The required infrastructure must exist or be provisioned through Terraform:

1. AWS IAM OIDC Identity Provider.
2. AWS IAM deployment role.
3. Amazon EC2 instance.
4. AWS Systems Manager configuration and permissions.
5. Amazon ECR repository.
6. ECS Cluster.
7. ECS Service.
8. ECS Task Execution Role.
9. ECS Task Role.
10. AWS Secrets Manager database secret.
11. CloudWatch Log Group.
12. AWS CodeDeploy application.
13. AWS CodeDeploy deployment group.
14. ECS networking and load balancer configuration where required.

### 7.2 GitHub Secrets

The workflow references the following GitHub Secrets:

| Secret | Purpose |
|---|---|
| `DEPLOY_AWS_ROLE_ARN` | AWS IAM role ARN used for OIDC authentication. |
| `AWS_REGION` | AWS region if configured as a secret or passed through the calling workflow. |
| `EC2_INSTANCE_ID` | Target EC2 instance ID. |
| `ECR_REPO` | Amazon ECR repository name. |
| `ECS_CLUSTER` | ECS cluster name. |
| `ECS_SERVICE` | ECS service name. |
| `CODEDEPLOY_APPLICATION` | CodeDeploy application name. |
| `CODEDEPLOY_DEPLOYMENT_GROUP` | CodeDeploy deployment group name. |

The current workflow hardcodes `us-east-1` as its AWS region. The `AWS_REGION` entry above is relevant only if the workflow is changed to obtain the region from a secret or input.

When using `workflow_call`, required secrets must be passed by the calling workflow. Declare the required reusable-workflow secrets under `on.workflow_call.secrets`, or use `secrets: inherit` where appropriate.

### 7.3 Application and Deployment Files

The following project files are referenced by the Terraform workflow:

| File | Purpose |
|---|---|
| `docker/apache-php/Dockerfile` | Builds the application Docker image. |
| `.github/task-definition.json` | ECS task definition input currently referenced by the workflow. |
| `appspec.yaml` | Defines the ECS CodeDeploy deployment configuration. |
| Application source directories | Supply the application files used during EC2 deployment. |

**Important:** The workflow currently references `.github/task-definition.json`. The documented Terraform task definition is stored under `docs/task-definition.json/terraform/`. These locations must be reconciled before deployment.

The task definition must also contain actual Terraform-managed execution role, task role, and Secrets Manager ARNs. The ECS render action replaces the container image only; it does not automatically replace these other placeholders.

## 8. Important Migration Considerations

The Terraform workflow introduces important improvements, but several legacy capabilities have not yet been carried forward.

The following items should be considered during the final CI/CD migration.

### 8.1 Restore Application Testing

The legacy workflow performs a local Docker container test and checks:

`http://localhost/health.php`

The new workflow currently builds and pushes the Docker image without performing an equivalent local application health check.

Recommended improvement:

- Build the image.
- Run the container.
- Execute the application health check.
- Stop deployment if the test fails.
- Publish the image only after successful validation.

### 8.2 Restore EC2 Deployment Verification

The legacy workflow waits for the SSM command and verifies its execution status.

The Terraform workflow currently sends the SSM command without waiting for completion or checking its result.

Recommended improvement:

- Capture the SSM Command ID.
- Wait for command completion.
- Retrieve the command invocation status.
- Fail the workflow if deployment fails.
- Perform an EC2 application health check.

### 8.3 Align ECS Task Definition Paths

Ensure that the Terraform workflow uses the correct ECS task definition file.

The intended Terraform documentation location is:

`docs/task-definition.json/terraform/task-definition.json`

However, the current workflow expects:

`.github/task-definition.json`

Choose and maintain one authoritative deployment template, and update the workflow accordingly.

### 8.4 Complete Dynamic Terraform Resource Integration

Ensure the ECS task definition receives the correct values for:

- ECS execution role ARN.
- ECS task role ARN.
- ECR container image URI.
- AWS Secrets Manager ARN.
- CloudWatch log configuration.

Terraform should manage the AWS resources and provide the correct resource values to the deployment process.

### 8.5 Preserve Canary Deployment Configuration

The legacy workflow explicitly selects:

`CodeDeployDefault.ECSCanary10Percent5Minutes`

The Terraform workflow does not explicitly select this deployment configuration.

Ensure that the CodeDeploy deployment group has the intended canary configuration if the same deployment behavior is required.

## 9. Recommended Usage

| Implementation | Workflow Location | Purpose |
|---|---|---|
| Original manual AWS deployment | `legacy/` | Historical reference and original CI/CD implementation. |
| New Terraform-based deployment | `terraform/` | Primary workflow for the Terraform migration. |

The Terraform workflow should become the primary deployment workflow after the migration requirements and missing validation steps have been addressed.

The legacy workflow should be preserved without modification for historical comparison and rollback reference.

## 10. Future CI/CD Architecture

The intended Charlie Cafe deployment architecture is:

```text
Developer
    |
    v
GitHub Repository
    |
    v
GitHub Actions
    |
    v
AWS IAM OIDC Authentication
    |
    v
Docker Build and Testing
    |
    +-----------------------+
    |                       |
    v                       v
EC2 Deployment          Amazon ECR
    |                       |
    v                       v
SSM Deployment          ECS Task Definition
    |                       |
    v                       v
EC2 Health Check        Amazon ECS
                            |
                            v
                       AWS CodeDeploy
                            |
                            v
                    Canary / Blue-Green
                       Deployment
                            |
                            v
                    Production Application
```

This architecture provides a structured approach to application delivery while keeping infrastructure provisioning and application deployment responsibilities clearly separated.

Terraform manages the AWS infrastructure, while GitHub Actions manages the CI/CD execution process.

## 11. Documentation Purpose

This directory is part of the Charlie Cafe AWS DevOps project documentation.

It maintains a clear separation between the original manually configured CI/CD implementation and the updated Terraform-compatible deployment workflow.

Maintaining both versions provides:

- Historical implementation reference.
- CI/CD migration documentation.
- Deployment architecture comparison.
- AWS authentication improvement tracking.
- Workflow version control.
- A reference for future infrastructure and pipeline enhancements.

---

**Project:** Charlie Cafe AWS DevOps Project

**Platform:** GitHub Actions

**Cloud Provider:** Amazon Web Services (AWS)

**Infrastructure as Code:** Terraform

**Containerization:** Docker

**Container Registry:** Amazon Elastic Container Registry (ECR)

**Container Orchestration:** Amazon Elastic Container Service (ECS)

**Compute Platform:** Amazon EC2 and AWS Fargate

**Deployment Automation:** AWS Systems Manager and AWS CodeDeploy

**Authentication:** AWS IAM OIDC

**Configuration Type:** GitHub Actions Workflow (YAML)