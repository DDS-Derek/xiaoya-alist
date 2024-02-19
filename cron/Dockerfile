FROM alpine:3.19

RUN set -ex && \
    apk add --no-cache \
        jq \
        bash \
        curl \
        docker \
        s6-overlay \
        sqlite && \
    rm -rf \
        /var/cache/apk/* \
        /tmp/*

COPY --chmod=755 ./rootfs /

ENTRYPOINT [ "/init" ]
