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
