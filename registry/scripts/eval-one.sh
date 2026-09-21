#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <path-to-promptfooconfig.yaml>" >&2
  exit 1
fi

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

npx promptfoo eval -c "$1"
