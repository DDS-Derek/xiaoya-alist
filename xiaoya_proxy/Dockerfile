FROM alpine:3.20

ENV LANG=zh_CN.UTF-8 \
    TZ=Asia/Shanghai \
    DEBUG=true \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]"

RUN apk add --no-cache \
       openjdk8-jre \
       dumb-init \
       tzdata \
       bash && \
    rm -rf /var/cache/apk/* /tmp/*

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 target/xiaoya_proxy-*.jar /xiaoya_proxy.jar

EXPOSE 9988

ENTRYPOINT [ "/entrypoint.sh" ]
