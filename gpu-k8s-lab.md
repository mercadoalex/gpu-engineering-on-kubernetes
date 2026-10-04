## Training Definition

### Title
**GPU-Aware Kubernetes: Scheduling, Observability & Inference**

### Author 
Alejandro Mercado 

### Target Audience
DevOps/SRE engineers with working K8s experience (CKA-level) who need to
operate GPU clusters for AI/ML workloads. No prior GPU or CUDA knowledge required.

### Prerequisites
- K8s fundamentals (pods, deployments, services, RBAC)
- Basic Linux (SSH, bash, networking)
- A laptop with 16 GB RAM + Docker (for Tier 1)

### Learning Objectives

By the end of this course, the student will be able to:

1. **Simulate and reason about GPU scheduling** on Kubernetes using KWOK,
   ghostgpu, Kueue, and Volcano — without real hardware.
2. **Design multi-tenant GPU quota policies** (ClusterQueues, cohorts,
   borrowing, fair-share) that mirror production patterns.
3. **Configure gang scheduling** for distributed training workloads and
   explain why it's non-optional for multi-GPU jobs.
4. **Author GPU node pool configurations** (Karpenter for AWS, GKE CA for
   GCP) with scale-to-zero and spot-instance cost controls.
5. **Deploy and operate the NVIDIA GPU Operator stack** (driver, toolkit,
   device plugin, DCGM exporter) on a real cloud GPU node.
6. **Build GPU observability dashboards** in Grafana from DCGM metrics and
   configure alerting rules for critical failure modes (XID errors, thermal
   throttling, VRAM exhaustion).
7. **Deploy and benchmark an LLM inference server** (vLLM) on a single GPU,
   measure tokens/s, TTFT, and TPOT, and compare against SGLang.
8. **Partition a GPU with MIG** and schedule workloads to individual
   partitions — understanding the isolation guarantees vs. time-slicing.
9. **Explain GPU interconnect topology** (NVLink domains, PCIe, RDMA) and
   how it affects multi-node training performance.
10. **Operate a self-service GPU platform** with cost guardrails (Kueue
    quotas, pod deadlines, CA limits) suitable for a multi-tenant environment.

### Course Topics (Module Structure)

| # | Module | Topics | Tier | Duration |
|---|--------|--------|------|----------|
| 1 | **GPU Fundamentals for K8s Engineers** | GPU architecture (SMs, VRAM, tensor cores), `nvidia-smi`, extended resources vs. DRA, MIG vs. time-slicing vs. vGPU, NVLink/PCIe topology | 1 | 2 hr |
| 2 | **Simulating GPU Clusters** | KWOK + `kwokctl`, ghostgpu / fake-gpu-operator, injecting GPU capacity, DRA ResourceSlices, verifying node allocatable | 1 | 3 hr |
| 3 | **GPU-Aware Scheduling** | Kueue (ClusterQueue, LocalQueue, cohorts, borrowing, preemption), Volcano (gang scheduling, DRF, queues), kube-scheduler limitations, topology-aware placement | 1 | 4 hr |
| 4 | **GPU Node Lifecycle & Autoscaling** | Karpenter NodePool (AWS), GKE Cluster Autoscaler (GCP), spot instances, scale-to-zero, consolidation, cost patterns | 1 | 2 hr |
| 5 | **GPU Observability with DCGM** | DCGM architecture, dcgm-exporter, Prometheus scrape config, Grafana dashboard (util, VRAM, temp, power, XID), alerting rules, MIG-level metrics | 1→2 | 3 hr |
| 6 | **NVIDIA GPU Operator in Production** | GPU Operator architecture (driver, toolkit, device plugin, DCGM, MIG manager), Helm install on GKE, MIG strategy (single vs. mixed), verifying node labels | 2 | 2 hr |
| 7 | **LLM Inference Serving** | vLLM (PagedAttention, continuous batching, OpenAI-compatible API), deployment on K8s, benchmarking (tokens/s, TTFT, TPOT), SGLang comparison, TensorRT-LLM overview | 2 | 3 hr |
| 8 | **Capstone: Multi-Tenant GPU Platform** | 3 teams, 3 workload types, full scheduling + quota + observability + cost guardrails, self-service GPU access pattern, Kueue + CA + MIG combined | 1+2 | 4 hr |

