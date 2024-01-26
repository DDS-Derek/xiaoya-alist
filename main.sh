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
# This is free software, licensed under the Mit License.
#
# ——————————————————————————————————————————————————————————————————————————————————
#
# bash -c "$(curl http://docker.xiaoya.pro/update_new.sh | awk '{gsub("/etc/xiaoya", "/ssd/data/docker/xiaoya/xiaoya"); print}')"
#
# bash -c "$(curl http://docker.xiaoya.pro/emby_plus.sh \
# | awk '{gsub("emby/embyserver:4.8.0.56", "amilys/embyserver:4.8.0.56"); print}' \
# | awk '{gsub("emby/embyserver_arm64v8:4.8.0.56", "amilys/embyserver:4.8.0.56"); print}' \
# | awk '{gsub("--name emby", "--name xiaoya-emby"); print}')"
#
# bash -c "$(curl -s https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh| tail -n +2)" -s 3 -tg
#
# docker run -d -p 4567:4567 -p 5344:80 -e ALIST_PORT=5344 --restart=always -v /etc/xiaoya:/data --name=xiaoya-tvbox haroldli/xiaoya-tvbox
# bash -c "$(curl -fsSL https://d.har01d.cn/update_xiaoya.sh)"
#
# bash -c "$(curl http://docker.xiaoya.pro/update_new.sh)"
#
# find ./ -name "*.strm" -exec sed \-i "s#http://127.0.0.1:5678#自己的地址#g; s# #%20#g; s#|#%7C#g" {} \;
#
# bash -c "$(curl http://docker.xiaoya.pro/emby.sh)" -s /媒体库目录
#
# bash -c "$(curl http://docker.xiaoya.pro/resilio.sh)" -s /媒体库目录
#
# 0 6 * * * bash -c "$(curl http://docker.xiaoya.pro/sync_emby_config.sh)" -s /媒体库目录
#
# ——————————————————————————————————————————————————————————————————————————————————
#
# The functions that the script can call are 'INFO' 'WARN' 'ERROR'
#                 INFO function use(log output): INFO "xxxx"
#                 WARN function use(log output): WARN "xxxx"
#                 ERROR function use(log output): ERROR "xxxx"
#
# ——————————————————————————————————————————————————————————————————————————————————
#
DATE_VERSION="v1.0.0-2024_01_26_18_21"
#
# ——————————————————————————————————————————————————————————————————————————————————

Blue="\033[34m"
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

DDSREM_CONFIG_DIR=/etc/DDSRem

function root_need(){
    if [[ $EUID -ne 0 ]]; then
        ERRO '此脚本必须以 root 身份运行！'
        exit 1
    fi
}

function TODO(){
    WARN "此功能未完成，请耐心等待开发者开发"
}

function get_config_dir(){

    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
        INFO "已读取小雅Alist配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo ${CONFIG_DIR} > ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 /etc/xiaoya ）"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/xiaoya"
        touch ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt
        echo ${CONFIG_DIR} > ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt
    fi

}

