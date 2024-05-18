#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC2068

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
    if grep -qs '/volume_img' /proc/mounts; then
        umount /volume_img
        wait ${!}
    fi
    mount -o loop /media.img /volume_img
    INFO "img 镜像挂载成功！"

}

if [ "${RESTART_AUTO_UPDATE}" == "true" ]; then
    update_app
fi

if [ -f /media.img ]; then
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
