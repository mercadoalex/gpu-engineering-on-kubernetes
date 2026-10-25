---
kind: lesson
title: "Inside HAMi: The Architecture of GPU Sharing"
description: |
  On a dedicated four-VM k3s playground, meet HAMi — the CNCF project that slices GPUs
  in software. fake-gpu-operator and HAMi (scheduler + webhook, device-plugin off) are
  already installed; you'll watch fake nvidia.com/gpu capacity appear, trace the
  webhook → hami-scheduler → placement chain, learn the gpumem/gpucores resource model,
  and run a GPU pod with a simulated nvidia-smi. Honest scope: real memory and compute
  slicing need real hardware and wait for Lesson 6.4.
name: lesson-hami-architecture
slug: lesson-hami-architecture
createdAt: 2026-10-12
updatedAt: 2026-10-12
categories:
  - kubernetes
tagz:
  - hami
  - gpu-sharing
  - vgpu
  - cncf
  - scheduler
playground:
  name: hami-k3s-b5cd6d78
# challenges:   (commented out — no platform slug yet)
#   <platform-slug>: {}
tasks:
  verify_cluster_ready:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=$HOME/.kube/config
      # The k3s cluster plus its init tasks come up on boot. There is no init
      # task in the lesson, so this first grading task doubles as the "wait for
      # cluster" gate: it polls until >= 3 nodes are Ready (cplane-01 + node-01 +
      # node-02; dev-machine is a workstation, not a cluster node). grep piped to
      # wc -l (not grep -c) so a zero count still returns exit 0.
      READY=$(kubectl get nodes --no-headers 2>/dev/null | grep ' Ready ' | wc -l | tr -d ' ')
      [ "${READY:-0}" -ge 3 ] || { echo "Waiting for k3s nodes to be Ready (have ${READY:-0})..."; exit 1; }
      echo "${READY} nodes Ready ✓"

  verify_fake_gpu_operator_installed:
    machine: dev-machine
    user: laborant
    run: |
      export KUBECONFIG=$HOME/.kube/config
      # Confirm the gpu-operator namespace exists and its pods are Running
      # (device-plugin / status-updater / topology-server, etc.).
      kubectl get namespace gpu-operator >/dev/null 2>&1 \
        || { echo "gpu-operator namespace not found — fake-gpu-operator is not installed"; exit 1; }
      RUNNING=$(kubectl get pods -n gpu-operator --no-headers 2>/dev/null | grep ' Running ' | wc -l | tr -d ' ')
      [ "${RUNNING:-0}" -ge 1 ] || { echo "No Running fake-gpu-operator pods yet (have ${RUNNING:-0})..."; exit 1; }
      echo "fake-gpu-operator running with ${RUNNING} pod(s) ✓"

  verify_fake_gpus_present:
    machine: dev-machine
    user: laborant
    needs:
      - verify_fake_gpu_operator_installed
    run: |
      export KUBECONFIG=$HOME/.kube/config
      # Total nvidia.com/gpu capacity across all nodes must be >= 1.
      GPU=$(kubectl get nodes -o json 2>/dev/null | jq '[.items[].status.capacity["nvidia.com/gpu"] // "0" | tonumber] | add')
      [ "${GPU:-0}" -ge 1 ] || { echo "No fake nvidia.com/gpu capacity found on any node"; exit 1; }
      echo "Fake GPU capacity on cluster: ${GPU} ✓"

  verify_hami_scheduler_running:
    machine: dev-machine
    user: laborant
    needs:
      - verify_fake_gpu_operator_installed
    run: |
      export KUBECONFIG=$HOME/.kube/config
      # The HAMi scheduler pod runs two containers (scheduler + webhook), so it
      # reports 2/2 when healthy. grep piped to wc -l (not grep -c) keeps exit 0
      # on a zero match.
      COUNT=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | grep hami-scheduler | grep '2/2' | grep ' Running ' | wc -l | tr -d ' ')
      [ "${COUNT:-0}" -ge 1 ] || { echo "hami-scheduler is not 2/2 Running yet (have ${COUNT:-0})..."; exit 1; }
      echo "hami-scheduler is 2/2 Running ✓"

  verify_gpu_pod_scheduled:
    machine: dev-machine
    user: laborant
    needs:
      - verify_fake_gpus_present
      - verify_hami_scheduler_running
    run: |
      export KUBECONFIG=$HOME/.kube/config
      # The test pod (course-1/manifests/hami-fake-gpu-pod.yaml) should reach Running.
      PHASE=$(kubectl get pod hami-fake-gpu-pod -n default -o jsonpath='{.status.phase}' 2>/dev/null)
      [ "$PHASE" = "Running" ] || { echo "hami-fake-gpu-pod is not Running (phase: ${PHASE:-not found}) — apply course-1/manifests/hami-fake-gpu-pod.yaml"; exit 1; }
      echo "hami-fake-gpu-pod is Running ✓"

  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - verify_cluster_ready
      - verify_fake_gpu_operator_installed
      - verify_fake_gpus_present
      - verify_hami_scheduler_running
      - verify_gpu_pod_scheduled
    run: |
      export KUBECONFIG=$HOME/.kube/config
      echo "All HAMi architecture tasks complete ✓"
---
