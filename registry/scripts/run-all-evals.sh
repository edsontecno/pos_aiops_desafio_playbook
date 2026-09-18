#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY_DIR="$(dirname "$SCRIPT_DIR")"

cd "$REGISTRY_DIR"

promptfoo eval -c devops/nota-de-triagem/promptfooconfig.yaml
promptfoo eval -c devops/triagem-de-pods/promptfooconfig.yaml
promptfoo eval -c devops/networkpolicy-sentinel/promptfooconfig.yaml
