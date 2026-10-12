---
kind: unit
title: Your Cluster Has No Idea What a GPU Is (Yet)
name: lesson-gpu-fundamentals-unit-1
---

## First, why a GPU at all?

A CPU is a small team of very fast, very clever workers. Four, eight, maybe 64 cores — each one powerful, each one able to handle complex, branching logic on its own. Give a CPU a to-do list with lots of different decisions and it flies through it. That's what runs your operating system, your web server, your database.

A GPU is the opposite shape. Instead of a handful of clever cores, it has **thousands** of simpler ones. No single one is impressive, but together they do the same operation across a mountain of data at the same time. That's called massively parallel computation.

::image-box
---
:src: __static__/cpu-vs-gpu-v2.png
:alt: Side-by-side comparison illustration. Left panel labeled "CPU" shows 8 large glowing blue cores arranged in a grid, each with a gear icon suggesting complex logic, with the caption "a few powerful cores — fast at one task at a time". Right panel labeled "GPU" shows a dense grid of hundreds of small green cores all lit up simultaneously, with the caption "thousands of simple cores — the same operation across huge data, all at once". Below both panels, a shared timeline bar shows the CPU processing matrix operations sequentially (a long thin bar) versus the GPU processing them in parallel (a short wide bar), with the label "same AI workload: GPU finishes 10–100x sooner".
:max-width: 860px
---
_A CPU has a few powerful cores for complex sequential work. A GPU has thousands of simple cores that do the same operation across massive data in parallel — exactly the shape of neural network math._
::

::hint-box
---
:summary: Wait — how much is "a core"? Is a GPU core the same as a CPU core?
---
No, and it's an important distinction. They share a name but they are not the same unit.

A **CPU core** is a full-featured, independent processor. It has its own control
logic, can run a completely different program from the core next to it, handles
branching (`if/else`), and manages its own cache. A modern server CPU has roughly
**8 to 128** of these. Each is genuinely powerful on its own.

A **GPU "core"** (NVIDIA calls them **CUDA cores**) is far simpler. It is not an
independent processor — it's one lane in a much larger execution unit. Thousands of
them run in lockstep, executing the **same instruction** on different pieces of data
at the same time. One CUDA core on its own is weak; the power is in having thousands
act together. A single NVIDIA L4 has **7,424** CUDA cores; an A100 has **6,912** plus
specialized **tensor cores** built just for matrix math.

So "a few vs thousands" isn't an apples-to-apples core count — it's two different
designs. The CPU optimizes for *doing different things quickly*. The GPU optimizes
for *doing the same thing to a lot of data at once*. For a neural network, which is
the same arithmetic repeated billions of times, the GPU's design wins by a wide margin.
::

Here's why that matters for AI. A neural network is, under the hood, a staggering number of multiply-and-add operations on matrices — the same arithmetic, repeated billions of times. On a CPU's few cores that's a slow march. On a GPU's thousands of cores it's done in parallel, often **10–100× faster**. Training a modern model on CPUs would take months or years; on GPUs it takes days. Inference — actually answering your prompt — is the same story: the GPU is what makes the response feel instant instead of taking a minute per sentence.

| | CPU | GPU |
|---|---|---|
| Cores | A few, very powerful | Thousands, simpler |
| Best at | Complex, branching logic — one thing at a time, fast | The same simple operation across huge data, all at once |
| Runs | OS, web servers, databases | Training & inference for AI/ML, graphics, simulation |
| The AI job | Slow — a few workers doing billions of ops in sequence | Fast — thousands of workers doing them in parallel |

So when a company runs AI, it runs on GPUs. And when that AI runs at scale, it runs on GPUs **orchestrated by Kubernetes** — which is where you come in. But before you can schedule a GPU, you have to understand how Kubernetes sees one. The answer is going to surprise you.

::hint-box
---
:summary: Do I need to understand GPU hardware to be good at this?
---
Not deeply. You need the mental model above — parallel vs sequential, why AI maps onto parallel — and that's about it for this course. Your job isn't to design GPUs or write CUDA kernels. Your job is to make Kubernetes schedule, share, and observe them correctly. That's an operations skill, and it's the one that's in short supply.
::

---

