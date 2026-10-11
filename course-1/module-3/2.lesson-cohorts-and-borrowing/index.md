---
kind: lesson
title: 'Cohorts and Borrowing: Share GPUs Without Fighting'
description: |
  Put two teams in one cohort and watch Team A borrow Team B's idle GPUs, then watch B reclaim them when it needs them back. You'll configure the borrowing and lending limits that make fair GPU sharing possible.
name: lesson-cohorts-and-borrowing
slug: lesson-cohorts-and-borrowing
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - kueue
  - cohort
  - borrowing
  - gpu-scheduling
  - multi-tenancy
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
  create_two_team_queues:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for create_two_team_queues"
      exit 1
  configure_cohort:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for configure_cohort"
      exit 1
  team_a_borrows_idle_gpus:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for team_a_borrows_idle_gpus"
      exit 1
  team_b_reclaims:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for team_b_reclaims"
      exit 1
  verify_borrowing_behavior:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for verify_borrowing_behavior"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - create_two_team_queues
      - configure_cohort
      - team_a_borrows_idle_gpus
      - team_b_reclaims
      - verify_borrowing_behavior
    run: |
      echo "Lesson complete ✓"
---