### Out of Scope (explicitly)

- CUDA programming / kernel development
- Model training (PyTorch, distributed training frameworks)
- Multi-node GPU networking (InfiniBand, NCCL tuning) — *explained conceptually, not hands-on*
- GPU security hardening (CKS-level)
- Production DR/HA for GPU clusters

### Assessment Model

| Type | Weight | Description |
|------|--------|-------------|
| Auto-graded tasks (iximiuz) | 60% | Each module has 2–4 tasks with pass/fail scripts |
| Capstone challenge | 30% | Multi-tenant scenario, evaluated on scheduling correctness + cost efficiency |
| GPU validation report | 10% | Student documents vLLM benchmark results + DCGM dashboard screenshots |

### Success Criteria (what "done" looks like)

- Student can explain why a 4-GPU training job deadlocks without gang scheduling
- Student can configure a Kueue cohort where Team A borrows from Team B
- Student can read a Grafana DCGM panel and identify thermal throttling
- Student can deploy vLLM on a MIG partition and report tokens/s
- Student can size a GCP node pool (CA min/max) to keep monthly GPU cost < $50   

# GPU-Aware Kubernetes Training Lab — Project Context

## Goal

Build a self-paced, auto-graded training lab that teaches GPU-aware Kubernetes
scheduling, observability, and inference serving. Target audience: DevOps/SRE
engineers moving into AI infrastructure roles. Budget: < $10 per student per session.

## Architecture (Two Tiers)

### Tier 1 — Local Simulation (free, no GPU)
- **Substrate:** KWOK (Kubernetes WithOut Kubelet) via `kwokctl` on `kind`
- **GPU simulation:** ghostgpu or Run:ai fake-gpu-operator (injected `nvidia.com/gpu` + DRA ResourceSlices)
- **Scheduling:** Kueue (quota, cohorts, borrowing) + Volcano (gang, DRF, queues)
- **Autoscaling:** Karpenter NodePool (authoring/validation only, no real provisioning)
- **Observability:** Prometheus + Grafana with synthetic DCGM metrics
- **RAM footprint:** ~2 GB total (runs on any 16 GB laptop)

### Tier 2 — Cloud GPU Validation (~$3–8 per session)
- **Provider:** GCP `g2-standard-4` (1× L4 24 GB, Ada, FP8) in `us-west1`
- **Why GCP over Azure/AWS:** L4 is newer gen than A10/A10G; MIG is a single CLI
  flag (`--gpu-partition-size`); smoothest GKE + GPU Operator path; $0.71/hr
- **Multi-student:** 1× `a2-highgpu-1g` (A100 40 GB) partitioned into 7× MIG `1g.5gb`
  → hardware-isolated GPU per student at ~$0.16/student/hr
- **Stack:** NVIDIA GPU Operator (driver, toolkit, device plugin, DCGM exporter)
- **Inference:** vLLM (primary), SGLang (comparison)
- **Metrics:** Real DCGM → Prometheus → Grafana (GPU util, VRAM, temp, power, XID errors)

## Key Technical Decisions

| Decision | Choice | Rationale |
|---|---|---|
| GPU simulation | KWOK + ghostgpu | Free, scales to 1000s of nodes, no hardware |
| Gang scheduling | Volcano | Native gang + DRF fair-share |
| Quota management | Kueue | CNCF, DRA-aware, cohort/borrowing |
| Autoscaler (GCP) | GKE Cluster Autoscaler | Karpenter has no official GKE provider |
| GPU sharing (multi-student) | MIG (hardware) | True isolation, production-relevant skill |
| Cloud provider | GCP `us-west1` | Best GPU gen + MIG CLI + smoothest setup |
| Inference engine | vLLM | PagedAttention, continuous batching, OpenAI-compatible API |
| Lab platform | iximiuz Labs (delivery) + GCP (GPU) | Browser-based, auto-graded, no student setup |
| Monetization | Own billing (Gumroad/Stripe) + iximiuz as delivery | iximiuz Independent Authors program is pilot-only (4 hand-picked authors), not self-serve |

