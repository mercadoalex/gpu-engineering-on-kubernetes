# GPU Engineering on Kubernetes — iximiuz Lab VM image
# Boots as a Firecracker microVM (NOT a container at runtime).
# Docker is only the build tool — the OCI image is flattened to ext4 by iximiuz.
#
# Runtime cluster = kwokctl *binary* runtime (etcd + kube-apiserver + kwok as
# plain Linux binaries). No Docker, no kind at runtime. All cluster binaries and
# the course repo are pre-cached at BUILD time so NOTHING is fetched at boot.
#
# Build:  make build REGISTRY=ghcr.io/mercadoalex
# Push:   make push  REGISTRY=ghcr.io/mercadoalex
# Create playground: labctl playground create -f playground/playground.yaml -b flexbox gpu-engineering-on-kubernetes

FROM ubuntu:24.04
ARG LAB_USER=laborant
ARG KUBECTL_VERSION=v1.31.3
ARG KWOKCTL_VERSION=v0.6.0
ARG HELM_VERSION=v3.16.3
# Kubernetes version warmed into the kwokctl binary-runtime cache. Must match
# the --kube-version the setup script requests at runtime (course-1/scripts).
ARG KUBE_VERSION=v1.31.3
# etcd image tag that kwok v0.6.0 downloads for K8s v1.31.x (the default etcd
# tag pinned by the Kubernetes 1.31 release). Confirm from the warm-up download
# log during the build and keep this in sync if it ever changes.
ARG ETCD_VERSION=3.5.15-0

# ── Disable interactive prompts ──────────────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ── Pin apt away from backports (avoids GPG failures under QEMU/amd64) ───────
RUN echo 'Package: *\nPin: release a=noble-backports\nPin-Priority: -1' \
    > /etc/apt/preferences.d/no-backports

# ── Base OS packages ──────────────────────────────────────────────────────────
# netcat-openbsd stays for the init-task `nc -z` port pre-check.
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    wget \
    git \
    jq \
    make \
    netcat-openbsd \
    openssh-server \
    sudo \
    systemd \
    systemd-sysv \
    udev \
    kmod \
    ca-certificates \
    gnupg \
    lsb-release \
    iproute2 \
    iputils-ping \
    vim \
    less \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── yq (YAML processor) ───────────────────────────────────────────────────────
RUN curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq

# ── kubectl ───────────────────────────────────────────────────────────────────
RUN curl -fsSL https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# ── kwokctl (ships the binary runtime: etcd + kube + kwok) ───────────────────
RUN curl -fsSL https://github.com/kubernetes-sigs/kwok/releases/download/${KWOKCTL_VERSION}/kwokctl-linux-amd64 \
    -o /usr/local/bin/kwokctl && chmod +x /usr/local/bin/kwokctl

# ── Helm (used by install-ghostgpu.sh, not by the cluster setup script) ──────
RUN curl -fsSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    | tar -xz --strip-components=1 -C /usr/local/bin linux-amd64/helm

# ── SSH ───────────────────────────────────────────────────────────────────────
RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ── Serial console (required for Firecracker microVM boot) ───────────────────
RUN systemctl enable getty@ttyS0.service

# ── Lab user (created BEFORE the warm-up so the cache lands in its home dir) ──
RUN useradd -m -s /bin/bash -u 1001 ${LAB_USER} && \
    echo "${LAB_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${LAB_USER}

# ── Course repo baked into the image ─────────────────────────────────────────
# Build context is the worktree root (Makefile passes $(CUR_DIR)). Lessons do
# `cd /workdir`, so we copy the repo to /opt/gpu-k8s-lab and symlink /workdir to
# it — a single source of truth, chowned so laborant can write cluster state.
COPY --chown=${LAB_USER}:${LAB_USER} . /opt/gpu-k8s-lab
RUN ln -s /opt/gpu-k8s-lab /workdir

# ── Warm the kwokctl binary-runtime cache AT BUILD TIME ──────────────────────
# Cache-location decision: kwokctl's binary runtime caches downloaded binaries
# under ~/.kwok/cache/kubernetes/<KUBE_VERSION>/... — i.e. home-dir relative.
# The playground runs as `laborant`, so we run the warm-up AS laborant (not root)
# so the cache lands in /home/laborant/.kwok where the runtime looks. The create
# forces kwokctl to download kube-apiserver, kube-controller-manager,
# kube-scheduler, etcd (${ETCD_VERSION}) and kwok; the delete removes the
# ephemeral cluster but the cache persists. Result: boot is fully offline.
RUN su -s /bin/bash ${LAB_USER} -c '\
      kwokctl create cluster --name warmup --runtime=binary --kube-version=${KUBE_VERSION} && \
      kwokctl delete cluster --name warmup' && \
    ls -d /home/${LAB_USER}/.kwok/cache/kubernetes/${KUBE_VERSION}

# ── machine-id reset (required — each VM must have a unique machine-id) ───────
RUN rm -f /etc/machine-id /var/lib/dbus/machine-id && \
    systemd-machine-id-setup || true

# ── Welcome message ───────────────────────────────────────────────────────────
COPY rootfs/welcome /home/${LAB_USER}/.welcome
RUN chown ${LAB_USER}:${LAB_USER} /home/${LAB_USER}/.welcome
RUN echo 'cat ~/.welcome' >> /home/${LAB_USER}/.bashrc

# ── iximiuz examiner (task engine) ────────────────────────────────────────────
# The iximiuz platform injects the examiner binary at VM creation time.
# This stub ensures the service file exists so systemd doesn't error on boot.
RUN mkdir -p /opt/iximiuz-labs/examiner/checks.d

# ── systemd as PID 1 (required for Firecracker microVM) ───────────────────────
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
