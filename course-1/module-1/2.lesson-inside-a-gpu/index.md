---
kind: lesson
title: What's Actually Inside a GPU (and Why K8s Doesn't Care)
description: |
  Open a captured nvidia-smi sample and map streaming multiprocessors, VRAM, and tensor cores onto the single opaque nvidia.com/gpu integer Kubernetes tracks. You'll inspect a node's extended-resource data model and see exactly how much the scheduler throws away.
name: lesson-inside-a-gpu
slug: lesson-inside-a-gpu
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - gpu-scheduling
  - nvidia
  - nvidia-smi
  - extended-resources
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
  inspect_nvidia_smi_sample:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for inspect_nvidia_smi_sample"
      exit 1
  map_gpu_to_extended_resource:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for map_gpu_to_extended_resource"
      exit 1
  inspect_node_resource_model:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for inspect_node_resource_model"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - inspect_nvidia_smi_sample
      - map_gpu_to_extended_resource
      - inspect_node_resource_model
    run: |
      echo "Lesson complete ✓"
---
