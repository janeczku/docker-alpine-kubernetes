
# Alpine-kubernetes

The Alpine-kubernetes base image is targeted at scenarios where Alpine Linux containers are deployed in Kubernetes or any other Docker cluster environment that relies on resolv.conf `search` domain handling for DNS-based service discovery.

## About
Alpine Linux uses musl-libc and as such does not support the `search` keyword in resolv.conf. This absolutely breaks things in environments that rely on DNS service discovery (e.g. Kubernetes, Tutum.co, Consul).    
Additionally Alpine Linux deviates from the well established GNU libc's logic of always querying the primary DNS server first. Instead it sends parallel queries to all nameservers and returns whatever answer it receives first. This introduces problems in cases where the host is configured with multiple nameserver with inconsistent records (e.g. one Consul server and one recursing server).
    
To overcome this issues Alpine-kubernetes bundles a lightweight (1.15 MB) local DNS-resolver that replicates GNU libc's resolve logic.
As an added bonus - unlike the native GNU libc resolver - Alpine-kubernetes does not limit the number of `search` and `nameservers` entries.

Alpine-kubernetes is based on gliderlabs [Docker Alpine image](https://github.com/gliderlabs/docker-alpine) and uses the [S6](http://skarnet.org/software/s6/) process manager and [go-dnsmasg](https://github.com/janeczku/go-dnsmasq) DNS-resolver for minimal runtime and filesystem overhead. Additionally it provides a minimal busybox syslogd that makes syslog messages and stdout/stderr of background processes available in `docker logs`.

-------

[![Imagelayers](https://badge.imagelayers.io/janeczku/alpine-kubernetes:latest.svg)](https://imagelayers.io/?images=janeczku/alpine-kubernetes:latest 'Get your own badge on imagelayers.io') [![Docker Pulls](https://img.shields.io/docker/pulls/janeczku/alpine-kubernetes.svg?style=flat-square)](https://hub.docker.com/r/janeczku/alpine-kubernetes/)

## How the DNS resolver works

On container start the DNS resolver parses the `nameserver` and `search` domains from the containers /etc/resolv.conf and configures itself as the primary nameserver for the container. When it receives DNS queries from local processes it handles them according to the logic applied by GNU C library's getaddrinfo.c:
* The first nameserver in resolv.conf is the primary server. It is always queried first.
* Hostnames are qualified by appending the domains configured by the `search` keyword in resolv.conf
* Single-label hostnames (e.g.: "redis-master") will always be qualified with search domain paths
* Multi-label hostnames will first tried as-is and only qualified in case this does not return any records from the upstream server

## Usage

Alpine-kubernetes can be used like any other base image. Read [these instruction](https://github.com/gliderlabs/docker-alpine#usage) for the specifics of building Docker images based on Alpine Linux.

**Example - Alpine Docker Redis image:**

```Dockerfile
FROM janeczku/alpine-kubernetes
RUN apk-install redis
CMD ["redis-server"]
```

*The small print:*    
You should NOT redeclare the `ENTRYPOINT` in your Dockerfile as this would prevent the process manager and the DNS resolver from running.

### Multi-process Docker images
Creating multi-process images is absolutely easy thanks to the build-in process supervisor: To add applications as supervised S6 services follow the instructions [here](https://github.com/just-containers/s6-overlay#usage).

**Example - Nginx as a supervised service:**

Create a service script named `run`:

```bash
#!/usr/bin/env sh
exec nginx -g "daemon off;" 2>&1 | logger
```

*In case you wonder:*     
`2>&1 | logger` effectively redirects Nginx's stdout/stderr to the console making sure that it is visible in `docker logs`.
     
Then in your Dockerfile just copy the service script to the service directory `/etc/services.d/nginx`:

```Dockerfile
FROM janeczku/alpine-kubernetes
...
COPY /run /etc/services.d/nginx/run
...
```

That's it. Now Nginx will be started as a supervised process by S6 on container start (No need to define `CMD` in your Dockerfile - alas you still can run another process that way).

## Docker Hub image tags

It is recommended to use the image tagged as 'latest'.

Additionally, images are tagged with the version of the [Alpine Docker](http://gliderlabs.com/) image they are derived from suffixed with a Alpine-kubernetes version number. For example: `3.2.1.0` where  `3.2` is the version of the Alpine Docker base image used and `1.0` is the version of the Alpine-kubernetes image derived from that 3.2 base image.
 
### Configuration
The behavior of the DNS resolver can be configure by providing environment variables when starting the container. This allows you - inter alia - to specify specific nameservers or search-domains to take precedence over the values in the containers resolv.conf.
Read the documentation for [go-dnsmasg](https://github.com/janeczku/go-dnsmasq) to find out what configuration variables can be passed on container start.

## Credits

* [Gliderlabs](http://gliderlabs.com/) for providing the [Alpine Docker](http://gliderlabs.com/) base-image.
* [Sillien](http://gliderlabs.com/) for coming up with the original idea of creating a base image dealing with Alpine Linux's DNS shortcomings in Tutum/Kubernets clusters: [base-alpine](https://github.com/sillelien/base-alpine/)

