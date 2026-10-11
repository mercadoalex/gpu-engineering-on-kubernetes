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
