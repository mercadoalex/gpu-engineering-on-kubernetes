---
kind: lesson
title: 'vLLM vs SGLang: A Head-to-Head on the Same GPU'
description: |
  Deploy SGLang, run the same benchmark you ran against vLLM, and build a side-by-side comparison table on the same GPU. You'll close the inference module with data, not opinions, on which server wins where.
name: lesson-vllm-vs-sglang
slug: lesson-vllm-vs-sglang
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - vllm
  - sglang
  - benchmark
  - inference
  - comparison
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
# challenges:   (commented out — no slug yet; FINAL LESSON ONLY)
#   TODO: add platform challenge slug once labctl content create assigns one
#   <platform-slug>: {}
tasks:
  deploy_sglang:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for deploy_sglang"
      exit 1
  run_same_benchmark:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for run_same_benchmark"
      exit 1
  build_comparison_table:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for build_comparison_table"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - deploy_sglang
      - run_same_benchmark
      - build_comparison_table
    run: |
      echo "Lesson complete ✓"
---
