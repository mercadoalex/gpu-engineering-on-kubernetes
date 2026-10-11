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
