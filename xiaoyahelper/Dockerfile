FROM alpine:3.18.2

ENV LANG=zh_CN.UTF-8 \
    TZ=Asia/Shanghai

RUN apk add --no-cache \
       docker-cli \
       curl \
       tzdata && \
       cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
       echo "Asia/Shanghai" >/etc/timezone

COPY xiaoyahelper/aliyun_clear.sh /etc/xiaoya/aliyun_clear.sh

RUN chmod 755 /etc/xiaoya/aliyun_clear.sh

CMD ["sh", "/etc/xiaoya/aliyun_clear.sh", "5"]