## kubectl get nodes shows 8 GPUs. Your cluster has absolutely no idea what a GPU is.

That number — `nvidia.com/gpu: 8` — is just an integer Kubernetes is tracking.
The scheduler treats it like any other resource: decrement it when a pod claims it,
increment it when the pod exits. There is no GPU awareness in the scheduler.
No GPU code. No understanding of VRAM or compute units.

That's actually a clever design. Kubernetes handles the resource accounting.
A **device plugin** — a DaemonSet running on each node — does the hardware work.
Without the device plugin, that number is zero. You'll see this happen in the
first few minutes.

::image-box
---
:src: __static__/gpu-extended-resource-v1.png
:alt: Two-panel diagram showing how Kubernetes models GPU resources. Left panel: a K8s node with status.allocatable listing cpu, memory, and nvidia.com/gpu set to 0, with a red X over a GPU chip and the label 'Without device plugin, K8s cannot allocate GPU resources.' Right panel: the same node after ghostgpu is installed, with nvidia.com/gpu set to 4 and a green checkmark. A device plugin DaemonSet icon connects the two panels with an arrow labeled 'PATCH /api/v1/nodes/name/status'.
:max-width: 860px
---
_Without a device plugin, nvidia.com/gpu is 0. Install ghostgpu and it becomes 4. Kubernetes itself never changed — only the device plugin running on the node._
::

::hint-box
---
:summary: Do I need to know CUDA or GPU hardware internals for this lesson?
---
No. This lesson is about how Kubernetes models GPU resources — not how GPUs work
internally. You'll learn about CUDA and GPU architecture conceptually in later sections
of this module, but this hands-on exercise only needs kubectl, helm, and a working cluster.
::

---

## Wait — where are these nodes coming from? Meet KWOK

You don't have a rack of GPU servers under your desk, and you don't need one.
The cluster in this lab is built with **KWOK — Kubernetes WithOut Kubelet**.

KWOK is a toolkit that spins up a cluster of thousands of nodes in seconds. Under
the hood, every node is **simulated** to behave like a real one — it reports Ready,
accepts pods, updates status, and responds to the scheduler exactly as a physical
node would. But there's no kubelet, no container runtime, and no actual machine
behind it. The nodes are pure Kubernetes API objects whose lifecycle KWOK maintains.

That's what makes this course possible on a laptop. A real 3-node GPU cluster would
cost thousands of dollars an hour. KWOK gives you the same scheduling surface — the
same `kubectl get nodes`, the same pod placement, the same `Pending` behavior — for
a resource footprint of roughly 2 GB of RAM and zero dollars.

::image-box
---
:src: __static__/real-cluster-kwok-v1.png
:alt: Side-by-side comparison illustration. Left panel labeled "Real cluster" shows three physical server racks, each with a kubelet badge and a container runtime badge, connected to a Kubernetes API server, with a red price tag reading "$$$ per hour". Right panel labeled "KWOK cluster" shows the same Kubernetes API server connected to three nodes drawn as dashed-outline ghost boxes marked "simulated — no kubelet, no runtime", with a green tag reading "~2 GB RAM, free". A center label reads "same scheduling surface — the control plane can't tell the difference". A small KWOK logo sits in the top-right of the right panel.
:max-width: 860px
---
_KWOK presents the Kubernetes control plane with the exact same node and pod API objects a real cluster would — minus the kubelet, the runtime, and the bill._
::

| | Real cluster | KWOK cluster |
|---|---|---|
| Nodes | Physical/virtual machines with a kubelet | Simulated API objects, no kubelet |
| Pods | Actually run containers | Simulated as Running — no real execution |
| GPU scheduling | Real device plugin + hardware | Identical scheduling logic, injected GPU capacity |
| Cost to run 3 nodes | Dollars per hour | Free |
| Time to create | Minutes (provision + join) | Seconds |

::hint-box
---
:summary: If the pods don't really run, what am I actually learning?
---
Everything that matters for GPU **operations**. Scheduling, quota, gang scheduling,
preemption, autoscaling decisions, and observability all happen in the Kubernetes
control plane — above the layer where real execution would occur. KWOK simulates
that execution layer so the control plane behaves identically.

