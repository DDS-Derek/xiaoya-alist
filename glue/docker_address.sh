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

trap 'onCtrlC' INT
function onCtrlC () {
    #捕获CTRL+C，当脚本被ctrl+c的形式终止时同时终止程序的后台进程
    kill -9 ${do_sth_pid} ${progress_pid}
    exit 1
}

do_sth() {
    #运行的主程序
    fdfind --extension strm --exec sed \-i "s#http://xiaoya.host:5678#$docker_addr#g; s# #%20#g; s#|#%7C#g" {} \;
    chmod -R 777 *
}

progress() {
    #进度条程序
    local main_pid=$1
    local length=50
    local ratio=1
    while [ "$(ps -p ${main_pid} | wc -l)" -ne "1" ] ; do
            mark='>'
            progress_bar=
            for i in $(seq 1 "${length}"); do
                    if [ "$i" -gt "${ratio}" ] ; then
                            mark='-'
                    fi
                    progress_bar="${progress_bar}${mark}"
            done
            printf "替换DOCKER_ADDRESS: ${progress_bar}\r"
            ratio=$((ratio+1))
            if [ "${ratio}" -gt "${length}" ] ; then
                    ratio=1
            fi
            sleep 0.5
    done
}

cd /media/xiaoya

docker_addr=$(head -n1 /etc/xiaoya/docker_address.txt)

for i in `seq -w 3 -1 0`
do
    echo -en "${INFO} 即将开始替换地址：${docker_addr}${Blue} $i ${Font}\r"  
sleep 1;
done

INFO "执行替换DOCKER_ADDRESS                                                          "
start_time2=`date +%s`

do_sth &
do_sth_pid=$(jobs -p | tail -1)

progress "${do_sth_pid}" &
progress_pid=$(jobs -p | tail -1)

wait "${do_sth_pid}"

end_time2=`date +%s`
total_time2=$((end_time2 - start_time2))
total_time2=$((total_time2 / 60))
printf "${INFO} 替换执行时间：$total_time2 分钟                                      \n"