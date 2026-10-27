# HAMi-prepulled k3s control-plane rootfs (Lesson 3.6, Option A).
#
# k3s auto-imports EVERY `*.tar` found in /var/lib/rancher/k3s/agent/images/ at
# boot. The base image already ships k3s's own `airgap-images.tar` there; we add
# a SECOND tar beside it containing the HAMi + fake-gpu-operator + ubuntu:22.04
# images. No k3s rebuild — the control plane simply imports both tars, so the
# "Warming up" cold image pull on the hami-k3s playground is eliminated.
#
# Option A = preload images only. Init-task helm-install logic is unchanged;
# the helm pulls still run but the container images are already present locally.
#
# Build context is this directory (rootfs-hami-k3s/) so the COPY only needs the
# tar, not the multi-GB repo. Keep platform linux/amd64.
FROM ghcr.io/iximiuz/labs/rootfs:ubuntu-k3s-server

COPY airgap-images-hami.tar /var/lib/rancher/k3s/agent/images/airgap-images-hami.tar