function get_media_dir(){

    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt ]; then
        OLD_MEDIA_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt)
        INFO "已读取媒体库目录：${OLD_MEDIA_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -ep "MEDIA_DIR:" MEDIA_DIR
        [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR=${OLD_MEDIA_DIR}
        echo ${MEDIA_DIR} > ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt
    else
        INFO "请输入媒体库目录（默认 /opt/media ）"
        read -ep "MEDIA_DIR:" MEDIA_DIR
        [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR="/etc/xiaoya"
        touch ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt
        echo ${MEDIA_DIR} > ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt
    fi

}

function install_xiaoya_alist(){

    INFO "小白全部回车即可完成安装！"

    get_config_dir

    if [ ! -d ${CONFIG_DIR} ]; then
        mkdir -p ${CONFIG_DIR}
    else
        if [ -d ${CONFIG_DIR}/mytoken.txt ]; then
            rm -rf ${CONFIG_DIR}/mytoken.txt
        fi
    fi

    touch ${CONFIG_DIR}/mytoken.txt
    touch ${CONFIG_DIR}/myopentoken.txt
    touch ${CONFIG_DIR}/temp_transfer_folder_id.txt

    mytokenfilesize=$(cat ${CONFIG_DIR}/mytoken.txt)
    mytokenstringsize=${#mytokenfilesize}
    if [ $mytokenstringsize -le 31 ]; then
        INFO "输入你的阿里云盘 Token（32位长）"
        read -ep "TOKEN:" token
        token_len=${#token}
        if [ $token_len -ne 32 ]; then
            ERROR "长度不对,阿里云盘 Token是32位长"
            ERROR "安装停止，请参考指南配置文件: https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f"
            exit 1
        else
            echo $token > ${CONFIG_DIR}/mytoken.txt
        fi
    fi

    myopentokenfilesize=$(cat ${CONFIG_DIR}/myopentoken.txt)
    myopentokenstringsize=${#myopentokenfilesize}
    if [ $myopentokenstringsize -le 279 ]; then
        INFO "输入你的阿里云盘 Open Token（280位长或者335位长）"
        read -ep "OPENTOKEN:" opentoken
        opentoken_len=${#opentoken}
        if [[ $opentoken_len -ne 280 ]] && [[ $opentoken_len -ne 335 ]]; then
            ERROR "长度不对,阿里云盘 Open Token是280位长或者335位"
            ERROR "安装停止，请参考指南配置文件: https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f"
            exit 1
        else
            echo $opentoken > ${CONFIG_DIR}/myopentoken.txt
        fi
    fi

    folderidfilesize=$(cat ${CONFIG_DIR}/temp_transfer_folder_id.txt)
    folderidstringsize=${#folderidfilesize}
    if [ $folderidstringsize -le 39 ]; then
        INFO "输入你的阿里云盘转存目录folder id"
        read -p "FOLDERID:" folderid
        folder_id_len=${#folderid}
        if [ $folder_id_len -ne 40 ]; then
            ERROR "长度不对,阿里云盘 folder id是40位长"
            ERROR "安装停止，请参考指南配置文件: https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f"
            exit 1
        else
            echo $folderid > ${CONFIG_DIR}/temp_transfer_folder_id.txt
        fi
    fi

    localip=$(ip address | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:" | head -n1 | cut -f1 -d"/")
    INFO "本地IP：${localip}"

    INFO "是否使用host网络模式 [Y/n]（默认 n 不使用）"
    read -ep "NET_MODE:" NET_MODE
    [[ -z "${NET_MODE}" ]] && NET_MODE="n"
    if [[ ${NET_MODE} == [Yy] ]]; then
        if [ ! -s ${CONFIG_DIR}/docker_address.txt ]; then
            echo "http://$localip:5678" > ${CONFIG_DIR}/docker_address.txt
        fi
        docker pull xiaoyaliu/alist:hostmode
        if [[ -f ${CONFIG_DIR}/proxy.txt ]] && [[ -s ${CONFIG_DIR}/proxy.txt ]]; then
            proxy_url=$(head -n1 ${CONFIG_DIR}/proxy.txt)
            docker run -itd \
                --env HTTP_PROXY="$proxy_url" \
                --env HTTPS_PROXY="$proxy_url" \
                --env no_proxy="*.aliyundrive.com" \
                --network=host \
                -v ${CONFIG_DIR}:/data \
                --restart=always \
                --name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt) \
                xiaoyaliu/alist:hostmode
        else
            docker run -itd \
                --network=host \
                -v ${CONFIG_DIR}:/data \
                --restart=always \
                --name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt) \
                xiaoyaliu/alist:hostmode
        fi
    fi
    if [[ ${NET_MODE} == [Nn] ]]; then
        if [ ! -s ${CONFIG_DIR}/docker_address.txt ]; then
                echo "http://$localip:5678" > ${CONFIG_DIR}/docker_address.txt
        fi
        docker pull xiaoyaliu/alist:latest
        if [[ -f ${CONFIG_DIR}/proxy.txt ]] && [[ -s ${CONFIG_DIR}/proxy.txt ]]; then
            proxy_url=$(head -n1 ${CONFIG_DIR}/proxy.txt)
            docker run -itd \
                -p 5678:80 \
                -p 2345:2345 \
                -p 2346:2346 \
                --env HTTP_PROXY="$proxy_url" \
                --env HTTPS_PROXY="$proxy_url" \
                --env no_proxy="*.aliyundrive.com" \
                -v ${CONFIG_DIR}:/data \
                --restart=always \
                --name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt) \
                xiaoyaliu/alist:latest
        else
            docker run -itd \
                -p 5678:80 \
                -p 2345:2345 \
                -p 2346:2346 \
                -v ${CONFIG_DIR}:/data \
                --restart=always \
                --name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt) \
                xiaoyaliu/alist:latest
        fi
    fi
    INFO "安装完成！"

}

function update_xiaoya_alist(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始更新小雅Alist${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker pull containrrr/watchtower:latest
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        containrrr/watchtower:latest \
        --run-once \
        --cleanup \
        $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)
    docker rmi containrrr/watchtower:latest
    INFO "更新成功！"
}

function uninstall_xiaoya_alist(){
    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载小雅Alist${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker stop $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)
    docker rm $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)
    if docker inspect xiaoyaliu/alist:latest >/dev/null 2>&1; then
        docker rmi xiaoyaliu/alist:latest
    elif docker inspect xiaoyaliu/alist:hostmode >/dev/null 2>&1; then
        docker rmi xiaoyaliu/alist:hostmode
    fi
    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
        rm -rf ${OLD_CONFIG_DIR}
    fi
    INFO "卸载成功！"
}

function main_xiaoya_alist(){

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Alist${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-4]:" num
    case "$num" in
        1)
        clear
        install_xiaoya_alist
        ;;
        2)
        clear
        update_xiaoya_alist
        ;;
        3)
        clear
        uninstall_xiaoya_alist
        ;;
        4)
        clear
        main_return
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-4]'
        main_xiaoya_alist
        ;;
        esac

}

function test_xiaoya_status(){

    if [ -s ${CONFIG_DIR}/docker_address.txt ]; then
        docker_addr=$(head -n1 ${CONFIG_DIR}/docker_address.txt)
    else
        ERROR "请先配置 ${CONFIG_DIR}/docker_address.txt 后重试"
        exit 1
    fi

	INFO "测试xiaoya的联通性.......尝试连接 ${docker_addr}"
	wget -4 -q -T 5 -O /tmp/test.md "${docker_addr}/README.md"
	test_size=$(du -k /tmp/test.md |cut -f1)
	if [[ "$test_size" -eq 196 ]] || [[ "$test_size" -eq 65 ]] ||[[ "$test_size" -eq 0 ]]; then
		ERROR "请检查xiaoya是否正常运行后再试"
		exit 1
	else
		INFO "xiaoya容器正常工作"	
	fi

    rm -rf /tmp/test.md

}

