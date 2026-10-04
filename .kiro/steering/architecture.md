---
inclusion: auto
name: architecture
description: Two-tier lab architecture, GCP integration, iximiuz split, key technical decisions
---

# Architecture — Two-Tier Design & Key Decisions

## Two-Tier Model

Every course separates "free simulation" from "real GPU validation" so students can complete 80% of the learning without spending money.

### Tier 1 — Local Simulation (free, no GPU)

- **Substrate:** KWOK via `kwokctl` on `kind`
- **GPU simulation:** ghostgpu / fake-gpu-operator → injects `nvidia.com/gpu` + DRA ResourceSlices into virtual nodes
- **Scheduling:** Kueue (quota, cohorts, borrowing) + Volcano (gang, DRF, queues)
- **Autoscaling:** Karpenter NodePool YAML authored and validated only — no real provisioning
- **Observability:** Prometheus + Grafana with synthetic DCGM metrics
- **RAM footprint:** ~2 GB — runs on any 16 GB laptop with Docker

### Tier 2 — Cloud GPU Validation (~$3–8 per session)

- **Provider:** GCP `us-west1`
- **Single-student node:** `g2-standard-4` — 1× L4 24 GB (Ada, FP8), $0.71/hr
- **Multi-student node:** `a2-highgpu-1g` — 1× A100 40 GB, partitioned into 7× MIG `1g.5gb` → hardware-isolated GPU per student at ~$0.16/student/hr
- **Stack:** NVIDIA GPU Operator (driver, toolkit, device plugin, DCGM exporter, MIG manager)
- **Inference:** vLLM 0.28.x (primary), SGLang (comparison benchmark)
- **Metrics:** Real DCGM → Prometheus → Grafana

## Why GCP over AWS/Azure

| Factor | GCP | AWS | Azure |
|--------|-----|-----|-------|
| GPU generation | L4 (Ada, FP8) | A10G (older) | A100 (expensive) |
| MIG setup | Single CLI flag (`--gpu-partition-size`) | Manual, more steps | Harder |
| Autoscaler | GKE CA (native) | Karpenter (native) | AKS CA |
| GPU Operator path | Smoothest on GKE | Good on EKS | Workable |
| Hourly cost | $0.71/hr (L4) | $0.90+/hr (A10G) | Higher |
| Instructor region | CDMX → us-west1 ~25 ms | us-west-2 ~30 ms | westus ~35 ms |

## iximiuz Labs / GCP Split

iximiuz handles **delivery** (browser-based playground, auto-graded tasks, enrollment).  
GCP handles **GPU compute** (real hardware, DCGM, vLLM).

They connect as follows:

```
iximiuz VM (Firecracker microVM)
    │
    │  kubectl over public HTTPS (port 443)
    │  gke-gcloud-auth-plugin → short-lived OAuth2 token
    │  GCP SA key baked into VM as ADC
    ▼
GKE API Server (GCP, us-west1)
    │
    ├── GPU node pool (g2-standard-4 or a2-highgpu-1g)
    ├── NVIDIA GPU Operator
    └── Prometheus + Grafana
```

- No VPC peering, no tunnel — plain HTTPS is sufficient for lab traffic.
- Auth: GCP Service Account key provided as Application Default Credentials inside the iximiuz VM.
- iximiuz cannot do GPU passthrough (Firecracker limitation) — all GPU work lives on GCP.

## Key Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| GPU simulation | KWOK + ghostgpu | Free, scales to 1000s of nodes, no hardware needed |
| Gang scheduling | Volcano | Native gang + DRF fair-share |
| Quota management | Kueue 0.7.x | CNCF, DRA-aware, cohort/borrowing |
| Autoscaler (GCP) | GKE Cluster Autoscaler | Karpenter has no official GKE provider |
| GPU sharing (multi-student) | MIG (hardware isolation) | True isolation, production-relevant skill |
| Cloud provider | GCP `us-west1` | Best GPU gen + MIG CLI + smoothest GKE setup |
| Inference engine | vLLM 0.28.x | PagedAttention, continuous batching, OpenAI-compatible API |
| Lab delivery platform | iximiuz Labs | Browser-based, auto-graded, no student setup required |
| Monetization | Gumroad/Stripe (own billing) + iximiuz (delivery) | iximiuz Independent Authors is pilot-only, not self-serve |
| C2 app ↔ GPU contract | OpenAI-compatible `/v1` API | vLLM exposes it; `ChatOpenAI(base_url=...)` is the client |
| C3 multi-node GPU | RunPod IB clusters (primary) | Cheapest multi-node InfiniBand at ~$20–30/hr |

## Course-to-Course Infrastructure Reuse

| Component | C1 | C2 | C3 |
|-----------|----|----|----|
| GCP `g2-standard-4` / `a2-highgpu-1g` | vLLM serving | Same endpoint, reused | Upgraded to multi-node |
| NVIDIA GPU Operator + DCGM | GPU telemetry | Correlate with app latency | Extended with NCCL exporter |
| Prometheus + Grafana | DCGM dashboards | Add Langfuse metrics | Add NCCL / fabric metrics |
| Kueue + Volcano | Core scheduling | Background awareness | Gang scheduling for distributed jobs |
| iximiuz playground | Scheduling lab | Same playground + Python venv | Same playground for Tier 1 modules |
