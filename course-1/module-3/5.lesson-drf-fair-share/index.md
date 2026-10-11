---
kind: lesson
title: 'DRF Fair-Share: Make Volcano Divide Resources Fairly'
description: |
  Configure Volcano queues with Dominant Resource Fairness, submit competing jobs from multiple teams, and observe the scheduler divide GPUs fairly. You'll close out the scheduling module by making fairness a configured guarantee, not an accident.
name: lesson-drf-fair-share
slug: lesson-drf-fair-share
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - volcano
  - drf
  - fair-share
  - gpu-scheduling
  - multi-tenancy
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
  configure_volcano_drf_queues:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for configure_volcano_drf_queues"
      exit 1
  submit_competing_jobs:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for submit_competing_jobs"
      exit 1
  observe_fair_division:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for observe_fair_division"
      exit 1
  verify_drf_shares:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for verify_drf_shares"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - configure_volcano_drf_queues
      - submit_competing_jobs
      - observe_fair_division
      - verify_drf_shares
    run: |
      echo "Lesson complete ✓"
---
