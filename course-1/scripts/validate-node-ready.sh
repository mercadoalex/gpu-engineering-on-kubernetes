#!/usr/bin/env bash
set -euo pipefail
# grep -c exits 1 when count is 0, which kills the subshell under set -euo pipefail.
# Use grep | wc -l instead — wc -l always exits 0.
READY=$(kubectl get nodes --no-headers 2>/dev/null | grep ' Ready ' | wc -l | tr -d ' ')
[ "${READY:-0}" -ge 2 ] || { echo "ERROR: Expected >= 2 Ready KWOK nodes, got ${READY:-0}"; echo "Run: kubectl get nodes"; exit 1; }
echo "OK: $READY nodes are Ready ✓"
