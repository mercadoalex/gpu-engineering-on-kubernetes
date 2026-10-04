---
inclusion: auto
name: budget-rules
description: Cost guardrails, GCP billing limits, Kueue quotas, and per-student budget targets
---

# Budget Rules & Cost Guardrails

## Target: < $10 per student per session

This is the hard ceiling. Every architectural decision is evaluated against it.

## Budget Summary

| Item | Cost |
|------|------|
| iximiuz Labs (Tinkerer/creator plan) | ~$25–50/mo |
| GCP GPU — 15 students × 2 hrs/week × spot | ~$42/mo |
| **Total infra** | **~$70/mo** |
| Course 1 student price | $50–100 one-time |
| Course 2 student price | $75–150 one-time |
| Course 3 student price (4-hr multi-node) | ~$8–12/student (shared 2-node cluster) |

## Per-Session Cost Targets

| Scenario | Target | How |
|----------|--------|-----|
| C1 Tier 2 session (single student, L4) | ~$3–8 | 4 hr × $0.71/hr spot + scale-to-zero |
| C1 multi-student (A100 MIG, 7 students) | ~$0.16/student/hr | `1g.5gb` MIG partition per student |
| C2 Tier 2 session | ~$0 incremental | Reuses C1 GPU endpoint |
| C3 multi-node session (4–6 students sharing) | ~$8–12/student | RunPod 2× A100 IB cluster, ~$20–30/hr split |

## GCP Guardrails (enforce on every cluster)

```yaml
# GKE Cluster Autoscaler — every GPU node pool
minNodeCount: 0        # scale-to-zero when idle
maxNodeCount: 3        # hard cap, prevents runaway scaling
```

- Use **spot instances** for all Tier 2 GPU nodes.
- Set a **GCP billing alert at $30/mo** (email + Pub/Sub to Slack).
- GPU nodes must scale to zero when no workloads are queued.
- Region: `us-west1` only — do not provision GPU nodes in other regions without explicit approval.

## Kueue Quota Rules (self-paced sessions)

```yaml
# ClusterQueue for self-paced students
nominalQuota:
  nvidia.com/gpu: 1      # 1 GPU per student, hard limit

# WorkloadClass or PriorityClass
activeDeadlineSeconds: 7200   # 2-hour session hard stop
```

- No borrowing beyond cohort for self-paced tier.
- Instructor-led (ILT) sessions may use a separate cohort with higher quota.
- Gang jobs (Volcano) must set `minAvailable` — a job that can't get all GPUs should not
  hold partial allocations and block others.

## Session Lifecycle Rules

1. **Scale-to-zero is mandatory** — GPU node pool `minSize: 0`.
2. **Session TTL:** `activeDeadlineSeconds: 7200` (2 hr) on all student workloads.
3. **Spot-only for labs** — on-demand GPU only for instructor demos.
4. **CA max:** 3 nodes maximum across all GPU pools in `us-west1`.
5. **Alert before billing** — GCP budget alert fires at $30/mo; at $50/mo the node pool
   is manually scaled to zero until the next billing cycle.

## Success Criterion

> Student can size a GCP node pool (CA min/max) to keep monthly GPU cost < $50.

This is taught explicitly in Course 1 Module 4 and assessed in the Capstone.
