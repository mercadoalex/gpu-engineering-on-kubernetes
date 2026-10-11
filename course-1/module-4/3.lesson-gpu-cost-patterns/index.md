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
      if [ ! -d /workdir/.git ]; then
        git clone https://github.com/mercadoalex/gpu-engineering-on-kubernetes.git /workdir
      fi
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      kubectl config use-context kind-gpu-lab
      kubectl wait --for=condition=Ready nodes --all --timeout=120s
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
