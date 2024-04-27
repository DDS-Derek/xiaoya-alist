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

cd /app || exit

while true; do
    INFO "开始下载同步！"
    INFO "python3 solid.py $*"
    python3 solid.py $@
    INFO "运行完成！"
    INFO "等待${CYCLE}秒后下次运行！"
    sleep "${CYCLE}"
done
