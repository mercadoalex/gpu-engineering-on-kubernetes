#!/usr/bin/env bash
set -euo pipefail
GPU_COUNT=$(kubectl get nodes -o json | jq '[.items[].status.allocatable | to_entries[] | select(.key == "nvidia.com/gpu")] | length' 2>/dev/null || echo 0)
[ "$GPU_COUNT" -eq 0 ] || { echo "ERROR: nvidia.com/gpu already present on $GPU_COUNT nodes — ghostgpu may already be installed"; exit 1; }
echo "OK: No nvidia.com/gpu resources found — cluster is GPU-naive ✓"
