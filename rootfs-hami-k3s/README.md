# HAMi-prepulled k3s control-plane rootfs (Lesson 3.6)

This directory bakes a custom k3s control-plane rootfs image that **pre-loads**
the container images Lesson 3.6 ("Inside HAMi: The Architecture of GPU Sharing")
needs, so the `hami-k3s` playground no longer stalls on a 3–5 min cold image
pull ("Warming up 1/3").

## How it works — the k3s airgap mechanism

On boot, k3s auto-imports **every** `*.tar` file found in
`/var/lib/rancher/k3s/agent/images/`. The base image
(`ghcr.io/iximiuz/labs/rootfs:ubuntu-k3s-server`, aliased `k3s-cplane`) already
ships k3s's own `airgap-images.tar` there. We add a **second** tar,
`airgap-images-hami.tar`, beside it. No k3s rebuild — the control plane imports
both tars into containerd at startup, so HAMi + fake-gpu-operator + ubuntu
images are already present locally when the init tasks run.

**Option A = preload images only.** The init-task helm-install logic in
`playgrounds/hami-k3s/manifest.yaml` is **unchanged**; the helm pulls still run,
but the container images they reference are already cached, so pod startup is
fast instead of network-bound.

Only **cplane-01** uses this image. dev-machine (`k3s-dev-machine`) and the
workers (`k3s-node`) stay on their base sources.

## Files

| File | Purpose |
|------|---------|
| `derive-images.sh` | Renders the fake-gpu-operator (0.0.80) and HAMi (device-plugin off) charts, normalizes + dedupes every `image:` ref, appends `docker.io/library/ubuntu:22.04`, writes `images.txt`. |
| `images.txt` | The deduped, fully-qualified image list (committed source of truth). |
| `build.sh` | Pulls every image (`--platform linux/amd64`) and `docker save`s them ALL into one `airgap-images-hami.tar`. |
| `Dockerfile` | `FROM` the k3s cplane base, `COPY`s the tar into the airgap dir. |

The multi-GB `airgap-images-hami.tar` is gitignored (built locally).

## Build & publish flow

```sh
# From the repo root. Derive -> pull/save -> docker build (local image only):
make bake-hami-k3s

# Publish to the registry (run manually — the bake target never pushes):
make bake-hami-k3s-push

# Then point the playground's cplane-01 at the new image (already wired in
# playgrounds/hami-k3s/manifest.yaml: oci://ghcr.io/mercadoalex/hami-k3s-cplane:v1)
# and update the playground on iximiuz Labs:
labctl playground update -f playgrounds/hami-k3s/manifest.yaml <slug>
```

`REGISTRY` defaults to `ghcr.io/mercadoalex`; override with
`make bake-hami-k3s REGISTRY=...` (also `HAMI_IMAGE_NAME`, `HAMI_TAG`).
