![xiaoya-alist](https://socialify.git.ci/DDS-Derek/xiaoya-alist/image?description=1&font=KoHo&forks=1&issues=1&logo=https%3A%2F%2Fraw.githubusercontent.com%2FDDS-Derek%2Fxiaoya-alist%2Fmaster%2Fassets%2Flogo.jpg&name=1&owner=1&pattern=Signal&pulls=1&stargazers=1&theme=Auto)

![](https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/assets/image.png)

![](https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/assets/image-1.png)

![](https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/assets/image-2.png)

![](https://count.getloli.com/get/@DDS-Derek.xiaoya-alist.readme?theme=rule34)

- [main.sh](#mainsh)
  - [使用](#使用)
  - [功能列表](#功能列表)
- [emby\_config\_editor.sh](#emby_config_editorsh)
  - [介绍](#介绍)
  - [使用](#使用-1)
- [相关地址](#相关地址)
- [通用兼容性测试报告](#通用兼容性测试报告)
- [免责声明](#免责声明)
- [Star History](#star-history)
- [感谢](#感谢)
- [捐赠](#捐赠)

## main.sh

整合安装脚本，内置所有相关软件的安装。

### 使用

```shell
bash -c "$(curl -sLk https://ddsrem.com/xiaoya_install.sh)"
```

**备用地址**

```shell
bash -c "$(curl -sLk https://cdn.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/main.sh)"
```

```shell
bash -c "$(curl -sLk https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/main.sh)"
```

### 功能列表

> 数字代表先选x，再选x，再选x
> 
> PS: 2 2 8代表先选2，再选2，最后选8

**普通功能**

```shell
———————————————————————————————————————安装———————————————————————————————————————
安装 小雅Alist -> 1 1
安装 小雅Alist-TVBox -> 4 1
安装/更新 小雅助手（xiaoyahelper）-> 3 1
安装 Onelist -> 5 1
安装 Portainer -> 6 1 1
安装 Emby全家桶（一键） -> 2 1
安装 Resilio-Sync（单独） -> 2 5 1
安装 Auto_Symlink -> 6 2 1
————————————————————————————————手动全家桶配置————————————————————————————————————
单独 下载并解压 全部元数据 -> 2 2 1
单独 解压 全部元数据 -> 2 2 2
单独 下载 all.mp4 -> 2 2 3
单独 解压 all.mp4 -> 2 2 4
单独 下载 config.mp4 -> 2 2 5
单独 解压 config.mp4 -> 2 2 6
单独 下载 pikpak.mp4 -> 2 2 7
单独 解压 pikpak.mp4 -> 2 2 8
选择 下载器【aria2/wget】-> 2 2 9
单独 安装Emby（可选择版本，支持官方，amilys，lovechen）-> 2 3
立即 同步小雅Emby的config目录 -> 2 6
单独 创建/删除 同步定时更新任务 -> 2 7
图形化编辑 emby_config.txt -> 2 8
———————————————————————————————————————更新———————————————————————————————————————
更新 小雅Alist-TVBox -> 4 2
更新 小雅Alist -> 1 2
更新 Resilio-Sync（单独） -> 2 5 2
更新 Onelist -> 5 2
更新 Portainer -> 6 1 2
更新 Auto_Symlink -> 6 2 2
———————————————————————————————————————卸载———————————————————————————————————————
卸载 小雅Alist -> 1 3
卸载 Emby全家桶 -> 2 9
卸载 Resilio-Sync（单独） -> 2 5 3
卸载 小雅助手（xiaoyahelper）-> 3 3
卸载 小雅Alist-TVBox -> 4 3
卸载 Onelist -> 5 3
卸载 Portainer -> 6 1 3
卸载 Auto_Symlink -> 6 2 3
——————————————————————————————————————系统工具——————————————————————————————————————
查看系统磁盘挂载 -> 6 3
———————————————————————————————————————其他———————————————————————————————————————
一次性运行 小雅助手（xiaoyahelper）-> 3 2
```

**高级功能**

```shell
Docker启动容器名称设置 -> 7 1
是否开启容器运行额外参数添加 -> 7 2
重置脚本配置 -> 7 3
开启/关闭 磁盘容量检测 -> 7 4
开启/关闭 小雅连通性检测 -> 7 5
```

## emby_config_editor.sh

### 介绍

emby_config.txt 的命令行的图形化编辑器，内置纠错。

### 使用

```shell
bash -c "$(curl -sLk https://ddsrem.com/xiaoya/emby_config_editor.sh)" -s xiaoya配置目录
```

**备用地址**

```shell
bash -c "$(curl -sLk https://cdn.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/emby_config_editor.sh)" -s xiaoya配置目录
```

```shell
bash -c "$(curl -sLk https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/emby_config_editor.sh)" -s xiaoya配置目录
```

## 相关地址

[https://github.com/DDS-Derek/xiaoya-alist](https://github.com/DDS-Derek/xiaoya-alist)

小雅官方 [Telegram](https://t.me/xiaoyaliu00) 交流群

## 通用兼容性测试报告

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
|   LibreELEC     |    ✅    |           ✅           |

## 免责声明

- 请勿将 小雅系列软件 用于商业用途。
- 请勿将 小雅系列软件 用于任何违反法律法规的行为。
- 本仓库所有脚本均基于官方脚本制作，使用请自行承担数据损失但不限于此的风险。

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=DDS-Derek/xiaoya-alist&type=Date)](https://star-history.com/#DDS-Derek/xiaoya-alist)

## 感谢

- [xiaoyaLiu](http://alist.xiaoya.pro/)
- [heiheigui](https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh)
- [alist-tvbox](https://github.com/power721/alist-tvbox)
- [Auto_Symlink](https://github.com/shenxianmq/Auto_Symlink)
- [Portainer](https://github.com/portainer/portainer)
- [CatVod](https://pcoof.com/git/https://github.com/catvod/CatVodOpen)
- [AI老G](https://space.bilibili.com/252166818)

<a href="https://github.com/DDS-Derek/xiaoya-alist/graphs/contributors"><img src="https://contrib.rocks/image?repo=DDS-Derek/xiaoya-alist"></a>

## 捐赠

> 注：以下捐赠不包含此项目作者（DDSRem）的捐赠！

- [捐赠小雅](https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/assets/appreciate-xiaoya.png)
- [捐赠AI老G](https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/assets/appreciate-ailaog.png)