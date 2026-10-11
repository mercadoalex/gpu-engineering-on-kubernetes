---
kind: lesson
title: 'Preemption: Who Gets Evicted When the Cluster Is Full'
description: |
  Define priority classes, configure a Kueue preemption policy, and watch a low-priority job get evicted to make room for a high-priority one. You'll understand exactly who gets evicted when the cluster is full and why.
name: lesson-preemption
slug: lesson-preemption
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - kueue
  - preemption
  - priority-class
  - gpu-scheduling
  - kubernetes
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
  create_priority_classes:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for create_priority_classes"
      exit 1
  configure_preemption_policy:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for configure_preemption_policy"
      exit 1
  submit_competing_jobs:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for submit_competing_jobs"
      exit 1
  observe_eviction:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for observe_eviction"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - create_priority_classes
      - configure_preemption_policy
      - submit_competing_jobs
      - observe_eviction
    run: |
      echo "Lesson complete ✓"
---
