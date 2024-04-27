FROM python:3.12-alpine3.19

ENV TZ=Asia/Shanghai \
    CYCLE=86400

RUN set -ex && \
    apk add --no-cache \
        bash \
        git \
        tzdata && \
    git clone -b main https://github.com/Rik-F5/xiaoya_db.git /app && \
    python3 -m pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /app/requirements.txt

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["--media", "/media", "--db", "true"]
