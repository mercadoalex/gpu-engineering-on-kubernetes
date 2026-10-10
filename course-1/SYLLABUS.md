# GPU Engineering on Kubernetes — Course 1 Syllabus

> Internal planning document. Source of truth for the module/lesson scaffold.
> Subject to change — reshuffle freely before building. Not pushed to iximiuz.

**Philosophy:** Learn by doing, break things, understand why. Every lesson puts
the student's hands on a terminal within the first 5 minutes. No slides, no theory
without a command to run.

**Course total:** 8 modules · 27 lessons · ~23 hours
**Tier 1 (local KWOK sim, free):** Modules 1–5 · **Tier 2 (GCP GPU):** Modules 6–8

---

## Module 1 — GPU Fundamentals for K8s Engineers
**Tier 1 · 2 hr · 3 lessons** — How Kubernetes actually models a GPU.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 1.1 | **Your Cluster Has No Idea What a GPU Is (Yet)** ✅ *built* | Install ghostgpu on KWOK, go from 0→4 GPUs, schedule a pod, break it with an over-request | 5 |
| 1.2 | **What's Actually Inside a GPU (and Why K8s Doesn't Care)** | Read `nvidia-smi` output from a captured sample, map SMs/VRAM/tensor cores to the opaque `nvidia.com/gpu` integer; inspect a node's extended-resource data model | 3 |
| 1.3 | **MIG, Time-Slicing, vGPU: Three Ways to Share One GPU** | Simulate each sharing mode's node labels in KWOK, schedule pods against `nvidia.com/mig-1g.5gb`, reason about isolation guarantees | 4 |

---

## Module 2 — Simulating GPU Clusters with KWOK
**Tier 1 · 3 hr · 4 lessons** — Build the simulation substrate the whole course runs on.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 2.1 | **Fake a Thousand-Node GPU Cluster on Your Laptop** | `kwokctl create cluster`, add virtual GPU nodes, watch them report Ready with ~0 RAM cost | 4 |
| 2.2 | **Injecting GPU Capacity: ghostgpu vs fake-gpu-operator** | Compare both injectors, patch node status directly, understand the device-plugin contract they emulate | 3 |
| 2.3 | **DRA ResourceSlices: The New GPU Model** | Enable the DRA feature gate, create ResourceSlices, schedule a pod via ResourceClaim, contrast with extended resources | 4 |
| 2.4 | **Break the Scheduler: Taints, Affinity, and Why Pods Pend** | Deliberately misconfigure taints/nodeSelectors, read scheduler events, fix each failure | 4 |

---

## Module 3 — GPU-Aware Scheduling (Kueue + Volcano)
**Tier 1 · 4 hr · 5 lessons** — The core of the course: quota, fairness, gang scheduling.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 3.1 | **Install Kueue and Build Your First Quota Wall** | ClusterQueue + LocalQueue + ResourceFlavor, submit a Job, watch it admitted vs suspended | 4 |
| 3.2 | **Cohorts and Borrowing: Share GPUs Without Fighting** | Two teams, one cohort; Team A borrows Team B's idle GPUs, then B reclaims them | 5 |
| 3.3 | **Preemption: Who Gets Evicted When the Cluster Is Full** | Priority classes, configure preemption policy, watch a low-prio job get evicted for a high-prio one | 4 |
| 3.4 | **Gang Scheduling with Volcano: Why Training Jobs Deadlock** | Submit a 4-pod job without gang (deadlock), then with Volcano `minAvailable` (all-or-nothing) | 5 |
| 3.5 | **DRF Fair-Share: Make Volcano Divide Resources Fairly** | Configure Volcano queues with DRF, submit competing jobs, observe fair division | 4 |

---

## Module 4 — GPU Node Lifecycle & Autoscaling
**Tier 1 · 2 hr · 3 lessons** — Author node pools that scale to zero and control cost.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 4.1 | **Scale-to-Zero: GPU Nodes Shouldn't Idle at $0.71/hr** | Author a GKE CA node pool YAML, validate with `--dry-run=server`, reason about min=0/max=3 | 3 |
| 4.2 | **Karpenter NodePool (Authoring Only — No GCP Provider)** | Write a Karpenter NodePool + spot config, validate it, understand why GCP uses GKE CA instead | 3 |
| 4.3 | **Cost Patterns: Spot, Consolidation, and the Idle-Node Trap** | Model a month of GPU cost under spot vs on-demand, configure consolidation, hit the < $50/mo target | 3 |

---

