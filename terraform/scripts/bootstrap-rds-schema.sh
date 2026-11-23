#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REGION="${AWS_REGION:-us-east-1}"
SECRET_ID="${DB_SECRET_NAME:-}"
if [[ -z "$SECRET_ID" ]]; then
  echo "Set DB_SECRET_NAME to the Phase 2 Secrets Manager secret name/ARN." >&2
  exit 2
fi
if [[ -d "$ROOT/application/infrastructure/rds" ]]; then SQL_DIR="$ROOT/application/infrastructure/rds"; else SQL_DIR="$ROOT/infrastructure/rds"; fi
SECRET_JSON="$(aws secretsmanager get-secret-value --region "$REGION" --secret-id "$SECRET_ID" --query SecretString --output text)"
DB_HOST="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["host"])' <<<"$SECRET_JSON")"
DB_USER="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["username"])' <<<"$SECRET_JSON")"
DB_PASS="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["password"])' <<<"$SECRET_JSON")"
export MYSQL_PWD="$DB_PASS"
mysql --host="$DB_HOST" --user="$DB_USER" --connect-timeout=15 < "$SQL_DIR/schema.sql"
if [[ -f "$SQL_DIR/data.sql" ]]; then mysql --host="$DB_HOST" --user="$DB_USER" --connect-timeout=15 < "$SQL_DIR/data.sql"; fi
if [[ -f "$SQL_DIR/verify.sql" ]]; then mysql --host="$DB_HOST" --user="$DB_USER" --connect-timeout=15 < "$SQL_DIR/verify.sql"; fi
unset MYSQL_PWD
printf 'Phase 2 RDS schema/data initialization completed for %s\n' "$DB_HOST"
