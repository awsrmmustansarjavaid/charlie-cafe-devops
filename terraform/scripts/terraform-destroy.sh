#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../environments/dev" && pwd)"
if [[ "${CONFIRM_PHASE2_DESTROY:-}" != "DESTROY-CHARLIE-CAFE-PHASE2" ]]; then echo "Refusing destroy. This does not protect Phase 1 if state is misconfigured. Set CONFIRM_PHASE2_DESTROY=DESTROY-CHARLIE-CAFE-PHASE2 only after independently verifying workspace and state." >&2; exit 2; fi
terraform -chdir="$ROOT" destroy
