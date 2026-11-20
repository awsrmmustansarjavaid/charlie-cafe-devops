# Charlie Cafe — AWS Certificate Manager (ACM) Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for AWS Certificate Manager (ACM).

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

### 🔐 STEP 4️⃣ — CloudFront SSL Certificate (Optional)
Viewer Certificate

Choose:

```
Default CloudFront certificate (*.cloudfront.net)
```

✅ This is fine

✅ HTTPS works automatically

❌ No ACM needed here



#### 🔹 SSL Certificate (ACM - Optional)

| Parameter  | Value                         |
| ---------- | ----------------------------- |
| Source     | AWS Certificate Manager (ACM) |
| Type       | Public SSL Certificate        |
| Validation | DNS (recommended)             |
| Domain     | Your domain / wildcard        |


