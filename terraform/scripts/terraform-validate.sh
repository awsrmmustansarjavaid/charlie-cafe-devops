#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../environments/dev" && pwd)"
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/package-lambda-layer.sh"
terraform -chdir="$ROOT" init -backend=false
terraform -chdir="$ROOT" validate
