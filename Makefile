# Makefile for the Docker image janeczku/alpine-kubernetes
# MAINTAINER: Jan Broer <janeczku@yahoo.com>

.PHONY: all build release test

IMAGE = janeczku/alpine-kubernetes
VERSIONS = 3.2 3.3
VERSION =

ifdef CIRCLE_BUILD_NUM
BUILD_NUM = ${CIRCLE_BUILD_NUM}
else
BUILD_NUM = $(shell git rev-parse --short HEAD)
endif

all:
	@echo "Supported versions: $(VERSIONS)"
	@echo "Available targets:"
	@echo "  * build - build images"
	@echo "  * test  - run integration tests"
	@echo "  * release  - git tag build and push to Docker Hub"

build:
	@$(foreach var,$(VERSIONS),$(MAKE) do/build VERSION=$(var);)
	@$(MAKE) do/tag-latest VERSION=$(word $(words $(VERSIONS)),$(VERSIONS))

do/build:
	@echo "=> building $(IMAGE):$(VERSION)-$(BUILD_NUM)"
	docker build -t $(IMAGE):$(VERSION) -f versions/$(VERSION)/Dockerfile .
	docker tag -f $(IMAGE):$(VERSION) $(IMAGE):$(VERSION)-$(BUILD_NUM)

test:
	@$(foreach var,$(VERSIONS),$(MAKE) do/test VERSION=$(var);)

do/test: do/build-test
	@echo "=> running tests for $(IMAGE):$(VERSION)-$(BUILD_NUM)"
	docker run -e S6_LOGGING=1 --dns=8.8.4.4 --dns-search=10.0.0.1.xip.io test-image:$(VERSION)-$(BUILD_NUM) /bin/sh -c "sleep 5; /usr/local/bin/bats /tests/bats-tests"
	docker run -e S6_LOGGING=1 --dns 8.8.4.4 --dns 8.8.8.8 --dns-search google.com --dns-search video.google.com test-image:$(VERSION)-$(BUILD_NUM) /bin/sh -c "sleep 5; /usr/local/bin/bats /tests/bats-tests-more"

do/build-test:
	docker build -t test-image:$(VERSION)-$(BUILD_NUM) -f tests/dockerfile-test-$(VERSION) .

release: do/git-tag
	@$(foreach var,$(VERSIONS),$(MAKE) do/release VERSION=$(var);)
	docker push $(IMAGE):latest

do/release:
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):$(VERSION)-$(BUILD_NUM)

do/git-tag:
	git tag -f -a build-$(BUILD_NUM) -m "Release CI build $(BUILD_NUM)"
	git push -f --tags

do/tag-latest:
	docker tag -f $(IMAGE):$(VERSION) $(IMAGE):latest
