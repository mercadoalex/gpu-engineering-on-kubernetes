# GPU Engineering on Kubernetes — Course 1 Syllabus

> Internal planning document. Source of truth for the module/lesson scaffold.
> Subject to change — reshuffle freely before building. Not pushed to iximiuz.

**Philosophy:** Learn by doing, break things, understand why. Every lesson puts
the student's hands on a terminal within the first 5 minutes. No slides, no theory
without a command to run.

**Course total:** 8 modules · 29 lessons · ~25 hours
**Tier 1 (local KWOK sim, free):** Modules 1–5 · **Tier 2 (GCP GPU):** Modules 6–8
**Note:** Lesson 3.6 (HAMi architecture) runs on a dedicated **k3s** playground
(`hami-k3s-b5cd6d78`), not the KWOK one — it needs a real kubelet. Still free / Tier 1.

---

## Module 1 — GPU Fundamentals for K8s Engineers
**Tier 1 · 2 hr · 3 lessons** — How Kubernetes actually models a GPU.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 1.1 | **Your Cluster Has No Idea What a GPU Is (Yet)** ✅ *built* | Install ghostgpu on KWOK, go from 0→4 GPUs, schedule a pod, break it with an over-request | 5 |
| 1.2 | **What's Actually Inside a GPU (and Why K8s Doesn't Care)** | Read `nvidia-smi` output from a captured sample, map SMs/VRAM/tensor cores to the opaque `nvidia.com/gpu` integer; inspect a node's extended-resource data model | 3 |
| 1.3 | **MIG, Time-Slicing, vGPU: Three Ways to Share One GPU** | Simulate each sharing mode's node labels in KWOK, schedule pods against `nvidia.com/mig-1g.5gb`, reason about isolation guarantees. Forward-reference: HAMi's software sharing architecture in Lesson 3.6 (free), real HAMi slicing on hardware in Lesson 6.4. | 4 |

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

