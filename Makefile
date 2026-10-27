CUR_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# ── Configuration ─────────────────────────────────────────────────────────────
REGISTRY   ?= ghcr.io/mercadoalex
IMAGE_NAME ?= gpu-k8s-lab
RELEASE    ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
FULL_TAG   := $(REGISTRY)/$(IMAGE_NAME):$(RELEASE)
LATEST_TAG := $(REGISTRY)/$(IMAGE_NAME):latest

# HAMi-prepulled k3s control-plane rootfs (Lesson 3.6, Option A)
HAMI_IMAGE_NAME ?= hami-k3s-cplane
HAMI_TAG        ?= v1
HAMI_FULL_TAG   := $(REGISTRY)/$(HAMI_IMAGE_NAME):$(HAMI_TAG)

LAB_USER           ?= laborant
KUBECTL_VERSION    ?= v1.31.3
KWOKCTL_VERSION    ?= v0.6.0
HELM_VERSION       ?= v3.16.3
KUBE_VERSION       ?= v1.31.3
ETCD_VERSION       ?= 3.5.15-0

.PHONY: all build push tag-latest run shell clean help bake-hami-k3s bake-hami-k3s-push

all: build

## build: Build the lab VM OCI image
build: check-docker
	@echo "\033[0;32mBuilding $(FULL_TAG)...\033[0m"
	docker build \
		--progress plain \
		--platform linux/amd64 \
		--build-arg LAB_USER=$(LAB_USER) \
		--build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) \
		--build-arg KWOKCTL_VERSION=$(KWOKCTL_VERSION) \
		--build-arg HELM_VERSION=$(HELM_VERSION) \
		--build-arg KUBE_VERSION=$(KUBE_VERSION) \
		--build-arg ETCD_VERSION=$(ETCD_VERSION) \
		-t $(FULL_TAG) \
		-t $(REGISTRY)/$(IMAGE_NAME):dev \
		-f $(CUR_DIR)/rootfs/Dockerfile \
		$(CUR_DIR)
	@echo "\033[0;32mBuild complete: $(FULL_TAG) (also tagged :dev)\033[0m"

## bake-hami-k3s: Bake HAMi+fake-gpu-operator+ubuntu images into the k3s cplane rootfs (Lesson 3.6, Option A)
bake-hami-k3s: check-docker
	@echo "\033[0;32mDeriving HAMi image list...\033[0m"
	bash $(CUR_DIR)/rootfs-hami-k3s/derive-images.sh
	@echo "\033[0;32mPulling + saving images into airgap tar...\033[0m"
	bash $(CUR_DIR)/rootfs-hami-k3s/build.sh
	@echo "\033[0;32mBuilding $(HAMI_FULL_TAG)...\033[0m"
	docker build \
		--progress plain \
		--platform linux/amd64 \
		-t $(HAMI_FULL_TAG) \
		-f $(CUR_DIR)/rootfs-hami-k3s/Dockerfile \
		$(CUR_DIR)/rootfs-hami-k3s
	@echo "\033[0;32mBake complete: $(HAMI_FULL_TAG)\033[0m"

## bake-hami-k3s-push: Push the baked HAMi cplane image to the registry (run manually)
bake-hami-k3s-push: check-registry
	docker push $(HAMI_FULL_TAG)
	@echo "\033[0;32mPushed: $(HAMI_FULL_TAG)\033[0m"

## push: Push the image to the registry
push: build check-registry
	docker push $(FULL_TAG)
	@echo "\033[0;32mPushed: $(FULL_TAG)\033[0m"

## tag-latest: Tag :dev as :latest and push
tag-latest: check-registry
	docker tag $(REGISTRY)/$(IMAGE_NAME):dev $(LATEST_TAG)
	docker push $(LATEST_TAG)
	@echo "\033[0;32mTagged and pushed: $(LATEST_TAG)\033[0m"

## run: Open a shell in the image locally (filesystem inspection only — systemd won't boot in a container)
run: build
	docker run --rm -it \
		--name gpu-k8s-lab-test \
		--entrypoint /bin/bash \
		$(REGISTRY)/$(IMAGE_NAME):dev

## shell: Alias for run
shell: run

## inspect: Show image size and layers
inspect: build
	docker inspect $(FULL_TAG) | jq '.[0] | {Id, Architecture, Os, Size: (.Size / 1024 / 1024 | floor | tostring + " MB"), Layers: (.RootFS.Layers | length)}'

## playground-create: Register the playground on iximiuz Labs (run once)
playground-create:
	@echo "\033[0;32mCreating playground on iximiuz Labs...\033[0m"
	labctl playground create -f playground/playground.yaml -b flexbox gpu-engineering-on-kubernetes
	@echo ""
	@echo "Copy the slug from the output above and:"
	@echo "  1. Add it as 'name:' in playground/playground.yaml"
	@echo "  2. Update playground.name in every lesson index.md"

## playground-update: Push updated playground.yaml to iximiuz Labs
playground-update:
	@SLUG=$$(grep '^name:' playground/playground.yaml | awk '{print $$2}'); \
	if [ -z "$$SLUG" ]; then echo "ERROR: Set name: in playground/playground.yaml first (run make playground-create)"; exit 1; fi; \
	labctl playground update -f playground/playground.yaml $$SLUG

## course-push: Push course 1 content to iximiuz Labs
course-push:
	@SLUG=$$(grep 'slug:' course-1/index.md | head -1 | awk '{print $$2}'); \
	echo "Pushing course: $$SLUG"; \
	labctl content push -f course $$SLUG -d course-1

## clean: Remove local image
clean:
	docker rmi $(FULL_TAG) $(LATEST_TAG) 2>/dev/null || true
	@echo "Cleaned."

# ── Checks ────────────────────────────────────────────────────────────────────
check-docker:
	@command -v docker >/dev/null 2>&1 || \
	  (echo "\033[0;31mERROR: docker not found.\033[0m"; exit 1)

check-registry:
	@command -v docker >/dev/null 2>&1 || \
	  (echo "\033[0;31mERROR: docker not found.\033[0m"; exit 1)

## help: Show this help
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /'
