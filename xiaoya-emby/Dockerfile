FROM scratch as emby

COPY --from=amilys/embyserver:4.8.0.56 /bin /bin
COPY --from=amilys/embyserver:4.8.0.56 /etc /etc
COPY --from=amilys/embyserver:4.8.0.56 /usr /usr
COPY --from=amilys/embyserver:4.8.0.56 /system /system
COPY --from=amilys/embyserver:4.8.0.56 /share /share
COPY --from=amilys/embyserver:4.8.0.56 /init /init
COPY --from=amilys/embyserver:4.8.0.56 /lib /lib
COPY --from=amilys/embyserver:4.8.0.56 /libexec /libexec
COPY --from=amilys/embyserver:4.8.0.56 /licenses /licenses

FROM alpine:3.19

ENV LANG=C.UTF-8 \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]" \
    S6_SERVICES_GRACETIME=30000 \
    S6_KILL_GRACETIME=60000 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_SYNC_DISKS=1 \
    TZ=Asia/Shanghai

ENV AMDGPU_IDS=/share/libdrm/amdgpu.ids \
    FONTCONFIG_PATH=/etc/fonts \
    LD_LIBRARY_PATH=/lib:/system \
    LIBVA_DRIVERS_PATH=/lib/dri \
    OCL_ICD_VENDORS=/etc/OpenCL/vendors \
    PCI_IDS_PATH=/share/hwdata/pci.ids \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    UID=0 \
    GID=0 \
    GIDLIST=0 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,video,utility \
    XDG_CACHE_HOME=/config/cache

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
COPY --from=emby / /

RUN echo "v."`date +%m%d.%H%M\(B\)` > /docker.version

COPY --chmod=755 ./rootfs /

ENTRYPOINT ["/init"]