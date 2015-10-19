# Makefile for the Docker image janeczku/alpine-kubernetes
# MAINTAINER: Jan Broer <janeczku@yahoo.com>

.PHONY: all git-tag build release test

IMAGE = janeczku/alpine-kubernetes
TAG = 3.2

ifdef CIRCLE_BUILD_NUM
BUILD = ${CIRCLE_BUILD_NUM}
else
BUILD = $(shell git rev-parse --short HEAD)
endif

all:
	@echo "Available targets:"
	@echo "  * build - build a Docker image for $(IMAGE)"
	@echo "  * test  - test the image"
	@echo "  * release  - tag and push to Docker Hub"
	@echo "  * git-tag  - tag git commit with CIRCLE_BUILD_NUM"
	@echo $(IMAGE):$(TAG)-$(BUILD)

build:
	docker build -t $(IMAGE):$(TAG) .
	docker tag $(IMAGE):$(TAG) $(IMAGE):$(TAG)-$(BUILD)

test:
	docker run -d --name bats-test --dns=209.244.0.4 --dns-search=10.0.0.1.xip.io $(IMAGE):$(TAG)-$(BUILD)
	docker exec bats-test apk-install bind-tools
	bats test/alpine-kubernetes.bats

release: git-tag
	docker push $(IMAGE):$(TAG)
	docker push $(IMAGE):$(TAG)-$(BUILD)

git-tag:
	git tag -f $(TAG)-$(BUILD)
	git push -f --tags
