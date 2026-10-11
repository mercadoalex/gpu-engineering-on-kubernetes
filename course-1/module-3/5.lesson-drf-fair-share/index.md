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
