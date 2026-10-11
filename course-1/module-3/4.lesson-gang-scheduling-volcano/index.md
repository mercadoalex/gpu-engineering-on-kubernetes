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
      if [ ! -d /workdir/.git ]; then
        git clone https://github.com/mercadoalex/gpu-engineering-on-kubernetes.git /workdir
      fi
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      kubectl config use-context kind-gpu-lab
      kubectl wait --for=condition=Ready nodes --all --timeout=120s
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
