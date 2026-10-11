---
inclusion: manual
---

# iximiuz Init Tasks — Troubleshooting Playbook

> If the playground is stuck at "Warming up playground… Init tasks completed: 0/N",
> an init task script has either timed out or is polling something that boots too slowly.

---

## How the platform boots a playground

```
VM starts (microVM cold boot)
  └── systemd starts services

Platform task runner fires ALL init tasks in parallel immediately on SSH-reachability

Playground UI shows "Warming up playground..."
  └── spinner stays until EVERY init task exits 0
  └── Once all exit 0 → regular tasks start → UI unlocks
```

**Key insight:** init tasks fire the moment the VM is reachable via SSH — the services
have NOT started yet. If an init task times out it exits non-zero and the spinner
**never clears** (no platform-side timeout on the warming-up phase visible to students).

---

## Canonical init task patterns

### Wait for a port (preferred — use `nc -z`)

```yaml
init_wait_for_service:
  init: true
  machine: <machine-name>
  user: laborant
  timeout_seconds: 300
  run: |
    until nc -z 127.0.0.1 <PORT> 2>/dev/null; do
      echo "Waiting for service on port <PORT>..."
      sleep 5
    done
    sleep 10
    echo "Service is up ✓"
```

**Rules:**
- Use `nc -z` (TCP port open check) **not** an HTTP URL poll — HTTP endpoints are
  one of the last things a service exposes; the port opens 30–40 s earlier.
- `sleep 10` after the port opens gives the process time to finish internal init
  before regular tasks start firing requests.
- `timeout_seconds: 300` — always. 120 s was too tight and caused timeouts.

### Wait for an HTTP endpoint (only when port check isn't reliable)

```yaml
init_wait_for_http:
  init: true
  machine: <machine-name>
  user: laborant
  timeout_seconds: 300
  run: |
    until curl -s -o /dev/null -w "%{http_code}" http://localhost:<PORT>/ \
        | grep -q "200\|302"; do
      echo "Waiting for HTTP on port <PORT>..."
      sleep 5
    done
    echo "Service is up ✓"
```

Use this when a service's HTTP layer initialises slightly after the port opens
(e.g. CommandBox/Lucee). For most services `nc -z` is faster and more reliable.

### Wait for a child process (add a leading sleep)

When service B is spawned by service A (e.g. Solr spawned by ColdFusion), add
`sleep 30` before the poll loop so you don't waste the entire timeout polling a
port that won't open for 60+ seconds:

```yaml
init_wait_for_child_service:
  init: true
  machine: <machine-name>
  user: laborant
  timeout_seconds: 300
  run: |
    sleep 30
    until nc -z 127.0.0.1 <PORT> 2>/dev/null; do
      echo "Waiting..."
      sleep 5
    done
    echo "Service is up ✓"
```

---

## What "Warming up playground" actually means

| Platform state | UI |
|---|---|
| VMs booting | "Warming up playground… Init tasks completed: 0/N" |
| Init tasks running (poll loop) | Same — still 0/N |
| Any init task exits non-zero (timeout) | **Stuck forever at 0/N** |
| All init tasks exit 0 | Spinner clears, regular tasks start, UI unlocks |

---

## Common failure modes

| Symptom | Cause | Fix |
|---|---|---|
| "0/N" forever after 3+ min | `timeout_seconds` too low (e.g. 120) | Use 300 |
| Init task hangs near timeout | Polling a slow HTTP admin URL instead of port | Use `nc -z` |
| Child service init times out at 300 s | Task starts polling before parent service is up | Add `sleep 30` |
| Two init tasks both time out simultaneously | Parallel fire burning the same timeout window | Tasks are independent by design — use `sleep` stagger |

## Critical: `init: true` must ONLY appear on real init tasks

Adding `init: true` to regular (student-facing) tasks causes the "Warming up
playground" screen to hang forever. The foundations course has **zero** init tasks
and works correctly — regular tasks run after the playground is up with no `init:` key.

---

## Pre-push checklist

- [ ] Every `init` task uses `timeout_seconds: 300`
- [ ] Port checks use `nc -z`, not an HTTP URL
- [ ] `nc -z` is followed by `sleep 10`
- [ ] Child-process services start with `sleep 30` before their poll loop
- [ ] Regular tasks do NOT have `init: true`
- [ ] Regular tasks do NOT use `timeout_seconds` (not a documented field on regular tasks)
- [ ] Regular tasks do NOT use `needs: [init_wait_*]` — platform guarantees regular
      tasks only start after all init tasks pass; explicit `needs` to init tasks is
      not required and is not supported

---

## kwokctl binary-runtime gotchas (learned the hard way)

- **Warm the cache at BUILD time, never at boot.** `kwokctl create cluster --runtime=binary`
  downloads kube + etcd + kwok binaries from `dl.k8s.io`. Run a throwaway
  `create`+`delete` in the Dockerfile so the binaries land in `~/.kwok/cache/`.
  At playground boot the create is then fully offline.
- **kwokctl v0.6.0 has NO `--kube-version` flag.** Select the version with the
  `KWOK_KUBE_VERSION` env var: `KWOK_KUBE_VERSION=v1.31.3 kwokctl create cluster --runtime=binary`.
- **Cache path is URL-mirrored**, not `cache/kubernetes/<ver>`. The real path is
  `~/.kwok/cache/https/dl.k8s.io/release/<ver>/bin/linux/amd64/kube-apiserver`.
  Assert that exact path in the Dockerfile to confirm the warm-up worked.
- **Run the warm-up AS the lab user** (`laborant`), not root — the cache is HOME-relative
  and the playground runs as the lab user.
- **"Cluster is started" is optimistic.** kwokctl prints it even if the apiserver
  isn't serving yet. ALWAYS poll `kubectl get --raw /healthz` until it returns `ok`
  before applying any objects, or node applies hit "connection refused".
- **Apply fake nodes with `kubectl apply --validate=false`** — avoids a dependency on
  the apiserver's openapi endpoint being fully warmed in the first seconds.
- **Never hardcode `lastHeartbeatTime` on KWOK fake nodes.** With the
  `kwok.x-k8s.io/node: fake` annotation, the kwok controller owns the Ready condition
  and heartbeat. A pinned timestamp goes stale and fails the Ready freshness check.
- **QEMU emulation is NOT representative of boot time.** Building/running the amd64
  image on an Apple Silicon host under QEMU makes the apiserver take minutes to serve.
  On native amd64 (the real Firecracker runtime) it's ~10s. Do not quote emulated
  timings to students, and give the health-check loop generous headroom.

## Service startup times (reference)

| Service | Port | Time to ready (cold boot, 2 GiB microVM) |
|---|---|---|
| Kubernetes API server (kind) | 6443 | 30–60 s |
| KWOK nodes reporting Ready | — | 5–10 s after API server |
| Kueue controller | — | 10–20 s after API server |
| Prometheus | 9090 | 15–30 s |
| Grafana | 3000 | 20–40 s |
| vLLM (CPU stub / smoke test) | 8000 | 30–60 s |
