# Charlie Cafe — Amazon S3 Configuration Guide

Service-specific configuration, setup steps, code, permissions, integrations, and verification material identified in the master README for Amazon S3.

> Source: `AWS Charlie Cafe Project README.md`. Content is reorganized by AWS service; original wording and configuration values are retained where possible. Cross-service sections may appear in more than one guide.

---

## PHASE 1️⃣ — S3 Bucket


### 1️⃣ Create S3 Bucket

- AWS Console → Search S3

- Click Create bucket


#### Bucket Configuration :


| Setting             | Value                            |
| ------------------- | -------------------------------- |
| Bucket name         | `charlie-cafe-s3-bucket` |
| Region              | `us-east-1` (same as Lambda)     |
| Object ownership    | ACLs disabled                    |
| Block public access | ✅ Enabled (KEEP ON)             |


Click **Create bucket**


#### ✅ Bucket created


#### 📣 Disable “Block Public Access”

✔️ Uncheck all

✔️ Acknowledge


### 2️⃣ Upload Images to S3 


#### 1️⃣ Upload Images

Example:

```
hero.jpg
espresso.jpg
latte.jpg
```


#### 2️⃣ Make Images Public

- Select image

- Actions → Make public


### 3️⃣ Link S3 Images to index.php


#### Copy S3 Object URL:

```
https://charlie-cafe-assets.s3.amazonaws.com/hero.jpg
```


#### Replace in index.php:

```
<section class="hero" style="background-image:url('https://charlie-cafe-assets.s3.amazonaws.com/hero.jpg')">
```

✅ No backend impact

✅ No API involved

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

#  - Publish via AWS CLI (NO S3)

# -------- CONFIGURATION --------
AWS_DEFAULT_REGION="us-east-1"

S3_BUCKET="charlie-cafe-s3-bucket"
S3_KEY="layers/pymysql-layer.zip"


# -------- STEP 6: Upload to S3 --------
echo "☁️ Uploading to S3..."
aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$S3_KEY" --region "$AWS_DEFAULT_REGION"

echo "✅ DONE!"
echo "Attach this layer to Lambda (Python 3.9 / 3.10 / 3.11)"
```

```
sudo chmod +x upload-pymysql-layer.sh
```

```
sudo ./upload-pymysql-layer.sh
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**


## 📢 SECTION 3️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---

## 📢 SECTION 4️⃣ CAFE FrontEnd Development & Deployment


## ☕ AWS CAFE - PHASE 1️⃣ FRONTEND central FOUNDATION (REUSABLE)


### 1️⃣ Download & Upload Html Directory 


### ⚠️ Read ablout all "FrontEnd Configuration"

[Cafe_FrontEnd_Config](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cafe_FrontEnd_Config/Cafe_FrontEnd_Config.md)


### 2️⃣ Charlie Cafe Export S3 to HTML Script


### ➡️ Create Folder on S3 

- Create Folder

- **Name: Charlie Cafe Code Drive**

```
sudo nano charlie-cafe-export-s3-to-html.sh
```

[Charlie Cafe Export S3 to HTML Script](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/charlie-cafe-export-s3-to-html/charlie-cafe-export-s3-to-html.sh)

```
#!/bin/bash

# S3 TO EC2 EXPORT + PERMISSIONS SCRIPT

# =========================================================
AWS_REGION="us-east-1"
S3_BUCKET="charlie-cafe-s3-bucket"


# 📂 S3 FOLDERS

# 🚀 STEP 1 — EXPORT FILES FROM S3

# =========================================================
echo "======================================================="
echo "🚀 Starting Charlie Cafe S3 Export..."
echo "Bucket: $S3_BUCKET"
echo "Region: $AWS_REGION"
echo "======================================================="

echo "📥 Syncing HTML folder from S3 to EC2..."
aws s3 sync "s3://$S3_BUCKET/$S3_HTML_FOLDER" "$EC2_HTML_FOLDER" \
--region $AWS_REGION --delete

echo "📥 Syncing Bash scripts from S3 to EC2..."
aws s3 sync "s3://$S3_BUCKET/$S3_BASH_FOLDER" "$EC2_BASH_FOLDER" \
--region $AWS_REGION --delete

echo "📥 Downloading httpd.conf from S3..."
sudo aws s3 cp "s3://$S3_BUCKET/$S3_HTTPD_FILE" "$EC2_HTTPD_FILE" --region $AWS_REGION
if [ $? -eq 0 ]; then
    echo "✅ httpd.conf successfully copied to $EC2_HTTPD_FILE"
else
    echo "⚠️ Failed to copy httpd.conf from S3!"
fi

echo "======================================================="
echo "✅ S3 Export Completed!"
echo "HTML folder → $EC2_HTML_FOLDER"
echo "Bash folder → $EC2_BASH_FOLDER"
echo "HTTPD config → $EC2_HTTPD_FILE"
echo "======================================================="


# Additional verification for HTTPD
if [ -f "$EC2_HTTPD_FILE" ]; then
    echo "✅ httpd.conf exists at $EC2_HTTPD_FILE"
else
    echo "⚠️ httpd.conf missing at $EC2_HTTPD_FILE"
fi

echo "---------------------------------------------"
echo "✅ Charlie Cafe Deployment Completed!"
echo "S3 files synced + permissions applied + httpd.conf verified."
echo "---------------------------------------------"
```

```
sudo chmod +x charlie-cafe-export-s3-to-html.sh
```

```
sudo ./charlie-cafe-export-s3-to-html.sh
```


