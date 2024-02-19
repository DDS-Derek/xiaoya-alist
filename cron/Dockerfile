FROM alpine:3.19

ENV TZ=Asia/Shanghai

RUN set -ex && \
    apk add --no-cache \
        jq \
        bash \
        curl \
        docker \
        s6-overlay \
        tzdata \
        sqlite && \
    rm -rf \
        /var/cache/apk/* \
        /tmp/*

COPY --chmod=755 ./rootfs /

ENTRYPOINT [ "/init" ]
