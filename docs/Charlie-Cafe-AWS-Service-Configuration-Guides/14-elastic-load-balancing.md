# Charlie Cafe — Elastic Load Balancing (ALB) Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Elastic Load Balancing (ALB).

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

### 1️⃣  — USE ALB

> **This is the simplest HTTPS solution.**


### STEP 1️⃣ — CREATE APPLICATION LOAD BALANCER

```
EC2 → Load Balancers → Create Load Balancer
```


#### Choose:

```
Application Load Balancer
```


### STEP 2️⃣ — BASIC ALB Configuration


| Setting                  | Value / Selection                                      | Notes / Requirement                          |
|--------------------------|--------------------------------------------------------|----------------------------------------------|
| **Name**                 | charlie-cafe-alb                                       | Unique name for your ALB                     |
| **Scheme**               | Internet-facing                                        | Allows public internet access                |
| **IP address type**      | IPv4                                                   | Standard for most setups                     |
| **VPC**                  | Same VPC as your EC2 instance                          | Must match EC2 placement                     |
| **Subnets**              | Select at least 2 **public** subnets                   | Required for internet-facing ALB; choose different Availability Zones if possible |
| **Availability Zones**   | At least 2 AZs (where public subnets exist)            | Improves high availability                   |



### STEP 4️⃣ — Target Group Configuration (for EC2 registration)


| Setting                  | Value / Selection                          | Notes / Requirement                                      |
|--------------------------|--------------------------------------------|----------------------------------------------------------|
| **Type**                 | Instance                                   | Standard for registering EC2 instances by ID             |
| **Protocol**             | HTTP                                       | Matches your web server on EC2 (use HTTPS only if EC2 already has SSL) |
| **Port**                 | 80                                         | Default HTTP port your web server listens on             |
| **Target registration**  | Register your EC2 instance                 | Select your EC2 instance by name/ID (not IP)             |
| **Health check path**    | / (or /cafe-admin-dashboard.html)                  | Path ALB uses to check if instance is healthy            |


### STEP 5️⃣ — Add Listener to ALB 


#### - Add HTTP listener 

- **Listener:** HTTP 80

- **Target Group:** Select Your Target Group


#### - Add HTTPS listener (Optional)


| Setting                  | Value / Selection                                      | Notes / Requirement                                                                 |
|--------------------------|--------------------------------------------------------|-------------------------------------------------------------------------------------|
| **Listener**             | HTTPS : 443                                            | Standard secure port for HTTPS traffic                                              |
| **Certificate**          | Request or select from ACM (AWS Certificate Manager)   | Must use a valid SSL/TLS certificate; free public certs available via ACM           |
| **Certificate source**   | ACM                                                    | Recommended – free, auto-renewing certificates                                      |
| **Domain name (for ACM request)** | Your domain (e.g., charliecafe.com, *.charliecafe.com) | Required to request certificate; can be:<br>• Real domain you own<br>• Wildcard (*.example.com)<br>• Multiple SANs (Subject Alternative Names) |
| **Validation method**    | DNS validation (preferred) or Email                    | DNS is faster & automatic if using Route 53                                         |
| **Default action**       | Forward to target group (e.g., cafe-target-group)      | Routes HTTPS traffic to your EC2 instance(s)                                        |
| **HTTP → HTTPS redirect** | Add separate HTTP:80 listener with redirect rule       | Recommended: Redirect all HTTP traffic to HTTPS                                     |


### STEP 6️⃣ — GET ALB DNS NAME

Example:

```
https://charlie-cafe-alb-123.us-east-1.elb.amazonaws.com
```


### 🧱 STEP 1️⃣ — CloudFront Origin (ALB)


#### Go to:

```
AWS Console → CloudFront → Create Distribution
```

- **Distribution name:** Charlie-Cafe

- **Next:**

- **Origin type:** Elastic Load Balancer


#### CloudFront Origin Settings (CRITICAL)

>**Go to:** CloudFront → Distributions → Your Distribution → Origins → Edit

> **Set EXACTLY like this:**

| Setting                | Value                                                   |
| ---------------------- | ------------------------------------------------------- |
| Origin domain          | charlie-cafe-alb-1050813156.us-east-1.elb.amazonaws.com |
| Origin protocol policy | **HTTP only** ✅                                         |
| HTTP port              | 80                                                      |
| Origin SSL protocols   | (doesn’t matter now)                                    |


✅ This is correct

❌ Do NOT select EC2 IP

❌ Do NOT select S3


## 6️⃣ ALB & CloudFront Configuration


### ⚖️ 1️⃣ Application Load Balancer (ALB)


#### 🔹 Core Configuration

