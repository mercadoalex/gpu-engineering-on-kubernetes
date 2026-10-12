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
      # NO `set -e` here on purpose. The Ready-count uses `grep -c`, which exits 1
      # when the count is 0 (normal on cold boot before nodes register). Under
      # `set -e` that non-zero exit would abort the whole init task on the first
      # loop iteration, leaving the playground stuck at "Init tasks 0/1" forever.
      # This task must TOLERATE not-ready-yet and keep polling.
      #
      # The KWOK cluster is created and kept alive by the kwok-cluster.service
      # systemd unit baked into the image (NOT by this init task). The examiner
      # reaps an init task's process tree on completion, so a cluster created here
      # would die. This task only WAITS for the systemd-managed cluster.
      echo "Waiting for the systemd-managed KWOK cluster..."
      for i in $(seq 1 60); do
        READY=$(kubectl get nodes --no-headers 2>/dev/null | grep ' Ready ' | wc -l | tr -d ' ')
        if [ "${READY:-0}" -ge 3 ]; then
          echo "KWOK cluster ready — ${READY} nodes Ready ✓"
          exit 0
        fi
        echo "Waiting for 3 Ready nodes (have ${READY:-0})..."
        sleep 5
      done
      echo "ERROR: cluster did not reach 3 Ready nodes within timeout" >&2
      exit 1
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
