#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC2068
# shellcheck disable=SC2114

Green="\033[32m"
Red="\033[31m"
Yellow='\033[33m'
Font="\033[0m"
INFO="[${Green}INFO${Font}]"
ERROR="[${Red}ERROR${Font}]"
WARN="[${Yellow}WARN${Font}]"
function INFO() {
    echo -e "${INFO} ${1}"
}
function ERROR() {
    echo -e "${ERROR} ${1}"
}
function WARN() {
    echo -e "${WARN} ${1}"
}

function update_app() {

    cd /app || exit
    echo "Update xiaoya_db script..."
    git remote set-url origin "${REPO_URL}"
    git fetch --all
    git reset --hard "origin/${BRANCH}"
    pip install --upgrade pip
    pip install -r /app/requirements.txt

}

function mount_img() {

    if [ ! -d /volume_img ]; then
        mkdir /volume_img
    fi
    while true; do
        if mount /dev/loop7 /volume_img; then
            INFO "img 镜像挂载成功！"
            break
        fi
        sleep 30
    done
    if [ -d /media ]; then
        if [ -d /media/电影/2023 ]; then
            if ! rm -rf /media; then
                ERROR '删除 /media 失败！使用老G速装版emby请勿将任何目录挂载到容器的 /media 目录！程序退出！'
                exit 1
            fi
        else
            ERROR '/media 文件夹不为空！使用老G速装版emby请勿将任何目录挂载到容器的 /media 目录！程序退出！'
            exit 1
        fi
    fi
    ln -sf /volume_img/xiaoya /media
    INFO "/media 创建软链接成功！"

}

if [ "${RESTART_AUTO_UPDATE}" == "true" ]; then
    update_app
fi

if [ "${IMG_VOLUME}" == "true" ]; then
    mount_img
fi

cd /app || exit

TWELVE_HOURS=$((12 * 60 * 60))

if [ "$CYCLE" -lt "$TWELVE_HOURS" ]; then
    WARN "您设置的循环时间小于12h，对于服务器压力过大，同步下载将不会运行！"
    tail -f /dev/null
else
    while true; do
        INFO "开始下载同步！"
        INFO "python3 solid.py $*"
        python3 solid.py $@
        INFO "运行完成！"
        INFO "等待${CYCLE}秒后下次运行！"
        sleep "${CYCLE}"
    done
fi
