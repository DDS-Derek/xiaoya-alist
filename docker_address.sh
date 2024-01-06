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

cd /media/xiaoya

docker_addr=$(head -n1 /etc/xiaoya/docker_address.txt)

for i in `seq -w 3 -1 0`
do
    echo -en "${INFO} 即将开始替换地址：${docker_addr}${Blue} $i ${Font}\r"  
sleep 1;
done

INFO "执行替换DOCKER_ADDRESS............"
start_time2=`date +%s`
fdfind --extension strm --exec sed \-i "s#DOCKER_ADDRESS#$docker_addr#g; s# #%20#g; s#|#%7C#g" {} \;
chmod -R 777 *	
end_time2=`date +%s`
total_time2=$((end_time2 - start_time2))
total_time2=$((total_time2 / 60))
INFO "替换执行时间：$total_time2 分钟"