---
kind: lesson
title: Install the GPU Operator (Driver → Toolkit → Plugin → DCGM)
description: |
  Helm-install the NVIDIA GPU Operator and watch each component — driver, container toolkit, device plugin, DCGM exporter — roll out, then verify the node labels it adds. You'll stand up the full production GPU stack.
name: lesson-install-gpu-operator
slug: lesson-install-gpu-operator
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - gpu-operator
  - nvidia
  - helm
  - dcgm
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
tasks:
  helm_install_gpu_operator:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for helm_install_gpu_operator"
      exit 1
  watch_components_rollout:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for watch_components_rollout"
      exit 1
  verify_device_plugin:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for verify_device_plugin"
      exit 1
  verify_node_labels:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for verify_node_labels"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - helm_install_gpu_operator
      - watch_components_rollout
      - verify_device_plugin
      - verify_node_labels
    run: |
      echo "Lesson complete ✓"
---
