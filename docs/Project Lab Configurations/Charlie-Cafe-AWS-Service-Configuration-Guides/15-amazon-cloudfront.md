# Charlie Cafe — Amazon CloudFront Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon CloudFront.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

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


### 🔐 STEP 3️⃣ — CloudFront General Configuration

> **This step finalizes the CloudFront distribution behavior and ensures it works correctly with ALB + Cognito Hosted UI without breaking authentication or routing.**


### 🧠 Correct CloudFront Path Logic

| Configuration Item   | Value                             |
| -------------------- | --------------------------------- |
| Origin Path          | ❌ Empty                           |
| Default Root Object  | ✅ `cafe-admin-dashboard.html`             |
| File location on EC2 | `/var/www/html/cafe-admin-dashboard.html` |


This ensures:

```
CloudFront → ALB → EC2 Apache → cafe-admin-dashboard.html
```


### 2️⃣ 🔄 CloudFront Invalidations (Admin Dashboard Use Case)

**👉 Invalidation tells CloudFront to delete cached copies immediately.**

- Go to: CloudFront → Distributions → Your Distribution

- Click Invalidations

- Click Create invalidation

- In Object paths, enter:


#### 1️⃣ ✅ invalidation path:

```
/cafe-admin-dashboard.html
```


#### 2️⃣ ✅ /var/www/html/js/


#### Example:

```
/var/www/html/js/config.js
/var/www/html/js/central-auth.js
/var/www/html/js/utils.js
/var/www/html/js/api.js
/var/www/html/js/central-printing.js
/var/www/html/js/role-guard.js
```

#### ✅ From CloudFront perspective, the paths are:


#### Option 1 — Invalidate One-by-One (Best Practice)

```
/js/config.js
/js/central-auth.js
/js/utils.js
/js/api.js
/js/central-printing.js
/js/role-guard.js
```


### ✅ BEST PRACTICE (Better Than Invalidation)

Instead of invalidating every time, use versioning:


#### Change:

```
/js/config.js
/js/central-auth.js
/js/utils.js
/js/api.js
/js/central-printing.js
/js/role-guard.js
```


#### To:

```
/js/config.v2.js
/js/central-auth.v2.js
/js/utils.v2.js
/js/api.v2.js
/js/central-printing.v2.js
/var/www/html/js/role-guard.v2.js
```


#### Or:

```
<script src="/js/config.js?v=2"></script>
<script src="/js/central-auth.js?v=2"></script>
<script src="/js/utils.js?v=2"></script>
<script src="/js/app.js?v=2"></script>
<script src="/js/central-printing.js?v=2"></script>
<script src="/js/role-guard.js?v=2"></script>
```


#### Option 2 — Invalidate Entire JS Folder

```
/js/*
```

✔ This deletes cache for all JS files

⚠ Use only when necessary


#### Option 3 — Invalidate Everything (Heavy)

```
/*
```

⚠ Not recommended often

⚠ Counts toward invalidation limits

**✅ CloudFront treats it as new object → no invalidation needed.**


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


### 5️⃣ Click Create invalidation

⏳ Status will show:

```
In Progress → Completed
```

Usually completes in 1–3 minutes.


### How to Confirm Invalidation Worked

After status = Completed:

1️⃣ Open browser

2️⃣ Hard refresh:

- Windows/Linux: Ctrl + F5

- Mac: Cmd + Shift + R

3️⃣ Open:

```
https://xxxxx.cloudfront.net/cafe-admin-dashboard.html
```

You should see latest code.


### Important Notes:

✔ /order-status.html is the correct invalidation path

✔ Use invalidation after frontend changes

✔ Do not overuse /*

✔ Required when testing Cognito changes


### 🔐 STEP 4️⃣ — CloudFront SSL Certificate (Optional)
Viewer Certificate

Choose:

```
Default CloudFront certificate (*.cloudfront.net)
```

✅ This is fine

✅ HTTPS works automatically

❌ No ACM needed here



### 5️⃣ CloudFront Validation (VERY IMPORTANT)

> **After configuration, always validate CloudFront before integrating Cognito.**


## 6️⃣ ALB & CloudFront Configuration


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


### ✅ BEST PRACTICE (Better Than Invalidation)

Instead of invalidating every time, use versioning:

```
/js/config.v2.js
/js/central-auth.v2.js
/js/utils.v2.js
/js/api.v2.js
/js/central-printing.v2.js
/var/www/html/js/role-guard.v2.js
```


#### Or:

```
<script src="/js/config.js?v=2"></script>
<script src="/js/central-auth.js?v=2"></script>
<script src="/js/utils.js?v=2"></script>
<script src="/js/app.js?v=2"></script>
<script src="/js/central-printing.js?v=2"></script>
<script src="/js/role-guard.js?v=2"></script>
```


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

