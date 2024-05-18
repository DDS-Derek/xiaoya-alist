#!/usr/bin/with-contenv sh
# shellcheck shell=sh
# shellcheck disable=SC2114

if [ -f /media.img ]; then
    if [ ! -d /volume_img ]; then
        mkdir /volume_img
    fi
    if grep -qs '/volume_img' /proc/mounts; then
        umount /volume_img
        wait ${!}
    fi
    mount -o loop,offset=10000000 /media.img /volume_img
    echo "img 镜像挂载成功！"
    if [ -d /media ]; then
        rm -rf /media
    fi
    ln -sf /volume_img/xiaoya /media
    echo "媒体库软连接创建成功！"
else
    echo "img 镜像未挂载，跳过自动挂载！"
fi
