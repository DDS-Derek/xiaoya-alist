#!/bin/bash
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
# Copyright (c) 2023 DDSRem <https://blog.ddsrem.com>
#
# This is free software, licensed under the GNU General Public License v3.0.
#
# ——————————————————————————————————————————————————————————————————————————————————
#
# https://github.com/duckeaty/update_xiaoya_emby_config_library

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

bash /app/module.sh update_config
bash /app/module.sh update_policy

crontab -r
echo -e "${CRON} bash /app/module.sh update_config && bash /app/module.sh update_policy" >> /tmp/crontab.list
INFO "设置定时任务中..."
crontab /tmp/crontab.list
INFO "定时任务预览:"
crontab -l
rm -f /tmp/crontab.list

exec crond -f