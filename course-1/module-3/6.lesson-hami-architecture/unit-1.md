---
kind: unit
title: "Inside HAMi: The Architecture of GPU Sharing"
name: lesson-hami-architecture-unit-1
---

## Kubernetes hands you a whole GPU. HAMi hands out slices of one.

In Lesson 1.1 you learned that `nvidia.com/gpu: 1` is an all-or-nothing number — one pod claims one whole card, and the scheduler decrements a counter. A 24 GB GPU running a model that needs 4 GB still shows up as *fully booked*. That is the whole-card waste you have been circling all through Module 3: quota, borrowing, gang scheduling, and fair-share all divide **whole** GPUs. None of them cut a single card into pieces.

[HAMi](https://project-hami.io/) is the piece that does. It is a CNCF project (currently **Incubating**) that lets several pods share one physical GPU — each pod asking for a slice of **memory** and a slice of **compute** — and it does this in software, without touching the NVIDIA driver or rebuilding the kernel. This lesson is the architecture tour: you will see HAMi's components, trace how a GPU pod flows through them, and learn the resource model you will use for real on live hardware in **Lesson 6.4**.

> **Don't worry if this feels like a lot at first.** This lesson is a gentle,
> no-GPU-needed walkthrough of *how HAMi is put together* — just enough to recognize
> its parts and understand what it does. You don't have to master every detail here.
> We go much deeper, on a real NVIDIA GPU, in **Module 6 (Lesson 6.4)**, where you'll
> actually slice a card, pack several workloads onto it, and watch the limits enforce
> themselves. Think of this lesson as the map; Module 6 is the territory.

::image-box
---
:src: __static__/hami-architecture-components-v1.png
:alt: Architecture overview diagram of HAMi on a Kubernetes cluster. On the left, a stack of three component cards labeled "HAMi scheduler", "HAMi mutating webhook", and "HAMi device-plugin (OFF in this lesson)", with the device-plugin card greyed out and marked with a dashed border. In the center, a Kubernetes API server box connects to the scheduler and webhook. On the right, a worker node card shows a green GPU chip labeled "nvidia.com/gpu (from fake-gpu-operator)" and two small pod boxes each labeled with "gpumem" and "gpucores" slice tags. A footer banner reads "HAMi = scheduler + webhook + device-plugin + in-container core — software GPU sharing, no driver changes". A small "CNCF Incubating" badge sits in the top-right corner.
:max-width: 860px
---
_HAMi has four parts: a scheduler, a mutating webhook, a device-plugin, and an in-container core library. In this lesson the device-plugin is deliberately OFF — you are touring the control plane, not slicing real silicon._
::

::hint-box
---
:summary: Do I need a real GPU for this lesson? No — and here's the honest boundary.
---
No GPU, real or rented. This whole lesson runs on a **k3s** cluster with
[run-ai/fake-gpu-operator](https://github.com/run-ai/fake-gpu-operator) fabricating
`nvidia.com/gpu` out of thin air. That is enough to install HAMi, watch its scheduler
and webhook come up, trace how a GPU pod is routed, and read the resource model.

What fake GPUs **cannot** do is actually partition memory or compute — there is no real
VRAM to carve up. So this lesson stops at architecture and workflow. The real thing —
asking for `nvidia.com/gpumem: 4000`, packing three models onto one card, and watching
an over-request get rejected — happens on a live NVIDIA L4 in **Lesson 6.4**. Keeping that
boundary honest is the point; it mirrors how [HAMi's own Lab 2](https://project-hami.io/)
frames the fake-GPU setup.
::

---

## 1. The cluster already has fake GPUs — meet the two operators

This playground did the install for you. Two separate things are running, and it helps to know which does what:

- **fake-gpu-operator** lives in the `gpu-operator` namespace. Its only job is to make nodes *advertise* `nvidia.com/gpu` — and to answer `nvidia-smi` inside a pod with a convincing simulated card — without any hardware. Think of it as a stand-in for the real NVIDIA device plugin you met in Lesson 1.1.
- **HAMi** lives in `kube-system`. It adds the GPU-sharing brain: a scheduler and a mutating webhook. It does **not** fabricate GPUs — it schedules against the ones fake-gpu-operator advertises.

Two operators, two jobs: one invents the GPUs, the other decides who gets them.

::image-box
---
:src: __static__/hami-fakegpu-on-k3s-v1.png
:alt: Diagram of the two operators running on the k3s playground. On the left, a namespace card labeled "gpu-operator" contains four small pod boxes labeled "device-plugin", "status-updater", "topology-server", and "nvidia-dcgm-exporter", with a caption "fabricates nvidia.com/gpu — no hardware". On the right, a namespace card labeled "kube-system" contains a single pod box labeled "hami-scheduler (2/2)" split into two containers "scheduler" and "webhook", with a caption "decides GPU placement". Between them, a worker node card shows a green GPU chip and node labels "nvidia.com/gpu.product=Tesla-K80" and "run.ai/simulated-gpu-node-pool=default". Arrows show fake-gpu-operator writing capacity onto the node, and HAMi reading it.
:max-width: 860px
---
_fake-gpu-operator (namespace gpu-operator) invents the GPUs; HAMi (namespace kube-system) schedules against them. Separating the two is what makes a no-hardware architecture lesson possible._
::

**Activity — Terminal:** Confirm the fake-gpu-operator pods are up, then look at the GPU-related labels the operator stamped onto the worker node:

```bash
kubectl get pods -n gpu-operator
```

```bash
# Find the simulated-GPU worker node, then show just its GPU/run.ai labels.
NODE=$(kubectl get nodes -l run.ai/simulated-gpu-node-pool=default -o jsonpath='{.items[0].metadata.name}')
kubectl get node "$NODE" --show-labels | tr ',' '\n' | grep -E 'nvidia.com/gpu|run.ai'
```

You will see labels like `nvidia.com/gpu.count`, `nvidia.com/gpu.product`, `nvidia.com/gpu.memory`, and `run.ai/simulated-gpu-node-pool=default`. These are what fake-gpu-operator writes so the rest of the stack believes the node has GPUs.

::hint-box
---
:summary: Why two separate operators instead of one GPU thing?
---
Because they solve different problems. In a **real** cluster the NVIDIA device plugin
(advertising hardware) and HAMi (sharing it) are also two separate pieces — HAMi layers
on top of a working GPU stack. The playground just swaps the real NVIDIA device plugin for
fake-gpu-operator so there is something advertising `nvidia.com/gpu` for HAMi to schedule
against. The split mirrors production; nothing about it is a toy shortcut.
::

::hint-box
---
:summary: What are all those other pods in the gpu-operator namespace?
---
fake-gpu-operator ships a few cooperating pods: a **device-plugin** that advertises the
GPUs to the kubelet, a **status-updater** that keeps node labels and capacity in sync, a
**topology-server** that describes how the fake GPUs are laid out, and an
**nvidia-dcgm-exporter** that emits simulated DCGM metrics (the same metric names you met
in the observability modules). You do not configure any of these by hand — they come up
with the Helm release.
::

::simple-task
---
:tasks: tasks
:name: verify_cluster_ready
---
#active
In the **Terminal**, run `kubectl get nodes` and confirm at least **3** nodes show
**Ready** (cplane-01, node-01, node-02 — the dev-machine is your workstation, not a
cluster node).

#completed
k3s cluster is Ready ✓
::

---

## 2. Watch fake nvidia.com/gpu appear on the node

Labels are metadata. The thing the scheduler actually reads is **capacity** — the integer count of `nvidia.com/gpu` on each node. fake-gpu-operator patches that in exactly where a real device plugin would.

**Activity — Terminal:** Sum the GPU capacity across every node, then look at one node's full GPU picture:

```bash
# Total fake GPU capacity across the whole cluster.
kubectl get nodes -o json | jq '[.items[].status.capacity["nvidia.com/gpu"] // "0" | tonumber] | add'
```

```bash
NODE=$(kubectl get nodes -l run.ai/simulated-gpu-node-pool=default -o jsonpath='{.items[0].metadata.name}')
kubectl get node "$NODE" -o json | jq '{gpu_capacity: .status.capacity["nvidia.com/gpu"], product: .metadata.labels["nvidia.com/gpu.product"], memory: .metadata.labels["nvidia.com/gpu.memory"]}'
```

By default fake-gpu-operator advertises a couple of simulated **Tesla-K80** cards with roughly 11 GB each. To the scheduler, that is indistinguishable from real hardware — it is the same `status.capacity` field you patched by hand in Lesson 1.1.

::image-box
---
:src: __static__/hami-fakegpu-on-k3s-capacity-v1.png
:alt: Illustration of a worker node's status.capacity after fake-gpu-operator installs. A node card lists standard resources cpu, memory, pods, and a highlighted green row "nvidia.com/gpu: 2" with a small label "simulated Tesla-K80, ~11 GB each". A dashed callout points at the GPU row reading "patched by fake-gpu-operator's device-plugin — no real hardware behind it". On the side, the kube-scheduler is shown reading the capacity with a thought bubble "I see 2 GPUs — I can't tell they're fake".
:max-width: 860px
---
_fake-gpu-operator patches nvidia.com/gpu into node capacity just like a real device plugin would. The scheduler reads a plain integer and cannot tell the GPUs are simulated._
::

::hint-box
---
:summary: These GPUs aren't real — what does that actually buy us?
---
It buys the entire **control-plane** story: capacity advertising, scheduling decisions,
the webhook rewrite you will trace in Section 4, and a pod reaching `Running` on a
"GPU" node. Everything that happens *above* the hardware is faithful.

What it does **not** buy is anything that touches real silicon: actual VRAM partitioning,
compute isolation, CUDA execution, or OOM-when-you-overcommit behavior. Those need a real
GPU, which is why Lesson 6.4 exists. If you have done the KWOK lessons this trade-off should
feel familiar — same idea, different simulator.
::

::simple-task
---
:tasks: tasks
:name: verify_fake_gpu_operator_installed
---
#active
In the **Terminal**, run `kubectl get pods -n gpu-operator` and confirm its pods are
**Running**. This proves fake-gpu-operator is live and advertising GPUs.

#completed
fake-gpu-operator is installed and Running ✓
::

---

## 3. HAMi's control plane: scheduler + webhook in one pod

Now the HAMi side. When the playground ran `helm install hami hami-charts/hami -n kube-system --set devicePlugin.enabled=false`, it created a single Deployment whose pod carries **two** containers: the **scheduler** (an extension of the kube-scheduler that understands GPU slices) and the **mutating webhook** (which intercepts GPU pods on their way into the cluster). That is why a healthy HAMi pod reads **2/2**.

**Activity — Terminal:** Find the HAMi pod and confirm both containers are ready:

```bash
kubectl get pods -n kube-system | grep hami
```

Look at the broader set of objects the chart created:

```bash
kubectl get deploy,svc,cm,sa -n kube-system | grep hami
```

You will see a `hami-scheduler` Deployment, a Service the webhook is registered against, a ConfigMap holding the scheduler policy, and a ServiceAccount. Notice there is **no** `hami-device-plugin` DaemonSet — you turned it off at install time.

::image-box
---
:src: __static__/hami-scheduler-webhook-v1.png
:alt: Diagram of the HAMi scheduler pod in the kube-system namespace. A single pod card labeled "hami-scheduler  2/2" is split into two container boxes. The top box "scheduler" shows an arrow to the Kubernetes API server labeled "binds GPU pods to nodes". The bottom box "webhook" shows an arrow from an incoming pod labeled "mutates spec.schedulerName". Below the pod, four small resource cards represent the chart objects: Deployment, Service, ConfigMap, ServiceAccount. A greyed-out, dashed card labeled "device-plugin DaemonSet — DISABLED" sits off to the side with a red X.
:max-width: 860px
---
_One HAMi pod, two jobs: the scheduler container places GPU pods, the webhook container rewrites them on admission. The device-plugin DaemonSet that would partition real GPUs is switched off in this lesson._
::

::hint-box
---
:summary: Why is the HAMi device-plugin OFF here? (the honest core of this lesson)
---
Two reasons, and both matter.

**First, a conflict.** HAMi's device-plugin and fake-gpu-operator's device-plugin would
*both* try to own `nvidia.com/gpu` on the node. Only one can advertise that resource
cleanly, so running both fights over it. We want fake-gpu-operator to win, because it is
the thing simulating the GPUs.

**Second, and deeper:** HAMi's device-plugin is the component that actually carves real VRAM
and compute into slices and enforces the limits inside the container. Fake GPUs have **no real
memory to partition**, so even if it ran, there would be nothing for it to slice. Turning it
off is not a workaround — it is an honest statement that real slicing needs real hardware.

That real device-plugin comes on in **Lesson 6.4**, on a live L4, and that is where
`gpumem`/`gpucores` requests start enforcing actual limits.
::

::simple-task
---
:tasks: tasks
:name: verify_hami_scheduler_running
---
#active
In the **Terminal**, run `kubectl get pods -n kube-system | grep hami-scheduler` and
confirm the pod is **2/2** and **Running** — scheduler plus webhook, both healthy.

#completed
hami-scheduler is 2/2 Running ✓
::

::simple-task
---
:tasks: tasks
:name: verify_fake_gpus_present
---
#active
In the **Terminal**, confirm total `nvidia.com/gpu` capacity across the cluster is **1 or
more** using the `jq` sum command from Section 2.

#completed
Fake GPU capacity is present on the cluster ✓
::

---

## 4. Trace the scheduling chain: webhook → hami-scheduler → placement

Here is the clever part, and it is worth slowing down for. In a normal cluster every pod is placed by the default `kube-scheduler`. HAMi needs GPU pods to go through **its** scheduler instead — but it does not ask you to set `schedulerName` yourself. The **mutating webhook** does it automatically.

The chain, for a pod that requests a GPU:

1. You `kubectl apply` a pod that asks for GPU resources.
2. On admission, HAMi's **mutating webhook** inspects the pod. If it requests GPU resources (and is not told to skip), the webhook rewrites `spec.schedulerName` to **`hami-scheduler`**.
3. The **hami-scheduler** container then picks the node and the specific GPU, accounting for `gpumem`/`gpucores` slices, and binds the pod.
4. The pod lands, sharing a card with whatever else HAMi already placed there.

That is the whole GPU-sharing routing story in four steps — no code in the pod, no manual scheduler selection.

::image-box
---
:src: __static__/hami-scheduling-chain-v1.png
:alt: Numbered flow diagram of the HAMi scheduling chain. Step 1 on the left shows a kubectl apply arrow sending a pod manifest that requests "nvidia.com/gpumem" into the cluster. Step 2 shows the pod passing through a "HAMi mutating webhook" box that stamps "spec.schedulerName = hami-scheduler" onto it, drawn as a label being written. Step 3 shows the pod arriving at a "hami-scheduler" box that evaluates two candidate GPU nodes and picks one, annotated "accounts for gpumem + gpucores slices". Step 4 shows the pod bound onto a node's GPU alongside an existing pod, both sharing one green GPU chip. A side branch shows a second pod labeled "hami.io/webhook: ignore" bypassing the webhook with a dashed arrow straight to the default kube-scheduler.
:max-width: 860px
---
_A GPU pod flows webhook → hami-scheduler → placement. The webhook silently rewrites schedulerName so you never set it by hand. A pod labeled hami.io/webhook ignore skips the webhook and uses the default scheduler instead._
::

Our test pod in the next section takes the **side branch** in that diagram: it carries the label `hami.io/webhook: ignore`. That tells the webhook to leave it alone, so it is placed by the default `kube-scheduler` using the plain `nvidia.com/gpu` count. We do that deliberately here — because the device-plugin is off, there is nothing for `hami-scheduler` to slice, so routing the pod through the default scheduler is the honest way to get it running on a fake GPU.

::hint-box
---
:summary: Is the webhook required for HAMi to work?
---
For HAMi's *automatic* routing, yes — the mutating webhook is what quietly sends GPU pods
to `hami-scheduler` without the user having to set `schedulerName`. You could set
`schedulerName: hami-scheduler` by hand and skip the webhook, but that pushes the burden onto
every pod author. The webhook is the ergonomics layer: it makes GPU sharing transparent to
whoever writes the pod spec.
::

::hint-box
---
:summary: What does hami.io/webhook ignore actually change?
---
It is an opt-out label. With it present, HAMi's webhook does not touch the pod, so
`spec.schedulerName` stays `default-scheduler`. The pod is then scheduled on the plain
`nvidia.com/gpu` integer — no slice accounting. In this fake-GPU lesson that is exactly what
we want. On real hardware in 6.4 you would normally *omit* this label so HAMi takes over and
enforces your `gpumem`/`gpucores` request.
::

---

## 5. The resource model you'll use for real in 6.4: gpumem & gpucores

HAMi replaces the all-or-nothing `nvidia.com/gpu: 1` with two fine-grained knobs:

- **`nvidia.com/gpumem`** — the amount of GPU memory the pod gets, in **MB**. Ask for `4000` and HAMi reserves ~4 GB of VRAM on the card it places you on.
- **`nvidia.com/gpucores`** — the share of **compute**, as a percentage (0–100). Ask for `30` and the pod is limited to roughly 30% of the GPU's streaming multiprocessors.

Together they turn one 24 GB card into, say, five independent 4 GB tenants that cannot stomp on each other's memory. This is the model you will drive for real in Lesson 6.4.

Here is what such a request looks like. **Read it — do not run it here**:

> ⚠️ **Reference only — do not paste this into the terminal.** On these fake GPUs there is
> no real VRAM to carve, and the HAMi device-plugin that enforces these limits is off, so a
> `gpumem`/`gpucores` request has nothing to act on. This snippet is adapted from HAMi's
> `examples/nvidia/default_use.yaml` and is here to show the shape of the model, not to run.

```yaml
# Reference only — runs for real on hardware in Lesson 6.4, NOT on this fake-GPU cluster.
apiVersion: v1
kind: Pod
metadata:
  name: hami-sliced-example
spec:
  containers:
    - name: app
      image: your-cuda-image
      resources:
        limits:
          nvidia.com/gpu: 1          # one physical card...
          nvidia.com/gpumem: 4000    # ...but only 4000 MB of its VRAM
          nvidia.com/gpucores: 30    # ...and only 30% of its compute
```

::image-box
---
:src: __static__/hami-resource-model-gpumem-gpucores-v1.png
:alt: Diagram illustrating the HAMi resource model on one physical GPU. A single large GPU card is drawn in neon green, divided vertically into memory and compute halves. The memory half is split into five stacked blocks each labeled "gpumem: 4000 MB", filling a 24 GB total bar. The compute half shows a circular gauge split into percentage wedges, one highlighted at "gpucores: 30%". Three small pod boxes point to different memory blocks and compute wedges, each labeled "tenant A", "tenant B", "tenant C", showing independent slices of the same card. A caption reads "one 24 GB L4 → many isolated tenants, each with its own gpumem + gpucores".
:max-width: 860px
---
_HAMi's two knobs — gpumem (MB of VRAM) and gpucores (percent of compute) — turn one physical GPU into several isolated tenants. On real hardware the device-plugin enforces these limits; on fake GPUs they are only a model to read._
::

::hint-box
---
:summary: Why can't I just try the gpumem request now and see what happens?
---
You can apply it, but nothing meaningful happens. With the device-plugin off and no real
VRAM behind the fake card, HAMi has nothing to reserve or enforce — the numbers are inert.
Worse, routing it through `hami-scheduler` on a cluster that cannot honor the slice would
just leave you debugging a `Pending` pod for the wrong reason. The model is the lesson here;
the enforcement is Lesson 6.4's job.
::

::hint-box
---
:summary: How is this different from MIG and time-slicing (Lesson 1.3)?
---
In Lesson 1.3 you met three hardware/driver sharing modes. **MIG** physically partitions
certain NVIDIA GPUs into fixed instances in firmware. **Time-slicing** round-robins a whole
GPU between pods with no memory isolation. HAMi is the **software** approach: it enforces
`gpumem`/`gpucores` from a userspace library injected into the container, so it works on GPUs
that do not support MIG and still gives memory isolation that time-slicing cannot. That is why
HAMi is worth a dedicated lesson — it is the most flexible of the three.
::

---

## 6. Run a GPU pod and see a simulated nvidia-smi

Enough reading — put a pod on a fake GPU. The manifest already lives in the repo. It carries `hami.io/webhook: ignore` (so it uses the default scheduler, per Section 4) and `nvidia.com/gpu: 1`.

**Activity — Terminal:** Apply the test pod and watch it schedule:

```bash
kubectl apply -f /workdir/course-1/manifests/hami-fake-gpu-pod.yaml
```

```bash
kubectl get pod hami-fake-gpu-pod -w
```

It should move from `Pending` to `Running` within a few seconds. Press `Ctrl+C` once it is `Running`, then confirm which node it landed on:

```bash
kubectl get pod hami-fake-gpu-pod -o wide
```

Now the payoff — run `nvidia-smi` **inside** the pod. fake-gpu-operator intercepts it and prints a simulated card:

```bash
kubectl exec hami-fake-gpu-pod -- nvidia-smi
```

You will see a simulated **Tesla-K80** with a utilization figure in the 10–30% band (that range comes from the `run.ai/simulated-gpu-utilization: "10-30"` annotation on the pod). No hardware ran a single instruction — the operator fabricated the output.

::image-box
---
:src: __static__/hami-what-needs-real-gpu-v1.png
:alt: Split illustration contrasting what works on fake GPUs versus what needs real hardware. The left half, on a green background, is headed "Works on fake GPUs (this lesson)" and lists cards: "capacity advertising", "HAMi scheduler + webhook", "scheduling chain / schedulerName rewrite", "pod reaches Running", "simulated nvidia-smi output". The right half, on an amber background, is headed "Needs a real GPU (Lesson 6.4)" and lists cards: "real gpumem VRAM partition", "real gpucores compute limit", "OOM on over-request", "binpack vs spread packing", "CUDA execution". A dashed vertical line divides the two halves, with a label "the honest boundary".
:max-width: 860px
---
_Everything in the control plane — advertising, scheduling, routing, a Running pod, a simulated nvidia-smi — works on fake GPUs. Real memory and compute slicing and enforcement sit on the far side of the line, in Lesson 6.4._
::

::hint-box
---
:summary: Why does our pod use the default scheduler and not hami-scheduler?
---
Because of the `hami.io/webhook: ignore` label from Section 4. On these fake GPUs there is
nothing for `hami-scheduler` to slice, so the honest, reliable path is to let the default
scheduler place the pod against the plain `nvidia.com/gpu` count that fake-gpu-operator
advertises. In 6.4, with the real device-plugin on, you drop that label and HAMi takes the
wheel.
::

::hint-box
---
:summary: Why can't we slice memory or compute here? (the scope boundary, stated plainly)
---
Two things are deliberately missing on this cluster: the HAMi **device-plugin is off**, and
the GPUs are **fake** — they have no real VRAM to partition. So `nvidia.com/gpumem` and
`nvidia.com/gpucores` have nothing to reserve or enforce, there is no real memory to run out
of, and there is no genuine binpack-vs-spread packing decision to make.

All of that — real `gpumem`/`gpucores` slicing, OOM-on-overcommit, and binpack vs spread —
happens on a real NVIDIA **L4** in **Lesson 6.4**. This lesson stays on architecture and
workflow on purpose. That is the same split HAMi's own Lab 2 draws.
::

### A quick word on the HAMi WebUI

HAMi ships an optional **WebUI** that visualizes nodes, per-GPU allocation, and utilization trends — a nice operator view once a cluster is carrying real workloads. We do not install it as a graded step here: it needs Prometheus running and a manual `hami.io/node-nvidia-register` annotation on the node (because the device-plugin, which would normally write that, is off). So treat the WebUI as a concept for now; you will have the metrics backing to make it useful after the observability and real-GPU lessons.

::image-box
---
:src: __static__/hami-webui-tour-v1.png
:alt: Mock-up of the HAMi WebUI dashboard. A dark dashboard shows a left sidebar with "Nodes", "GPUs", "Tasks" menu items. The main panel shows a grid of GPU cards, each a green chip with a small bar reading "gpumem used 12 / 24 GB" and "gpucores 45%". A top strip shows a line chart titled "cluster GPU utilization (24h)" with a blue trend line. An overlay banner reads "Requires Prometheus + manual node annotation — not part of the graded path in this lesson".
:max-width: 860px
---
_The HAMi WebUI shows per-node and per-GPU allocation and utilization trends. It needs Prometheus and a manual node annotation to work, so this lesson tours it in prose rather than installing it._
::

::simple-task
---
:tasks: tasks
:name: verify_gpu_pod_scheduled
---
#active
In the **Terminal**, apply `course-1/manifests/hami-fake-gpu-pod.yaml`, then run
`kubectl get pod hami-fake-gpu-pod` and confirm the status is **Running**.

#completed
hami-fake-gpu-pod is Running on a fake GPU ✓
::

---

## Key concepts reference

| Concept | Detail |
|---------|--------|
| fake-gpu-operator | run-ai operator (ns `gpu-operator`) that advertises `nvidia.com/gpu` and answers `nvidia-smi` with no hardware |
| HAMi scheduler | Scheduler container that places GPU pods, accounting for `gpumem`/`gpucores` slices |
| HAMi webhook | Mutating webhook that rewrites a GPU pod's `spec.schedulerName` to `hami-scheduler` on admission |
| `devicePlugin.enabled=false` | Install flag that turns HAMi's device-plugin off — avoids conflict with fake-gpu-operator and reflects that fake GPUs have no VRAM to slice |
| `hami.io/webhook: ignore` | Pod label that opts out of the webhook, so the default scheduler places the pod on the plain `nvidia.com/gpu` count |
| `nvidia.com/gpumem` | Per-pod GPU memory slice, in MB (enforced for real in Lesson 6.4) |
| `nvidia.com/gpucores` | Per-pod GPU compute slice, as a percentage 0–100 (enforced for real in Lesson 6.4) |
| `run.ai/simulated-gpu-node-pool` | Node label telling fake-gpu-operator which node to simulate GPUs on |

---

> **Attribution.** This lesson adapts the approach from [HAMi's Lab 2 — Local Fake GPU
> Setup](https://project-hami.io/) and the [Project-HAMi/hami-workshop](https://github.com/Project-HAMi/hami-workshop)
> (both Apache-2.0). The prose, commands, and diagrams here are original; the install flow and
> the honest fake-GPU scope follow HAMi's own framing. Content was rephrased for compliance
> with licensing restrictions.

::simple-task
---
:tasks: tasks
:name: verify_lesson_complete
---
#active
All 5 checks are green — you've toured HAMi's architecture end to end.

#completed
HAMi architecture lesson complete. Real slicing awaits in Lesson 6.4! ✓
::

---

## Now Prove It

You installed nothing — the playground did — but you can still reconstruct the whole story from memory, which is the real test of understanding:

1. Name the two operators, their namespaces, and which one advertises `nvidia.com/gpu` versus which one schedules against it.
2. Explain, in order, what happens to a GPU pod that does **not** carry `hami.io/webhook: ignore`: who rewrites what, and which scheduler ends up placing it.
3. Say exactly why `devicePlugin.enabled=false` is set here — the conflict reason **and** the no-real-VRAM reason.
4. List two things that work on these fake GPUs and two that genuinely need the real L4 in Lesson 6.4.

There is no automated check for this part. If you can walk a colleague through all four without peeking, you understand HAMi's architecture — and you are ready to do the real slicing in Lesson 6.4.

<!-- TODO: Add platform challenge card once labctl assigns a slug
::card
---
:challenge: challenges.<platform-slug>
---
::
-->
