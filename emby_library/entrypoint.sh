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

bash /app/update.sh update_config
bash /app/update.sh update_policy

crontab -r
echo -e "${CRON} bash /app/update.sh update_config && bash /app/update.sh update_policy" >> /tmp/crontab.list
INFO "设置定时任务中..."
crontab /tmp/crontab.list
INFO "定时任务预览:"
crontab -l
rm -f /tmp/crontab.list

exec crond -f