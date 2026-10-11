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
