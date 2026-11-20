# Charlie Cafe — AWS Lambda Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for AWS Lambda.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

#### Note: RDS SG is private, only Lambda can access 3306.


### 3️⃣ Lambda Security Group

- Name: charlie-lambda-sg

- Attached to: Lambda functions in VPC

- Inbound Rules:

| Type  | Protocol | Port Range | Source                                |
| ----- | -------- | ---------- | ------------------------------------- |
| SSH   | TCP      | 22         | Default SG (if admin needs)           |
| HTTP  | TCP      | 80         | Default SG (for API testing)          |
| HTTPS | TCP      | 443        | Default SG                            |
| MySQL | TCP      | 3306       | RDS SG (so Lambda can connect to RDS) |

- Outbound Rules:

  - All traffic allowed (default)


#### Notes:

- Lambda in VPC requires SG to allow outbound to RDS SG on 3306

- SSH/HTTP/HTTPS in inbound is optional unless you want Lambda testing/debugging


## ☕ AWS CAFE - PHASE 2️⃣ Lambda Layer (pymysql)

Read more about Charlie Cafe Lambda Layer (pymysql)

[Lambda Layer (pymysql)](./AWS%20Charlie%20Cafe%20Project%20DOCs/Charlie%20Cafe%20Lambda%20pymysql-layer.md)


# Charlie Cafe - PyMySQL Lambda Layer via AWS CLI


## PHASE 1️⃣ Basic pymysql-layer Configurations


### Verify prerequisites (Optional)

```
aws --version
```

```
python3 --version
```

```
pip3 --version
```


#### 👁‍🗨 You should see:

```
aws-cli/2.x

Python 3.x
```


#### ❗️ If pip3 missing:


### 1️⃣ Prepare ZIP File (EC2 or Local)

```bash
sudo dnf install -y python3 python3-pip
```


### 2️⃣ — Create clean working directory

```
sudo mkdir lambda-layer && cd lambda-layer
```


### 3️⃣ — Create required Lambda layer folder structure

⚠️ Lambda REQUIRES this exact structure

```
mkdir python
```


#### 👁‍🗨 You should see:

```
pymysql-layer/
└── python/
```


### 4️⃣ — Install PyMySQL INTO python folder

```
pip3 install pymysql -t python/
```


### 5️⃣ Verify install:

```
ls python/
```


#### 👁‍🗨 You should see:

```
pymysql/
pymysql-*.dist-info/
```


### 6️⃣ — Create ZIP file (VERY IMPORTANT)

```
zip -r pymysql-layer.zip python
```


### 7️⃣ Confirm ZIP exists:

```
ls -lh pymysql-layer.zip
```


#### 👁‍🗨 You should see:

```
pymysql-layer.zip   (few MB)
```



### 8️⃣ — Publish Lambda Layer USING AWS CLI (NO S3)

🔥 This is what you want instead of S3

```
aws lambda publish-layer-version \
  --layer-name pymysql-layer \
  --description "PyMySQL Lambda Layer" \
  --zip-file fileb://pymysql-layer.zip \
  --compatible-runtimes python3.9 python3.10 python3.11
```


### 9️⃣ — Confirm Layer was created

```
aws lambda list-layer-versions \
  --layer-name pymysql-layer
```


#### 👁‍🗨 You should see:

```
{
  "LayerVersions": [
    {
      "Version": 1,
      "LayerVersionArn": "arn:aws:lambda:us-east-1:123456789012:layer:pymysql-layer:1"
    }
  ]
}
```


#### ✅ Copy the LayerVersionArn


### 🔟 — Attach Layer to Lambda (CLI way)


#### 1️⃣ Get current layers (IMPORTANT – don’t overwrite)

```
aws lambda get-function-configuration \
  --function-name YOUR_LAMBDA_NAME
```

Check "Layers" section.


#### 2️⃣ Update Lambda with PyMySQL layer

⚠️ Replace ARN + function name

```
aws lambda update-function-configuration \
  --function-name YOUR_LAMBDA_NAME \
  --layers arn:aws:lambda:REGION:ACCOUNT_ID:layer:pymysql-layer:1
```

If you already have layers, include ALL layer ARNs together.


### 1️⃣1️⃣ — Test inside Lambda (MANDATORY)

In your Lambda code:

```
import pymysql

def lambda_handler(event, context):
    return {
        "status": "ok",
        "pymysql_version": pymysql.__version__
    }
```

Invoke test → expect no import error.


#### 🔹 — Common mistakes (READ THIS)

❌ Installing pymysql globally
❌ Zipping wrong folder
❌ Missing python/ root directory
❌ Using --zip-file file:// instead of fileb://
❌ Wrong Python runtime


#### 🔹 OPTIONAL — Cleanup local files

```
cd ..
rm -rf pymysql-layer
```


#### ✅ FINAL RESULT

You now have:

✔ PyMySQL Lambda Layer

✔ Created entirely via AWS CLI

✔ No S3 bucket involved

✔ Reusable across all Lambdas


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---


## PHASE 2️⃣ Auto-update ALL Lambdas with a Layer

> **Goal: Attach pymysql-layer to every Lambda (or filtered ones) automatically.**


### 1️⃣ — Get Layer ARN

```
aws lambda list-layer-versions --layer-name pymysql-layer
```


#### Copy:

```
arn:aws:lambda:REGION:ACCOUNT_ID:layer:pymysql-layer:VERSION
```


### 2️⃣ — List all Lambda names

```
aws lambda list-functions \
  --query 'Functions[].FunctionName' \
  --output text
```


### 3️⃣ — Auto-attach layer to ALL Lambdas

```
for fn in $(aws lambda list-functions --query 'Functions[].FunctionName' --output text); do
  aws lambda update-function-configuration \
    --function-name $fn \
    --layers arn:aws:lambda:REGION:ACCOUNT_ID:layer:pymysql-layer:1
done
```

