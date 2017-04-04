FROM qnib/alplain-init

ENV GOSU_VERSION 1.9
RUN set -x \
    && apk add --no-cache --virtual .gosu-deps \
        dpkg \
        gnupg \
        curl \
    && export ARCH=$(echo $(dpkg --print-architecture) | cut -d"-" -f3) \
    && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$ARCH" \
    && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$ARCH.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apk del .gosu-deps

RUN addgroup crate && adduser -G crate -H crate -D

# install crate
ENV CRATE_VERSION 1.1.1
RUN apk add --no-cache --virtual .crate-rundeps \
        openjdk8-jre-base \
        python3 \
        openssl \
        sigar \
    && apk add --no-cache --virtual .build-deps \
        curl \
        gnupg \
        tar 
RUN set -x \
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz \
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 90C23FC6585BC0717F8FBFC37FAAE51A06F6EAEB \
    && gpg --batch --verify crate-$CRATE_VERSION.tar.gz.asc crate-$CRATE_VERSION.tar.gz \
    && rm -r "$GNUPGHOME" crate-$CRATE_VERSION.tar.gz.asc \
    && mkdir /crate \
    && tar -xf crate-$CRATE_VERSION.tar.gz -C /crate --strip-components=1 \
    && rm crate-$CRATE_VERSION.tar.gz \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && rm /crate/plugins/sigar/lib/libsigar-amd64-linux.so \
    && apk del .build-deps

ENV PATH /crate/bin:$PATH

VOLUME ["/data"]

ADD config/crate.yml /crate/config/crate.yml
ADD config/logging.yml /crate/config/logging.yml
ENV ENTRY_USER=crate
COPY opt/qnib/entry/15-crate-chown.sh /opt/qnib/entry/
COPY opt/qnib/crate/bin/start.sh /opt/qnib/crate/bin/
CMD ["/opt/qnib/crate/bin/start.sh"]
