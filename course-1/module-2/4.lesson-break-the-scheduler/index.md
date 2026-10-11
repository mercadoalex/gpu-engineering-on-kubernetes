---
kind: lesson
title: 'Break the Scheduler: Taints, Affinity, and Why Pods Pend'
description: |
  Deliberately misconfigure taints and nodeSelectors, read the scheduler events that explain each failure, then fix them one by one. You'll build the debugging reflex that turns a Pending pod into a solved problem.
name: lesson-break-the-scheduler
slug: lesson-break-the-scheduler
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - kwok
  - scheduler
  - taints
  - affinity
  - troubleshooting
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
  misconfigure_taints:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for misconfigure_taints"
      exit 1
  read_scheduler_events:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for read_scheduler_events"
      exit 1
  fix_nodeselector:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for fix_nodeselector"
      exit 1
  verify_pod_scheduled:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for verify_pod_scheduled"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - misconfigure_taints
      - read_scheduler_events
      - fix_nodeselector
      - verify_pod_scheduled
    run: |
      echo "Lesson complete ✓"
---