✅ All Lambdas updated
⚠️ If Lambdas already have layers → include ALL ARNs in --layers


### 2️⃣ 🧪 DB Connection Test Lambda (REAL MySQL Test)


#### 1️⃣ — Lambda code (db_test.py)

```
import pymysql
import os

def lambda_handler(event, context):
    conn = pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
        database=os.environ["DB_NAME"],
        connect_timeout=5
    )

    with conn.cursor() as cursor:
        cursor.execute("SELECT 1")
        result = cursor.fetchone()

    conn.close()
    return {"db_test": "SUCCESS", "result": result}
```


#### 2️⃣ — Set env vars (CLI)

```
aws lambda update-function-configuration \
  --function-name db-test-lambda \
  --environment Variables="{DB_HOST=xxx,DB_USER=xxx,DB_PASS=xxx,DB_NAME=xxx}"
```


#### 3️⃣ — Invoke test

```
aws lambda invoke \
  --function-name db-test-lambda \
  response.json && cat response.json
```


### 3️⃣ 🐳 Build Lambda Layers Using Docker (AWS-Perfect)

Why: avoids “works locally but fails in Lambda”


#### 1️⃣ — Dockerfile

```
FROM public.ecr.aws/lambda/python:3.10

RUN pip install pymysql -t /layer/python

CMD ["bash"]
```


#### 2️⃣ Build image

```
docker build -t pymysql-layer .
```


#### 3️⃣ Copy layer files out

```
docker run --rm -v $(pwd):/out pymysql-layer \
  cp -r /layer /out
```


#### 4️⃣ Zip and publish

```
zip -r pymysql-layer.zip layer/python

aws lambda publish-layer-version \
  --layer-name pymysql-layer \
  --zip-file fileb://pymysql-layer.zip \
  --compatible-runtimes python3.10
```


### 4️⃣ Move DB Credentials to Secrets Manager


#### 1️⃣ — Create secret

```
aws secretsmanager create-secret \
  --name cafe-db-credentials \
  --secret-string '{
    "host":"db-endpoint",
    "user":"admin",
    "password":"secret",
    "dbname":"cafe"
  }'
```


#### 2️⃣ IAM permission (Lambda role)

```
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "arn:aws:secretsmanager:*:*:secret:cafe-db-credentials*"
}
```


#### 3️⃣ Lambda code usage

```
import boto3, json

def get_db_creds():
    sm = boto3.client("secretsmanager")
    secret = sm.get_secret_value(SecretId="cafe-db-credentials")
    return json.loads(secret["SecretString"])
```


### 5️⃣ CloudWatch Structured Logging (JSON)


#### 1️⃣ — Logging utility

```
import json, logging, time

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def log(event, level="INFO", **data):
    logger.info(json.dumps({
        "level": level,
        "event": event,
        "timestamp": int(time.time()),
        **data
    }))
```


#### 2️⃣ — Usage

```
log("DB_CONNECTED", lambda="order-service", status="ok")
```


#### Result in CloudWatch:

```
{"event":"DB_CONNECTED","lambda":"order-service","status":"ok"}
```


### 6️⃣ Shared DB Utility Lambda Layer


#### 1️⃣ — Folder structure

```
db-layer/
└── python/
    └── db.py
```


#### 2️⃣ db.py

```
import pymysql, boto3, json

def get_conn():
    sm = boto3.client("secretsmanager")
    secret = json.loads(
        sm.get_secret_value(SecretId="cafe-db-credentials")["SecretString"]
    )

    return pymysql.connect(
        host=secret["host"],
        user=secret["user"],
        password=secret["password"],
        database=secret["dbname"]
    )
```


#### 3️⃣ Publish layer

```
zip -r db-utils-layer.zip python

aws lambda publish-layer-version \
  --layer-name db-utils-layer \
  --zip-file fileb://db-utils-layer.zip
```


#### 4️⃣ Use in Lambda

```
from db import get_conn
```


### 7️⃣ CI/CD Script to Auto-Publish Layers


#### 1️⃣ — Bash script (deploy-layer.sh)

```
#!/bin/bash
set -e

LAYER_NAME="pymysql-layer"

rm -rf python pymysql-layer.zip
mkdir python

pip install pymysql -t python/
zip -r pymysql-layer.zip python

aws lambda publish-layer-version \
  --layer-name $LAYER_NAME \
  --zip-file fileb://pymysql-layer.zip \
  --compatible-runtimes python3.10
```


#### 2️⃣ Make executable

```
sudo chmod +x deploy-layer.sh
```


#### 3️⃣ Run anytime

```
sudo ./deploy-layer.sh
```


### ✅ FINAL ARCHITECTURE YOU NOW HAVE

✔ Central DB logic
✔ Secure Secrets Manager creds
✔ Structured CloudWatch logs
✔ Docker-built AWS-native layers
✔ One-command CI/CD deployment
✔ Mass Lambda updates

This is real AWS production setup, not tutorial junk.

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---


## PHASE 3️⃣  Bash script charlie-cafe-pymysql-layer

Below is a single, production-ready Bash script, fully commented, that covers:

✅ PHASE 1: PyMySQL Lambda Layer build & publish (CLI only)

✅ PHASE 2: Auto-attach layer to ALL Lambdas

✅ Optional: Docker-based build

✅ Optional: Secrets Manager creation

✅ Safe defaults + clear variables

❌ No S3

❌ No missing steps

❌ No magic

You can run parts or the whole thing.


### 📜 charlie-cafe-pymysql-layer.sh


#### Run on EC2 / CloudShell / Amazon Linux / Linux

[charlie-cafe-pymysql-layer.sh](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/charlie-cafe-pymysql-layer.sh)

