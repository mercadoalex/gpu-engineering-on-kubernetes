---
kind: lesson
title: Install Kueue and Build Your First Quota Wall
description: |
  Install Kueue and wire up a ClusterQueue, LocalQueue, and ResourceFlavor into a working GPU quota wall. Submit a Job and watch it get admitted or suspended based on the quota you set.
name: lesson-kueue-quota-wall
slug: lesson-kueue-quota-wall
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - kueue
  - gpu-scheduling
  - clusterqueue
  - quota
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
  install_kueue:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for install_kueue"
      exit 1
  create_resourceflavor:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for create_resourceflavor"
      exit 1
  create_cluster_and_local_queue:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for create_cluster_and_local_queue"
      exit 1
  submit_job_and_observe_admission:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for submit_job_and_observe_admission"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - install_kueue
      - create_resourceflavor
      - create_cluster_and_local_queue
      - submit_job_and_observe_admission
    run: |
      echo "Lesson complete ✓"
---