What you *won't* do on KWOK is run real GPU code (a CUDA kernel, a vLLM server).
That's exactly why the course has a Tier 2: Modules 6–8 move to a real GPU on GCP
to deploy and benchmark actual inference. Everything up to that point — the hard,
scarce, high-value scheduling and platform skills — you learn here, for free.
::

---

## 1. What your cluster actually knows about hardware

Kubernetes discovers node resources in two steps.

First, the **kubelet** reads the machine's capacity from the OS: CPU cores, RAM,
local storage. These show up in `node.status.capacity`. Kubernetes natively
understands these.

Second, **device plugins** register extended resources with the kubelet via a gRPC
socket at `/var/lib/kubelet/device-plugins/`. The plugin reports how many units
of a custom resource are available. The kubelet patches `node.status.capacity`
with that count. The scheduler then sees it as an allocatable resource — and it
knows nothing about what that resource actually is.

So what does `node.status.capacity` actually look like? It's a field inside the
Node object, which Kubernetes stores as structured data. When you ask for it, you
get YAML (or JSON) — a plain map of resource name to quantity:

```yaml
# kubectl get node <name> -o yaml  → status.capacity section
status:
  capacity:
    cpu: "32"
    memory: 131072000Ki
    pods: "110"
    ephemeral-storage: 209715200Ki
    nvidia.com/gpu: "4"        # ← patched in by the device plugin
  allocatable:
    cpu: "31500m"
    memory: 130023424Ki
    pods: "110"
    ephemeral-storage: 193379953Ki
    nvidia.com/gpu: "4"        # ← same count; GPUs have no system reservation
```

Notice `nvidia.com/gpu` sits right next to `cpu` and `memory` as if it were a
built-in resource. To the scheduler, it is — just another key with a number.

::hint-box
---
:summary: Is the device-plugin-to-kubelet message also YAML?
---
No — that part is **gRPC (protobuf)**, binary on the wire, not YAML or plain text.
The device plugin implements a gRPC service and streams a `ListAndWatchResponse`
protobuf message listing the devices. You never see that message directly; it lives
between the plugin and the kubelet over a Unix socket.

What you *do* see — and what's shown above — is the **result**: the kubelet takes
that gRPC message and patches the Node object's `status.capacity`. The Node object
is stored as JSON in etcd and rendered as YAML or JSON by `kubectl`. So:

- **Plugin → kubelet:** gRPC / protobuf (invisible)
- **Kubelet → API server:** a PATCH to the Node object (JSON)
- **What you query:** `kubectl get node -o yaml` → human-readable YAML
::

::image-box
---
:src: __static__/device-plugin-arch-v1.png
:alt: Architecture diagram of the Kubernetes device plugin mechanism. On a node, a device plugin DaemonSet pod registers with the kubelet over a gRPC socket at /var/lib/kubelet/device-plugins/. An arrow labeled "ListAndWatch gRPC" flows from the device plugin to the kubelet. The kubelet then sends a "PATCH node.status.capacity" arrow up to the Kubernetes API server, adding "nvidia.com/gpu: 4" to the node's allocatable resources. On the right, the kube-scheduler reads the node status and is shown placing a GPU-requesting pod onto the node, with a thought-bubble label "I see 4 units of nvidia.com/gpu — I don't know or care what they are".
:max-width: 860px
---
_The device plugin tells the kubelet how many units exist over a gRPC socket. The kubelet patches the node's capacity. The scheduler just sees a number — it never learns what the resource actually is._
::

**Extended resources** are the mechanism. Any string in the form `vendor.com/resource`
is a valid extended resource. `nvidia.com/gpu` is just a well-known string the
NVIDIA device plugin registers. Kubernetes could just as easily track `acme.com/widget`.

In the **Terminal**, inspect your cluster's current resource picture:

```bash
kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, allocatable: .status.allocatable}'
```

You'll see `cpu`, `memory`, `pods`, `ephemeral-storage` — and no `nvidia.com/gpu`.
That's expected. No device plugin has registered GPU resources yet.

