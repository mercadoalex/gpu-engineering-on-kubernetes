---
kind: lesson
title: Wire Up Prometheus + Grafana for GPU Metrics
description: |
  Deploy Prometheus and Grafana, scrape a synthetic DCGM exporter, and watch GPU metrics flow into dashboards. You'll build the observability stack that the rest of the module depends on.
name: lesson-prometheus-grafana-gpu
slug: lesson-prometheus-grafana-gpu
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
  - observability
tagz:
  - prometheus
  - grafana
  - dcgm
  - gpu-metrics
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
tasks:
  init_kwok_cluster:
    init: true
    machine: dev-machine
    user: laborant
    timeout_seconds: 300
    run: |
      # NO `set -e` here on purpose. The Ready-count uses `grep -c`, which exits 1
      # when the count is 0 (normal on cold boot before nodes register). Under
      # `set -e` that non-zero exit would abort the whole init task on the first
      # loop iteration, leaving the playground stuck at "Init tasks 0/1" forever.
      # This task must TOLERATE not-ready-yet and keep polling.
      #
      # The KWOK cluster is created and kept alive by the kwok-cluster.service
      # systemd unit baked into the image (NOT by this init task). The examiner
      # reaps an init task's process tree on completion, so a cluster created here
      # would die. This task only WAITS for the systemd-managed cluster.
      echo "Waiting for the systemd-managed KWOK cluster..."
      for i in $(seq 1 60); do
        READY=$(kubectl get nodes --no-headers 2>/dev/null | grep ' Ready ' | wc -l | tr -d ' ')
        if [ "${READY:-0}" -ge 3 ]; then
          echo "KWOK cluster ready — ${READY} nodes Ready ✓"
          exit 0
        fi
        echo "Waiting for 3 Ready nodes (have ${READY:-0})..."
        sleep 5
      done
      echo "ERROR: cluster did not reach 3 Ready nodes within timeout" >&2
      exit 1
  deploy_prometheus_grafana:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for deploy_prometheus_grafana"
      exit 1
  deploy_dcgm_exporter:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for deploy_dcgm_exporter"
      exit 1
  configure_scrape:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for configure_scrape"
      exit 1
  verify_metrics_flow:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for verify_metrics_flow"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - deploy_prometheus_grafana
      - deploy_dcgm_exporter
      - configure_scrape
      - verify_metrics_flow
    run: |
      echo "Lesson complete ✓"
---
