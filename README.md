
# Alpine-Kubernetes base image

[![CircleCI](https://img.shields.io/circleci/project/janeczku/docker-alpine-kubernetes.svg?style=flat-square)](https://circleci.com/gh/janeczku/docker-alpine-kubernetes)

The Alpine-Kubernetes base image enables deployment of Alpine Linux micro-services containers in Kubernetes, Consol, Tutum or other Docker cluster environments that use DNS-based service discovery and rely on the containers being able to use the `search` domains from resolv.conf for resolving service names.

## About

Alpine-Kubernetes is based on the official [Docker Alpine](https://hub.docker.com/_/alpine/) image adding the excellent [s6 supervisor for containers](https://github.com/just-containers/s6-overlay) and [go-dnsmasg](https://github.com/janeczku/go-dnsmasq). Both s6 and go-dnsmasq introduce very minimal runtime and filesystem overhead.

-------

[![Imagelayers](https://badge.imagelayers.io/janeczku/alpine-kubernetes:latest.svg)](https://imagelayers.io/?images=janeczku/alpine-kubernetes:latest 'Get your own badge on imagelayers.io') [![Docker Pulls](https://img.shields.io/docker/pulls/janeczku/alpine-kubernetes.svg?style=flat-square)](https://hub.docker.com/r/janeczku/alpine-kubernetes/)

## Motivation
Alpine Linux uses musl-libc and thus does not support the `search` keyword in resolv.conf. This absolutely breaks things in environments that rely on DNS service discovery (e.g. Kubernetes, Tutum.co, Consul).    
Additionally Alpine Linux deviates from the well established pardigm of always querying the primary DNS server first. This introduces problems in cases where the host is configured with multiple nameserver with inconsistent records (e.g. one Consul server and one recursing server).
    
To overcome these issues Alpine-Kubernetes provides a lightweight (1.2 MB) local DNS server that replicates GNU libc's resolver logic and enables processes running in the container to properly resolve service names.

## How it works

On container start the DNS resolver parses the `nameserver` and `search` entries from the containers /etc/resolv.conf and configures itself as the primary nameserver for the container. DNS queries from local processes are resolved according to the following conventions:
* The nameserver listed first in resolv.conf is the primary server. It is always queried first.
* Hostnames are qualified by appending the domains configured by the `search` keyword in resolv.conf
* Single-label hostnames (e.g.: "redis-master") are always qualified with search domain paths
* Multi-label hostnames are first tried as absolute names and only qualified with search paths if this does not yield results from the upstream server

## Usage

Building your own image based on Alpine-Kubernetes is as easy as typing    
`FROM janeczku/alpine-kubernetes`.    
The official Alpine Docker image is well documented, so check out [their documentation](http://gliderlabs.viewdocs.io/docker-alpine) to learn more about building micro Docker images with Alpine Linux.

*The small print:*    
Do NOT redeclare the `ENTRYPOINT` in your Dockerfile as this is being used for s6's `init` script.

### Example Alpine Redis image

```Dockerfile
FROM janeczku/alpine-kubernetes:3.2
RUN apk-install redis
CMD ["redis-server"]
```

## Docker Hub image tags

Alpine-Kubernetes image tags follow the official [Alpine Linux image](https://hub.docker.com/_/alpine/).
To build your images with the latest version of Alpine-Kubernetes that is based on Alpine Linux 3.2 use: 

```Dockerfile
FROM janeczku/kubernetes-alpine:3.2
```

Each release build is also statically tagged. Those have the form of `<Alpine Linux image version>-<Alpine-Kubernetes build number>`, e.g.: `3.2-34`.
 
### DNS server configuration
The DNS server can be configured by providing environment variables either at runtime with `docker run -e ...` or from within the Dockerfile.
Check out the documentation for [go-dnsmasq](https://github.com/janeczku/go-dnsmasq) to find out what configuration options are available.

## Acknowledgement

* [Gliderlabs](http://gliderlabs.com/) for providing the official [Alpine Docker image](https://hub.docker.com/_/alpine/)
* [Sillien](http://gliderlabs.com/) for coming up with the original idea of creating a base image dealing with Alpine Linux's DNS shortcomings in Tutum/Kubernets clusters: [base-alpine](https://github.com/sillelien/base-alpine/)

