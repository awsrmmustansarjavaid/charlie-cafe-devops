# Charlie Cafe — Amazon DynamoDB Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon DynamoDB.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

## PHASE 1 — AMAZON DYNAMODB (Menu + Cache Layer)


### 1️⃣ Create DynamoDB Table

- **DynamoDB → Create table**


### 1️⃣ Basic Table Settings

| Field         | Value      |
| ------------- | ---------- |
| Table name    | `CafeMenu` |
| Partition key | `item`     |
| Type          | `String`   |


##### ⚠️ Do NOT add Sort key


##### ⚠️ Partition key name must be exactly item


### 2️⃣ Table Settings (Capacity)

Scroll down to Table settings

- Capacity mode:

    ✅ On-demand


#### Why?

- No capacity planning

- Free-tier friendly

- Ideal for learning & small apps


### 3️⃣ Additional Settings (Keep Default)

Leave ALL of these as default:

- Encryption at rest: AWS owned key

- Table class: Standard

- Deletion protection: Disabled

- Tags: Optional (skip)


### 4️⃣ Create Table

- Click Create table


#### Wait until:

```
Status = ACTIVE
```


##### ⏳ This may take 20–60 seconds


### 2️⃣ Insert Menu Items

- **DynamoDB → CafeMenu → Explore table → Create item**


### 1️⃣ Method 1 JSON EDitor


#### 1️⃣ Create First Item (Coffee)

You will see a JSON editor.

Replace everything with:

```
{
  "item": {
    "S": "Coffee"
  },
  "price": {
    "N": "3"
  }
}
```

- ✅ Click Create item


#### 2️⃣ Create Second Item (Latte)

Click Create item again:

```
{
  "item": {
    "S": "Latte"
  },
  "price": {
    "N": "5"
  }
}
```

- ✅ Click Create item


#### 3️⃣ Create Third Item (Tea)

Click Create item again:

```
{
  "item": {
    "S": "Tea"
  },
  "price": {
    "N": "2"
  }
}
```

- ✅ Click Create item

---


#### 4️⃣ Create 4th Item (Cappuccino)

```
{
  "item": {
    "S": "Cappuccino"
  },
  "price": {
    "N": "8"
  }
}
```

- ✅ Click Create item

---


#### 5️⃣ Create 5th Item (Fresh Juice)

```
{
  "item": {
    "S": "Fresh Juice"
  },
  "price": {
    "N": "6"
  }
}
```

- ✅ Click Create item

---


### 2️⃣ Method 2 Item editor screen



#### 1️⃣ Create First Item (Coffee)

1. Partition key:

- item → Coffee

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 3

- ✅ Click Create item


#### 2️⃣ Create Second Item (Latte)

1. Partition key:

- item → Latte

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 5

- ✅ Click Create item


#### 3️⃣ Create Third Item (Tea)

1. Partition key:

- item → Latte

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 2

- ✅ Click Create item


#### 4️⃣ Create 4th Item (Cappuccino)

1. Partition key:

- item → Cappuccino

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 8

- ✅ Click Create item


#### 5️⃣ Create 5th Item (Fresh Juice)

1. Partition key:

- item → Fresh Juice

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 6

- ✅ Click Create item

---

### 3️⃣ Verify Items

You should now see 5 items in the table. You should now see:

| item   | price |
| ------ | ----- |
| Coffee | 3     |
| Latte  | 5     |
| Cappuccino    | 8     |
| Fresh Juice    | 6     |

✅ DynamoDB table is ready


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

### 5️⃣ Lambda Code: Read Menu from DynamoDB (Python)

Now we implement the logic.

Use boto3 to fetch menu/prices before processing orders.

[CafeMenuLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeMenuLambda.py)

**✔️ Click Deploy**


## PHASE 1️⃣ — DYNAMODB METRICS TABLE (FULL)


### 1️⃣ Open DynamoDB Console


#### AWS Console → DynamoDB → Tables → Create table


### 2️⃣ CREATE DYNAMODB METRICS TABLE


#### 1️⃣ Table configuration

| Field         | Value              |
| ------------- | ------------------ |
| Table name    | `CafeOrderMetrics` |
| Partition key | `metric` (String)  |
| Sort key      | ❌ None             |
| Table class   | Standard           |
| Capacity      | On-demand          |
| Encryption    | Default            |


#### Sample items:

```
{ "metric": "TOTAL_ORDERS", "count": 120 }
{ "metric": "TODAY_ORDERS", "count": 25 }
```

Click Create table

**🕐 WAIT until status = ACTIVE**


### 3️⃣ Insert initial items (VERY IMPORTANT)

**Click table → Explore table → Create item**


#### Item 1

```
{
  "metric": {
    "S": "TOTAL_ORDERS"
  },
  "count": {
    "N": "0"
  }
}
```

Click Create item


#### Item 2

