# Charlie Cafe — Amazon Cognito Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon Cognito.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

### 3️⃣ Create central-auth.js (COGNITO ONLY)

This file contains ONLY authentication logic.

No API routes inside.

```
sudo nano /var/www/html/js/central-auth.js
```

[central-auth.js](../../☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth.js)




### 6️⃣ — USE THIS IN COGNITO

```
d2og2zrs47voou.cloudfront.net
```
**This is your Return URL**

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**


### AWS Cognito + PHP backend + protected API

[☕ AWS Cognito + PHP backend + protected API](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/AWS%20Cognito%20%2B%20PHP%20backend%20%2B%20protected%20API.md)



## 🔐 PHASE 1️⃣ — Cognito Authentication infrastructure 
> **🔐 COGNITO INTEGRATION (PRODUCTION READY)**

Cognito configuration from scratch based on your NEW architecture plan:

✅ Public routes (no login)

✅ Protected routes (Cognito + Groups)

✅ One prod stage

✅ Role-based backend enforcement

✅ SPA for management team

✅ PHP for public ordering

This will be clean, production-ready, and aligned with your new API structure.

We will rebuild Cognito properly using:

- Amazon Cognito

- Amazon API Gateway

- AWS Lambda


### 🔐 FINAL COGNITO DESIGN (BASED ON YOUR NEW PLAN)

We will configure:

- 1 User Pool

- 1 Public App Client (NO client secret)

- Hosted UI login

- Role groups:

    - Admin

    - Manager

    - Employee

- OAuth Authorization Code Grant (NOT implicit anymore)


### 1️⃣ Basic Cognito Configuration — DEFINE YOUR APPLICATION

> **🚀 STEP-BY-STEP — CLEAN NEW COGNITO SETUP**


### 🟢 STEP 1 — Create User Pool (Clean Setup)

- Go to: AWS Console → Cognito → User pools → Create user pool

- Name:

```
CharlieCafeAdminSPA
```



#### 1️⃣ Application Type

- Choose: ✅ Single-page application (SPA)

- Click Next.


#### 2️⃣ Sign-in Options

- Select: ☑ Username


#### DO NOT select:

❌ Email

❌ Phone

This keeps login simple:

```
admin
manager1
employee1
```

- Click Next.


#### 3️⃣ Self Registration

❌ Disable self-registration

(Uncheck enable self-registration)

Production systems never allow public admin registration.

Click Next.


#### 4️⃣ Required Attributes

- Click “Select attributes”

- Choose only: ☑ email

- Do NOT choose anything else.

- Click Save.

- Click Next.


### 🟢 STEP 2 — Security Settings


#### 1️⃣ Password Policy

- Leave default.

- No changes needed.


#### 2️⃣ MFA

- Set: ❌ No MFA (for now)

You can enable later in production.


#### 3️⃣ Account Recovery

- Select: ☑ Email only

- Disable SMS.

- Click Next.


### 🟢 STEP 3 — App Client (CRITICAL)

This is where most mistakes happen.


#### 1️⃣ Client Type

- Choose: ✅ Public client

This disables client secret.

If you accidentally create confidential client → delete and recreate.


#### 2️⃣ App Client Name

Example:

```
CharlieCafeAdminSPA
```

- Click Next.


### 🟢 STEP 4 — OAuth Configuration (IMPORTANT CHANGE)



#### ⚠️ We are NOT using Implicit anymore.

We will use:

✅ Authorization Code Grant (RECOMMENDED)

❌ Do NOT enable Implicit

Because:

- Implicit = older

- Authorization Code = more secure

- Industry standard now


#### 1️⃣ OAuth 2.0 Grant Types

- Select: ☑ Authorization code grant

❌ Do NOT select implicit.


#### 2️⃣ OAuth Scopes

- Select ONLY:

☑ openid

☑ email

☑ profile

Nothing else.


### 🟢 STEP 5 — Callback & Logout URLs

Add EXACT URLs:


### 1️⃣ Callback URL


#### 1️⃣ Callback Login Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/login.html
```

Example:

```
https://dxxxx.cloudfront.net/login.html
```


#### 2️⃣ Callback Admin Dashboard Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/cafe-admin-dashboard.html
```


#### 3️⃣ Callback Order Status Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/order-status.html
```


#### 4️⃣ Callback Admin Order Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/admin-orders.html
```


