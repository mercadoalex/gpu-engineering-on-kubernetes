#!/usr/bin/env bash
# build.sh — Pull every image in images.txt for linux/amd64 and `docker save`
# them ALL into a single airgap tar (airgap-images-hami.tar) that k3s will
# auto-import on boot (every *.tar under /var/lib/rancher/k3s/agent/images/).
#
# On this arm64 host the amd64 pulls run under QEMU emulation — that is expected
# and only affects pull time, not the saved image contents.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_FILE="${SCRIPT_DIR}/images.txt"
TAR="${SCRIPT_DIR}/airgap-images-hami.tar"

GREEN='\033[0;32m'
NC='\033[0m'

# Derive the list first if it is missing.
if [ ! -s "${IMAGES_FILE}" ]; then
  echo -e "${GREEN}images.txt missing — running derive-images.sh...${NC}"
  bash "${SCRIPT_DIR}/derive-images.sh" >/dev/null
fi

# Read images (skip blank lines) — portable, works on bash 3.2 (macOS) too.
IMAGES=()
while IFS= read -r line; do
  [ -n "$line" ] || continue
  IMAGES+=("$line")
done < <(grep -v '^[[:space:]]*$' "${IMAGES_FILE}")
echo -e "${GREEN}Pulling ${#IMAGES[@]} image(s) for linux/amd64...${NC}"

for img in "${IMAGES[@]}"; do
  echo -e "${GREEN}  pull ${img}${NC}"
  docker pull --platform linux/amd64 "${img}"
done

echo -e "${GREEN}Saving all images into ${TAR}...${NC}"
docker save "${IMAGES[@]}" -o "${TAR}"

SIZE=$(du -h "${TAR}" | awk '{print $1}')
echo -e "${GREEN}Done. ${TAR} (${SIZE})${NC}"
