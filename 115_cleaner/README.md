# 115 清理助手

自动清理 115 转存文件。

## Run

```shell
docker run -d \
    --name=xiaoya-115cleaner \
    -v 小雅配置文件目录:/data \
    --net=host \
    -e TZ=Asia/Shanghai \
    --restart=always \
    ddsderek/xiaoya-115cleaner:latest
```