## Module 5 — GPU Observability with DCGM
**Tier 1→2 · 3 hr · 4 lessons** — Build the dashboards and alerts that keep GPUs healthy.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 5.1 | **Wire Up Prometheus + Grafana for GPU Metrics** | Deploy the stack, scrape a synthetic DCGM exporter, see metrics flow | 4 |
| 5.2 | **The 5 DCGM Metrics That Actually Matter** | Build Grafana panels for util, VRAM, temp, power, XID; read each one | 4 |
| 5.3 | **Alerting on Failure Modes: Thermal, XID, VRAM Exhaustion** | Write Prometheus alert rules, trigger a synthetic thermal-throttle event, see the alert fire | 4 |
| 5.4 | **MIG-Level Metrics: Observing Partitioned GPUs** | Scrape per-MIG-instance metrics, build a dashboard that distinguishes 7 partitions | 3 |

---

## Module 6 — NVIDIA GPU Operator in Production
**Tier 2 (GCP) · 2 hr · 3 lessons** — First real GPU. Install the full operator stack.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 6.1 | **Your First Real GPU Node on GKE** | Provision a `g2-standard-4` (L4), verify the node joins, see real `nvidia.com/gpu` | 3 |
| 6.2 | **Install the GPU Operator (Driver → Toolkit → Plugin → DCGM)** | Helm install, watch each component roll out, verify node labels | 4 |
| 6.3 | **Partition an A100 with MIG (Single vs Mixed Strategy)** | Enable MIG, create 7× `1g.5gb`, schedule a pod to one partition, confirm isolation | 4 |

---

## Module 7 — LLM Inference Serving with vLLM
**Tier 2 (GCP) · 3 hr · 4 lessons** — Deploy and benchmark a real inference server.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 7.1 | **Deploy vLLM on a Single L4 GPU** | Deployment + Service, load a small model, hit the OpenAI-compatible `/v1` endpoint | 4 |
| 7.2 | **Benchmark It: tokens/s, TTFT, TPOT** | Run a load test, capture the three latency metrics, interpret them | 4 |
| 7.3 | **PagedAttention and Continuous Batching: Why vLLM Is Fast** | Toggle batching config, measure throughput delta, correlate with GPU util in Grafana | 3 |
| 7.4 | **vLLM vs SGLang: A Head-to-Head on the Same GPU** | Deploy SGLang, run the same benchmark, build a comparison table | 3 |

---

## Module 8 — Capstone: Multi-Tenant GPU Platform
**Tier 1 + 2 · 4 hr · 1 lesson (project)** — Combine everything into one scenario.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 8.1 | **Run a 3-Team GPU Platform with Quota, Gang Scheduling, Observability, and Cost Guardrails** | 3 teams × 3 workload types (training gang, inference, data-prep); Kueue cohorts + Volcano + DCGM dashboards + CA cost limits; evaluated on scheduling correctness + cost efficiency | 6 |

---

## Assessment (from product.md)

| Type | Weight | How |
|------|--------|-----|
| Auto-graded tasks (iximiuz) | 60% | Each lesson's tasks must turn green |
| Capstone challenge | 30% | Module 8 scenario — scheduling correctness + cost efficiency |
| GPU validation report | 10% | Student documents vLLM benchmark + DCGM dashboard screenshots |

---

## Build order recommendation

1. **Finish Module 1** (lessons 1.2, 1.3) — proves the lesson pattern end-to-end
2. **Module 2** — unblocks everything (the KWOK substrate all later modules reuse)
3. **Module 3** — the course's center of gravity (most tasks, highest value)
4. Modules 4–5 — complete the Tier 1 (free) arc; course is sellable at this point
5. Modules 6–8 — Tier 2 GCP; requires the GCP cluster + SA key wiring

**Milestone:** After Module 5, the entire free tier is complete — a student can do
80% of the course with zero cost. That's the natural first public release.

---

## Open questions / decisions needed

- [ ] **Lesson count per module** — proposed above (3/4/5/3/4/3/4/1). Adjust?
- [ ] **Playground init task** — all Tier 1 lessons need a shared init task that creates
      the KWOK cluster + clones the repo to `/workdir`. Build once, reuse across modules.
- [ ] **Tier 2 gating** — Modules 6–8 need the GCP SA key baked into the VM image (or a
      separate Tier-2 playground). Decide before building Module 6.
- [ ] **Challenges** — syllabus lists tasks only. Which lessons also get a graded
      `::card` challenge? (Suggest: 1 per module, on the final lesson.)
