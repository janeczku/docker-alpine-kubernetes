
# Alpine-Kubernetes base image

[![CircleCI](https://img.shields.io/circleci/project/janeczku/docker-alpine-kubernetes.svg?style=flat-square)](https://circleci.com/gh/janeczku/docker-alpine-kubernetes)

The Alpine-Kubernetes base image enables deployment of Alpine Linux micro-service containers in Kubernetes, Consul, Tutum or other Docker cluster environments that use DNS-based service discovery and rely on the containers being able to use the `search` domains from resolv.conf for resolving service names.

## About

Alpine-Kubernetes is based on the official [Docker Alpine](https://hub.docker.com/_/alpine/) image adding the excellent [s6 supervisor for containers](https://github.com/just-containers/s6-overlay) and [go-dnsmasq DNS server](https://github.com/janeczku/go-dnsmasq). Both s6 and go-dnsmasq introduce very minimal runtime and filesystem overhead.    
Trusted builds are available on [Docker Hub](https://hub.docker.com/r/janeczku/alpine-kubernetes/).

-------

[![Imagelayers](https://badge.imagelayers.io/janeczku/alpine-kubernetes:latest.svg)](https://imagelayers.io/?images=janeczku/alpine-kubernetes:latest 'Get your own badge on imagelayers.io') 
[![Docker Pulls](https://img.shields.io/docker/pulls/janeczku/alpine-kubernetes.svg?style=flat-square)](https://hub.docker.com/r/janeczku/alpine-kubernetes/)

## Motivation
Alpine Linux does not support the `search` keyword in resolv.conf. This absolutely breaks things in environments that rely on DNS service discovery (e.g. Kubernetes, Tutum.co, Consul).
Additionally Alpine Linux deviates from the well established pardigm of always querying the primary DNS server first. This introduces problems in cases where the host is configured with multiple nameserver with inconsistent records (e.g. one Consul server and one recursing server).
    
To overcome these issues the Alpine-Kubernetes base image embeds a lightweight (1.2 MB) local DNS server that replicates GNU libc's resolver logic and enables processes running in the container to properly resolve service names.

## How it works
The embedded DNS server acts as the nameserver for processes running in the container. On container start it parses the `nameserver` and `search` entries from the containers /etc/resolv.conf and configures itself as the nameserver for the container. It answers DNS queries according to the following conventions:
* The nameserver listed first in resolv.conf is the primary server. It is always queried first.
* Hostnames are qualified by appending the domains configured by the `search` keyword in resolv.conf
* Single-label hostnames (e.g.: "redis-master") are always qualified with search domain paths
* Multi-label hostnames are first tried as absolute names and only qualified with search paths if this does not yield results from the upstream server

## Usage

Building your own image based on Alpine-Kubernetes is as easy as typing    
`FROM janeczku/alpine-kubernetes`.    
The official Alpine Docker image is well documented, so check out [their documentation](http://gliderlabs.viewdocs.io/docker-alpine) to learn more about building micro Docker images with Alpine Linux.

*The small print:*    
Do NOT redeclare the `ENTRYPOINT` in your Dockerfile as this is reserved for S6's init script.

### Example Alpine Redis image

```Dockerfile
FROM janeczku/alpine-kubernetes:3.2
RUN apk-install redis
CMD ["redis-server"]
```

### Optional: Multiple processes in a single container

If you care to run multiple processes in a single container you can leverage s6 supervised services to achieve that. Instructions can be found [here](https://github.com/just-containers/s6-overlay#writing-a-service-script). Since the DNS server itself is a service, any additional services need to be configured to be started **after** the DNS service. This is accomplished by adding the following line to the service script:

> if { s6-svwait -t 5000 -u /var/run/s6/services/resolver }

#### Example service script

```BASH
#!/usr/bin/execlineb -P
if { s6-svwait -t 5000 -u /var/run/s6/services/resolver }
with-contenv
nginx
```

## Docker Hub image tags

Alpine-Kubernetes image tags follow the official [Alpine Linux image](https://hub.docker.com/_/alpine/).
To build your images with the latest version of Alpine-Kubernetes that is based on Alpine Linux 3.2 use: 

```Dockerfile
FROM janeczku/alpine-kubernetes:3.2
```

Each release build is also statically tagged with `<Alpine Linux image version>-<Alpine-Kubernetes build number>`, e.g.: `3.2-34`.
 
### DNS server configuration (optional)
Configuration of the DNS server can be adjusted by providing environment variables either at runtime with `docker run -e ...` or from within the Dockerfile.
Check out the documentation for [go-dnsmasq](https://github.com/janeczku/go-dnsmasq) to find out what configuration options are available.

## Acknowledgement

* [Gliderlabs](http://gliderlabs.com/) for providing the official [Alpine Docker image](https://hub.docker.com/_/alpine/)
* [Sillien](http://gliderlabs.com/) for coming up with the original idea of creating a base image dealing with Alpine Linux's DNS shortcomings in Tutum/Kubernets clusters: [base-alpine](https://github.com/sillelien/base-alpine/)

