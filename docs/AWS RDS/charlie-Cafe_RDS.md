# Charlie Cafe - RDS


### verify_rds.sh


```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — RDS Verification Script (Auto-create DB)
# ==========================================================

set -e

REPO_DIR="$HOME/charlie-cafe-devops"
SQL_FILE="$REPO_DIR/infrastructure/rds/verify.sql"
SECRET_NAME="CafeDevDBSM"

if [[ ! -f "$SQL_FILE" ]]; then
    echo "❌ SQL file not found: $SQL_FILE"
    exit 1
fi

echo "🔑 Fetching RDS credentials from Secrets Manager..."
CREDS_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text)

DB_HOST=$(echo "$CREDS_JSON" | jq -r '.host')
DB_PORT=$(echo "$CREDS_JSON" | jq -r '.port // 3306')
DB_USER=$(echo "$CREDS_JSON" | jq -r '.username')
DB_PASS=$(echo "$CREDS_JSON" | jq -r '.password')
DB_NAME=$(echo "$CREDS_JSON" | jq -r '.dbname')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "❌ Failed to fetch RDS credentials"
    exit 1
fi

echo "✅ RDS credentials fetched successfully."

# 1️⃣ Connect without database to check/create DB
echo "🔨 Ensuring database '$DB_NAME' exists..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"

# 2️⃣ Run verify.sql
echo "📜 Running verify.sql against RDS..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SQL_FILE"

echo "✅ RDS verification completed successfully!"
```

#### 🔹 How to use

```
# 1. Save the file
nano verify_rds.sh

# 2. Make it executable
chmod +x verify_rds.sh

# 3. Run it
./verify_rds.sh
```

---

