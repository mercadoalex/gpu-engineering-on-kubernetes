---
inclusion: fileMatch
fileMatchPattern: "deploy/**/*.yaml,gcp/**/*.tf"
---

# GCP Deployment — Node Pools, MIG, CA Config & SA Keys

## Node Pool Reference

### Single-Student GPU Pool (Course 1 & 2)

```yaml
# deploy/node-pools/gpu-l4-usw1.yaml
name: gpu-l4-usw1
machineType: g2-standard-4        # 1× L4 24 GB VRAM, 4 vCPU, 16 GB RAM
acceleratorType: nvidia-l4
acceleratorCount: 1
region: us-west1
nodeLocations:
  - us-west1-b                    # single zone — simplifies CA
minNodeCount: 0                   # scale-to-zero mandatory
maxNodeCount: 3                   # hard cap
spot: true                        # spot instances only for labs
diskSizeGb: 100
diskType: pd-ssd
taints:
  - key: nvidia.com/gpu
    value: present
    effect: NoSchedule
labels:
  gpu-type: l4
  course: c1-c2
  tier: "2"
```

### Multi-Student MIG Pool (Course 1 shared lab)

```yaml
# deploy/node-pools/gpu-a100-mig-usw1.yaml
name: gpu-a100-mig-usw1
machineType: a2-highgpu-1g        # 1× A100 40 GB VRAM
acceleratorType: nvidia-tesla-a100
acceleratorCount: 1
region: us-west1
nodeLocations:
  - us-west1-b
minNodeCount: 0
maxNodeCount: 1                   # 1 A100 → 7 MIG partitions → 7 students
spot: true
diskSizeGb: 200
diskType: pd-ssd
taints:
  - key: nvidia.com/gpu
    value: present
    effect: NoSchedule
labels:
  gpu-type: a100-mig
  mig-strategy: mixed
  course: c1-shared
  tier: "2"
```

## MIG Configuration

**Partition strategy for the A100:** `1g.5gb` × 7 — hardware isolation per student.

```bash
# deploy/mig/configure-mig.sh
# Run on the A100 node after GPU Operator is installed

# Enable MIG mode
sudo nvidia-smi -mig 1

# Create 7× 1g.5gb profiles (GI + CI)
for i in $(seq 1 7); do
  sudo nvidia-smi mig -cgi 19,19 -C   # profile 19 = 1g.5gb
done

# Verify
nvidia-smi -L
# Expected: 7x MIG 1g.5gb instances
```

**GPU Operator MIG strategy:** set `migStrategy: mixed` in the GPU Operator Helm values
so individual MIG instances appear as separate allocatable resources.

```yaml
# In GPU Operator Helm values
mig:
  strategy: mixed
```

**Node label after MIG setup:**
```
nvidia.com/mig.capable=true
nvidia.com/mig-1g.5gb.count=7
```

**Pod resource request (student workload targeting a MIG slice):**
```yaml
resources:
  limits:
    nvidia.com/mig-1g.5gb: 1
```

## Cluster Autoscaler Config

```yaml
# Applied via GKE node pool settings or gcloud
# Key parameters — enforce on all GPU pools
--scale-down-enabled=true
--scale-down-delay-after-add=5m
--scale-down-unneeded-time=5m     # aggressive — GPUs are expensive
--scale-down-utilization-threshold=0.3
--max-node-provision-time=15m
```

Scale-down is intentionally aggressive (`5m` unneeded time) because idle GPU nodes
cost $0.71/hr. Students should expect cold-start latency (~3–5 min) when the pool
is at zero.

## Service Account Setup

**Principle of least privilege** — the lab SA only needs GKE developer access on
the lab cluster, not project-wide editor.

```bash
# One-time setup (run by instructor, not automated)
gcloud iam service-accounts create gpu-lab-sa \
  --display-name="GPU Lab Student SA" \
  --project=YOUR_PROJECT_ID

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:gpu-lab-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/container.developer"

# Export key (bake into iximiuz VM image — never commit to git)
gcloud iam service-accounts keys create /tmp/gpu-lab-sa-key.json \
  --iam-account=gpu-lab-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

Key handling:
- The JSON key is baked into the iximiuz VM image during image build.
- It is **never stored in this repo** — see `deploy/sa/README.md` for the bake-in procedure.
- Rotate keys every 90 days.
- Scope: `roles/container.developer` on the lab cluster only.

## GCP Billing Alert

```bash
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="GPU Lab Budget" \
  --budget-amount=50USD \
  --threshold-rule=percent=60 \    # alert at $30
  --threshold-rule=percent=100     # alert at $50
```

At $50 threshold: manually scale all GPU node pools to `maxNodeCount: 0` until
the next billing cycle. This is a manual circuit breaker, not automated.

## Terraform Module Layout

```
gcp/
├── main.tf            # Provider config, project, region
├── cluster.tf         # GKE cluster definition
├── node-pools.tf      # GPU node pool resources
├── iam.tf             # Service account + bindings
├── variables.tf       # project_id, region, cluster_name, etc.
└── outputs.tf         # cluster endpoint, SA email
```

All Terraform uses `us-west1` as default region. Do not parameterize region
without also updating the billing alert and the iximiuz VM ADC config.
