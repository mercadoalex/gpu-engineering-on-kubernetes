---
kind: lesson
title: 'Alerting on Failure Modes: Thermal, XID, VRAM Exhaustion'
description: |
  Write Prometheus alert rules for thermal, XID, and VRAM-exhaustion failure modes, then trigger a synthetic thermal-throttle event and watch the alert fire. You'll turn raw metrics into actionable alerts.
name: lesson-gpu-alerting
slug: lesson-gpu-alerting
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
  - observability
tagz:
  - prometheus
  - alerting
  - dcgm
  - gpu-metrics
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
  write_thermal_alert:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for write_thermal_alert"
      exit 1
  write_xid_alert:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for write_xid_alert"
      exit 1
  write_vram_alert:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for write_vram_alert"
      exit 1
  trigger_and_verify_alert:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for trigger_and_verify_alert"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - write_thermal_alert
      - write_xid_alert
      - write_vram_alert
      - trigger_and_verify_alert
    run: |
      echo "Lesson complete ✓"
---
