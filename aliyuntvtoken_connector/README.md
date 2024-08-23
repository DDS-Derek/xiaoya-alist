# 阿里云盘 TV Token 令牌刷新接口

## Run

**docker-cli**

```shell
docker run -d \
    -p 34278:34278 \
    --name=xiaoya-aliyuntvtoken_connector \
    --restart=always \
    ddsderek/xiaoya-glue:aliyuntvtoken_connector
```

**docker-compose**

```yaml
version: "3"
services:
    aliyuntvtoken_connector:
        ports:
            - 34278:34278
        container_name: xiaoya-aliyuntvtoken_connector
        restart: always
        image: ddsderek/xiaoya-glue:aliyuntvtoken_connector
```

令牌刷新接口地址：`http://ip:34278/oauth/alipan/token`