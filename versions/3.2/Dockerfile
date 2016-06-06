FROM alpine:3.2
MAINTAINER Jan Broer <janeczku@yahoo.com>

##
## S6 Overlay && go-dnsmasq
##

ENV S6_VERSION=v1.17.1.1 GODNSMASQ_VERSION=1.0.6

RUN apk add --update wget \
	&& wget https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz --no-check-certificate --quiet -O /tmp/s6-overlay.tar.gz \
	&& wget https://github.com/janeczku/go-dnsmasq/releases/download/${GODNSMASQ_VERSION}/go-dnsmasq-min_linux-amd64 --no-check-certificate --quiet -O /usr/sbin/go-dnsmasq \
	&& chmod +x /usr/sbin/go-dnsmasq \
	&& tar xvfz /tmp/s6-overlay.tar.gz -C / \
	&& rm -f /tmp/s6-overlay.tar.gz \
	&& apk del wget \
	&& rm -rf /var/cache/apk/*

##
## RootFS
##

COPY rootfs /

##
## Init
##

ENTRYPOINT ["/init"]