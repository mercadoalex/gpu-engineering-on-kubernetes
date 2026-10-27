#!/usr/bin/env bash
# derive-images.sh — Derive the exact container-image list to bake into the
# HAMi k3s control-plane rootfs (Lesson 3.6, Option A: preload images only).
#
# Source of truth is the rendered Helm charts, NOT hardcoded tags:
#   - run-ai/fake-gpu-operator (OCI chart, pinned 0.0.80)
#   - HAMi (project-hami charts repo, device-plugin DISABLED to match the
#     playground, which runs scheduler + webhook only)
#   - plus docker.io/library/ubuntu:22.04 (the Lesson 3.6 demo-pod image)
#
# Every `image:` value is stripped of quotes, normalized to a fully-qualified
# registry/repo:tag, deduped (sort -u), and written to images.txt next to this
# script. Idempotent; prints the final list.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${SCRIPT_DIR}/images.txt"

GREEN='\033[0;32m'
NC='\033[0m'

FAKE_GPU_VERSION="0.0.80"
HAMI_REPO_URL="https://project-hami.github.io/HAMi/"

# normalize <ref> — emit a fully-qualified docker ref.
# Rules (only applied when truly absent):
#   - no registry host (first path segment has no '.' or ':') -> prefix docker.io/
#   - a bare docker.io/<name> single-segment repo             -> docker.io/library/<name>
#   - no tag                                                  -> :latest
normalize() {
  local ref="$1"
  # strip surrounding single/double quotes
  ref="${ref//\"/}"
  ref="${ref//\'/}"

  local host rest
  local first="${ref%%/*}"
  if [[ "$ref" == */* ]] && [[ "$first" == *.* || "$first" == *:* || "$first" == "localhost" ]]; then
    # already has a registry host
    host="$first"
    rest="${ref#*/}"
  else
    # no registry host -> default docker.io
    host="docker.io"
    rest="$ref"
    # official single-name image on docker.io needs the library/ namespace
    if [[ "$rest" != */* ]]; then
      rest="library/${rest}"
    fi
  fi

  # ensure a tag is present (check the repo part only, not the host:port)
  if [[ "$rest" != *:* ]]; then
    rest="${rest}:latest"
  fi

  echo "${host}/${rest}"
}

echo -e "${GREEN}Rendering fake-gpu-operator ${FAKE_GPU_VERSION} chart...${NC}" >&2
fake_images=$(helm template gpu-operator \
  oci://ghcr.io/run-ai/fake-gpu-operator/fake-gpu-operator \
  --version "${FAKE_GPU_VERSION}" 2>/dev/null \
  | grep -oE 'image: *\S+' | awk '{print $2}')

echo -e "${GREEN}Rendering HAMi chart (device-plugin disabled)...${NC}" >&2
helm repo add hami-charts "${HAMI_REPO_URL}" >/dev/null 2>&1 || true
helm repo update hami-charts >/dev/null 2>&1
hami_images=$(helm template hami hami-charts/hami \
  --set devicePlugin.enabled=false 2>/dev/null \
  | grep -oE 'image: *\S+' | awk '{print $2}')

# Collect, normalize, dedupe. Append the mandated ubuntu:22.04 demo image.
{
  printf '%s\n' ${fake_images}
  printf '%s\n' ${hami_images}
  echo "docker.io/library/ubuntu:22.04"
} | while IFS= read -r raw; do
  [ -n "$raw" ] || continue
  normalize "$raw"
done | sort -u > "${OUT}"

echo -e "${GREEN}Wrote $(wc -l < "${OUT}" | tr -d ' ') image(s) to ${OUT}:${NC}" >&2
cat "${OUT}"
