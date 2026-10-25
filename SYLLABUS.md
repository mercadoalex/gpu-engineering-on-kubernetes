# GPU Engineering on Kubernetes — Course 1 Syllabus

> Internal planning document. Source of truth for the module/lesson scaffold.
> Subject to change — reshuffle freely before building. Not pushed to iximiuz.

**Philosophy:** Learn by doing, break things, understand why. Every lesson puts
the student's hands on a terminal within the first 5 minutes. No slides, no theory
without a command to run.

**Course total:** 8 modules · 28 lessons · ~24 hours
**Tier 1 (local KWOK sim, free):** Modules 1–5 · **Tier 2 (GCP GPU):** Modules 6–8

---

## Module 1 — GPU Fundamentals for K8s Engineers
**Tier 1 · 2 hr · 3 lessons** — How Kubernetes actually models a GPU.

| # | Lesson | Hands-on outcome | Tasks |
|---|--------|------------------|-------|
| 1.1 | **Your Cluster Has No Idea What a GPU Is (Yet)** ✅ *built* | Install ghostgpu on KWOK, go from 0→4 GPUs, schedule a pod, break it with an over-request | 5 |
| 1.2 | **What's Actually Inside a GPU (and Why K8s Doesn't Care)** | Read `nvidia-smi` output from a captured sample, map SMs/VRAM/tensor cores to the opaque `nvidia.com/gpu` integer; inspect a node's extended-resource data model | 3 |
| 1.3 | **MIG, Time-Slicing, vGPU: Three Ways to Share One GPU** | Simulate each sharing mode's node labels in KWOK, schedule pods against `nvidia.com/mig-1g.5gb`, reason about isolation guarantees. Forward-reference: software-defined fractional sharing with HAMi is covered hands-on in Lesson 3.6. | 4 |

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
| 3.6 | **Fractional GPU Sharing with HAMi: One GPU, Many Workloads** | Install HAMi (CNCF Incubating GPU-virtualization middleware) on the KWOK cluster; schedule pods that request a *slice* of a GPU via `nvidia.com/gpumem` (memory in MB or %) and `nvidia.com/gpucores` (compute %); pack multiple pods onto one GPU; break it by over-requesting memory and watch HAMi's hard isolation reject it; compare binpack vs spread placement. | 6 |

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

## Lesson 3.6 — Fractional GPU Sharing with HAMi (detailed design)

**Why this lesson matters:** Lesson 1.3 teaches the *hardware* sharing modes (MIG,
time-slicing, vGPU) conceptually. HAMi is the *software* sharing layer engineers
actually deploy to pack many workloads onto one GPU — with real memory + compute
isolation — WITHOUT needing MIG-capable hardware. It's CNCF Incubating, Kubernetes-
native, DRA-aware, and directly serves the course's < $10/student cost thesis:
fractional sharing means one simulated GPU serves many student pods.

**What HAMi is (teach honestly):** Heterogeneous AI Computing Virtualization
Middleware. Kubernetes treats a GPU as one indivisible `nvidia.com/gpu` integer — a
pod asking for 1 GPU takes the whole card even if it uses 10% of it. HAMi adds two
extra resource dimensions so a pod requests a *slice*:
- `nvidia.com/gpu` — number of physical GPUs to share across
- `nvidia.com/gpumem` — device memory in MB (or `nvidia.com/gpumem-percentage`)
- `nvidia.com/gpucores` — percentage of GPU compute cores (0–100)

HAMi runs in **device-plugin mode** (HAMi schedules, via node annotations + a
scheduler extender) or **DRA mode** (K8s schedules via ResourceSlice/ResourceClaim —
requires K8s 1.34+ with the DRA Consumable Capacity gate + CDI). Device-plugin mode
is the teaching default; DRA mode is a forward-reference to Module 2's DRA lesson.

**Hands-on arc (break-it included):**
1. Install HAMi via Helm onto the KWOK cluster (`helm install hami hami-charts/hami`).
2. Inspect what it added — the scheduler, the device plugin, the webhook, and the
   new `nvidia.com/gpumem` / `nvidia.com/gpucores` resources on nodes.
3. Schedule pod A requesting `gpu: 1, gpumem: 4000, gpucores: 30` — lands on a GPU.
4. Schedule pods B and C with the same slice — all three PACK onto one physical GPU
   (vs. the whole-card model where only one would fit). `kubectl describe node` shows
   the slices adding up.
5. **Break it:** request `gpumem: 50000` on a 24 GB GPU → HAMi's hard isolation
   rejects/pends it. Over-commit cores past 100% → same. Students see isolation is
   real, not advisory.
6. Compare **binpack** (fill one GPU before using the next) vs **spread** (distribute)
   placement policies and observe the different packing.

**Tier:** 1 (free, no real GPU) — BUT on a **dedicated kind-based playground**, NOT the
KWOK playground the rest of Module 1–5 use. This is the critical design decision:

**Why kind + fake-gpu-operator, not KWOK.** HAMi's value is REAL slicing — its
scheduler, webhook, and device-plugin pods must actually EXECUTE and enforce memory/
compute isolation. KWOK only *simulates* pods (they never run their containers), so
HAMi's components would be no-ops there — the exact failure mode hit with the
fake-gpu-operator in Lesson 1.1. HAMi's own official **Lab 2** (see hami-workshop repo)
solves this by running on **kind** (real kubelet) + **run-ai/fake-gpu-operator** (whose
pods genuinely execute because kind has a kubelet). That combo gives a fully working
HAMi install with fractional slicing, on a laptop, with no real GPU. We mirror that.

**Dedicated playground:** a new iximiuz playground (`hami-kind-...`) whose image/base
provides kind (real K8s cluster-in-container) + fake-gpu-operator + HAMi preinstalled or
installed by the lesson. Lessons 3.1–3.5 keep the KWOK playground; 3.6 points its
`playground.name` at the kind playground. Build the kind image/base the same way the
KWOK image was built (Dockerfile → ghcr.io → labctl playground create).

**Licensing:** HAMi is Apache-2.0 and ships an official `Project-HAMi/hami-workshop`
(hands-on tutorials). We may adapt the technical approach (kind + fake-gpu-operator +
HAMi install flow) freely with attribution. Write ORIGINAL prose/tasks; cite HAMi; do
not copy their text verbatim. Reference: https://github.com/Project-HAMi/hami-workshop

**Build note:** because this runs on kind with a real kubelet, HAMi installs and
functions normally — `helm install hami`, its pods actually run, and real fractional
scheduling + isolation work. No direct-node-patch hack needed (that was only for KWOK).
This is a genuinely working HAMi demo, which is a strong course selling point: "slice a
GPU across 3 workloads, for free, on your laptop."

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
