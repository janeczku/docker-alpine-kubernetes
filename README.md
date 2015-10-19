
# Alpine-kubernetes

The Alpine-kubernetes base image is targeted at scenarios where Alpine Linux containers are deployed in Kubernetes or any other Docker cluster environment that relies on resolv.conf `search` domain handling for DNS-based service discovery.

## About
Alpine Linux uses musl-libc and as such does not support the `search` keyword in resolv.conf. This absolutely breaks things in environments that rely on DNS service discovery (e.g. Kubernetes, Tutum.co, Consul).    
Additionally Alpine Linux deviates from the well established GNU libc's logic of always querying the primary DNS server first. Instead it sends parallel queries to all nameservers and returns whatever answer it receives first. This introduces problems in cases where the host is configured with multiple nameserver with inconsistent records (e.g. one Consul server and one recursing server).
    
To overcome this issues Alpine-kubernetes provides a lightweight (1.2 MB) local DNS resolver that replicates GNU libc's resolver logic.
As an added bonus - unlike the native GNU libc resolver - Alpine-kubernetes does not limit the number of `search` and `nameservers` entries.

Alpine-kubernetes is based on the official [Docker Alpine](https://hub.docker.com/_/alpine/) image adding the excellent [s6 supervisor for containers](https://github.com/just-containers/s6-overlay) and [go-dnsmasg](https://github.com/janeczku/go-dnsmasq). Both s6 and go-dnsmasq introduce very minimal runtime and filesystem overhead.

-------

[![Imagelayers](https://badge.imagelayers.io/janeczku/alpine-kubernetes:latest.svg)](https://imagelayers.io/?images=janeczku/alpine-kubernetes:latest 'Get your own badge on imagelayers.io') [![Docker Pulls](https://img.shields.io/docker/pulls/janeczku/alpine-kubernetes.svg?style=flat-square)](https://hub.docker.com/r/janeczku/alpine-kubernetes/)

## About the local DNS resolver

On container start the DNS resolver parses the `nameserver` and `search` domains from the containers /etc/resolv.conf and configures itself as the primary nameserver for the container. When it receives DNS queries from local processes it handles them according to the logic applied by GNU C library's getaddrinfo.c:
* The first nameserver in resolv.conf is the primary server. It is always queried first.
* Hostnames are qualified by appending the domains configured by the `search` keyword in resolv.conf
* Single-label hostnames (e.g.: "redis-master") will always be qualified with search domain paths
* Multi-label hostnames will first tried as-is and only qualified in case this does not return any records from the upstream server

## Usage

Building your own image based on Alpine-kubernetes is as easy as typing `FROM janeczku/alpine-kubernetes`.    
The official Alpine Docker image is well documented, so check out [their documentation](http://gliderlabs.viewdocs.io/docker-alpine) to learn more about building micro Docker images with Alpine Linux.

*The small print:*    
Do NOT redeclare the `ENTRYPOINT` in your Dockerfile as this is used by s6's `init` script.

### Example Alpine Redis iamge

```Dockerfile
FROM janeczku/alpine-kubernetes
RUN apk-install redis
CMD ["redis-server"]
```

## Docker Hub image tags

It is recommended to use the image tagged as 'latest'.

Additionally, images are tagged with the version of the [Docker Alpine](https://github.com/gliderlabs/docker-alpine) image they are derived from suffixed with a Alpine-kubernetes version number. For example: `3.2.1.0` where  `3.2` is the version of the Alpine Docker base image used and `1.0` is the version of the Alpine-kubernetes image derived from that 3.2 base image.
 
### Configuration
The behavior of the DNS resolver can be configure by providing environment variables when starting the container. This allows you - inter alia - to specify specific nameservers or search-domains to take precedence over the values in the containers resolv.conf.
Read the documentation for [go-dnsmasg](https://github.com/janeczku/go-dnsmasq) to find out what configuration variables can be passed on container start.

## Acknowledgement

* [Gliderlabs](http://gliderlabs.com/) for providing the official [Alpine Docker image](https://hub.docker.com/_/alpine/)
* [Sillien](http://gliderlabs.com/) for coming up with the original idea of creating a base image dealing with Alpine Linux's DNS shortcomings in Tutum/Kubernets clusters: [base-alpine](https://github.com/sillelien/base-alpine/)

