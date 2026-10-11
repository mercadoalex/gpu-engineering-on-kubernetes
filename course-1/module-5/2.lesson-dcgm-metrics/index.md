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
  build_util_vram_panels:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for build_util_vram_panels"
      exit 1
  build_temp_power_panels:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for build_temp_power_panels"
      exit 1
  build_xid_panel:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for build_xid_panel"
      exit 1
  interpret_metrics:
    machine: dev-machine
    user: laborant
    run: |
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
      echo "Lesson complete ✓"
---
