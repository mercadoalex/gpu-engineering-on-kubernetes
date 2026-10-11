---
kind: lesson
title: 'Benchmark It: tokens/s, TTFT, TPOT'
description: |
  Run a load test against your vLLM deployment, capture tokens/s, time-to-first-token, and time-per-output-token, and interpret what each number means. You'll learn to measure inference performance like an operator.
name: lesson-benchmark-vllm
slug: lesson-benchmark-vllm
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - vllm
  - benchmark
  - ttft
  - tpot
  - inference
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
tasks:
  run_load_test:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for run_load_test"
      exit 1
  capture_tokens_per_sec:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for capture_tokens_per_sec"
      exit 1
  capture_ttft_tpot:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for capture_ttft_tpot"
      exit 1
  interpret_results:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for interpret_results"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - run_load_test
      - capture_tokens_per_sec
      - capture_ttft_tpot
      - interpret_results
    run: |
      echo "Lesson complete ✓"
---