::image-box
---
:src: __static__/kubernetes-nodes-resources-v1.png
:alt: Illustration of a Kubernetes node's status.allocatable resource map. A node box lists its standard advertised resources as rows — cpu, memory, pods, ephemeral-storage — each with a value and a small icon. A greyed-out, dashed row at the bottom labeled nvidia.com/gpu shows a question mark and the note "not present — no device plugin has registered it". The scheduler is shown on the side reading only the four solid rows.
:max-width: 860px
---
_A fresh node advertises only its built-in resources. `nvidia.com/gpu` is absent — nothing has registered it yet. That's the GPU-shaped hole you're about to fill._
::

::hint-box
---
:summary: What is .status.allocatable vs .status.capacity?
---
`.status.capacity` is the total resources on the node.
`.status.allocatable` is capacity minus what the OS and system daemons reserve.
When you schedule pods, the scheduler uses `allocatable` — not `capacity`.

For extended resources like `nvidia.com/gpu`, both fields are typically the same
number because there's no system reservation for GPUs. The distinction matters for
cpu and memory where the kubelet reserves headroom for itself.
::

::simple-task
---
:tasks: tasks
:name: verify_node_allocatable
---
#active
In the **Terminal**, run `kubectl get nodes` and confirm at least 2 nodes show
**Ready** status. The KWOK virtual nodes should already be running.

#completed
KWOK virtual nodes are Ready ✓
::

---

## 2. The GPU-shaped hole in your cluster

Your cluster has nodes. The nodes have CPU and memory. But from the scheduler's
perspective, GPUs don't exist yet.

::hint-box
---
:summary: Re-running this lesson? Reset first.
---
`verify_no_gpu_before` checks that GPU capacity has **not** been injected yet. If you're
retrying this lesson on a cluster where you already ran the inject step, remove the
capacity from the nodes first:

```bash
for n in $(kubectl get nodes -l nvidia.com/gpu.present=true -o name); do
  kubectl patch "$n" --subresource=status --type=json \
    -p '[{"op":"remove","path":"/status/capacity/nvidia.com~1gpu"},
         {"op":"remove","path":"/status/allocatable/nvidia.com~1gpu"}]' 2>/dev/null || true
done
```

Then continue from Step 2. The remaining tasks are all idempotent.
::

**Activity — Terminal:** Look for GPU resources on a node:

```bash
# Pick the first node name
NODE=$(kubectl get nodes --no-headers | awk 'NR==1{print $1}')

# Show its extended resources — nvidia.com/gpu will be absent
kubectl get node $NODE -o json | jq '.status.allocatable | to_entries[] | select(.key | startswith("nvidia"))'
```

No output. That's the GPU-shaped hole.

Now see what happens when you try to schedule a GPU-requesting pod:

```bash
tee /tmp/gpu-pending-test.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pending-demo
spec:
  containers:
  - name: test
    image: busybox:1.36
    resources:
      requests:
        nvidia.com/gpu: "1"
      limits:
        nvidia.com/gpu: "1"
  restartPolicy: Never
EOF
kubectl apply -f /tmp/gpu-pending-test.yaml
```

Watch its status:

```bash
kubectl get pod gpu-pending-demo -w
```

It stays `Pending`. Press `Ctrl+C` to stop watching.

::hint-box
---
:summary: What are extended resources? How does Kubernetes know this isn't a real resource?
---
Extended resources are any capacity advertised under a namespaced key like `vendor.com/name`.
Kubernetes treats them as opaque integers. It doesn't validate whether the resource
is "real" — it just tracks the count.

If you patch a node's status with `acme.com/widget: 100`, the scheduler will
happily assign `acme.com/widget: 1` pods to that node, no questions asked.
That's exactly what ghostgpu does — it patches `nvidia.com/gpu` into virtual node
status. The scheduler can't tell the difference between a virtual GPU and a real one.
::

::hint-box
---
:summary: Why does the pod stay Pending instead of failing with an error?
---
The scheduler puts pods in `Pending` when it can't find a node that satisfies
all resource requests. It doesn't fail the pod — it keeps trying on every
scheduling cycle in case a node with capacity shows up later.

`Pending` is the correct and expected state here. Once you install ghostgpu
and the nodes report `nvidia.com/gpu` capacity, the scheduler will find a fit
and the pod will move to `Running`.
::

Clean up the demo pod before moving on:

```bash
kubectl delete pod gpu-pending-demo
```

