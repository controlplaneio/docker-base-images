NAME := base
REGISTRY := docker.io/controlplane
BUILD_DATE := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
GIT_SHA := $(shell git log -1 --format=%h)
GIT_TAG ?= $(shell bash -c 'TAG=$$(git tag | tail -n1); echo "$${TAG:-none}"')
GIT_MESSAGE := $(shell git -c log.showSignature=false log --max-count=1 --pretty=format:"%H")
GIT_UNTRACKED_CHANGES := $(shell git status --porcelain --untracked-files=no)
ifneq ($(GIT_UNTRACKED_CHANGES),)
        GIT_TAG := $(GIT_TAG)-dirty
        GIT_SHA := $(GIT_SHA)-dirty
endif

CONTAINER_TAG ?= $(GIT_SHA)
# TODO(ajm) should this always tag SHA and latest?
CONTAINER_TAG = latest

CONTAINER_NAME_BASE := $(REGISTRY)/$(NAME):$(CONTAINER_TAG)

CONTAINER_NAME_BASE_UBUNTU := $(REGISTRY)/$(NAME)-ubuntu:$(CONTAINER_TAG)
CONTAINER_NAME_BASE_ALPINE := $(REGISTRY)/$(NAME)-alpine:$(CONTAINER_TAG)
CONTAINER_NAME_BASE_CENTOS := $(REGISTRY)/$(NAME)-centos:$(CONTAINER_TAG)

CONTAINER_NAME_JRE := $(REGISTRY)/$(NAME)-jre:$(CONTAINER_TAG)
CONTAINER_NAME_TEST := $(REGISTRY)-$(NAME)-test-$(CONTAINER_TAG)

BUILD_JOBS_BASE :=  build-base-alpine \
										build-base-centos \
										build-base-ubuntu
BUILD_JOBS_INHERITED := build-jre

TEST_JOBS_BASE :=   test-base-alpine \
										test-base-centos \
										test-base-ubuntu \
										test-jre

PUSH_JOBS_BASE :=   push-base-alpine \
										push-base-centos \
										push-base-ubuntu \
										push-jre

export NAME REGISTRY BUILD_DATE GIT_SHA GIT_TAG GIT_MESSAGE CONTAINER_NAME CONTAINER_TAG

# ---

# this intentionally does not push images
.PHONY: all
all: build test ## build and test all base images

# ---

define build_image
	set -x;
	docker run --rm -i hadolint/hadolint < $(2) | grep --color=always '.*'
	docker build \
	    --tag "$(1)" \
			--rm=true \
			--file=$(2) \
			.
endef

define test_image
	cd $(1)/ \
	&& [ -f goss.yaml ] || { echo "error: goss.yaml not found"; exit 1; } \
	&& docker \
		run \
		-i \
		$(2) \
		goss -g - validate < goss.yaml
endef

define push_image
		set -x
		docker push $(1)
endef

define make_parallel
	make \
  		--jobs 2 \
  		--max-load 3 \
  		--output-sync=recurse \
  		\
  		$(1)
endef

# ---

.PHONY: build
build: ## build all base images
	@echo "+ $@"
	$(call make_parallel,$(BUILD_JOBS_BASE))
	$(call make_parallel,$(BUILD_JOBS_INHERITED))

.PHONY: build-base-ubuntu
build-base-ubuntu: ## build ubuntu base image
	@echo "+ $@"
	$(call build_image,$(CONTAINER_NAME_BASE_UBUNTU),base-ubuntu/Dockerfile.base-ubuntu)

.PHONY: build-base-alpine
build-base-alpine: ## build base alpine image
	@echo "+ $@"
	$(call build_image,$(CONTAINER_NAME_BASE_ALPINE),base-alpine/Dockerfile.base-alpine)

.PHONY: build-base-centos
build-base-centos: ## build base centos image
	@echo "+ $@"
	$(call build_image,$(CONTAINER_NAME_BASE_CENTOS),base-centos/Dockerfile.base-centos)

.PHONY: build-jre
build-jre: ## build JRE image
	@echo "+ $@"
	$(call build_image,$(CONTAINER_NAME_JRE),jre/Dockerfile.jre)

# ---

.PHONY: test
test: ## test all base images
	@echo "+ $@"
	$(call make_parallel,$(TEST_JOBS_BASE))

.PHONY: test-base-ubuntu
test-base-ubuntu: ## test base ubuntu image
	@echo "+ $@"
	$(call test_image,base-ubuntu,$(CONTAINER_NAME_BASE_UBUNTU))

.PHONY: test-base-alpine
test-base: ## test base alpine image
	@echo "+ $@"
	$(call test_image,base-alpine,$(CONTAINER_NAME_BASE_ALPINE))

.PHONY: test-base-centos
test-base-centos: ## test base centos image
	@echo "+ $@"
	$(call test_image,base-centos,$(CONTAINER_NAME_BASE_CENTOS))

.PHONY: test-jre
test-jre: ## test JRE image
	@echo "+ $@"
	$(call test_image,jre,$(CONTAINER_NAME_JRE))

# ---

.PHONY: pull
pull: ## pull all base images
	@echo "+ $@"
	@echo "Pulling base images..."
	grep FROM Dockerfile* **/Dockerfile* 2>/dev/null | awk '{print $$2}' | xargs -n 1 docker pull

# ---

.PHONY: push
push: ## push all base images
	@echo "+ $@"
	@echo "Pushing images in parallel..."
	$(call make_parallel,$(PUSH_JOBS_BASE))

.PHONY: push-base-ubuntu
push-base-ubuntu: ## push ubuntu base image
	@echo "+ $@"
	$(call push_image,$(CONTAINER_NAME_BASE_UBUNTU))

.PHONY: push-base-alpine
push-base-alpine: ## push base alpine image
	@echo "+ $@"
	$(call push_image,$(CONTAINER_NAME_BASE_ALPINE))

.PHONY: push-base-centos
push-base-centos: ## push base centos image
	@echo "+ $@"
	$(call push_image,$(CONTAINER_NAME_BASE_CENTOS))

.PHONY: push-jre
push-jre: ## push JRE image
	@echo "+ $@"
	$(call push_image,$(CONTAINER_NAME_JRE))

# ---

.PHONY: help
help: ## parse jobs and descriptions from this Makefile
	@grep -E '^[ a-zA-Z0-9_-]+:([^=]|$$)' $(MAKEFILE_LIST) \
    | grep -Ev '^help\b[[:space:]]*:' \
    | sort \
    | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

