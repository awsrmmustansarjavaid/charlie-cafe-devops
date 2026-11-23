#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../environments/dev" && pwd)"
if [[ "${CONFIRM_PHASE2_APPLY:-}" != "YES-I-REVIEWED-THE-PHASE2-PLAN" ]]; then echo "Refusing apply. Set CONFIRM_PHASE2_APPLY=YES-I-REVIEWED-THE-PHASE2-PLAN after reviewing the plan." >&2; exit 2; fi
terraform -chdir="$ROOT" apply phase2.tfplan
