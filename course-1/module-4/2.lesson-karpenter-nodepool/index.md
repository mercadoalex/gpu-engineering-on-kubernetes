---
kind: lesson
title: Karpenter NodePool (Authoring Only — No GCP Provider)
description: |
  Write a Karpenter NodePool with a spot configuration and validate it, then understand why GCP uses the GKE Cluster Autoscaler instead of Karpenter. You'll author the config for portability without provisioning anything.
name: lesson-karpenter-nodepool
slug: lesson-karpenter-nodepool
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - karpenter
  - nodepool
  - spot
  - gke
  - finops
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
tasks:
  author_karpenter_nodepool:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for author_karpenter_nodepool"
      exit 1
  add_spot_config:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for add_spot_config"
      exit 1
  validate_nodepool:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "TODO: implement check for validate_nodepool"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - author_karpenter_nodepool
      - add_spot_config
      - validate_nodepool
    run: |
      export KUBECONFIG=/home/laborant/.kube/config
      echo "Lesson complete ✓"
---
