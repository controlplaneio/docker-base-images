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
CONTAINER_NAME_BASE_CENTOS := $(REGISTRY)/$(NAME)-centos:$(CONTAINER_TAG)
CONTAINER_NAME_JRE := $(REGISTRY)/$(NAME)-jre:$(CONTAINER_TAG)
CONTAINER_NAME_TEST := $(REGISTRY)-$(NAME)-test-$(CONTAINER_TAG)

export NAME REGISTRY BUILD_DATE GIT_SHA GIT_TAG GIT_MESSAGE CONTAINER_NAME CONTAINER_TAG

# ---

# this intentionally does not push images
.PHONY: all
all: build test ## build and test all base images

# ---

define build_image
	set -x;
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

# ---

.PHONY: build
build: build-all ## build all base images

.PHONY: build-all
build-all: build-base ## build all base images
	@echo "+ $@"
	make \
		--jobs 2 \
		--max-load 3 \
		--output-sync=recurse \
		\
		build-base-centos \
		build-jre

.PHONY: build-base
build-base: ## build base alpine image
	@echo "+ $@"
	$(call build_image,$(CONTAINER_NAME_BASE),base/Dockerfile.base)

.PHONY: build-base-centos
build-base-centos: ## build base centos image
	@echo "+ $@"
	$(call build_image,$(CONTAINER_NAME_BASE_CENTOS),base-centos/Dockerfile.base-centos)

.PHONY: build-jre
build-jre: ## build base JRE centos image
	@echo "+ $@"
	$(call build_image,$(CONTAINER_NAME_JRE),jre/Dockerfile.jre)

# ---

.PHONY: test
test: ## test all base images
	@echo "+ $@"
	make \
		--jobs 2 \
		--max-load 3 \
		--output-sync=recurse \
		test-all

.PHONY: test-all
test-all: test-base test-base-centos test-jre  ## test all base images

.PHONY: test-base
test-base: ## test base alpine image
	@echo "+ $@"
	$(call test_image,base,$(CONTAINER_NAME_BASE))

.PHONY: test-base-centos
test-base-centos: ## test base centos image
	@echo "+ $@"
	$(call test_image,base-centos,$(CONTAINER_NAME_BASE_CENTOS))

.PHONY: test-base-jre
test-jre: ## test base JRE centos image
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
	make \
		--jobs 3 \
		--max-load 3 \
		--output-sync=recurse \
		push-all

.PHONY: push-all
push-all: push-base push-base-centos push-jre ## push all base images

.PHONY: push-base
push-base: ## push base alpine image
	@echo "+ $@"
	$(call push_image,$(CONTAINER_NAME_BASE))

.PHONY: push-base-centos
push-base-centos: ## push base centos image
	@echo "+ $@"
	$(call push_image,$(CONTAINER_NAME_BASE_CENTOS))

.PHONY: push-jre
push-jre: ## push base JRE centos image
	@echo "+ $@"
	$(call push_image,$(CONTAINER_NAME_JRE))


.PHONY: help
help: ## parse jobs and descriptions from this Makefile
	@grep -E '^[ a-zA-Z0-9_-]+:([^=]|$$)' $(MAKEFILE_LIST) \
    | grep -Ev '^help\b[[:space:]]*:' \
    | sort \
    | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