function pull_run_glue(){

    if docker inspect xiaoyaliu/glue:latest >/dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/glue:latest | cut -f2 -d:)
        remote_sha=$(curl -s "https://hub.docker.com/v2/repositories/xiaoyaliu/glue/tags/latest"| grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ ! "$local_sha" == "$remote_sha" ]; then
            docker rmi xiaoyaliu/glue:latest
        fi
    fi

    docker run -it \
        --security-opt seccomp=unconfined \
        --rm \
        --net=host \
        -v ${MEDIA_DIR}:/media \
        -v ${CONFIG_DIR}:/etc/xiaoya \
        ${extra_parameters} \
        -e LANG=C.UTF-8 \
        xiaoyaliu/glue:latest \
        ${@}

    docker rmi xiaoyaliu/glue:latest

}

function pull_run_ddsderek_glue(){

    if docker inspect ddsderek/xiaoya-glue:latest >/dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' ddsderek/xiaoya-glue:latest | cut -f2 -d:)
        remote_sha=$(curl -s "https://hub.docker.com/v2/repositories/ddsderek/xiaoya-glue/tags/latest"| grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ ! "$local_sha" == "$remote_sha" ]; then
            docker rmi ddsderek/xiaoya-glue:latest
        fi
    fi

    docker run -it \
        --security-opt seccomp=unconfined \
        --rm \
        --net=host \
        -v ${MEDIA_DIR}:/media \
        -v ${CONFIG_DIR}:/etc/xiaoya \
        ${extra_parameters} \
        -e LANG=C.UTF-8 \
        ddsderek/xiaoya-glue:latest \
        ${@}

    docker rmi ddsderek/xiaoya-glue:latest

}

function set_emby_server_infuse_api_key(){

    if command -v ifconfig >/dev/null 2>&1; then
        docker0=$(ifconfig docker0 | grep "inet " |awk '{print $2}'|tr -d "addr:" |head -n1)
    else
        docker0=$(ip addr show docker0 |grep "inet " |awk '{print $2}'|tr -d "addr:" |head -n1|cut -f1 -d/)
    fi

    echo "http://$docker0:6908" > ${CONFIG_DIR}/emby_server.txt
    echo "e825ed6f7f8f44ffa0563cddaddce14d" > ${CONFIG_DIR}/infuse_api_key.txt

}

function download_unzip_xiaoya_all_emby(){

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p ${MEDIA_DIR}/temp
	rm -rf ${MEDIA_DIR}/config
    free_size=$(df -P ${MEDIA_DIR} | tail -n1 | awk '{print $4}')
	free_size=$((free_size))
    free_size_G=$((free_size/1024/1024))
    if [ "$free_size" -le 63886080  ]; then
        ERROR "空间剩余容量不够：${free_size_G}G 小于最低要求140G"
        exit 1
    else
        INFO "磁盘容量：${free_size_G}G"
    fi
	mkdir -p ${MEDIA_DIR}/xiaoya
	mkdir -p ${MEDIA_DIR}/config
	chmod 755 ${MEDIA_DIR}
	chown root:root ${MEDIA_DIR}

	if command -v ifconfig >/dev/null 2>&1; then
		docker0=$(ifconfig docker0 | grep "inet " | awk '{print $2}' | tr -d "addr:" | head -n1)
	else
		docker0=$(ip addr show docker0 | grep "inet " | awk '{print $2}' | tr -d "addr:" | head -n1 | cut -f1 -d/)
	fi

    INFO "开始下载解压..."

    pull_run_glue '/update_all.sh'

    set_emby_server_infuse_api_key

    INFO "设置目录权限..."
    chmod -R 777 ${MEDIA_DIR}

    INFO "下载解压完成！"

}

function unzip_xiaoya_all_emby(){

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p ${MEDIA_DIR}/temp
	rm -rf ${MEDIA_DIR}/config
    free_size=$(df -P ${MEDIA_DIR} | tail -n1 | awk '{print $4}')
	free_size=$((free_size))
    free_size_G=$((free_size/1024/1024))
    if [ "$free_size" -le 63886080  ]; then
        ERROR "空间剩余容量不够：${free_size_G}G 小于最低要求140G"
        exit 1
    else
        INFO "磁盘容量：${free_size_G}G"
    fi
	mkdir -p ${MEDIA_DIR}/xiaoya
	mkdir -p ${MEDIA_DIR}/config
	chmod 755 ${MEDIA_DIR}
	chown root:root ${MEDIA_DIR}

	if command -v ifconfig >/dev/null 2>&1; then
		docker0=$(ifconfig docker0 | grep "inet " | awk '{print $2}' | tr -d "addr:" | head -n1)
	else
		docker0=$(ip addr show docker0 | grep "inet " | awk '{print $2}' | tr -d "addr:" | head -n1 | cut -f1 -d/)
	fi

    INFO "开始解压..."

    pull_run_glue '/unzip.sh'
    
    set_emby_server_infuse_api_key

    INFO "设置目录权限..."
    chmod -R 777 ${MEDIA_DIR}

    INFO "解压完成！"

}

