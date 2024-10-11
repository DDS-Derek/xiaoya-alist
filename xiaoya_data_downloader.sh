#!/bin/bash
# shellcheck shell=bash
PATH=${PATH}:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/opt/homebrew/bin
export PATH
#
# ——————————————————————————————————————————————————————————————————————————————————
# __   ___                                    _ _     _
# \ \ / (_)                             /\   | (_)   | |
#  \ V / _  __ _  ___  _   _  __ _     /  \  | |_ ___| |_
#   > < | |/ _` |/ _ \| | | |/ _` |   / /\ \ | | / __| __|
#  / . \| | (_| | (_) | |_| | (_| |  / ____ \| | \__ \ |_
# /_/ \_\_|\__,_|\___/ \__, |\__,_| /_/    \_\_|_|___/\__|
#                       __/ |
#                      |___/
#
# Copyright (c) 2024 DDSRem <https://blog.ddsrem.com>
#
# This is free software, licensed under the GNU General Public License v3.0.
#
# ——————————————————————————————————————————————————————————————————————————————————

Green="\033[32m"
Red="\033[31m"
Font="\033[0m"
INFO="[${Green}INFO${Font}]"
ERROR="[${Red}ERROR${Font}]"
Time=$(date +"%Y-%m-%d %T")
function INFO() {
    echo -e "${Time} ${INFO} ${1}"
}
function ERROR() {
    echo -e "${Time} ${ERROR} ${1}"
}

# 弃用此脚本
if [ -n "$(date)" ]; then
    ERROR "此脚本已弃用！"
    exit 0
fi

files=(tvbox.zip update.zip index.zip)
base_urls=(
    "https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://cdn.wygg.shop/https://raw.githubusercontent.com/xiaoyaliu00/data/main"
    "https://fastly.jsdelivr.net/gh/xiaoyaliu00/data@latest/"
    "https://521github.com/extdomains/github.com/xiaoyaliu00/data/raw/main/"
    "https://cors.zme.ink/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://git.jasonml.xyz/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://cdn.wygg.shop/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://gh.ddlc.top/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://git.886.be/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://gh.idayer.com/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://slink.ltd/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://raw.yzuu.cf/xiaoyaliu00/data/main/"
    "https://raw.nuaa.cf/xiaoyaliu00/data/main/"
    "https://raw.kkgithub.com/xiaoyaliu00/data/main/"
    "https://ghp.ci/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://gitdl.cn/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://gh.con.sh/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://ghproxy.net/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://github.moeyy.xyz/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://gh-proxy.com/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://ghproxy.cc/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://gh.llkk.cc/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://gh-proxy.llyke.com/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
)

if [ -z "${1}" ]; then
    ERROR "请配置小雅Alist配置文件目录后重试！"
    exit 1
else
    data_dir="${1}/data"
fi

if [ -f "${data_dir}/version.txt" ]; then
    OLD_VERSION=$(cat "${data_dir}"/version.txt)
    INFO "本地数据版本：${OLD_VERSION}"
else
    OLD_VERSION=none
fi

for base_url in "${base_urls[@]}"; do
    if curl --insecure -fsSL -o "${data_dir}/version.txt" "${base_url}version.txt"; then
        available_url=${base_url}
        NEW_VERSION=$(cat "${data_dir}"/version.txt)
        INFO "远端数据版本：${NEW_VERSION}"
        break
    fi
done

if [ "${OLD_VERSION}" != "${NEW_VERSION}" ]; then
    for file in "${files[@]}"; do
        if curl --insecure -fsSL -o "${data_dir}/${file}" "${available_url}${file}"; then
            INFO "$available_url$file 更新成功！"
        else
            ERROR "$available_url$file 更新失败！"
        fi
    done
else
    INFO "无需更新，跳过下载！"
fi
