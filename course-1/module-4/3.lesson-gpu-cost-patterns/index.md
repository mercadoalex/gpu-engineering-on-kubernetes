---
kind: lesson
title: 'Cost Patterns: Spot, Consolidation, and the Idle-Node Trap'
description: |
  Model a month of GPU cost under spot versus on-demand pricing, configure node consolidation, and hit the under-$50/month target. You'll turn cost control from a hope into a configured outcome.
name: lesson-gpu-cost-patterns
slug: lesson-gpu-cost-patterns
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - finops
  - spot
  - consolidation
  - gpu-cost
  - gke
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
  model_monthly_cost:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for model_monthly_cost"
      exit 1
  configure_consolidation:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for configure_consolidation"
      exit 1
  hit_cost_target:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for hit_cost_target"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - model_monthly_cost
      - configure_consolidation
      - hit_cost_target
    run: |
      echo "Lesson complete ✓"
---
