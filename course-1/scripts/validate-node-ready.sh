#!/usr/bin/env bash
set -euo pipefail
READY=$(kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready ' || echo 0)
[ "$READY" -ge 2 ] || { echo "ERROR: Expected >= 2 Ready KWOK nodes, got $READY"; echo "Run: kubectl get nodes"; exit 1; }
echo "OK: $READY nodes are Ready ✓"
