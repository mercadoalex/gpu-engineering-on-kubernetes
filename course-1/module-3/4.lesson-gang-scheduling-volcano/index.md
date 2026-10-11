---
kind: lesson
title: 'Gang Scheduling with Volcano: Why Training Jobs Deadlock'
description: |
  Submit a 4-pod job without gang scheduling and watch it deadlock, then resubmit it with Volcano's minAvailable all-or-nothing guarantee. You'll see firsthand why distributed training jobs need gang scheduling to make progress.
name: lesson-gang-scheduling-volcano
slug: lesson-gang-scheduling-volcano
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - volcano
  - gang-scheduling
  - training
  - gpu-scheduling
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
  install_volcano:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for install_volcano"
      exit 1
  submit_job_without_gang:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for submit_job_without_gang"
      exit 1
  observe_deadlock:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for observe_deadlock"
      exit 1
  submit_job_with_minavailable:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for submit_job_with_minavailable"
      exit 1
  verify_all_or_nothing:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for verify_all_or_nothing"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - install_volcano
      - submit_job_without_gang
      - observe_deadlock
      - submit_job_with_minavailable
      - verify_all_or_nothing
    run: |
      echo "Lesson complete ✓"
---
