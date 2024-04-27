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
# This is free software, licensed under the Mit License.
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

files=(tvbox.zip update.zip index.zip version.txt)
base_urls=(
    "https://gitlab.com/xiaoyaliu/data/-/raw/main/"
    "https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
    "https://cdn.wygg.shop/https://raw.githubusercontent.com/xiaoyaliu00/data/main"
    "https://fastly.jsdelivr.net/gh/xiaoyaliu00/data@latest/"
    "https://521github.com/extdomains/github.com/xiaoyaliu00/data/raw/main/"
    "https://cors.zme.ink/https://raw.githubusercontent.com/xiaoyaliu00/data/main/"
)

if [ -z "${1}" ]; then
    ERROR "请配置小雅Alist配置文件目录后重试！"
    exit 1
else
    data_dir="${1}/data"
fi

for file in "${files[@]}"; do
    success=false
    for base_url in "${base_urls[@]}"; do
        if curl --insecure -fsSL -o "${data_dir}/${file}" "${base_url}${file}"; then
            success=true
            INFO "$base_url$file 下载成功"
            break
        fi
    done
    if [ "$success" = false ]; then
        ERROR "$base_url$file 下载失败"
    fi
done
