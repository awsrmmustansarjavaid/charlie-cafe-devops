# legacy Github Workflow  Phase 1 of Charlie Cafe DevOps project

### .github/workflows/deploy.yml

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
        docker build -t charlie-cafe -f application/docker/apache-php/Dockerfile .

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
          -f application/docker/apache-php/Dockerfile .

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

# Final Phase 1 GitHub Actions workflow

### .github/workflows/deploy.yml

```
# ==========================================================
# ☕ CHARLIE CAFE — PRODUCTION CI/CD PIPELINE
# PHASE 1: EC2 + AMAZON ECS + AWS CODEDEPLOY
# ==========================================================
#
# PURPOSE:
# Automate application testing, Docker image building,
# Amazon ECR publishing, EC2 deployment, and ECS deployment.
#
# DEPLOYMENT ARCHITECTURE:
# GitHub Actions → CI Testing → EC2 (SSM)
#                 → Amazon ECR → Amazon ECS → CodeDeploy
#
# SECURITY:
# ✔ AWS credentials stored in GitHub Secrets
# ✔ No hardcoded AWS access credentials
# ✔ Dynamic Docker image tagging using Git SHA
# ✔ Centralized application and deployment variables
#
# TRIGGER:
# Automatically execute when code is pushed to main.
#
# ==========================================================

name: ☕ Charlie Cafe — PRODUCTION CI/CD PIPELINE (FINAL)

# ==========================================================
# 1. WORKFLOW TRIGGER
# ==========================================================

on:
  push:
    branches: ["main"]

# ==========================================================
# 2. JOB CONFIGURATION
# ==========================================================

jobs:
  build-test-deploy:

    # Use GitHub-hosted Ubuntu runner
    runs-on: ubuntu-latest

    # ======================================================
    # 🌍 GLOBAL ENVIRONMENT VARIABLES
    # ======================================================
    # PURPOSE:
    # Centralize application paths, Docker configuration,
    # AWS settings, and deployment resources.
    #
    # BENEFITS:
    # ✔ Avoid repeating directory paths
    # ✔ Simplify future project restructuring
    # ✔ Maintain consistent deployment configuration
    # ✔ Make workflow easier to manage
    # ======================================================

    env:

      # ----------------------------------------------------
      # APPLICATION CONFIGURATION
      # ----------------------------------------------------

      APP_DIR: application

      DOCKERFILE_PATH: application/docker/apache-php/Dockerfile

      IMAGE_NAME: charlie-cafe

      # ----------------------------------------------------
      # ECS DEPLOYMENT FILES
      # ----------------------------------------------------

      TASK_DEFINITION_FILE: .github/task-definition.json

      APPSPEC_FILE: appspec.yaml

      # ----------------------------------------------------
      # AWS CONFIGURATION
      # ----------------------------------------------------

      AWS_REGION: ${{ secrets.AWS_REGION }}

      AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}

      ECR_REPOSITORY: ${{ secrets.ECR_REPO }}

      # Dynamically construct the ECR registry URL
      ECR_REGISTRY: ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

      # ----------------------------------------------------
      # EC2 DEPLOYMENT CONFIGURATION
      # ----------------------------------------------------

      EC2_INSTANCE_ID: ${{ secrets.EC2_INSTANCE_ID }}

      # Deployment script location on the EC2 instance
      EC2_DEPLOY_SCRIPT: /home/ec2-user/charlie-cafe-devops/deploy_master.sh

      # Application health-check endpoint
      APP_HEALTH_PATH: /health.php

      # ----------------------------------------------------
      # AWS CODEDEPLOY CONFIGURATION
      # ----------------------------------------------------

      CODEDEPLOY_APPLICATION: charlie-ecs-app

      CODEDEPLOY_DEPLOYMENT_GROUP: charlie-ecs-deployment-group

      CODEDEPLOY_CONFIG: CodeDeployDefault.ECSCanary10Percent5Minutes

      # ----------------------------------------------------
      # DOCKER IMAGE VERSION
      # ----------------------------------------------------

      # Initially use the full Git commit SHA.
      # This will be replaced with a 7-character short SHA.
      IMAGE_TAG: ${{ github.sha }}

    steps:

    # ======================================================
    # 1️⃣ SOURCE CODE CHECKOUT
    # ======================================================
    # PURPOSE:
    # Download the latest source code from the main branch
    # into the GitHub Actions runner.
    # ======================================================

    - name: 📥 Checkout Source Code
      uses: actions/checkout@v4

    # ------------------------------------------------------
    # Generate a short Git commit SHA
    # ------------------------------------------------------
    # PURPOSE:
    # Generate a unique and readable Docker image tag.
    #
    # EXAMPLE:
    # Full SHA:  a1b2c3d4e5f6...
    # Short SHA: a1b2c3d
    #
    # BENEFIT:
    # Every pipeline execution can publish a versioned image.
    # ------------------------------------------------------

    - name: 🔤 Generate Short Git SHA
      shell: bash
      run: |
        echo "IMAGE_TAG=${GITHUB_SHA::7}" >> "$GITHUB_ENV"
        echo "✅ Docker Image Tag: ${GITHUB_SHA::7}"

    # ======================================================
    # 2️⃣ AWS CONFIGURATION
    # ======================================================
    # PURPOSE:
    # Configure AWS authentication using GitHub Secrets.
    #
    # REQUIRED SECRETS:
    # AWS_ACCESS_KEY_ID
    # AWS_SECRET_ACCESS_KEY
    # AWS_REGION
    # AWS_ACCOUNT_ID
    # ECR_REPO
    # EC2_INSTANCE_ID
    #
    # NOTE:
    # This workflow uses stored AWS credentials.
    # GitHub OIDC can be introduced later to eliminate
    # long-lived access keys.
    # ======================================================

    - name: 🔐 Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    # ======================================================
    # 3️⃣ CI ENVIRONMENT SETUP
    # ======================================================
    # PURPOSE:
    # Install the command-line utilities required by the
    # CI testing and deployment stages.
    #
    # TOOLS:
    # ✔ jq
    # ✔ curl
    # ✔ zip
    # ✔ Python 3 pip
    # ✔ MySQL client
    # ======================================================

    - name: 🧰 Install Required Tools
      run: |
        sudo apt-get update
        sudo apt-get install -y jq curl zip python3-pip mysql-client

    # ======================================================
    # 4️⃣ CI TESTING — LOCAL DOCKER BUILD
    # ======================================================
    # PURPOSE:
    # Build the application Docker image before deployment.
    #
    # DOCKERFILE:
    # application/docker/apache-php/Dockerfile
    #
    # BUILD CONTEXT:
    # application/
    #
    # IMPORTANT:
    # The application directory is used as the Docker
    # build context to match the updated project structure.
    # ======================================================

    - name: 🐳 Build Docker Image (CI)
      run: |
        echo "🐳 Building Charlie Cafe Docker image..."

        docker build \
          -t "$IMAGE_NAME:$IMAGE_TAG" \
          -f "$DOCKERFILE_PATH" \
          "$APP_DIR"

    # ------------------------------------------------------
    # Run application container for CI testing
    # ------------------------------------------------------
    # PURPOSE:
    # Start the newly built Docker image locally.
    #
    # PORT:
    # Host port 80 → Container port 80
    #
    # The container will be tested before deployment.
    # ------------------------------------------------------

    - name: 🚀 Run Container (CI Test)
      run: |
        docker rm -f test_app || true

        docker run -d \
          -p 80:80 \
          --name test_app \
          "$IMAGE_NAME:$IMAGE_TAG"

        sleep 10

    # ------------------------------------------------------
    # Application health-check validation
    # ------------------------------------------------------
    # PURPOSE:
    # Verify that the application responds successfully.
    #
    # EXPECTED RESULT:
    # HTTP 200 response from /health.php
    #
    # Stop the pipeline if the health check fails.
    # ------------------------------------------------------

    - name: ❤️ Application Health Check (CI)
      run: |
        curl --fail --show-error http://localhost/health.php

        echo "✅ Local application health check passed."

    # ------------------------------------------------------
    # Cleanup CI testing container
    # ------------------------------------------------------
    # PURPOSE:
    # Remove the temporary container after CI testing.
    #
    # ALWAYS RUN:
    # Execute cleanup even if a previous CI test fails.
    # ------------------------------------------------------

    - name: 🧹 Cleanup CI Container
      if: always()
      run: |
        docker rm -f test_app || true

    # ======================================================
    # 🚀 5️⃣ EC2 DEPLOYMENT — AWS SYSTEMS MANAGER
    # ======================================================
    # PURPOSE:
    # Trigger application deployment on the EC2 instance
    # using AWS Systems Manager (SSM).
    #
    # DEPLOYMENT SCRIPT:
    # /home/ec2-user/charlie-cafe-devops/deploy_master.sh
    #
    # BENEFITS:
    # ✔ No SSH connection required
    # ✔ Centralized remote deployment
    # ✔ AWS-managed command execution
    # ======================================================

    - name: 🚀 Deploy to EC2 via AWS SSM
      run: |

        COMMAND_ID=$(aws ssm send-command \
          --targets "Key=InstanceIds,Values=$EC2_INSTANCE_ID" \
          --document-name "AWS-RunShellScript" \
          --parameters "{\"commands\":[\"bash $EC2_DEPLOY_SCRIPT\"]}" \
          --query "Command.CommandId" \
          --output text \
          --no-cli-pager)

        echo "COMMAND_ID=$COMMAND_ID" >> "$GITHUB_ENV"

        echo "🚀 EC2 deployment command submitted."
        echo "Command ID: $COMMAND_ID"

    # ------------------------------------------------------
    # Wait for EC2 deployment completion
    # ------------------------------------------------------
    # PURPOSE:
    # Wait until AWS Systems Manager finishes executing
    # the deployment script on the EC2 instance.
    # ------------------------------------------------------

    - name: ⏳ Wait for EC2 Deployment
      run: |
        aws ssm wait command-executed \
          --command-id "$COMMAND_ID" \
          --instance-id "$EC2_INSTANCE_ID"

    # ------------------------------------------------------
    # Verify EC2 deployment execution status
    # ------------------------------------------------------
    # PURPOSE:
    # Confirm that the remote deployment command completed
    # successfully.
    #
    # FAILURE:
    # Stop the pipeline if SSM reports a failed execution.
    # ------------------------------------------------------

    - name: 🔍 Verify EC2 Deployment Status
      run: |

        STATUS=$(aws ssm get-command-invocation \
          --command-id "$COMMAND_ID" \
          --instance-id "$EC2_INSTANCE_ID" \
          --query "Status" \
          --output text \
          --no-cli-pager)

        echo "EC2 DEPLOYMENT STATUS: $STATUS"

        if [ "$STATUS" != "Success" ]; then
          echo "❌ EC2 deployment failed."

          aws ssm get-command-invocation \
            --command-id "$COMMAND_ID" \
            --instance-id "$EC2_INSTANCE_ID" \
            --query "{Status:Status,Output:StandardOutputContent,Error:StandardErrorContent}" \
            --output json \
            --no-cli-pager

          exit 1
        fi

        echo "✅ EC2 deployment completed successfully."

    # ------------------------------------------------------
    # Retrieve EC2 public IP address
    # ------------------------------------------------------
    # PURPOSE:
    # Dynamically retrieve the public IP of the EC2 instance
    # for external application health verification.
    # ------------------------------------------------------

    - name: 🌐 Get EC2 Public IP
      run: |

        INSTANCE_IP=$(aws ec2 describe-instances \
          --instance-ids "$EC2_INSTANCE_ID" \
          --query "Reservations[0].Instances[0].PublicIpAddress" \
          --output text \
          --no-cli-pager)

        if [ -z "$INSTANCE_IP" ] || [ "$INSTANCE_IP" = "None" ]; then
          echo "❌ EC2 public IP address is unavailable."
          exit 1
        fi

        echo "INSTANCE_IP=$INSTANCE_IP" >> "$GITHUB_ENV"

        echo "✅ EC2 Public IP: $INSTANCE_IP"

    # ------------------------------------------------------
    # Verify EC2 application health
    # ------------------------------------------------------
    # PURPOSE:
    # Confirm that the deployed application is accessible
    # through the EC2 public IP address.
    # ------------------------------------------------------

    - name: 🌐 EC2 Application Health Check
      run: |
        curl --fail \
          --show-error \
          --retry 5 \
          --retry-delay 5 \
          --retry-connrefused \
          "http://${INSTANCE_IP}${APP_HEALTH_PATH}"

        echo "✅ EC2 application health check passed."

    # ======================================================
    # 🎉 EC2 DEPLOYMENT SUCCESS
    # ======================================================

    - name: 🎉 EC2 Deployment Success
      run: |
        echo "=========================================================="
        echo "✅ CHARLIE CAFE EC2 DEPLOYMENT COMPLETED"
        echo "=========================================================="

    # ======================================================
    # ⚡ 6️⃣ ECS DEPLOYMENT — AMAZON ECR
    # ======================================================
    # PURPOSE:
    # Build and publish a versioned Docker image for
    # the production Amazon ECS environment.
    # ======================================================

    # ------------------------------------------------------
    # 6.1 Authenticate Docker with Amazon ECR
    # ------------------------------------------------------
    # PURPOSE:
    # Authenticate Docker against the private ECR registry
    # using AWS credentials configured earlier.
    # ------------------------------------------------------

    - name: 🐳 Login to Amazon ECR
      run: |
        echo "🔐 Authenticating with Amazon ECR..."

        aws ecr get-login-password \
          --region "$AWS_REGION" \
          --no-cli-pager | \
        docker login \
          --username AWS \
          --password-stdin "$ECR_REGISTRY"

        echo "✅ Amazon ECR authentication successful."

    # ------------------------------------------------------
    # 6.2 Build versioned ECS Docker image
    # ------------------------------------------------------
    # PURPOSE:
    # Build the production Docker image using the short
    # Git commit SHA as its unique image tag.
    #
    # BUILD CONTEXT:
    # application/
    #
    # IMAGE EXAMPLE:
    # charlie-cafe:a1b2c3d
    # ------------------------------------------------------

    - name: 🏗️ Build ECS Docker Image
      run: |
        docker build \
          -t "$ECR_REPOSITORY:$IMAGE_TAG" \
          -f "$DOCKERFILE_PATH" \
          "$APP_DIR"

    # ------------------------------------------------------
    # 6.3 Tag image for Amazon ECR
    # ------------------------------------------------------
    # PURPOSE:
    # Assign the full ECR repository URI to the local image.
    #
    # IMAGE FORMAT:
    # ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/REPOSITORY:TAG
    # ------------------------------------------------------

    - name: 🏷️ Tag ECS Docker Image
      run: |
        docker tag \
          "$ECR_REPOSITORY:$IMAGE_TAG" \
          "$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

    # ------------------------------------------------------
    # 6.4 Push versioned image to Amazon ECR
    # ------------------------------------------------------
    # PURPOSE:
    # Upload the tagged Docker image to the private
    # Amazon Elastic Container Registry repository.
    # ------------------------------------------------------

    - name: 📤 Push ECS Image to Amazon ECR
      run: |
        docker push "$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

        echo "✅ Docker image successfully pushed."
        echo "📦 Image: $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

    # ======================================================
    # 7️⃣ ECS TASK DEFINITION — SAFE RENDERING
    # ======================================================
    # PURPOSE:
    # Prepare the ECS task definition using the newly
    # published Docker image.
    #
    # SOURCE:
    # .github/task-definition.json
    #
    # OUTPUT:
    # task-def.json
    #
    # IMAGE_PLACEHOLDER is replaced with the actual ECR URI.
    # ======================================================

    - name: 📄 Render ECS Task Definition
      run: |

        echo "📄 Preparing ECS task definition..."

        cp "$TASK_DEFINITION_FILE" task-def.json

        sed -i \
          "s#IMAGE_PLACEHOLDER#$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG#g" \
          task-def.json

        # Validate rendered JSON before registration
        jq empty task-def.json

        echo "✅ ECS task definition rendered successfully."

    # ------------------------------------------------------
    # Register ECS task definition
    # ------------------------------------------------------
    # PURPOSE:
    # Register a new ECS task definition revision containing
    # the newly built and published Docker image.
    #
    # OUTPUT:
    # TASK_DEF_ARN
    # ------------------------------------------------------

    - name: 📦 Register ECS Task Definition
      run: |

        TASK_DEF_ARN=$(aws ecs register-task-definition \
          --cli-input-json file://task-def.json \
          --query 'taskDefinition.taskDefinitionArn' \
          --output text \
          --no-cli-pager)

        echo "TASK_DEF_ARN=$TASK_DEF_ARN" >> "$GITHUB_ENV"

        echo "✅ New ECS Task Definition registered."
        echo "Task Definition ARN: $TASK_DEF_ARN"

    # ======================================================
    # 8️⃣ AWS CODEDEPLOY — APPSPEC PREPARATION
    # ======================================================
    # PURPOSE:
    # Prepare the AppSpec deployment configuration using
    # the newly registered ECS task definition ARN.
    #
    # SOURCE:
    # appspec.yaml
    #
    # OUTPUT:
    # appspec-rendered.yaml
    # ======================================================

    - name: 📄 Prepare AppSpec Configuration
      run: |

        cp "$APPSPEC_FILE" appspec-rendered.yaml

        sed -i \
          "s#TASK_DEFINITION#$TASK_DEF_ARN#g" \
          appspec-rendered.yaml

        echo "✅ AppSpec configuration prepared."

    # ======================================================
    # 9️⃣ AWS CODEDEPLOY — CANARY DEPLOYMENT
    # ======================================================
    # PURPOSE:
    # Start an ECS blue/green deployment using AWS CodeDeploy.
    #
    # DEPLOYMENT STRATEGY:
    # CodeDeployDefault.ECSCanary10Percent5Minutes
    #
    # This strategy initially shifts 10% of production traffic
    # and then shifts the remaining traffic after five minutes,
    # provided deployment validation succeeds.
    # ======================================================

    - name: 🚀 Deploy ECS via AWS CodeDeploy
      run: |

        # Convert AppSpec content into a valid JSON revision
        jq -n \
          --rawfile content appspec-rendered.yaml \
          '{revisionType:"AppSpecContent",appSpecContent:{content:$content}}' \
          > codedeploy-revision.json

        # Submit the CodeDeploy deployment
        DEPLOYMENT_ID=$(aws deploy create-deployment \
          --application-name "$CODEDEPLOY_APPLICATION" \
          --deployment-group-name "$CODEDEPLOY_DEPLOYMENT_GROUP" \
          --deployment-config-name "$CODEDEPLOY_CONFIG" \
          --revision file://codedeploy-revision.json \
          --query "deploymentId" \
          --output text \
          --no-cli-pager)

        echo "DEPLOYMENT_ID=$DEPLOYMENT_ID" >> "$GITHUB_ENV"

        echo "🚀 CodeDeploy deployment started."
        echo "Deployment ID: $DEPLOYMENT_ID"

    # ------------------------------------------------------
    # Wait for CodeDeploy deployment completion
    # ------------------------------------------------------
    # PURPOSE:
    # Wait until AWS CodeDeploy reports that the ECS
    # deployment has completed successfully.
    #
    # FAILURE:
    # Stop the pipeline if the deployment fails.
    # ------------------------------------------------------

    - name: ⏳ Wait for CodeDeploy Deployment
      run: |

        aws deploy wait deployment-successful \
          --deployment-id "$DEPLOYMENT_ID" \
          --no-cli-pager

        echo "✅ CodeDeploy deployment completed successfully."

    # ======================================================
    # 🎉  🔟 FINAL PIPELINE SUCCESS
    # ======================================================
    # PURPOSE:
    # Confirm that all CI/CD stages have completed.
    # ======================================================

    - name: 🎉 Full Pipeline Success
      run: |

        echo "=========================================================="
        echo "🎉 CHARLIE CAFE — FULL CI/CD PIPELINE SUCCESSFUL"
        echo "=========================================================="
        echo "Application Directory: $APP_DIR"
        echo "Dockerfile: $DOCKERFILE_PATH"
        echo "Image Tag: $IMAGE_TAG"
        echo "ECR Repository: $ECR_REPOSITORY"
        echo "AWS Region: $AWS_REGION"
        echo "ECS Task Definition: $TASK_DEF_ARN"
        echo "CodeDeploy ID: $DEPLOYMENT_ID"
        echo "=========================================================="
        echo "🚀 Charlie Cafe production deployment completed!"
        echo "=========================================================="
```

## 2. Expected project directory structure

### Your GitHub workflow now expects the following layout:

```
charlie-cafe-devops/
│
├── .github/
│   ├── workflows/
│   │   └── deploy.yml
│   │
│   └── task-definition.json
│
├── application/
│   ├── app/
│   │   ├── frontend/
│   │   └── backend/
│   │
│   └── docker/
│       └── apache-php/
│           └── Dockerfile
│
├── appspec.yaml
│
├── infrastructure/
│
├── scripts/
│
└── deploy_master.sh
```

## 3. GitHub Secrets Required

Make sure the following secrets exist in your GitHub repository:

**Navigation:** `GitHub Repository → Settings → Secrets and variables → Actions → New repository secret`

| Secret Name | Purpose |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS authentication |
| `AWS_SECRET_ACCESS_KEY` | AWS authentication |
| `AWS_REGION` | AWS deployment region |
| `AWS_ACCOUNT_ID` | AWS account ID |
| `ECR_REPO` | Amazon ECR repository name |
| `EC2_INSTANCE_ID` | EC2 deployment target |

**Note:** The remaining application paths, Docker configuration, and deployment settings are centralized in the GitHub Actions workflow's `env` section. You do not need to create separate GitHub Secrets for those variables unless they contain sensitive information.


