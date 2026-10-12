---
kind: lesson
title: 'Injecting GPU Capacity: ghostgpu vs fake-gpu-operator'
description: |
  Compare the two GPU-capacity injectors side by side, patch node status directly, and understand the device-plugin contract they both emulate. You'll know which tool to reach for and why they produce identical scheduler behavior.
name: lesson-injecting-gpu-capacity
slug: lesson-injecting-gpu-capacity
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - kwok
  - ghostgpu
  - fake-gpu-operator
  - device-plugin
  - nvidia
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
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
  install_ghostgpu:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for install_ghostgpu"
      exit 1
  patch_node_status_manually:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for patch_node_status_manually"
      exit 1
  compare_injectors:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for compare_injectors"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - install_ghostgpu
      - patch_node_status_manually
      - compare_injectors
    run: |
      echo "Lesson complete ✓"
---
