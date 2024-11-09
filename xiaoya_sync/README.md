# xiaoya-sync

[源项目地址](https://github.com/907739769/xiaoya-sync)

注意，这个docker容器运行任务期间会占用`300MB-700MB`的内存。

同步小雅emby媒体库，每天早上晚上六点同步，服务启动也会执行一次。扫描一次大概30秒钟。

每三天同步一次全量数据，扫描下载一次大概20分钟以上，具体看有多少更新文件。

自动删除本地过时文件夹及文件（小雅媒体库网站不存在的文件及文件夹，不会删除其他目录的文件），网站上面文件的和本地。

同名文件不会删除，防止网站没有`nfo`等文件，但是本地有`nfo`等文件，导致误删`nfo`等文件。

```shell
https://emby.xiaoya.pro/
https://icyou.eu.org/
https://emby.8.net.co/
https://emby.raydoom.tk/
https://emby.kaiserver.uk/
https://embyxiaoya.laogl.top/
https://emby-data.raydoom.tk/
https://emby-data.5168168.xyz/
https://emby-data.ermaokj.com/
https://emby-data.tmxy.pp.ua/
https://emby-data.poxi1221.eu.org/
```

以上网站会同步以下指定目录。

```shell
每日更新/
电影/
纪录片（已刮削）/
音乐/
PikPak/
动漫/
电视剧/
纪录片/
综艺/
📺画质演示测试（4K，8K，HDR，Dolby）/
```

## 部署

### 部署前参数需要修改

> [!WARNING]
> 必要参数

```shell
/volume1/docker-data/xiaoya/xiaoya   修改成媒体库路径
```

> [!NOTE]
> 可选参数

```shell
runAfterStartup      启动是否立即执行同步任务 默认不启用0，启用填1
excludeList          排除列表 默认为空 设置不进行同步及删除的目录例如每日更新/动漫/.*,每日更新/动漫剧场版/.*
syncUrl              同步网站 不填默认从网站池中随机选一个  可选https://icyou.eu.org/或者https://lanyuewan.cn/
syncDir              同步路径 指定同步路径 默认空 同步全站，可填入 每日更新/电影/ 或者 每日更新/  等具体的网站路径
tgToken              tg机器人token，通过t.me/BotFather机器人创建bot获取token
tgUserId             tg用户id，通过t.me/userinfobot机器人获取userId
tgUserName           tg机器人名称 可不填
logLevel             日志级别 DEBUG INFO ERROR OFF
JAVA_OPTS            设置JVM参数  默认-Xms32m -Xmx512m
retryDownEmptyFile   是否重新下载本地0KB大小的文件 默认不启用0，启用填1
```

### 一键命令部署

修改 `/volume1/docker-data/xiaoya/xiaoya` 为你的emby媒体库目录即可

```shell
docker run -d \
    --name=xiaoya-sync \
    --network="host" \
    -v /volume1/docker-data/xiaoya/xiaoya:/data \
    jacksaoding/xiaoya-sync:latest
```


### 完整参数部署

**docker-cli**

```shell
docker run -d \
    --name=xiaoya-sync \
    --network="host" \
    -e TZ=Asia/Shanghai \
    -e runAfterStartup=0 \
    -e excludeList="" \
    -e threadPoolNum="99" \
    -e syncUrl="" \
    -e syncDir="" \
    -v /volume1/docker-data/xiaoya/xiaoya:/data \
    -v /volume1/docker/xiaoya-sync/log:/log \
    jacksaoding/xiaoya-sync:latest
```

**docker compose**

```yaml
services:
  app:
    container_name: xiaoya-sync
    image: 'jacksaoding/xiaoya-sync:latest'
    network_mode: "host"
    environment:
      TZ: Asia/Shanghai
      runAfterStartup: 0
      excludeList: ""
      threadPoolNum: 99
      syncUrl: ""
      syncDir: ""
    volumes:
      - /volume1/docker-data/xiaoya/xiaoya:/data
      - /volume1/docker/xiaoya-sync/log:/log
```