#### 5️⃣ Callback Analytics Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/analytics.html
```


#### 6️⃣ Callback Employee-portal Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/employee-portal.html
```


#### 7️⃣ Callback hr-attendance Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/hr-attendance.html
```


### 2️⃣ Sign-out URL

```
https://YOUR_CLOUDFRONT_DOMAIN/logout.php?loggedout=true
```

Example:

```
https://dxxxx.cloudfront.net/logout.php?loggedout=true
```

Must match EXACTLY.

- Save.

⌛️ Wait 30–60 seconds.


### 🟢 STEP 6 — Configure Cognito Domain

- Go to: User pool → App integration → Domain

- Create domain prefix:

```
charlie-cafe-auth
```

You will get:

```
charlie-cafe-auth.auth.us-east-1.amazoncognito.com
```

- Copy this.

❌ Do NOT include https.


### 🟢 STEP 7 — App Client Authentication Flows

- Go to: User pool → App clients → Show details


#### Ensure these are enabled:

✔ ALLOW_USER_PASSWORD_AUTH

✔ ALLOW_USER_SRP_AUTH

✔ ALLOW_REFRESH_TOKEN_AUTH

- ❌ Do NOT enable other unnecessary flows.



### 🟢 STEP 8 — Create Groups (FINAL STRUCTURE)

- Go to: User pool → Groups → Create group

| Group     | Group Name | Precedence |
|-----------|------------|------------|
| Group 1   | Admin      | 1          |
| Group 2   | Manager    | 5          |
| Group 3   | Employee   | 10         |

- ❌ No IAM role attached.


### 🟢 STEP 9 — Create Users

Create:

| Username  | Group    | Password            |
|-----------|----------|---------------------|
| cafeadmin | Admin    | ^MyH%H!A4YjD        |
| manager1  | Manager  | jfZvm@^3gTVE        |
| ali       | Employee | *KEXO^C3mjm3        |

- Mark email verified.

- Add each to correct group.


### 🟢 STEP 10 — Create Employee ID Attribute in Cognito

> **To make Employee ID flow correctly from Cognito → Employee Portal → Lambda → RDS, your Cognito configuration must include the Employee ID inside the ID Token.
Below is the complete correct setup step-by-step.**

- Go to : Amazon Cognito Console → User Pools → Your User Pool

- Open Sign-up experience

- Scroll to Custom attributes

- Click Add custom attribute


#### Create:

```
Name: employee_id
Type: String
Mutable: Yes
```


#### Cognito will internally store it as:

```
custom:employee_id
```


#### ⚠️ This is the exact name that will appear inside the JWT token.


### 🟢 STEP 11 — Add attribute to App Client

- Go to: App integration

- Open your App Client

- Find: Attribute read permissions

- Enable: custom:employee_id

> **✔️ Both permissions are enabled:**

  - ✔ Read

  - ✔ Write

> **This is exactly what is required so the App Client can access the attribute and include it in the JWT ID token.**

Save changes.

- Save.



### 🟢 STEP 12 — Add Employee ID to Users

- Go to: User Pools → Users → Create user / select user

- Edit attributes.

- Add:

```
custom:employee_id = 5
```


#### Example:

```
Username: ali
Email: ali@charliecafe.com
custom:employee_id = 5
```


#### Now Cognito stores:

```
custom:employee_id = 5
```

Where 5 must match the employee_id in your RDS employees table.


#### Example users: employees table

| Cognito Username | Employee ID |
| ---------------- | ----------- |
| ali              | 5           |
| ahmed            | 6           |
| sara             | 7           |

- Save.





### 🟢 STEP 13 — Amazon Cognito Hosted UI — Callback + Logout

✅ Updated Login.html (with your Cognito config structure ready)

✅ Proper cognito-callback.php (NEW – required for token handling)

✅ Updated Logout.php (with Cognito global sign-out)

🎨 Café-themed UI (coffee background, icons, logo text, warm styling)

💬 Clear comments inside the code


### 1️⃣ Updated Login Page (Charlie Café Theme)


#### ✅ Replace with your real values:

- YOUR_DOMAIN_PREFIX

- YOUR_REGION

- YOUR_APP_CLIENT_ID

- Cloudfront

[login.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cognito%20Hosted%20UI/login.html)


### ✅ 2️⃣ Updated logout.php

(Proper Cognito global sign-out + styled logout page option)

⚠️ Important: If you only destroy session locally, the user stays logged into Cognito.
We must redirect to Cognito logout endpoint.

🌟 Recommended Logout (Full Cognito Sign-Out)

Rename file to: logout.php


### 🔹 OPTION A — Global Logout (Recommended)

This:

Destroys PHP session

Logs user out from Cognito Hosted UI

Shows styled logout page


#### ⚠️ Important: When logging out from Cognito, you must redirect to Cognito first.

So the styled page must appear after Cognito redirects back.

That means:

First request → destroy session + redirect to Cognito

Second request → show styled page

We can handle both in ONE FILE using a condition.


### ✅ Single File: logout.php

[logout.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cognito%20Hosted%20UI/logout.php)


### 🧠 Why This Works

- First visit: logout.php → destroys session → redirects to Cognito → Cognito logs user out → redirects back to: 

```
logout.php?loggedout=true
```

Now PHP skips redirect and displays styled page.

🔥 Clean. Secure. One file only.


### 🎯 Important Cognito Console Setting

Inside Amazon Cognito:

Set Sign-out URL to:

```
https://YOUR_CLOUDFRONT_DOMAIN/logout.php?loggedout=true
```

Otherwise Cognito will reject the redirect.


### 🚀 Recommendation Level

This single-file approach is:
✔ Professional

✔ Secure

✔ Production-ready

✔ Cleaner file structure


### 🟢 STEP 14 — — central-auth-api


### 🔥 STEP 1 — config.js (NO LOGIC HERE)

This replaces hardcoded config from your old file.

[config.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/config.js)


#### ✅ Replace with your real values:

- YOUR_DOMAIN_PREFIX

- YOUR_REGION

- YOUR_APP_CLIENT_ID

- Cloudfront


### 🔥 STEP 2 — utils.js (Shared Helpers)

Move all generic helpers here.

[utils.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/utils.js)



### 🔐 STEP 3 — central-auth.js (COGNITO ONLY)

This file contains ONLY authentication logic.

No API routes inside.

[central-auth.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth.js)


### 🌐 STEP 4 — api.js (PUBLIC + PROTECTED FETCH)

This file handles API logic only.

[api.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/api.js)


### 🌐 STEP 5 — Create central-printing.js

[central-printing.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-printing.js)


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


### 🔐 PART 15 — EASIEST WAY TO GET ACCESS TOKEN (Manual Test)

You asked for easiest method.

Here is the clean method.


#### STEP 1️⃣ Open Cognito Hosted UI Login

- Go to AWS Console → Cognito → User Pools → Your pool

- Click App integration → App client settings


#### You will see:

- Domain

- Client ID

- Callback URL

- Allowed OAuth flows


#### STEP 2️⃣ Construct the LOGIN URL

Open browser and paste (replace values):

```
https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://yourdomain.com/login.html
```


#### 📌 Example:

```
https://charlie-cafe.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://yourdomain.com/login.html
```

- 👉 Press Enter


#### 🌐 Cognito Access Auth Code

```
https://yourdomain.com/login.html?code=ebec6a0a-54e8-49c0-a093-d68150c182b1
```


#### STEP 3️⃣ Login Screen Appears

- Enter username & password

- Click Sign in

If login is successful → browser redirects to:

```
https://yourdomain.com/login.html?code=AUTH_CODE
```

Access token will only appear after your frontend exchanges the code via:

```
POST https://YOUR_DOMAIN/oauth2/token
```


#### STEP 4️⃣ COPY THE ACCESS TOKEN

From the URL bar, copy ONLY this part:

```
?code=...
```


#### ⚠️ Do NOT copy:

- id_token

- expires_in

- token_type

👉 You need access_token


#### STEP 5️⃣ Use Token in API Call (Browser DevTools)

Open Chrome DevTools → Console

Paste:

```
fetch("https://API_ID.execute-api.REGION.amazonaws.com/status/order-status", {
  headers: {
    "Authorization": "Bearer YOUR_ACCESS_TOKEN"
  }
})
.then(res => res.json())
.then(data => console.log(data));
```


#### ✅ EXPECTED RESULT

```
{
  "orders": [...],
  "metrics": {...}
}
```

🎉 DONE — frontend token works.


### 🧪 METHOD 2 — curl (CLI / AWS TESTING)

Use this after you already have the token.


#### STEP 1️⃣ Open Terminal / CMD


#### STEP 2️⃣ Run curl Command

- Make GET request with header:

```
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
https://API_ID.execute-api.REGION.amazonaws.com/status/order-status
```


#### 📌 Example:

```
curl -H "Authorization: Bearer eyJraWQiOiJr..." \
https://abcd123.execute-api.us-east-1.amazonaws.com/status/order-status
```


#### ✅ EXPECTED RESPONSES

```
JSON response with metrics + recent orders
```


#### ✅ SUCCESS (200)

```
{
  "orders": [...],
  "metrics": {...}
}
```


#### ❌ NO TOKEN

```
{"message":"Unauthorized"}
```


#### ❌ INVALID TOKEN

```
401 Unauthorized
```


#### 3️⃣ Date Filter Test

```
curl -H "Authorization: Bearer <access_token>" \
"https://API_ID.execute-api.REGION.amazonaws.com/status/order-status?date=2026-01-17"
```


#### ✅ Expected: 

```
Only orders for 2026-01-17 returned
```

**✅ Metrics counts match filtered orders**


#### 4️⃣ Verify Auto Refresh / Chart in Frontend

- Open order-status.html

- Enter date in filter box

- Click Filter

- Metrics + table + chart should update correctly

- Spinner shows loading


### 📣 Simple & Easy way test 


#### 1️⃣ Login & Token Issued

- Open your Cafe Dashboard frontend (order-status.html).

- Click Login.

- You should be redirected to Cognito Hosted UI.

- Enter Admin credentials.

- After login, you are redirected back to the dashboard.

- Open browser DevTools → Application → Local Storage.

  - **✅ access_token should exist.**

**If no token → STOP, check Cognito setup.**


#### 2️⃣ Dashboard Loads

- After login, the dashboard content should appear (metrics + table).

- Metrics should show Total Orders, Total Items Sold, Customers.

- Orders table should populate with recent orders.

- Spinner should appear while loading, then hide.

- **✅ If dashboard is blank → STOP, check Lambda/API response.**


#### 3️⃣ Auto Refresh Works

- Wait ~10 seconds (or the interval set in frontend).

- Dashboard metrics and table should update automatically.

- Open DevTools → Network tab

  - You should see GET requests to /order-status fired every 10 seconds.

- **✅ If auto refresh doesn’t work → check setInterval(loadData, 10000) in frontend JS.**


#### 4️⃣ Date Filter Works

- On dashboard, select a date in the date picker.

- Click Filter.

- Dashboard metrics + table should update only for that date.

- Network tab → Confirm request URL:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/order-status?date=YYYY-MM-DD
```

