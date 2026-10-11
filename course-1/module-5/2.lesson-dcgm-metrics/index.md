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