function download_xiaoya_emby(){

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p ${MEDIA_DIR}/temp
    free_size=$(df -P ${MEDIA_DIR} | tail -n1 | awk '{print $4}')
	free_size=$((free_size))
    free_size_G=$((free_size/1024/1024))
    INFO "磁盘容量：${free_size_G}G"

	mkdir -p ${MEDIA_DIR}/xiaoya
	mkdir -p ${MEDIA_DIR}/config
	chmod 755 ${MEDIA_DIR}
	chown root:root ${MEDIA_DIR}

    INFO "开始下载 ${1} ..."

    docker_addr=$(head -n1 ${CONFIG_DIR}/docker_address.txt)

    extra_parameters="--workdir=/media/temp"

    pull_run_glue aria2c -o ${1} --auto-file-renaming=false -c -x6 "${docker_addr}/d/元数据/${1}"

    INFO "设置目录权限..."
    chmod 777 ${MEDIA_DIR}/temp/${1}

    INFO "下载完成！"

}

function unzip_xiaoya_emby(){

    get_config_dir

    get_media_dir

    free_size=$(df -P ${MEDIA_DIR} | tail -n1 | awk '{print $4}')
	free_size=$((free_size))
    free_size_G=$((free_size/1024/1024))
    INFO "磁盘容量：${free_size_G}G"

	mkdir -p ${MEDIA_DIR}/xiaoya
	mkdir -p ${MEDIA_DIR}/config
	chmod 755 ${MEDIA_DIR}
	chown root:root ${MEDIA_DIR}

    INFO "开始解压 ${1} ..."

    docker_addr=$(head -n1 ${CONFIG_DIR}/docker_address.txt)

    if [ "${1}" == "config.mp4" ]; then
        extra_parameters="--workdir=/media"

        pull_run_glue 7z x -aoa -mmt=16 temp/config.mp4

        INFO "设置目录权限..."
        chmod 777 ${MEDIA_DIR}/config
    else
        extra_parameters="--workdir=/media/xiaoya"

        pull_run_glue 7z x -aoa -mmt=16 /media/temp/${1}

        INFO "设置目录权限..."
        chmod 777 ${MEDIA_DIR}/xiaoya
    fi

    INFO "解压完成！"

}

function main_download_unzip_xiaoya_emby(){

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}下载/解压 元数据${Font}\n"
    echo -e "1、下载并解压 全部元数据"
    echo -e "2、解压 全部元数据"
    echo -e "3、下载 all.pm4"
    echo -e "4、解压 all.pm4"
    echo -e "5、下载 config.pm4"
    echo -e "6、解压 config.pm4"
    echo -e "7、下载 pikpak.mp4"
    echo -e "8、解压 pikpak.mp4"
    echo -e "9、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-9]:" num
    case "$num" in
        1)
        clear
        download_unzip_xiaoya_all_emby
        ;;
        2)
        clear
        unzip_xiaoya_all_emby
        ;;
        3)
        clear
        download_xiaoya_emby "all.mp4"
        ;;
        4)
        clear
        unzip_xiaoya_emby "all.mp4"
        ;;
        5)
        clear
        download_xiaoya_emby "config.mp4"
        ;;
        6)
        clear
        unzip_xiaoya_emby "config.mp4"
        ;;
        7)
        clear
        download_xiaoya_emby "pikpak.mp4"
        ;;
        8)
        clear
        unzip_xiaoya_emby "pikpak.mp4"
        ;;
        9)
        clear
        main_xiaoya_all_emby
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-9]'
        main_download_unzip_xiaoya_emby
        ;;
        esac

}

function install_emby_embyserver(){

    cpu_arch=$(uname -m)
    INFO "开始安装Emby容器....."
    case $cpu_arch in
        "x86_64" | *"amd64"*)
            docker run -itd \
                --name $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
                -v ${MEDIA_DIR}/config:/config \
                -v ${MEDIA_DIR}/xiaoya:/media \
                -v /etc/nsswitch.conf:/etc/nsswitch.conf \
                ${MOUNT} \
                --add-host="xiaoya.host:$xiaoya_host" \
                --net=host \
                --privileged=true \
                ${extra_parameters} \
                -e PUID=0 \
                -e PGID=0 \
                --restart=always \
                emby/embyserver:4.8.0.56
        ;;
        "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
            docker run -itd \
                --name $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
                -v ${MEDIA_DIR}/config:/config \
                -v ${MEDIA_DIR}/xiaoya:/media \
                -v /etc/nsswitch.conf:/etc/nsswitch.conf \
                ${MOUNT} \
                --add-host="xiaoya.host:$xiaoya_host" \
                --net=host \
                --privileged=true \
                ${extra_parameters} \
                -e PUID=0 \
                -e PGID=0 \
                --restart=always \
                emby/embyserver_arm64v8:4.8.0.56
        ;;
        *)
            ERROR "目前只支持amd64和arm64架构，你的架构是：$cpu_arch"
            exit 1
        ;;
    esac

}

function install_amilys_embyserver(){

    cpu_arch=$(uname -m)
    INFO "开始安装Emby容器....."
    case $cpu_arch in
        "x86_64" | *"amd64"*)
            docker run -itd \
                --name $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
                -v ${MEDIA_DIR}/config:/config \
                -v ${MEDIA_DIR}/xiaoya:/media \
                -v /etc/nsswitch.conf:/etc/nsswitch.conf \
                ${MOUNT} \
                --add-host="xiaoya.host:$xiaoya_host" \
                --net=host \
                --privileged=true \
                ${extra_parameters} \
                -e PUID=0 \
                -e PGID=0 \
                --restart=always \
                amilys/embyserver:4.8.0.56
        ;;
        *)
            ERROR "目前只支持amd64架构，你的架构是：$cpu_arch"
            exit 1
        ;;
    esac

}

