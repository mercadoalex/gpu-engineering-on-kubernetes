---
kind: lesson
title: Your Cluster Has No Idea What a GPU Is (Yet)
description: |
  Kubernetes treats GPUs as opaque integers. In this lesson you'll discover why — then fix it.
  Install ghostgpu on a KWOK virtual cluster, watch nodes go from zero GPU capacity to four,
  schedule your first GPU pod, and deliberately break it by asking for more than the cluster has.
name: lesson-gpu-fundamentals
slug: lesson-gpu-fundamentals
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - gpu-scheduling
  - kwok
  - nvidia
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
# challenges:   (commented out — no slug yet)
#   <platform-slug>: {}
tasks:
  init_kwok_cluster:
    init: true
    machine: dev-machine
    user: laborant
    timeout_seconds: 300
    run: |
      set -e
      if [ ! -d /workdir/.git ]; then
        git clone https://github.com/mercadoalex/gpu-engineering-on-kubernetes.git /workdir
      fi
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      kubectl config use-context kind-gpu-lab
      kubectl wait --for=condition=Ready nodes --all --timeout=120s
      echo "KWOK cluster ready ✓"
  verify_node_allocatable:
    machine: dev-machine
    user: laborant
    run: |
      # Verify KWOK virtual nodes exist and are Ready
      READY=$(kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready ' || echo 0)
      [ "$READY" -ge 2 ] || { echo "Expected >= 2 Ready nodes, got $READY"; exit 1; }
      echo "$READY nodes Ready ✓"

  verify_no_gpu_before:
    machine: dev-machine
    user: laborant
    run: |
      # Confirm nvidia.com/gpu is NOT present before ghostgpu install
      GPU_COUNT=$(kubectl get nodes -o json | jq '[.items[].status.allocatable | to_entries[] | select(.key == "nvidia.com/gpu")] | length')
      [ "$GPU_COUNT" -eq 0 ] || { echo "nvidia.com/gpu already present — ghostgpu may already be installed"; exit 1; }
      echo "No GPU resources found — cluster is GPU-naive ✓"

  verify_ghostgpu_installed:
    machine: dev-machine
    user: laborant
    run: |
      # Verify ghostgpu Helm release exists
      helm list -n kube-system --filter ghostgpu -o json | jq -e '.[0].status == "deployed"' > /dev/null 2>&1 || { echo "ghostgpu Helm release not found in kube-system"; exit 1; }
      echo "ghostgpu Helm release deployed ✓"

  verify_gpu_capacity:
    machine: dev-machine
    user: laborant
    needs:
      - verify_ghostgpu_installed
    run: |
      # Verify at least one node reports nvidia.com/gpu >= 1
      GPU_COUNT=$(kubectl get nodes -o json | jq '[.items[].status.allocatable["nvidia.com/gpu"] // "0" | tonumber] | add')
      [ "${GPU_COUNT:-0}" -ge 1 ] || { echo "No nvidia.com/gpu capacity found on any node"; exit 1; }
      echo "Total GPU capacity: $GPU_COUNT ✓"

  verify_gpu_pod_scheduled:
    machine: dev-machine
    user: laborant
    needs:
      - verify_gpu_capacity
    run: |
      # Verify the gpu-test pod is Running
      PHASE=$(kubectl get pod gpu-test -n default -o jsonpath='{.status.phase}' 2>/dev/null)
      [ "$PHASE" = "Running" ] || { echo "gpu-test pod is not Running (phase: ${PHASE:-not found})"; exit 1; }
      echo "gpu-test pod is Running ✓"

  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - verify_node_allocatable
      - verify_no_gpu_before
      - verify_ghostgpu_installed
      - verify_gpu_capacity
      - verify_gpu_pod_scheduled
    run: |
      echo "All GPU Fundamentals tasks complete ✓"
---
