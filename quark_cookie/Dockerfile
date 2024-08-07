FROM python:3.12.4-slim-bookworm

ENV TZ=Asia/Shanghai \
    DISPLAY=:956 \
    PLAYWRIGHT_BROWSERS_PATH=/quark_cookie/firefox

WORKDIR /quark_cookie

COPY --chmod=755 . /quark_cookie

RUN apt-get update -y && \
    apt-get install -y xvfb && \
    pip install --no-cache --upgrade pip && \
    pip install --no-cache -r requirements.txt && \
    playwright install-deps firefox && \
    playwright install firefox && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

CMD [ "/quark_cookie/quark_cookie.py" ]
