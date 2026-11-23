#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TFDIR="$ROOT/terraform/environments/dev"
REGION="$(terraform -chdir="$TFDIR" output -raw aws_region)"
INSTANCE_ID="$(terraform -chdir="$TFDIR" output -raw ec2_instance_id)"
SECRET_NAME="$(terraform -chdir="$TFDIR" output -raw db_secret_name)"
REMOTE_COMMAND="sudo DB_SECRET_NAME=$SECRET_NAME AWS_REGION=$REGION bash /opt/charlie-cafe/terraform/scripts/bootstrap-rds-schema.sh"
PARAMS="$(python3 -c 'import json,sys; print(json.dumps({"commands":[sys.argv[1]]}))' "$REMOTE_COMMAND")"
COMMAND_ID="$(aws ssm send-command --region "$REGION" --instance-ids "$INSTANCE_ID" --document-name AWS-RunShellScript --parameters "$PARAMS" --comment "Initialize new Charlie Cafe Phase 2 RDS schema" --query 'Command.CommandId' --output text)"
aws ssm wait command-executed --region "$REGION" --command-id "$COMMAND_ID" --instance-id "$INSTANCE_ID"
aws ssm get-command-invocation --region "$REGION" --command-id "$COMMAND_ID" --instance-id "$INSTANCE_ID" --query '{Status:Status,Stdout:StandardOutputContent,Stderr:StandardErrorContent}' --output json