```
{
  "metric": {
    "S": "TODAY_ORDERS"
  },
  "count": {
    "N": "0"
  }
}
```

Click Create item


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

#### ✅ Your DynamoDB Items Are Now Correct

You now have:

```
{ "metric": "TOTAL_ORDERS", "count": 0 }
{ "metric": "TODAY_ORDERS", "count": 0 }
```

✔ Perfect

✔ No duplicates

✔ Correct partition keys


### 1️⃣ DynamoDB / RDS (Order Table)
> **UPDATE DATABASE (VERY IMPORTANT)**


#### 1️⃣ If you are using DynamoDB


#### 🔹 Step 1.1 — Create the CafeOrders Table

- AWS Console → DynamoDB → Tables → CafeOrders

- Fill EXACTLY like this

| Field         | Value        |
| ------------- | ------------ |
| Table name    | `CafeOrders` |
| Partition key | `order_id`   |
| Type          | `String`     |
| Sort key      | ❌ NONE       |
| Table class   | Standard     |
| Capacity mode | On-demand    |
| Encryption    | Default      |


- Click Create table.

**🕐 Wait 1-2 minutes until status shows Active.**


#### 🔹 Step 1.2 — Confirm Primary Key

- Your table must have:

```
Partition Key: order_id (String)
```

**⚠️ If not, STOP — this lab assumes order_id is the key.**


#### 🔹 Step 1.3 — Add Attributes (NO MIGRATION NEEDED)


#### Basic test item (CASH payment – PENDING)

```
{
  "order_id": { "S": "ORD-TEST-001" },
  "table_number": { "N": "5" },
  "item": { "S": "Coffee" },
  "quantity": { "N": "2" },
  "total_amount": { "N": "6" },

  "payment_method": { "S": "CASH" },
  "payment_status": { "S": "PENDING" },

  "status": { "S": "RECEIVED" },
  "created_at": { "S": "2026-01-14T10:30:00Z" }
}
```


#### Another test item (CARD payment – PAID)

```
{
  "order_id": { "S": "ORD-TEST-002" },
  "table_number": { "N": "5" },
  "item": { "S": "Coffee" },
  "quantity": { "N": "2" },
  "total_amount": { "N": "6" },

  "payment_method": { "S": "CARD" },
  "payment_status": { "S": "PENDING" },

  "status": { "S": "RECEIVED" },
  "created_at": { "S": "2026-01-14T10:30:00Z" }
}
```

#### 🔎 VERIFY STEP 1.3 WORKED

Click the item → you should see:

```
payment_method: CASH
payment_status: PENDING
```

✅ That’s it

✅ Nothing else to configure here

✅ DynamoDB auto-creates attributes

❌ No further DB action needed


#### Run this ONCE:

```
ALTER TABLE orders
ADD payment_method VARCHAR(10),
ADD payment_status VARCHAR(10);
```


#### verify

```
use cafe_db;
```

```
DESCRIBE orders;
```


#### 💻 MODERN CAFE-STYLE orders.php (Frontend Only Modified)

