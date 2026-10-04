# Repo Layout, Naming & Where Things Go

## Top-Level Directory Structure

```
K8s_gpu_lab/
├── .kiro/
│   ├── steering/          # Steering files (this file lives here)
│   └── hooks/             # Agent hooks
├── course-1/              # GPU-Aware Kubernetes
│   ├── manifests/         # K8s YAML files (Kueue, Volcano, GPU Operator, etc.)
│   ├── tasks/             # iximiuz auto-graded task definitions
│   ├── scripts/           # Setup, validation, and benchmark scripts
│   ├── dashboards/        # Grafana dashboard JSON exports
│   └── README.md
├── course-2/              # Production LLM Applications
│   ├── manifests/         # K8s YAML (FastAPI deployment, Langfuse, etc.)
│   ├── tasks/             # iximiuz task definitions
│   ├── app/               # FastAPI + LangGraph + LangChain source code
│   ├── evals/             # Langfuse evaluation datasets and scoring scripts
│   └── README.md
├── course-3/              # Multi-Node GPU Clusters
│   ├── manifests/         # K8s YAML (StatefulSet, PyTorchJob, NCCL config, etc.)
│   ├── tasks/             # iximiuz task definitions
│   ├── scripts/           # NCCL benchmark, FinOps analysis scripts
│   └── README.md
├── deploy/                # GCP deployment automation
│   ├── node-pools/        # GKE CA node pool YAML configs
│   ├── mig/               # MIG partitioning scripts and configs
│   └── sa/                # Service account key instructions (never commit actual keys)
├── gcp/                   # Terraform / gcloud configs for GCP infrastructure
│   └── *.tf
├── docs/                  # Design docs, ADRs, student guides
└── gpu-k8s-lab.md         # Original source-of-truth document (retained for reference)
```

## Naming Conventions

### Kubernetes Manifests

| Resource | Pattern | Example |
|----------|---------|---------|
| ClusterQueue | `cq-<team-or-purpose>` | `cq-team-a`, `cq-default` |
| LocalQueue | `lq-<namespace>-<purpose>` | `lq-team-a-training` |
| Kueue cohort | `cohort-<name>` | `cohort-shared` |
| Volcano Queue | `vq-<name>` | `vq-high-priority` |
| GPU node pool | `gpu-<type>-<region-short>` | `gpu-l4-usw1`, `gpu-a100-usw1` |
| Namespace | `<team>-<course-short>` | `team-a-c1`, `infra-c2` |

### Files

- Manifests: `<resource-type>-<name>.yaml` — e.g., `clusterqueue-default.yaml`
- Scripts: `<verb>-<subject>.sh` — e.g., `install-gpu-operator.sh`, `benchmark-vllm.sh`
- Grafana dashboards: `dashboard-<name>.json` — e.g., `dashboard-dcgm-overview.json`
- iximiuz tasks: `task-<module>-<number>-<slug>.yaml` — e.g., `task-03-1-install-kueue.yaml`

### Branches

- `main` — stable, course-content-ready
- `course-<N>/module-<N>-<slug>` — in-progress module work
- `fix/<slug>` — bug fixes
- `lab/<slug>` — lab environment experiments

## iximiuz Task File Conventions

Each module has 2–4 auto-graded tasks. Task files live in `course-N/tasks/` and follow the iximiuz `<task>` block format. Naming: `task-<module>-<seq>-<slug>.md`.

Validation scripts (the pass/fail checker invoked by iximiuz) live alongside tasks as `validate-<slug>.sh`.

## What Goes Where — Quick Reference

| Content | Location |
|---------|----------|
| Kueue ClusterQueue / LocalQueue YAML | `course-1/manifests/` |
| vLLM Deployment + Service YAML | `course-1/manifests/` or `course-2/manifests/` |
| Langfuse K8s manifests | `course-2/manifests/` |
| GKE CA node pool configs | `deploy/node-pools/` |
| MIG partition scripts | `deploy/mig/` |
| Terraform for GCP infra | `gcp/*.tf` |
| DCGM Grafana dashboard JSON | `course-1/dashboards/` |
| vLLM benchmark scripts | `course-1/scripts/` |
| NCCL `all_reduce_perf` scripts | `course-3/scripts/` |
| ADRs and design decisions | `docs/` |

## Secrets & Keys

- **Never commit GCP service account keys** — document the path (`~/.config/gcloud/` or mounted Secret) in `deploy/sa/README.md` only.
- `.env` files are `.gitignore`d at root level.
- Langfuse API keys: inject via K8s Secret, never hardcoded in manifests.
