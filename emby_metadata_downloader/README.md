# 小雅同步元数据

高速异步爬虫从 https://emby.xiaoya.pro/ 同步小雅元数据

## Run

```shell
docker run -d \
    --name=xiaoya-emd \
    --restart=always \
    --net=host \
    -v 媒体库目录:/media \
    -e CYCLE=86400 \
    ddsderek/xiaoya-emd:latest
```
