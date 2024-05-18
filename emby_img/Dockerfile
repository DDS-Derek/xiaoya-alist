ARG EMBY_IMAGE
ARG EMBY_VERSION

FROM ${EMBY_IMAGE}:${EMBY_VERSION}

COPY --chmod=755 run.sh /etc/cont-init.d/run

RUN sed -i 's|programdata /config|programdata /volume_img/config|g' /etc/services.d/emby-server/run
