---
kind: lesson
title: The 5 DCGM Metrics That Actually Matter
description: |
  Build Grafana panels for GPU utilization, VRAM, temperature, power, and XID errors, and learn to read each one. You'll know which five DCGM metrics tell you whether a GPU fleet is healthy.
name: lesson-dcgm-metrics
slug: lesson-dcgm-metrics
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
  - observability
tagz:
  - dcgm
  - grafana
  - gpu-metrics
  - prometheus
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
tasks:
  build_util_vram_panels:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for build_util_vram_panels"
      exit 1
  build_temp_power_panels:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for build_temp_power_panels"
      exit 1
  build_xid_panel:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for build_xid_panel"
      exit 1
  interpret_metrics:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for interpret_metrics"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - build_util_vram_panels
      - build_temp_power_panels
      - build_xid_panel
      - interpret_metrics
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "Lesson complete ✓"
---
