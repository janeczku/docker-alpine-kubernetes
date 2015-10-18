# Makefile for the Docker image janeczku/alpine2skydns
# MAINTAINER: Jan Broer <janeczku@yahoo.com>

.PHONY: all container push

PREFIX = janeczku
TAG = 3.2.1.2

all: container

tag:
	git tag -f $(TAG)
	git push -f --tags

container: tag
	docker build -t $(PREFIX)/alpine-kubernetes .
	docker tag $(PREFIX)/alpine-kubernetes:latest $(PREFIX)/alpine-kubernetes:$(TAG)

push:
	docker push $(PREFIX)/alpine-kubernetes