## Module 3 — GPU-Aware Scheduling (Kueue + Volcano + HAMi)
**Tier 1 · 5 hr · 6 lessons** — The core of the course: quota, fairness, gang scheduling, and fractional sharing.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 3.1 | **Install Kueue and Build Your First Quota Wall** | ClusterQueue + LocalQueue + ResourceFlavor, submit a Job, watch it admitted vs suspended | 4 |
| 3.2 | **Cohorts and Borrowing: Share GPUs Without Fighting** | Two teams, one cohort; Team A borrows Team B's idle GPUs, then B reclaims them | 5 |
| 3.3 | **Preemption: Who Gets Evicted When the Cluster Is Full** | Priority classes, configure preemption policy, watch a low-prio job get evicted for a high-prio one | 4 |
| 3.4 | **Gang Scheduling with Volcano: Why Training Jobs Deadlock** | Submit a 4-pod job without gang (deadlock), then with Volcano `minAvailable` (all-or-nothing) | 5 |
| 3.5 | **DRF Fair-Share: Make Volcano Divide Resources Fairly** | Configure Volcano queues with DRF, submit competing jobs, observe fair division | 4 |
| 3.6 | **Inside HAMi: The Architecture of GPU Sharing (no GPU needed)** | On a dedicated k3s playground, install run-ai/fake-gpu-operator + HAMi (scheduler + webhook, `devicePlugin.enabled=false`); watch fake `nvidia.com/gpu` appear; trace the full scheduling chain (webhook → hami-scheduler → pod placement); learn the `gpumem`/`gpucores` resource *model*; run a GPU pod and see simulated `nvidia-smi`; tour the HAMi WebUI. HONEST scope (matches HAMi's own Lab 2): this teaches HAMi's components and scheduling workflow on fake GPUs — real memory/compute slicing needs real hardware and is done in Lesson 6.4. | 6 |

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

## Module 6 — NVIDIA GPU Operator & GPU Sharing in Production
**Tier 2 (GCP) · 3 hr · 4 lessons** — Real GPU. Install the operator stack; partition and share a real card.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 6.1 | **Your First Real GPU Node on GKE** | Provision a `g2-standard-4` (L4), verify the node joins, see real `nvidia.com/gpu` | 3 |
| 6.2 | **Install the GPU Operator (Driver → Toolkit → Plugin → DCGM)** | Helm install, watch each component roll out, verify node labels | 4 |
| 6.3 | **Partition an A100 with MIG (Single vs Mixed Strategy)** | Enable MIG, create 7× `1g.5gb`, schedule a pod to one partition, confirm isolation | 4 |
| 6.4 | **Real Fractional GPU Sharing with HAMi (on a live L4)** | On the real GPU node, install HAMi with its device-plugin ENABLED; schedule pods that request true slices via `nvidia.com/gpumem` (MB) and `nvidia.com/gpucores` (%); pack 3 workloads onto one physical L4; prove hard isolation by over-requesting memory and watching it get rejected; compare binpack vs spread. This is the real-hardware payoff that Lesson 3.6 set up on fake GPUs. Pairs with HAMi's own Lab 1 (real T4). | 5 |

---

## Module 7 — LLM Inference Serving with vLLM
**Tier 2 (GCP) · 3 hr · 4 lessons** — Deploy and benchmark a real inference server.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 7.1 | **Deploy vLLM on a Single L4 GPU** | Deployment + Service, load a small model, hit the OpenAI-compatible `/v1` endpoint | 4 |
| 7.2 | **Benchmark It: tokens/s, TTFT, TPOT** | Run a load test, capture the three latency metrics, interpret them | 4 |
| 7.3 | **PagedAttention and Continuous Batching: Why vLLM Is Fast** | Toggle batching config, measure throughput delta, correlate with GPU util in Grafana | 3 |
| 7.4 | **vLLM vs SGLang vs NVIDIA NIM: Pick Your Serving Stack** | Deploy SGLang, run the same benchmark, build a comparison table; add NVIDIA NIM as the managed/enterprise option — show the OpenAI-compatible API parity, discuss the tradeoff (turnkey + supported + TensorRT-LLM-optimized vs. opaque, NGC-licensed, heavier). vLLM stays the primary hands-on engine; NIM is a comparison aside, not a replacement. | 3 |

> **NVIDIA NIM note:** NIM = prebuilt NVIDIA inference microservice containers
> (OpenAI-compatible API over TensorRT-LLM/vLLM). It fits as an *alternative serving
> backend* across all three courses: in C1 Module 7 as a comparison point; in C2 as a
> drop-in `base_url` swap behind `ChatOpenAI`; in C3 for multi-GPU serving. We keep
> vLLM primary because the course thesis is "understand the layer underneath" — NIM
> hides it. NIM also needs NGC auth + licensing, which complicates the < $10/student
> guardrail. Teach it as "the enterprise turnkey option," not the default.

---

## Module 8 — Capstone: Multi-Tenant GPU Platform
**Tier 1 + 2 · 4 hr · 1 lesson (project)** — Combine everything into one scenario.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 8.1 | **Run a 3-Team GPU Platform with Quota, Gang Scheduling, Fractional Sharing, Observability, and Cost Guardrails** | 3 teams × 3 workload types (training gang, fractional-shared inference via HAMi, data-prep); Kueue cohorts + Volcano + HAMi slicing + DCGM dashboards + CA cost limits; evaluated on scheduling correctness + packing efficiency + cost | 6 |

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

## HAMi — two-lesson split (detailed design)

HAMi is taught in TWO lessons, mirroring how the HAMi project itself splits it
(Lab 2 = fake/architecture, Lab 1 = real GPU/slicing). This is the HONEST split —
verified against HAMi's official Lab 2, which states plainly that real memory slicing
(`gpumem`), compute limits (`gpucores`), CUDA execution, and isolation REQUIRE a real GPU.

### Lesson 3.6 — Inside HAMi: The Architecture of GPU Sharing (Tier 1, free)

**Scope (what genuinely works on fake GPUs):** install, components, scheduling chain,
the resource *model*. NOT real slicing — that's 6.4. Be explicit about this boundary
in a hint box, exactly like Lesson 1.1 is honest about simulated GPUs.

**Substrate:** the dedicated **k3s** playground `hami-k3s-b5cd6d78` (already created by
the user via `labctl playground create hami-k3s --base k3s`). The iximiuz k3s base is a
REAL 4-VM cluster (dev-machine + cplane-01 + 2 workers, real kubelets, Helm preinstalled)
— confirmed via `labctl playground manifest`. HAMi's scheduler/webhook pods actually run
here (real kubelet), unlike KWOK. Lessons 3.1–3.5 keep the KWOK playground; only 3.6
points `playground.name` at `hami-k3s-b5cd6d78`.

**Install flow (from HAMi Lab 2, adapt — Apache-2.0, cite, don't copy verbatim):**
1. `kubectl create namespace gpu-operator` + label it `pod-security...=privileged`.
2. Label a node `run.ai/simulated-gpu-node-pool=default`.
3. `helm upgrade -i gpu-operator oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator`
   → nodes advertise fake `nvidia.com/gpu` (count, product, memory labels).
4. `helm repo add hami-charts https://project-hami.github.io/HAMi/` then
   `helm install hami hami-charts/hami -n kube-system --set devicePlugin.enabled=false`
   (device-plugin OFF to avoid conflicting with fake-gpu-operator — this is WHY real
   slicing is off here; HAMi only runs scheduler + webhook).
5. Run a test pod with `hami.io/webhook: ignore` + `nvidia.com/gpu: 1` → schedules, and
   `kubectl exec ... nvidia-smi` shows a simulated card.

**Hands-on arc:** install fake-gpu-operator → see fake GPUs on nodes → install HAMi →
inspect scheduler+webhook (`kubectl get pods -n kube-system | grep hami`, the 2/2 pod) →
trace the scheduling chain (webhook rewrites schedulerName → hami-scheduler places pod) →
learn the `gpumem`/`gpucores` resource MODEL (explain, don't run) → run a fake GPU pod,
`nvidia-smi` inside it → honest hint box: "why can't we slice here? device-plugin is off,
fake GPUs have no real memory to partition — Lesson 6.4 does the real thing."

**Grading tasks (k3s playground; init tasks live in the PLAYGROUND manifest, NOT here):**
verify_cluster_ready, verify_fake_gpu_operator_installed, verify_fake_gpus_present,
verify_hami_scheduler_running, verify_gpu_pod_scheduled, verify_lesson_complete.
Each `run:` starts with `export KUBECONFIG=$HOME/.kube/config` (the k3s playground's
init task writes it there, per the Rancher pattern).

**Playground manifest (`playgrounds/hami-k3s/manifest.yaml`):** model on
`rancher_ex/playgrounds/rancher-k3s/manifest.yaml`. initTasks (in the MANIFEST): 
init_kubeconfig_devmachine (ssh cplane-01, fetch k3s.yaml, write ~/.kube/config +
.bashrc), init_fake_gpu_operator (needs kubeconfig; helm install + label node), init_hami
(needs fake-gpu-operator; helm install with devicePlugin.enabled=false). Multi-machine
k3s topology has a real control-plane, so the single-machine `controlPlaneOnly` hang does
NOT apply. timeout_seconds valid here.

### Lesson 6.4 — Real Fractional GPU Sharing with HAMi (Tier 2, real L4)

**Scope:** the real payoff. On the live GCP L4 GPU node (from 6.1/6.2), install HAMi with
`devicePlugin.enabled=true` (real device-plugin, no fake-gpu-operator). Now `gpumem` and
`gpucores` actually partition the physical card.

**Hands-on arc (break-it works for real here):**
1. Install HAMi (device-plugin enabled) on the real GPU node.
2. Schedule pod A: `nvidia.com/gpu: 1, nvidia.com/gpumem: 4000, nvidia.com/gpucores: 30`.
3. Pods B, C same slice → all three pack onto ONE physical L4 (24 GB). `nvidia-smi` and
   HAMi show the real partitioning.
4. **Break it (real):** request `gpumem: 50000` on the 24 GB L4 → HAMi's hard isolation
   rejects it. A pod exceeding its memory slice at runtime gets OOM'd — real isolation.
5. binpack vs spread placement on the real card.

**Cost note:** runs on the same L4 node as 6.1–6.3, within the < $10/student guardrail.

**Licensing (both lessons):** HAMi Apache-2.0; official `Project-HAMi/hami-workshop`.
Adapt the approach with attribution; original prose. Refs: https://project-hami.io/ ,
https://github.com/Project-HAMi/hami-workshop

**Graded challenge for the module:** pack 3 inference pods onto a single simulated GPU
with distinct memory slices, prove the 4th pods pends on over-request. (This is the
Module 3 `::card` challenge.)

---

## Open questions / decisions needed

- [ ] **Lesson count per module** — proposed above (3/4/6/3/4/3/4/1). Adjust?
- [x] **HAMi substrate** — RESOLVED: HAMi gets its own dedicated **kind +
      fake-gpu-operator** playground (not KWOK), so its pods actually run and real
      slicing works. Mirrors HAMi's official Lab 2. Needs a new kind-based lab image +
      playground built before Lesson 3.6 content. See Lesson 3.6 design note.
- [ ] **kind-in-microVM** — verify a kind cluster (Docker-in-the-VM) actually boots
      inside the iximiuz Firecracker microVM for the HAMi playground. kind needs a
      container runtime; earlier we DROPPED kind from the KWOK image because kind-in-
      microVM was unreliable. The HAMi playground must prove kind works there (or use
      iximiuz's official `k3s`/`kind` base which is built for this) BEFORE building the
      lesson. This is the main build risk for 3.6.
- [ ] **Playground init task** — all Tier 1 lessons need a shared init task that creates
      the KWOK cluster + clones the repo to `/workdir`. Build once, reuse across modules.
- [ ] **Tier 2 gating** — Modules 6–8 need the GCP SA key baked into the VM image (or a
      separate Tier-2 playground). Decide before building Module 6.
- [ ] **Challenges** — syllabus lists tasks only. Which lessons also get a graded
      `::card` challenge? (Suggest: 1 per module, on the final lesson.)

---

## Reference material (source links)

External sources that validate or enrich course concepts. Cite these in lessons
where relevant (not as required reading — the course is hands-on first).

| Topic | Link | Where it's used |
|-------|------|-----------------|
| Why K8s has no native GPU knowledge (scheduler + cAdvisor understand only CPU/memory; GPUs are opaque vendor hardware) | https://newsletter.devopscube.com/p/gpu-scheduling-kubernetes | Reinforces the thesis of Lesson 1.1 — cite as further reading |
| GPU sharing strategies on Kubernetes | https://newsletter.devopscube.com/p/kubernetes-gpu-sharing-strategies | Lesson 1.3 (MIG/time-slicing/vGPU) and Lesson 3.6 (HAMi) |
| HAMi — Heterogeneous AI Computing Virtualization Middleware (CNCF Incubating) | https://project-hami.io/ | Lesson 3.6 — the dedicated fractional-sharing lesson |
| HAMi NVIDIA pod example (`gpucores`, `gpumem`) | https://github.com/Project-HAMi/HAMi/blob/master/examples/nvidia/default_use.yaml | Lesson 3.6 — canonical pod spec for the activities |

**Key framing pulled from the DevOpsCube GPU-scheduling piece (rephrased for compliance
with licensing):** Kubernetes natively understands CPU and memory because the kubelet
reports them via cAdvisor; GPUs are specialized vendor hardware the scheduler has no
built-in model for (no notion of a GPU's memory or compute speed). That gap — and how
device plugins / DRA / HAMi fill it — is exactly what Module 1 and Lesson 3.6 teach.
*Content was rephrased for compliance with licensing restrictions.*
