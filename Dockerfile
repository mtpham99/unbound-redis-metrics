FROM alpine:3.21.3 as builder-base

ENV CFLAGS="-O3 -flto" \
    BUILD_DEPS="gcc make libc-dev go protobuf-c-dev ca-certificates curl tar gnupg git openssl-dev libevent-dev nghttp2-dev libsodium-dev hiredis-dev expat-dev libmnl-dev"

RUN set -xeu && \
    apk update && apk add --no-cache ${BUILD_DEPS}


FROM builder-base as redis

ENV REDIS_VERSION=7.4.2

ENV REDIS_SOURCE=https://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz \
    REDIS_SHA256=https://raw.githubusercontent.com/redis/redis-hashes/master/README

WORKDIR /tmp/redis

RUN set -xeu && \
    curl -sSL -o redis-${REDIS_VERSION}.tar.gz ${REDIS_SOURCE} && \
    curl -sSL -o redis-hashes.txt ${REDIS_SHA256} && \
    echo "$(grep redis-${REDIS_VERSION}.tar.gz redis-hashes.txt | awk '{print $4}') redis-${REDIS_VERSION}.tar.gz" | sha256sum -c - && \
    tar -xzf redis-${REDIS_VERSION}.tar.gz && \
    cd redis-${REDIS_VERSION} && \
    make MALLOC=libc -j$(nproc) && \
    make PREFIX=/usr/local install && \
    rm -rf /usr/local/share


FROM builder-base as unbound

ENV UNBOUND_VERSION=1.22.0

ENV UNBOUND_SOURCE=https://nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz \
    UNBOUND_SHA256=https://www.nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz.sha256 \
    UNBOUND_PGP=https://nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz.asc \
    UNBOUND_GPG_KEY=EDFAA3F2CA4E6EB05681AF8E9F6F1C2D7E045F8D

WORKDIR /tmp/unbound

RUN set -xeu && \
    curl -sSL -o unbound-${UNBOUND_VERSION}.tar.gz ${UNBOUND_SOURCE} && \
    curl -sSL -o unbound-${UNBOUND_VERSION}.tar.gz.sha256 ${UNBOUND_SHA256} && \
    curl -sSL -o unbound-${UNBOUND_VERSION}.tar.gz.asc ${UNBOUND_PGP} && \
    echo "$(cat unbound-${UNBOUND_VERSION}.tar.gz.sha256) unbound-${UNBOUND_VERSION}.tar.gz" | sha256sum -c - && \
    gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys ${UNBOUND_GPG_KEY} && \
    gpg --verify unbound-${UNBOUND_VERSION}.tar.gz.asc unbound-${UNBOUND_VERSION}.tar.gz && \
    tar -xzf unbound-${UNBOUND_VERSION}.tar.gz && \
    cd unbound-${UNBOUND_VERSION} && \
    ./configure \
    --prefix=/usr/local \
    --enable-shared=no \
    --enable-static=yes \
    --with-conf-file=/etc/unbound.conf \
    --with-run-dir=/run/unbound \
    --with-username=unbound \
    --disable-dependency-tracking \
    --disable-option-checking \
    --disable-rpath \
    --enable-subnet \
    --enable-tfo-client \
    --enable-tfo-server \
    --enable-dnstap \
    --enable-dnscrypt \
    --enable-cachedb \
    --enable-ipsecmod \
    --enable-ipset \
    --enable-event-api \
    --with-pthreads \
    --with-ssl=/usr \
    --with-libevent=/usr \
    --with-libexpat=/usr \
    --with-libhiredis=/usr \
    --with-libnghttp2=/usr \
    --with-protobuf-c=/usr \
    --with-libsodium=/usr \
    --with-libmnl=/usr && \
    make -j$(nproc) && \
    make install && \
    rm -rf /usr/local/share


FROM builder-base as unbound-exporter

ENV UNBOUND_EXPORTER_SOURCE="https://github.com/ar51an/unbound-exporter.git"

WORKDIR /tmp/unbound-exporter

RUN set -xeu && \
    apk update && apk add --no-cache ${BUILD_DEPS} && \
    mkdir unbound-exporter && cd unbound-exporter && \
    git clone --depth=1 --single-branch ${UNBOUND_EXPORTER_SOURCE} && \
    cd unbound-exporter && \
    go mod tidy && go build && strip unbound-exporter && \
    cp unbound-exporter /usr/local/bin


FROM alpine:3.21.3

ENV RUNTIME_DEPS="ca-certificates curl protobuf-c openssl libevent nghttp2 libsodium hiredis expat-dev libmnl sed grep coreutils drill dcron loki-promtail logrotate"

RUN set -xeu && \
    apk update && apk add --no-cache ${RUNTIME_DEPS} && \
    addgroup -S unbound && adduser -SDH unbound -G unbound && \
    addgroup -S redis && adduser -SDH redis -G redis && \
    addgroup -S promtail && adduser -SDH promtail -G promtail && \
    addgroup -S unbound-redis && adduser unbound unbound-redis && adduser redis unbound-redis

COPY --from=redis /usr/local /usr/local
COPY --from=unbound /usr/local /usr/local
COPY --from=unbound-exporter /usr/local /usr/local
COPY ./configs/ /etc/
COPY ./scripts/ /scripts/

RUN set -xeu && \
    chown -R unbound:unbound /scripts/ && \
    chmod -R u+x /scripts/ && \
    mkdir -p /run/unbound /etc/unbound.d /run/redis /etc/redis.d /etc/promtail /etc/cron.d && \
    /scripts/update_blocklist.sh && \
    /scripts/update_roothints.sh && \
    chown -R unbound:unbound /run/unbound /etc/unbound.conf /etc/unbound.d && \
    chown -R redis:redis /run/redis /etc/redis.conf /etc/redis.d && \
    chown -R promtail:promtail /etc/promtail

EXPOSE 53/tcp 53/udp 9167/tcp
# EXPOSE 443/tcp 6379/tcp

WORKDIR /run/unbound

CMD /scripts/start.sh
HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 CMD /scripts/healthcheck.sh
