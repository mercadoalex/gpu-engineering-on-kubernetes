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
