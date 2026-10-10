---
inclusion: manual
---

# Visual Style Guide — Image Generation Prompts

All images across all three courses must follow this visual specification.
Use these prompts as the base for every AI-generated image (Gemini, Midjourney, DALL-E, etc.).
Consistency across 24+ lessons and 3 courses is the goal.

---

## Design System

### Color palette
| Role | Color | Hex |
|------|-------|-----|
| Background | Deep navy | `#0D1117` |
| Primary accent | Electric blue | `#2F81F7` |
| GPU / hardware accent | Neon green | `#39D353` |
| Warning / alert | Amber | `#F0883E` |
| Error / failure | Coral red | `#F85149` |
| Text / labels | Off-white | `#E6EDF3` |
| Subtle grid / lines | Muted steel | `#21262D` |

### Typography in diagrams
- Labels: clean sans-serif (Inter or similar), white or off-white
- Code snippets in diagrams: monospace, electric blue tint
- Never use decorative or script fonts

### Style rules
- **Flat technical illustration** — no photorealism, no gradients on solid shapes
- Subtle hexagonal grid or circuit-trace background texture (low opacity, ~10%)
- Node/server cards: rounded rectangles, dark fill (`#161B22`), thin blue border
- GPU chips inside nodes: bright green glow, NVIDIA-green tint
- Arrows and flows: thin, straight or 90° elbow lines with arrowheads
- Status indicators: colored dots (green = Ready, amber = Pending, red = Failed)
- Terminal windows: dark card with green prompt `$` and monospace output
- Aspect ratio: **16:9** for all course covers and module covers
- Aspect ratio: **4:3 or 16:9** for lesson diagrams (`::image-box`)

---

## Base prompt fragment (append to every generation)

