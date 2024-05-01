FROM python:3.12-alpine3.19

ENV TZ=Asia/Shanghai \
    CYCLE=86400

ARG BRANCH

RUN set -ex && \
    apk add --no-cache \
        bash \
        git \
        tini \
        tzdata && \
    apk add --no-cache --virtual=build-dependencies \
        build-base \
        gcc \
        g++ && \
    git clone -b ${BRANCH} https://github.com/Rik-F5/xiaoya_db.git /app && \
    python3 -m pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /app/requirements.txt && \
    apk del --purge build-dependencies && \
    rm -rf \
        /root/.cache \
        /tmp/*

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["tini", "-g", "--", "/entrypoint.sh"]

CMD ["--media", "/media"]
