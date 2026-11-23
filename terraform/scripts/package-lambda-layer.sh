#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REQ="$ROOT/application/infrastructure/lambda-layer/requirements.txt"
DEST="$ROOT/terraform/modules/lambda/layer-build/python"
rm -rf "$DEST"/*
python3 -m pip install --upgrade -r "$REQ" -t "$DEST"
