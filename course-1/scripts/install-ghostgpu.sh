#!/usr/bin/env bash
# install-ghostgpu.sh — Installs fake-gpu-operator (run-ai/fake-gpu-operator) via Helm
# to simulate nvidia.com/gpu resources on KWOK virtual nodes.
#
# Chart source: https://github.com/run-ai/fake-gpu-operator
# OCI registry: oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator
#
# Usage: bash course-1/scripts/install-ghostgpu.sh
set -euo pipefail

RELEASE_NAME="ghostgpu"
NAMESPACE="gpu-operator"
GPU_COUNT=4
# GPU memory in MiB — 24576 MiB = 24 GB (matches NVIDIA L4)
GPU_MEMORY_MIB=24576

# ── Dependency checks ──────────────────────────────────────────────────────────
check_dep() {
  command -v "$1" &>/dev/null || { echo "ERROR: $1 is required but not found."; exit 1; }
}
check_dep kubectl
check_dep helm
check_dep jq

echo "✓ Dependencies OK"

# ── Verify KWOK nodes exist ────────────────────────────────────────────────────
READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready ' || echo 0)
if [ "$READY_NODES" -lt 2 ]; then
  echo "ERROR: Expected >= 2 Ready nodes. Found: $READY_NODES"
  echo "Run setup-kwok-cluster.sh first."
  exit 1
fi
echo "✓ $READY_NODES Ready nodes found"

# ── Create namespace ───────────────────────────────────────────────────────────
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
echo "✓ Namespace '${NAMESPACE}' ready"

# ── Install or upgrade fake-gpu-operator ──────────────────────────────────────
# fake-gpu-operator is distributed as an OCI Helm chart.
# It patches KWOK virtual node status.allocatable with nvidia.com/gpu resources
# so the Kubernetes scheduler can assign GPU-requesting pods.
echo "→ Installing fake-gpu-operator (ghostgpu)..."
helm upgrade --install "${RELEASE_NAME}" \
  oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
  --namespace "${NAMESPACE}" \
  --set "topology.nodePools.default.gpuCount=${GPU_COUNT}" \
  --set "topology.nodePools.default.gpuMemory=${GPU_MEMORY_MIB}" \
  --wait --timeout 120s

echo "✓ fake-gpu-operator installed"

# ── Wait for DaemonSet rollout ─────────────────────────────────────────────────
echo "→ Waiting for DaemonSet to roll out on all nodes..."
# ⏱️ This can take 30–60 seconds for all nodes to be patched
sleep 15
kubectl rollout status daemonset -n "${NAMESPACE}" --timeout=120s || true

# ── Verify GPU capacity ────────────────────────────────────────────────────────
echo "→ Verifying GPU capacity on nodes..."
sleep 10  # give the DaemonSet time to patch node status

GPU_TOTAL=$(kubectl get nodes -o json \
  | jq '[.items[].status.allocatable["nvidia.com/gpu"] // "0" | tonumber] | add' \
  2>/dev/null || echo 0)

if [ "${GPU_TOTAL:-0}" -lt 1 ]; then
  echo "⚠️  WARNING: nvidia.com/gpu capacity not yet visible on nodes."
  echo "   Wait 30 seconds and check: kubectl get nodes -o json | jq '.items[] | .status.allocatable'"
else
  echo "✓ Total GPU capacity across cluster: ${GPU_TOTAL}"
fi

# ── GPU inventory ──────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════"
echo "  GPU Inventory"
echo "════════════════════════════════════════════════════════"
kubectl get nodes -o custom-columns=\
'NAME:.metadata.name,CPU:.status.allocatable.cpu,MEM:.status.allocatable.memory,GPU:.status.allocatable.nvidia\.com/gpu'
echo ""
echo "Next step: verify and schedule your first GPU pod"
echo "  kubectl apply -f course-1/manifests/gpu-test-pod.yaml"
echo "  kubectl get pod gpu-test -w"
echo ""
