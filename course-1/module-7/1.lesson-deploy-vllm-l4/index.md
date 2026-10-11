---
kind: lesson
title: Deploy vLLM on a Single L4 GPU
description: |
  Create a vLLM Deployment and Service, load a small model, and hit the OpenAI-compatible /v1 endpoint. You'll serve your first real LLM from a single L4 GPU.
name: lesson-deploy-vllm-l4
slug: lesson-deploy-vllm-l4
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - vllm
  - l4
  - inference
  - openai-api
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
tasks:
  deploy_vllm:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for deploy_vllm"
      exit 1
  create_service:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for create_service"
      exit 1
  load_small_model:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for load_small_model"
      exit 1
  hit_v1_endpoint:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for hit_v1_endpoint"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - deploy_vllm
      - create_service
      - load_small_model
      - hit_v1_endpoint
    run: |
      echo "Lesson complete ✓"
---
