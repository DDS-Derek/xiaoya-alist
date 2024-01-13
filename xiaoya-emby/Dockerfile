FROM amilys/embyserver:4.8.0.56

COPY --from=alpine:3.19 / /

ENV LANG=C.UTF-8 \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]" \
    S6_SERVICES_GRACETIME=30000 \
    S6_KILL_GRACETIME=60000 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_SYNC_DISKS=1 \
    TZ=Asia/Shanghai

RUN set -ex && \
    apk add --update --no-cache \
        sqlite \
        unzip \
        bash \
        curl \
        gzip \
        ripgrep \
        busybox-extras \
        nginx \
        nginx-mod-http-js \
        jq \
        tzdata && \
    rm -rf /tmp/* /var/cache/apk/* && \
    mv /usr/bin/rg /bin/grep

COPY --from=xiaoyaliu/alist:latest /opt/alist/alist /opt/alist/alist
COPY --from=xiaoyaliu/alist:latest /var/lib/data.zip /var/lib/data.zip
COPY --from=xiaoyaliu/alist:latest /entrypoint.sh /entrypoint.sh
COPY --from=xiaoyaliu/alist:latest /updateall /updateall

RUN echo "v."`date +%m%d.%H%M\(B\)` > /docker.version

COPY --chmod=755 ./rootfs /