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
