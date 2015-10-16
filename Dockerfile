FROM gliderlabs/alpine:3.2
MAINTAINER Jan Broer <janeczku@yahoo.com>

COPY rootfs /
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.15.0.0/s6-overlay-amd64.tar.gz /tmp/s6-overlay.tar.gz
ADD https://github.com/janeczku/go-dnsmasq/releases/download/0.9.5/go-dnsmasq-min_linux-amd64 /usr/sbin/go-dnsmasq

RUN tar xvfz /tmp/s6-overlay.tar.gz -C / && \
  chmod 755 /usr/sbin/go-dnsmasq /etc/services.d/dns/run /etc/services.d/syslog/run

ENTRYPOINT ["/init"]
CMD []
