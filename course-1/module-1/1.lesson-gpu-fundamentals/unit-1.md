---
kind: unit
title: Your Cluster Has No Idea What a GPU Is (Yet)
name: lesson-gpu-fundamentals-unit-1
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

**Extended resources** are the mechanism. Any string in the form `vendor.com/resource`
is a valid extended resource. `nvidia.com/gpu` is just a well-known string the
NVIDIA device plugin registers. Kubernetes could just as easily track `acme.com/widget`.

In the **Terminal**, inspect your cluster's current resource picture:

```bash
kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, allocatable: .status.allocatable}'
```

You'll see `cpu`, `memory`, `pods`, `ephemeral-storage` — and no `nvidia.com/gpu`.
That's expected. No device plugin has registered GPU resources yet.

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
`verify_no_gpu_before` checks that ghostgpu is **not** installed yet. If you're retrying
this lesson on a cluster where ghostgpu is already running, uninstall it first:

```bash
helm uninstall ghostgpu -n kube-system
kubectl wait --for=delete pods -l app=fake-gpu-operator -n kube-system --timeout=60s
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

## 3. Installing ghostgpu — teaching your cluster what a GPU is

**ghostgpu** (also called fake-gpu-operator) is a DaemonSet that patches KWOK
virtual node status to inject `nvidia.com/gpu` into `status.allocatable`.
It also creates DRA `ResourceSlices` — more on those in Section 4.

The important point: ghostgpu simulates the same contract a real NVIDIA device plugin
satisfies. From the Kubernetes scheduler's perspective, the result is identical to
real GPU hardware.

::image-box
---
:src: __static__/ghostgpu-architecture-v1.png
:alt: Architecture diagram showing the ghostgpu DaemonSet installation flow. A ghostgpu DaemonSet pod runs on a KWOK virtual node shown as a dashed box. An arrow from the DaemonSet to the node status is labeled 'PATCH /api/v1/nodes/{name}/status'. Three numbered steps are annotated: step 1 'ghostgpu pod starts on labeled node', step 2 'PATCH adds nvidia.com/gpu: 4 to status.allocatable', step 3 'kubectl describe node shows nvidia.com/gpu: 4 in Allocatable'. A footer note reads 'KWOK virtual nodes — no real hardware involved.'
:max-width: 860px
---
_ghostgpu's DaemonSet patches each KWOK node's status.allocatable via the Kubernetes API — no real GPU hardware involved._
::

**Activity — Terminal:** Install ghostgpu via Helm:

```bash
# Add the KWOK fake-gpu-operator Helm repository
# Source: https://github.com/kubernetes-sigs/kwok/tree/main/charts/fake-gpu-operator
helm repo add fake-gpu-operator https://kwok.sigs.k8s.io/charts
helm repo update

# Install ghostgpu into kube-system
# gpu.count: number of GPUs per virtual node
# gpu.memory: VRAM per GPU in MiB (24576 MiB = 24 GB, matching an NVIDIA L4)
helm install ghostgpu fake-gpu-operator/fake-gpu-operator \
  --namespace kube-system \
  --set gpu.count=4 \
  --set gpu.memory=24576
```

> ⏱️ This can take 30–60 seconds for the DaemonSet to start and patch all nodes.

Watch the DaemonSet roll out:

```bash
kubectl rollout status daemonset -n kube-system --timeout=120s
```

::hint-box
---
:summary: Is ghostgpu safe to use on a real cluster? Will it affect real GPU nodes?
---
ghostgpu is designed for KWOK virtual clusters used in labs and testing. Do NOT
install it on a cluster with real GPU nodes — it would overwrite the real device
plugin's reported capacity with fake values, breaking GPU scheduling for real workloads.

If you're running this lesson on the iximiuz playground, you're on a KWOK virtual
cluster. Real GPU hardware is introduced in Module 6 on GCP.
::

::hint-box
---
:summary: What does DRA mean? Do I need to understand it now?
---
DRA stands for **Dynamic Resource Allocation** — a newer Kubernetes API for
hardware resources that's more expressive than the extended resource integer model.
Instead of just counting units, DRA can describe structured resource attributes
(memory, topology, NUMA node, etc.) via `ResourceSlice` objects.

You don't need to understand DRA internals to complete this lesson. ghostgpu
creates `ResourceSlices` alongside the extended resource patch so the cluster
matches what a real NVIDIA GPU Operator would produce. You'll revisit DRA in
Module 5 when you work with real GPU Operator.
::

::simple-task
---
:tasks: tasks
:name: verify_ghostgpu_installed
---
#active
In the **Terminal**, run `helm list -n kube-system` and confirm the **ghostgpu**
release shows status **deployed**.

#completed
ghostgpu Helm release deployed ✓
::

---

## 4. Your cluster can see GPUs now

With ghostgpu running, every virtual node should now report `nvidia.com/gpu` in its
allocatable resources.

**Activity — Terminal:** Compare before and after:

```bash
# See GPU capacity on every node
kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, gpu: .status.allocatable["nvidia.com/gpu"]}'
```

You should see `"gpu": "4"` on each node — the value you set with `--set gpu.count=4`.

Check the overall cluster GPU inventory:

```bash
kubectl get nodes -o custom-columns=\
'NAME:.metadata.name,CPU:.status.allocatable.cpu,MEM:.status.allocatable.memory,GPU:.status.allocatable.nvidia\.com/gpu'
```

Now check if DRA ResourceSlices are present:

```bash
kubectl get resourceslices.resource.k8s.io 2>/dev/null || echo 'DRA ResourceSlices not available in this K8s version'
```

If your cluster is Kubernetes 1.31+ and has the DRA feature gate enabled, you'll see
`ResourceSlice` objects — one per virtual GPU per node. On older versions, only the
extended resource integer is used.

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

---

## Now Prove It

You've installed ghostgpu, scheduled a GPU pod, and seen what `Insufficient nvidia.com/gpu` looks like.

Here's a self-directed challenge to close the loop:

**Without looking at the scripts or manifests**, recreate the state from scratch on a clean cluster:

1. Delete the `gpu-test` pod and uninstall ghostgpu.
2. Confirm the cluster shows zero GPU capacity.
3. Re-install ghostgpu with a different GPU count (`--set gpu.count=2`).
4. Schedule a pod requesting 2 GPUs — it should land. Then try requesting 3 — it should `Pending`.

There's no automated check for this part. The point is that you can reconstruct the full flow
from memory. If you can do that, you're ready for Module 2.

<!-- TODO: Add platform challenge card once labctl assigns a slug
::card
---
:challenge: challenges.<platform-slug>
---
::
-->
