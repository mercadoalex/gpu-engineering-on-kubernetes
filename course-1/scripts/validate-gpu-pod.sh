#!/usr/bin/env bash
set -euo pipefail
PHASE=$(kubectl get pod gpu-test -n default -o jsonpath='{.status.phase}' 2>/dev/null || echo '')
[ "$PHASE" = "Running" ] || { echo "ERROR: gpu-test pod is not Running (phase: ${PHASE:-not found})"; echo "Run: kubectl describe pod gpu-test"; exit 1; }
echo "OK: gpu-test pod is Running ✓"
