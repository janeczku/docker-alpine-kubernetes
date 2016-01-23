FROM alpine:3.3
MAINTAINER Jan Broer <janeczku@yahoo.com>

##
## Add bind-tools
##

RUN apk add --update bind-tools && \
    rm -rf /var/cache/apk/*

##
## S6 Overlay && go-dnsmasq
##

ENV S6_VERSION=v1.17.1.1 GODNSMASQ_VERSION=0.9.8

ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz /tmp/s6-overlay.tar.gz

ADD https://github.com/janeczku/go-dnsmasq/releases/download/${GODNSMASQ_VERSION}/go-dnsmasq-min_linux-amd64 /usr/sbin/go-dnsmasq

RUN tar xvfz /tmp/s6-overlay.tar.gz -C / \
    && chmod 755 /usr/sbin/go-dnsmasq \
    && rm -rf /tmp/*

##
## RootFS
##

COPY rootfs /

##
## Init
##

ENTRYPOINT ["/init"]