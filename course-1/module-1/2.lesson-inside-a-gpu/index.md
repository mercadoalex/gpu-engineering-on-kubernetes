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
  inspect_nvidia_smi_sample:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for inspect_nvidia_smi_sample"
      exit 1
  map_gpu_to_extended_resource:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for map_gpu_to_extended_resource"
      exit 1
  inspect_node_resource_model:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
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
      export KUBECONFIG=/home/laborant/.kube/config
      echo "Lesson complete ✓"
---
