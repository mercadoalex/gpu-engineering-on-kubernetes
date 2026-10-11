---
kind: lesson
title: Partition an A100 with MIG (Single vs Mixed Strategy)
description: |
  Enable MIG on an A100, create seven 1g.5gb instances, schedule a pod to one partition, and confirm isolation. You'll compare single and mixed MIG strategies and see fractional GPU sharing on real hardware.
name: lesson-mig-partition-a100
slug: lesson-mig-partition-a100
createdAt: 2026-10-04
updatedAt: 2026-10-04
categories:
  - kubernetes
tagz:
  - mig
  - a100
  - nvidia
  - gpu-operator
playground:
  name: gpu-engineering-on-kubernetes-62a4150c
# challenges:   (commented out — no slug yet; FINAL LESSON ONLY)
#   TODO: add platform challenge slug once labctl content create assigns one
#   <platform-slug>: {}
tasks:
  enable_mig:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for enable_mig"
      exit 1
  create_seven_1g5gb:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for create_seven_1g5gb"
      exit 1
  schedule_pod_to_partition:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for schedule_pod_to_partition"
      exit 1
  confirm_isolation:
    machine: dev-machine
    user: laborant
    run: |
      echo "TODO: implement check for confirm_isolation"
      exit 1
  verify_lesson_complete:
    machine: dev-machine
    user: laborant
    needs:
      - enable_mig
      - create_seven_1g5gb
      - schedule_pod_to_partition
      - confirm_isolation
    run: |
      echo "Lesson complete ✓"
---
