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
  create_priority_classes:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for create_priority_classes"
      exit 1
  configure_preemption_policy:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for configure_preemption_policy"
      exit 1
  submit_competing_jobs:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for submit_competing_jobs"
      exit 1
  observe_eviction:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
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
      export KUBECONFIG=/home/laborant/.kube/config
      echo "Lesson complete ✓"
---