[orders.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---


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


#### 1️⃣ OPEN DYNAMODB CONSOLE

- Login to AWS Console

- Search DynamoDB

- Click DynamoDB

- Click Tables

- Click Create table


#### 3️⃣ VERIFY DYNAMODB OUTPUT

- Open CafeOrders

- Open latest item

- Confirm these fields exist:

```
item_cost
total_cost
```


#### 1️⃣ – Verify DynamoDB Order Item Structure

- Open DynamoDB → Tables → CafeOrders → Explore table

- Confirm EACH ORDER ITEM contains ALL of these attributes:

```
order_id        (String)
order_date      (String)   e.g. "2026-01-17"
order_timestamp (Number)
item_name       (String)
quantity        (Number)
item_price      (Number)   ← selling price
item_cost       (Number)   ← base cost
order_status    (String)   ← COMPLETED
```

❌ If item_cost does NOT exist → STOP

✔ Fix order-processing Lambda FIRST


#### Confirm in DynamoDB that:

```
order_status = "COMPLETED"
```


#### 1️⃣ DynamoDB Table (Attendance)

- Create table:

| Setting       | Value                       |
| ------------- | --------------------------- |
| Table name    | `CafeAttendance`            |
| Partition key | `employee_id` (String)      |
| Sort key      | `date` (String, YYYY-MM-DD) |

📌 This allows:

- One record per day

- Easy query by date

📌 Format you will store:

- Other attributes:

    - check_in

    - check_out

    - role


#### ✅ DynamoDB is schema-less

Attributes are added automatically when Lambda inserts data.

Example item inserted later:

```
{
  "employee_id": { "S": "101" },
  "date": { "S": "2026-02-01" },
  "check_in": { "S": "09:03" },
  "check_out": { "S": "17:11" },
  "role": { "S": "Employee" }
}
```

👉 "S" = String

👉 "N" = Number


#### Your table requires:

employee_id ✅ (Partition key)
date ✅ (Sort key)

If you miss these → insert will fail.


### 4️⃣ DynamoDB Setup


### 1️⃣ Create DynamoDB CafeMenu Table 


#### 🔹 Table Configuration

| Parameter     | Value          |
| ------------- | -------------- |
| Table Name    | `CafeMenu`     |
| Partition Key | `item`         |
| Key Type      | String         |
| Sort Key      | ❌ Not required |


#### 🔹 Capacity Settings

| Setting       | Value     |
| ------------- | --------- |
| Capacity Mode | On-Demand |


#### 💡 Why On-Demand?

| Reason               | Benefit               |
| -------------------- | --------------------- |
| No planning required | Auto scaling          |
| Cost efficient       | Free-tier friendly    |
| Ideal use case       | Learning + small apps |


#### 🔹 Default Settings (Keep As-Is)

| Setting             | Value           |
| ------------------- | --------------- |
| Encryption          | AWS Owned Key   |
| Table Class         | Standard        |
| Deletion Protection | Disabled        |
| Tags                | Optional (skip) |


#### 🔹 Table Status

| Step         | Status         |
| ------------ | -------------- |
| Create Table | Click “Create” |
| Wait Status  | `ACTIVE`       |


### 2️⃣ Create DynamoDB METRICS TABLE


### 1️⃣ Create DynamoDB Table

| Parameter     | Value                 |
| ------------- | --------------------- |
| Table Name    | `CafeOrderMetrics`    |
| Partition Key | `metric`              |
| Key Type      | String                |
| Sort Key      | ❌ None                |
| Table Class   | Standard              |
| Capacity Mode | On-Demand             |
| Encryption    | Default (AWS managed) |


#### 🔹 Table Status

| Step         | Status         |
| ------------ | -------------- |
| Create Table | Click “Create” |
| Wait Status  | `ACTIVE`       |


#### 🔹 Metrics Table Data Structure

| Attribute | Type   | Purpose           |
| --------- | ------ | ----------------- |
| metric    | String | Metric identifier |
| count     | Number | Metric value      |


#### 🔹 Initial Metrics Items

| Metric Name  | Meaning                | Initial Value |
| ------------ | ---------------------- | ------------- |
| TOTAL_ORDERS | Total orders in system | 0             |
| TODAY_ORDERS | Orders for current day | 0             |


### 3️⃣ Create DynamoDB CafeOrders TABLE


### 4️⃣ CREATE GSI

- AWS Console → DynamoDB → CafeOrders

- Click Indexes tab → Create index

- Configure Index

| Setting       | Value            |
| ------------- | ---------------- |
| Partition Key | order_date       |
| Type          | String           |
| Sort Key      | ❌ None           |
| Index Name    | order_date-index |

- Projection Type: ALL | Capacity Mode: On-demand (default) | Action: Click Create Index | Status: ACTIVE (wait 1–2 min)


#### 📦 REQUIRED TABLE STRUCTURE

> #### 🧾 DynamoDB GSI Configuration (CafeOrders)

| Parameter       | Value                        |
| --------------- | ---------------------------- |
| Table Name      | CafeOrders                   |
| Index Name      | order_date-index             |
| Index Type      | Global Secondary Index (GSI) |
| Partition Key   | order_date (String)          |
| Sort Key        | None                         |
| Projection Type | ALL                          |
| Capacity Mode   | On-Demand                    |
| Status          | ACTIVE                       |


#### 📦 REQUIRED TABLE STRUCTURE (IMPORTANT)

> #### 🧾 Orders Table Schema

| Parameter       | Value                        |
| --------------- | ---------------------------- |
| Table Name      | CafeOrders                   |
| Index Name      | order_date-index             |
| Index Type      | Global Secondary Index (GSI) |
| Partition Key   | order_date (String)          |
| Sort Key        | None                         |
| Projection Type | ALL                          |
| Capacity Mode   | On-Demand                    |
| Status          | ACTIVE                       |


### 2️⃣ TEST GSI

- Go to: Explore table items → Change: Scan → Query

- Select index: order_date-index


#### ✔ Query Example:

| Field      | Value      |
| ---------- | ---------- |
| order_date | 2026-01-17 |

> #### - OR range: BETWEEN 2026-01-01 AND 2026-01-31

✔ If items return → GSI works

❌ If empty → fix dates or index


### 5️⃣ Create DynamoDB CafeAttendance TABLE


#### 🔹 Example Item (DynamoDB JSON Format)

```
{
  "employee_id": { "S": "101" },
  "date": { "S": "2026-02-01" },
  "check_in": { "S": "09:03" },
  "check_out": { "S": "17:11" },
  "role": { "S": "Employee" }
}
```


