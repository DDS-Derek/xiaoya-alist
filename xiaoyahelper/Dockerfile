FROM alpine:3.20

ENV LANG=zh_CN.UTF-8 \
    TZ=Asia/Shanghai

RUN apk add --no-cache \
       docker-cli \
       curl \
       tzdata \
       bash

COPY --chmod=755 aliyun_clear.sh /etc/xiaoya/aliyun_clear.sh

CMD ["sh", "/etc/xiaoya/aliyun_clear.sh", "5"]
