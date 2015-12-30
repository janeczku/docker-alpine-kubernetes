FROM janeczku/alpine-kubernetes:3.3

ADD ./tests/alpine-kubernetes.bats /tests/bats-tests
ADD ./tests/alpine-kubernetes-more.bats /tests/bats-tests-more
ADD ./tests/bats-master.zip /tmp/bats.zip

RUN apk-install bind-tools bash \
	&& cd /tmp \
	&& unzip -q bats.zip \
	&& ./bats-master/install.sh /usr/local \
	&& ln -sf /usr/local/libexec/bats /usr/local/bin/bats

CMD [ "/bin/sh", "-c", "sleep 5; /usr/local/bin/bats /tests/bats-tests" ]
