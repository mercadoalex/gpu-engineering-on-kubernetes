---
kind: unit
title: What's Actually Inside a GPU (and Why K8s Doesn't Care)
name: lesson-inside-a-gpu-unit-1
---

## Streaming Multiprocessors, VRAM, Tensor Cores — and the One Integer K8s Keeps

This lesson maps the real hardware inside a GPU onto the single opaque `nvidia.com/gpu` integer that Kubernetes tracks, so you can see exactly how much detail the scheduler throws away.

> 🚧 This lesson is scaffolded but not yet written. See SYLLABUS.md for the planned hands-on outcome.

::simple-task
---
:tasks: tasks
:name: inspect_nvidia_smi_sample
---
#active
TODO: describe what the student does for inspect_nvidia_smi_sample.

#completed
inspect_nvidia_smi_sample ✓
::

::simple-task
---
:tasks: tasks
:name: map_gpu_to_extended_resource
---
#active
TODO: describe what the student does for map_gpu_to_extended_resource.

#completed
map_gpu_to_extended_resource ✓
::

::simple-task
---
:tasks: tasks
:name: inspect_node_resource_model
---
#active
TODO: describe what the student does for inspect_node_resource_model.

#completed
inspect_node_resource_model ✓
::

## Now Prove It

::simple-task
---
:tasks: tasks
:name: verify_lesson_complete
---
#active
All 3 tasks are green — this lesson is complete.

#completed
Lesson complete. On to the next one! ✓
::
