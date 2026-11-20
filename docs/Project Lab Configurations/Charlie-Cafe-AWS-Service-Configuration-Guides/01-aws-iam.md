# Charlie Cafe — AWS IAM Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for AWS IAM.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

### 6️⃣ IAM Role & Policies

- Create Iam Roles for charlie Cafe [Charlie-Cafe_IAM-Role](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20AWS%20IAM%20Policy%20JSON%20Script/Charlie-Cafe_IAM-Role.md)


# ☕ AWS CAFE — AWS IAM Policy JSON Script


### 1️⃣ IAM Role for EC2 (Secrets Access)


#### 1️⃣ IAM Role Name:

```
EC2-Cafe-Secrets-Role
```


#### 2️⃣ Service You Must Select

When creating the IAM role:

- Trusted Entity Type : AWS Service

- Use Case / Service : ✅ EC2

> **This allows the EC2 instance to assume the role and use the permissions defined in your policy.**


#### ✅ Complete IAM Role Creation Steps:

- Go to: AWS Console → IAM → Roles

- Click: Create Role

- Select: Trusted entity type → AWS Service

- Then select: Use case → EC2

- Click: Next

- Attach your custom policy: EC2-Cafe-Secrets-Role

- Role name example: Cafe-EC2-Secrets-Role

- (Optional description): 

```
Role for EC2 to access Lambda, RDS, Secrets Manager, S3 and other services
```

- Click: Create Role


#### ✅ This policy contains permissions for:

- Lambda

- DynamoDB

- SQS

- S3

- Secrets Manager

- RDS

- API Gateway

- CloudWatch

- Elastic Load Balancer

- CloudFront

So this single custom policy replaces many AWS managed policies.


### AWS Managed Policies

In your merged setup you are using 0 AWS Managed Policies.

If you had used AWS managed policies instead of merging, the list would normally be something like:

- AWSLambda_FullAccess

- AmazonDynamoDBFullAccess

- AmazonS3FullAccess

- AmazonSQSFullAccess

- SecretsManagerReadWrite

- AmazonRDSFullAccess

- AmazonAPIGatewayAdministrator

- CloudWatchFullAccess

- ElasticLoadBalancingFullAccess

- CloudFrontFullAccess


### What You Need To Replace

Only ONE value needs to be replaced.

Replace:

```
YOUR_ACCOUNT_ID
```

Example:

```
arn:aws:lambda:us-east-1:123456789012:function:*
```

You can find your account ID here:

AWS Console → Top Right → Account ID


#### 1️⃣ Number of AWS Managed Policies

AWS Managed Policies:
These are policies created by Amazon Web Services like:

AmazonS3FullAccess

AWSLambdaFullAccess

AmazonDynamoDBFullAccess

In your case:

You did NOT use any AWS managed policy.

✅ AWS Managed Policies = 0


#### 2️⃣ Number of Custom Policies

You created your own policy JSON and merged everything into one file.

So in IAM it will appear as:


#### ✅ COPY-PASTE READY POLICY JSON

You can paste this directly into IAM → Policies → Create policy → JSON

[EC2-Cafe-Secrets-Role](./EC2-Cafe-Secrets-Role.json)

```
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Sid": "EC2Describe",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    },

    {
      "Sid": "SSMDeploy",
      "Effect": "Allow",
      "Action": [
        "ssm:SendCommand",
        "ssm:GetCommandInvocation",
        "ssm:ListCommandInvocations"
      ],
      "Resource": "*"
    },

    {
      "Sid": "LambdaFullAccess",
      "Effect": "Allow",
      "Action": [
        "lambda:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "InvokeLambdaFunctions",
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "arn:aws:lambda:us-east-1:YOUR_ACCOUNT_ID:function:*"
    },

    {
      "Sid": "S3FullAccess",
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "RDSFullAccess",
      "Effect": "Allow",
      "Action": [
        "rds:*",
        "rds-data:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "SecretsManagerFullAccess",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "GetCafeDevDBSecret",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*"
    },

    {
      "Sid": "SQSFullAccess",
      "Effect": "Allow",
      "Action": [
        "sqs:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "DynamoDBFullAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "APIGatewayFullAccess",
      "Effect": "Allow",
      "Action": [
        "apigateway:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "CloudWatchFullAccess",
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "ElasticLoadBalancingFullAccess",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    },

    {
      "Sid": "CloudFrontFullAccess",
      "Effect": "Allow",
      "Action": [
        "cloudfront:*"
      ],
      "Resource": "*"
    }

  ]
}
```


**⚠️ Attach role to EC2 (NO reboot).**

- **✔️ Click Create IAM ROLE**


