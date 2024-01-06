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
# ——————————————————————————————————————————————————————————————————————————————————
#
# The functions that the script can call are 'INFO' 'WARN' 'ERROR'
#                 INFO function use(log output): INFO "xxxx"
#                 WARN function use(log output): WARN "xxxx"
#                 ERROR function use(log output): ERROR "xxxx"


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

if [ ! -d ${DDSREM_CONFIG_DIR} ]; then
    mkdir -p ${DDSREM_CONFIG_DIR}
fi

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

    if [ -f ${DDSREM_MEDIA_DIR}/xiaoya_alist_media_dir.txt ]; then
        OLD_MEDIA_DIR=$(cat ${DDSREM_MEDIA_DIR}/xiaoya_alist_media_dir.txt)
        INFO "已读取媒体库目录：${OLD_MEDIA_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -ep "MEDIA_DIR:" MEDIA_DIR
        [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR=${OLD_MEDIA_DIR}
        echo ${MEDIA_DIR} > ${DDSREM_MEDIA_DIR}/xiaoya_alist_media_dir.txt
    else
        INFO "请输入媒体库目录（默认 /opt/media ）"
        read -ep "MEDIA_DIR:" MEDIA_DIR
        [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR="/etc/xiaoya"
        touch ${DDSREM_MEDIA_DIR}/xiaoya_alist_media_dir.txt
        echo ${MEDIA_DIR} > ${DDSREM_MEDIA_DIR}/xiaoya_alist_media_dir.txt
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
            echo "http://$localip:6789" > ${CONFIG_DIR}/docker_address.txt
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
                --name=xiaoya-hostmode \
                xiaoyaliu/alist:hostmode
        else
            docker run -itd \
                --network=host \
                -v ${CONFIG_DIR}:/data \
                --restart=always \
                --name=xiaoya-hostmode \
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
                --name=xiaoya \
                xiaoyaliu/alist:latest
        else
            docker run -itd \
                -p 5678:80 \
                -p 2345:2345 \
                -p 2346:2346 \
                -v ${CONFIG_DIR}:/data \
                --restart=always \
                --name=xiaoya \
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
        xiaoya-hostmode xiaoya
    docker rmi containrrr/watchtower:latest
    INFO "更新成功！"
}

function uninstall_xiaoya_alist(){
    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载小雅Alist${Blue} $i ${Font}\r"  
    sleep 1;
    done
	docker stop xiaoya-hostmode
	docker rm xiaoya-hostmode
	docker rmi xiaoyaliu/alist:hostmode
    docker stop xiaoya
    docker rm xiaoya
    docker rmi xiaoyaliu/alist:latest
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

	local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/glue:latest | cut -f2 -d:)
	remote_sha=$(curl -s "https://hub.docker.com/v2/repositories/xiaoyaliu/glue/tags/latest"| grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
	if [ ! "$local_sha" == "$remote_sha" ]; then
		docker rmi xiaoyaliu/glue:latest
	fi

    docker run -it \
        --security-opt seccomp=unconfined \
        --rm \
        --net=host \
        -v ${MEDIA_DIR}:/media \
        -v ${CONFIG_DIR}:/etc/xiaoya \
        -e LANG=C.UTF-8 \
        xiaoyaliu/glue:latest \
        ${1}

    docker rmi xiaoyaliu/glue:latest

}

function pull_run_ddsderek_glue(){

	local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' ddsderek/xiaoya-glue:latest | cut -f2 -d:)
	remote_sha=$(curl -s "https://hub.docker.com/v2/repositories/ddsderek/xiaoya-glue/tags/latest"| grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
	if [ ! "$local_sha" == "$remote_sha" ]; then
		docker rmi ddsderek/xiaoya-glue:latest
	fi

    docker run -it \
        --security-opt seccomp=unconfined \
        --rm \
        --net=host \
        -v ${MEDIA_DIR}:/media \
        -v ${CONFIG_DIR}:/etc/xiaoya \
        -e LANG=C.UTF-8 \
        -e TZ=Asia/Shanghai \
        ddsderek/xiaoya-glue:latest \
        ${1}

    docker rmi ddsderek/xiaoya-glue:latest

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
    
    echo "http://$docker0:8096" > ${CONFIG_DIR}/emby_server.txt
    echo "e825ed6f7f8f44ffa0563cddaddce14d" > ${CONFIG_DIR}/infuse_api_key.txt
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
    
    echo "http://$docker0:8096" > ${CONFIG_DIR}/emby_server.txt
    echo "e825ed6f7f8f44ffa0563cddaddce14d" > ${CONFIG_DIR}/infuse_api_key.txt
    chmod -R 777 ${MEDIA_DIR}

    INFO "解压完成！"

}

function install_emby_embyserver(){

    cpu_arch=$(uname -m)
    INFO "开始安装Emby容器....."
    case $cpu_arch in
        "x86_64" | *"amd64"*)
            docker run -itd \
                --name xiaoya-emby \
                -v ${MEDIA_DIR}/config:/config \
                -v ${MEDIA_DIR}/xiaoya:/media \
                --net=host \
                -e PUID=0 \
                -e PGID=0 \
                --restart=always \
                emby/embyserver:4.8.0.56
        ;;
        "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
            docker run -itd \
                --name xiaoya-emby \
                -v ${MEDIA_DIR}/config:/config \
                -v ${MEDIA_DIR}/xiaoya:/media \
                --net=host \
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
                --name xiaoya-emby \
                -v ${MEDIA_DIR}/config:/config \
                -v ${MEDIA_DIR}/xiaoya:/media \
                --net=host \
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

function install_emby_xiaoya_all_emby(){

    if [ "$1" == "official" ]; then
        install_emby_embyserver
    else
        INFO "请选择使用的Emby镜像 [ 1:amilys/embyserver | 2:emby/embyserver ]（默认 2）"
        read -ep "IMAGE:" IMAGE
        [[ -z "${IMAGE}" ]] && IMAGE="2"
        if [[ ${IMAGE} == [1] ]]; then
            install_amilys_embyserver
        elif [[ ${IMAGE} == [2] ]]; then
            install_emby_embyserver
        else
            ERROR "输入无效，请重新选择"
            install_emby_xiaoya_all_emby
        fi
    fi

    INFO "Emby安装完成！"

}

function docker_address_xiaoya_all_emby(){

    get_config_dir

    get_media_dir

    pull_run_ddsderek_glue "/docker_address.sh"

}

function uninstall_xiaoya_all_emby(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载小雅Emby全家桶${Blue} $i ${Font}\r"  
    sleep 1;
    done
	docker stop xiaoya-emby
	docker rm xiaoya-emby
    cpu_arch=$(uname -m)
    case $cpu_arch in
        "x86_64" | *"amd64"*)
            docker rmi amilys/embyserver:4.8.0.56
            docker rmi emby/embyserver:4.8.0.56
        ;;
        "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
            docker rmi emby/embyserver_arm64v8:4.8.0.56
        ;;
    esac
    INFO "卸载成功！"

}

function main_xiaoya_all_emby(){

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Emby全家桶${Font}\n"
    echo -e "1、一键安装全家桶"
    echo -e "2、下载解压元数据"
    echo -e "3、解压元数据"
    echo -e "4、安装Emby（可选择版本）"
    echo -e "5、替换DOCKER_ADDRESS"
    echo -e "6、一键安装全家桶 Plus（包含所有步骤，可选择Emby版本）"
    echo -e "7、卸载"
    echo -e "8、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-8]:" num
    case "$num" in
        1)
        clear
        download_unzip_xiaoya_all_emby
        docker_address_xiaoya_all_emby
        install_emby_xiaoya_all_emby "official"
        ;;
        2)
        clear
        download_unzip_xiaoya_all_emby
        ;;
        3)
        clear
        unzip_xiaoya_all_emby
        ;;
        4)
        clear
        get_media_dir
        install_emby_xiaoya_all_emby
        ;;
        5)
        clear
        docker_address_xiaoya_all_emby
        ;;
        6)
        clear
        download_unzip_xiaoya_all_emby
        docker_address_xiaoya_all_emby
        install_emby_xiaoya_all_emby
        ;;
        7)
        clear
        uninstall_xiaoya_all_emby
        ;;
        8)
        clear
        main_return
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-8]'
        main_xiaoya_all_emby
        ;;
        esac

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
        INFO "小白全部回车即可完成安装！"
        INFO "是否使用Telegram通知 [Y/n]（默认 n 不使用）"
        read -ep "TG:" TG
        [[ -z "${TG}" ]] && TG="n"
        if [[ ${TG} == [Yy] ]]; then
            bash -c "$(curl -s https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh| tail -n +2)" -s 3 -tg
        fi
        if [[ ${TG} == [Nn] ]]; then
            bash -c "$(curl -s https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh| tail -n +2)" -s 3
        fi
        INFO "安装完成！"
        ;;
        2)
        clear
        for i in `seq -w 3 -1 0`
        do
            echo -en "即将开始卸载小雅助手（xiaoyahelper）${Blue} $i ${Font}\r"  
        sleep 1;
        done
        docker stop xiaoyakeeper
        docker rm xiaoyakeeper
        docker rmi dockerproxy.com/library/alpine:3.18.2
        INFO "卸载成功！"
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

    get_config_dir

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
        --name=xiaoya-tvbox \
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
        xiaoya-tvbox
    docker rmi containrrr/watchtower:latest
    INFO "更新成功！"

}

function uninstall_xiaoya_alist_tvbox(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载小雅Alist-TVBox${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker stop xiaoya-tvbox
    docker rm xiaoya-tvbox
    docker rmi haroldli/xiaoya-tvbox:latest
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

function main_return(){
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    curl -sL https://ddsrem.com/xiaoya_alist
    echo -e "
Copyright (c) 2023 DDSRem <https://blog.ddsrem.com>

This is free software, licensed under the Mit License.

——————————————————————————————————————————————————————————————————————————————————"
    echo -e "1、安装/更新/卸载 小雅Alist"
    echo -e "2、安装/更新/卸载 小雅Emby全家桶"
    echo -e "3、安装/更新/卸载 小雅助手（xiaoyahelper）"
    echo -e "4、安装/更新/卸载 小雅Alist-TVBox"
    echo -e "5、退出脚本"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-5]:" num
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
        exit 0
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-5]'
        main_return
        ;;
        esac
}

function main(){
    root_need
    clear
    main_return
}

main