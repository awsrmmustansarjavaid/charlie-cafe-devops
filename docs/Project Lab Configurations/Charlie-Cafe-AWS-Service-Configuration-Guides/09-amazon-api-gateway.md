# Charlie Cafe — Amazon API Gateway Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon API Gateway.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

#### 3️⃣ Very Important — If Using API Gateway

If your JS calls:

```
https://api-id.execute-api.us-east-1.amazonaws.com/prod
```

And that is not routed through ALB,

CloudFront settings won’t affect it.

CloudFront only affects traffic going through:

```
cloudfront.net → ALB → EC2
```

So confirm:

Are you calling API Gateway directly?
Or through ALB reverse proxy?


## PHASE 3️⃣ — API Gateway


### Objective:

Expose your `CafeOrderProcessor` Lambda function via REST API so your EC2 Café web app can send orders to it.


### 1️⃣ Create a REST API

1. Open **AWS Management Console → API Gateway**.
2. Click **Create API**.
3. Choose **REST API → Build**.
4. **Configuration:**
   - API name: `CafeOrderAPI`
   - Description: `API for processing café orders`
   - Endpoint type: `Regional` (default)
5. Click **Create API**.


### 2️⃣ Create Resource

1. In your API, click **Resources → Actions → Create Resource**.
2. Configure:
   - Resource Name: `orders`
   - Resource Path: `/orders`
3. Click **Create Resource**.


### 3️⃣ Create POST Method

1. Select `/orders` resource.
2. Click **Actions → Create Method → POST**.
3. Integration type: **Lambda Function**
   - Check **Use Lambda Proxy integration**
   - Lambda Region: `us-east-1`
   - Lambda Function: `CafeOrderProcessor`
4. Click **Save** → **OK** to give permissions to API Gateway to invoke Lambda.


### 4️⃣ Enable CORS (Cross-Origin Resource Sharing)

1. Select `/orders` resource.
2. Click **Actions → Enable CORS**.
3. Configure:
   - Allowed Methods: `POST`
   - Allowed Headers: `Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token`
   - Allow Credentials: unchecked
4. Click **Enable CORS and replace existing CORS headers**.
5. Click **Yes, replace existing values** if prompted.

**⚠️ DO NOT attach authorizer**


### 5️⃣ Deploy API

1. Click **Actions → Deploy API**.
2. Configure:
   - Deployment stage: `prod`
   - Stage description: `Development stage`
   - Deployment description: `Initial deployment`
3. Click **Deploy**.


### 6️⃣ Copy API Invoke URL

After deployment, you’ll see an **Invoke URL** at the top of the Stage page, e.g.:

```
https://abcdef123.execute-api.us-east-1.amazonaws.com/prod/orders
```

> This URL will be used in your EC2 PHP web app `curl` requests.


### 2nd Method - ADD API GATEWAY TRIGGER Method


### 1️⃣ ADD API GATEWAY TRIGGER


When you go to:

- CafeOrderProcessor Lambda → Add Trigger → API Gateway

- Choose: Create an API

| Setting  | Value              |
| -------- | ------------------ |
| API Type | REST API           |
| Security | Open (for testing) |

- Click Add


#### ➡️ AWS automatically:

```
- Creates an API

- Creates a resource

- Creates a method (POST/GET)

- Connects it to the Lambda

- Adds permission so API Gateway can invoke the Lambda

- This is the Lambda-centric way.

You start from Lambda and let AWS build the API for you.
```


### 2️⃣ Get Your Endpoint

- Go to API Gateway → Open your new API

- Click: Stages → Prod


#### ✅ You will see:

```
Invoke URL:
https://abc123.execute-api.us-east-1.amazonaws.com/Prod
```

Your final endpoint will be:

```
https://abc123.execute-api.us-east-1.amazonaws.com/Prod
```

If resource path is /orders:

```
https://abc123.execute-api.us-east-1.amazonaws.com/Prod/orders
```


### 3️⃣ — ENABLE CORS

- Inside API Gateway:

- Click Resources

- Select /orders

- Click Actions

- Choose: Enable CORS

- Confirm

- Deploy API again

This prevents browser blocking.


### 4️⃣ — Deploy API

- After any change:

- Click Actions

- Click Deploy API

- Choose: Prod

- Deploy

Without deploy → it will NOT work.


