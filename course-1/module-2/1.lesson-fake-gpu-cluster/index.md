---
kind: lesson
title: Fake a Thousand-Node GPU Cluster on Your Laptop
description: |
  Use kwokctl create cluster to stand up a virtual control plane, add virtual GPU nodes, and watch them report Ready at near-zero RAM cost. You'll build the simulation substrate every later Tier 1 module reuses.
name: lesson-fake-gpu-cluster
slug: lesson-fake-gpu-cluster
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - kwok
  - simulation
  - gpu-scheduling
  - kwokctl
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
  create_kwok_cluster:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for create_kwok_cluster"
      exit 1
  add_virtual_gpu_nodes:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for add_virtual_gpu_nodes"
      exit 1
  verify_nodes_ready:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for verify_nodes_ready"
      exit 1
  check_ram_footprint:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for check_ram_footprint"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - create_kwok_cluster
      - add_virtual_gpu_nodes
      - verify_nodes_ready
      - check_ram_footprint
    run: |
      echo "Lesson complete ✓"
---
