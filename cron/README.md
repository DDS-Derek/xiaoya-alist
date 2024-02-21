## 示例

```shell
docker run -itd \
    --name=xiaoya-cron \
    -e TZ=Asia/Shanghai \
    -e EMBY=xiaoya-emby \
    -e RESILIO=xiaoya-resilio \
    -e CRON="30 05 */3 * *" \
    -e HOST_MEDIA_DIR=/ssd/data/docker/xiaoya/media \
    -e HOST_RESILIO_DIR=/ssd/data/docker/xiaoya/resilio \
    -e HOST_CONFIG_DIR=/ssd/data/docker/xiaoya/xiaoya \
    -v "/ssd/data/docker/xiaoya/resilio:/ssd/data/docker/xiaoya/resilio" \
    -v "/ssd/data/docker/xiaoya/media:/ssd/data/docker/xiaoya/media" \
    -v "/ssd/data/docker/xiaoya/xiaoya:/ssd/data/docker/xiaoya/xiaoya" \
    -v /tmp:/tmp \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --net=host \
    --restart=always \
    ddsderek/xiaoya-cron:latest
```