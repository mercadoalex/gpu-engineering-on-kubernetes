---
kind: lesson
title: 'Scale-to-Zero: GPU Nodes Shouldn''t Idle at $0.71/hr'
description: |
  Author a GKE Cluster Autoscaler node pool YAML, validate it with --dry-run=server, and reason about a min=0/max=3 scale-to-zero policy. You'll learn to keep GPU nodes from burning money while idle.
name: lesson-scale-to-zero
slug: lesson-scale-to-zero
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - gke
  - cluster-autoscaler
  - scale-to-zero
  - finops
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
  author_nodepool_yaml:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for author_nodepool_yaml"
      exit 1
  validate_dry_run:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for validate_dry_run"
      exit 1
  reason_about_min_max:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for reason_about_min_max"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - author_nodepool_yaml
      - validate_dry_run
      - reason_about_min_max
    run: |
      echo "Lesson complete ✓"
---
