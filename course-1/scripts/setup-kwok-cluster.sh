#!/usr/bin/env bash
# setup-kwok-cluster.sh — Brings up a kwokctl *binary-runtime* cluster (etcd +
# kube-apiserver + kwok as plain Linux binaries — no Docker, no kind) with 3
# virtual GPU worker nodes for the GPU Engineering on Kubernetes course.
#
# The cluster binaries are pre-cached in the lab image at build time (see
# rootfs/Dockerfile), so this script runs fully OFFLINE and completes in <30s.
#
# Usage: bash course-1/scripts/setup-kwok-cluster.sh
set -euo pipefail

CLUSTER_NAME="kwok"
KUBE_VERSION="v1.31.3"

# ── Dependency checks ──────────────────────────────────────────────────────────
# kwokctl ships the binary runtime (etcd + kube + kwok), so no kind/docker needed.
# helm is used only by the separate ghostgpu script, not here.
check_dep() {
  command -v "$1" &>/dev/null || { echo "ERROR: $1 is required but not found. Install it and retry."; exit 1; }
}
check_dep kwokctl
check_dep kubectl
check_dep jq

echo "✓ Dependencies OK"

# ── Create the kwokctl binary-runtime cluster ──────────────────────────────────
# Idempotent: skip create if the cluster already exists.
if kwokctl get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  echo "ℹ️  kwok cluster '${CLUSTER_NAME}' already exists — skipping create"
else
  echo "→ Creating kwok binary-runtime cluster '${CLUSTER_NAME}' (kube ${KUBE_VERSION})..."
  kwokctl create cluster \
    --name "${CLUSTER_NAME}" \
    --runtime=binary \
    --kube-version="${KUBE_VERSION}"
  echo "✓ kwok cluster created"
fi

# ── Select the kubectl context ─────────────────────────────────────────────────
# kwokctl's binary runtime writes a kubeconfig context named kwok-<name>.
# Detect it rather than hardcoding so it survives a cluster-name change.
CTX="kwok-${CLUSTER_NAME}"
if ! kubectl config get-contexts -o name 2>/dev/null | grep -q "^${CTX}$"; then
  echo "ERROR: expected kubeconfig context '${CTX}' not found."
  echo "       Available contexts:"; kubectl config get-contexts -o name || true
  exit 1
fi
kubectl config use-context "${CTX}"
echo "✓ Using context '${CTX}'"

# ── Create virtual GPU worker nodes ───────────────────────────────────────────
# These are KWOK-managed nodes — no real VMs. The kwok controller (bundled in the
# binary runtime) owns the heartbeat and the Ready condition for any node carrying
# the kwok.x-k8s.io/node: fake annotation, so we DON'T hardcode status.conditions
# or lastHeartbeatTime (a stale timestamp fails the Ready freshness check).
# NOTE: we deliberately do NOT add nvidia.com/gpu capacity here — ghostgpu injects
# it in a later lesson (verify_no_gpu_before asserts its absence first).
echo "→ Creating KWOK virtual GPU nodes..."
for i in 1 2 3; do
  NODE_NAME="gpu-worker-${i}"
  if kubectl get node "${NODE_NAME}" &>/dev/null; then
    echo "   ℹ️  Node ${NODE_NAME} already exists — skipping"
    continue
  fi
  kubectl apply -f - <<EOF
apiVersion: v1
kind: Node
metadata:
  name: ${NODE_NAME}
  annotations:
    kwok.x-k8s.io/node: fake
  labels:
    node-role.kubernetes.io/worker: ""
    nvidia.com/gpu.present: "true"
    beta.kubernetes.io/os: linux
    kubernetes.io/os: linux
    kubernetes.io/arch: amd64
spec:
  taints: []
status:
  allocatable:
    cpu: "32"
    memory: 128Gi
    pods: "110"
    ephemeral-storage: 200Gi
  capacity:
    cpu: "32"
    memory: 128Gi
    pods: "110"
    ephemeral-storage: 200Gi
  nodeInfo:
    architecture: amd64
    containerRuntimeVersion: containerd://1.7.0
    kernelVersion: 5.15.0-fake
    kubeProxyVersion: v1.31.3
    kubeletVersion: v1.31.3
    operatingSystem: linux
    osImage: Ubuntu 22.04 LTS (simulated)
EOF
  echo "   ✓ ${NODE_NAME} created"
done

# ── Wait for nodes to report Ready ──────────────────────────────────────────────
echo "→ Waiting for virtual nodes to be Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=60s
echo "✓ All 3 virtual nodes are Ready"

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════"
echo "  GPU Lab cluster is ready!"
echo "════════════════════════════════════════════════════════"
echo ""
kubectl get nodes
echo ""
echo "Next step: install the GPU simulator"
echo "  bash course-1/scripts/install-ghostgpu.sh"
echo ""
