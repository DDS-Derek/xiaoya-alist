FROM alpine:3.20

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
        docker \
        curl \
        tini && \
    rm -rf \
        /root/.cache \
        /tmp/*

WORKDIR /app

COPY --chmod=755 . /app

ENTRYPOINT ["tini", "-g", "--", "/app/entrypoint.sh"]