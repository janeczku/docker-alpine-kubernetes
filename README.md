
# Alpine-kubernetes

The Alpine-kubernetes base-image is targeted to users wanting to run Alpine Linux in Kubernetes clusters or in other (e.g. Tutum.co) docker hosting environments that rely on resolv.conf SEARCH domain functionality for DNS-based service discovery.

## About
Alpine Linux uses musl-libc and as such does not support the SEARCH keyword in resolv.conf. This absolutely breaks things in environments that rely on DNS service discovery (e.g. Kubernetes, Tutum.co).
    
To overcome this issue Alpine-kubernetes comes with a lightweight (1.15 MB) DNS-resolver background process that replicates glibc's SEARCH path feature.   
As an added bonus - unlike the native glibc implementation - Alpine-kubernetes does not limit the number of SEARCH paths and nameservers.
    
Alpine-kubernetes is based on gliderlabs [Alpine base-image](https://github.com/gliderlabs/docker-alpine) and uses the [S6](http://skarnet.org/software/s6/) process manager and [go-dnsmasg](https://github.com/janeczku/go-dnsmasq) DNS-resolver for minimal runtime and filesystem overhead.

-------

[![Imagelayers](https://badge.imagelayers.io/janeczku/alpine-kubernetes:latest.svg)](https://imagelayers.io/?images=janeczku/alpine-kubernetes:latest 'Get your own badge on imagelayers.io') [![Docker Pulls](https://img.shields.io/docker/pulls/janeczku/alpine-kubernetes.svg?style=flat-square)](https://hub.docker.com/r/janeczku/alpine-kubernetes/)

## Usage

Alpine-kubernetes can be used as any other base image. Read [these instruction](https://github.com/gliderlabs/docker-alpine#usage) for the specifics of building images based on Alpine Linux.

**Example - Alpine Docker Redis image:**

```Dockerfile
FROM janeczku/alpine-kubernetes
RUN apk-install redis
CMD ["redis-server"]
```



**The small print:**    
You should NOT redeclare the ENTRYPOINT in your Dockerfile as this would prevent the process manager and the DNS-resolver from running.

### Multi-process docker images
Creating multi-process containers is absolutely easy thanks to the build-in process manager: Just add  applications as supervised S6 services following the instructions [here](https://github.com/just-containers/s6-overlay#usage).

**Example - Nginx as a supervised service:**

Create a service script named `run`:

```bash
#!/usr/bin/env sh
exec nginx -g "daemon off;" 2>&1 | logger
```

*In case you wonder: `2>&1 | logger` effectively redirects Nginx's stdout/stderr to the console making sure that it is visible in `docker logs`.*

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

Additionally, images are tagged with the version of the [Alpine docker](http://gliderlabs.com/) image they are derived from suffixed with a Alpine-kubernetes version number. For example: `3.2.1.0` where  `3.2` is the version of the Alpine Docker base image used and `1.0` is the version of the Alpine-kubernetes image derived from that 3.2 base image.

## About the DNS-resolver

On container start the DNS-resolver reads the NAMESERVERS and SEARCH domains in /etc/resolv.conf and then registers itself as the local resolver. When the resolver receives a single-label DNS query from a process running in the container it will resolve the query by appending the SEARCH domains and querying the appropriate nameservers.
 
### Configuration
The behavior of the DNS-resolver can be changed by providing environment variables when starting the container. This allows you to e.g. specify specific nameservers or search-domains taking precedence over the values in the containers resolv.conf.
Read the documentation for [go-dnsmasg](https://github.com/janeczku/go-dnsmasq) to find out what configuration variables can be passed on container start.

## Credits

* [Gliderlabs](http://gliderlabs.com/) for providing the [Alpine docker](http://gliderlabs.com/) base-image.
* [Sillien](http://gliderlabs.com/) for the original idea of creating a base-image dealing with Alpine Linux DNS shortcomings in Tutum/Kubernets clusters: [base-alpine](https://github.com/sillelien/base-alpine/)

