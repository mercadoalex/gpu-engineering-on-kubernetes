---
kind: course
title: GPU Engineering on Kubernetes
description: |-
  A hands-on training for DevOps/SRE engineers who need to operate GPU clusters for AI/ML workloads. Learn GPU scheduling, quota management, observability, and LLM inference — by doing, not by reading slides. The first modules run entirely in local simulation with KWOK, so no GPU hardware is required to start.
categories:
- kubernetes
- observability
tagz:
- gpu
- kueue
- kwok
- vllm
- nvidia
createdAt: 2026-10-04
updatedAt: 2026-10-04
cover: __static__/cover.png
---

## What this course is

GPUs are the most expensive, most contended resource in a modern Kubernetes cluster — and the one Kubernetes understands the least. This course teaches you to operate them like an engineer, not a tourist: schedule them fairly, quota them across teams, watch them for failure, and serve real LLM inference on them.

You learn by doing. Every lesson puts your hands on a terminal in the first five minutes. You'll install things, schedule workloads, and deliberately break them so you understand *why* they break — because that's the knowledge that matters at 3 a.m. when a training job is stuck Pending.

## What you'll be able to do

- Explain how Kubernetes models a GPU — and why the scheduler knows nothing about the hardware
- Simulate thousand-node GPU clusters on your laptop with KWOK — no hardware, no cost
- Enforce multi-tenant GPU quotas with Kueue — cohorts, borrowing, and preemption
- Configure gang scheduling with Volcano and explain why distributed training deadlocks without it
- Author GPU node pools that scale to zero and keep monthly cost under control
- Build Grafana dashboards and alerts from DCGM metrics for thermal, XID, and VRAM failures
- Install the full NVIDIA GPU Operator stack on a real GCP GPU node
- Partition a GPU with MIG and schedule workloads to individual slices
- Deploy and benchmark a vLLM inference server — tokens/s, TTFT, TPOT

## How the course is structured

**Two tiers, one continuous journey.**

- **Tier 1 — Local simulation (free, no GPU):** Modules 1–5 run entirely in a KWOK virtual cluster inside your browser lab. ~2 GB RAM. You can complete 80% of the course without spending a cent or touching real hardware.
- **Tier 2 — Real GPU on GCP:** Modules 6–8 connect to a GCP GPU node (NVIDIA L4 / A100) to install the GPU Operator, partition with MIG, and serve real inference. Cost guardrail: under $10 per session.

| # | Module | Tier |
|---|--------|------|
| 1 | GPU Fundamentals for K8s Engineers | Local |
| 2 | Simulating GPU Clusters with KWOK | Local |
| 3 | GPU-Aware Scheduling (Kueue + Volcano) | Local |
| 4 | GPU Node Lifecycle & Autoscaling | Local |
| 5 | GPU Observability with DCGM | Local |
| 6 | NVIDIA GPU Operator in Production | GCP GPU |
| 7 | LLM Inference Serving with vLLM | GCP GPU |
| 8 | Capstone: Multi-Tenant GPU Platform | Both |

## Who this is for

DevOps and SRE engineers moving into AI infrastructure roles. If you're comfortable with Kubernetes at a CKA level and want the GPU-specific skills that are scarce and well-paid, this is for you.

## Prerequisites

- CKA-level Kubernetes knowledge (pods, deployments, services, RBAC)
- Basic Linux comfort (systemd, bash, curl)
- No GPU, CUDA, or ML experience required — Module 1 starts from zero

## Lab environment

Every lesson runs in a live browser-based environment — no local install needed. The Tier 1 lab ships with `kind`, `kwokctl`, `kubectl`, `helm`, and `jq` pre-configured; your KWOK cluster is created automatically when the playground starts.
