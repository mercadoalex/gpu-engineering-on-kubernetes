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

CTX="kwok-${CLUSTER_NAME}"

# ── Fast idempotent early-exit ─────────────────────────────────────────────────
# The cluster is owned by the kwok-cluster.service systemd unit and persists for
# the VM lifetime. This script is run both by that service (at boot) and can be
# re-run by hand or by `systemctl restart`. If the cluster ALREADY exists AND its
# apiserver is serving /healthz=ok, there is nothing to do: select the context so
# the caller's kubeconfig points at it and exit 0 immediately.
#
# NOTE: `kwokctl get clusters` only confirms the cluster METADATA exists, not that
# the processes are up (after a reboot the metadata dir can survive while etcd/
# apiserver are down). So we require BOTH: metadata present AND a single immediate
# /healthz check. If metadata exists but is NOT serving, we fall through to the
# recovery branch below (delete the dead cluster, then recreate).
if kwokctl get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  if kubectl config get-contexts -o name 2>/dev/null | grep -q "^${CTX}$" \
     && kubectl --context "${CTX}" get --raw /healthz 2>/dev/null | grep -q '^ok$'; then
    kubectl config use-context "${CTX}" >/dev/null 2>&1 || true
    echo "ℹ️  kwok cluster already running and serving — nothing to do"
    exit 0
  fi
fi

# ── Create the kwokctl binary-runtime cluster ──────────────────────────────────
if kwokctl get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  # Metadata exists but the apiserver is NOT serving (checked above) — the cluster
  # is dead (e.g. a reboot left stale metadata). Delete it and recreate cleanly;
  # kwokctl refuses to create over an existing name, so the delete is required.
  echo "⚠  kwok cluster '${CLUSTER_NAME}' exists but is not serving — recreating"
  kwokctl delete cluster --name "${CLUSTER_NAME}" 2>/dev/null || true
fi

echo "→ Creating kwok binary-runtime cluster '${CLUSTER_NAME}' (kube ${KUBE_VERSION})..."
# kwokctl v0.6.0 has NO --kube-version flag; the version is selected via the
# KWOK_KUBE_VERSION env var. The binaries are pre-cached in the image at this
# exact version, so this create is fully offline.
KWOK_KUBE_VERSION="${KUBE_VERSION}" kwokctl create cluster \
  --name "${CLUSTER_NAME}" \
  --runtime=binary
echo "✓ kwok cluster created"

# ── Select the kubectl context ─────────────────────────────────────────────────
# kwokctl's binary runtime writes a kubeconfig context named kwok-<name> into the
# DEFAULT kubeconfig (~/.kube/config since no KUBECONFIG/--kubeconfig is set), so
# the laborant login shell sees it with no manual export. CTX is set at the top.
if ! kubectl config get-contexts -o name 2>/dev/null | grep -q "^${CTX}$"; then
  echo "ERROR: expected kubeconfig context '${CTX}' not found."
  echo "       Available contexts:"; kubectl config get-contexts -o name || true
  exit 1
fi
kubectl config use-context "${CTX}"
echo "✓ Using context '${CTX}'"

# ── Wait for the apiserver to actually SERVE ───────────────────────────────────
# kwokctl's "Cluster is started" message is optimistic — under slower hosts the
# kube-apiserver may still be warming up. Poll /healthz before touching the API,
# otherwise the node apply below hits "connection refused". On native amd64 this
# is ready in seconds; the generous loop covers slow/first-boot cases.
echo "→ Waiting for the apiserver to serve..."
for i in $(seq 1 60); do
  if kubectl get --raw /healthz 2>/dev/null | grep -q '^ok$'; then
    echo "✓ apiserver healthy"
    break
  fi
  [ "$i" -eq 60 ] && { echo "ERROR: apiserver did not become healthy in 300s"; exit 1; }
  sleep 5
done

# ── Persist KUBECONFIG for the iximiuz examiner (safety net) ───────────────────
# The iximiuz examiner runs grading task checks in a minimal environment (often
# root with HOME unset) where kubectl's default ~/.kube/config is empty, so it
# falls back to localhost:8080, gets "connection refused", and every task fails —
# leaving the playground spinner stuck at "Init tasks 0/1". The PRIMARY fix is a
# per-task `export KUBECONFIG=/home/laborant/.kube/config` embedded in each Tier 1
# lesson's task run blocks. This writes the same value to /etc/environment as a
# secondary safety net so login shells inherit it too. Idempotent: only append if
# the line is not already present.
KUBECONFIG_LINE="KUBECONFIG=/home/laborant/.kube/config"
if ! grep -qxF "${KUBECONFIG_LINE}" /etc/environment 2>/dev/null; then
  echo "${KUBECONFIG_LINE}" | sudo tee -a /etc/environment >/dev/null
  echo "✓ Persisted ${KUBECONFIG_LINE} to /etc/environment"
else
  echo "ℹ️  ${KUBECONFIG_LINE} already in /etc/environment — skipping"
fi
export KUBECONFIG=/home/laborant/.kube/config

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
  # --validate=false: skip the openapi schema download. The fake Node spec is
  # trivially valid, and skipping avoids a dependency on the apiserver's openapi
  # endpoint being fully warmed during the first seconds after startup.
  kubectl apply --validate=false -f - <<EOF
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