- **✅ If metrics or table show wrong data → check Lambda filter code.**


#### 5️⃣ Chart Works

- Chart below metrics should update matching the filtered data.

- Check bars/lines correspond to orders/items counts.

- Change date → chart updates accordingly.

- **✅ If chart does not update → check frontend chart destroy/create logic.**

**✔ Everything works → Phase Complete**

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**


#### 2️⃣ – Decode JWT (jwt.io)

Confirm this exists:

```
"cognito:groups": ["Admin"]
```

**❌ If missing → group assignment failed**


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






### 🔹 Step 0 — Assumptions

- Your EC2 Apache server is already hosting other café pages.

- Your API Gateway endpoints are ready (PART 3).

- Cognito User Pool exists, and employees/admin users are registered.

- We will use JavaScript fetch API to call API Gateway with JWT from Cognito.

> **Optional: We will use Bootstrap 5 for styling and responsive UI.**


### 3️⃣ Cognito-Tester
> **📄 Cognito-Tester.html**


#### 1️⃣ Create file to EC2:

```
sudo nano /var/www/html/Cognito-Tester.html
```


#### 2️⃣ Cognito-Tester

[Cognito-Tester.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cognito%20Hosted%20UI/Cognito%20Employee%20ID%20Tester/Cognito-Tester.html)


