# charlie-cafe  DEVOPS Network Connectivity

### 🔹 Step 1: Check Your ECS Task Subnet

- Go to VPC → Subnets → Your ECS Task Subnet.

- Check if it’s private (doesn’t have an Internet Gateway route).

- If it is private, you cannot access ECR over the internet without:

    - NAT Gateway

    - or VPC Endpoint for ECR

### 🔹 Step 2: Option 1 — Use NAT Gateway (Internet Access)

> If your ECS tasks are in a private subnet, you can use a NAT Gateway to allow outbound internet access:

- ECS task in a private subnet with route to NAT Gateway

- NAT Gateway in public subnet with Internet Gateway

- Security group allows outbound TCP 443

- Pros: Works immediately, easy to test

- Cons: Cost for NAT Gateway

#### Steps:

- Create a NAT Gateway in a public subnet.

- VPC → NAT Gateways → Create NAT Gateway

- Assign an Elastic IP

- Place it in a public subnet (with route to Internet Gateway)

- Update Private Subnet Route Table

- Route Table → Subnet associated with ECS task

- Add route: Destination: 0.0.0.0/0 → Target: NAT Gateway

- Ensure your ECS task’s security group allows outbound traffic:

  - Type: HTTPS (TCP 443)

  - Destination: 0.0.0.0/0 (or restrict to ECR CIDR 52.95.255.0/24 etc.)

✅ This will let ECS tasks pull images from ECR via the internet.

### 🔹 Step 3: Option 2 — Use VPC Endpoints (No Internet Needed)

> AWS supports VPC Endpoints to access ECR privately without NAT. This is recommended for security.

- No internet needed, fully private

- You need three endpoints:

| Endpoint                        | Type      | Notes                                            |
| ------------------------------- | --------- | ------------------------------------------------ |
| com.amazonaws.us-east-1.ecr.api | Interface | ECS tasks → ECR API                              |
| com.amazonaws.us-east-1.ecr.dkr | Interface | ECS tasks → Docker registry                      |
| com.amazonaws.us-east-1.s3      | Gateway   | Needed because ECR image layers are stored in S3 |

#### Steps:

- ECR API Endpoint

  - Service Name: com.amazonaws.us-east-1.ecr.api

  - Type: Interface

  - Attach to the private subnet of your ECS tasks

  - Assign security group allowing ECS outbound

- ECR Docker (registry) Endpoint

  - Service Name: com.amazonaws.us-east-1.ecr.api

  - Type: Interface

  - Attach to same private subnet

  - Security group similar to above

- Optional: S3 VPC Endpoint

> Because pulling images sometimes accesses S3 (ECR stores layers in S3)

  - Type: Gateway

  - Route table: private subnet

  - Destination: S3 prefix list pl-xxxxxx

✅ After endpoints are in place, ECS tasks can pull images privately, no NAT required.

### 🔹 Step 4: Security Groups & IAM

#### Security Groups

    - ECS task SG: allow outbound HTTPS to ECR endpoints (or 0.0.0.0/0 if using NAT)

    - Endpoint SG: allow inbound HTTPS from ECS task SG

- IAM Role

    - ECS task role must have:

```
{
  "Effect": "Allow",
  "Action": [
    "ecr:GetAuthorizationToken",
    "ecr:BatchCheckLayerAvailability",
    "ecr:GetDownloadUrlForLayer"
  ],
  "Resource": "*"
}
```

### 🔹 Step 5: Test Network Connectivity

From an ECS instance (or a temporary EC2 in the same subnet):

```
# Test ECR API
curl -v https://api.ecr.us-east-1.amazonaws.com/

# Test ECR registry
curl -v https://<account-id>.dkr.ecr.us-east-1.amazonaws.com/v2/
```

- If timeout → network issue

- If JSON response → network works

### 🔹 Step 6: ECS Task Definition Settings

- Use Fargate Launch Type

- Ensure subnet selection matches your private subnet

- Assign task role with ECR permissions

- Security group allows outbound HTTPS

- If using private subnet without NAT, make sure VPC endpoints exist

### 🔹 Step 7: Verify ECS Once Networking Works

After your tasks can access ECR:

- Go to ECS → Clusters → charlie-cluster → Services → charlie-service

- Check Tasks:

  - Status: Running

  - Last Status: RUNNING

- Go to Target Groups → charlie-blue → Targets

  - Status: Healthy

  - Should see the private IP of the Fargate task

- Open your ALB DNS in browser:

  - You should see your app page served from the container

- Logs:

  - Go to CloudWatch Logs (if configured in task definition)

  - Verify container starts without errors

### 🔹 Step 8: Debug Common Remaining Issues

- IAM role

    - Task Role must allow:  

```
"Action": [
  "ecr:GetAuthorizationToken",
  "ecr:BatchCheckLayerAvailability",
  "ecr:GetDownloadUrlForLayer"
],
"Resource": "*"
```

- Security Groups

    - ECS task SG: outbound TCP 443 to NAT / Endpoint

    - Endpoint SG: inbound TCP 443 from ECS task SG

- Subnet Routes

    - Private subnet → NAT Gateway OR VPC Endpoints

    - Public subnet → Internet Gateway (for NAT)

- Docker Image Tag

    - Ensure latest exists in ECR

### 💡 Bottom line:

- Your ECS service looks fine, but it cannot start the container because networking blocks ECR access. Fix the network (NAT or VPC endpoints) and then verify tasks as shown above.

### ✅ Summary of Options

| Option        | Pros                                       | Cons                                   |
| ------------- | ------------------------------------------ | -------------------------------------- |
| NAT Gateway   | Simple, works with existing internet paths | Costs extra, internet traffic goes out |
| VPC Endpoints | Private, secure, no internet needed        | Slightly more setup, need endpoint SGs |
| Public Subnet | Very simple                                | Not secure for private ECS workloads   |


