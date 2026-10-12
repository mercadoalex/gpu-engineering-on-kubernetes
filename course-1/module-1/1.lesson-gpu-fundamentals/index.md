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
      # NO `set -e` here on purpose. The Ready-count uses `grep -c`, which exits 1
      # when the count is 0 (normal on cold boot before nodes register). Under
      # `set -e` that non-zero exit would abort the whole init task on the first
      # loop iteration, leaving the playground stuck at "Init tasks 0/1" forever.
      # This task must TOLERATE not-ready-yet and keep polling.
      #
      # The KWOK cluster is created and kept alive by the kwok-cluster.service
      # systemd unit baked into the image (NOT by this init task). The examiner
      # reaps an init task's process tree on completion, so a cluster created here
      # would die. This task only WAITS for the systemd-managed cluster.
      echo "Waiting for the systemd-managed KWOK cluster..."
      for i in $(seq 1 60); do
        READY=$(kubectl get nodes --no-headers 2>/dev/null | grep ' Ready ' | wc -l | tr -d ' ')
        if [ "${READY:-0}" -ge 3 ]; then
          echo "KWOK cluster ready — ${READY} nodes Ready ✓"
          exit 0
        fi
        echo "Waiting for 3 Ready nodes (have ${READY:-0})..."
        sleep 5
      done
      echo "ERROR: cluster did not reach 3 Ready nodes within timeout" >&2
      exit 1
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
      # Verify GPU capacity was injected onto at least one node via status patch.
      # (On KWOK we patch node status directly — there is no Helm release to check.)
      INJECTED=$(kubectl get nodes -o json | jq '[.items[] | select(.status.capacity["nvidia.com/gpu"] != null)] | length')
      [ "${INJECTED:-0}" -ge 1 ] || { echo "No node has nvidia.com/gpu capacity yet — run install-ghostgpu.sh"; exit 1; }
      echo "GPU capacity injected on $INJECTED node(s) ✓"

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
