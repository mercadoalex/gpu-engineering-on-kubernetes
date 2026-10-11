---
kind: lesson
title: 'PagedAttention and Continuous Batching: Why vLLM Is Fast'
description: |
  Toggle vLLM's batching configuration, measure the throughput delta, and correlate it with GPU utilization in Grafana. You'll understand why PagedAttention and continuous batching make vLLM fast.
name: lesson-pagedattention-batching
slug: lesson-pagedattention-batching
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - vllm
  - pagedattention
  - continuous-batching
  - throughput
  - inference
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
tasks:
  toggle_batching_config:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for toggle_batching_config"
      exit 1
  measure_throughput_delta:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for measure_throughput_delta"
      exit 1
  correlate_with_gpu_util:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for correlate_with_gpu_util"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - toggle_batching_config
      - measure_throughput_delta
      - correlate_with_gpu_util
    run: |
      echo "Lesson complete ✓"
---