#### 3️⃣ Test Steps

- Open the tester page in your browser.

- Fill all four input fields with your environment, domain, client ID, and redirect URI.

- Click Login & Test.

  - This will redirect to the Cognito Hosted UI.

- Enter username and password for a user in your pool.

- After login, Cognito redirects back to your tester page with a ?code=... in the URL.

- On page load, the tester:

  - Reads the authorization code from the URL

  - Exchanges the code for ID token via POST /oauth2/token

  - Parses the ID token and checks for custom:employee_id

  - Displays the environment, employee ID status, and decoded token in the table


#### 4️⃣ Expected Behavior / Output

- Environment Column:

  - Should display the value you entered in Environment Name input.

- Employee ID Status Column:

  - If custom:employee_id exists in token → shows green check with numeric employee ID.

  - If missing → shows red cross with “Missing”.

- Decoded Token Column:

  - Shows full decoded ID token JSON, including:

  - sub → Cognito user ID

  - email → user's email

  - cognito:groups → optional, if group assigned

  - custom:employee_id → numeric employee ID

  - exp, iat → token expiry and issue timestamps

  - Confirms your App Client & token configuration is correct.

- LocalStorage:

  - id_token is saved in browser localStorage, same as your portal.

- URL Cleanup:

  - After processing, the ?code=... is removed from the URL for a clean page reload.


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