::simple-task
---
:tasks: tasks
:name: verify_no_gpu_before
---
#active
In the **Terminal**, confirm that `nvidia.com/gpu` does **not** appear in any
node's allocatable resources. The command above with `jq` should return no output.

#completed
No nvidia.com/gpu resources found — cluster is GPU-naive ✓
::

---

## 3. Inject GPU capacity — be the device plugin yourself

Here's the honest truth most tutorials hide behind an operator: advertising a GPU
to Kubernetes is **just a PATCH to the node's status**. That's it. A real NVIDIA
device plugin does exactly one meaningful thing — it tells the kubelet "this node
has 4 GPUs," and the kubelet writes `nvidia.com/gpu: 4` into `status.capacity`.

On a KWOK cluster there's no kubelet and no device plugin pod to do that for us. So
we do it directly — we patch the node status ourselves. The scheduler cannot tell
the difference. To it, a patched `nvidia.com/gpu: 4` is a GPU, full stop.

::image-box
---
:src: __static__/ghostgpu-architecture-v1.png
:alt: Diagram showing GPU capacity injection on a KWOK node. A kubectl patch command on the left sends 'PATCH /api/v1/nodes/{name}/status' to the Kubernetes API server in the center, writing nvidia.com/gpu: 4 into the node's status.allocatable and status.capacity. On the right, the kube-scheduler reads the node and now sees 4 schedulable GPUs. A footer note reads 'KWOK virtual node — no kubelet, no device plugin, no real hardware. The status patch IS the GPU.'
:max-width: 860px
---
_On KWOK you patch `nvidia.com/gpu` straight into the node status — the same field a real device plugin makes the kubelet write. The scheduler treats both identically._
::

