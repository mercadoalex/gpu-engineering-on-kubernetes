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
      set -e
      if [ ! -d /workdir/.git ]; then
        git clone https://github.com/mercadoalex/gpu-engineering-on-kubernetes.git /workdir
      fi
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      kubectl config use-context kind-gpu-lab
      kubectl wait --for=condition=Ready nodes --all --timeout=120s
      echo "KWOK cluster ready ✓"
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
