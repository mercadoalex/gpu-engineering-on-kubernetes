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
