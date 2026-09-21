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

GATE_CONFIGS=(
  devops/nota-de-triagem/promptfooconfig.yaml
  devops/triagem-de-pods/promptfooconfig.yaml
  devops/networkpolicy-sentinel/promptfooconfig.yaml
  devops/causa-raiz-cerebro/promptfooconfig.yaml
)

for config in "${GATE_CONFIGS[@]}"; do
  promptfoo eval -c "$config"
done
