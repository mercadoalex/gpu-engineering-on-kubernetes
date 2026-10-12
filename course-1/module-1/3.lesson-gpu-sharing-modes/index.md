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
