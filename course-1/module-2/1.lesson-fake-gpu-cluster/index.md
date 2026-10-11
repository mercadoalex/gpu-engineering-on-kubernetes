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
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      # Best-effort: wait for the apiserver port (derived from the kubeconfig
      # server URL) before polling node readiness. The script already created
      # the cluster synchronously, so this just hardens against a race.
      PORT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null | sed -E 's#.*:([0-9]+)/?$#\1#')
      if [ -n "${PORT}" ]; then
        until nc -z 127.0.0.1 "${PORT}" 2>/dev/null; do sleep 2; done
      fi
      kubectl wait --for=condition=Ready nodes --all --timeout=120s
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
