FROM python:3.12-alpine3.20

ENV TZ=Asia/Shanghai

WORKDIR /app

COPY . .

RUN set -ex && \
    apk add --no-cache \
        bash \
        tzdata && \
    python3 -m pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /app/requirements.txt && \
    rm -rf \
        /root/.cache \
        /tmp/*

EXPOSE 34278

ENTRYPOINT [ "python3", "/app/main.py" ]