function choose_emby_image(){

    INFO "请选择使用的Emby镜像 [ 1:amilys/embyserver | 2:emby/embyserver ]（默认 2）"
    read -ep "IMAGE:" IMAGE
    [[ -z "${IMAGE}" ]] && IMAGE="2"
    if [[ ${IMAGE} == [1] ]]; then
        install_amilys_embyserver
    elif [[ ${IMAGE} == [2] ]]; then
        install_emby_embyserver
    else
        ERROR "输入无效，请重新选择"
        choose_emby_image
    fi

}

function install_emby_xiaoya_all_emby(){

    if ! grep xiaoya.host /etc/hosts; then
        echo -e "127.0.0.1\txiaoya.host\n" >> /etc/hosts
        xiaoya_host="127.0.0.1"
    else
        xiaoya_host=$(grep xiaoya.host /etc/hosts |awk '{print $1}' |head -n1)	
    fi

    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        INFO "请输入其他参数（默认 无 ）"
        read -ep "Extra parameters:" extra_parameters
    fi

    if [ "$1" == "official" ]; then
        install_emby_embyserver
    else
        choose_emby_image
    fi

    set_emby_server_infuse_api_key

    sleep 5

    INFO "重启小雅容器中..."
    docker restart \
        $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt) \
        $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)

    INFO "Emby安装完成！"

}

function docker_address_xiaoya_all_emby(){

    get_config_dir

    get_media_dir

    pull_run_ddsderek_glue "/docker_address.sh"

    INFO "替换DOCKER_ADDRESS完成！"

}

function uninstall_xiaoya_all_emby(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载小雅Emby全家桶${Blue} $i ${Font}\r"  
    sleep 1;
    done
	docker stop $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)
	docker rm $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)
    cpu_arch=$(uname -m)
    case $cpu_arch in
        "x86_64" | *"amd64"*)
            if docker inspect amilys/embyserver:4.8.0.56 >/dev/null 2>&1; then
                docker rmi amilys/embyserver:4.8.0.56
            elif docker inspect emby/embyserver:4.8.0.56 >/dev/null 2>&1; then
                docker rmi emby/embyserver:4.8.0.56
            fi
        ;;
        "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
            docker rmi emby/embyserver_arm64v8:4.8.0.56
        ;;
    esac
    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt ]; then
        OLD_MEDIA_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt)
        rm -rf ${OLD_MEDIA_DIR}
    fi
    INFO "卸载成功！"

}

function install_resilio(){

    if [ -f ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt)
        INFO "已读取Resilio-Sync配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo ${CONFIG_DIR} > ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 /etc/xiaoya/resilio ）"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/xiaoya/resilio"
        touch ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
        echo ${CONFIG_DIR} > ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
    fi

    INFO "请输入后台管理端口（默认 8888 ）"
    read -ep "HT_PORT:" HT_PORT
    [[ -z "${HT_PORT}" ]] && HT_PORT="8888"

    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        INFO "请输入其他参数（默认 无 ）"
        read -ep "Extra parameters:" extra_parameters
    fi

    get_media_dir

    if [ ! -d ${MEDIA_DIR}/config_sync ]; then
        mkdir -p ${MEDIA_DIR}/config_sync
        chmod 777 ${MEDIA_DIR}/config_sync
        cp -r ${MEDIA_DIR}/config/* ${MEDIA_DIR}/config_sync/
    fi

    INFO "开始安装resilio..."
    docker run -d \
        --name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
        -e PUID=0 \
        -e PGID=0 \
        -e TZ=Asia/Shanghai \
        -p ${HT_PORT}:8888 \
        -p 55555:55555 \
        -v ${CONFIG_DIR}:/config \
        -v ${CONFIG_DIR}/downloads:/downloads \
        -v ${MEDIA_DIR}:/sync \
        ${extra_parameters} \
        --restart=always \
        linuxserver/resilio-sync:latest

    CRON="0 6 */3 * * bash -c \"\$(curl http://docker.xiaoya.pro/sync_emby_config.sh)\" -s ${MEDIA_DIR} $(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt) $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) >> ${CONFIG_DIR}/cron.log 2>&1"
    if command -v crontab >/dev/null 2>&1; then
        crontab -l |grep -v sync_emby_config > /tmp/cronjob.tmp
        echo -e "${CRON}" >> /tmp/cronjob.tmp
        crontab /tmp/cronjob.tmp
        INFO '已经添加下面的记录到crontab定时任务，每三天更新一次config'
        INFO "${CRON}"
        rm -rf /tmp/cronjob.tmp
    fi

    INFO "安装完成！"

}

function update_resilio(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始更新Resilio-Sync${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker pull containrrr/watchtower:latest
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        containrrr/watchtower:latest \
        --run-once \
        --cleanup \
        $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)
    docker rmi containrrr/watchtower:latest
    INFO "更新成功！"

}

