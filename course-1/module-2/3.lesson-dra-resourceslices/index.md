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
      if [ ! -d /workdir/.git ]; then
        git clone https://github.com/mercadoalex/gpu-engineering-on-kubernetes.git /workdir
      fi
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      kubectl config use-context kind-gpu-lab
      kubectl wait --for=condition=Ready nodes --all --timeout=120s
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