### 5️⃣ — TEST 


#### 1️⃣ Test API Gateway Endpoint (Console Method)

- Go to AWS Console

- Click API Gateway

- Open your API

- Click Resources

- Click /orders

- Click POST

- On the POST method page

- Click the Test button (top right)

- Update Request Body

In Request Body, paste:

```
{
  "table_number": 3,
  "customer_name": "ApiTest",
  "item": "Coffee",
  "quantity": 1,
  "payment_method": "CASH"
}
```

- Leave:

  - Headers empty (unless using auth)

  - Query params empty

- Click “Test” (Blue Button)

- Scroll down to see:

  - Request

  - Response Body

  - Response Headers

  - Logs


#### ✅ Expected Success Response

You should see:

```
{
  "order_id": "...",
  "table_number": 3,
  "customer_name": "ApiTest",
  "item": "Coffee",
  "quantity": 1,
  "total": 3.0,
  "status": "RECEIVED",
  "created_at": "..."
}
```

#### 2️⃣ TEST WITH CURL (Important)

Test outside PHP first.

- Open terminal:

```
curl -X POST https://hihe1z5ci7.execute-api.us-east-1.amazonaws.com/prod/orders \
-H "Content-Type: application/json" \
-d '{"table_number":5,"customer_name":"John","item":"Coffee","quantity":2,"payment_method":"CASH"}'
```

If correct, you get:

```
{
  "message": "Order created successfully",
  "table_number": 5
}
```


#### Then check:

- RDS → new row

- DynamoDB → updated

- SQS → message sent


### 🔹 2️⃣ “Lambda integrated inside API Gateway”

When you go to:

- API Gateway → Create Resource → Create Method → Integration = Lambda

You are:

- Designing API structure first

- Choosing which Lambda to connect

- Controlling stages, routes, throttling, etc.

- This is the API-centric way.

You start from API Gateway and connect Lambda manually.


### 🎯 Technically:

👉 Both result in the exact same architecture.

Internally it always becomes:

```
Client → API Gateway → Lambda
```

There is no architectural difference. The difference is only how you configure it.


### 🚀 Real Differences (Practical)

| Feature             | Add Trigger from Lambda | Integrate from API Gateway |
| ------------------- | ----------------------- | -------------------------- |
| Setup Speed         | Very fast               | Manual setup               |
| Control over routes | Limited                 | Full control               |
| Good for production | ❌ Not ideal             | ✅ Yes                      |
| Multi-endpoint APIs | Hard                    | Easy                       |
| Versioning & stages | Basic                   | Full control               |
| Best for quick test | ✅ Yes                   | ❌ Overkill                 |


### 🔥 When Should You Use Each?


#### ✅ Use “Add Trigger from Lambda” if:

- Quick prototype

- Testing only

- Single endpoint

- Small internal tool


### ✅ Use “Integrate from API Gateway” if:

Production system

Multiple endpoints like:

```
POST /orders
GET /orders
PUT /orders/{id}
GET /serving
POST /payment
```

- Need throttling

- Need authentication

- Need API keys

- Need usage plans


### 💡 Another Important Difference (Permissions)

When you add trigger from Lambda:

AWS automatically adds this permission:

```
{
  "Principal": "apigateway.amazonaws.com"
}
```

When you integrate from API Gateway:

You may need to manually allow Lambda invocation.

So Lambda-trigger method is easier for beginners.


### 🎯 Final Recommendation For You

Since your system is growing (admin, status, metrics, serving, payments):

👉 Use API Gateway as the main controller

👉 Integrate Lambdas inside API Gateway

👉 Don’t rely on “Add Trigger” shortcut

This gives you:

- Cleaner architecture

- Easier scaling

- Better long-term management

- Production-ready structure


### 🏆 Summary

There is no runtime difference.

The difference is:

| Lambda trigger method | Quick & automatic |
| API Gateway integration method | Structured & production-ready |


**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---


## PHASE 5️⃣ — API GATEWAY ENDPOINT

👉 Use your EXISTING API

👉 Create a NEW METHOD (GET /order-status) on it

❌ Do NOT create a new API


### 🧠 WHY YOU SHOULD USE THE EXISTING API


#### You already have something like:

```
CafeOrdersAPI
https://xxxxx.execute-api.us-east-1.amazonaws.com/prod
```


#### And inside it you probably have:

