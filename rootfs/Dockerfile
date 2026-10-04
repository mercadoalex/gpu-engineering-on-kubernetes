# GPU Engineering on Kubernetes — iximiuz Lab VM image
# Boots as a Firecracker microVM (NOT a container at runtime).
# Docker is only the build tool — the OCI image is flattened to ext4 by iximiuz.
#
# Build:  make build REGISTRY=ghcr.io/mercadoalex
# Push:   make push  REGISTRY=ghcr.io/mercadoalex
# Create playground: labctl playground create -f playground/playground.yaml -b flexbox gpu-engineering-on-kubernetes

FROM ubuntu:24.04
ARG LAB_USER=laborant
ARG KUBECTL_VERSION=v1.31.3
ARG KIND_VERSION=v0.24.0
ARG KWOKCTL_VERSION=v0.6.0
ARG HELM_VERSION=v3.16.3

# ── Disable interactive prompts ──────────────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ── Pin apt away from backports (avoids GPG failures under QEMU/amd64) ───────
RUN echo 'Package: *\nPin: release a=noble-backports\nPin-Priority: -1' \
    > /etc/apt/preferences.d/no-backports

# ── Base OS packages ──────────────────────────────────────────────────────────
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

# ── kind ─────────────────────────────────────────────────────────────────────
RUN curl -fsSL https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64 \
    -o /usr/local/bin/kind && chmod +x /usr/local/bin/kind

# ── kwokctl ──────────────────────────────────────────────────────────────────
RUN curl -fsSL https://github.com/kubernetes-sigs/kwok/releases/download/${KWOKCTL_VERSION}/kwokctl-linux-amd64 \
    -o /usr/local/bin/kwokctl && chmod +x /usr/local/bin/kwokctl

# ── Helm ─────────────────────────────────────────────────────────────────────
RUN curl -fsSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    | tar -xz --strip-components=1 -C /usr/local/bin linux-amd64/helm

# ── Docker (needed by kind to create the K8s cluster) ────────────────────────
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    docker-ce docker-ce-cli containerd.io \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── SSH ───────────────────────────────────────────────────────────────────────
RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ── Serial console (required for Firecracker microVM boot) ───────────────────
RUN systemctl enable getty@ttyS0.service

# ── Lab user ──────────────────────────────────────────────────────────────────
RUN useradd -m -s /bin/bash -u 1001 ${LAB_USER} && \
    echo "${LAB_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${LAB_USER} && \
    usermod -aG docker ${LAB_USER}

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

# ── Workdir symlink (lessons reference /workdir/course-1/...) ─────────────────
# The course repo is expected to be cloned to /workdir at playground start
# via an init task (see iximiuz-init-tasks.md steering file).
RUN mkdir -p /workdir && chown ${LAB_USER}:${LAB_USER} /workdir

# ── systemd as PID 1 (required for Firecracker microVM) ───────────────────────
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