::hint-box
---
:summary: Why not use the fake-gpu-operator / a real device plugin here?
---
A real device plugin (and tools like run.ai's fake-gpu-operator) run as a **pod on
the node** that registers GPUs with the kubelet over a gRPC socket. KWOK nodes have
**no kubelet**, and KWOK only *simulates* pods — they show `Running` but their
containers never actually execute. So an operator's pods would be a façade: green
status, but their code never runs and no capacity ever gets patched.

Patching the node status directly is the reliable KWOK-native approach — and it
teaches you exactly what a device plugin accomplishes, without the moving parts.
You'll meet the real NVIDIA device plugin on real hardware in Module 6.
::

**Activity — Terminal:** Inject GPU capacity. The repo ships a small script that
patches every GPU node — but let's do it by hand first so you see the mechanism:

```bash
# Patch one node's status: add nvidia.com/gpu to capacity AND allocatable.
# --subresource=status is required — nvidia.com/gpu lives under .status, not .spec.
kubectl patch node gpu-worker-1 --subresource=status --type=merge -p '{
  "status": {
    "capacity":    {"nvidia.com/gpu": "4"},
    "allocatable": {"nvidia.com/gpu": "4"}
  }
}'
```

Confirm it took:

```bash
kubectl get node gpu-worker-1 -o json | jq '.status.allocatable["nvidia.com/gpu"]'
```

You should see `"4"`. Now do all the GPU nodes at once with the course script:

```bash
bash /workdir/course-1/scripts/install-ghostgpu.sh
```

> The script name is `install-ghostgpu.sh` for continuity with the course, but as
> you now know, it isn't installing an operator — it's patching node status. That's
> the whole trick.

::hint-box
---
:summary: Would this patch work on a REAL cluster?
---
On a real cluster you would **never** patch GPU capacity by hand — the NVIDIA
device plugin does it for you based on the actual hardware it detects, and
overwriting that would break real scheduling. This direct-patch technique is
specific to KWOK simulation, where there's no hardware and no plugin.

The value is conceptual: you've now seen that "advertising a GPU" is nothing more
than a number in node status. That demystifies everything the GPU Operator does in
Module 6 — it's a lot of machinery whose end result is the same patch you just did.
::

::hint-box
---
:summary: What about DRA — the newer Dynamic Resource Allocation API?
---
DRA (**Dynamic Resource Allocation**) is a newer Kubernetes API for hardware that's
more expressive than the extended-resource integer model. Instead of just counting
units, DRA describes structured attributes (memory, topology, NUMA node) via
`ResourceSlice` objects and `ResourceClaim`s.

This lesson uses the classic **extended resource** path (`nvidia.com/gpu` as an
integer) because it's what the vast majority of real GPU clusters still run today,
and it's the clearest way to see how the scheduler accounts for GPUs. DRA is a
dedicated topic — you'll build a ResourceSlice-based setup in Module 2.
::

::simple-task
---
:tasks: tasks
:name: verify_ghostgpu_installed
---
#active
In the **Terminal**, run the inject step (`install-ghostgpu.sh`, or the manual
`kubectl patch`) and confirm at least one node now has `nvidia.com/gpu` in its
`status.capacity`.

#completed
GPU capacity injected into node status ✓
::

---

## 4. Your cluster can see GPUs now

With the status patch applied, every virtual node now reports `nvidia.com/gpu` in its
allocatable resources.

**Activity — Terminal:** Compare before and after:

```bash
# See GPU capacity on every node
kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, gpu: .status.allocatable["nvidia.com/gpu"]}'
```

You should see `"gpu": "4"` on each node — the value the inject step patched in.

Check the overall cluster GPU inventory:

```bash
kubectl get nodes -o custom-columns=\
'NAME:.metadata.name,CPU:.status.allocatable.cpu,MEM:.status.allocatable.memory,GPU:.status.allocatable.nvidia\.com/gpu'
```

We advertised GPUs the classic way — an extended-resource integer in node status.
The newer DRA model would instead describe each GPU as a `ResourceSlice` object:

```bash
# We didn't create any ResourceSlices, so this returns none (or "No resources found").
# That's expected — we used the extended-resource path, not DRA.
kubectl get resourceslices.resource.k8s.io 2>/dev/null || echo 'DRA API not enabled in this cluster'
```

No ResourceSlices — because we didn't create any. You'll build a DRA-based GPU
setup in Module 2 and see how `ResourceSlice` objects differ from the integer
`nvidia.com/gpu` count you just patched.

::hint-box
---
:summary: What is a ResourceSlice? How does it differ from extended resources?
---
A `ResourceSlice` is a DRA object that describes a specific hardware instance with
structured attributes — serial number, VRAM amount, PCIe topology, NUMA node affinity.

Extended resources (`nvidia.com/gpu: 4`) are opaque integers — the scheduler knows
there are 4 GPUs but nothing about them individually.

For this course the distinction is mostly conceptual: you'll schedule workloads using
the `nvidia.com/gpu` extended resource, which works identically against real and virtual GPUs.
DRA becomes relevant when you need topology-aware placement or fractional GPU sharing
(covered in the MIG module).
::

::simple-task
---
:tasks: tasks
:name: verify_gpu_capacity
---
#active
In the **Terminal**, confirm that at least one node reports `nvidia.com/gpu` capacity
of 1 or more. The `jq` command above should show a non-null `"gpu"` value.

#completed
nvidia.com/gpu capacity found on cluster nodes ✓
::

---

## 5. Schedule your first GPU pod

Time to actually schedule something. The manifest is already in the repo — apply it directly:

**Activity — Terminal:**

```bash
kubectl apply -f /workdir/course-1/manifests/gpu-test-pod.yaml
```

Watch it schedule:

```bash
kubectl get pod gpu-test -w
```

Unlike the earlier `gpu-pending-demo`, this one should move from `Pending` to
`Running` within a few seconds. Press `Ctrl+C` when it shows `Running`.

Verify which node it landed on:

```bash
kubectl get pod gpu-test -o wide
```

Check the node's remaining GPU capacity — it should have dropped from 4 to 3:

```bash
NODE=$(kubectl get pod gpu-test -o jsonpath='{.spec.nodeName}')
kubectl get node $NODE -o json | jq '.status.allocatable["nvidia.com/gpu"]'
```

::hint-box
---
:summary: Why does requests: nvidia.com/gpu: 1 AND limits: nvidia.com/gpu: 1?
---
For extended resources, Kubernetes requires `requests` and `limits` to be **equal**.
You can't set `requests: 1` and `limits: 2` — the API will reject it.

This is different from CPU and memory where requests and limits can differ.
Extended resources are treated as all-or-nothing: the pod gets exactly what it
requests, and the node's count decrements by that amount.

On a real NVIDIA GPU, this means one GPU is exclusively allocated to the pod.
No sharing, no partial allocation — unless you use MIG (covered in Module 5)
or time-slicing (an advanced GPU Operator feature).
::

::simple-task
---
:tasks: tasks
:name: verify_gpu_pod_scheduled
---
#active
In the **Terminal**, run `kubectl get pod gpu-test` and confirm the pod
status shows **Running**.

#completed
gpu-test pod is Running ✓
::

---

## 6. Break it — what happens when you ask for too much

Here's where it gets interesting. Your cluster has `4 GPUs × 3 nodes = 12 GPUs`
total. What happens when you ask for 99?

**Activity — Terminal:**

```bash
tee /tmp/gpu-greedy-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: gpu-greedy
spec:
  containers:
  - name: greedy
    image: busybox
    resources:
      requests:
        nvidia.com/gpu: 99
      limits:
        nvidia.com/gpu: 99
  restartPolicy: Never
EOF
kubectl apply -f /tmp/gpu-greedy-pod.yaml
```

Watch the event stream:

```bash
kubectl describe pod gpu-greedy | grep -A5 Events
```

You'll see: `Insufficient nvidia.com/gpu`. The scheduler tried every node,
found none with 99 GPU capacity, and put the pod in `Pending` with that reason.

Check the pod status directly:

```bash
kubectl get pod gpu-greedy
```

Still `Pending`. It will stay there until it's deleted or until a node with
99 GPU capacity shows up — which won't happen.

Now look at the node — your existing `gpu-test` pod is still Running, unaffected:

```bash
kubectl get pods
```

::hint-box
---
:summary: This is exactly what happens in production.
---
When your ML team submits 4 training jobs each requesting 8 GPUs, and your cluster
only has 16 GPUs total — the scheduler puts jobs 3 and 4 in `Pending`.

They'll stay Pending until:
- Jobs 1 or 2 complete and return GPUs
- A new node with GPU capacity joins the cluster (via autoscaler)
- Or forever, if nobody's watching

The solution is **Kueue** — covered in Module 3. Kueue adds a queue, priority,
fairness, and borrowing on top of the raw scheduler. Without it, your GPU cluster
is first-come, first-served with no visibility.
::

Clean up:

```bash
kubectl delete pod gpu-greedy
```

---

## Key concepts reference

| Concept | Detail |
|---------|--------|
| Extended resource | Any resource not built into Kubernetes (cpu/memory) — registered via node patch or device plugin |
| Device plugin | A DaemonSet that advertises hardware to kubelet via a gRPC socket at `/var/lib/kubelet/device-plugins/` |
| allocatable | Resources available for pod scheduling after system and daemon reservations |
| ghostgpu | KWOK simulation tool that injects `nvidia.com/gpu` into virtual node status |
| ResourceSlice | DRA (Dynamic Resource Allocation) object — newer, more expressive than extended resource integers |
| Pending pod | Pod waiting for schedulable resources — check `Events: Insufficient nvidia.com/gpu` |

---

## Now Prove It

You've injected GPU capacity by patching node status, scheduled a GPU pod, and seen
what `Insufficient nvidia.com/gpu` looks like.

Here's a self-directed challenge to close the loop:

**Without looking at the scripts**, recreate the state from scratch:

1. Delete the `gpu-test` pod, then remove `nvidia.com/gpu` from every node's status
   (patch it away, the reverse of what you did in Section 3).
2. Confirm the cluster shows zero GPU capacity again.
3. Re-inject capacity, but this time patch **2** GPUs per node instead of 4.
4. Schedule a pod requesting 2 GPUs — it should land. Then try requesting 3 — it should `Pending`.

There's no automated check for this part. The point is that you can reconstruct the full flow
from memory — and that you understand GPU capacity is just a number you control in node status.
If you can do that, you're ready for Module 2.

<!-- TODO: Add platform challenge card once labctl assigns a slug
::card
---
:challenge: challenges.<platform-slug>
---
::
-->

::simple-task
---
:tasks: tasks
:name: verify_lesson_complete
---
#active
All 5 tasks are green — this lesson is complete.

#completed
GPU Fundamentals lesson complete. On to the next one! ✓
::