```
POST /orders       → CreateOrderLambda
```


#### ✔️ This is CORRECT architecture

One API = One backend system
Multiple resources/methods inside it

**Creating multiple APIs would be:**

❌ Hard to manage

❌ Bad practice

❌ Confusing for frontend


### STRUCTURE (VISUAL)

```
CafeOrdersAPI
│
├── POST /orders
│     └── CreateOrderLambda
│
└── GET /get-order-status
      └── GetOrderStatusLambda
```

✔️ SAME API

✔️ DIFFERENT Lambda functions


### 1️⃣ Open API Gateway


#### API Gateway → Open Your Existing API (example: CafeOrdersAPI) → Resources


### 2️⃣ Create Resource

```
Resource name: get-order-status
Resource path: /get-order-status
```

Click Create resource


### 3️⃣ Create NEW METHOD

Select /get-order-status

Click Create Method

```
GET /get-order-status
```

- **Method:** GET

- **Integration:** Lambda

- **Select GetOrderStatusLambda**

- **Lambda name:** GetOrderStatusLambda

✔️ Enable Lambda proxy integration

Click Create method



### 4️⃣ Enable CORS (VERY IMPORTANT)

Select /get-order-status

Actions → Enable CORS

✔️ GET

✔️ OPTIONS

Click Enable CORS and replace existing CORS headers


### 5️⃣ Deploy API (MOST MISSED STEP 🚨)

API Gateway → Actions → Deploy API

| Field            | Value                 |
| ---------------- | --------------------- |
| Deployment stage | Exist stage             |
| Stage name       | Prod               |
| Description      | Order status endpoint |

Click Deploy


### 6️⃣ Test with API Gateway


#### 1️⃣ Test API Gateway Endpoint (Console Method)

- Go to AWS Console

- Click API Gateway

- Open your API

- Click Resources

- Click /get-order-status

- Click GET

- On the GET method page

- Click the Test button (top right)

- Update Request Body

In Request Body, paste:

```
{}
```


#### 🌐 FINAL API URL

```
GET https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/get-order-status
```


#### 🧪 TEST IT (MUST WORK)

```
curl https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/get-order-status
```


#### ✅ You MUST see JSON like:

```
{
  "metrics": [
    {"metric":"Total Orders","count":15}
  ],
  "recent_orders": [
    {
      "customer_name":"Ali",
      "item":"Coffee",
      "quantity":2,
      "created_at":"2026-01-09 12:30:00"
    }
  ]
}
```

❌ If this does not work → STOP. Fix backend first.


#### Open browser:

```
https://API_ID.execute-api.region.amazonaws.com/prod/get-order-status
```


#### Example;

```
https://a1053skr51.execute-api.us-east-1.amazonaws.com/prod/get-order-status
```

✔ JSON visible

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---

### 6️⃣ — CREATE API GATEWAY (READ-ONLY)


#### 1️⃣ Open API Gateway 

- Open → REST API 


#### 2️⃣ Create Resource

```
/cafe-order-status
```


#### 3️⃣ Create GET Method


#### Integration:

    - Lambda Function

    - CafeOrderStatusLambda

Enable Lambda Proxy Integration


#### 4️⃣ Enable CORS

- **Allow Origin:** *

- **Allow Methods:** GET

- **Allow Headers:** *


#### 5️⃣ Deploy API


#### Stage name:

```
prod
```

**Copy Invoke URL**


#### Example:

```
https://xxxx.execute-api.us-east-1.amazonaws.com/prod/cafe-order-status
```


### 🌐 STEP 5 — CREATE New Resources API GATEWAY FOR WORKER


#### Resources

```
/order-update
```

- API Method: POST

- Integration: CafeOrderWorkerLambda

- Enable CORS

- Check Box : POST

- Deploy stage: order-update


#### Endpoint 

```
POST /order-update
```


#### 🔹 4.1 Open API Gateway

- AWS Console → API Gateway → Choose your existing REST API (or create a new one)


#### 🔹 4.4 Enable CORS (MANDATORY)

- Select /admin/mark-paid

- Click Enable CORS

- Accept defaults

- Save


## PHASE 3️⃣  – API GATEWAY


### 1️⃣ – API GATEWAY CONFIGURATION


####  1️⃣ Create Resource

- **Go to API Gateway → Your Existing API → Resources → Create Resource**

