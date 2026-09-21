#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY_DIR="$(dirname "$SCRIPT_DIR")"

cd "$REGISTRY_DIR"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/ensure-node.sh"
ensure_node

if [ ! -d node_modules/promptfoo ]; then
  echo "Installing dependencies..." >&2
  npm install
fi

SMOKE_CONFIGS=(
  devops/backpressure-relay/promptfooconfig.yaml
  devops/migracao-forge-diagnostico/promptfooconfig.yaml
  devops/migracao-forge-plano/promptfooconfig.yaml
  devops/migracao-forge-fase-1/promptfooconfig.yaml
  devops/networkpolicy-sentinel-verificacao/promptfooconfig.yaml
)

for config in "${SMOKE_CONFIGS[@]}"; do
  promptfoo eval -c "$config"
done
