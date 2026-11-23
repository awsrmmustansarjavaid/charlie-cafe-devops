#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$ROOT/application"
[[ -d "$SRC/app" ]] || { echo "Missing application/app source snapshot" >&2; exit 2; }
mkdir -p "$ROOT/app" "$ROOT/infrastructure" "$ROOT/docker"
cp -a "$SRC/app/." "$ROOT/app/"
for folder in scripts rds lambda-layer iam-policies; do
  if [[ -d "$SRC/infrastructure/$folder" ]]; then
    mkdir -p "$ROOT/infrastructure/$folder"
    cp -a "$SRC/infrastructure/$folder/." "$ROOT/infrastructure/$folder/"
  fi
done
if [[ -d "$SRC/docker" ]]; then cp -a "$SRC/docker/." "$ROOT/docker/"; fi
for file in appspec.yaml docker-compose.yml .dockerignore; do
  [[ -f "$SRC/$file" ]] && cp -a "$SRC/$file" "$ROOT/$file"
done
[[ -f "$SRC/README.md" ]] && cp -a "$SRC/README.md" "$ROOT/APP-README.md"
echo "Copied the included app snapshot into the repository's standard app/, infrastructure/, and docker/ layout. Review git diff before committing."
