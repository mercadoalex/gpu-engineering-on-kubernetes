---
kind: lesson
title: 'DRA ResourceSlices: The New GPU Model'
description: |
  Enable the Dynamic Resource Allocation feature gate, create ResourceSlices, and schedule a pod through a ResourceClaim. You'll contrast structured DRA objects with the opaque extended-resource integer model from Module 1.
name: lesson-dra-resourceslices
slug: lesson-dra-resourceslices
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - dra
  - resourceslices
  - kwok
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
  enable_dra_feature_gate:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for enable_dra_feature_gate"
      exit 1
  create_resourceslices:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for create_resourceslices"
      exit 1
  schedule_via_resourceclaim:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for schedule_via_resourceclaim"
      exit 1
  contrast_with_extended_resources:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for contrast_with_extended_resources"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - enable_dra_feature_gate
      - create_resourceslices
      - schedule_via_resourceclaim
      - contrast_with_extended_resources
    run: |
      echo "Lesson complete ✓"
---
