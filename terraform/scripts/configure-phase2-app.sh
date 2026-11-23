#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TFDIR="$ROOT/terraform/environments/dev"
OUT="$ROOT/application/app/frontend/js/config.js"
terraform -chdir="$TFDIR" output -json > "$TFDIR/phase2-outputs.json"
python3 - "$TFDIR/phase2-outputs.json" "$OUT" "$ROOT/app/frontend/js/config.js" "$ROOT/.github/task-definition.json" <<'PYCODE'
import json,sys
values=json.load(open(sys.argv[1]))
def val(k): return values[k]["value"]
config={"REGION":"us-east-1","rdsSecretName":val("db_secret_name"),"USER_POOL_ID":val("cognito_user_pool_id"),"CLIENT_ID":val("cognito_client_id"),"COGNITO_DOMAIN":val("cognito_domain"),"API_BASE":val("api_invoke_url"),"CLOUDFRONT_BASE":val("cloudfront_url")}
for config_path in [sys.argv[2],sys.argv[3]]:
 import os
 if config_path == sys.argv[3] and not os.path.isdir(os.path.dirname(config_path)):
  continue
 os.makedirs(os.path.dirname(config_path),exist_ok=True)
 with open(config_path,"w") as f:
  f.write("// Generated from Terraform Phase 2 outputs. Do not edit by hand.\nwindow.CHARLIE_CONFIG = "+json.dumps(config,indent=4)+";\n")
task={
 "family":val("ecs_task_family"),
 "networkMode":"awsvpc",
 "requiresCompatibilities":["FARGATE"],
 "cpu":"512","memory":"1024",
 "executionRoleArn":val("ecs_execution_role_arn"),
 "taskRoleArn":val("ecs_task_role_arn"),
 "containerDefinitions":[{
  "name":"charlie-container","image":val("ecr_repository_url")+":bootstrap","essential":True,
  "portMappings":[{"containerPort":80,"hostPort":80,"protocol":"tcp"}],
  "environment":[{"name":"DB_NAME","value":val("db_name")}],
  "secrets":[
   {"name":"DB_HOST","valueFrom":val("rds_secret_arn")+":host::"},
   {"name":"DB_USER","valueFrom":val("rds_secret_arn")+":username::"},
   {"name":"DB_PASS","valueFrom":val("rds_secret_arn")+":password::"}
  ],
  "logConfiguration":{"logDriver":"awslogs","options":{"awslogs-group":val("ecs_log_group_name"),"awslogs-region":"us-east-1","awslogs-stream-prefix":"ecs"}}
 }]
}
with open(sys.argv[4],"w") as f: json.dump(task,f,indent=2); f.write("\n")
print("Updated frontend config and ECS task definition from Terraform outputs.")
PYCODE