function unisntall_resilio(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载Resilio-Sync${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker stop $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)
    docker rm $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)
    docker rmi linuxserver/resilio-sync:latest
    if [ -f ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt)
        rm -rf ${OLD_CONFIG_DIR}
    fi
    crontab -l > /tmp/cronjob.tmp
    grep -n "sync_emby_config" /tmp/cronjob.tmp | cut -d ":" -f 1 | xargs -I {} sed -i '{}d' /tmp/cronjob.tmp
    crontab /tmp/cronjob.tmp
    rm -rf /tmp/cronjob.tmp
    INFO "卸载成功！"

}

function main_resilio(){

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Resilio-Sync${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-4]:" num
    case "$num" in
        1)
        clear
        install_resilio
        ;;
        2)
        clear
        update_resilio
        ;;
        3)
        clear
        unisntall_resilio
        ;;
        4)
        clear
        main_xiaoya_all_emby
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-4]'
        main_resilio
        ;;
        esac
    
}

function main_xiaoya_all_emby(){

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Emby全家桶${Font}\n"
    echo -e "1、一键安装Emby全家桶"
    echo -e "2、下载/解压 元数据"
    echo -e "3、安装Emby（可选择版本）"
    echo -e "4、替换DOCKER_ADDRESS（${Red}已弃用${Font}）"
    echo -e "5、安装/更新/卸载 Resilio-Sync"
    echo -e "6、卸载Emby全家桶"
    echo -e "7、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-7]:" num
    case "$num" in
        1)
        clear
        download_unzip_xiaoya_all_emby
        install_emby_xiaoya_all_emby "official"
        ;;
        2)
        clear
        main_download_unzip_xiaoya_emby
        ;;
        3)
        clear
        get_media_dir
        install_emby_xiaoya_all_emby
        ;;
        4)
        clear
        docker_address_xiaoya_all_emby
        ;;
        5)
        clear
        main_resilio
        ;;
        6)
        clear
        uninstall_xiaoya_all_emby
        ;;
        7)
        clear
        main_return
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-7]'
        main_xiaoya_all_emby
        ;;
        esac

}

function install_xiaoyahelper() {

    INFO "小白全部回车即可完成安装！"

    INFO "选择模式：模式3（定时运行小雅转存清理并升级小雅镜像）或模式5（只要产生了播放缓存一分钟内立即清理。签到和定时升级同模式3）[3/5]（默认 3）"
    read -ep "MODE:" MODE
    [[ -z "${MODE}" ]] && MODE="3"

    INFO "是否使用Telegram通知 [Y/n]（默认 n 不使用）"
    read -ep "TG:" TG
    [[ -z "${TG}" ]] && TG="n"
    if [[ ${TG} == [Yy] ]]; then
        bash -c "$(curl -s https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh| tail -n +2)" -s ${MODE} -tg
    fi
    if [[ ${TG} == [Nn] ]]; then
        bash -c "$(curl -s https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh| tail -n +2)" -s ${MODE}
    fi
    INFO "安装完成！"

}

function uninstall_xiaoyahelper() {

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载小雅助手（xiaoyahelper）${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker stop xiaoyakeeper
    docker rm xiaoyakeeper
    docker rmi dockerproxy.com/library/alpine:3.18.2
    INFO "卸载成功！"

}

function main_xiaoyahelper(){

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅助手（xiaoyahelper）${Font}\n"
    echo -e "1、安装/更新"
    echo -e "2、卸载"
    echo -e "3、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-3]:" num
    case "$num" in
        1)
        clear
        install_xiaoyahelper
        ;;
        2)
        clear
        uninstall_xiaoyahelper
        ;;
        3)
        clear
        main_return
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-3]'
        main_xiaoyahelper
        ;;
        esac

}

function install_xiaoya_alist_tvbox(){

    INFO "小白全部回车即可完成安装！"

    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt)
        INFO "已读取小雅Alist-TVBox配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo ${CONFIG_DIR} > ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 /etc/xiaoya ）"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/xiaoya"
        touch ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt
        echo ${CONFIG_DIR} > ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt
    fi

    INFO "请输入Alist端口（默认 5344 ）"
    read -ep "ALIST_PORT:" ALIST_PORT
    [[ -z "${ALIST_PORT}" ]] && ALIST_PORT="5344"

    INFO "请输入后台管理端口（默认 4567 ）"
    read -ep "HT_PORT:" HT_PORT
    [[ -z "${HT_PORT}" ]] && HT_PORT="4567"

    INFO "请输入内存限制（默认 -Xmx512M ）"
    read -ep "MEM_OPT:" MEM_OPT
    [[ -z "${MEM_OPT}" ]] && MEM_OPT="-Xmx512M"

    INFO "请输入其他挂载参数（默认 无 ）"
    read -ep "MOUNT:" MOUNT

    docker run -itd \
        -p ${HT_PORT}:4567 \
        -p ${ALIST_PORT}:80 \
        -e ALIST_PORT=${ALIST_PORT} \
        -e MEM_OPT="${MEM_OPT}" \
        -v ${CONFIG_DIR}:/data \
        ${MOUNT} \
        --restart=always \
        --name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt) \
        haroldli/xiaoya-tvbox:latest

    INFO "安装完成！"

}

function update_xiaoya_alist_tvbox(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始更新小雅Alist-TVBox${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker pull containrrr/watchtower:latest
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        containrrr/watchtower:latest \
        --run-once \
        --cleanup \
        $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)
    docker rmi containrrr/watchtower:latest
    INFO "更新成功！"

}

