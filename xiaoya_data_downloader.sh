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

function pull_run_glue() {

    if docker inspect xiaoyaliu/glue:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/glue:latest | cut -f2 -d:)
        remote_sha=$(curl -s "https://hub.docker.com/v2/repositories/xiaoyaliu/glue/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ ! "$local_sha" == "$remote_sha" ]; then
            docker rmi xiaoyaliu/glue:latest
            if docker pull xiaoyaliu/glue:latest; then
                INFO "镜像拉取成功！"
            else
                ERROR "镜像拉取失败！"
                exit 1
            fi
        fi
    else
        if docker pull xiaoyaliu/glue:latest; then
            INFO "镜像拉取成功！"
        else
            ERROR "镜像拉取失败！"
            exit 1
        fi
    fi

    docker run -i \
        --security-opt seccomp=unconfined \
        --rm \
        --net=host \
        -e LANG=C.UTF-8 \
        -v "${data_dir}:${data_dir}" \
        xiaoyaliu/glue:latest \
        "${@}"

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

for base_url in "${base_urls[@]}"; do
    if pull_run_glue curl --insecure -fsSL "${base_url}version.txt"; then
        available_url=${base_url}
        break
    fi
done

for file in "${files[@]}"; do
    pull_run_glue wget --no-check-certificate -nc -O "${data_dir}/${file}" "${available_url}${file}"
    INFO "$available_url$file 更新成功"
done
