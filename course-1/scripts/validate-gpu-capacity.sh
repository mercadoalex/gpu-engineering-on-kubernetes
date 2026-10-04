#!/usr/bin/env bash
set -euo pipefail
GPU_TOTAL=$(kubectl get nodes -o json | jq '[.items[].status.allocatable["nvidia.com/gpu"] // "0" | tonumber] | add' 2>/dev/null || echo 0)
[ "${GPU_TOTAL:-0}" -ge 1 ] || { echo "ERROR: No nvidia.com/gpu capacity found"; echo "Run: kubectl get nodes -o json | jq '.items[] | .status.allocatable'"; exit 1; }
echo "OK: Total GPU capacity across cluster: $GPU_TOTAL ✓"