## iximiuz Labs Integration

- **Playground:** Custom `flexbox` or `k8s-omni`-based multi-VM environment
- **Tutorial:** Markdown + embedded shell steps + auto-graded `<task>` blocks
- **ILT (instructor-led):** For paid training cohorts — enrollment, premium seats, progress tracking
- **Self-paced:** Published tutorial with access control (`canStart` role)
- **GCP connection:** Students `kubectl` from iximiuz VM → GCP API server over public HTTPS.
  Auth via `gke-gcloud-auth-plugin` exec credential (short-lived OAuth2 token from GCP SA key
  baked into VM as ADC). No VPC peering, no tunnel.
- **Cost guardrails (self-paced):** Kueue `nominalQuota: 1` GPU/student,
  `activeDeadlineSeconds: 7200`, CA `minSize: 0, maxSize: 3`, spot instances,
  GCP billing alert at $30/mo.

## GPU Observability (DCGM)

Critical metrics for dashboards/alerts:
- `DCGM_FI_DEV_GPU_UTIL` — alert < 30% for 15 min
- `DCGM_FI_DEV_FB_USED` — alert > 90%
- `DCGM_FI_DEV_GPU_TEMP` — alert > 83°C
- `DCGM_FI_DEV_XID_ERRORS` — alert on any non-zero
- `DCGM_FI_DEV_POWER_USAGE` — alert approaching TDP

## Lab Phases (Student Journey)

1. **Verify cluster** (3 nodes Ready, GPU capacity visible)
2. **Install ghostgpu** → nodes report `nvidia.com/gpu`
3. **Configure Kueue** → ClusterQueue, LocalQueue, cohort, borrowing
4. **Gang scheduling with Volcano** → `minAvailable`, DRF fair-share
5. **Karpenter NodePool** → author YAML, validate with `--dry-run=server`
6. **Observability** → wire Prometheus + Grafana, DCGM panels
7. **Capstone** → 3 teams, 3 workloads (training gang, inference, data prep), observe scheduling
8. **GPU Validation (GCP)** → deploy vLLM, benchmark tokens/s, compare with SGLang

## Budget Summary

| Item | Cost |
|---|---|
| iximiuz Labs (Tinkerer/creator plan) | ~$25–50/mo |
| GCP GPU (15 students × 2 hrs/week × spot) | ~$42/mo |
| **Total infra** | **~$70/mo** |
| Course price (student pays) | $50–100 one-time |
| Your margin | ~$35–85/student |

## Constraints

- No GPU access at work — all simulation is KWOK-based
- Instructor is in Mexico (CDMX) — nearest GPU region is US West (~25 ms)
- Limited budget — cloud session is 4 hrs max, scale-to-zero when idle
- iximiuz Labs does NOT support GPU passthrough (Firecracker microVMs)
- Karpenter has no GCP provider — use GKE CA instead
- iximiuz Independent Authors monetization is NOT self-serve (pilot with 4 authors)

## Reference Certifications (for course alignment)

- CKA (baseline, de facto required)
- NCP-AII (NVIDIA AI Infrastructure — the differentiator)
- NCP-AIO (NVIDIA AI Operations)
- CKS (optional, security — not mandatory for AI clusters)   


### ROADMAO -  Three -Course Sequence (to be implemented later)

## Course 2 Definition

### Title
**Building Production LLM Applications: RAG, Serving & Observability**

### Relationship to Course 1
Course 1 (GPU-Aware Kubernetes) covers the **infrastructure + serving boundary**:
scheduling, quota, DCGM, GPU Operator, vLLM deployment.
This course covers the **application layer above vLLM**: building a RAG pipeline
with LangChain, instrumenting it with Langfuse, and operating it as a production
service. Students reuse the same GCP vLLM endpoint from Course 1.

### Target Audience
Engineers who completed Course 1 (or have equivalent K8s + vLLM experience)
and now need to build, deploy, and monitor LLM applications on top of their
own GPU infrastructure. No prior LangChain or Langfuse experience required.

