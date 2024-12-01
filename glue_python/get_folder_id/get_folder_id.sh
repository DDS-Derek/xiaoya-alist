#!/bin/bash

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

if ! folderid=$(python /get_folder_id/get_folder_id.py); then
    ERROR "自动获取 阿里云盘转存目录 folder id 失败，请手动获取！"
    exit 1
fi
if [ -n "${folderid}" ]; then
    INFO "阿里云盘转存目录 folder id：${folderid}"
else
    ERROR "自动获取 阿里云盘转存目录 folder id 失败，请手动获取！"
    exit 1
fi

echo "${folderid}" > /data/temp_transfer_folder_id.txt
echo "r" > /data/folder_type.txt

refresh_token=$(sed 's/:\s*/:/g' /root/.aligo/aligo.json | sed -n 's/.*"refresh_token":"\([^"]*\).*/\1/p')

INFO "自动刷新 refresh_token：${refresh_token}"

echo "${refresh_token}" > /data/mytoken.txt
