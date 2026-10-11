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
  - observability
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
      if [ ! -d /workdir/.git ]; then
        git clone https://github.com/mercadoalex/gpu-engineering-on-kubernetes.git /workdir
      fi
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      kubectl config use-context kind-gpu-lab
      kubectl wait --for=condition=Ready nodes --all --timeout=120s
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
