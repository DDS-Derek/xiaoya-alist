# Xiaoya Proxy

小雅容器代理工具，确保 UA 统一。

## Run

```shell
docker run -d \
    --name=xiaoya-proxy \
    --restart=always \
    --net=host \
    -e TZ=Asia/Shanghai \
    ddsderek/xiaoya-proxy:latest
```