| Parameter      | Value                              |
| -------------- | ---------------------------------- |
| Name           | `charlie-cafe-alb`                 |
| Scheme         | Internet-facing                    |
| IP Type        | IPv4                               |
| VPC            | `CafeDevVPC`                       |
| Subnets        | 2+ Public Subnets (multi-AZ)       |
| Security Group | Allow HTTPS (443) from `0.0.0.0/0` |


#### 🔹 Target Group (EC2 Backend)

| Parameter    | Value                               |
| ------------ | ----------------------------------- |
| Type         | Instance                            |
| Protocol     | HTTP                                |
| Port         | 80                                  |
| Target       | EC2 Instance (`CafeDevWebServer`)   |
| Health Check | `/` or `/cafe-admin-dashboard.html` |


#### 🔹 Listeners (HTTP → HTTPS Setup - Optional)

| Listener   | Action                  |
| ---------- | ----------------------- |
| HTTP :80   | Redirect → HTTPS :443   |
| HTTPS :443 | Forward to Target Group |


#### 🔹 SSL Certificate (ACM - Optional)

| Parameter  | Value                         |
| ---------- | ----------------------------- |
| Source     | AWS Certificate Manager (ACM) |
| Type       | Public SSL Certificate        |
| Validation | DNS (recommended)             |
| Domain     | Your domain / wildcard        |


#### 🔹 ALB Output

| Item    | Value                                                         |
| ------- | ------------------------------------------------------------- |
| ALB DNS | `http(s)://charlie-cafe-alb-xxxx.us-east-1.elb.amazonaws.com` |


### ☁️ 2️⃣ CloudFront Configuration


#### 🔹 Origin (ALB Backend)

| Parameter       | Value                                               |
| --------------- | --------------------------------------------------- |
| Origin Type     | Application Load Balancer                           |
| Origin Domain   | ALB DNS (`charlie-cafe-alb-xxxx.elb.amazonaws.com`) |
| Origin Protocol | HTTP only                                           |
| Port            | 80                                                  |


#### 🔹 Default Cache Behavior

| Setting                | Value                                        |
| ---------------------- | -------------------------------------------- |
| Viewer Protocol Policy | Redirect HTTP → HTTPS                        |
| Allowed Methods        | GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE |
| Cache Policy           | CachingDisabled                              |
| Origin Request Policy  | AllViewer                                    |


#### 🔹 Key Purpose

| Feature           | Purpose                      |
| ----------------- | ---------------------------- |
| Forward Headers   | Auth (Cognito tokens)        |
| Disable Cache     | Prevent login/session issues |
| Full HTTP Methods | Support APIs + forms         |


#### 🔹 General Settings

| Parameter           | Value                       |
| ------------------- | --------------------------- |
| IPv6                | Disabled (lab setup)        |
| Default Root Object | `cafe-admin-dashboard.html` |
| Origin Path         | Empty                       |


#### 🔹 Routing Flow

```
CloudFront → ALB → EC2 → Apache → Web App
```


#### 🔹 CloudFront Domain

| Item | Value                  |
| ---- | ---------------------- |
| URL  | `xxxxx.cloudfront.net` |


### 🔄 3️⃣ CloudFront Invalidations


#### 🔹 Common Paths

| Type           | Path                         |
| -------------- | ---------------------------- |
| HTML           | `/cafe-admin-dashboard.html` |
| Full JS Folder | `/js/*`                      |
| Entire Cache   | `/*`                         |


#### 🔹 Best Practice (Recommended)

| Method            | Recommendation               |
| ----------------- | ---------------------------- |
| Versioning        | `app.v2.js` or `?v=2`        |
| Cache Bypass      | Avoid frequent invalidations |
| Full Invalidation | Use only when required       |


### 🔐 4️⃣ Cognito Integration

| Parameter            | Value                          |
| -------------------- | ------------------------------ |
| Hosted UI Return URL | `https://xxxxx.cloudfront.net` |
| Login Flow           | ALB → CloudFront → EC2         |
| Requirement          | HTTPS mandatory                |


#### 💡 Key Notes

- ALB handles traffic routing + SSL termination

- CloudFront handles global caching + HTTPS enforcement

- Always use HTTPS (required for Cognito)

- Avoid caching API/auth responses

- Use versioning instead of frequent invalidations
---

#### 2️⃣ Update ALB Listener

- Go to: EC2 → Load Balancer → Listeners

- Edit HTTP:80


### 2️⃣ Verify Target Group

- Go EC2 → Target Groups → charlie-blue → Targets

> You should see IP addresses (Fargate tasks) and Status: Healthy


#### You should see:

- IP addresses (NOT EC2)

- Status: Healthy


