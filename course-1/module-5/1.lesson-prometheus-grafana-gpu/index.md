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
  - observability
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
      set -e
      if [ ! -d /workdir/.git ]; then
        git clone https://github.com/mercadoalex/gpu-engineering-on-kubernetes.git /workdir
      fi
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      kubectl config use-context kind-gpu-lab
      kubectl wait --for=condition=Ready nodes --all --timeout=120s
      echo "KWOK cluster ready ✓"
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
