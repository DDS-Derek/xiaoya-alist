# 一劳永逸的小雅转存清理工具

## 说明

本仓库镜像备份了xiaoyakeeper，意旨提供稳定高效的服务！

服务状态查看：https://uptime.ddsrem.com/status/xiaoyahelper

## 使用

**模式0**：每天自动清理一次。如果系统重启需要手动重新运行或把命令加入系统启动。
```shell
bash -c "$(curl -sLk https://xiaoyahelper.ddsrem.com/aliyun_clear.sh | tail -n +2)" -s 0 -tg
```

**模式1**：一次性清理，一般用于测试效果。
```shell
bash -c "$(curl -sLk https://xiaoyahelper.ddsrem.com/aliyun_clear.sh | tail -n +2)" -s 1 -tg
```

**模式2**：已废弃，不再支持

**模式3**：创建一个名为 xiaoyakeeper 的docker定时运行小雅转存清理并升级小雅镜像
```shell
bash -c "$(curl -sLk https://xiaoyahelper.ddsrem.com/aliyun_clear.sh | tail -n +2)" -s 3 -tg
```

**模式4**：同模式3

**模式5**：与模式3的区别是实时清理，只要产生了播放缓存一分钟内立即清理。签到和定时升级同模式3
```shell
bash -c "$(curl -sLk https://xiaoyahelper.ddsrem.com/aliyun_clear.sh | tail -n +2)" -s 5 -tg
```

**其它模式**：也可以把脚本下载下来自己魔改。

### 签到功能说明：

1. 执行时机和清理缓存完全相同
2. 可以手动创建`/etc/xiaoya/mycheckintoken.txt`，定义多个网盘签到的32位`refresh token`，每行一个，不添加文件就是默认小雅转存的网盘签到。
3. 自动刷新`/etc/xiaoya/mycheckintoken.txt`、`/etc/xiaoya/mytoken.txt`（可能可以延长`refresh token`时效，待观察）

### 关于模式0/3/4/5定时运行的说明：

1. 默认从运行脚本的下一分钟开始，每天运行一次
2. 运行的时间也可以通过手动创建`/etc/xiaoya/myruntime.txt`修改，比如06:00,18:00就是每天早晚6点各运行一次

### 关于自动升级:

1. 定时升级的命令保存在`/etc/xiaoya/mycmd.txt`中，删除该文件变成定时重启小雅
2. 完成清理和签到后自动执行`/etc/xiaoya/mycmd.txt`中的命令，该文件中的内容默认升级小雅镜像，可以修改该文件改编脚本的行为，不建议修改。

### 关于tg推送：

所有模式加上`-tg`功能均可绑定消息推送的TG账号，只有第1次运行需要加`-tg`参数

**问题反馈**: 联系[Telegram群](https://t.me/xiaoyaliu00)里的heiheigui

## 免责声明

- 请勿将 xiaoyahelper 用于商业用途。
- 请勿将 xiaoyahelper 用于任何违反法律法规的行为。
- 本仓库 xiaoyahelper 基于官方作者仓库备份，使用请自行承担数据损失但不限于此的风险。
- 此项目 xiaoyahelper 开启`Telegram通知`时会收集用户`ChatID`，用于消息通知和数据分析，使用即代表默认同意。
- 此项目 xiaoyahelper 所有`API`均使用阿里云官方渠道。 