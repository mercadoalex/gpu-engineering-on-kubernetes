# Tech Stack, Versions & Constraints

## Tier 1 — Local Simulation (no GPU required)

| Component | Technology | Version / Notes |
|-----------|-----------|-----------------|
| Cluster simulator | KWOK (`kwokctl`) | latest stable |
| Local cluster | `kind` | latest stable |
| GPU simulation | ghostgpu / fake-gpu-operator | injects `nvidia.com/gpu` + DRA ResourceSlices |
| Quota management | Kueue | 0.7.x |
| Gang scheduling | Volcano | latest stable |
| Autoscaler authoring | Karpenter NodePool | author/validate only — no real provisioning on GCP |
| Observability | Prometheus + Grafana | synthetic DCGM metrics |
| RAM footprint | ~2 GB total | runs on any 16 GB laptop |

## Tier 2 — Cloud GPU (GCP)

| Component | Technology | Version / Notes |
|-----------|-----------|-----------------|
| GPU node (single-student) | `g2-standard-4` — 1× L4 24 GB | `us-west1`, $0.71/hr on-demand |
| GPU node (multi-student) | `a2-highgpu-1g` — 1× A100 40 GB | partitioned into 7× MIG `1g.5gb` |
| GPU Operator | NVIDIA GPU Operator | Helm, latest GKE-compatible |
| Device plugin | NVIDIA device plugin | bundled with GPU Operator |
| DCGM exporter | `dcgm-exporter` | bundled with GPU Operator |
| MIG manager | NVIDIA MIG manager | bundled with GPU Operator |
| Inference server | vLLM | 0.28.x (primary) |
| Inference comparison | SGLang | latest stable |
| Autoscaler (GCP) | GKE Cluster Autoscaler | Karpenter has no official GKE provider |

## Course 2 — Application Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Pipeline orchestration | LangGraph | 1.1+ |
| Pipeline composition | LangChain LCEL | 1.0+ |
| LLM client | `langchain-openai` (`ChatOpenAI`) | 1.6.x |
| Inference server | vLLM OpenAI-compatible `/v1` | 0.28.x (reused from C1) |
| Vector store (local) | Chroma | latest |
| Vector store (production) | Qdrant | latest |
| Observability | Langfuse (self-hosted) | latest (MIT, OTel-native) |
| API framework | FastAPI + uvicorn | latest |
| Evaluation | Langfuse LLM-as-a-judge + datasets | built-in |
| Runtime | Python | 3.11+ |

## Course 3 — Multi-Node Stack

| Layer | Technology | Version / Notes |
|-------|-----------|-----------------|
| GPU interconnect | NVLink 4.0 (900 GB/s), InfiniBand NDR400 / RoCE | intra-node vs. inter-node |
| Communication lib | NCCL | 2.21+ |
| Distributed inference | vLLM + Ray (TP/PP) | multi-node via StatefulSet |
| Distributed training | PyTorch FSDP / DeepSpeed ZeRO | PyTorchJob on K8s |
| Scheduling | Kueue + Volcano | gang scheduling, topology-aware (from C1) |
| GPU telemetry | DCGM + NCCL exporter | Prometheus + Grafana |
| FinOps | OpenCost / Kubecost | GPU cost allocation |
| Autoscaling | KEDA (GPU queue depth) + GKE CA | scale on real GPU load, not CPU |
| Network monitoring | `ibstat`, port CRC counters, `ib_read_bw` | fabric health |

## Hard Constraints

- **No Karpenter on GCP** — use GKE Cluster Autoscaler exclusively for GCP node pools.
- **No iximiuz GPU passthrough** — iximiuz uses Firecracker microVMs; GPU is only accessible via GCP over HTTPS.
- **vLLM pin:** `0.28.x` for C1/C2; do not upgrade without testing `langchain-openai` compat.
- **Kueue pin:** `0.7.x` for C1; API changes between minor versions affect ClusterQueue/LocalQueue YAML.
- **Python:** `3.11+` required for all C2 code (async type hints, match statements).
- **iximiuz Independent Authors** is pilot-only (4 hand-picked authors) — not self-serve; monetize via Gumroad/Stripe with iximiuz as delivery layer.

## DCGM Metrics in Scope

| Metric | Alert Threshold |
|--------|----------------|
| `DCGM_FI_DEV_GPU_UTIL` | < 30% for 15 min |
| `DCGM_FI_DEV_FB_USED` | > 90% |
| `DCGM_FI_DEV_GPU_TEMP` | > 83°C |
| `DCGM_FI_DEV_XID_ERRORS` | any non-zero |
| `DCGM_FI_DEV_POWER_USAGE` | approaching TDP |
