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
  init_kwok_cluster:
    init: true
    machine: dev-machine
    user: laborant
    timeout_seconds: 300
    run: |
      set -e
      cd /workdir
      bash course-1/scripts/setup-kwok-cluster.sh
      # Best-effort: wait for the apiserver port (derived from the kubeconfig
      # server URL) before polling node readiness. The script already created
      # the cluster synchronously, so this just hardens against a race.
      PORT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null | sed -E 's#.*:([0-9]+)/?$#\1#')
      if [ -n "${PORT}" ]; then
        until nc -z 127.0.0.1 "${PORT}" 2>/dev/null; do sleep 2; done
      fi
      kubectl wait --for=condition=Ready nodes --all --timeout=120s
      echo "KWOK cluster ready ✓"
  author_karpenter_nodepool:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for author_karpenter_nodepool"
      exit 1
  add_spot_config:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for add_spot_config"
      exit 1
  validate_nodepool:
    machine: dev-machine
    user: laborant
    run: |
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
      echo "Lesson complete ✓"
---