```
Resource Name: analytics
Resource Path: /analytics
```


####  2️⃣ CREATE METHOD

```
Create Method → GET
Integration: Lambda Proxy
Lambda: CafeAnalyticsLambda
```


####  3️⃣ ENABLE CORS

```
Actions → Enable CORS
```


#### Confirm:

```
GET, OPTIONS
```


####  4️⃣ QUERY STRING PARAMETERS


#### 1️⃣ Find URL Query String Parameters

> **You will see sections like:**

- Authorization

- Request Validator

- URL Query String Parameters

- HTTP Request Headers


#### 👉 Find this section:

```
URL Query String Parameters
```


#### 2️⃣ ADD period PARAMETER (EXACT)

- Click Edit (top right)

- Under URL Query String Parameters

- Click Add query string

- **Enter:**

```
Name: period
Required: ❌ NO (leave unchecked)
```

#### Set Allowed Values for period Parameter

- After adding the query string period (Required = ❌ No), click on it.

- Look for “Request Validator / Model” or “Validation” (depends on API Gateway type).

- Under Allowed Values / Enum (if using REST API Request Validator with Model):

```
today
week
month
```

- **Click Save**


#### ⚠️ Important Notes

- ⚠️ If you skip this, API Gateway will accept any value and Lambda must handle invalid ones.

- ⚠️ Do NOT mark it required

- ⚠️ Required = unchecked,  You don’t need to mark as required — Lambda already checks for invalid or missing values.


#### In short:

| Parameter | Required | Allowed Values     |
| --------- | -------- | ------------------ |
| period    | No       | today, week, month |


**That’s it — this is all you need for allowed values configuration.**



#### 3️⃣ VERIFY

> **You must now see:**

```
URL Query String Parameters
--------------------------------
period   false
```

**⚠️ If you don’t see this → it was NOT saved.


#### 4️⃣ DO NOTHING ELSE HERE

✅ Do NOT add mapping templates

✅ Do NOT add models

✅ Do NOT add validators

✅ Do NOT touch headers

**⚠️  Because: ✔ Lambda Proxy Integration already passes query parameters automatically**


####  5️⃣ DEPLOY API

> **If you skip this → nothing works**

- Click Actions

- Click Deploy API

- **Choose:**

```
Stage: prod
```

(or your existing stage)

- **Click Deploy**


#### 6️⃣ FINAL API URL FORMAT (CONFIRM)

