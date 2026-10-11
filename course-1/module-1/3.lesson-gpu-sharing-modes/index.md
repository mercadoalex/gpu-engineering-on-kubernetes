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
      if [ ! -d /workdir/.git ]; then
        git clone https://github.com/mercadoalex/gpu-engineering-on-kubernetes.git /workdir
      fi
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      kubectl config use-context kind-gpu-lab
      kubectl wait --for=condition=Ready nodes --all --timeout=120s
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
