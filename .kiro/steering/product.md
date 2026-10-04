# Product — What We're Building and Why

## Goal

A self-paced, auto-graded training lab that teaches GPU-aware Kubernetes
scheduling, observability, and inference serving. Target: DevOps/SRE engineers
moving into AI infrastructure roles. Budget: < $10 per student per session.

## Three-Course Sequence

| Course | Title | Focus |
|--------|-------|-------|
| 1 | GPU-Aware Kubernetes: Scheduling, Observability & Inference | Single-GPU scheduling, DCGM, vLLM on 1 GPU |
| 2 | Building Production LLM Applications: RAG, Serving & Observability | Application layer above vLLM (LangChain, LangGraph, Langfuse) |
| 3 | Multi-Node GPU Clusters: Networking, Distributed Training & FinOps | Multi-node, NCCL, FSDP, TP/PP, FinOps |

---

## Course 1 — GPU-Aware Kubernetes

**Author:** Alejandro Mercado
**Audience:** DevOps/SRE with CKA-level K8s; no GPU/CUDA background required.
**Prerequisites:** K8s fundamentals, basic Linux, 16 GB RAM + Docker laptop.

### Learning Objectives

1. Simulate and reason about GPU scheduling (KWOK, ghostgpu, Kueue, Volcano).
2. Design multi-tenant GPU quota policies (ClusterQueues, cohorts, borrowing, fair-share).
3. Configure gang scheduling for distributed training workloads.
4. Author GPU node pool configs (Karpenter / GKE CA) with scale-to-zero and spot controls.
5. Deploy and operate NVIDIA GPU Operator (driver, toolkit, device plugin, DCGM, MIG manager).
6. Build DCGM Grafana dashboards and alerting rules (XID, thermal, VRAM).
7. Deploy and benchmark vLLM (tokens/s, TTFT, TPOT); compare with SGLang.
8. Partition a GPU with MIG and schedule workloads to individual partitions.
9. Explain GPU interconnect topology (NVLink, PCIe, RDMA) and multi-node impact.
10. Operate a self-service GPU platform with cost guardrails.

### Module Structure

| # | Module | Tier | Duration |
|---|--------|------|----------|
| 1 | GPU Fundamentals for K8s Engineers | 1 | 2 hr |
| 2 | Simulating GPU Clusters | 1 | 3 hr |
| 3 | GPU-Aware Scheduling | 1 | 4 hr |
| 4 | GPU Node Lifecycle & Autoscaling | 1 | 2 hr |
| 5 | GPU Observability with DCGM | 1→2 | 3 hr |
| 6 | NVIDIA GPU Operator in Production | 2 | 2 hr |
| 7 | LLM Inference Serving | 2 | 3 hr |
| 8 | Capstone: Multi-Tenant GPU Platform | 1+2 | 4 hr |

### Assessment

| Type | Weight |
|------|--------|
| Auto-graded tasks (iximiuz) | 60% |
| Capstone challenge | 30% |
| GPU validation report | 10% |

**Price:** $50–100 one-time. **Margin:** ~$35–85/student.

### Out of Scope (Course 1)

- CUDA programming / kernel development
- Model training (PyTorch, distributed frameworks)
- Multi-node GPU networking (explained conceptually, not hands-on)
- GPU security hardening (CKS-level)
- Production DR/HA for GPU clusters

---

## Course 2 — Production LLM Applications

**Prerequisites:** Course 1 (or: can deploy vLLM on K8s). Python 3.11+, async/FastAPI.

### Learning Objectives

1. Build a production RAG pipeline with LangChain LCEL connected to vLLM.
2. Design a self-healing RAG graph with LangGraph (retrieval validation, retry, fallback).
3. Instrument with Langfuse (`@observe`, nested traces, token/cost capture).
4. Implement LLM-as-a-judge evaluation and dataset-based regression testing.
5. Use Langfuse prompt management (versioned prompts, A/B, trace linking).
6. Deploy the RAG service as a FastAPI app on K8s with proper resource limits.
7. Correlate Langfuse app metrics with DCGM/Grafana infrastructure metrics.
8. Operate the full stack end-to-end with observability at every layer.

### Key Design Principle

Course 2 Module 1 starts by pointing `ChatOpenAI` at the vLLM endpoint the
student already deployed in Course 1 Module 7. Same GPU. Same Grafana. Only
new thing is the Python code running above it.

**Incremental infra cost:** ~$0 (runs on existing Course 1 infrastructure).
**Price:** $75–150 one-time.

---

## Course 3 — Multi-Node GPU Clusters

**Prerequisites:** Courses 1+2 (or equivalent single-node GPU K8s experience).

### Learning Objectives

1. Explain GPU interconnect topology (NVLink, PCIe, InfiniBand/RoCE, GPUDirect RDMA).
2. Configure and debug NCCL for multi-node workloads.
3. Deploy distributed inference with vLLM TP+PP across multiple nodes via Ray.
4. Run distributed training with PyTorch FSDP / DeepSpeed ZeRO.
5. Design a GPU cluster network (fat-tree, IB NDR400, RoCE, Ethernet tradeoffs).
6. Implement GPU FinOps (cost-per-token, MIG fractional sharing, KEDA autoscaling).
7. Operate multi-node GPU cluster (Kueue+Volcano, topology-aware placement, failure recovery).
8. Correlate network metrics with GPU metrics (NCCL bandwidth, DCGM utilization).

**Budget per student (4-hr multi-node session):** ~$8–12 shared across 4–6 students.
**This is where the compensation premium is**: engineers who understand GPU
interconnect topology and distributed systems at depth remain scarce.

---

## Certification Alignment

| Cert | Course |
|------|--------|
| CKA (baseline) | C1 (required prerequisite) |
| NCP-AII (NVIDIA AI Infrastructure) | C1 |
| NCP-AIO (NVIDIA AI Operations) | C1 |
| NCP-AIN (NVIDIA AI Networking) | C3 (Modules 1, 2, 5) |
| FinOps AI Fundamentals | C3 (Module 6) |
| CKS (optional) | Not required for AI clusters |
