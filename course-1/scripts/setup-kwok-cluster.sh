#!/usr/bin/env bash
# setup-kwok-cluster.sh — Creates a kind cluster and installs the KWOK controller
# with 3 virtual GPU worker nodes for the GPU Engineering on Kubernetes course.
#
# Usage: bash course-1/scripts/setup-kwok-cluster.sh
set -euo pipefail

CLUSTER_NAME="gpu-lab"
KWOK_REPO="kubernetes-sigs/kwok"

# ── Dependency checks ──────────────────────────────────────────────────────────
check_dep() {
  command -v "$1" &>/dev/null || { echo "ERROR: $1 is required but not found. Install it and retry."; exit 1; }
}
check_dep kind
check_dep kubectl
check_dep helm
check_dep jq

echo "✓ Dependencies OK"

# ── Create kind cluster ────────────────────────────────────────────────────────
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  echo "ℹ️  kind cluster '${CLUSTER_NAME}' already exists — skipping create"
else
  echo "→ Creating kind cluster '${CLUSTER_NAME}'..."
  kind create cluster --name "${CLUSTER_NAME}" --wait 60s
  echo "✓ kind cluster created"
fi

# Set kubectl context
kubectl config use-context "kind-${CLUSTER_NAME}"

# ── Install KWOK controller ────────────────────────────────────────────────────
# KWOK turns the kind cluster into a hybrid: the kind control-plane handles
# the API server, and KWOK simulates virtual worker nodes.
echo "→ Installing KWOK controller..."
KWOK_LATEST=$(curl -s "https://api.github.com/repos/${KWOK_REPO}/releases/latest" | jq -r '.tag_name')
echo "   KWOK version: ${KWOK_LATEST}"

# Install KWOK CRDs and controller
kubectl apply -f "https://github.com/${KWOK_REPO}/releases/download/${KWOK_LATEST}/kwok.yaml"

# Install fast simulation stages (pod/node lifecycle simulation)
kubectl apply -f "https://github.com/${KWOK_REPO}/releases/download/${KWOK_LATEST}/stage-fast.yaml"

# Wait for the KWOK controller to be ready
kubectl rollout status deployment/kwok-controller -n kube-system --timeout=120s
echo "✓ KWOK controller ready"

# ── Create virtual GPU worker nodes ───────────────────────────────────────────
# These are KWOK-managed nodes — no real VMs are created. They appear in
# kubectl get nodes as Ready but all pod execution is simulated by KWOK.
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
  conditions:
  - lastHeartbeatTime: "2026-10-04T00:00:00Z"
    lastTransitionTime: "2026-10-04T00:00:00Z"
    message: kubelet is posting ready status
    reason: KubeletReady
    status: "True"
    type: Ready
  nodeInfo:
    architecture: amd64
    containerRuntimeVersion: containerd://1.7.0
    kernelVersion: 5.15.0-fake
    kubeProxyVersion: v1.29.0
    kubeletVersion: v1.29.0
    operatingSystem: linux
    osImage: Ubuntu 22.04 LTS (simulated)
EOF
  echo "   ✓ ${NODE_NAME} created"
done

# Wait for nodes to report Ready
echo "→ Waiting for virtual nodes to be Ready..."
for i in 1 2 3; do
  kubectl wait node "gpu-worker-${i}" --for=condition=Ready --timeout=60s
done
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