```
#!/bin/bash

# PyMySQL Lambda Layer – FULL AUTOMATION SCRIPT

#  - Build PyMySQL Lambda Layer

# -----------------------------
echo "📦 Building PyMySQL Lambda Layer..."


# -----------------------------
echo "🚀 Publishing Lambda Layer via AWS CLI (NO S3)..."

LAYER_PUBLISH_OUTPUT=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --description "Charlie Cafe PyMySQL Lambda Layer" \
  --zip-file fileb://pymysql-layer.zip \
  --compatible-runtimes $PYTHON_RUNTIMES)

echo "$LAYER_PUBLISH_OUTPUT"

LAYER_ARN=$(echo "$LAYER_PUBLISH_OUTPUT" | jq -r '.LayerVersionArn')

echo "✅ Layer published:"
echo "$LAYER_ARN"
echo


# -----------------------------
echo "🔁 Attaching layer to ALL Lambda functions..."

FUNCTIONS=$(aws lambda list-functions \
  --query 'Functions[].FunctionName' \
  --output text)

for FN in $FUNCTIONS; do
  echo "➡ Updating Lambda: $FN"

  aws lambda update-function-configuration \
    --function-name "$FN" \
    --layers "$LAYER_ARN"
done

echo "✅ All Lambdas updated"
echo


# -----------------------------
echo "🐳 Optional: Docker-based AWS parity build"
echo "⏭ Skipped by default (uncomment section to enable)"
: '
docker build -t pymysql-layer-docker - <<EOF
FROM public.ecr.aws/lambda/python:3.10
RUN pip install pymysql -t /layer/python
CMD ["bash"]
EOF

docker run --rm -v $(pwd):/out pymysql-layer-docker \
  cp -r /layer /out

zip -r pymysql-layer.zip layer/python

aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --zip-file fileb://pymysql-layer.zip \
  --compatible-runtimes python3.10
'
echo


### ✅ WHAT THIS SCRIPT GUARANTEES

✔ Correct Lambda layer structure
✔ CLI-only (no S3)
✔ Safe re-runs
✔ Mass Lambda updates
✔ Optional Docker parity
✔ Optional Secrets Manager
✔ Clean rollback-free process

This is production-level automation, not tutorial fluff.

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---


### 1️⃣ - PyMySQL Lambda Layer

> #### Method 1️⃣ - PyMySQL Lambda Layer (Bash Script)

```
sudo nano upload-pymysql-layer.sh
```

[PyMySQL Lambda Layer](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/☕%20AWS%20CAFE%20—%20PyMySQL%20Lambda%20Layer/upload-pymysql-layer.sh)

```
#!/bin/bash

# Bash Script: Create PyMySQL Lambda Layer

# Correct Structure for AWS Lambda

# -------- STEP 2: Create Correct Folder Structure --------
echo "📁 Creating Lambda layer structure..."
mkdir -p "$PYTHON_DIR"


## PHASE 1️⃣ — SQS/LAMBDA (Producer)


### ✅ Verify

- Queue status should be Available

- Copy Queue ARN

- Copy Queue URL (IMPORTANT — save it)


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## PHASE 2️⃣ — AUTOMATION Lambda Cafe-Order (SERVERLESS)


### 1️⃣ Create Lambda Role

* Name: `Lambda-Cafe-Order-Role`
* Policies:

  * AWSLambdaBasicExecutionRole
  * Secrets Manager custom policy



### 2️⃣ Create Lambda Function

* Name: `CafeOrderProcessor`
* Runtime: Python 3.12
* Role: `Lambda-Cafe-Order-Role`


### 3️⃣ Create Lambda Layer Using S3


#### 1️⃣  Lambda Console

* AWS Console → **Lambda**
* Click **Layers**
* Click **Create layer**


#### 2️⃣  Layer Settings

| Field              | Value                                                          |
| ------------------ | -------------------------------------------------------------- |
| Name               | `pymysql-layer`                                                |
| Description        | PyMySQL dependency layer                                       |
| Code entry type    | **Upload a file from Amazon S3**                               |
| S3 URI             | `s3://cafe-lambda-artifacts-<unique>/layers/pymysql-layer.zip` |
| Compatible runtime | Python 3.12                                                    |

Click **Create**

✅ Lambda Layer created from S3


### 4️⃣ Attach Layer to Lambda Function


####  1️⃣ Open Lambda Function

* Lambda → Functions → `CafeOrderProcessor`


#### 2️⃣ Add Layer

* Scroll to **Layers** section
* Click **Add a layer**
* Choose **Custom layers**
* Select:

  * Layer: `pymysql-layer`
  * Version: latest

Click **Add**


### 5️⃣ Lambda Payload Code (INSERT INTO MariaDB)

Paste THIS EXACT CODE ⬇️

