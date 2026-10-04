#!/usr/bin/env bash
set -euo pipefail
HELM_STATUS=$(helm list -n kube-system --filter ghostgpu -o json 2>/dev/null | jq -r '.[0].status // empty')
[ "$HELM_STATUS" = "deployed" ] || { echo "ERROR: ghostgpu Helm release not found (status: ${HELM_STATUS:-not found})"; echo "Run: helm list -n kube-system"; exit 1; }
echo "OK: ghostgpu Helm release is deployed ✓"