function uninstall_xiaoya_alist_tvbox(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载小雅Alist-TVBox${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker stop $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)
    docker rm $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)
    docker rmi haroldli/xiaoya-tvbox:latest
    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt)
        rm -rf ${OLD_CONFIG_DIR}
    fi
    INFO "卸载成功！"

}

function main_xiaoya_alist_tvbox(){

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Alist-TVBox${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-4]:" num
    case "$num" in
        1)
        clear
        install_xiaoya_alist_tvbox
        ;;
        2)
        clear
        update_xiaoya_alist_tvbox
        ;;
        3)
        clear
        uninstall_xiaoya_alist_tvbox
        ;;
        4)
        clear
        main_return
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-4]'
        main_xiaoya_alist_tvbox
        ;;
        esac

}

function install_onelist(){

    if [ -f ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt)
        INFO "已读取Onelist配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo ${CONFIG_DIR} > ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 /etc/onelist ）"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/onelist"
        touch ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt
        echo ${CONFIG_DIR} > ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt
    fi

    INFO "请输入后台管理端口（默认 5245 ）"
    read -ep "HT_PORT:" HT_PORT
    [[ -z "${HT_PORT}" ]] && HT_PORT="5245"

    docker run -itd \
        -p ${HT_PORT}:5245 \
        -e PUID=0 \
        -e PGID=0 \
        -e UMASK=022 \
        -e TZ=Asia/Shanghai \
        -v ${CONFIG_DIR}:/config \
        --restart=always \
        --name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt) \
        msterzhang/onelist:latest

    INFO "安装完成！"

}

function update_onelist(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始更新Onelist${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker pull containrrr/watchtower:latest
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        containrrr/watchtower:latest \
        --run-once \
        --cleanup \
        $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt)
    docker rmi containrrr/watchtower:latest
    INFO "更新成功！"

}

function uninstall_onelist(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载Onelist${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker stop $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt)
    docker rm $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt)
    docker rmi msterzhang/onelist:latest
    if [ -f ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt)
        rm -rf ${OLD_CONFIG_DIR}
    fi
    INFO "卸载成功！"

}

function main_onelist(){

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Onelist${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-4]:" num
    case "$num" in
        1)
        clear
        install_onelist
        ;;
        2)
        clear
        update_onelist
        ;;
        3)
        clear
        uninstall_onelist
        ;;
        4)
        clear
        main_return
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-4]'
        main_onelist
        ;;
        esac

}

function install_portainer(){

    if [ -f ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt)
        INFO "已读取Onelist配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo ${CONFIG_DIR} > ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 /etc/portainer ）"
        read -ep "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/portainer"
        touch ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt
        echo ${CONFIG_DIR} > ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt
    fi

    INFO "请输入后台HTTP管理端口（默认 9000 ）"
    read -ep "HTTP_PORT:" HTTP_PORT
    [[ -z "${HTTP_PORT}" ]] && HTTP_PORT="9000"

    INFO "请输入后台HTTP管理端口（默认 9443 ）"
    read -ep "HTTPS_PORT:" HTTPS_PORT
    [[ -z "${HTTPS_PORT}" ]] && HTTPS_PORT="9443"

    INFO "请输入镜像TAG（默认 latest ）"
    read -ep "TAG:" TAG
    [[ -z "${TAG}" ]] && TAG="latest"

    docker run -itd \
        -p ${HTTPS_PORT}:9443 \
        -p ${HTTP_PORT}:9000 \
        --name $(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt) \
        -e TZ=Asia/Shanghai \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v ${CONFIG_DIR}:/data \
        portainer/portainer-ce:${TAG}

    INFO "安装完成！"

}

function update_portainer(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始更新Portainer${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker pull containrrr/watchtower:latest
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        containrrr/watchtower:latest \
        --run-once \
        --cleanup \
        $(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt)
    docker rmi containrrr/watchtower:latest
    INFO "更新成功！"

}

function uninstall_portainer(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载Portainer${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker stop $(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt)
    docker rm $(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt)
    docker rmi msterzhang/onelist:latest
    if [ -f ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt)
        rm -rf ${OLD_CONFIG_DIR}
    fi
    INFO "卸载成功！"

}

function main_portainer(){

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Portainer${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-4]:" num
    case "$num" in
        1)
        clear
        install_portainer
        ;;
        2)
        clear
        update_portainer
        ;;
        3)
        clear
        uninstall_portainer
        ;;
        4)
        clear
        main_return
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-4]'
        main_portainer
        ;;
        esac

}

function init_container_name(){

    if [ ! -d ${DDSREM_CONFIG_DIR}/container_name ]; then
        mkdir -p ${DDSREM_CONFIG_DIR}/container_name
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt ]; then
        xiaoya_alist_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)
    else
        echo 'xiaoya' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt
        xiaoya_alist_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt ]; then
        xiaoya_emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)
    else
        echo 'emby' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt
        xiaoya_emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt ]; then
        xiaoya_resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)
    else
        echo 'resilio' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt
        xiaoya_resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt ]; then
        xiaoya_tvbox_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)
    else
        echo 'xiaoya-tvbox' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt
        xiaoya_tvbox_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt ]; then
        xiaoya_onelist_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt)
    else
        echo 'onelist' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt
        xiaoya_onelist_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt ]; then
        portainer_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt)
    else
        echo 'portainer' > ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt
        portainer_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt)
    fi

}

