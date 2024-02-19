```shell
docker run -d \
    --name=xiaoya-cron \
    -e TZ=Asia/Shanghai \
    -e EMBY= \
    -e RESILIO= \
    -e CRON= \
    -v "${RESILIO_DIR}:/config" \
    -v "${MEDIA_DIR}:/media" \
    -v "${XIAOYA_DIR}:/etc/xiaoya" \
    --restart=always \
    ddsderek/xiaoya-cron:latest
```