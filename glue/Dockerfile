FROM ubuntu:22.04

RUN set -ex && \
    apt update -y && \
    apt install -y \
        busybox \
        unzip \
        curl \
        fd-find \
        gzip \
        wget \
        lsof \
        tzdata && \
    rm -rf /tmp/* /var/lib/apt/lists/*

COPY --chmod=755 docker_address.sh /docker_address.sh