## 7️⃣ AWS Cognito Authentication Configuration


### 🔐 1️⃣ Cognito User Pool (Core Setup)

| Parameter           | Value                            |
| ------------------- | -------------------------------- |
| User Pool Name      | `CharlieCafeAdminSPA`            |
| Application Type    | Single Page Application (SPA)    |
| Sign-in Method      | Username only                    |
| Example Users       | `admin`, `manager1`, `employee1` |
| Self Registration   | ❌ Disabled                       |
| Required Attributes | `email` only                     |


### 🔐 2️⃣ Security Configuration

| Setting          | Value                |
| ---------------- | -------------------- |
| Password Policy  | Default              |
| MFA              | ❌ Disabled (Dev/Lab) |
| Account Recovery | Email only           |
| SMS Recovery     | ❌ Disabled           |


### 🔐 3️⃣ App Client Configuration

| Parameter        | Value                        |
| ---------------- | ---------------------------- |
| Client Type      | Public Client (NO secret)    |
| App Client Name  | `CharlieCafeAdminSPA`        |
| OAuth Flow       | Authorization Code Grant     |
| Implicit Flow    | ❌ Disabled                   |
| Supported Scopes | `openid`, `email`, `profile` |


### 🔐 4️⃣ Authentication Flows

| Flow               | Status     |
| ------------------ | ---------- |
| USER_PASSWORD_AUTH | Enabled    |
| USER_SRP_AUTH      | Enabled    |
| REFRESH_TOKEN_AUTH | Enabled    |
| Others             | ❌ Disabled |


### 👥 5️⃣ User Groups (RBAC)

| Group    | Precedence | Purpose              |
| -------- | ---------- | -------------------- |
| Admin    | 1          | Full system access   |
| Manager  | 5          | Management dashboard |
| Employee | 10         | Employee portal      |


### 👤 6️⃣ User Management

| Username  | Group    | Email                                                         | Password (Default) | New Password | Email Verified |
| --------- | -------- | ------------------------------------------------------------- | ------------------ | ------------ | -------------- |
| cafeadmin | Admin    | [cafeadmin@charliecafe.com](mailto:cafeadmin@charliecafe.com) | ^MyH%H!A4YjD       | *KEXO^C3mjm3 | ✔ true         |
| manager1  | Manager  | [manager1@charliecafe.com](mailto:manager1@charliecafe.com)   | jfZvm@^3gTVE       | *KEXO^C3mjm3 | ✔ true         |
| ali       | Employee | [ali@charliecafe.com](mailto:ali@charliecafe.com)             | *KEXO^C3mjm3       | ^MyH%H!A4YjD | ✔ true         |



### 🧩 7️⃣ Custom Attributes (Employee Mapping)

- Go to : Amazon Cognito Console → User Pools → Your User Pool

- Open Sign-up experience

- Scroll to Custom attributes

- Click Add custom attribute

| Attribute | Value                                   |
| --------- | --------------------------------------- |
| Name      | `employee_id`                    |
| Type      | String                                  |
| Mutable   | Yes                                     |
| Purpose   | Link Cognito user → RDS employee record |

> #### Cognito will internally store it as: custom:employee_id


### 🔐 8️⃣ App Client Attribute Access

| Setting          | Value                |
| ---------------- | -------------------- |
| Read Permission  | `custom:employee_id` |
| Write Permission | `custom:employee_id` |
| Token Inclusion  | Included in JWT      |