### Prerequisites
- Course 1 completed (or: can deploy vLLM on K8s, understand DCGM metrics)
- Python 3.11+ (comfortable with async, type hints, FastAPI)
- Basic understanding of embeddings and vector similarity

### Learning Objectives

By the end of this course, the student will be able to:

1. **Build a production RAG pipeline** with LangChain (LCEL) — document
   ingestion, chunking, embedding, vector store, retrieval, and generation —
   wired to a self-hosted vLLM endpoint via `ChatOpenAI(base_url=...)`.
2. **Design a self-healing RAG graph** with LangGraph — retrieval validation,
   hallucination grading, conditional retry, and graceful fallback.
3. **Instrument the full pipeline with Langfuse** — `@observe` decorator,
   nested traces (retrieval → generation → verification), token/cost capture,
   and session grouping for multi-turn conversations.
4. **Implement LLM-as-a-judge evaluation** with Langfuse — automated scoring
   for grounding, relevance, and hallucination; dataset-based regression
   testing before and after prompt/model changes.
5. **Use Langfuse prompt management** — versioned prompts stored outside the
   codebase, A/B comparison, and linking prompt versions to production traces.
6. **Deploy the RAG service as a FastAPI application** on Kubernetes —
   health checks, rate limiting, structured logging, and resource limits
   that respect the GPU constraints from Course 1.
7. **Correlate application-layer metrics (Langfuse) with infrastructure
   metrics (DCGM/Grafana)** — e.g., p99 latency spike in Langfuse traces
   correlates with GPU thermal throttling in DCGM.
8. **Operate the full stack end-to-end** — from a user query through
   LangGraph → LangChain → vLLM → GPU, with observability at every layer.

### Course Topics (Module Structure)

| # | Module | Topics | Tier | Duration |
|---|--------|--------|------|----------|
| 1 | **LLM Application Architecture** | Where LangChain/LangGraph/Langfuse sit in the stack (above vLLM), OpenAI-compatible API as the contract, `ChatOpenAI(base_url=...)` integration pattern, streaming, version pinning (vLLM 0.28.x + langchain-openai 1.6.x) | 1 | 2 hr |
| 2 | **RAG Pipeline with LangChain** | Document loading (PDF, Markdown, HTML), intelligent chunking (semantic vs. fixed-size), embedding models (via vLLM `/v1/embeddings` or separate TEI server), vector stores (Chroma, Qdrant, pgvector), retrieval strategies (top-k, MMR, hybrid BM25+dense), LCEL chain composition | 1 | 4 hr |
| 3 | **Self-Healing RAG with LangGraph** | StateGraph definition, retrieval quality assessment node, hallucination grader node, conditional edges (retry vs. fallback), `max_iterations` caps, checkpointing, comparison: LCEL chain vs. LangGraph for the same pipeline | 1 | 3 hr |
| 4 | **Langfuse Observability** | Self-hosted Langfuse on K8s (Docker Compose for local), `@observe` decorator, nested trace hierarchy, sessions for multi-turn, user attribution, token/cost tracking (custom model pricing for self-hosted vLLM), OpenTelemetry integration, LangChain callback handler | 1→2 | 3 hr |
| 5 | **Evaluation & Prompt Management** | LLM-as-a-judge (grounding, relevance, hallucination scores), datasets for regression testing, prompt management (versioning, A/B, linking to traces), scoring API (numeric, categorical, boolean), CI/CD integration (run evals on every model/prompt change) | 1→2 | 3 hr |
| 6 | **Production Deployment** | FastAPI service wrapping the LangGraph pipeline, Dockerfile, K8s Deployment + Service + HPA, resource limits (CPU for the app, GPU for vLLM), rate limiting, structured logging, health/readiness probes, connecting Langfuse → vLLM → GPU metrics in a unified dashboard | 2 | 3 hr |
| 7 | **End-to-End Correlation & Capstone** | Full request lifecycle traced: user query → FastAPI → LangGraph → LangChain → vLLM → GPU (DCGM), Langfuse trace shows every span, Grafana shows GPU util/VRAM/temp for the same request, student identifies a performance bottleneck and fixes it | 1+2 | 4 hr |

### Technology Stack