### 2️⃣ IAM Role for Charlie Cafe

- **IAM Role Name:**

```
charlie-cafe-iam-Role
```

- Trusted entity type: AWS service

- Service: Lambda

- Click Next

- **Description:**

```
This IAM role is designed to support the backend services of the Charlie Cafe system by providing controlled access to AWS resources required for logging, database operations, message queue processing, secrets management, and file storage.
```


#### Step 3️⃣: Attach Permissions

- **IAM Role for Charlie Cafe Policies**


### 1️⃣ IAM Policies Method -1 ✅ Mega Custom IAM Policy

**👉 Paste into IAM → Policies → Create policy → JSON**

- Policy Name: charlie-cafe-iam-policy

- Region: us-east-1

- Account: Your AWS_Account_ID

- **Description:**

```
This IAM policy is designed to support the backend services of the Charlie Cafe system by providing controlled access to AWS resources required for logging, database operations, message queue processing, secrets management, and file storage.
```


### ✅ This policy includes:


### 1️⃣ AWS Managed Policies (permissions merged)

- AmazonDynamoDBFullAccess

- AmazonDynamoDBFullAccess_v2 (same permissions, safely merged once)

- AWSLambdaBasicExecutionRole

- AWSLambdaVPCAccessExecutionRole

- AmazonRDSDataFullAccess

- CloudWatchLogsFullAccess


### 2️⃣ Custom Policies (ALL merged)

- AWSLambdaBasicExecution (custom logs scope)

- CafeMenuDynamoDBReadPolicy

- CafeOrderWorkerPermissions

- CafeSecretsManagerAccess

- CafeSecretsManagerReadOnly

- CashPaymentLambda

- LambdaCafeSecretsAccess

- S3AppBucketAccessPolicy

- SendOrderToSQS


#### ✅ COPY-PASTE READY POLICY JSON

You can paste this directly into IAM → Policies → Create policy → JSON

