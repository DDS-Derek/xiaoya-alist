FROM alpine:3.19

ENV LANG=C.UTF-8 \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]" \
    TZ=Asia/Shanghai

RUN set -ex && \
    apk add --no-cache \
        jq \
        bash \
        tzdata \
        grep \
        sqlite \
        docker

WORKDIR /app

COPY --chmod=755 . /app

ENTRYPOINT [ "/entrypoint.sh" ]

# docker run -d -v /ssd/data/docker/xiaoya/media:/data -v /var/run/docker.sock:/var/run/docker.sock:ro --net=host alpine:latest
# EMBY_NAME EMBY_API EMBY_URL CRON