function change_container_name(){

    INFO "请输入新的容器名称"
    read -ep "Container name:" container_name
    [[ -z "${container_name}" ]] && container_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/${1}.txt)
    echo ${container_name} > ${DDSREM_CONFIG_DIR}/container_name/${1}.txt
    clear
    container_name_settings

}

function container_name_settings(){

    init_container_name

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}容器名称设置${Font}\n"
    echo -e "1、更改 小雅 容器名（当前：${Green}${xiaoya_alist_name}${Font}）"
    echo -e "2、更改 小雅Emby 容器名（当前：${Green}${xiaoya_emby_name}${Font}）"
    echo -e "3、更改 Resilio 容器名（当前：${Green}${xiaoya_resilio_name}${Font}）"
    echo -e "4、更改 小雅Alist-TVBox 容器名（当前：${Green}${xiaoya_tvbox_name}${Font}）"
    echo -e "5、更改 Onelist 容器名（当前：${Green}${xiaoya_onelist_name}${Font}）"
    echo -e "6、更改 Portainer 容器名（当前：${Green}${portainer_name}${Font}）"
    echo -e "7、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-7]:" num
    case "$num" in
        1)
        change_container_name "xiaoya_alist_name"
        ;;
        2)
        change_container_name "xiaoya_emby_name"
        ;;
        3)
        change_container_name "xiaoya_resilio_name"
        ;;
        4)
        change_container_name "xiaoya_tvbox_name"
        ;;
        5)
        change_container_name "xiaoya_onelist_name"
        ;;
        6)
        change_container_name "portainer_name"
        ;;
        7)
        clear
        main_advanced_configuration
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-7]'
        container_name_settings
        ;;
        esac

}

function main_advanced_configuration(){

    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}高级配置${Font}\n"
    echo -e "1、容器名称设置"
    echo -e "2、是否开启容器运行额外参数添加（当前：${Green}${container_run_extra_parameters}${Font}）"
    echo -e "3、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-3]:" num
    case "$num" in
        1)
        clear
        container_name_settings
        ;;
        2)
        if [ "${container_run_extra_parameters}" == "false" ]; then
            echo 'true' > ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt
        else
            echo 'false' > ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt
        fi
        clear
        main_advanced_configuration
        ;;
        3)
        clear
        main_return
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-3]'
        main_advanced_configuration
        ;;
        esac

}

function main_return(){
    curl -sL https://ddsrem.com/xiaoya/xiaoya_alist | sed "s/DATE_VERSION/${DATE_VERSION}/g"
    echo -e "1、安装/更新/卸载 小雅Alist"
    echo -e "2、安装/卸载 小雅Emby全家桶"
    echo -e "3、安装/更新/卸载 小雅助手（xiaoyahelper）"
    echo -e "4、安装/更新/卸载 小雅Alist-TVBox"
    echo -e "5、安装/更新/卸载 Onelist"
    echo -e "6、安装/更新/卸载 Portainer"
    echo -e "7、高级配置"
    echo -e "8、退出脚本"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-8]:" num
    case "$num" in
        1)
        clear
        main_xiaoya_alist
        ;;
        2)
        clear
        main_xiaoya_all_emby
        ;;
        3)
        clear
        main_xiaoyahelper
        ;;
        4)
        clear
        main_xiaoya_alist_tvbox
        ;;
        5)
        clear
        main_onelist
        ;;
        6)
        clear
        main_portainer
        ;;
        7)
        clear
        main_advanced_configuration
        ;;
        8)
        clear
        exit 0
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-8]'
        main_return
        ;;
        esac
}

function main(){
    clear
    main_return
}

function ci_test(){

    docker pull xiaoyaliu/alist:latest
    docker pull xiaoyaliu/alist:hostmode
    docker pull xiaoyaliu/glue:latest
    docker pull ddsderek/xiaoya-glue:latest
    docker pull linuxserver/resilio-sync:latest
    docker pull ddsderek/xiaoya-emby-library:latest
    docker pull haroldli/xiaoya-tvbox:latest
    docker pull msterzhang/onelist:latest
    docker pull portainer/portainer-ce
    docker pull amilys/embyserver:4.8.0.56
    docker pull emby/embyserver:4.8.0.56

}

function first_init(){

    root_need
    if [ ! -d ${DDSREM_CONFIG_DIR} ]; then
        mkdir -p ${DDSREM_CONFIG_DIR}
    fi
    # Fix https://github.com/DDS-Derek/xiaoya-alist/commit/a246bc582393b618b564e3beca2b9e1d40800a5d 中media目录保存错误
    if [ -f /xiaoya_alist_media_dir.txt ]; then
        mv /xiaoya_alist_media_dir.txt ${DDSREM_CONFIG_DIR}
    fi
    init_container_name

    if [ ! -f ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt ]; then
        echo 'false' > ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_emby_url.txt ]; then
        rm -rf ${DDSREM_CONFIG_DIR}/xiaoya_emby_url.txt
    fi
    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_emby_api.txt ]; then
        rm -rf ${DDSREM_CONFIG_DIR}/xiaoya_emby_api.txt
    fi

}

if [ ! $@ ]; then
    first_init
    main
elif [ "$@" == test ]; then
    INFO "Test"
    ci_test
else
    first_init
    $@
fi