[charlie-cafe-iam-policy](./charlie-cafe-iam-policy.json)

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CloudWatchLogsFullAccess",
            "Effect": "Allow",
            "Action": "logs:*",
            "Resource": "*"
        },
        {
            "Sid": "LambdaVPCAccess",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*"
        },
        {
            "Sid": "DynamoDBFullAccess",
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "*"
        },
        {
            "Sid": "RDSDataAPIFullAccess",
            "Effect": "Allow",
            "Action": [
                "rds-data:ExecuteStatement",
                "rds-data:BatchExecuteStatement",
                "rds-data:BeginTransaction",
                "rds-data:CommitTransaction",
                "rds-data:RollbackTransaction"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CafeMenuTableAccess",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:537236558357:table/CafeMenu"
        },
        {
            "Sid": "CafeOrdersTableAccess",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem",
                "dynamodb:Query",
                "dynamodb:Scan"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:537236558357:table/CafeOrders"
        },
        {
            "Sid": "CafeOrdersQueueAccess",
            "Effect": "Allow",
            "Action": [
                "sqs:SendMessage",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
            ],
            "Resource": "arn:aws:sqs:us-east-1:537236558357:CafeOrdersQueue"
        },
        {
            "Sid": "CafeSecretsManagerAccess",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": [
                "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*",
                "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSecret*"
            ]
        },
        {
            "Sid": "CafeS3AppBucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::demo-test-s3-b",
                "arn:aws:s3:::demo-test-s3-b/*"
            ]
        },
        {
            "Sid": "ECRFullAccess",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ECSFullAccess",
            "Effect": "Allow",
            "Action": [
                "ecs:UpdateService",
                "ecs:DescribeServices",
                "ecs:RegisterTaskDefinition"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMPassRoleSecure",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": [
                        "ecs.amazonaws.com",
                        "lambda.amazonaws.com",
                        "codepipeline.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
```

**⚠️ JUST Replace 123456789012 with your real AWS account ID. with your own account ID**


#### ✅ WHY THIS POLICY IS SAFE & CORRECT

✔ No duplicate invalid statements

✔ No conflicting ARNs

✔ Correct AWS service actions

✔ Passes IAM JSON validation

✔ Works for Lambda + DynamoDB + RDS + SQS + S3 + Secrets Manager

✔ Can be attached to Lambda execution roles

**✔️ Click Create policy**

---


### 7️⃣ EC2 USER DATA


### 1️⃣ LAMP Server USER DATA
> **📍 File Location: AWS-LAMP Server-Bash-Script.md**

[AWS-LAMP Server Bash-Script](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/Linux%20Lamp%20Server/Lamp%20Server%20Script.sh)

```
#!/bin/bash

#### 2️⃣ IAM permission (Lambda role)

```
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "arn:aws:secretsmanager:*:*:secret:cafe-db-credentials*"
}
```


### 6️⃣ Create role-guard.js

```
sudo nano /var/www/html/js/role-guard.js
```

[role-guard.js](../../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/role-guard.js)



#### ⚠️ Use * to apply it to all files (all extensions) in the directory:


# Secure Version (Uses EC2 IAM Role)

### 🌐 STEP 2️⃣ — Default Cache Behavior (VERY IMPORTANT)

>**Go to:** Behaviors → Default → Edit


| Setting                | Value                  |
| ---------------------- | ---------------------- |
| Viewer protocol policy | Redirect HTTP to HTTPS |
| Allowed HTTP methods   | GET, HEAD, OPTIONS     |
| Cache policy           | CachingDisabled        |
| Origin request policy  | AllViewer              |


**⚠️ Cognito tokens must NOT be cached**


### ✅ Correct Setting for Your Case

- Go to: CloudFront → Behaviors → Default → Edit

- Change:

| Setting                | Correct Value                                    |
| ---------------------- | ------------------------------------------------ |
| Viewer protocol policy | Redirect HTTP to HTTPS                           |
| Allowed HTTP methods   | **GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE** |
| Cache policy           | CachingDisabled                                  |
| Origin request policy  | AllViewer                                        |

**👉 This ensures:**

- POST requests pass through

- Authorization headers pass

- Cognito tokens are not cached

- No 403 / 405 errors


#### 1️⃣ Password Policy

- Leave default.

- No changes needed.


### 🌐 STEP 6 — Create role-guard.js

[role-guard.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/role-guard.js)


#### ✅ After This, You Must Verify

- Login

- Check localStorage

- Confirm access_token exists

- Paste token in jwt.io

- Confirm:

- email

- cognito:groups

- exp

If groups are missing → your Lambda 403 will happen again.


### 1️⃣ Create Lambda Role

* Name: `Lambda-Cafe-Order-Role`
* Policies:

  * AWSLambdaBasicExecutionRole
  * Secrets Manager custom policy



### 1️⃣ Attach Policy to Lambda Role

You likely have two Lambdas:

    API Lambda

    Worker Lambda

👉 Attach this policy to API Lambda role

- **Go to IAM → Roles → Search for your Lambda role**

Example:

```
CafeAPILambdaRole
```

- Attach Policy to API Lambda role **CafeLambdaExecutionRole**

```
CafeMenuDynamoDBReadPolicy
```
✅ IAM is now correctly configured

✅ Lambda now has DynamoDB access



### 3️⃣ IAM ROLE CHECK (DO THIS FIRST)

Make sure Worker Lambda Role has:


### 2️⃣ — IAM PERMISSIONS (CRITICAL)

Lambda needs UpdateItem permission for your table.


#### Open:

```
AdminMarkPaidLambda
→ Configuration
→ Permissions
→ Role
```


#### Ensure this permission exists:

```
{
  "Effect": "Allow",
  "Action": [
    "dynamodb:UpdateItem",
    "dynamodb:GetItem",
    "dynamodb:Query"
  ],
  "Resource": "arn:aws:dynamodb:*:*:table/CafeOrders"
}
```

- Attach this policy to the Lambda’s role.

- **⚠️ If missing → Admin cannot mark paid.**

- **⚠️ 2️⃣ is ALREADY implemented in your orders.php.You do NOT need structural changes.**



#### Lambda IAM Role: Must allow:

- Secrets Manager access

- VPC / RDS access (if private)


#### 2️⃣ Attach IAM Permissions

= **Lambda → Configuration → Permissions**

- **Click Role → Attach policies**

- **Attach:**

```
AmazonDynamoDBReadOnlyAccess
CloudWatchLogsFullAccess
```

- ✔ Save


#### 2️⃣ VERIFY IAM PERMISSIONS (NO SKIP)

- Click Configuration

- Click Permissions

- Click Execution role

- Ensure this policy exists:

```
AmazonDynamoDBReadOnlyAccess
AWSSecretsManagerReadWrite
```


## PHASE 9️⃣  ROLE-BASED ACCESS (ADMIN VS STAFF)


### 🔗 1️⃣ – VERIFY GROUP CLAIM IN TOKEN


#### 1️⃣ – Login as Admin

- Login via Hosted UI

- Open browser DevTools

- Copy access_token


#### 2️⃣ – Decode JWT (jwt.io)

Confirm this exists:

```
"cognito:groups": ["Admin"]
```

**❌ If missing → group assignment failed**


### 🧠 2️⃣ – ENFORCE ROLE IN ANALYTICS LAMBDA


#### 1️⃣ – Extract Claims (EXACT CODE)

Add TOP of lambda_handler:

```
claims = event['requestContext']['authorizer']['claims']
groups = claims.get('cognito:groups', '')
```


#### 2️⃣ – Enforce Admin-Only Access

Add IMMEDIATELY AFTER:

```
if 'Admin' not in groups:
    return response(403, "Access denied")
```

✔ This blocks Staff

✔ This secures Analytics & PDF


#### 3️⃣ COPY THIS FULL FINAL CODE (Recommanded)

> **(PHASE 11 + PHASE 12 INCLUDED)**

- **Open CafeAnalyticsLambda**

[CafeAnalyticsLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)


#### 4️⃣ CONFIGURE LAMBDA ENVIRONMENT VARIABLES (MANDATORY)

- **Go to:**

```
AWS Console → Lambda → Your Analytics Lambda
→ Configuration → Environment variables → Edit
```


#### 1️⃣ Add EXACTLY these variables

| Key                   | Value        | Notes                      |
| --------------------- | ------------ | -------------------------- |
| `DYNAMODB_TABLE_NAME` | `CafeOrders` | ✅ Your DynamoDB table name |
| `AWS_REGION`          | `ap-south-1` | ✅ Same region as DynamoDB  |

👉 Click Save

❗ DO NOT add quotes

❗ Key names must match exactly


#### 2️⃣ DEPLOY LAMBDA

- **Click Deploy**

- **🕐 Wait for: Successfully deployed**


### 3️⃣ Lambda Test Event

> ** (DO NOT CONTINUE WITHOUT THIS)**


#### 1️⃣ TEST PHASE 11 + 12 (REQUIRED - Recommanded)


#### 1️⃣ ✅ Test as ADMIN (SUCCESS)


#### Lambda Test Event

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  },
  "queryStringParameters": {
    "period": "month"
  }
}
```

✔ StatusCode: 200

✔ Returns:

- total_sales

- total_cost

- profit

- profit_per_item[]


#### 2️⃣ ❌ Test as STAFF (BLOCKED)

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Staff"
      }
    }
  }
}
```

✔ StatusCode: 403

✔ Message: "Access denied"


#### 2️⃣ TEST PHASE 12 (ROLE SECURITY)


#### 1️⃣ ❌ STAFF TEST

Change test event to:

```
"cognito:groups": "Staff"
```


#### EXPECTED:

```
403 Access denied
```

✔ Security works


#### 3️⃣ – TEST ROLE ACCESS (MANDATORY)


#### 1️⃣ – STAFF USER

- Login as Staff

- Open Analytics

- Expected result:

```
403 Access denied
```

**✔ PASS**


#### 2️⃣ – ADMIN USER

- Login as Admin

- Open Analytics

- Expected result:

✔ Data loads

✔ PDF downloads


### ✅ PHASE 12 COMPLETION CHECKLIST

✔ Cognito groups created

✔ Users assigned correctly

✔ Token contains cognito:groups

✔ Lambda enforces role

✔ Staff blocked

✔ Admin allowed


**✅ PHASE 9️⃣ STATUS**

> **🟢 PHASE 9️⃣ COMPLETE & VERIFIED**


### 3️⃣ 🔐 Create IAM User Access Key for GitHub

- Go to AWS → IAM → Users → your user

- Go to Security credentials → Access keys → Create Access key

- #### Choose Use Case:

  Select: 👉 Command Line Interface (CLI)

- Click Next → Create

- ### ✅ Save Keys (VERY IMPORTANT)

You will get:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```


### 1️⃣ IAM Role & Policies

- Create the following three IAM roles using the configurations defined in the [Charlie Cafe DevOps IAM Policy](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/AWS%20Services%20Configurations%20/AWS%20IAM%20Role%20&%20Policies/Charlie-Cafe_IAM_Roles_Config.md)


#### 🌐 EC2 IAM ROle 

[EC2-Cafe-Secrets-Role](./docs/Charlie%20Cafe%20Project%20Lab%20Configurations/AWS%20Services%20Configurations%20/AWS%20IAM%20Role%20&%20Policies/Charlie%20Cafe%20IAm%20Policies/EC2-Cafe-Secrets-Role.json)


### ✅ IAM ROle for CodeDeploy

- Go to IAM role → create iam role 

- Select Trusted Entity: AWS service

- Use case: CodeDeploy


#### You will see 3 options:

- CodeDeploy

- CodeDeploy for Lambda

- ✅ CodeDeploy for ECS ← SELECT THIS

- AWS will automatically attach: 👉 AWSCodeDeployRoleForECS

- Role Name: charlie-codedeploy-role

👉 Click Create role