### 🌍 9️⃣ Cognito Hosted UI

| Parameter     | Value                                                |
| ------------- | ---------------------------------------------------- |
| Domain Prefix | `charlie-cafe-auth`                                  |
| Full Domain   | `charlie-cafe-auth.auth.us-east-1.amazoncognito.com` |
| Type          | Hosted UI (OAuth2)                                   |


### 🔁 1️⃣0️⃣ OAuth Configuration

| Setting       | Value                    |
| ------------- | ------------------------ |
| Grant Type    | Authorization Code Grant |
| Implicit Flow | ❌ Disabled               |
| Scope         | openid + email + profile |


### 🔗 1️⃣1️⃣ Callback & Logout URLs

| Type          | URL                                                                     |
| ------------- | ----------------------------------------------------------------------- |
| Callback URLs | CloudFront routes (dashboard, login, order, analytics, employee portal) |
| Logout URL    | `https://YOUR_CLOUDFRONT/logout.php?loggedout=true`                     |


#### 🔗 Construct the LOGIN URL

Open browser and paste (replace values):

```
https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://yourdomain.com/login.html
```


#### 📌 Example:

```
https://charlie-cafe.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://yourdomain.com/login.html
```

- 👉 Press Enter


#### 🌐 Cognito Access Auth Code

```
https://yourdomain.com/login.html?code=ebec6a0a-54e8-49c0-a093-d68150c182b1
```


#### 🔗 Login Screen Appears

- Enter username & password

- Click Sign in

If login is successful → browser redirects to:

```
https://yourdomain.com/login.html?code=AUTH_CODE
```

Access token will only appear after your frontend exchanges the code via:

```
POST https://YOUR_DOMAIN/oauth2/token
```


### 🔐 1️⃣2️⃣ Authentication Flow Summary

| Component  | Role                        |
| ---------- | --------------------------- |
| Cognito    | Authentication + JWT tokens |
| CloudFront | Frontend hosting            |
| ALB        | Backend routing             |
| Lambda/API | Business logic              |
| RDS        | Employee + order data       |


### 🧠 1️⃣3️⃣ Token Structure (Important)

| Token Type    | Contains           |
| ------------- | ------------------ |
| ID Token      | User info + groups |
| Access Token  | API authorization  |
| Refresh Token | Session renewal    |


### 🔄 1️⃣4️⃣ Login Flow (Architecture)

```
CloudFront → Cognito Hosted UI → JWT Token → Frontend → API Gateway/Lambda → RDS
```


### 🧩 1️⃣5️⃣ Employee ID Mapping (Critical Design)

| Component         | Value                        |
| ----------------- | ---------------------------- |
| Cognito Attribute | `custom:employee_id`         |
| Purpose           | Match RDS employee table     |
| Flow              | Cognito → JWT → Lambda → RDS |


### ⚠️ 1️⃣6️⃣ Key Security Rules

| Rule                   | Status        |
| ---------------------- | ------------- |
| Self registration      | ❌ Disabled    |
| Public admin creation  | ❌ Not allowed |
| Implicit flow          | ❌ Disabled    |
| Password auth exposure | ❌ Restricted  |
| Groups-based access    | ✔ Enabled     |


### 💡 1️⃣7️⃣ Best Practices

- Use Authorization Code Flow (modern standard)

- Always enforce group-based access control

- Store no secrets in frontend

- Use custom attributes for DB mapping

- Never use implicit OAuth flow

- Always validate JWT in backend


### 🚀 Final Summary

| Layer            | Service            |
| ---------------- | ------------------ |
| Identity         | Cognito            |
| UI Auth          | Hosted UI          |
| Token            | JWT                |
| Role Control     | Cognito Groups     |
| Backend Security | Lambda/API Gateway |
| Data Layer       | RDS                |
---

## 8️⃣ ☕ Employee ID System (Cognito ↔ RDS Integration)


### 🔄 Flow Diagram (Concept)

- Employee signs up in Amazon Cognito

- Cognito generates a unique sub (User ID)

- Lambda / Admin inserts employee into RDS

- RDS stores Cognito ID as reference

- Frontend uses Cognito token → fetch employee data from RDS


### 🔄 RDS Table Structure (Employee Master Table)

