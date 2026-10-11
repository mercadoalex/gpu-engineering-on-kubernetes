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
