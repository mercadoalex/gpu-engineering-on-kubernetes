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