| Column Name     | Data Type           | Purpose                 |
| --------------- | ------------------- | ----------------------- |
| id              | INT AUTO_INCREMENT  | Internal DB ID          |
| cognito_user_id | VARCHAR(100) UNIQUE | Links Cognito user      |
| name            | VARCHAR(100)        | Employee name           |
| job_title       | VARCHAR(50)         | Role (Barista, Manager) |
| salary          | DECIMAL(10,2)       | Salary                  |
| start_date      | DATE                | Joining date            |


### 🔄 Cognito → Employee Identity Mapping

| Cognito Attribute  | Meaning        | Usage in RDS                |
| ------------------ | -------------- | --------------------------- |
| sub                | Unique User ID | Stored as `cognito_user_id` |
| email              | Login email    | Optional mapping            |
| cognito:username   | Username       | UI reference                |
| custom:employee_id | Optional DB ID | Alternative mapping         |


### 1️⃣ Get Cognito User Info

Example Cognito user:

| Field    | Value                                  |
| -------- | -------------------------------------- |
| username | ali                                    |
| sub      | `74e8a458-a011-700d-dcdb-df9692b61962` |
| group    | Employee                               |


### 2️⃣ Insert Employee into RDS

```
INSERT INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('74e8a458-a011-700d-dcdb-df9692b61962',
 'Ali',
 'Barista',
 40000,
 '2026-03-05');
```


### 3️⃣ Verify Employee in RDS

```
SELECT * FROM employees
WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```


### 4️⃣ Batch Insert (Optional)

```
INSERT INTO employees (cognito_user_id, name, job_title, salary, start_date)
VALUES
('ID-2', 'Bob', 'Chef', 50000, '2026-03-01'),
('ID-3', 'Carol', 'Manager', 60000, '2026-02-15');
```


### 5️⃣ Integration Query (App Use Case)

```
SELECT name, job_title, salary
FROM employees
WHERE cognito_user_id = '74e8a458-a011-700d-dcdb-df9692b61962';
```


### 6️⃣ Cognito Configuration (Required Setup)


#### 🔐 App Client Settings

| Setting    | Value                    |
| ---------- | ------------------------ |
| OAuth Flow | Authorization Code Grant |
| Scope      | openid, email, profile   |


#### 🔁 Redirect URLs

| Type     | URL                                                                                                  |
| -------- | ---------------------------------------------------------------------------------------------------- |
| Callback | [https://your-cloudfront-url/employee-portal.html](https://your-cloudfront-url/employee-portal.html) |
| Logout   | [https://your-cloudfront-url/employee-login.html](https://your-cloudfront-url/employee-login.html)   |


#### 🌐 Cognito Hosted Domain

- Example: charlie-cafe-auth

- Login URL:

```
https://charlie-cafe-auth.auth.us-east-1.amazoncognito.com/login
```


### 🌐 Login Flow (Frontend)


#### 🔑 Login URL Example

```
https://charlie-cafe-auth.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://your-cloudfront-url/employee-portal.html
```


#### 🔁 After Login

Cognito returns:

```
employee-portal.html?code=xxxx
```

Frontend exchanges code → token


### 🔑 Token Verification (Frontend)

```
console.log(parseJwt(localStorage.getItem("id_token")));
```


#### ✅ Expected Token Output

```
{
  "sub": "74e8a458-a011-700d-dcdb-df9692b61962",
  "email": "ali@charliecafe.com",
  "cognito:username": "ali",
  "custom:employee_id": "5"
}
```


### 🌀 RDS ↔ Cognito Integration Logic

| Step | Action                   |
| ---- | ------------------------ |
| 1    | User logs in via Cognito |
| 2    | Get `sub` from token     |
| 3    | Use `sub` to query RDS   |
| 4    | Fetch employee record    |
| 5    | Return data to frontend  |


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


### ⚒ Final Verification Checklist


#### ✅ RDS Check

```
SHOW TABLES;
SELECT * FROM employees;
```


#### ✅ Cognito Check

- User pool active

- App client configured

- Hosted UI enabled

- OAuth scopes correct


#### ✅ Integration Check

- Token contains sub

- RDS stores cognito_user_id

- Query returns employee data


### 🎯 Final Result

✔ Cognito handles authentication

✔ RDS stores employee profile

✔ sub links both systems

✔ Frontend uses token to fetch employee data

✔ Lambda can automate employee creation
---

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


