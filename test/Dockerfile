FROM janeczku/alpine-kubernetes:3.2

ADD ./test/alpine-kubernetes.bats /app/bats-tests
ADD ./test/alpine-kubernetes-more.bats /app/bats-tests-more
ADD ./test/bats-master.zip /tmp/bats.zip

RUN apk-install bind-tools bash \
	&& cd /tmp \
	&& unzip -q bats.zip \
	&& ./bats-master/install.sh /usr/local \
	&& ln -sf /usr/local/libexec/bats /usr/local/bin/bats

CMD [ "/bin/sh", "-c", "sleep 5; /usr/local/bin/bats /app/bats-tests" ]