# Makefile for the Docker image janeczku/alpine-kubernetes
# MAINTAINER: Jan Broer <janeczku@yahoo.com>

.PHONY: all git-tag build release test build-test

IMAGE = janeczku/alpine-kubernetes
TAG = 3.2

ifdef CIRCLE_BUILD_NUM
BUILD_NUM = ${CIRCLE_BUILD_NUM}
else
BUILD_NUM = $(shell git rev-parse --short HEAD)
endif

all:
	@echo "Available targets:"
	@echo "  * build - build image $(IMAGE):$(TAG)-$(BUILD_NUM)"
	@echo "  * test  - run integration tests in test-image"
	@echo "  * release  - git tag build and push to Docker Hub"
	@echo "  * git-tag  - git tag build"

build:
	docker build -t $(IMAGE):$(TAG) .
	docker tag $(IMAGE):$(TAG) $(IMAGE):$(TAG)-$(BUILD_NUM)
	docker tag $(IMAGE):$(TAG) $(IMAGE):latest

build-test:
	docker build -t test-image:$(TAG)-$(BUILD_NUM) -f test/Dockerfile .

test: build-test
	docker run -e S6_LOGGING=1 --dns=209.244.0.4 --dns-search=10.0.0.1.xip.io test-image:$(TAG)-$(BUILD_NUM)

release: git-tag
	docker push $(IMAGE):$(TAG)
	docker push $(IMAGE):$(TAG)-$(BUILD_NUM)
	docker push $(IMAGE):latest

git-tag:
	git tag -f -a $(TAG)-$(BUILD_NUM) -m "Release build for $(TAG)-$(BUILD_NUM)"
	git push -f --tags
