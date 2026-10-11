#!/usr/bin/env bash
# install-ghostgpu.sh — Injects nvidia.com/gpu capacity onto the KWOK virtual
# nodes by PATCHING their node status directly.
#
# WHY NOT the fake-gpu-operator / a real device plugin?
# A real device plugin runs as a pod ON the node and registers GPUs with the
# kubelet over a gRPC socket. KWOK nodes have NO kubelet and KWOK only SIMULATES
# pods (they show Running but their containers never actually execute). So an
# operator's pods are a façade — their code never runs, and no GPU capacity ever
# gets patched. On KWOK the correct, reliable way to advertise an extended
# resource is to write it straight into the node's status.allocatable /
# status.capacity via the API — which is exactly what a real device plugin makes
# the kubelet do under the hood. We do that here with `kubectl patch`.
#
# Usage: bash course-1/scripts/install-ghostgpu.sh
set -euo pipefail

GPU_COUNT="${GPU_COUNT:-4}"
NODE_POOL_LABEL="nvidia.com/gpu.present=true"

# ── Dependency checks ──────────────────────────────────────────────────────────
check_dep() {
  command -v "$1" &>/dev/null || { echo "ERROR: $1 is required but not found."; exit 1; }
}
check_dep kubectl
check_dep jq
echo "✓ Dependencies OK"

# ── Find the GPU nodes ─────────────────────────────────────────────────────────
# Target every node labeled as a GPU node (set by setup-kwok-cluster.sh).
mapfile -t GPU_NODES < <(kubectl get nodes -l "${NODE_POOL_LABEL}" \
  --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null)

if [ "${#GPU_NODES[@]}" -eq 0 ]; then
  echo "ERROR: no nodes labeled '${NODE_POOL_LABEL}' found."
  echo "Run setup-kwok-cluster.sh first."
  exit 1
fi
echo "✓ Found ${#GPU_NODES[@]} GPU node(s): ${GPU_NODES[*]}"

# ── Inject GPU capacity by patching node status ────────────────────────────────
# Patch BOTH capacity and allocatable. The status subresource is required —
# nvidia.com/gpu lives under .status, not .spec.
echo "→ Injecting nvidia.com/gpu=${GPU_COUNT} onto each node..."
for NODE in "${GPU_NODES[@]}"; do
  kubectl patch node "${NODE}" --subresource=status --type=merge -p "{
    \"status\": {
      \"capacity\":    {\"nvidia.com/gpu\": \"${GPU_COUNT}\"},
      \"allocatable\": {\"nvidia.com/gpu\": \"${GPU_COUNT}\"}
    }
  }" >/dev/null
  echo "   ✓ ${NODE} now advertises nvidia.com/gpu=${GPU_COUNT}"
done

# ── Verify ─────────────────────────────────────────────────────────────────────
echo "→ Verifying GPU capacity..."
GPU_TOTAL=$(kubectl get nodes -o json \
  | jq '[.items[].status.allocatable["nvidia.com/gpu"] // "0" | tonumber] | add')

if [ "${GPU_TOTAL:-0}" -lt 1 ]; then
  echo "ERROR: GPU capacity was not applied. Check: kubectl get nodes -o json | jq '.items[].status.allocatable'"
  exit 1
fi
echo "✓ Total GPU capacity across cluster: ${GPU_TOTAL}"

# ── GPU inventory ──────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════"
echo "  GPU Inventory"
echo "════════════════════════════════════════════════════════"
kubectl get nodes -o custom-columns=\
'NAME:.metadata.name,CPU:.status.allocatable.cpu,MEM:.status.allocatable.memory,GPU:.status.allocatable.nvidia\.com/gpu'
echo ""
echo "Next step: schedule your first GPU pod"
echo "  kubectl apply -f course-1/manifests/gpu-test-pod.yaml"
echo "  kubectl get pod gpu-test -w"
echo ""