| Layer | Technology | Version (2026) |
|-------|-----------|----------------|
| Orchestration | LangGraph | 1.1+ |
| Pipeline composition | LangChain (LCEL) | 1.0+ |
| LLM client | `langchain-openai` (ChatOpenAI) | 1.6.x |
| Inference server | vLLM (OpenAI-compatible `/v1`) | 0.28.x |
| Vector store | Chroma (local) / Qdrant (production) | latest |
| Observability | Langfuse (self-hosted) | latest (MIT, OTel-native) |
| API framework | FastAPI + uvicorn | latest |
| Eval | Langfuse LLM-as-a-judge + datasets | built-in |
| GPU infra | GCP + NVIDIA GPU Operator + DCGM | (from Course 1) |

### Infrastructure Reuse from Course 1

| Component | From Course 1 | Used in Course 2 for |
|-----------|--------------|---------------------|
| GCP `g2-standard-4` (L4) or `a2-highgpu-1g` (A100 MIG) | vLLM serving | Same — vLLM endpoint is the LLM backend |
| NVIDIA GPU Operator + DCGM Exporter | GPU telemetry | Correlate app latency with GPU health |
| Prometheus + Grafana | DCGM dashboards | Add Langfuse metrics (p99 latency, cost/trace) alongside DCGM |
| Kueue / Volcano | GPU scheduling | (Not directly used, but students understand why their vLLM pod got a GPU) |
| iximiuz playground | Scheduling lab | Same playground + Python venv for LangChain/Langfuse |

### Out of Scope (explicitly)

