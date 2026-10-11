---
kind: lesson
title: 'MIG-Level Metrics: Observing Partitioned GPUs'
description: |
  Scrape per-MIG-instance metrics and build a Grafana dashboard that distinguishes all seven partitions of a MIG-sliced GPU. You'll close the observability module able to see inside a shared GPU.
name: lesson-mig-metrics
slug: lesson-mig-metrics
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
  - observability
tagz:
  - mig
  - dcgm
  - grafana
  - gpu-metrics
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
# challenges:   (commented out — no slug yet; FINAL LESSON ONLY)
#   TODO: add platform challenge slug once labctl content create assigns one
#   <platform-slug>: {}
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
  scrape_per_mig_metrics:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for scrape_per_mig_metrics"
      exit 1
  build_mig_dashboard:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for build_mig_dashboard"
      exit 1
  verify_seven_partitions:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for verify_seven_partitions"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - scrape_per_mig_metrics
      - build_mig_dashboard
      - verify_seven_partitions
    run: |
      echo "Lesson complete ✓"
---
