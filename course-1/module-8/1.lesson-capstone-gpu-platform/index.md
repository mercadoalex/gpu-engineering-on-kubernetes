---
kind: lesson
title: Run a 3-Team GPU Platform with Quota, Gang Scheduling, Observability, and Cost Guardrails
description: |
  Combine everything into one scenario: three teams running training, inference, and data-prep workloads under Kueue cohorts, Volcano gang scheduling, DCGM dashboards, and autoscaler cost limits. You're evaluated on scheduling correctness and cost efficiency.
name: lesson-capstone-gpu-platform
slug: lesson-capstone-gpu-platform
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - capstone
  - kueue
  - volcano
  - dcgm
  - finops
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
# challenges:   (commented out — no slug yet; FINAL LESSON ONLY)
#   TODO: add platform challenge slug once labctl content create assigns one
#   <platform-slug>: {}
tasks:
  setup_three_teams:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for setup_three_teams"
      exit 1
  configure_cohorts_and_queues:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for configure_cohorts_and_queues"
      exit 1
  submit_training_gang:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for submit_training_gang"
      exit 1
  submit_inference_and_dataprep:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for submit_inference_and_dataprep"
      exit 1
  verify_scheduling_correctness:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for verify_scheduling_correctness"
      exit 1
  verify_cost_guardrails:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for verify_cost_guardrails"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - setup_three_teams
      - configure_cohorts_and_queues
      - submit_training_gang
      - submit_inference_and_dataprep
      - verify_scheduling_correctness
      - verify_cost_guardrails
    run: |
      echo "Lesson complete ✓"
---