- Fine-tuning / RLHF / LoRA
- Multi-node distributed inference (tensor/pipeline parallelism)
- MCP (Model Context Protocol) / tool-calling agents — *mentioned, not built*
- LangSmith (LangChain's proprietary observability) — *Langfuse is the OSS path*
- RAG evaluation frameworks beyond Langfuse (RAGAS, TruLens) — *mentioned as alternatives*
- Frontend / UI development (Streamlit, Gradio) — *FastAPI + curl is sufficient*

### Assessment Model

| Type | Weight | Description |
|------|--------|-------------|
| Auto-graded tasks (iximiuz) | 50% | Each module: verify pipeline runs, traces appear in Langfuse, evals pass |
| RAG quality benchmark | 25% | Student's pipeline must achieve ≥ 80% grounding score on a provided 50-question dataset |
| Capstone: full-stack correlation | 25% | Student identifies a GPU-level bottleneck (e.g., VRAM pressure causing p99 spike) using Langfuse + DCGM together, documents the fix |

### Success Criteria (what "done" looks like)

- Student can point `ChatOpenAI` at their vLLM endpoint and stream tokens
- Student's LangGraph RAG pipeline retries on low-quality retrieval and
  flags hallucinated answers
- Every request in Langfuse shows a nested trace: `retrieve → assess →
  generate → verify` with per-step latency and token count
- LLM-as-a-judge scores are computed automatically and visible in the
  Langfuse dashboard
- A prompt change in Langfuse prompt management is reflected in production
  traces without a code deploy
- Student can look at a Langfuse p99 spike and find the corresponding
  DCGM thermal throttling event in Grafana

### Budget (incremental over Course 1)

| Item | Cost |
|------|------|
| Langfuse self-hosted (Postgres + ClickHouse + Redis + API) | Runs on CPU nodes, ~$0 (iximiuz playground or same GCP node) |
| vLLM GPU (shared with Course 1) | No additional cost — same L4/A100 |
| Vector store (Chroma in-memory) | $0 |
| **Total incremental infra** | **~$0** (all runs on existing infrastructure) |
| Course price (student pays) | $75–150 one-time |   


### Key design principle:
Course 2's Module 1 starts by pointing ChatOpenAI at the vLLM endpoint the student already deployed in Course 1's Module 7. The GPU is the same. The Grafana dashboard is the same. The only new thing is the Python code running above it. This makes the transition seamless and reinforces that the application layer is just another client of the infrastructure they now operate.

## Course 3 Definition

### Title
**Multi-Node GPU Clusters: Networking, Distributed Training & FinOps**

### Relationship to Courses 1 & 2
- Course 1: Single-GPU scheduling, DCGM, vLLM on 1 GPU
- Course 2: Application layer (RAG, Langfuse) on top of that vLLM
- **Course 3: What happens when the model doesn't fit on one GPU or one node.**
  Students move from single-GPU vLLM to multi-node tensor/pipeline parallelism,
  learn the network fabric that makes it work, and master the cost discipline
  that keeps a multi-node cluster from destroying the budget.

### Target Audience
Engineers who completed Courses 1+2 (or have equivalent single-node GPU K8s
experience) and now need to operate or design multi-node GPU clusters for
training and large-model inference.

### Prerequisites
- Course 1 + 2 completed (or: can deploy vLLM on K8s, understand DCGM,
  can build a RAG pipeline)
- Basic Linux networking (TCP/IP, MTU, bonding)
- Python (for running distributed training scripts)

### Learning Objectives

By the end of this course, the student will be able to:

1. **Explain GPU interconnect topology** — NVLink (intra-node), PCIe,
   InfiniBand/RoCE (inter-node), GPUDirect RDMA — and how topology affects
   collective communication performance.
2. **Configure and debug NCCL** for multi-node workloads — transport selection
   (P2P, SHM, NET/IB), `NCCL_IB_HCA`, `NCCL_NET_GDR_LEVEL`, `NCCL_SOCKET_IFNAME`,
   topology dump, and interpreting `NCCL_DEBUG=INFO` output.
3. **Deploy distributed inference** with vLLM using tensor parallelism (TP)
   and pipeline parallelism (PP) across multiple nodes via Ray, and size the
   parallelism strategy for a given model and cluster.
4. **Run distributed training** with PyTorch FSDP / DeepSpeed ZeRO on a
   multi-GPU cluster — understanding sharding strategies, gradient
   communication patterns, and checkpointing.
5. **Design a GPU cluster network** — fat-tree topology, non-blocking fabric,
   InfiniBand NDR400 vs. RoCE vs. plain Ethernet tradeoffs, and when each
   is appropriate.
6. **Implement GPU FinOps** — measure cost-per-token, identify the 5%
   utilization problem, configure bin-packing, spot orchestration,
   MIG-based fractional sharing, and autoscaling tied to GPU queue depth
   (not CPU/memory).
7. **Operate a multi-node GPU cluster** with Kueue + Volcano gang scheduling
   for distributed jobs, topology-aware placement (NVLink domains), and
   failure recovery (NCCL timeout, node eviction, checkpoint resume).
8. **Correlate network metrics with GPU metrics** — NCCL all-reduce bandwidth
   vs. DCGM GPU utilization, fabric port CRC errors, link flap detection,
   and their impact on training throughput.

### Course Topics (Module Structure)

| # | Module | Topics | Tier | Duration |
|---|--------|--------|------|----------|
| 1 | **GPU Interconnect & Network Topology** | NVLink/PCIe/InfiniBand/RoCE, GPUDirect RDMA, fat-tree topology, non-blocking fabric, `nvidia-smi topo -m`, `ibstat`, `ib_read_bw`, when Ethernet is "good enough" vs. when you need IB | 1 | 3 hr |
| 2 | **NCCL Deep Dive** | Transport selection (P2P/CUMEM, SHM, NET/IB/GDRDMA), env vars (`NCCL_IB_HCA`, `NCCL_NET_GDR_LEVEL`, `NCCL_SOCKET_IFNAME`, `NCCL_TIMEOUT`), topology dump, `all_reduce_perf` benchmark, interpreting NCCL INFO logs, debugging timeouts | 1→2 | 4 hr |
| 3 | **Distributed Inference (Multi-Node vLLM)** | Tensor parallelism (intra-node, NVLink), pipeline parallelism (inter-node), combined TP+PP (e.g., 405B on 2×8 H200), Ray for multi-node orchestration, StatefulSet deployment on K8s, RDMA device plugin, `/dev/shm` sizing, model caching via PVC | 2 | 4 hr |
| 4 | **Distributed Training Fundamentals** | PyTorch DDP vs. FSDP vs. DeepSpeed ZeRO (stage 1/2/3), gradient communication patterns (all-reduce, reduce-scatter, all-gather), checkpointing frequency, failure recovery, PyTorchJob / Kubeflow on K8s, gang scheduling for training (Volcano `minAvailable`) | 2 | 4 hr |
| 5 | **GPU Cluster Network Design** | Fat-tree topology (leaf/spine), InfiniBand NDR400 (400 Gb/s) vs. RoCE (200-400 Gb/s) vs. Ethernet (100 Gb/s), bandwidth calculations for all-reduce, hot-spot analysis, when to use SHARP/InfiniBand switch offload, storage plane separation (parallel filesystem vs. compute fabric) | 1 | 3 hr |
| 6 | **GPU FinOps & Cost Optimization** | The 5% utilization problem (Cast AI 2026), cost-per-token as the unit metric, FOCUS 1.3 (cost allocation for shared GPUs), bin-packing, MIG fractional sharing, spot orchestration with checkpointing, KEDA autoscaling on GPU queue depth, OpenCost/Kubecost for GPU cost visibility, reserved vs. spot vs. on-demand mix, self-host vs. API decision framework | 1→2 | 3 hr |
| 7 | **Production Multi-Node Operations** | Topology-aware scheduling (NVLink domain placement), NCCL failure modes (timeout, link flap, CRC errors), node eviction + checkpoint resume, capacity planning (scaling in multiples of 8), monitoring (NCCL exporter → Prometheus, fabric port health), DR/HA for GPU clusters | 2 | 3 hr |
| 8 | **Capstone: Design & Operate a 2-Node GPU Cluster** | Student designs a 2×8 GPU cluster (TP=8, PP=2) for serving a 405B model: network topology, NCCL config, vLLM deployment, DCGM + NCCL monitoring, FinOps report (cost-per-token, utilization, autoscaling config), failure drill (kill a node, verify recovery) | 1+2 | 4 hr |

### Technology Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| GPU interconnect | NVLink 4.0 (900 GB/s), InfiniBand NDR400 / RoCE | Intra-node vs. inter-node |
| Communication lib | NCCL 2.21+ (2026) | Dynamic topology detection, SHARP support |
| Distributed inference | vLLM + Ray (TP/PP) | Multi-node via StatefulSet |
| Distributed training | PyTorch FSDP / DeepSpeed ZeRO | PyTorchJob on K8s |
| Scheduling | Kueue + Volcano (from Course 1) | Gang scheduling, topology-aware |
| GPU telemetry | DCGM + NCCL exporter | Prometheus + Grafana |
| FinOps | OpenCost / Kubecost | GPU cost allocation, utilization |
| Autoscaling | KEDA (GPU queue depth) + GKE CA | Scale on real GPU load, not CPU |
| Network monitoring | `ibstat`, port CRC counters, `ib_read_bw` | Fabric health |

### Infrastructure Requirements (Tier 2)

This is the **only course in the series that genuinely needs multi-node GPU hardware.**

| Option | Config | Cost | Notes |
|--------|--------|------|-------|
| **GCP** | 2× `a2-ultragpu-8g` (8× A100 80GB each) | ~$58/hr | InfiniBand included, GKE native |
| **AWS** | 2× `p4d.24xlarge` (8× A100 40GB each) | ~$96/hr | EFA networking (not IB) |
| **RunPod** | 2× A100 80GB nodes (InfiniBand cluster) | ~$20–30/hr | Cheapest multi-node IB |
| **CoreWeave** | 2× H100 nodes (IB NDR) | ~$40–50/hr | K8s-native, IB included |
| **Simulation (Tier 1)** | KWOK + 2 fake 8-GPU nodes | $0 | NCCL can't run, but scheduling/topology/FinOps can be simulated |

**For the lab:** Use **RunPod InfiniBand clusters** (2× A100 nodes, ~$20–30/hr) for the hands-on NCCL + vLLM multi-node modules. For FinOps and scheduling, the KWOK simulation (Tier 1) is sufficient.

**Budget per student (4-hr multi-node session):** ~$8–12 (shared across 4–6 students on a 2-node cluster).

### Out of Scope

- CUDA kernel development
- Model architecture / training recipe design (learning rate schedules, etc.)
- Data pipeline engineering (loading, tokenization, sharding datasets)
- On-premises data center design (power, cooling, cabling) — *conceptual only*
- AMD GPU / ROCm (mentioned as alternative, not hands-on)

### Assessment Model

| Type | Weight | Description |
|------|--------|-------------|
| Auto-graded tasks (iximiuz) | 40% | NCCL config validation, vLLM TP/PP deployment, Kueue topology-aware job |
| NCCL benchmark report | 20% | Student runs `all_reduce_perf` on 2 nodes, documents bus bandwidth, identifies the transport used |
| FinOps analysis | 20% | Student calculates cost-per-token for their vLLM deployment, identifies utilization waste, proposes optimization |
| Capstone: 2-node cluster design | 20% | Full design doc + working deployment + failure drill |

### Success Criteria

- Student can read `NCCL_DEBUG=INFO` output and identify which transport
  (P2P, SHM, NET/IB) is being used for each GPU pair
- Student can deploy vLLM with TP=8, PP=2 across 2 nodes and serve a 405B model
- Student can explain why `NCCL_NET_GDR_LEVEL=5` matters and what breaks without it
- Student can calculate the all-reduce bandwidth for a given cluster topology
  and verify it matches the `all_reduce_perf` benchmark
- Student can identify that their cluster's 5% utilization is caused by
  over-provisioned reserved capacity and propose a spot + on-demand mix
- Student can kill a node mid-inference and verify the system recovers from
  the last checkpoint within N minutes

### Cert Alignment

| Cert | Coverage |
|------|----------|
| **NCP-AIN** (NVIDIA AI Networking) | Modules 1, 2, 5 (InfiniBand, RDMA, GPUDirect, topology) |
| **NCP-AII** (refresher) | Module 3 (multi-node GPU Operator, DRA for RDMA resources) |
| **CKA** (advanced) | Module 7 (topology-aware scheduling, PDBs for GPU nodes) |
| **FinOps AI Fundamentals** (new, FinOps Foundation) | Module 6 (FOCUS 1.3, cost-per-token, GPU utilization) |   

### Three-Course Roadmap
COURSE 1 (Weeks 1–4)          COURSE 2 (Weeks 5–8)         COURSE 3 (Weeks 9–12)
┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐
│ GPU-Aware Kubernetes │     │ Production LLM Apps  │     │ Multi-Node GPU       │
│                      │     │                      │     │ Clusters & FinOps    │
│ "Why is my GPU job   │     │ "How do I build,     │     │                      │
│  pending?"           │     │  observe & evaluate  │     │ "How do I scale      │
│                      │     │  my LLM app?"        │     │  beyond one node     │
│                      │     │                      │     │  and keep the bill   │
│ 1 GPU                │     │ 1 GPU (same vLLM)    │     │ 8–16+ GPUs           │
│ Single node          │     │ Single node          │     │ Multi-node + fabric  │
│                      │     │                      │     │                      │
│ Kueue, Volcano,      │     │ LangChain, LangGraph,│     │ NCCL, InfiniBand,    │
│ Karpenter, DCGM,     │     │ Langfuse, FastAPI    │     │ FSDP, TP/PP,         │
│ vLLM (1 GPU)         │     │ (on vLLM)            │     │ FinOps, fat-tree     │
│                      │     │                      │     │                      │
│ Cert: CKA + NCP-AII  │     │ (no specific cert)   │     │ Cert: NCP-AIN        │
│ Infra: GCP L4/A100   │     │ Infra: same as C1    │     │ Infra: 2× 8-GPU IB   │
│ Cost: ~$3/student    │     │ Cost: ~$0 extra      │     │ Cost: ~$10/student   │
└──────────────────────┘     └──────────────────────┘     └──────────────────────┘
       │                             │                             │
       └─────────────────────────────┴─────────────────────────────┘
                                   │
                    COMBINED DELIVERABLE:
                    "I can design, deploy, operate, and
                     cost-optimize a production GPU
                     platform from single-GPU inference
                     to multi-node training."   

### Course 3 is where the comp premium jumps 
The earlier conversation noted that "engineers who understand GPU interconnect topology and distributed systems at depth remain scarce." That's this course.
