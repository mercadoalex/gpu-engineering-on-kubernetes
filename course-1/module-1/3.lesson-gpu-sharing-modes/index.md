---
kind: lesson
title: 'MIG, Time-Slicing, vGPU: Three Ways to Share One GPU'
description: |
  Simulate the node labels each GPU-sharing mode produces in KWOK, schedule pods against nvidia.com/mig-1g.5gb, and reason about the isolation guarantees of MIG versus time-slicing versus vGPU. You'll see why "sharing a GPU" means three very different things.
name: lesson-gpu-sharing-modes
slug: lesson-gpu-sharing-modes
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - gpu-scheduling
  - mig
  - time-slicing
  - vgpu
  - kwok
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
# challenges:   (commented out — no slug yet; FINAL LESSON ONLY)
#   TODO: add platform challenge slug once labctl content create assigns one
#   <platform-slug>: {}
tasks:
  init_kwok_cluster:
    init: true
    machine: dev-machine
    user: laborant
    timeout_seconds: 300
    run: |
      set -e
      # The KWOK cluster is created and kept alive by the kwok-cluster.service
      # systemd unit baked into the image (NOT by this init task). The examiner
      # reaps an init task's process tree on completion, so a cluster created
      # here would die. This task only WAITS for the systemd-managed cluster.
      # Wait for the apiserver port derived from the kubeconfig the service wrote.
      echo "Waiting for the systemd-managed KWOK cluster..."
      for i in $(seq 1 60); do
        PORT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null | sed -E 's#.*:([0-9]+)/?$#\1#')
        if [ -n "${PORT}" ] && nc -z 127.0.0.1 "${PORT}" 2>/dev/null; then
          break
        fi
        sleep 5
      done
      # Loop until 3 nodes report Ready (or the 300s task timeout fires).
      until [ "$(kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready ')" -ge 3 ]; do
        echo "Waiting for 3 Ready nodes..."
        sleep 5
      done
      echo "KWOK cluster ready ✓"
  label_nodes_sharing_modes:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for label_nodes_sharing_modes"
      exit 1
  schedule_mig_pod:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for schedule_mig_pod"
      exit 1
  compare_isolation_guarantees:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for compare_isolation_guarantees"
      exit 1
  cleanup_sharing_demo:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for cleanup_sharing_demo"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - label_nodes_sharing_modes
      - schedule_mig_pod
      - compare_isolation_guarantees
      - cleanup_sharing_demo
    run: |
      echo "Lesson complete ✓"
---