Your final URL MUST look like this:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/analytics?period=today
```


#### Examples:

```
?period=today
?period=week
?period=month
```


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



## ☕ Charlie Café PHASE 3️⃣ — API Gateway Setup for HR Secure Attendance System


### 🔹 Step 0 — Assumptions


#### We already have:

- EC2 Apache frontend

- Lambda functions (5 HR Lambdas) fully working and tested

- RDS database with employees, attendance, leaves, holidays

- Cognito User Pool already created

| Method | Resource           | Path                   | Lambda Function             |
|-------|-------------------|------------------------|-----------------------------|
| POST  | Attendance        | `/attendance/checkin`  | `hr-attendance`             |
| POST  | Attendance        | `/attendance/checkout` | `hr-attendance`             |
|  POST    | Employee Profile  | `/employee-profile`    | `hr-employee-profile`       |
|  POST   | Attendance History| `/attendance-history`  | `hr-attendance-history`     |
|  POST    | Leaves & Holidays | `/leaves-holidays`     | `hr-leaves-holidays`        |

**⚠️ All methods = POST**


### 1️⃣ Open API Gateway

- Go to AWS Console → API Gateway → Open API

- Choose REST API (not HTTP API)

- API Name:

```
CafeOrderAPI
```

- Description:

```
HR Secure Attendance & Employee Management API
```

- Endpoint Type: Regional

- Click Create API


### 2️⃣ Create Resources (Paths)

| Method | Resource           | Path                   | Lambda Function             |
|-------|-------------------|------------------------|-----------------------------|
| POST  | Attendance        | `/attendance/checkin`  | `hr-attendance`             |
| POST  | Attendance        | `/attendance/checkout` | `hr-attendance`             |
|  POST    | Employee Profile  | `/employee-profile`    | `hr-employee-profile`       |
|  POST   | Attendance History| `/attendance-history`  | `hr-attendance-history`     |
|  POST    | Leaves & Holidays | `/leaves-holidays`     | `hr-leaves-holidays`        |


#### Step 1 — Add /attendance 

- Click Actions → Create Resource

- Resource Name: attendance

- Resource Path: /attendance

- Click Create Resource


#### Step 2 — Repeat for remaining resources

- /employee-profile

- /attendance-history

- /leaves-holidays

- /exchange-token


### 3️⃣ Create Methods


#### For each resource:

    - Click on Resource → Actions → Create Method

    - Select POST for /attendance,  /employee-profile, /attendance-history, /leaves-holidays , /exchange-token


### 5️⃣ Enable CORS (Cross-Origin Resource Sharing)


#### For each resource method:

- Click Method → Actions → Enable CORS

- Integration type → Mock Integration

- Allowed:

    - POST

    - OPTIONS

- Headers: 

```
*
```

Now configure 


#### Method Response

- Add status code: 200

- Add Response Headers:

    - Access-Control-Allow-Origin

    - Access-Control-Allow-Headers

    - Access-Control-Allow-Methods


#### Integration Response

Under Header Mappings add:  

```
Access-Control-Allow-Origin  ->  '*'
Access-Control-Allow-Headers ->  'Content-Type'
Access-Control-Allow-Methods ->  'GET,POST,OPTIONS'
```

- Save.

- Repeat for all 4 resources.


#### ✅ CORRECT PUBLIC CORS CONFIGURATION

Because you are using Lambda Proxy Integration, API Gateway CORS headers are NOT required in Method Response.

Your Lambda already returns:

```
"headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
}
```

That is enough.


### 6️⃣ Cognito Authorizers

- Go to Authorizers

- Create new:

  - Name: Cognito-Authorizer

  - Type: Cognito

  - User Pool: your pool

  - Token source: Authorization

- Attach authorizer to ALL endpoints:  

```
/employee-profile
/attendance-history
/leaves-holidays
```


#### 👉 Now API Gateway expects:

```
Authorization: Bearer <JWT>
```






### 7️⃣ Deploy API

- Actions → Deploy API

- Deployment stage: prod

- Stage description: HR Secure API

- Deploy


### ✅ Copy the Invoke URL. Example:

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/
```


### ✅ Final API Endpoint

Your endpoint becomes:

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/attendance
```

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/employee-profile
```

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/attendance-history
```

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/leaves-holidays
```

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/exchange-token
```

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

### 3️⃣ —API Gateway Configuration

- Resource Structure: /hr-analytics

```
/hr-analytics
```

- Method: GET

- Integration:

    - Type: Lambda

    - Lambda: hr-admin-attendance-analytics

    - Enable Lambda Proxy Integration ✅


### 4️⃣ ENABLE CORS

Still inside /hr-analytics:

- Click Actions → Enable CORS

- Headers: None ,Content-Type

- Methods: GET,OPTIONS

- Origin: *

- Click Enable CORS and replace

- Deploy

- Stage: prod

You will get something like:

```
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod
```

Final endpoint becomes:

```
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/hr-analytics
```


#### ✅ Final API Endpoints

```
GET /hr-analytics?type=daily
GET /hr-analytics?type=weekly&summary=true
GET /hr-analytics?employee_id=EMP001
GET /hr-analytics?employee_id=EMP001&date=2026-02-25
```

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---

### 2️⃣ API Gateway Endpoints


#### 1️⃣ Create a REST API

- Open AWS Management Console → API Gateway.

- Click Create API.

- Choose REST API → Build.

- Configuration:

  - API name: CafeOrderAPI

  - Description: API for processing café orders

  - Endpoint type: Regional (default)

- Click Create API.


#### 2️⃣ Create Resource

- In your API, click Resources → Actions → Create Resource.

- Configure:

  - Integration type: Lambda Function

  - Lambda Region: us-east-1

  - Check Use Lambda Proxy integration

| Resource Name        | Resource Path           | Lambda Function                | API Method | Enable CORS |
|---------------------|------------------------|-------------------------------|------------|-------------|
| orders              | /orders               | CafeOrderProcessor            | POST       | Yes         |
| get-order-status    | /get-order-status     | GetOrderStatusLambda          | GET        | Yes         |
| cafe-order-status   | /cafe-order-status    | CafeOrderStatusLambda         | GET        | Yes         |
| order-update        | /order-update         | CafeOrderWorkerLambda         | POST       | Yes         |
| mark-paid           | /admin/mark-paid      | AdminMarkPaidLambda           | POST       | Yes         |
| analytics           | /analytics            | CafeAnalyticsLambda           | GET        | Yes         |
| Attendance          | /attendance/checkin   | hr-attendance                 | POST       | Yes         |
| Attendance          | /attendance/checkout  | hr-attendance                 | POST       | Yes         |
| Employee Profile    | /employee-profile     | hr-employee-profile           | POST       | Yes         |
| Attendance History  | /attendance-history   | hr-attendance-history         | POST       | Yes         |
| Leaves & Holidays   | /leaves-holidays      | hr-leaves-holidays            | POST       | Yes         |
| hr-analytics        | /hr-analytics         | cafe-attendance-admin-service | GET        | Yes         |

- Click Save → OK to give permissions to API Gateway to invoke Lambda.


#### 3️⃣ Enable CORS (Cross-Origin Resource Sharing)
> Repeat the same configuration for all API application resources listed above.

- Select resource 

> for example /orders

- Click Actions → Enable CORS.

- Configure:

  - Allowed Methods: Select method of paritcular resource

  - Allowed Headers: Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token

  - Allow Credentials: unchecked

- Click Enable CORS and replace existing CORS headers.

- Click Yes, replace existing values if prompted.


#### 4️⃣ Deploy API

- Click Actions → Deploy API.

- Configure:

  - Deployment stage: prod

  - Stage description: Development stage

  - Deployment description: Initial deployment

- Click Deploy.


#### 5️⃣ Cognito Authorizers

- Go to Authorizers

- Create new:

  - Name: Cognito-Authorizer

  - Type: Cognito

  - User Pool: your pool

  - Token source: Authorization

- Attach authorizer to these 3 endpoints:

```
/employee-profile

