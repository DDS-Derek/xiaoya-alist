#!/bin/bash

# bash -c "$(curl http://docker.xiaoya.pro/update_new.sh | awk '{gsub("/etc/xiaoya", "/ssd/data/docker/xiaoya/xiaoya"); print}')"

# bash -c "$(curl http://docker.xiaoya.pro/emby_plus.sh \
# | awk '{gsub("emby/embyserver:4.8.0.56", "amilys/embyserver:4.8.0.56"); print}' \
# | awk '{gsub("emby/embyserver_arm64v8:4.8.0.56", "amilys/embyserver:4.8.0.56"); print}' \
# | awk '{gsub("--name emby", "--name xiaoya-emby"); print}')"

# bash -c "$(curl -s https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh| tail -n +2)" -s 3 -tg

# docker run -d -p 4567:4567 -p 5344:80 -e ALIST_PORT=5344 --restart=always -v /etc/xiaoya:/data --name=xiaoya-tvbox haroldli/xiaoya-tvbox
# bash -c "$(curl -fsSL https://d.har01d.cn/update_xiaoya.sh)"

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

function root_need(){
    if [[ $EUID -ne 0 ]]; then
        ERRO '此脚本必须以 root 身份运行！'
        exit 1
    fi
}

function TODO(){
    WARN "此功能未完成，请耐心等待开发者开发"
}

function install_xiaoya_alist(){

    INFO "小白全部回车即可完成安装！"

    INFO "请输入配置文件目录（默认 /etc/xiaoya ）"
    read -ep "CONFIG_DIR:" CONFIG_DIR
    [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/xiaoya"

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
        exit 0
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
    INFO "更新成功"
}

function uninstall_xiaoya_alist(){
	docker stop xiaoya-hostmode
	docker rm xiaoya-hostmode
	docker rmi xiaoyaliu/alist:hostmode
    docker stop xiaoya
    docker rm xiaoya
    docker rmi xiaoyaliu/alist:latest
    INFO "卸载成功"
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

function main_xiaoya_all_emby(){

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Emby全家桶${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-4]:" num
    case "$num" in
        1)
        clear
        TODO
        ;;
        2)
        clear
        TODO
        ;;
        3)
        clear
        TODO
        ;;
        4)
        clear
        main_return
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-4]'
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
        docker stop xiaoyakeeper
        docker rm xiaoyakeeper
        docker rmi dockerproxy.com/library/alpine:3.18.2
        INFO "卸载成功"
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

    INFO "请输入配置文件目录（默认 /etc/xiaoya ）"
    read -ep "CONFIG_DIR:" CONFIG_DIR
    [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/xiaoya"

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
    INFO "更新成功"

}

function uninstall_xiaoya_alist_tvbox(){

    docker stop xiaoya-tvbox
    docker rm xiaoya-tvbox
    docker rmi haroldli/xiaoya-tvbox:latest
    INFO "卸载成功"

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