> Style: flat technical illustration, dark navy background (#0D1117), electric blue (#2F81F7) and neon green (#39D353) accents, off-white (#E6EDF3) labels, subtle hexagonal grid texture at 10% opacity, no photorealism, no gradients on solid elements, clean sans-serif labels, developer education platform aesthetic. Aspect ratio 16:9.

Always end your specific prompt with this fragment.

---

## Course cover images

### Course 1 — GPU Engineering on Kubernetes

**File:** `course-1/__static__/cover.png`
**Referenced in:** `course-1/index.md` as `cover: __static__/cover.png`

**Prompt:**
> A dark-themed technical illustration for a Kubernetes GPU training course. A glowing Kubernetes helm wheel in electric blue sits at the center. Branching from it are three connected server node cards, each with a bright green GPU chip visible inside labeled "nvidia.com/gpu: 4". Above the cluster, a translucent scheduling queue shows three colored job blocks (blue, amber, purple) waiting to be dispatched. Bottom-left shows a small terminal window with `kubectl get nodes` and green "Ready" status text. Top-right corner shows a faint GCP logo and NVIDIA logo watermark. Style: flat technical illustration, dark navy background (#0D1117), electric blue (#2F81F7) and neon green (#39D353) accents, off-white (#E6EDF3) labels, subtle hexagonal grid texture at 10% opacity, no photorealism, no gradients on solid elements, clean sans-serif labels, developer education platform aesthetic. Aspect ratio 16:9.

---

### Course 2 — Building Production LLM Applications

**File:** `course-2/__static__/cover.png`

**Prompt:**
> A dark-themed technical illustration for an LLM application engineering course. On the left, a Python FastAPI service box connects via an arrow labeled "HTTP /v1/chat" to a LangGraph state machine diagram in the center — showing nodes for "retrieve", "assess", "generate", "verify" with conditional edges. The state machine connects to a vLLM inference server box on the right showing a GPU chip and "tokens/s" metric. Below, a Langfuse trace timeline shows nested spans with latency bars in electric blue. Top-right shows a small Grafana panel with a DCGM GPU utilization spike. Style: flat technical illustration, dark navy background (#0D1117), electric blue (#2F81F7) and neon green (#39D353) accents, off-white (#E6EDF3) labels, subtle hexagonal grid texture at 10% opacity, no photorealism, developer education platform aesthetic. Aspect ratio 16:9.

---

### Course 3 — Multi-Node GPU Clusters

**File:** `course-3/__static__/cover.png`

**Prompt:**
> A dark-themed technical illustration for a multi-node GPU cluster engineering course. Two server chassis are shown side by side, each containing 8 green GPU chips in a 2×4 grid. Between the chassis, thick InfiniBand cables glow amber with data flow arrows labeled "NDR400 — 400 Gb/s". Above, an NCCL all-reduce ring pattern shows tensors flowing between all 16 GPUs with curved arrows. Bottom-left shows a FinOps cost gauge — a half-circle meter in green-to-red showing "cost-per-token: $0.0003". Bottom-right shows a terminal with `NCCL_DEBUG=INFO` output. Style: flat technical illustration, dark navy background (#0D1117), electric blue (#2F81F7) and neon green (#39D353) accents, amber (#F0883E) for network links, off-white (#E6EDF3) labels, subtle hexagonal grid texture at 10% opacity, no photorealism, developer education platform aesthetic. Aspect ratio 16:9.

---

## Module cover images

Module covers are smaller visual summaries used in the course table of contents.
Same style rules, slightly simpler composition than course covers.

### Template prompt structure for module covers:
> A compact dark-themed technical illustration representing [MODULE TOPIC]. [1-2 sentence specific description of the key visual elements]. Style: flat technical illustration, dark navy background (#0D1117), electric blue (#2F81F7) and neon green (#39D353) accents, off-white (#E6EDF3) labels, subtle hexagonal grid texture at 10% opacity, no photorealism, developer education platform aesthetic. Aspect ratio 16:9.

### Module covers to generate (Course 1):

| Module | File | Key visual |
|--------|------|-----------|
| M1 — GPU Fundamentals | `course-1/module-1/__static__/cover.png` | A K8s node card with `nvidia.com/gpu: 0` on the left, arrow pointing right to same node with `nvidia.com/gpu: 4` after ghostgpu install. Device plugin DaemonSet icon above the arrow. |
| M2 — Simulating GPU Clusters | `course-1/module-2/__static__/cover.png` | KWOK logo (stylized K) surrounded by 6 virtual node cards marked "fake" in dashed borders, each showing GPU capacity. `kwokctl` terminal command visible. |
| M3 — GPU-Aware Scheduling | `course-1/module-3/__static__/cover.png` | Kueue ClusterQueue box at top with quota bars (3/4 GPUs used), two LocalQueue boxes below with job blocks queued. Volcano gang-scheduling icon (linked pods) on the right. |
| M4 — Node Lifecycle & Autoscaling | `course-1/module-4/__static__/cover.png` | GKE Cluster Autoscaler arrow scaling a node pool from 0 to 3 nodes. Spot instance price tag icon. Scale-to-zero timer showing idle countdown. |
| M5 — GPU Observability | `course-1/module-5/__static__/cover.png` | Grafana dashboard panel showing 4 DCGM metric sparklines: GPU util, VRAM, temp, XID errors. One XID spike highlighted in red. |
| M6 — GPU Operator | `course-1/module-6/__static__/cover.png` | NVIDIA GPU Operator stack diagram: driver → toolkit → device plugin → DCGM exporter, each as a stacked layer card on a GKE node. |
| M7 — LLM Inference | `course-1/module-7/__static__/cover.png` | vLLM server box with PagedAttention memory blocks visualized, continuous batching queue, OpenAI-compatible API endpoint label. Tokens/s metric prominent. |
| M8 — Capstone | `course-1/module-8/__static__/cover.png` | Three team namespaces (Team A, B, C) each with a LocalQueue, all feeding into a shared ClusterQueue. GPU util Grafana panel. Cost gauge showing < $10. |

---

## Lesson diagram images (`::image-box`)

Each lesson references diagrams in its `__static__/` folder. Check the `.todo` files
for the specific description of each diagram. Apply the base style above.

**Naming convention:** `<concept>-<descriptor>-v<N>.png`
- Always increment `v1` → `v2` when replacing — never overwrite
- Keep filenames lowercase with hyphens

---

## Quick generation checklist

Before generating any image:
- [ ] Background is `#0D1117` (deep navy) — not black, not dark grey
- [ ] Primary elements use `#2F81F7` (electric blue) or `#39D353` (neon green)
- [ ] Labels are readable off-white (`#E6EDF3`)
- [ ] No photorealism, no lens flares, no gradients on solid shapes
- [ ] Grid texture is subtle (≤10% opacity)
- [ ] Aspect ratio matches the intended use (16:9 for covers, 4:3 or 16:9 for diagrams)
- [ ] Append the base prompt fragment to your specific prompt
