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
      if [ ! -d /workdir/.git ]; then
        git clone https://github.com/mercadoalex/gpu-engineering-on-kubernetes.git /workdir
      fi
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      kubectl config use-context kind-gpu-lab
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
