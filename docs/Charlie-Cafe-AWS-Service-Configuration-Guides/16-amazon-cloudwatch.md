# Charlie Cafe — Amazon CloudWatch Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon CloudWatch.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

#### Result in CloudWatch:

```
{"event":"DB_CONNECTED","lambda":"order-service","status":"ok"}
```


### 4️⃣ Create CloudWatch Logs Interface Endpoint

- **Name:**

```
cloudwatch-INT-EP 
```

- **Service:**

```
com.amazonaws.us-east-1.logs
```

Same settings as above

Private DNS ✅


#### 🔹 CloudWatch Logs Endpoint

| Parameter      | Value                          |
| -------------- | ------------------------------ |
| Name           | `cloudwatch-INT-EP`            |
| Service        | `com.amazonaws.us-east-1.logs` |
| Type           | Interface                      |
| VPC            | Same VPC                       |
| Subnets        | Private subnets                |
| Security Group | `Lambda-SG`                    |
| Private DNS    | Enabled                        |


### 3️⃣ — Create CloudWatch Alarm


#### Create alarm:

- Name: charlie-health-alarm

- Metric: UnHealthyHostCount

- Target Group: charlie-green

- Condition: >= 1


### 3️⃣ — CREATE CLOUDWATCH ALARM

- Go to: 👉 CloudWatch → Alarms → Create Alarm