[CafeOrderProcessor.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project//☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Charlie%20Cafe%20-%20Order%20Backend%20Code/CafeOrderProcessor/CafeOrderProcessor.py)

Save Lambda

Click Deploy (top right)
---- 


### 6️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**


### 7️⃣ Increase Lambda Timeout

**Lambda → Configuration → General configuration → Edit**

| Setting | Value          |
| ------- | -------------- |
| Timeout | **15 seconds** |
| Memory  | **512 MB**     |


👉 Why:

- ENI creation

- Cold start

- DB connection

- Memory also improves network performance.

Click Save



#### 8️⃣ Add Environment Variable:

- Configuration → Environment variables

```
SQS_QUEUE_URL = https://sqs.us-east-1.amazonaws.com/xxxxxxxx/CafeOrdersQueue
```

- Click Edit

- Add:

| Key           | Value                  |
| ------------- | ---------------------- |
| SQS_QUEUE_URL | (paste your Queue URL) |



#### 📍 How to get Queue URL:

- Open SQS

- Click CafeOrdersQueue

- Copy Queue URL

**✔️ Click Save**

**✔️ Everything else remains same.**


### 🧪 LAMBDA TEST EVENT JSON

Use this in Lambda Test:

```
{
  "body": "{\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2,\"payment_method\":\"CASH\"}"
}
```

OR if paying by card:

```
{
  "body": "{\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2,\"payment_method\":\"CARD\"}"
}
```


#### ✅ Expected:

- Order inserted in RDS

- DynamoDB updated

- SQS message sent

- StatusCode 200

```
{
  "statusCode": 200,
  "body": "{\"order_id\":\"ORD-20260220-1234\",\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2,\"total\":6.0,\"status\":\"RECEIVED\",\"created_at\":\"2026-02-20 10:30:00\"}"
}
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---

### 🔹 2️⃣ “Lambda integrated inside API Gateway”

When you go to:

- API Gateway → Create Resource → Create Method → Integration = Lambda

You are:

- Designing API structure first

- Choosing which Lambda to connect

- Controlling stages, routes, throttling, etc.

- This is the API-centric way.

You start from API Gateway and connect Lambda manually.


#### ✅ Use “Add Trigger from Lambda” if:

- Quick prototype

- Testing only

- Single endpoint

- Small internal tool


### 2️⃣ CREATE NEW LAMBDA (MENU API)

- Open AWS Lambda

- **Function details:**

| Field          | Value                     |
| -------------- | ------------------------- |
| Function name  | `CafeMenuLambda`          |
| Runtime        | Python 3.12               |
| Architecture   | x86_64                    |
| Execution role | Use existing role         |
| Role           | `CafeLambdaExecutionRole` |

**✔️ Click Create function**


### 5️⃣ Lambda Code: Read Menu from DynamoDB (Python)

Now we implement the logic.

Use boto3 to fetch menu/prices before processing orders.

[CafeMenuLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeMenuLambda.py)

**✔️ Click Deploy**


### 6️⃣ TEST LAMBDA (MANDATORY)

- Click Test

- Test name: MenuTest

- Event JSON:

```
{}
```

**✔️ Click Test**


#### ✅ Expected Output:

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "[{\"price\": 5, \"item\": \"Latte\"}, {\"price\": 8, \"item\": \"Cappuccino\"}, {\"price\": 6, \"item\": \"Fresh Juice\"}, {\"price\": 2, \"item\": \"Tea\"}, {\"price\": 3, \"item\": \"Coffee\"}]"
}
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**


## PHASE 3️⃣ — Update CafeOrderProcessor
> **⚠️ This step is inside existing Worker Lambda, NOT API Lambda.**


###  1️⃣ Open Worker Lambda


### AWS Console → Lambda → CafeOrderWorker


### 3️⃣ ✅ FINAL WORKER LAMBDA CODE


#### Below is the FINAL, READY-TO-DEPLOY Worker Lambda code with:

[CafeOrderProcessor.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project//☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Charlie%20Cafe%20-%20Order%20Backend%20Code/CafeOrderProcessor/CafeOrderProcessor.py)

**⚠️ Already Updated, So skip this step**

✔️ RDS remains main source

✔️ DynamoDB gives fast counters


## PHASE 4️⃣ — CREATE ORDER STATUS LAMBDA (NEW)
> **📢 This Lambda ONLY READS DATA.**


### 1️⃣ Create Lambda


#### AWS Console → Lambda → Create function

| Setting        | Value                                   |
| -------------- | --------------------------------------- |
| Name           | `GetOrderStatusLambda`                  |
| Runtime        | Python 3.12                             |
| Execution role | Use existing role                       |
| Role           | Same role as Worker (read-only is fine) |


- **✔️ Click Create function**


### 2️⃣ Lambda Status Order Code

[GetOrderStatusLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Charlie%20Cafe%20-%20Order%20Backend%20Code/GetOrderStatusLambda/GetOrderStatusLambda.py)


### 3️⃣ Attach Layer to Lambda Function


####  1️⃣ Open Lambda Function

* Lambda → Functions → `GetOrderStatusLambda`


#### 2️⃣ Add Layer

* Scroll to **Layers** section
* Click **Add a layer**
* Choose **Custom layers**
* Select:

  * Layer: `pymysql-layer`
  * Version: latest

Click **Add**


### 4️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**


### 5️⃣ Test Lambda


#### Test Event Name:

```
Test-GetOrderStatusLambda
```


#### Test event:

```
{}
```


#### Expected:

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "{\"metrics\": [{\"metric\": \"TOTAL_ORDERS\", \"count\": \"2\"}], \"recent_orders\": ..........."
}
```

✔ Status code: 200

✔ JSON returned

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---

### 1️⃣ — CREATE NEW LAMBDA (READ-ONLY)


#### 1️⃣ Open AWS Lambda

AWS Console → Lambda → Create function


#### 2️⃣ Function Settings

| Field         | Value                         |
| ------------- | ----------------------------- |
| Function name | `CafeOrderStatusLambda`       |
| Runtime       | Python 3.12                   |
| Architecture  | x86_64                        |
| Role          | Same role used for RDS access |

Click Create function

Wait until status = Active


### 3️⃣ — FINAL LAMBDA CODE (READ-ONLY)

> **⚠️ COPY EXACTLY — do NOT modify**

[CafeOrderStatusLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderStatusLambda/CafeOrderStatusLambda.py)

Click Deploy


### 4️⃣ — Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**


### 5️⃣ — TEST LAMBDA (MANDATORY)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**


### 🧑‍💻 STEP 3 — CREATE WORKER (KITCHEN) LAMBDA


#### This simulates:

- Barista

- Kitchen staff

- Admin panel


### 1️⃣ Create Lambda

| Setting | Value                   |
| ------- | ----------------------- |
| Name    | `CafeOrderWorkerLambda` |
| Runtime | Python 3.12             |
| Role    | Same RDS role           |



### 2️⃣ Lambda Code (STRICT COPY)

[CafeOrderWorkerLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderWorkerLambda/CafeOrderWorkerLambda.py)


### 3️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**    


### 4️⃣ Attach Lambda Layer

- same steps 


### 🧑‍💻 STEP 7 — UPDATE ORDER STATUS LAMBDA (READ REAL STATUS)


#### Replace SELECT query:

> **🔁 Replace ONLY the SQL + response logic**

> **(keep env vars, VPC, API Gateway exactly as-is)**

```
SELECT order_id, table_number, item, quantity, total_amount, status, created_at
FROM orders
WHERE order_id=%s
```

#### ✅ FINAL — Order Status Lambda

```
import json
import os
import pymysql

def get_connection():
    return pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
        database=os.environ["DB_NAME"],
        cursorclass=pymysql.cursors.DictCursor
    )

def lambda_handler(event, context):
    params = event.get("queryStringParameters") or {}
    order_id = params.get("order_id")

    if not order_id:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": "order_id required"})
        }

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT
                order_id,
                table_number,
                customer_name,
                item,
                quantity,
                total_amount,
                status,
                created_at
            FROM orders
            WHERE order_id = %s
        """, (order_id,))

        order = cursor.fetchone()

        if not order:
            return {
                "statusCode": 404,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": "Order not found"})
            }

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "order": order
            }, default=str)
        }

    finally:
        cursor.close()
        conn.close()
```

#### ⚠️ Already Added And CafeOrderStatusLambda.py code is updated... Skip this step

[CafeOrderStatusLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderStatusLambda/CafeOrderStatusLambda.py)


#### Lambda responsibility

- Fetch order by order_id

- Return JSON

- No updates

- No auth


### 1️⃣ — CREATE ADMIN LAMBDA


#### 🔹 1.1 Open AWS Lambda

- AWS Console → Lambda → Create function


#### 🔹 1.2 Function Settings

- Function name: AdminMarkPaidLambda

- Runtime: Python 3.10

- Execution role: Use existing role
(Must allow DynamoDB UpdateItem)

- Permissions: Choose existing role or create new role with DynamoDB access

- Click Create function


### 3️⃣ — ADMIN LAMBDA CODE (WITH COMMENTS)


#### Replace entire Lambda code with this:

[AdminMarkPaidLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/AdminMarkPaidLambda/AdminMarkPaidLambda.py)


### 4️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**    


### 5️⃣ Attach Lambda Layer

- same steps 


#### 🔹 4.3 Create POST Method

- Select /admin/mark-paid

- Create Method → POST

- Integration type: Lambda

- Lambda name: AdminMarkPaidLambda

- Save


#### Your Lambda filters using:

```
AND created_at >= %s
```


#### Your Lambda ONLY reads:

```
WHERE payment_status = 'PAID'
```


## PHASE 2️⃣  – ANALYTICS LAMBDA (FULL CODE)


### ✅ Update Lambda to Use RDS Only

Use the final Analytics Lambda code I provided.


#### Key changes:

```

### 1️⃣ Create Cafe Analytics Lambda

- **AWS Console → Lambda → Create function**



#### 1️⃣ Lambda configurations

```
Function name: CafeAnalyticsLambda
Runtime: Python 3.10
Execution role: Create new role
```

#### ✅ FINAL ANALYTICS LAMBDA (WITH COMMENTS ONLY)

🔒 Logic unchanged

🧠 Architecture unchanged

📝 Only comments added

🌱 Environment variable usage clarified

[CafeAnalyticsLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)



### 4️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**    


### 5️⃣ Attach Lambda Layer

- same steps 


**✅ PHASE 2 STATUS**

> **🟢 PHASE 2 COMPLETE & VERIFIED**
---

#### 🧠 HOW THIS CONNECTS TO YOUR LAMBDA

API Gateway sends this to Lambda automatically:

```
{
  "queryStringParameters": {
    "period": "today"
  }
}
```

Which your Lambda reads as:

```
event['queryStringParameters']['period']
```

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## PHASE 6️⃣  EXACT LAMBDA RESPONSE FORMAT FOR ANALYTICS


### 1️⃣ Required DynamoDB Attributes (Orders Table)


#### 1️⃣ Open DynamoDB Table

- AWS Console → DynamoDB

- Click Tables

- Open table:

```
CafeOrders
```


#### 2️⃣ Verify Table Keys


#### Confirm:

| Setting       | Value               |
| ------------- | ------------------- |
| Partition Key | `order_id` (String) |
| GSI           | `order_date-index`  |


**📢 If GSI does not exist, STOP and create it before continuing.**


#### 3️⃣ Verify Required Attributes (CRITICAL)

Click Explore table items

Open at least ONE COMPLETED order

It MUST contain ALL attributes below:

```
{
  "order_id": "ORD123",
  "order_date": "2026-01-17",
  "order_timestamp": 1705488000,
  "item_name": "Latte",
  "quantity": 2,
  "item_cost": 1.5,
  "item_price": 3.0,
  "order_status": "COMPLETED"
}
```
❌ If ANY field is missing → fix order-creation Lambda first

✔ Do NOT continue until this is correct


### 2️⃣ – VERIFY GSI WORKS (NO CODE YET)


#### Test GSI in Console

- DynamoDB → Explore table items

- Switch Query

- Select index:

```
order_date-index
```

- Query condition:

```
order_date BETWEEN 2026-01-01 AND 2026-01-31
```

- Click Run

✔ If items return → GSI works

❌ If empty → fix dates or index


### 3️⃣ – CREATE ANALYTICS LAMBDA


#### 1️⃣ Create Lambda

- **AWS Console → Lambda → Create function**

| Field          | Value                 |
| -------------- | --------------------- |
| Function name  | `CafeAnalyticsLambda` |
| Runtime        | Python 3.10           |
| Execution role | Create new role       |

- Click Create function


#### 2️⃣ Attach IAM Permissions

= **Lambda → Configuration → Permissions**

- **Click Role → Attach policies**

- **Attach:**

```
AmazonDynamoDBReadOnlyAccess
CloudWatchLogsFullAccess
```

- ✔ Save


### 4️⃣ – PASTE FINAL ANALYTICS CODE (NO CHANGES)


#### 1️⃣ Open Code Editor

- Lambda → Code tab

    - Delete ALL existing code


#### 2️⃣ Paste THIS CODE (COPY EXACTLY)

[CafeAnalyticsLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)

- Click Deploy


### 🧪 5️⃣ – Analytics Lambda Using Environment Variables (Production-Ready)

- **Go to: Lambda → Configuration → Environment variables → Edit**


#### Add EXACTLY these:

| Key                 | Value              |
| ------------------- | ------------------ |
| `ORDERS_TABLE_NAME` | `CafeOrders`       |
| `ORDERS_GSI_NAME`   | `order_date-index` |
| `ALLOWED_ORIGIN`    | `*`                |

✅ Save changes

✅ No code hard-coding remains


### 🧪 5️⃣ – TEST LAMBDA IN CONSOLE (MANDATORY)

- **Lambda → Test → Configure test event**


#### 1️⃣ Create Monthly Analytics Test Event

- **Name:**

```
Analytics_Month
```

- **JSON:**

```
{
  "queryStringParameters": {
    "period": "month"
  }
}
```

- Click Save


#### 2️⃣ Run Test

- Click Test


#### ✅ Expected Result (Structure MUST match)

```
{
  "statusCode": 200,
  "body": {
    "period": "month",
    "total_sales": <number>,
    "total_cost": <number>,
    "profit": <number>,
    "orders_count": <number>,
    "profit_per_item": [
      {
        "item": "<string>",
        "quantity": <number>,
        "sales": <number>,
        "cost": <number>,
        "profit": <number>
      }
    ],
    "daily_sales": [
      {
        "date": "YYYY-MM-DD",
        "sales": <number>
      }
    ]
  }
}
```

✔ **Status code: 200**

✔ **Response body MUST look like:**


#### 2️⃣ Create Weekly Analytics Test Event

- **Name:**

```
Analytics_Week
```

- **JSON:**

```
{
  "queryStringParameters": {
    "period": "week"
  }
}
```

- Click Save


#### 2️⃣ Run Test

- Click Test


#### ✅ Expected Result (Structure MUST match)

```
{
  "statusCode": 200,
  "body": {
    "period": "week",
    "total_sales": <number>,
    "total_cost": <number>,
    "profit": <number>,
    "orders_count": <number>,
    "profit_per_item": [],
    "daily_sales": []
  }
}
```

📌 If last 7 days have data → arrays populated

📌 If not → empty arrays (this is correct behavior)


#### 3️⃣ Create Missing Parameter (ERROR CASE) Test Event

- **Name:**

```
Analytics_MissingPeriod
```

- **JSON:**

```
{
  "queryStringParameters": {}
}
```

- Click Save


#### 2️⃣ Run Test

- Click Test


#### ❌ Expected Result (Structure MUST match)

```
{
  "statusCode": 400,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "\"Missing period parameter\""
}
```


#### 📌 Note:

- Body is a JSON string

- Quotes are expected because of json.dumps()


#### 3️⃣ Create Invalid Period Value (ERROR CASE) Test Event

- **Name:**

```
Analytics_InvalidPeriod
```

- **JSON:**

```
{
  "queryStringParameters": {
    "period": "year"
  }
}
```

- Click Save


#### 2️⃣ Run Test

- Click Test


#### ❌ Expected Result (Structure MUST match)

```
{
  "statusCode": 400,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "\"Invalid period value\""
}
```


#### 📌 This confirms:

- Input validation works

- Lambda fails safely

- No DynamoDB call happens


### 🧪 6️⃣ – TEST THROUGH API GATEWAY


#### 1️⃣  API Gateway Setup (IF NOT DONE)

```
GET /analytics
→ Lambda Proxy → CafeAnalyticsLambda
```

- Deploy API


#### 2️⃣  Browser Test


#### Open browser:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/analytics?period=month
```

✔ JSON shown

✔ No CORS error

✔ Correct totals



### ✅ PHASE 9 COMPLETION CHECKLIST

| Item                         | Status |
| ---------------------------- | ------ |
| DynamoDB attributes verified | ✅      |
| GSI tested                   | ✅      |
| Lambda created               | ✅      |
| IAM correct                  | ✅      |
| Console test passed          | ✅      |
| API test passed              | ✅      |
| Response format EXACT        | ✅      |


### ⛔ DO NOT MOVE FORWARD UNTIL

✔ You see correct JSON

✔ Numbers match DynamoDB

✔ No CloudWatch errors

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---


#### Before touching Lambda:

- Click Explore table items


### 5️⃣ — OPEN ORDER PROCESSING LAMBDA


#### 1️⃣ OPEN LAMBDA

- Go to AWS Lambda

- Click Functions

- Click your Order Processing Lambda

- Example name:

```
CafeOrderProcessingLambda
```


#### 2️⃣ VERIFY IAM PERMISSIONS (NO SKIP)

- Click Configuration

- Click Permissions

- Click Execution role

- Ensure this policy exists:

```
AmazonDynamoDBReadOnlyAccess
AWSSecretsManagerReadWrite
```


#### ❌ If missing:

- Click Add permissions

- Attach policy

- Save


### 5️⃣ — CONNECT CafeMenu TABLE IN LAMBDA

[CafeOrderProcessingLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderProcessor/CafeOrderProcessingLambda.py)


#### 2️⃣ — DEPLOY LAMBDA (DO NOT SKIP)

- Click Deploy

- Wait for success message


#### 3️⃣ — ADD ENVIRONMENT VARIABLES (MANDATORY)

- **Go to: Configuration → Environment variables → Edit**


#### Add:

| Key             | Value      |
| --------------- | ---------- |
| MENU_TABLE_NAME | CafeMenu   |
| AWS_REGION      | ap-south-1 |

- Save


### 3️⃣ – MODIFY ANALYTICS LAMBDA (EXACT LOCATION)

- **Open CafeAnalyticsLambda**

[CafeAnalyticsLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsLambda.py)


### 4️⃣ CONFIGURE LAMBDA ENVIRONMENT VARIABLES (MANDATORY)

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


### 5️⃣ Lambda Test Event

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


#### 2️⃣ TEST PHASE 11 (PROFIT PER ITEM)


#### 1️⃣ – Lambda Test Event

In Lambda → Test, use:

- **Lambda Test Event - 1: (Recommanded)**

```
{
  "queryStringParameters": {
    "period": "month"
  },
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  }
}
```



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


## ☕ Charlie Café PHASE 2️⃣ — New AWS Lambda Functions (Full Configuration)


### 1️⃣ Lambda: hr-attendance

- AWS Console → Lambda

- Click Create function

- Author from scratch

- Runtime: Python 3.12

- Architecture: x86_64

- Use existing role: cafe-hr-lambda-role


### hr-attendance

> **a single merged Lambda, Check-in and check-out are the same domain action (attendance), just different operations.**

[hr-attendance.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/hr-attendance.py)



#### ✅ Add VPC Configuration (CRITICAL)

- Lambda → Configuration → VPC

- VPC: same VPC as RDS

- Subnets: private subnets used by RDS

- Security group: Lambda SG that allows RDS access

- Click Save


### 2️⃣ Create Lambda: hr-employee-profile


#### 1️⃣ Function name

```
hr-employee-profile
```


#### 2️⃣ Code:

[hr-employee-profile.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System//hr-employee-profile.py)

- Deploy.


### 3️⃣ Create Lambda: hr-attendance-history


#### 1️⃣ Function name

```
hr-attendance-history
```


#### 2️⃣ Code:

[hr-attendance-history.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System//hr-attendance-history.py)

- Deploy.


### 4️⃣ Create Lambda: hr-leaves-holidays


#### 1️⃣ Function name

```
hr-leaves-holidays
```


#### 2️⃣ Code:

[hr-leaves-holidays.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/hr-leaves-holidays.py)

- Deploy.

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---

### 4️⃣ Integrate Lambda Function


#### For each method:

    - Integration type: Lambda Function

    - Check Use Lambda Proxy Integration

    - Lambda Region: your Lambda region


#### Lambda Function:

    - /attendance/checkin → hr-attendance

    - /attendance/checkout → hr-attendance

    - /employee-profile → hr-employee-profile

    - /attendance-history → hr-attendance-history

    - /leaves-holidays → hr-leaves-holidays

    - /exchange-token → hr-cognito-token-exchange

- Click Save

- Grant permissions when prompted → Yes


### 2️⃣ — CREATE ONE LAMBDA ONLY


#### 1️⃣ 📄 Lambda Name : cafe-attendance-admin-service

[cafe-attendance-admin-service.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Cafe-HR%20%26%20Attendance%20System/cafe-attendance-admin-service.py)


### 🚀 Best Practice (for your project)

Since you're using Lambda + Python (boto3):

👉 Always use normal JSON (Option 1)

👉 boto3 automatically converts it


#### 🔹 Overview

| SG Name      | Purpose       | Attached To  | Inbound (Key)                    | Outbound  |
| ------------ | ------------- | ------------ | -------------------------------- | --------- |
| `default-sg` | General use   | EC2, RDS     | SSH, HTTP, HTTPS, MySQL, ALL TCP | Allow All |
| `rds-sg`     | DB protection | RDS          | MySQL (from Lambda + Default SG) | Allow All |
| `lambda-sg`  | Lambda access | Lambda (VPC) | HTTP/HTTPS, MySQL to RDS         | Allow All |


#### 🔹 Rules 

| SG Name    | Port   | Protocol | Source / Destination   | Purpose           |
| ---------- | ------ | -------- | ---------------------- | ----------------- |
| default-sg | 22     | TCP      | 0.0.0.0/0 (or your IP) | SSH access        |
| default-sg | 80     | TCP      | 0.0.0.0/0              | Web (HTTP)        |
| default-sg | 443    | TCP      | 0.0.0.0/0              | Web (HTTPS)       |
| default-sg | 3306   | TCP      | Open / restricted      | MySQL access      |
| rds-sg     | 3306   | TCP      | lambda-sg, default-sg  | DB access control |
| lambda-sg  | 3306   | TCP      | rds-sg                 | Connect to RDS    |
| lambda-sg  | 80/443 | TCP      | default-sg (optional)  | API testing       |


#### 💡 Important Notes 

🔒 RDS should NOT be public → only accessible via lambda-sg

⚡ Lambda needs outbound 3306 → RDS

🚫 Avoid 0.0.0.0/0 for MySQL in production

🧪 SSH/HTTP in Lambda SG = optional (debug only)


#### 🔹 Attendance Item Structure (Inserted via Lambda)

| Attribute   | Type   | Description                  |
| ----------- | ------ | ---------------------------- |
| employee_id | String | Employee unique ID           |
| date        | String | Attendance date (YYYY-MM-DD) |
| check_in    | String | Check-in time                |
| check_out   | String | Check-out time               |
| role        | String | Employee role                |


#### 🔹 Example Item (Lambda boto3 Format)

```
dynamo_table.put_item(
    Item={
        "employee_id": "101",
        "date": "2026-02-01",
        "check_in": "09:03",
        "check_out": "17:11",
        "role": "Employee"
    }
)
```


### 🌀 Lambda Automation (Best Practice)


#### ⚡ Auto Employee Creation (Post Confirmation Trigger)

```
INSERT INTO employees 
(cognito_user_id, name, job_title, salary, start_date)
VALUES (%s, %s, %s, %s, %s)
```


#### 🔄 Workflow:

| Event                | Action            |
| -------------------- | ----------------- |
| Cognito user created | Lambda triggered  |
| Lambda executes      | Inserts into RDS  |
| Employee ready       | Portal auto-syncs |


### 🔟 Lambda & API Configuration 


### 1️⃣ Create Lambda Function

- ### 1️⃣ Lambda Function 

| Lambda Function Name          | Python File                      | Handler                                      | VPC Required |
| ----------------------------- | -------------------------------- | -------------------------------------------- | ------------ |
| CafeOrderProcessor            | CafeOrderProcessor.py            | CafeOrderProcessor.lambda_handler            | ✔ Yes        |
| CafeMenuLambda                | CafeMenuLambda.py                | CafeMenuLambda.lambda_handler                | ❌ No         |
| CafeOrderStatusLambda         | CafeOrderStatusLambda.py         | CafeOrderStatusLambda.lambda_handler         | ✔ Yes        |
| GetOrderStatusLambda          | GetOrderStatusLambda.py          | GetOrderStatusLambda.lambda_handler          | ✔ Yes        |
| CafeOrderWorkerLambda         | CafeOrderWorkerLambda.py         | CafeOrderWorkerLambda.lambda_handler         | ✔ Yes        |
| AdminMarkPaidLambda           | AdminMarkPaidLambda.py           | AdminMarkPaidLambda.lambda_handler           | ✔ Yes        |
| CafeAnalyticsLambda           | CafeAnalyticsLambda.py           | CafeAnalyticsLambda.lambda_handler           | ✔ Yes        |
| hr-attendance                 | hr-attendance.py                 | hr-attendance.lambda_handler                 | ✔ Yes        |
| hr-employee-profile           | hr-employee-profile.py           | hr-employee-profile.lambda_handler           | ✔ Yes        |
| hr-attendance-history         | hr-attendance-history.py         | hr-attendance-history.lambda_handler         | ✔ Yes        |
| hr-leaves-holidays            | hr-leaves-holidays.py            | hr-leaves-holidays.lambda_handler            | ✔ Yes        |
| cafe-attendance-admin-service | cafe-attendance-admin-service.py | cafe-attendance-admin-service.lambda_handler | ✔ Yes        |

- ### 2️⃣ Basic Lambda Configurations

| Setting         | Value                          |
|-----------------|--------------------------------|
| Runtime         | Python 3.10, 3.11, or 3.12    |
| Architecture    | x86_64                         |
| Execution role  | Use existing role              |
| Role            | Lambda-Cafe-Order-Role         |
| Timeout         | 10–30 seconds                  |

- ### 3️⃣ FIX HANDLER (VERY IMPORTANT)

- Go to: 👉 Scroll Down → Runtime settings

- Click Edit

- Set Handler like this:

```
CafeOrderProcessor.lambda_handler
```

- RULE:

```
filename.function
```


⚠️ If wrong → CI/CD works but Lambda FAILS

- Save

✅ You only need to do this once per function. After this, your Bash script can fully update the code and layers automatically.

- ### 4️⃣ Move Lambda Into VPC

| Lambda Function Name             |
|---------------------------------|
| CafeOrderProcessor               | 
| CafeOrderStatusLambda            | 
| GetOrderStatusLambda             | 
| CafeOrderWorkerLambda            | 
| AdminMarkPaidLambda              | 
| CafeAnalyticsLambda              | 
| hr-attendance                    | 
| hr-employee-profile              | 
| hr-attendance-history            | 
| hr-leaves-holidays               | 
| cafe-attendance-admin-service    | 

- AWS Console → Lambda → Your Function

- Go to Configuration → Open VPC → Click Edit

- Select:

  - VPC → same as EC2

  - Subnets → PRIVATE subnets (important)

  - Security Group → Lambda SG

- Save

- ### 5️⃣ 🌐 Environment Variables

- #### 1️⃣ CafeOrderProcessor

| Key           | Value                  |
| ------------- | ---------------------- |
| SQS_QUEUE_URL | (paste your Queue URL) |

- #### 2️⃣ cafe-attendance-admin-service

| Key              | Value            |
|------------------|------------------|
| DYNAMODB_TABLE   | CafeAttendance   |


#### 📄 github-aws-devops-lambda-deploy.sh

```
nano github-aws-devops-lambda-deploy.sh
```

[github-aws-devops-lambda-deploy.sh](./infrastructure/scripts/github-aws-devops-lambda-deploy.sh)


#### 1️⃣ One-liner to list all Lambda functions in your region

```
aws lambda list-functions --region us-east-1 --query 'Functions[].FunctionName' --output table
```

✅ This will show a table of all Lambda function names. You can check if your functions (like CafeOrderProcessor or CafeMenuLambda) exist.


#### 2️⃣ Optional: check if a specific Lambda exists before running script

```
LAMBDA_NAME="CafeOrderProcessor"
aws lambda get-function --function-name $LAMBDA_NAME --region us-east-1 >/dev/null 2>&1 && echo "$LAMBDA_NAME exists ✅" || echo "$LAMBDA_NAME does not exist ❌"
```

- Replace CafeOrderProcessor with any function name

- Returns exists / does not exist