/attendance-history

/leaves-holidays
```

👉 Now API Gateway expects:

```
Authorization: Bearer <JWT>
```


#### 6️⃣ Copy API Invoke URL

After deployment, you’ll see an Invoke URL at the top of the Stage page, e.g.:

```
https://abcdefg123.execute-api.us-east-1.amazonaws.com/prod/
```


#### ✅ Final API Endpoint

| Resource Name        | Full Endpoint URL                                      | Lambda Function                | Method | CORS |
|---------------------|--------------------------------------------------------|-------------------------------|--------|------|
| orders              | https://api.yourdomain.com/orders                     | CafeOrderProcessor            | POST   | Yes  |
| get-order-status    | https://api.yourdomain.com/get-order-status          | GetOrderStatusLambda          | GET    | Yes  |
| cafe-order-status   | https://api.yourdomain.com/cafe-order-status         | CafeOrderStatusLambda         | GET    | Yes  |
| order-update        | https://api.yourdomain.com/order-update              | CafeOrderWorkerLambda         | POST   | Yes  |
| mark-paid           | https://api.yourdomain.com/admin/mark-paid           | AdminMarkPaidLambda           | POST   | Yes  |
| analytics           | https://api.yourdomain.com/analytics                 | CafeAnalyticsLambda           | GET    | Yes  |
| attendance-checkin  | https://api.yourdomain.com/attendance/checkin        | hr-attendance                 | POST   | Yes  |
| attendance-checkout | https://api.yourdomain.com/attendance/checkout       | hr-attendance                 | POST   | Yes  |
| employee-profile    | https://api.yourdomain.com/employee-profile          | hr-employee-profile           | POST   | Yes  |
| attendance-history  | https://api.yourdomain.com/attendance-history        | hr-attendance-history         | POST   | Yes  |
| leaves-holidays     | https://api.yourdomain.com/leaves-holidays           | hr-leaves-holidays            | POST   | Yes  |
| hr-analytics        | https://api.yourdomain.com/hr-analytics              | cafe-attendance-admin-service | GET    | Yes  |

Your endpoint becomes:

```
https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/orders

https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/get-order-status

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/cafe-order-status

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/order-update

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/admin/mark-paid

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/analytics

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/attendance/checkin

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/attendance/checkout

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/employee-profile

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/attendance-history

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/leaves-holidays

https://xxxx.execute-api.us-east-1.amazonaws.com/prod/hr-analytics

```


