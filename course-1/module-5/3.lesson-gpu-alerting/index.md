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
  - observability
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
      if [ ! -d /workdir/.git ]; then
        git clone https://github.com/mercadoalex/gpu-engineering-on-kubernetes.git /workdir
      fi
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      kubectl config use-context kind-gpu-lab
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
