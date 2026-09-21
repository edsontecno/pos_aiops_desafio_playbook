#!/usr/bin/env bash

REQUIRED_NODE="22.22.0"

node_meets_requirement() {
  node -e "
    const req = '${REQUIRED_NODE}'.split('.').map(Number);
    const cur = process.versions.node.split('.').map(Number);
    const ok = cur[0] > req[0] ||
      (cur[0] === req[0] && cur[1] > req[1]) ||
      (cur[0] === req[0] && cur[1] === req[1] && cur[2] >= req[2]);
    process.exit(ok ? 0 : 1);
  "
}

ensure_node() {
  if node_meets_requirement; then
    return 0
  fi

  if [ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]; then
    # shellcheck source=/dev/null
    source "${NVM_DIR:-$HOME/.nvm}/nvm.sh"

    if [ -f ".nvmrc" ]; then
      nvm use --silent 2>/dev/null || nvm install
    fi
    if node_meets_requirement; then
      return 0
    fi

    for candidate in 24 22; do
      if nvm use "$candidate" --silent 2>/dev/null && node_meets_requirement; then
        return 0
      fi
    done
  fi

  echo "promptfoo requires Node.js >= ${REQUIRED_NODE} (detected: $(node -v))." >&2
  echo "Run from registry/: nvm install && nvm use" >&2
  exit 1
}
