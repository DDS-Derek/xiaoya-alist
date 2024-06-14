![xiaoya-alist](https://socialify.git.ci/DDS-Derek/xiaoya-alist/image?description=1&font=KoHo&forks=1&issues=1&logo=https%3A%2F%2Fraw.githubusercontent.com%2FDDS-Derek%2Fxiaoya-alist%2Fmaster%2Fassets%2Flogo.jpg&name=1&owner=1&pattern=Signal&pulls=1&stargazers=1&theme=Auto)

![](https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/assets/image.png)

![](https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/assets/image-1.png)

![](https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/assets/image-2.png)

![](https://count.getloli.com/get/@DDS-Derek.xiaoya-alist.readme?theme=rule34)

> [!IMPORTANT]
> 脚本作者 DDSRem 维护精力有限，脚本更新速度将放缓！

- [main.sh](#mainsh)
  - [使用](#使用)
  - [功能列表](#功能列表)
- [相关地址](#相关地址)
- [通用兼容性测试报告](#通用兼容性测试报告)
- [免责声明](#免责声明)
- [Star History](#star-history)
- [小雅周边工具集合](#小雅周边工具集合)
- [感谢](#感谢)
- [捐赠](#捐赠)

## main.sh

> [!NOTE]
> 整合安装脚本，内置所有相关软件的安装。

### 使用

```shell
bash -c "$(curl --insecure -fsSL https://ddsrem.com/xiaoya_install.sh)"
```

**备用地址**

```shell
bash <(curl --insecure -fsSL https://ddsrem.com/xiaoya/all_in_one.sh)
```

```shell
bash <(curl --insecure -fsSL https://fastly.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/all_in_one.sh)
```

```shell
bash <(curl --insecure -fsSL https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/all_in_one.sh)
```

```shell
bash -c "$(curl --insecure -fsSL https://fastly.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/main.sh)"
```

```shell
bash -c "$(curl --insecure -fsSL https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/main.sh)"
```

### 功能列表

> [!NOTE]
> 数字代表先选x，再选x，再选x
> 
> PS: 2 2 8代表先选2，再选2，最后选8

**普通功能**

```shell
———————————————————————————————————————安装———————————————————————————————————————
安装 小雅Alist -> 1 1
安装 小雅Alist-TVBox -> 5 1
安装/更新 小雅助手（xiaoyahelper）-> 4 1
安装 Onelist -> 6 1
安装 Portainer -> 8 1 1
安装 Emby全家桶（一键） -> 2 1
安装 Jellyfin全家桶（一键） -> 3 1
安装 Resilio-Sync（单独） -> 2 5 1
安装 Auto_Symlink -> 8 2 1
安装 CasaOS -> 8 4 1
安装 小雅元数据定时爬虫 -> 2 9 1
——————————————————————————————Emby手动全家桶配置————————————————————————————————————
单独 下载并解压 全部元数据 -> 2 2 1
单独 解压 全部元数据 -> 2 2 2
单独 下载 all.mp4 -> 2 2 3
单独 解压 all.mp4 -> 2 2 4
解压 all.mp4 的指定元数据目录【非全部解压】-> 2 2 5
单独 下载 config.mp4 -> 2 2 6
单独 解压 config.mp4 -> 2 2 7
单独 下载 pikpak.mp4 -> 2 2 8
单独 解压 pikpak.mp4 -> 2 2 9
选择 下载器【aria2/wget】-> 2 2 10
单独 安装Emby（可选择版本，支持官方，amilys，lovechen）-> 2 3
立即 同步小雅Emby的config目录 -> 2 6
单独 创建/删除 同步定时更新任务 -> 2 7
图形化编辑 emby_config.txt -> 2 8
————————————————————————————Jellyfin手动全家桶配置——————————————————————————————————
单独 下载并解压 全部元数据 -> 3 2 1
单独 解压 全部元数据 -> 3 2 2
单独 下载 all_jf.mp4 -> 3 2 3
单独 解压 all_jf.mp4 -> 3 2 4
解压 all_jf.mp4 的指定元数据目录【非全部解压】-> 3 2 5
单独 下载 config_jf.mp4 -> 3 2 6
单独 解压 config_jf.mp4 -> 3 2 7
单独 下载 PikPak_jf.mp4 -> 3 2 8
单独 解压 PikPak_jf.mp4 -> 3 2 9
选择 下载器【aria2/wget】-> 3 2 10
单独 安装Jellyfin-> 3 3
———————————————————————————————————————更新———————————————————————————————————————
更新 小雅Alist-TVBox -> 5 2
更新 小雅Alist -> 1 2
更新 Resilio-Sync（单独） -> 2 5 2
更新 Onelist -> 6 2
更新 Portainer -> 8 1 2
更新 Auto_Symlink -> 8 2 2
更新 小雅元数据定时爬虫 -> 2 9 2
———————————————————————————————————————卸载———————————————————————————————————————
卸载 小雅Alist -> 1 3
卸载 Emby全家桶 -> 2 10
卸载 卸载Jellyfin全家桶 -> 3 4
卸载 Resilio-Sync（单独） -> 2 5 3
卸载 小雅助手（xiaoyahelper）-> 4 3
卸载 小雅Alist-TVBox -> 5 3
卸载 Onelist -> 6 3
卸载 Portainer -> 8 1 3
卸载 Auto_Symlink -> 8 2 3
卸载 CasaOS -> 8 4 2
卸载 小雅元数据定时爬虫 -> 2 9 3
————————————————————————————————Docker Compose—————————————————————————————————————
安装 小雅及全家桶 -> 7 1
卸载 小雅及全家桶 -> 7 2
——————————————————————————————————————系统工具——————————————————————————————————————
查看系统磁盘挂载 -> 8 3
———————————————————————————————————————其他———————————————————————————————————————
一次性运行 小雅助手（xiaoyahelper）-> 4 2
创建/删除 定时同步更新数据（小雅alist启动时拉取的数据）-> 1 4
```

**高级功能**

```shell
Docker启动容器名称设置 -> 9 1
是否开启容器运行额外参数添加 -> 9 2
重置脚本配置 -> 9 3
开启/关闭 磁盘容量检测 -> 9 4
开启/关闭 小雅连通性检测 -> 9 5
Docker镜像源选择 -> 9 6
```

## 相关地址

[https://github.com/DDS-Derek/xiaoya-alist](https://github.com/DDS-Derek/xiaoya-alist)

小雅官方 [Telegram](https://t.me/xiaoyaliu00) 交流群

## 通用兼容性测试报告

|             软件名称             | x86-64  \| amd64 | arm64 \| arm64v8 | armhf \| armv7 |
| :------------------------------: | :--------------: | :---------------: | :-------------: |
|          小雅Alist           |        ✅         |         ✅         |        ✅        |
|        小雅Emby全家桶        |        ✅         |         ✅         |        ❌        |
|      小雅Jellyfin全家桶      |        ✅         |         ✅         |        ❌        |
|   小雅助手（xiaoyahelper）   |        ✅         |         ✅         |        ✅        |
|       小雅Alist-TVBox        |        ✅         |         ✅         |        ❌        |
|           Onelist            |        ✅         |         ✅         |        ✅        |
| 小雅元数据爬虫（xiaoya-emd） |        ✅         |         ✅         |        ✅        |
| 小雅Cron容器（xiaoya-cron）  |        ✅         |         ✅         |        ✅        |

|    系统名称     | main.sh | emby_config_editor.sh |
| :-------------: | :-----: | :-------------------: |
|   CentOS 7.9    |    ✅    |           ✅           |
|   CentOS 8.4    |    ✅    |           ✅           |
| CentOS 8 Stream |    ✅    |           ✅           |
| CentOS 9 Stream |    ✅    |           ✅           |
|   Debian 10.3   |    ✅    |           ✅           |
|   Debian 11.3   |    ✅    |           ✅           |
|   Debian 12.0   |    ✅    |           ✅           |
|  Ubuntu 18.04   |    ✅    |           ✅           |
|  Ubuntu 20.04   |    ✅    |           ✅           |
|  Ubuntu 22.04   |    ✅    |           ✅           |
|    Fedora 31    |    ✅    |           ✅           |
|    Fedora 32    |    ✅    |           ✅           |
|   AlmaLinux 9   |    ✅    |           ✅           |
| RockyLinux 8.6  |    ✅    |           ✅           |
|   Arch Linux    |    ✅    |           ✅           |
|  openSUSE 15.4  |    ✅    |           ✅           |
|     FreeBSD     |    ✅    |           ✅           |
|     EulerOS     |    ✅    |           ✅           |
|  Amazon Linux   |    ✅    |           ✅           |
|     Alpine      |    ✅    |           ✅           |
|     UnRaid      |    ✅    |           ✅           |
| OpenMediaVault  |    ✅    |           ✅           |
|      QNAP       |    ✅    |           ✅           |
|     OpenWRT     |    ✅    |           ✅           |
|    Synology     |    ✅    |           ✅           |
|  TrueNAS CORE   |    ✅    |           ✅           |
|  TrueNAS SCALE  |    ✅    |           ✅           |
|     UGREEN      |    ✅    |           ✅           |
|   LibreELEC     |    ❌    |           ❌           |

## 免责声明

- 请勿将 小雅系列软件 用于商业用途。
- 请勿将 小雅系列软件 用于任何违反法律法规的行为。
- 本仓库所有脚本均基于官方脚本制作，使用请自行承担数据损失但不限于此的风险。

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=DDS-Derek/xiaoya-alist&type=Date)](https://star-history.com/#DDS-Derek/xiaoya-alist)

## 小雅周边工具集合

- [CatVod](https://pcoof.com/git/https://github.com/catvod/CatVodOpen): 猫影视
- [Xiaoya-convert](https://github.com/ypq123456789/xiaoya-convert): 自动批量将阿里云盘分享链接转换为小雅`alishare_list.txt`中的格式
- [Xiaoyahelper](https://github.com/DDS-Derek/xiaoya-alist/tree/master/xiaoyahelper): 一劳永逸的小雅转存清理工具
- [Alist-TVBox](https://hub.docker.com/r/haroldli/alist-tvbox): 一个基于`AList`和`xiaoya`的`TVBox`管理工具
- [`strm`文件生成](https://xiaoyaliu.notion.site/strm-2c8d136ceb37445fb6c0222eafb966ce): 小雅官方提供的一键生成`strm`文件脚本
- [monlor/docker-xiaoya](https://github.com/monlor/docker-xiaoya): Docker Compose 方式一键部署小雅全家桶
- [AI老G 脚本推荐](https://b23.tv/3Zo0IvD)
  - 小雅全家桶安装脚本（支持AI老G版小雅Alist安装，Jellyfin安装，快速Emby安装）:
    ```shell
    bash <(curl -sSLf https://xy.ggbond.org/xy/xy_install.sh)
    ```
  - [玩客云刷casaos小雅emby全家桶](https://b23.tv/KTIHxyT):
    ```shell
    bash <(curl -sSLf https://xy.ggbond.org/xy/wky_xy_emby_ailg.sh)
    ```

## 感谢

- [xiaoyaLiu](http://alist.xiaoya.pro/)
- [heiheigui](https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh)
- [alist-tvbox](https://github.com/power721/alist-tvbox)
- [Auto_Symlink](https://github.com/shenxianmq/Auto_Symlink)
- [Portainer](https://github.com/portainer/portainer)
- [AI老G](https://space.bilibili.com/252166818)
- [monlor](https://link.monlor.com)

<a href="https://github.com/DDS-Derek/xiaoya-alist/graphs/contributors"><img src="https://contrib.rocks/image?repo=DDS-Derek/xiaoya-alist"></a>

## 捐赠

- [捐赠项目作者DDSRem](https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/assets/appreciate-ddsrem.png)
- [捐赠小雅](https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/assets/appreciate-xiaoya.png)
- [捐赠AI老G](https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/assets/appreciate-ailaog.png)
