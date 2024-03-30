#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC2086
# shellcheck disable=SC1091
# shellcheck disable=SC2154
PATH=${PATH}:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/opt/homebrew/bin
export PATH
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
# Copyright (c) 2024 DDSRem <https://blog.ddsrem.com>
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
# bash -c "$(curl http://docker.xiaoya.pro/emby_new.sh)" -s --config_dir=xiaoya配置目录 --action=generate_config
#
# bash -c "$(curl http://docker.xiaoya.pro/emby_new.sh)" -s --config_dir=xiaoya配置目录
#
# 模式0：每天自动清理一次。如果系统重启需要手动重新运行或把命令加入系统启动。
# bash -c "$(curl -s https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh | tail -n +2)" -s 0 -tg
# 模式1：一次性清理，一般用于测试效果。
# bash -c "$(curl -s https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh | tail -n +2)" -s 1 -tg
# 模式2：已废弃，不再支持
# 模式3：创建一个名为 xiaoyakeeper 的docker定时运行小雅转存清理并升级小雅镜像
# bash -c "$(curl -s https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh | tail -n +2)" -s 3 -tg
# 模式4：同模式3
# 模式5：与模式3的区别是实时清理，只要产生了播放缓存一分钟内立即清理。签到和定时升级同模式3
# bash -c "$(curl -s https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh | tail -n +2)" -s 5 -tg
# 签到功能说明：
# 1、执行时机和清理缓存完全相同
# 2、可以手动创建/etc/xiaoya/mycheckintoken.txt，定义多个网盘签到的32位refresh token，每行一个，不添加文件就是默认小雅转存的网盘签到。
# 3、自动刷新/etc/xiaoya/mycheckintoken.txt、/etc/xiaoya/mytoken.txt（可能可以延长refresh token时效，待观察）
# 关于模式0/3/4/5定时运行的说明：
# 1、默认从运行脚本的下一分钟开始，每天运行一次
# 2、运行的时间也可以通过手动创建/etc/xiaoya/myruntime.txt修改，比如06:00,18:00就是每天早晚6点各运行一次
# 关于自动升级:
# 1、定时升级的命令保存在/etc/xiaoya/mycmd.txt中，删除该文件变成定时重启小雅
# 2、完成清理和签到后自动执行/etc/xiaoya/mycmd.txt中的命令，该文件中的内容默认升级小雅镜像，可以修改该文件改编脚本的行为，不建议修改。
# 关于tg推送：
# 所有模式加上-tg功能均可绑定消息推送的TG账号，只有第1次运行需要加-tg参数
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
DATE_VERSION="v1.4.6-2024_03_30_21_37"
#
# ——————————————————————————————————————————————————————————————————————————————————

Sky_Blue="\e[36m"
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

function root_need() {
    if [[ $EUID -ne 0 ]]; then
        ERROR '此脚本必须以 root 身份运行！'
        exit 1
    fi
}

function ___install_docker() {

    if ! which docker; then
        WARN "docker 未安装，脚本尝试自动安装..."
        wget -qO- get.docker.com | bash
        if which docker; then
            INFO "docker 安装成功！"
        else
            ERROR "docker 安装失败，请手动安装！"
            exit 1
        fi
    fi

}

function packages_need() {

    if [ "$1" == "apt" ]; then
        if ! which curl; then
            WARN "curl 未安装，脚本尝试自动安装..."
            apt update -y
            if apt install -y curl; then
                INFO "curl 安装成功！"
            else
                ERROR "curl 安装失败，请手动安装！"
                exit 1
            fi
        fi
        if ! which wget; then
            WARN "wget 未安装，脚本尝试自动安装..."
            apt update -y
            if apt install -y wget; then
                INFO "wget 安装成功！"
            else
                ERROR "wget 安装失败，请手动安装！"
                exit 1
            fi
        fi
        ___install_docker
    elif [ "$1" == "yum" ]; then
        if ! which curl; then
            WARN "curl 未安装，脚本尝试自动安装..."
            if yum install -y curl; then
                INFO "curl 安装成功！"
            else
                ERROR "curl 安装失败，请手动安装！"
                exit 1
            fi
        fi
        if ! which wget; then
            WARN "wget 未安装，脚本尝试自动安装..."
            if yum install -y wget; then
                INFO "wget 安装成功！"
            else
                ERROR "wget 安装失败，请手动安装！"
                exit 1
            fi
        fi
        ___install_docker
    elif [ "$1" == "zypper" ]; then
        if ! which curl; then
            WARN "curl 未安装，脚本尝试自动安装..."
            zypper refresh
            if zypper install curl; then
                INFO "curl 安装成功！"
            else
                ERROR "curl 安装失败，请手动安装！"
                exit 1
            fi
        fi
        if ! which wget; then
            WARN "wget 未安装，脚本尝试自动安装..."
            zypper refresh
            if zypper install wget; then
                INFO "wget 安装成功！"
            else
                ERROR "wget 安装失败，请手动安装！"
                exit 1
            fi
        fi
        ___install_docker
    elif [ "$1" == "apk_alpine" ]; then
        if ! which curl; then
            WARN "curl 未安装，脚本尝试自动安装..."
            if apk add curl; then
                INFO "curl 安装成功！"
            else
                ERROR "curl 安装失败，请手动安装！"
                exit 1
            fi
        fi
        if ! which wget; then
            WARN "wget 未安装，脚本尝试自动安装..."
            if apk add wget; then
                INFO "wget 安装成功！"
            else
                ERROR "wget 安装失败，请手动安装！"
                exit 1
            fi
        fi
        if ! which docker; then
            WARN "docker 未安装，脚本尝试自动安装..."
            if apk add docker; then
                INFO "docker 安装成功！"
            else
                ERROR "docker 安装失败，请手动安装！"
                exit 1
            fi
        fi
    elif [ "$1" == "pacman" ]; then
        if ! which curl; then
            WARN "curl 未安装，脚本尝试自动安装..."
            if pacman -Sy --noconfirm curl; then
                INFO "curl 安装成功！"
            else
                ERROR "curl 安装失败，请手动安装！"
                exit 1
            fi
        fi
        if ! which wget; then
            WARN "wget 未安装，脚本尝试自动安装..."
            if pacman -Sy --noconfirm wget; then
                INFO "wget 安装成功！"
            else
                ERROR "wget 安装失败，请手动安装！"
                exit 1
            fi
        fi
        if ! which docker; then
            WARN "docker 未安装，脚本尝试自动安装..."
            if pacman -Sy --noconfirm docker; then
                INFO "docker 安装成功！"
            else
                ERROR "docker 安装失败，请手动安装！"
                exit 1
            fi
        fi
    else
        if ! which curl; then
            ERROR "curl 未安装，请手动安装！"
            exit 1
        fi
        if ! which wget; then
            ERROR "wget 未安装，请手动安装！"
            exit 1
        fi
        if ! which docker; then
            ERROR "docker 未安装，请手动安装！"
            exit 1
        fi
    fi

}

function get_os() {

    if which getconf > /dev/null 2>&1; then
        is64bit="$(getconf LONG_BIT)bit"
    else
        is64bit="unknow"
    fi
    _os=$(uname -s)
    _os_all=$(uname -a)
    if [ "${_os}" == "Darwin" ]; then
        OSNAME='macos'
        packages_need
        DDSREM_CONFIG_DIR=/etc/DDSRem
    # 必须先判断的系统
    # 绿联NAS 基于 OpenWRT
    elif echo -e "${_os_all}" | grep -Eqi "UGREEN"; then
        OSNAME='ugreen'
        packages_need
        DDSREM_CONFIG_DIR=/etc/DDSRem
    # OpenMediaVault 基于 Debian
    elif grep -Eqi "openmediavault" /etc/issue || grep -Eqi "openmediavault" /etc/os-release; then
        OSNAME='openmediavault'
        packages_need "apt"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    # FreeNAS（TrueNAS CORE）基于 FreeBSD
    elif echo -e "${_os_all}" | grep -Eqi "FreeBSD" | grep -Eqi "TRUENAS"; then
        OSNAME='truenas core'
        packages_need
        DDSREM_CONFIG_DIR=/etc/DDSRem
    # TrueNAS SCALE 基于 Debian
    elif grep -Eqi "Debian" /etc/issue && [ -f /etc/version ]; then
        OSNAME='truenas scale'
        packages_need
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif [ -f /etc/synoinfo.conf ]; then
        OSNAME='synology'
        packages_need
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif [ -f /etc/openwrt_release ]; then
        OSNAME='openwrt'
        packages_need
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "QNAP" /etc/issue; then
        OSNAME='qnap'
        packages_need
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif [ -f /etc/unraid-version ]; then
        OSNAME='unraid'
        packages_need
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "LibreELEC" /etc/issue || grep -Eqi "LibreELEC" /etc/*-release; then
        OSNAME='libreelec'
        DDSREM_CONFIG_DIR=/storage/DDSRem
    elif grep -Eqi "openSUSE" /etc/*-release; then
        OSNAME='opensuse'
        packages_need "zypper"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "FreeBSD" /etc/*-release; then
        OSNAME='freebsd'
        packages_need
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "EulerOS" /etc/*-release || grep -Eqi "openEuler" /etc/*-release; then
        OSNAME='euler'
        packages_need "yum"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "CentOS" /etc/issue || grep -Eqi "CentOS" /etc/*-release; then
        OSNAME='centos'
        packages_need "yum"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Fedora" /etc/issue || grep -Eqi "Fedora" /etc/*-release; then
        OSNAME='fedora'
        packages_need "yum"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Rocky" /etc/issue || grep -Eqi "Rocky" /etc/*-release; then
        OSNAME='rocky'
        packages_need "yum"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "AlmaLinux" /etc/issue || grep -Eqi "AlmaLinux" /etc/*-release; then
        OSNAME='almalinux'
        packages_need "yum"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Arch Linux" /etc/issue || grep -Eqi "Arch Linux" /etc/*-release; then
        OSNAME='archlinux'
        packages_need "pacman"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Amazon Linux" /etc/issue || grep -Eqi "Amazon Linux" /etc/*-release; then
        OSNAME='amazon'
        packages_need "yum"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Debian" /etc/issue || grep -Eqi "Debian" /etc/os-release; then
        OSNAME='debian'
        packages_need "apt"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eqi "Ubuntu" /etc/os-release; then
        OSNAME='ubuntu'
        packages_need "apt"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Alpine" /etc/issue || grep -Eq "Alpine" /etc/*-release; then
        OSNAME='alpine'
        packages_need "apk_alpine"
        DDSREM_CONFIG_DIR=/etc/DDSRem
    else
        OSNAME='unknow'
        packages_need
        DDSREM_CONFIG_DIR=/etc/DDSRem
    fi

    HOSTS_FILE_PATH=/etc/hosts

}

function TODO() {
    WARN "此功能未完成，请耐心等待开发者开发"
}

function show_disk_mount() {

    df -h | grep -E -v "Avail|loop|boot|overlay|tmpfs|proc" | sort -nr -k 4

}

function judgment_container() {

    if docker container inspect "${1}" > /dev/null 2>&1; then
        echo -e "${Green}已安装${Font}"
    else
        echo -e "${Red}未安装${Font}"
    fi

}

function container_update() {

    if ! docker inspect containrrr/watchtower:latest > /dev/null 2>&1; then
        if docker pull containrrr/watchtower:latest; then
            INFO "镜像拉取成功！"
            REMOVE_WATCHTOWER_IMAGE=true
        else
            ERROR "镜像拉取失败！"
            exit 1
        fi
    fi

    CURRENT_WATCHTOWER=$(docker ps --format '{{.Names}}' --filter ancestor=containrrr/watchtower | sed ':a;N;$!ba;s/\n/ /g')

    if [ -n "${CURRENT_WATCHTOWER}" ]; then
        docker stop "${CURRENT_WATCHTOWER}"
    fi

    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        containrrr/watchtower:latest \
        --run-once \
        --cleanup \
        "${@}"

    if [ "${REMOVE_WATCHTOWER_IMAGE}" == "true" ]; then
        docker rmi containrrr/watchtower:latest
    fi

    if [ -n "${CURRENT_WATCHTOWER}" ]; then
        docker start "${CURRENT_WATCHTOWER}"
    fi

    INFO "${*} 更新成功"

}

function get_config_dir() {

    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
        INFO "已读取小雅Alist配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 /etc/xiaoya ）"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/xiaoya"
        touch ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt
    fi
    if [ -d "${CONFIG_DIR}" ]; then
        # 将所有小雅配置文件修正成 linux 格式
        find ${CONFIG_DIR} -type f -name "*.txt" -exec sed -i "s/\r$//g" {} \;
        # 设置权限
        chmod -R 777 ${CONFIG_DIR}
    fi

}

function get_media_dir() {

    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
        XIAOYA_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
        if [ -s "${XIAOYA_CONFIG_DIR}/emby_config.txt" ]; then
            source "${XIAOYA_CONFIG_DIR}/emby_config.txt"
            echo "${media_dir}" > ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt
            INFO "媒体库目录通过 emby_config.txt 获取"
        fi
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt ]; then
        OLD_MEDIA_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt)
        INFO "已读取媒体库目录：${OLD_MEDIA_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -erp "MEDIA_DIR:" MEDIA_DIR
        [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR=${OLD_MEDIA_DIR}
        echo "${MEDIA_DIR}" > ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt
    else
        INFO "请输入媒体库目录（默认 /opt/media ）"
        read -erp "MEDIA_DIR:" MEDIA_DIR
        [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR="/opt/media"
        touch ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt
        echo "${MEDIA_DIR}" > ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt
    fi

}

function install_xiaoya_alist() {

    get_config_dir

    if [ ! -d "${CONFIG_DIR}" ]; then
        mkdir -p "${CONFIG_DIR}"
    else
        if [ -d "${CONFIG_DIR}"/mytoken.txt ]; then
            rm -rf "${CONFIG_DIR}"/mytoken.txt
        fi
    fi

    if [ ! -f "${CONFIG_DIR}/mytoken.txt" ]; then
        touch ${CONFIG_DIR}/mytoken.txt
    fi
    if [ ! -f "${CONFIG_DIR}/myopentoken.txt" ]; then
        touch ${CONFIG_DIR}/myopentoken.txt
    fi
    if [ ! -f "${CONFIG_DIR}/temp_transfer_folder_id.txt" ]; then
        touch ${CONFIG_DIR}/temp_transfer_folder_id.txt
    fi

    mytokenfilesize=$(cat "${CONFIG_DIR}"/mytoken.txt)
    mytokenstringsize=${#mytokenfilesize}
    if [ "$mytokenstringsize" -le 31 ]; then
        INFO "输入你的阿里云盘 Token（32位长）"
        read -erp "TOKEN:" token
        token_len=${#token}
        if [ "$token_len" -ne 32 ]; then
            ERROR "长度不对,阿里云盘 Token是32位长"
            ERROR "安装停止，请参考指南配置文件: https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f"
            exit 1
        else
            echo "$token" > "${CONFIG_DIR}"/mytoken.txt
        fi
    fi

    myopentokenfilesize=$(cat "${CONFIG_DIR}"/myopentoken.txt)
    myopentokenstringsize=${#myopentokenfilesize}
    if [ "$myopentokenstringsize" -le 279 ]; then
        INFO "输入你的阿里云盘 Open Token（280位长或者335位长）"
        read -erp "OPENTOKEN:" opentoken
        opentoken_len=${#opentoken}
        if [[ "$opentoken_len" -ne 280 ]] && [[ "$opentoken_len" -ne 335 ]]; then
            ERROR "长度不对,阿里云盘 Open Token是280位长或者335位"
            ERROR "安装停止，请参考指南配置文件: https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f"
            exit 1
        else
            echo "$opentoken" > "${CONFIG_DIR}"/myopentoken.txt
        fi
    fi

    folderidfilesize=$(cat "${CONFIG_DIR}"/temp_transfer_folder_id.txt)
    folderidstringsize=${#folderidfilesize}
    if [ "$folderidstringsize" -le 39 ]; then
        INFO "输入你的阿里云盘转存目录folder id"
        read -erp "FOLDERID:" folderid
        folder_id_len=${#folderid}
        if [ "$folder_id_len" -ne 40 ]; then
            ERROR "长度不对,阿里云盘 folder id是40位长"
            ERROR "安装停止，请参考指南配置文件: https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f"
            exit 1
        else
            echo "$folderid" > "${CONFIG_DIR}"/temp_transfer_folder_id.txt
        fi
    fi

    if command -v ifconfig > /dev/null 2>&1; then
        localip=$(ifconfig -a | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1)
    else
        localip=$(ip address | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1 | cut -f1 -d"/")
    fi
    INFO "本地IP：${localip}"

    INFO "是否使用host网络模式 [Y/n]（默认 n 不使用）"
    read -erp "NET_MODE:" NET_MODE
    [[ -z "${NET_MODE}" ]] && NET_MODE="n"
    if [[ ${NET_MODE} == [Yy] ]]; then
        if [ ! -s "${CONFIG_DIR}"/docker_address.txt ]; then
            echo "http://$localip:5678" > "${CONFIG_DIR}"/docker_address.txt
        fi
        if docker pull xiaoyaliu/alist:hostmode; then
            INFO "镜像拉取成功！"
        else
            ERROR "镜像拉取失败！"
            exit 1
        fi
        if [[ -f ${CONFIG_DIR}/proxy.txt ]] && [[ -s ${CONFIG_DIR}/proxy.txt ]]; then
            proxy_url=$(head -n1 "${CONFIG_DIR}"/proxy.txt)
            docker run -itd \
                --env HTTP_PROXY="$proxy_url" \
                --env HTTPS_PROXY="$proxy_url" \
                --env no_proxy="*.aliyundrive.com" \
                --network=host \
                -v "${CONFIG_DIR}:/data" \
                --restart=always \
                --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" \
                xiaoyaliu/alist:hostmode
        else
            docker run -itd \
                --network=host \
                -v "${CONFIG_DIR}:/data" \
                --restart=always \
                --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" \
                xiaoyaliu/alist:hostmode
        fi
    fi
    if [[ ${NET_MODE} == [Nn] ]]; then
        if [ ! -s "${CONFIG_DIR}"/docker_address.txt ]; then
            echo "http://$localip:5678" > "${CONFIG_DIR}"/docker_address.txt
        fi
        if docker pull xiaoyaliu/alist:latest; then
            INFO "镜像拉取成功！"
        else
            ERROR "镜像拉取失败！"
            exit 1
        fi
        if [[ -f ${CONFIG_DIR}/proxy.txt ]] && [[ -s ${CONFIG_DIR}/proxy.txt ]]; then
            proxy_url=$(head -n1 "${CONFIG_DIR}"/proxy.txt)
            docker run -itd \
                -p 5678:80 \
                -p 2345:2345 \
                -p 2346:2346 \
                --env HTTP_PROXY="$proxy_url" \
                --env HTTPS_PROXY="$proxy_url" \
                --env no_proxy="*.aliyundrive.com" \
                -v "${CONFIG_DIR}:/data" \
                --restart=always \
                --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" \
                xiaoyaliu/alist:latest
        else
            docker run -itd \
                -p 5678:80 \
                -p 2345:2345 \
                -p 2346:2346 \
                -v "${CONFIG_DIR}:/data" \
                --restart=always \
                --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" \
                xiaoyaliu/alist:latest
        fi
    fi
    INFO "安装完成！"

}

function update_xiaoya_alist() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新小雅Alist${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"

}

function uninstall_xiaoya_alist() {

    INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
    read -erp "Clean config:" CLEAN_CONFIG
    [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅Alist${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
    if docker inspect xiaoyaliu/alist:latest > /dev/null 2>&1; then
        docker rmi xiaoyaliu/alist:latest
    elif docker inspect xiaoyaliu/alist:hostmode > /dev/null 2>&1; then
        docker rmi xiaoyaliu/alist:hostmode
    fi
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
            for file in "${OLD_CONFIG_DIR}/mycheckintoken.txt" "${OLD_CONFIG_DIR}/mycmd.txt" "${OLD_CONFIG_DIR}/myruntime.txt"; do
                if [ -f "$file" ]; then
                    mv -f "$file" "/tmp/$(basename "$file")"
                fi
            done
            rm -rf \
                ${OLD_CONFIG_DIR}/*.txt \
                ${OLD_CONFIG_DIR}/*.m3u \
                ${OLD_CONFIG_DIR}/*.m3u8
            if [ -d "${OLD_CONFIG_DIR}/xiaoya_backup" ]; then
                rm -rf ${OLD_CONFIG_DIR}/xiaoya_backup
            fi
            for file in /tmp/mycheckintoken.txt /tmp/mycmd.txt /tmp/myruntime.txt; do
                if [ -f "$file" ]; then
                    mv -f "$file" "${OLD_CONFIG_DIR}/$(basename "$file")"
                fi
            done
        fi
    fi
    INFO "小雅Alist卸载成功！"
}

function main_xiaoya_alist() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Alist${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-4]:" num
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

function get_docker0_url() {

    if command -v ifconfig > /dev/null 2>&1; then
        docker0=$(ifconfig docker0 | awk '/inet / {print $2}' | sed 's/addr://')
    else
        docker0=$(ip addr show docker0 | awk '/inet / {print $2}' | cut -d '/' -f 1)
    fi

    if [ -n "$docker0" ]; then
        INFO "docker0 的 IP 地址是：$docker0"
    else
        WARN "无法获取 docker0 的 IP 地址！"
        docker0=$(ip address | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1 | cut -f1 -d"/")
        INFO "尝试使用本地IP：${docker0}"
    fi

}

function test_xiaoya_status() {

    get_docker0_url

    INFO "测试xiaoya的联通性..."
    if curl -siL http://127.0.0.1:5678/d/README.md | grep -v 302 | grep "x-oss-"; then
        xiaoya_addr="http://127.0.0.1:5678"
    elif curl -siL http://${docker0}:5678/d/README.md | grep -v 302 | grep "x-oss-"; then
        xiaoya_addr="http://${docker0}:5678"
    else
        if [ -s ${CONFIG_DIR}/docker_address.txt ]; then
            docker_address=$(head -n1 ${CONFIG_DIR}/docker_address.txt)
            if curl -siL ${docker_address}/d/README.md | grep -v 302 | grep "x-oss-"; then
                xiaoya_addr=${docker_address}
            else
                __xiaoya_connectivity_detection=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt)
                if [ "${__xiaoya_connectivity_detection}" == "false" ]; then
                    xiaoya_addr=${docker_address}
                    WARN "您已设置跳过小雅连通性检测"
                else
                    ERROR "请检查xiaoya是否正常运行后再试"
                    ERROR "小雅日志如下："
                    docker logs --tail 8 "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
                    exit 1
                fi
            fi
        else
            ERROR "请先配置 ${CONFIG_DIR}/docker_address.txt 后重试"
            exit 1
        fi
    fi

    INFO "连接小雅地址为 ${xiaoya_addr}"

}

function test_disk_capacity() {

    if [ ! -d "${MEDIA_DIR}" ]; then
        mkdir -p "${MEDIA_DIR}"
    fi

    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))

    __disk_capacity_detection=$(cat ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt)
    if [ "${__disk_capacity_detection}" == "false" ]; then
        WARN "您已设置跳过磁盘容量检测"
        INFO "磁盘容量：${free_size_G}G"
    else
        if [ "$free_size" -le 63886080 ]; then
            ERROR "空间剩余容量不够：${free_size_G}G 小于最低要求140G"
            exit 1
        else
            INFO "磁盘容量：${free_size_G}G"
        fi
    fi

}

function pull_run_glue() {

    if docker inspect xiaoyaliu/glue:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/glue:latest | cut -f2 -d:)
        remote_sha=$(curl -s "https://hub.docker.com/v2/repositories/xiaoyaliu/glue/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ ! "$local_sha" == "$remote_sha" ]; then
            docker rmi xiaoyaliu/glue:latest
            if docker pull xiaoyaliu/glue:latest; then
                INFO "镜像拉取成功！"
            else
                ERROR "镜像拉取失败！"
                exit 1
            fi
        fi
    else
        if docker pull xiaoyaliu/glue:latest; then
            INFO "镜像拉取成功！"
        else
            ERROR "镜像拉取失败！"
            exit 1
        fi
    fi

    if [ -n "${extra_parameters}" ]; then
        docker run -it \
            --security-opt seccomp=unconfined \
            --rm \
            --net=host \
            -v "${MEDIA_DIR}:/media" \
            -v "${CONFIG_DIR}:/etc/xiaoya" \
            ${extra_parameters} \
            -e LANG=C.UTF-8 \
            xiaoyaliu/glue:latest \
            "${@}"
    else
        docker run -it \
            --security-opt seccomp=unconfined \
            --rm \
            --net=host \
            -v "${MEDIA_DIR}:/media" \
            -v "${CONFIG_DIR}:/etc/xiaoya" \
            -e LANG=C.UTF-8 \
            xiaoyaliu/glue:latest \
            "${@}"
    fi

}

function pull_run_ddsderek_glue() {

    if docker inspect ddsderek/xiaoya-glue:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' ddsderek/xiaoya-glue:latest | cut -f2 -d:)
        remote_sha=$(curl -s "https://hub.docker.com/v2/repositories/ddsderek/xiaoya-glue/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ ! "$local_sha" == "$remote_sha" ]; then
            docker rmi ddsderek/xiaoya-glue:latest
        fi
    fi

    if docker pull ddsderek/xiaoya-glue:latest; then
        INFO "镜像拉取成功！"
    else
        ERROR "镜像拉取失败！"
        exit 1
    fi

    if [ -n "${extra_parameters}" ]; then
        docker run -it \
            --security-opt seccomp=unconfined \
            --rm \
            --net=host \
            -v "${MEDIA_DIR}:/media" \
            -v "${CONFIG_DIR}:/etc/xiaoya" \
            ${extra_parameters} \
            -e LANG=C.UTF-8 \
            ddsderek/xiaoya-glue:latest \
            "${@}"
    else
        docker run -it \
            --security-opt seccomp=unconfined \
            --rm \
            --net=host \
            -v "${MEDIA_DIR}:/media" \
            -v "${CONFIG_DIR}:/etc/xiaoya" \
            -e LANG=C.UTF-8 \
            ddsderek/xiaoya-glue:latest \
            "${@}"
    fi

}

function set_emby_server_infuse_api_key() {

    get_docker0_url

    echo "http://$docker0:6908" > "${CONFIG_DIR}"/emby_server.txt

    if [ ! -f "${CONFIG_DIR}"/infuse_api_key.txt ]; then
        echo "e825ed6f7f8f44ffa0563cddaddce14d" > "${CONFIG_DIR}"/infuse_api_key.txt
    fi

}

function unzip_xiaoya_all_emby() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}"/temp
    rm -rf "${MEDIA_DIR}"/config

    test_disk_capacity

    mkdir -p "${MEDIA_DIR}"/xiaoya
    mkdir -p "${MEDIA_DIR}"/config
    chmod 755 "${MEDIA_DIR}"
    chown root:root "${MEDIA_DIR}"

    INFO "开始解压..."

    pull_run_glue "/unzip.sh" "$xiaoya_addr"

    set_emby_server_infuse_api_key

    INFO "设置目录权限..."
    INFO "这可能需要一定时间，请耐心等待！"
    chmod -R 777 "${MEDIA_DIR}"

    INFO "解压完成！"

}

function unzip_xiaoya_emby() {

    get_config_dir

    get_media_dir

    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))
    INFO "磁盘容量：${free_size_G}G"

    chmod 777 "${MEDIA_DIR}"
    chown root:root "${MEDIA_DIR}"

    INFO "开始解压 ${MEDIA_DIR}/temp/${1} ..."

    if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
        ERROR "存在 ${MEDIA_DIR}/temp/${1}.aria2 文件，文件不完整！"
        exit 1
    fi

    start_time1=$(date +%s)

    if [ "${1}" == "config.mp4" ]; then
        extra_parameters="--workdir=/media"

        mkdir -p "${MEDIA_DIR}"/config

        config_size=$(du -k ${MEDIA_DIR}/temp/config.mp4 | cut -f1)
        if [[ "$config_size" -le 3200000 ]]; then
            ERROR "config.mp4 下载不完整，文件大小(in KB):$config_size 小于预期"
            exit 1
        else
            INFO "config.mp4 文件大小验证正常"
            pull_run_glue 7z x -aoa -mmt=16 temp/config.mp4
        fi

        INFO "设置目录权限..."
        chmod 777 "${MEDIA_DIR}"/config
    elif [ "${1}" == "all.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        all_size=$(du -k ${MEDIA_DIR}/temp/all.mp4 | cut -f1)
        if [[ "$all_size" -le 30000000 ]]; then
            ERROR "all.mp4 下载不完整，文件大小(in KB):$all_size 小于预期"
            exit 1
        else
            INFO "all.mp4 文件大小验证正常"
            pull_run_glue 7z x -aoa -mmt=16 /media/temp/all.mp4
        fi

        INFO "设置目录权限..."
        chmod 777 "${MEDIA_DIR}"/xiaoya
    elif [ "${1}" == "pikpak.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        pikpak_size=$(du -k ${MEDIA_DIR}/temp/pikpak.mp4 | cut -f1)
        if [[ "$pikpak_size" -le 14000000 ]]; then
            ERROR "pikpak.mp4 下载不完整，文件大小(in KB):$pikpak_size 小于预期"
            exit 1
        else
            INFO "pikpak.mp4 文件大小验证正常"
            pull_run_glue 7z x -aoa -mmt=16 /media/temp/pikpak.mp4
        fi

        INFO "设置目录权限..."
        chmod 777 "${MEDIA_DIR}"/xiaoya
    fi

    end_time1=$(date +%s)
    total_time1=$((end_time1 - start_time1))
    total_time1=$((total_time1 / 60))
    INFO "解压执行时间：$total_time1 分钟"

    INFO "解压完成！"

}

function unzip_appoint_xiaoya_emby() {

    get_config_dir

    get_media_dir

    if [ "${1}" == "all.mp4" ]; then
        INFO "请选择要解压的压缩包目录 [ 1:动漫 | 2:每日更新 | 3:电影 | 4:电视剧 | 5:纪录片 | 6:纪录片（已刮削）| 7:综艺 ]"
        valid_choice=false
        while [ "$valid_choice" = false ]; do
            read -erp "请输入数字 [1-7]:" choice
            for i in {1..7}; do
                if [ "$choice" = "$i" ]; then
                    valid_choice=true
                    break
                fi
            done
            if [ "$valid_choice" = false ]; then
                ERROR "请输入正确数字 [1-7]"
            fi
        done
        case $choice in
        1)
            UNZIP_FOLD=动漫
            ;;
        2)
            UNZIP_FOLD=每日更新
            ;;
        3)
            UNZIP_FOLD=电影
            ;;
        4)
            UNZIP_FOLD=电视剧
            ;;
        5)
            UNZIP_FOLD=纪录片
            ;;
        6)
            UNZIP_FOLD=纪录片（已刮削）
            ;;
        7)
            UNZIP_FOLD=综艺
            ;;
        esac
    else
        ERROR "此文件暂时不支持解压指定元数据！"
    fi

    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))
    INFO "磁盘容量：${free_size_G}G"

    chmod 777 "${MEDIA_DIR}"
    chown root:root "${MEDIA_DIR}"

    INFO "开始解压 ${MEDIA_DIR}/temp/${1} ${UNZIP_FOLD} ..."

    if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
        ERROR "存在 ${MEDIA_DIR}/temp/${1}.aria2 文件，文件不完整！"
        exit 1
    fi

    start_time1=$(date +%s)

    if [ "${1}" == "all.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        all_size=$(du -k ${MEDIA_DIR}/temp/all.mp4 | cut -f1)
        if [[ "$all_size" -le 30000000 ]]; then
            ERROR "all.mp4 下载不完整，文件大小(in KB):$all_size 小于预期"
            exit 1
        else
            INFO "all.mp4 文件大小验证正常"
            pull_run_glue 7z x -aoa -mmt=16 /media/temp/all.mp4 ${UNZIP_FOLD}/* -o/media/xiaoya
        fi

        INFO "设置目录权限..."
        chmod 777 "${MEDIA_DIR}"/xiaoya
    else
        ERROR "此文件暂时不支持解压指定元数据！"
    fi

    end_time1=$(date +%s)
    total_time1=$((end_time1 - start_time1))
    total_time1=$((total_time1 / 60))
    INFO "解压执行时间：$total_time1 分钟"

    INFO "解压完成！"

}

function download_xiaoya_emby() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}"/temp
    chown 0:0 "${MEDIA_DIR}"/temp
    chmod 777 "${MEDIA_DIR}"/temp
    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))
    INFO "磁盘容量：${free_size_G}G"

    if [ -f "${MEDIA_DIR}/temp/${1}" ]; then
        INFO "清理旧 ${1} 中..."
        rm -f ${MEDIA_DIR}/temp/${1}
        if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
            rm -rf ${MEDIA_DIR}/temp/${1}.aria2
        fi
    fi

    INFO "开始下载 ${1} ..."
    INFO "下载路径：${MEDIA_DIR}/temp/${1}"

    extra_parameters="--workdir=/media/temp"

    if pull_run_glue aria2c -o "${1}" --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${xiaoya_addr}/d/元数据/${1}"; then
        if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/${1}.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "${1} 下载成功！"
        fi
    else
        ERROR "${1} 下载失败！"
        exit 1
    fi

    INFO "设置目录权限..."
    chmod 777 "${MEDIA_DIR}"/temp/"${1}"
    chown 0:0 "${MEDIA_DIR}"/temp/"${1}"

    INFO "下载完成！"

}

function download_wget_xiaoya_emby() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}"/temp
    chown 0:0 "${MEDIA_DIR}"/temp
    chmod 777 "${MEDIA_DIR}"/temp
    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))
    INFO "磁盘容量：${free_size_G}G"

    if [ -f "${MEDIA_DIR}/temp/${1}" ]; then
        INFO "清理旧 ${1} 中..."
        rm -f ${MEDIA_DIR}/temp/${1}
        if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
            rm -rf ${MEDIA_DIR}/temp/${1}.aria2
        fi
    fi

    INFO "开始下载 ${1} ..."
    INFO "下载路径：${MEDIA_DIR}/temp/${1}"

    extra_parameters="--workdir=/media/temp"

    if pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/${1}"; then
        if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/${1}.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "${1} 下载成功！"
        fi
    else
        ERROR "${1} 下载失败！"
        exit 1
    fi

    INFO "设置目录权限..."
    chmod 777 "${MEDIA_DIR}"/temp/"${1}"
    chown 0:0 "${MEDIA_DIR}"/temp/"${1}"

    INFO "下载完成！"

}

function download_unzip_xiaoya_all_emby() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}/temp"
    rm -rf "${MEDIA_DIR}/config"

    test_disk_capacity

    mkdir -p "${MEDIA_DIR}/xiaoya"
    mkdir -p "${MEDIA_DIR}/config"
    chmod 755 "${MEDIA_DIR}"
    chown root:root "${MEDIA_DIR}"

    INFO "开始下载解压..."

    pull_run_glue "/update_all.sh" "$xiaoya_addr"

    set_emby_server_infuse_api_key

    INFO "设置目录权限..."
    INFO "这可能需要一定时间，请耐心等待！"
    chmod -R 777 "${MEDIA_DIR}"

    INFO "下载解压完成！"

}

function download_wget_unzip_xiaoya_all_emby() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}/temp"
    rm -rf "${MEDIA_DIR}/config"

    test_disk_capacity

    mkdir -p "${MEDIA_DIR}/xiaoya"
    mkdir -p "${MEDIA_DIR}/config"
    mkdir -p "${MEDIA_DIR}/temp"
    chown 0:0 "${MEDIA_DIR}"
    chmod 777 "${MEDIA_DIR}"

    INFO "开始下载解压..."

    extra_parameters="--workdir=/media/temp"
    if pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/config.mp4"; then
        if [ -f "${MEDIA_DIR}/temp/config.mp4.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/config.mp4.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "config.mp4 下载成功！"
        fi
    else
        ERROR "config.mp4 下载失败！"
        exit 1
    fi
    if pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/all.mp4"; then
        if [ -f "${MEDIA_DIR}/temp/all.mp4.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/all.mp4.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "all.mp4 下载成功！"
        fi
    else
        ERROR "all.mp4 下载失败！"
        exit 1
    fi
    if pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/pikpak.mp4"; then
        if [ -f "${MEDIA_DIR}/temp/pikpak.mp4.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/pikpak.mp4.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "pikpak.mp4 下载成功！"
        fi
    else
        ERROR "pikpak.mp4 下载失败！"
        exit 1
    fi

    start_time1=$(date +%s)

    config_size=$(du -k ${MEDIA_DIR}/temp/config.mp4 | cut -f1)
    if [[ "$config_size" -le 3200000 ]]; then
        ERROR "config.mp4 下载不完整，文件大小(in KB):$config_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media"
    pull_run_glue 7z x -aoa -mmt=16 temp/config.mp4

    all_size=$(du -k ${MEDIA_DIR}/temp/all.mp4 | cut -f1)
    if [[ "$all_size" -le 30000000 ]]; then
        ERROR "all.mp4 下载不完整，文件大小(in KB):$all_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media/xiaoya"
    pull_run_glue 7z x -aoa -mmt=16 /media/temp/all.mp4

    pikpak_size=$(du -k ${MEDIA_DIR}/temp/pikpak.mp4 | cut -f1)
    if [[ "$pikpak_size" -le 14000000 ]]; then
        ERROR "pikpak.mp4 下载不完整，文件大小(in KB):$pikpak_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media/xiaoya"
    pull_run_glue 7z x -aoa -mmt=16 /media/temp/pikpak.mp4

    end_time1=$(date +%s)
    total_time1=$((end_time1 - start_time1))
    total_time1=$((total_time1 / 60))
    INFO "解压执行时间：$total_time1 分钟"

    set_emby_server_infuse_api_key

    INFO "设置目录权限..."
    INFO "这可能需要一定时间，请耐心等待！"
    chmod -R 777 "${MEDIA_DIR}"

    host=$(echo $xiaoya_addr | cut -f1,2 -d:)
    INFO "刮削数据已经下载解压完成，请登入${host}:2345，用户名:xiaoya   密码:1234"

}

function main_download_unzip_xiaoya_emby() {

    __data_downloader=$(cat ${DDSREM_CONFIG_DIR}/data_downloader.txt)

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}下载/解压 元数据${Font}\n"
    echo -e "1、下载并解压 全部元数据"
    echo -e "2、解压 全部元数据"
    echo -e "3、下载 all.mp4"
    echo -e "4、解压 all.mp4"
    echo -e "5、解压 all.mp4 的指定元数据目录【非全部解压】"
    echo -e "6、下载 config.mp4"
    echo -e "7、解压 config.mp4"
    echo -e "8、下载 pikpak.mp4"
    echo -e "9、解压 pikpak.mp4"
    echo -e "10、当前下载器【aria2/wget】                  当前状态：${Green}${__data_downloader}${Font}"
    echo -e "11、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-11]:" num
    case "$num" in
    1)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_unzip_xiaoya_all_emby
        else
            download_unzip_xiaoya_all_emby
        fi
        ;;
    2)
        clear
        unzip_xiaoya_all_emby
        ;;
    3)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_xiaoya_emby "all.mp4"
        else
            download_xiaoya_emby "all.mp4"
        fi
        ;;
    4)
        clear
        unzip_xiaoya_emby "all.mp4"
        ;;
    5)
        clear
        unzip_appoint_xiaoya_emby "all.mp4"
        ;;
    6)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_xiaoya_emby "config.mp4"
        else
            download_xiaoya_emby "config.mp4"
        fi
        ;;
    7)
        clear
        unzip_xiaoya_emby "config.mp4"
        ;;
    8)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_xiaoya_emby "pikpak.mp4"
        else
            download_xiaoya_emby "pikpak.mp4"
        fi
        ;;
    9)
        clear
        unzip_xiaoya_emby "pikpak.mp4"
        ;;
    10)
        if [ "${__data_downloader}" == "wget" ]; then
            echo 'aria2' > ${DDSREM_CONFIG_DIR}/data_downloader.txt
        elif [ "${__data_downloader}" == "aria2" ]; then
            echo 'wget' > ${DDSREM_CONFIG_DIR}/data_downloader.txt
        else
            echo 'aria2' > ${DDSREM_CONFIG_DIR}/data_downloader.txt
        fi
        clear
        main_download_unzip_xiaoya_emby
        ;;
    11)
        clear
        main_xiaoya_all_emby
        ;;
    *)
        clear
        ERROR '请输入正确数字 [1-11]'
        main_download_unzip_xiaoya_emby
        ;;
    esac

}

function install_emby_embyserver() {

    cpu_arch=$(uname -m)
    INFO "开始安装Emby容器....."
    INFO "您的架构是：$cpu_arch"
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        if docker pull emby/embyserver:4.8.0.56; then
            INFO "镜像拉取成功！"
        else
            ERROR "镜像拉取失败！"
            exit 1
        fi
        if [ -n "${extra_parameters}" ]; then
            docker run -itd \
                --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
                -v "${MEDIA_DIR}/config:/config" \
                -v "${MEDIA_DIR}/xiaoya:/media" \
                -v ${NSSWITCH}:/etc/nsswitch.conf \
                --add-host="xiaoya.host:$xiaoya_host" \
                ${NET_MODE} \
                --privileged=true \
                ${extra_parameters} \
                -e UID=0 \
                -e GID=0 \
                --restart=always \
                emby/embyserver:4.8.0.56
        else
            docker run -itd \
                --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
                -v "${MEDIA_DIR}/config:/config" \
                -v "${MEDIA_DIR}/xiaoya:/media" \
                -v ${NSSWITCH}:/etc/nsswitch.conf \
                --add-host="xiaoya.host:$xiaoya_host" \
                ${NET_MODE} \
                --privileged=true \
                -e UID=0 \
                -e GID=0 \
                --restart=always \
                emby/embyserver:4.8.0.56
        fi
        ;;
    "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        if docker pull emby/embyserver_arm64v8:4.8.0.56; then
            INFO "镜像拉取成功！"
        else
            ERROR "镜像拉取失败！"
            exit 1
        fi
        if [ -n "${extra_parameters}" ]; then
            docker run -itd \
                --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
                -v "${MEDIA_DIR}/config:/config" \
                -v "${MEDIA_DIR}/xiaoya:/media" \
                -v ${NSSWITCH}:/etc/nsswitch.conf \
                --add-host="xiaoya.host:$xiaoya_host" \
                ${NET_MODE} \
                --privileged=true \
                ${extra_parameters} \
                -e UID=0 \
                -e GID=0 \
                --restart=always \
                emby/embyserver_arm64v8:4.8.0.56
        else
            docker run -itd \
                --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
                -v "${MEDIA_DIR}/config:/config" \
                -v "${MEDIA_DIR}/xiaoya:/media" \
                -v ${NSSWITCH}:/etc/nsswitch.conf \
                --add-host="xiaoya.host:$xiaoya_host" \
                ${NET_MODE} \
                --privileged=true \
                -e UID=0 \
                -e GID=0 \
                --restart=always \
                emby/embyserver_arm64v8:4.8.0.56
        fi
        ;;
    *)
        ERROR "目前只支持amd64和arm64架构，你的架构是：$cpu_arch"
        exit 1
        ;;
    esac

}

function install_amilys_embyserver() {

    cpu_arch=$(uname -m)
    INFO "开始安装Emby容器....."
    INFO "您的架构是：$cpu_arch"
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        if docker pull amilys/embyserver:4.8.0.56; then
            INFO "镜像拉取成功！"
        else
            ERROR "镜像拉取失败！"
            exit 1
        fi
        if [ -n "${extra_parameters}" ]; then
            docker run -itd \
                --name "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
                -v "${MEDIA_DIR}/config:/config" \
                -v "${MEDIA_DIR}/xiaoya:/media" \
                -v ${NSSWITCH}:/etc/nsswitch.conf \
                --add-host="xiaoya.host:$xiaoya_host" \
                ${NET_MODE} \
                ${extra_parameters} \
                -e UID=0 \
                -e GID=0 \
                --restart=always \
                amilys/embyserver:4.8.0.56
        else
            docker run -itd \
                --name "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
                -v "${MEDIA_DIR}/config:/config" \
                -v "${MEDIA_DIR}/xiaoya:/media" \
                -v ${NSSWITCH}:/etc/nsswitch.conf \
                --add-host="xiaoya.host:$xiaoya_host" \
                ${NET_MODE} \
                -e UID=0 \
                -e GID=0 \
                --restart=always \
                amilys/embyserver:4.8.0.56
        fi
        ;;
    *)
        ERROR "目前只支持amd64架构，你的架构是：$cpu_arch"
        exit 1
        ;;
    esac

}

function install_lovechen_embyserver() {

    cpu_arch=$(uname -m)
    INFO "开始安装Emby容器....."
    INFO "您的架构是：$cpu_arch"

    INFO "开始转换数据库..."

    mv ${MEDIA_DIR}/config/data/library.db ${MEDIA_DIR}/config/data/library.org.db
    if [ -f "${MEDIA_DIR}/config/data/library.db-wal" ]; then
        rm -rf ${MEDIA_DIR}/config/data/library.db-wal
    fi
    if [ -f "${MEDIA_DIR}/config/data/library.db-shm" ]; then
        rm -rf ${MEDIA_DIR}/config/data/library.db-shm
    fi
    chmod 777 ${MEDIA_DIR}/config/data/library.org.db
    curl -o ${MEDIA_DIR}/config/data/library.db https://cdn.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/emby_lovechen/library.db
    curl -o ${MEDIA_DIR}/temp.sql https://cdn.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/emby_lovechen/temp.sql
    pull_run_glue sqlite3 /media/config/data/library.db ".read /media/temp.sql"

    INFO "数据库转换成功！"
    rm -rf ${MEDIA_DIR}/temp.sql

    case $cpu_arch in
    "x86_64" | *"amd64"* | "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        if docker pull lovechen/embyserver:4.7.14.0; then
            INFO "镜像拉取成功！"
        else
            ERROR "镜像拉取失败！"
            exit 1
        fi
        if [ -n "${extra_parameters}" ]; then
            docker run -itd \
                --name "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
                -v "${MEDIA_DIR}/config:/config" \
                -v "${MEDIA_DIR}/xiaoya:/media" \
                -v ${NSSWITCH}:/etc/nsswitch.conf \
                --add-host="xiaoya.host:$xiaoya_host" \
                ${NET_MODE} \
                ${extra_parameters} \
                -e UID=0 \
                -e GID=0 \
                --restart=always \
                lovechen/embyserver:4.7.14.0
        else
            docker run -itd \
                --name "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
                -v "${MEDIA_DIR}/config:/config" \
                -v "${MEDIA_DIR}/xiaoya:/media" \
                -v ${NSSWITCH}:/etc/nsswitch.conf \
                --add-host="xiaoya.host:$xiaoya_host" \
                ${NET_MODE} \
                -e UID=0 \
                -e GID=0 \
                --restart=always \
                lovechen/embyserver:4.7.14.0
        fi
        ;;
    *)
        ERROR "目前只支持amd64和arm64架构，你的架构是：$cpu_arch"
        exit 1
        ;;
    esac

}

function choose_network_mode() {

    INFO "请选择使用的网络模式 [ 1:host | 2:bridge ]（默认 1）"
    read -erp "Net:" MODE
    [[ -z "${MODE}" ]] && MODE="1"
    if [[ ${MODE} == [1] ]]; then
        MODE=host
    elif [[ ${MODE} == [2] ]]; then
        MODE=bridge
    else
        ERROR "输入无效，请重新选择"
        choose_network_mode
    fi

    if [ "$MODE" == "host" ]; then
        NET_MODE="--net=host"
    elif [ "$MODE" == "bridge" ]; then
        NET_MODE="-p 6908:6908"
    fi

}

function choose_emby_image() {

    INFO "请选择使用的Emby镜像 [ 1:amilys/embyserver | 2:emby/embyserver | 3:lovechen/embyserver(目前不能直接同步config数据，且还存在一些已知问题未修复) ]（默认 2）"
    read -erp "IMAGE:" IMAGE
    [[ -z "${IMAGE}" ]] && IMAGE="2"
    if [[ ${IMAGE} == [1] ]]; then
        install_amilys_embyserver
    elif [[ ${IMAGE} == [2] ]]; then
        install_emby_embyserver
    elif [[ ${IMAGE} == [3] ]]; then
        install_lovechen_embyserver
    else
        ERROR "输入无效，请重新选择"
        choose_emby_image
    fi

}

function get_nsswitch_conf_path() {

    if [ -f /etc/nsswitch.conf ]; then
        NSSWITCH="/etc/nsswitch.conf"
    else
        CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
        echo -e "hosts:\tfiles dns" > ${CONFIG_DIR}/nsswitch.conf
        echo -e "networks:\tfiles" >> ${CONFIG_DIR}/nsswitch.conf
        NSSWITCH="${CONFIG_DIR}/nsswitch.conf"
    fi
    INFO "nsswitch.conf 配置文件路径：${NSSWITCH}"

}

function get_xiaoya_hosts() {

    if ! grep -q xiaoya.host ${HOSTS_FILE_PATH}; then
        if [ "$MODE" == "host" ]; then
            echo -e "127.0.0.1\txiaoya.host\n" >> ${HOSTS_FILE_PATH}
            xiaoya_host="127.0.0.1"
        fi
        if [ "$MODE" == "bridge" ]; then
            echo -e "$docker0\txiaoya.host\n" >> ${HOSTS_FILE_PATH}
            xiaoya_host="$docker0"
        fi
    else
        xiaoya_host=$(grep xiaoya.host ${HOSTS_FILE_PATH} | awk '{print $1}' | head -n1)
    fi

    XIAOYA_HOSTS_SHOW=$(grep xiaoya.host ${HOSTS_FILE_PATH})
    # if echo "${XIAOYA_HOSTS_SHOW}" | awk '
    # {
    #     split($1, ip, ".");
    #     if(length(ip) == 4 && ip[1] >= 0 && ip[1] <= 255 && ip[2] >= 0 && ip[2] <= 255 && ip[3] >= 0 && ip[3] <= 255 && ip[4] >= 0 && ip[4] <= 255 && index($2, "\t") == 0)
    #         exit 0;
    #     else
    #         exit 1;
    # }'; then
    #     INFO "hosts 文件设置正确！"
    # else
    #     WARN "hosts 文件设置错误！"
    #     INFO "是否使用脚本自动纠错（只支持单机部署自动纠错，如果小雅和全家桶不在同一台机器上，请手动修改）[Y/n]（默认 Y）"
    #     read -erp "自动纠错:" FIX_HOST_ERROR
    #     [[ -z "${FIX_HOST_ERROR}" ]] && FIX_HOST_ERROR="y"
    #     if [[ ${FIX_HOST_ERROR} == [Yy] ]]; then
    #         INFO "开始自动纠错..."
    #         sed -i '/xiaoya\.host/d' /etc/hosts
    #         get_xiaoya_hosts
    #     else
    #         exit 1
    #     fi
    # fi
    if echo "${XIAOYA_HOSTS_SHOW}" | awk '{ if($1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $2 ~ /^[^\t]+$/) exit 0; else exit 1 }'; then
        INFO "hosts 文件设置正确！"
    else
        WARN "hosts 文件设置错误！"
        INFO "是否使用脚本自动纠错（只支持单机部署自动纠错，如果小雅和全家桶不在同一台机器上，请手动修改）[Y/n]（默认 Y）"
        read -erp "自动纠错:" FIX_HOST_ERROR
        [[ -z "${FIX_HOST_ERROR}" ]] && FIX_HOST_ERROR="y"
        if [[ ${FIX_HOST_ERROR} == [Yy] ]]; then
            INFO "开始自动纠错..."
            sed -i '/xiaoya\.host/d' /etc/hosts
            get_xiaoya_hosts
        else
            exit 1
        fi
    fi

}

function install_emby_xiaoya_all_emby() {

    get_docker0_url

    if [ -f "${MEDIA_DIR}/config/config/system.xml" ]; then
        if ! grep -q 6908 ${MEDIA_DIR}/config/config/system.xml; then
            ERROR "Emby config 出错，请重新下载解压！"
            exit 1
        fi
    else
        ERROR "Emby config 出错，请重新下载解压！"
        exit 1
    fi

    XIAOYA_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
    if [ -s "${XIAOYA_CONFIG_DIR}/emby_config.txt" ]; then
        source "${XIAOYA_CONFIG_DIR}/emby_config.txt"

        if [ "${mode}" == "bridge" ]; then
            MODE=bridge
            NET_MODE="-p 6908:6908"
        elif [ "${mode}" == "host" ]; then
            MODE=host
            NET_MODE="--net=host"
        else
            choose_network_mode
        fi

        get_xiaoya_hosts

        if [ "${dev_dri}" == "yes" ]; then
            extra_parameters="--device /dev/dri:/dev/dri --privileged -e GIDLIST=0,0 -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all"
        fi

        get_nsswitch_conf_path

        if [ "${image}" == "emby" ]; then
            install_emby_embyserver
        else
            install_amilys_embyserver
        fi

    else
        choose_network_mode

        get_xiaoya_hosts

        INFO "如果需要开启Emby硬件转码请先返回主菜单开启容器运行额外参数添加 -> 72"
        container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
        if [ "${container_run_extra_parameters}" == "true" ]; then
            INFO "请输入其他参数（默认 --device /dev/dri:/dev/dri --privileged -e GIDLIST=0,0 -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all ）"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters="--device /dev/dri:/dev/dri --privileged -e GIDLIST=0,0 -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all"
        fi

        get_nsswitch_conf_path

        choose_emby_image
    fi

    set_emby_server_infuse_api_key

    start_time=$(date +%s)
    CONTAINER_NAME=$(cat "${DDSREM_CONFIG_DIR}"/container_name/xiaoya_emby_name.txt)
    TARGET_LOG_LINE_SUCCESS="All entry points have started"
    while true; do
        line=$(docker logs "$CONTAINER_NAME" 2>&1 | tail -n 10)
        echo "$line"
        if [[ "$line" == *"$TARGET_LOG_LINE_SUCCESS"* ]]; then
            break
        fi
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if ((elapsed_time >= 300)); then
            break
        fi
        sleep 3
    done

    sleep 2

    if ! curl -I -s http://$docker0:2345/ | grep -q "302"; then
        INFO "重启小雅容器中..."
        docker restart "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
    fi

    INFO "Emby安装完成！"

}

function docker_address_xiaoya_all_emby() {

    get_config_dir

    get_media_dir

    pull_run_ddsderek_glue "/docker_address.sh"

    INFO "替换DOCKER_ADDRESS完成！"

}

function install_xiaoya_notify_cron() {

    if [ ! -f ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt ]; then
        INFO "请输入Resilio-Sync配置文件目录"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        touch ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
    fi
    if [ ! -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
        get_config_dir
    fi
    if [ ! -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt ]; then
        get_media_dir
    fi

    # 配置定时任务Cron
    while true; do
        INFO "请输入您希望的同步时间"
        read -erp "注意：24小时制，格式：hh:mm，小时分钟之间用英文冒号分隔 （示例：23:45，默认：06:00）：" sync_time
        [[ -z "${sync_time}" ]] && sync_time="06:00"
        read -erp "您希望几天同步一次？（单位：天）（默认：7）" sync_day
        [[ -z "${sync_day}" ]] && sync_day="7"
        # 中文冒号纠错
        time_value=${sync_time//：/:}
        # 提取小时位
        hour=${time_value%%:*}
        # 提取分钟位
        minu=${time_value#*:}
        if [[ "$hour" -ge 0 && "$hour" -le 23 && "$minu" -ge 0 && "$minu" -le 59 ]]; then
            break
        else
            ERROR "输入错误，请重新输入。小时必须为0-23的正整数，分钟必须为0-59的正整数。"
        fi
    done

    INFO "是否开启Emby config自动同步 [Y/n]（默认 Y 开启）"
    read -erp "Auto update config:" AUTO_UPDATE_CONFIG
    [[ -z "${AUTO_UPDATE_CONFIG}" ]] && AUTO_UPDATE_CONFIG="y"
    if [[ ${AUTO_UPDATE_CONFIG} == [Yy] ]]; then
        auto_update_config=yes
    else
        auto_update_config=no
    fi

    INFO "是否开启自动同步 all 与 pikpak 元数据 [Y/n]（默认 Y 开启）"
    read -erp "Auto update all & pikpak:" AUTO_UPDATE_ALL_PIKPAK
    [[ -z "${AUTO_UPDATE_ALL_PIKPAK}" ]] && AUTO_UPDATE_ALL_PIKPAK="y"
    if [[ ${AUTO_UPDATE_ALL_PIKPAK} == [Yy] ]]; then
        auto_update_all_pikpak=yes
    else
        auto_update_all_pikpak=no
    fi

    # 组合定时任务命令
    CRON="${minu} ${hour} */${sync_day} * *   bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh)\" -s \
--auto_update_all_pikpak=${auto_update_all_pikpak} \
--auto_update_config=${auto_update_config} \
--force_update_config=no \
--media_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt) \
--config_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt) \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt) >> \
$(cat ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt)/cron.log 2>&1"
    if command -v crontab > /dev/null 2>&1; then
        crontab -l | grep -v sync_emby_config | grep -v xiaoya_notify > /tmp/cronjob.tmp
        echo -e "${CRON}" >> /tmp/cronjob.tmp
        crontab /tmp/cronjob.tmp
        INFO '已经添加下面的记录到crontab定时任务'
        INFO "${CRON}"
        rm -rf /tmp/cronjob.tmp
    elif [ -f /etc/synoinfo.conf ]; then
        # 群晖单独支持
        cp /etc/crontab /etc/crontab.bak
        INFO "已创建/etc/crontab.bak备份文件"
        sed -i '/sync_emby_config/d; /xiaoya_notify/d' /etc/crontab
        echo -e "${CRON}" >> /etc/crontab
        INFO '已经添加下面的记录到crontab定时任务'
        INFO "${CRON}"
    else
        INFO '已经添加下面的记录到crontab定时任务容器'
        INFO "${CRON}"
        if docker pull ddsderek/xiaoya-cron:latest; then
            INFO "镜像拉取成功！"
        else
            ERROR "镜像拉取失败！"
            exit 1
        fi
        CRON_PARAMETERS="--auto_update_all_pikpak=${auto_update_all_pikpak} \
--auto_update_config=${auto_update_config} \
--force_update_config=no \
--media_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt) \
--config_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt) \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
        docker run -itd \
            --name=xiaoya-cron \
            -e TZ=Asia/Shanghai \
            -e CRON="${minu} ${hour} */${sync_day} * *" \
            -e parameters="${CRON_PARAMETERS}" \
            -v "$(cat ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt):/config" \
            -v "$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt):$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt)" \
            -v "$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt):$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)" \
            -v /tmp:/tmp \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --net=host \
            --restart=always \
            ddsderek/xiaoya-cron:latest
    fi

}

function install_resilio() {

    get_media_dir

    if [ -f ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt)
        INFO "已读取Resilio-Sync配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 ${MEDIA_DIR}/resilio ）"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="${MEDIA_DIR}/resilio"
        touch ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
    fi

    INFO "请输入后台管理端口（默认 8888 ）"
    read -erp "HT_PORT:" HT_PORT
    [[ -z "${HT_PORT}" ]] && HT_PORT="8888"

    INFO "请输入同步端口（默认 55555 ）"
    read -erp "SYNC_PORT:" SYNC_PORT
    [[ -z "${SYNC_PORT}" ]] && SYNC_PORT="55555"

    INFO "resilio容器内存上限（单位：MB，默认：2048）"
    WARN "PS: 部分系统有可能不支持内存限制设置，请输入 n 取消此设置！"
    read -erp "mem_size:" mem_size
    [[ -z "${mem_size}" ]] && mem_size="2048"
    if [[ ${mem_size} == [Nn] ]]; then
        mem_set=
    else
        mem_set="-m ${mem_size}M"
    fi

    INFO "resilio日志文件大小上限（单位：MB；默认：2；设置为 0 则代表关闭日志；设置为 n 则代表取消此设置）"
    read -erp "log_size:" log_size
    [[ -z "${log_size}" ]] && log_size="2"

    if [ "${log_size}" == "0" ]; then
        log_opinion="--log-driver none"
    elif [[ ${log_size} == [Nn] ]]; then
        log_opinion=
    else
        log_opinion="--log-opt max-size=${log_size}m --log-opt max-file=1"
    fi

    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        INFO "请输入其他参数（默认 无 ）"
        read -erp "Extra parameters:" extra_parameters
    fi

    INFO "是否自动配置系统 inotify watches & instances 的数值 [Y/n]（默认 Y）"
    read -erp "inotify:" inotify_set
    [[ -z "${inotify_set}" ]] && inotify_set="y"
    if [[ ${inotify_set} == [Yy] ]]; then
        if ! grep -q "fs.inotify.max_user_watches=524288" /etc/sysctl.conf; then
            echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf
        else
            INFO "系统 inotify watches 数值已存在！"
        fi
        if ! grep -q "fs.inotify.max_user_instances=524288" /etc/sysctl.conf; then
            echo fs.inotify.max_user_instances=524288 | tee -a /etc/sysctl.conf
        else
            INFO "系统 inotify instances 数值已存在！"
        fi
        # 清除多余的inotify设置
        awk \
            '!seen[$0]++ || !/^(fs\.inotify\.max_user_instances|fs\.inotify\.max_user_watches)/' /etc/sysctl.conf > \
            /tmp/sysctl.conf.tmp && mv /tmp/sysctl.conf.tmp /etc/sysctl.conf
        sysctl -p
        INFO "系统 inotify watches & instances 数值配置成功！"
    fi

    INFO "开始安装resilio..."
    if [ ! -d "${CONFIG_DIR}" ]; then
        mkdir -p "${CONFIG_DIR}"
    fi
    if [ ! -d "${CONFIG_DIR}/downloads" ]; then
        mkdir -p "${CONFIG_DIR}/downloads"
    fi
    if docker pull linuxserver/resilio-sync:latest; then
        INFO "镜像拉取成功！"
    else
        ERROR "镜像拉取失败！"
        exit 1
    fi
    if [ -n "${extra_parameters}" ]; then
        docker run -d \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)" \
            ${mem_set} \
            ${log_opinion} \
            -e PUID=0 \
            -e PGID=0 \
            -e TZ=Asia/Shanghai \
            -p ${HT_PORT}:8888 \
            -p ${SYNC_PORT}:55555 \
            -v "${CONFIG_DIR}:/config" \
            -v "${CONFIG_DIR}/downloads:/downloads" \
            -v "${MEDIA_DIR}:/sync" \
            ${extra_parameters} \
            --restart=always \
            linuxserver/resilio-sync:latest
    else
        docker run -d \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)" \
            ${mem_set} \
            ${log_opinion} \
            -e PUID=0 \
            -e PGID=0 \
            -e TZ=Asia/Shanghai \
            -p ${HT_PORT}:8888 \
            -p ${SYNC_PORT}:55555 \
            -v "${CONFIG_DIR}:/config" \
            -v "${CONFIG_DIR}/downloads:/downloads" \
            -v "${MEDIA_DIR}:/sync" \
            --restart=always \
            linuxserver/resilio-sync:latest
    fi

    install_xiaoya_notify_cron

    INFO "安装完成！"
    INFO "请浏览器访问 ${Sky_Blue}http://IP:${HT_PORT}${Font} 进行 Resilio 设置并自行添加下面的同步密钥："
    echo -e "/每日更新/电视剧 （保存到 /sync/xiaoya/每日更新/电视剧 ）
${Sky_Blue}BHB7NOQ4IQKOWZPCLK7BIZXDGIOVRKBUL${Font}
/每日更新/电影 （保存到 /sync/xiaoya/每日更新/电影 ）
${Sky_Blue}BCFQAYSMIIDJBWJ6DB7JXLHBXUGYKEQ43${Font}
/电影/2023 （保存到 /sync/xiaoya/电影/2023 ）
${Sky_Blue}BGUXZBXWJG6J47XVU4HSNJEW4HRMZGOPL${Font}
/纪录片（已刮削） （保存到 /sync/xiaoya/纪录片（已刮削） ）
${Sky_Blue}BDBOMKR6WP7A4X55Z6BY7IA4HUQ3YO4BH${Font}
/音乐 （保存到 /sync/xiaoya/音乐 ）
${Sky_Blue}BHAYCNF5MJSGUF2RVO6XDA55X5PVBKDUB${Font}
/每日更新/动漫 （保存到 /sync/xiaoya/每日更新/动漫 ）
${Sky_Blue}BQEIV6B3DKPZWAFHO7V6QQJO2X3DOQSJ4${Font}
/每日更新/动漫剧场版 （保存到 /sync/xiaoya/每日更新/动漫剧场版 ）
${Sky_Blue}B42SOXBKLMRWHRZMCAIQZWNOBLUUH3HO3${Font}"

}

function update_resilio() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新Resilio-Sync${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)"

}

function uninstall_xiaoya_notify_cron() {

    # 清理定时同步任务
    if command -v crontab > /dev/null 2>&1; then
        crontab -l > /tmp/cronjob.tmp
        sed -i '/sync_emby_config/d; /xiaoya_notify/d' /tmp/cronjob.tmp
        crontab /tmp/cronjob.tmp
        rm -f /tmp/cronjob.tmp
    elif [ -f /etc/synoinfo.conf ]; then
        sed -i '/sync_emby_config/d; /xiaoya_notify/d' /etc/crontab
    else
        if docker container inspect xiaoya-cron > /dev/null 2>&1; then
            docker stop xiaoya-cron
            docker rm xiaoya-cron
            docker rmi ddsderek/xiaoya-cron:latest
        fi
    fi

}

function unisntall_resilio() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载 Resilio-Sync${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)"
    docker rmi linuxserver/resilio-sync:latest
    if [ -f ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt)
        rm -rf "${OLD_CONFIG_DIR}"
    fi

    uninstall_xiaoya_notify_cron

    INFO "Resilio-Sync 卸载成功！"

}

function main_resilio() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Resilio-Sync${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-4]:" num
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

function once_sync_emby_config() {

    if command -v crontab > /dev/null 2>&1; then
        COMMAND_1=$(crontab -l | grep 'xiaoya_notify' | sed 's/^.*-s//; s/>>.*$//' |
            sed 's/--auto_update_all_pikpak=yes/--auto_update_all_pikpak=no/g' |
            sed 's/--force_update_config=no/--force_update_config=yes/g')
        if [ -z "$COMMAND_1" ]; then
            get_config_dir
            get_media_dir
            COMMAND="bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh | head -n -2 && echo detection_config_update)\" -s \
--auto_update_all_pikpak=no \
--auto_update_config=yes \
--force_update_config=yes \
--media_dir=${MEDIA_DIR} \
--config_dir=${CONFIG_DIR} \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
        else
            COMMAND="bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh | head -n -2 && echo detection_config_update)\" -s ${COMMAND_1}"
        fi
    elif [ -f /etc/synoinfo.conf ]; then
        COMMAND_1=$(grep 'xiaoya_notify' /etc/crontab | sed 's/^.*-s//; s/>>.*$//' |
            sed 's/--auto_update_all_pikpak=yes/--auto_update_all_pikpak=no/g' |
            sed 's/--force_update_config=no/--force_update_config=yes/g')
        if [ -z "$COMMAND_1" ]; then
            get_config_dir
            get_media_dir
            COMMAND="bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh | head -n -2 && echo detection_config_update)\" -s \
--auto_update_all_pikpak=no \
--auto_update_config=yes \
--force_update_config=yes \
--media_dir=${MEDIA_DIR} \
--config_dir=${CONFIG_DIR} \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
        else
            COMMAND="bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh | head -n -2 && echo detection_config_update)\" -s ${COMMAND_1}"
        fi
    else
        if docker container inspect xiaoya-cron > /dev/null 2>&1; then
            # 先更新 xiaoya-cron，再运行立刻同步
            if docker pull containrrr/watchtower:latest; then
                INFO "镜像拉取成功！"
            else
                ERROR "镜像拉取失败！"
                exit 1
            fi
            docker run --rm \
                -v /var/run/docker.sock:/var/run/docker.sock \
                containrrr/watchtower:latest \
                --run-once \
                --cleanup \
                xiaoya-cron
            docker rmi containrrr/watchtower:latest
            sleep 10
            COMMAND="docker exec -it xiaoya-cron bash /app/command.sh"
        else
            get_config_dir
            get_media_dir
            COMMAND="bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh | head -n -2 && echo detection_config_update)\" -s \
--auto_update_all_pikpak=no \
--auto_update_config=yes \
--force_update_config=yes \
--media_dir=${MEDIA_DIR} \
--config_dir=${CONFIG_DIR} \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
        fi
    fi
    echo -e "${COMMAND}" > /tmp/sync_command.sh
    echo -e "${COMMAND}"

    INFO "是否前台输出运行日志 [Y/n]（默认 Y）"
    read -erp "Log out:" LOG_OUT
    [[ -z "${LOG_OUT}" ]] && LOG_OUT="y"

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始同步小雅Emby的config目录${Blue} $i ${Font}\r"
        sleep 1
    done

    echo > /tmp/sync_config.log
    # 后台运行
    bash /tmp/sync_command.sh > /tmp/sync_config.log 2>&1 &
    # 获取pid
    pid=$!
    if [[ ${LOG_OUT} == [Yy] ]]; then
        clear
        # 实时输出模式
        while ps ${pid} > /dev/null; do
            clear
            cat /tmp/sync_config.log
            sleep 4
        done
        sleep 2
        rm -f /tmp/sync_command.sh
    else
        # 后台运行模式
        clear
        INFO "Emby config同步后台运行中..."
        INFO "运行日志存于 /tmp/sync_config.log 文件内。"
        # 守护进程，最终清理运行产生的文件
        {
            while ps ${pid} > /dev/null; do sleep 4; done
            sleep 2
            rm -f /tmp/sync_command.sh
        } &
    fi

}

function judgment_xiaoya_notify_status() {

    if command -v crontab > /dev/null 2>&1; then
        if crontab -l | grep 'xiaoya_notify\|sync_emby_config' > /dev/null 2>&1; then
            echo -e "${Green}已创建${Font}"
        else
            echo -e "${Red}未创建${Font}"
        fi
    elif [ -f /etc/synoinfo.conf ]; then
        if grep 'xiaoya_notify\|sync_emby_config' /etc/crontab > /dev/null 2>&1; then
            echo -e "${Green}已创建${Font}"
        else
            echo -e "${Red}未创建${Font}"
        fi
    else
        if docker container inspect xiaoya-cron > /dev/null 2>&1; then
            echo -e "${Green}已创建${Font}"
        else
            echo -e "${Red}未创建${Font}"
        fi
    fi

}

function uninstall_xiaoya_all_emby() {

    INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
    read -erp "Clean config:" CLEAN_CONFIG
    [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅Emby全家桶${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)"
    cpu_arch=$(uname -m)
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        if docker inspect amilys/embyserver:4.8.0.56 > /dev/null 2>&1; then
            docker rmi amilys/embyserver:4.8.0.56
        elif docker inspect emby/embyserver:4.8.0.56 > /dev/null 2>&1; then
            docker rmi emby/embyserver:4.8.0.56
        fi
        ;;
    "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        docker rmi emby/embyserver_arm64v8:4.8.0.56
        ;;
    esac
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt ]; then
            OLD_MEDIA_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt)
            rm -rf "${OLD_MEDIA_DIR}"
        fi
    fi

    unisntall_resilio

    INFO "全家桶卸载成功！"

}

function main_xiaoya_all_emby() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Emby全家桶${Font}\n"
    echo -e "${Red}注意：2024年3月16日后Emby config同步定时任务更换为同步定时更新任务${Font}"
    echo -e "${Red}用户需先执行一遍 菜单27 删除旧任务，再执行一遍 菜单27 创建新任务${Font}\n"
    echo -e "1、一键安装Emby全家桶"
    echo -e "2、下载/解压 元数据"
    echo -e "3、安装Emby（可选择版本）"
    echo -e "4、替换DOCKER_ADDRESS（${Red}已弃用${Font}）"
    echo -e "5、安装/更新/卸载 Resilio-Sync                当前状态：$(judgment_container "${xiaoya_resilio_name}")"
    echo -e "6、立即同步小雅Emby config目录"
    echo -e "7、创建/删除 同步定时更新任务                 当前状态：$(judgment_xiaoya_notify_status)"
    echo -e "8、图形化编辑 emby_config.txt"
    echo -e "9、卸载Emby全家桶"
    echo -e "10、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-10]:" num
    case "$num" in
    1)
        clear
        download_unzip_xiaoya_all_emby
        install_emby_xiaoya_all_emby
        XIAOYA_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
        if [ ! -s "${XIAOYA_CONFIG_DIR}/emby_config.txt" ]; then
            install_resilio
        else
            source "${XIAOYA_CONFIG_DIR}/emby_config.txt"
            if [ "${resilio}" == "yes" ]; then
                install_resilio
            elif [ "${resilio}" == "no" ]; then
                INFO "跳过 Resilio-Sync 安装"
            else
                WARN "resilio 配置错误！默认安装 Resilio-Sync"
                install_resilio
            fi
        fi
        INFO "全家桶安装完成！ "
        ;;
    2)
        clear
        main_download_unzip_xiaoya_emby
        ;;
    3)
        clear
        get_config_dir
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
        once_sync_emby_config
        ;;
    7)
        clear
        if command -v crontab > /dev/null 2>&1; then
            if crontab -l | grep xiaoya_notify > /dev/null 2>&1; then
                for i in $(seq -w 3 -1 0); do
                    echo -en "即将删除Emby config同步定时任务${Blue} $i ${Font}\r"
                    sleep 1
                done
                uninstall_xiaoya_notify_cron
                clear
                INFO "已删除"
            else
                install_xiaoya_notify_cron
            fi
        elif [ -f /etc/synoinfo.conf ]; then
            if grep 'xiaoya_notify' /etc/crontab > /dev/null 2>&1; then
                for i in $(seq -w 3 -1 0); do
                    echo -en "即将删除Emby config同步定时任务${Blue} $i ${Font}\r"
                    sleep 1
                done
                uninstall_xiaoya_notify_cron
                clear
                INFO "已删除"
            else
                install_xiaoya_notify_cron
            fi
        else
            if docker container inspect xiaoya-cron > /dev/null 2>&1; then
                for i in $(seq -w 3 -1 0); do
                    echo -en "即将删除Emby config同步定时任务${Blue} $i ${Font}\r"
                    sleep 1
                done
                uninstall_xiaoya_notify_cron
                clear
                INFO "已删除"
            else
                install_xiaoya_notify_cron
            fi
        fi
        ;;
    8)
        clear
        get_config_dir
        bash -c "$(curl -sLk https://ddsrem.com/xiaoya/emby_config_editor.sh)" -s ${CONFIG_DIR}
        ;;
    9)
        clear
        uninstall_xiaoya_all_emby
        ;;
    10)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [1-10]'
        main_xiaoya_all_emby
        ;;
    esac

}

function install_xiaoyahelper() {

    INFO "选择模式：[3/5]（默认 3）"
    INFO "模式3: 定时运行小雅转存清理并升级小雅镜像"
    INFO "模式5: 只要产生了播放缓存一分钟内立即清理。签到和定时升级同模式3"
    read -erp "MODE:" MODE
    [[ -z "${MODE}" ]] && MODE="3"

    INFO "是否使用Telegram通知 [Y/n]（默认 n 不使用）"
    read -erp "TG:" TG
    [[ -z "${TG}" ]] && TG="n"
    if [[ ${TG} == [Yy] ]]; then
        bash -c "$(curl -s ${XIAOYAHELPER_URL} | tail -n +2)" -s "${MODE}" -tg
    fi
    if [[ ${TG} == [Nn] ]]; then
        bash -c "$(curl -s ${XIAOYAHELPER_URL} | tail -n +2)" -s "${MODE}"
    fi
    INFO "安装完成！"

}

function once_xiaoyahelper() {

    INFO "是否使用Telegram通知 [Y/n]（默认 n 不使用）"
    read -erp "TG:" TG
    [[ -z "${TG}" ]] && TG="n"
    if [[ ${TG} == [Yy] ]]; then
        bash -c "$(curl -s ${XIAOYAHELPER_URL} | tail -n +2)" -s 1 -tg
    fi
    if [[ ${TG} == [Nn] ]]; then
        bash -c "$(curl -s ${XIAOYAHELPER_URL} | tail -n +2)" -s 1
    fi

}

function uninstall_xiaoyahelper() {

    INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
    read -erp "Clean config:" CLEAN_CONFIG
    [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅助手（xiaoyahelper）${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop xiaoyakeeper
    docker rm xiaoyakeeper
    docker rmi dockerproxy.com/library/alpine:3.18.2

    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
            for file in "${OLD_CONFIG_DIR}/mycheckintoken.txt" "${OLD_CONFIG_DIR}/mycmd.txt" "${OLD_CONFIG_DIR}/myruntime.txt"; do
                if [ -f "$file" ]; then
                    rm -f "$file"
                fi
            done
        fi
        rm -f ${OLD_CONFIG_DIR}/*json
    fi

    INFO "小雅助手（xiaoyahelper）卸载成功！"

}

function main_xiaoyahelper() {

    XIAOYAHELPER_URL="https://xiaoyahelper.ddsrem.com/aliyun_clear.sh"

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅助手（xiaoyahelper）${Font}\n"
    echo -e "1、安装/更新"
    echo -e "2、一次性运行"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-4]:" num
    case "$num" in
    1)
        clear
        install_xiaoyahelper
        ;;
    2)
        clear
        once_xiaoyahelper
        ;;
    3)
        clear
        uninstall_xiaoyahelper
        ;;
    4)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [1-4]'
        main_xiaoyahelper
        ;;
    esac

}

function install_xiaoya_alist_tvbox() {

    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt)
        INFO "已读取小雅Alist-TVBox配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 /etc/xiaoya ）"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/xiaoya"
        touch ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt
    fi

    INFO "请输入Alist端口（默认 5344 ）"
    read -erp "ALIST_PORT:" ALIST_PORT
    [[ -z "${ALIST_PORT}" ]] && ALIST_PORT="5344"

    INFO "请输入后台管理端口（默认 4567 ）"
    read -erp "HT_PORT:" HT_PORT
    [[ -z "${HT_PORT}" ]] && HT_PORT="4567"

    INFO "请输入内存限制（默认 -Xmx512M ）"
    read -erp "MEM_OPT:" MEM_OPT
    [[ -z "${MEM_OPT}" ]] && MEM_OPT="-Xmx512M"

    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        INFO "请输入其他参数（默认 无 ）"
        read -erp "Extra parameters:" extra_parameters
    fi

    if ls ${CONFIG_DIR}/*.txt 1> /dev/null 2>&1; then
        INFO "备份小雅配置数据中..."
        mkdir -p ${CONFIG_DIR}/xiaoya_backup
        cp -rf ${CONFIG_DIR}/*.txt ${CONFIG_DIR}/xiaoya_backup
        INFO "完成备份小雅配置数据！"
        INFO "备份数据路径：${CONFIG_DIR}/xiaoya_backup"
    fi

    if docker pull haroldli/xiaoya-tvbox:latest; then
        INFO "镜像拉取成功！"
    else
        ERROR "镜像拉取失败！"
        exit 1
    fi

    if [ -n "${extra_parameters}" ]; then
        docker run -itd \
            -p "${HT_PORT}":4567 \
            -p "${ALIST_PORT}":80 \
            -e ALIST_PORT="${ALIST_PORT}" \
            -e MEM_OPT="${MEM_OPT}" \
            -v "${CONFIG_DIR}:/data" \
            ${extra_parameters} \
            --restart=always \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)" \
            haroldli/xiaoya-tvbox:latest
    else
        docker run -itd \
            -p "${HT_PORT}":4567 \
            -p "${ALIST_PORT}":80 \
            -e ALIST_PORT="${ALIST_PORT}" \
            -e MEM_OPT="${MEM_OPT}" \
            -v "${CONFIG_DIR}:/data" \
            --restart=always \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)" \
            haroldli/xiaoya-tvbox:latest
    fi

    INFO "安装完成！"

}

function update_xiaoya_alist_tvbox() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新小雅Alist-TVBox${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)"

}

function uninstall_xiaoya_alist_tvbox() {

    INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
    read -erp "Clean config:" CLEAN_CONFIG
    [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅Alist-TVBox${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)"
    docker rmi haroldli/xiaoya-tvbox:latest
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt)
            for dir in "${OLD_CONFIG_DIR}"/*/; do
                rm -rf "$dir"
            done
            rm -rf ${OLD_CONFIG_DIR}/*.db
        fi
    fi
    INFO "小雅Alist-TVBox卸载成功！"

}

function main_xiaoya_alist_tvbox() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Alist-TVBox${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-4]:" num
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

function install_onelist() {

    if [ -f ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt)
        INFO "已读取Onelist配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 /etc/onelist ）"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/onelist"
        touch ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt
    fi

    INFO "请输入后台管理端口（默认 5245 ）"
    read -erp "HT_PORT:" HT_PORT
    [[ -z "${HT_PORT}" ]] && HT_PORT="5245"

    if docker pull msterzhang/onelist:latest; then
        INFO "镜像拉取成功！"
    else
        ERROR "镜像拉取失败！"
        exit 1
    fi

    docker run -itd \
        -p "${HT_PORT}":5245 \
        -e PUID=0 \
        -e PGID=0 \
        -e UMASK=022 \
        -e TZ=Asia/Shanghai \
        -v "${CONFIG_DIR}:/config" \
        --restart=always \
        --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt)" \
        msterzhang/onelist:latest

    INFO "安装完成！"

}

function update_onelist() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新Onelist${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt)"

}

function uninstall_onelist() {

    INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
    read -erp "Clean config:" CLEAN_CONFIG
    [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载 Onelist${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt)"
    docker rmi msterzhang/onelist:latest
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/onelist_config_dir.txt)
            rm -rf "${OLD_CONFIG_DIR}"
        fi
    fi
    INFO "Onelist 卸载成功！"

}

function main_onelist() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Onelist${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-4]:" num
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

function install_portainer() {

    if [ -f ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt)
        INFO "已读取Portainer配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 /etc/portainer ）"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/portainer"
        touch ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt
    fi

    INFO "请输入后台HTTP管理端口（默认 9000 ）"
    read -erp "HTTP_PORT:" HTTP_PORT
    [[ -z "${HTTP_PORT}" ]] && HTTP_PORT="9000"

    INFO "请输入后台HTTP管理端口（默认 9443 ）"
    read -erp "HTTPS_PORT:" HTTPS_PORT
    [[ -z "${HTTPS_PORT}" ]] && HTTPS_PORT="9443"

    INFO "请输入镜像TAG（默认 latest ）"
    read -erp "TAG:" TAG
    [[ -z "${TAG}" ]] && TAG="latest"

    if docker pull portainer/portainer-ce:${TAG}; then
        INFO "镜像拉取成功！"
    else
        ERROR "镜像拉取失败！"
        exit 1
    fi

    docker run -itd \
        -p "${HTTPS_PORT}":9443 \
        -p "${HTTP_PORT}":9000 \
        --name "$(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt)" \
        -e TZ=Asia/Shanghai \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v "${CONFIG_DIR}:/data" \
        portainer/portainer-ce:"${TAG}"

    INFO "安装完成！"

}

function update_portainer() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新Portainer${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update "$(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt)"

}

function uninstall_portainer() {

    INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
    read -erp "Clean config:" CLEAN_CONFIG
    [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载 Portainer${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt)"
    docker image rm "$(docker image ls --filter=reference="portainer/portainer-ce" -q)"
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/portainer_config_dir.txt)
            rm -rf "${OLD_CONFIG_DIR}"
        fi
    fi
    INFO "Portainer 卸载成功！"

}

function main_portainer() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Portainer${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-4]:" num
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
        main_other_tools
        ;;
    *)
        clear
        ERROR '请输入正确数字 [1-4]'
        main_portainer
        ;;
    esac

}

function install_auto_symlink() {

    if [ -f ${DDSREM_CONFIG_DIR}/auto_symlink_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/auto_symlink_config_dir.txt)
        INFO "已读取Auto_Symlink配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/auto_symlink_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 /etc/auto_symlink ）"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="/etc/auto_symlink"
        touch ${DDSREM_CONFIG_DIR}/auto_symlink_config_dir.txt
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/auto_symlink_config_dir.txt
    fi

    INFO "请输入后台管理端口（默认 8095 ）"
    read -erp "PORT:" HTTP_PORT
    [[ -z "${PORT}" ]] && PORT="8095"

    INFO "请输入挂载目录（可设置多个）（PS：-v /media:/media）"
    read -erp "Volumes:" volumes

    if docker pull shenxianmq/auto_symlink:latest; then
        INFO "镜像拉取成功！"
    else
        ERROR "镜像拉取失败！"
        exit 1
    fi

    if [ -n "${volumes}" ]; then
        docker run -d \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt)" \
            -e TZ=Asia/Shanghai \
            -v "${CONFIG_DIR}:/app/config" \
            -p "${PORT}":8095 \
            --restart always \
            --log-opt max-size=10m \
            --log-opt max-file=3 \
            ${volumes} \
            shenxianmq/auto_symlink:latest
    else
        docker run -d \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt)" \
            -e TZ=Asia/Shanghai \
            -v "${CONFIG_DIR}:/app/config" \
            -p "${PORT}":8095 \
            --restart always \
            --log-opt max-size=10m \
            --log-opt max-file=3 \
            shenxianmq/auto_symlink:latest
    fi

    INFO "安装完成！"

}

function update_auto_symlink() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新Auto_Symlink${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update "$(cat ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt)"

}

function uninstall_auto_symlink() {

    INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
    read -erp "Clean config:" CLEAN_CONFIG
    [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载 Auto_Symlink${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt)"
    docker image rm shenxianmq/auto_symlink:latest
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/auto_symlink_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/auto_symlink_config_dir.txt)
            rm -rf "${OLD_CONFIG_DIR}"
        fi
    fi
    INFO "Auto_Symlink 卸载成功！"

}

function main_auto_symlink() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Auto_Symlink${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-4]:" num
    case "$num" in
    1)
        clear
        install_auto_symlink
        ;;
    2)
        clear
        update_auto_symlink
        ;;
    3)
        clear
        uninstall_auto_symlink
        ;;
    4)
        clear
        main_other_tools
        ;;
    *)
        clear
        ERROR '请输入正确数字 [1-4]'
        main_auto_symlink
        ;;
    esac

}

function init_container_name() {

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

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt ]; then
        auto_symlink_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt)
    else
        echo 'auto_symlink' > ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt
        auto_symlink_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt)
    fi

}

function change_container_name() {

    INFO "请输入新的容器名称"
    read -erp "Container name:" container_name
    [[ -z "${container_name}" ]] && container_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/"${1}".txt)
    echo "${container_name}" > ${DDSREM_CONFIG_DIR}/container_name/"${1}".txt
    clear
    container_name_settings

}

function container_name_settings() {

    init_container_name

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}容器名称设置${Font}\n"
    echo -e "1、更改 小雅 容器名                 （当前：${Green}${xiaoya_alist_name}${Font}）"
    echo -e "2、更改 小雅Emby 容器名             （当前：${Green}${xiaoya_emby_name}${Font}）"
    echo -e "3、更改 Resilio 容器名              （当前：${Green}${xiaoya_resilio_name}${Font}）"
    echo -e "4、更改 小雅Alist-TVBox 容器名      （当前：${Green}${xiaoya_tvbox_name}${Font}）"
    echo -e "5、更改 Onelist 容器名              （当前：${Green}${xiaoya_onelist_name}${Font}）"
    echo -e "6、更改 Portainer 容器名            （当前：${Green}${portainer_name}${Font}）"
    echo -e "7、更改 Auto_Symlink 容器名         （当前：${Green}${auto_symlink_name}${Font}）"
    echo -e "8、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-8]:" num
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
        change_container_name "auto_symlink_name"
        ;;
    8)
        clear
        main_advanced_configuration
        ;;
    *)
        clear
        ERROR '请输入正确数字 [1-8]'
        container_name_settings
        ;;
    esac

}

function reset_script_configuration() {

    INFO "是否${Red}删除所有脚本配置文件${Font} [Y/n]（默认 Y 删除）"
    read -erp "Clean config:" CLEAN_CONFIG
    [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"

    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        for i in $(seq -w 3 -1 0); do
            echo -en "即将开始清理配置文件${Blue} $i ${Font}\r"
            sleep 1
        done
        rm -rf ${DDSREM_CONFIG_DIR}/container_name
        rm -f \
            xiaoya_alist_tvbox_config_dir.txt \
            xiaoya_alist_media_dir.txt \
            xiaoya_alist_config_dir.txt \
            resilio_config_dir.txt \
            portainer_config_dir.txt \
            onelist_config_dir.txt \
            container_run_extra_parameters.txt \
            auto_symlink_config_dir.txt \
            data_downloader.txt
        INFO "清理完成！"

        for i in $(seq -w 3 -1 0); do
            echo -en "即将返回主界面并重新生成默认配置${Blue} $i ${Font}\r"
            sleep 1
        done

        first_init
        clear
        main
    else
        exit 0
    fi

}

function main_advanced_configuration() {

    __container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${__container_run_extra_parameters}" == "true" ]; then
        _container_run_extra_parameters="${Green}开启${Font}"
    elif [ "${__container_run_extra_parameters}" == "false" ]; then
        _container_run_extra_parameters="${Red}关闭${Font}"
    else
        _container_run_extra_parameters="${Red}错误${Font}"
    fi

    __disk_capacity_detection=$(cat ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt)
    if [ "${__disk_capacity_detection}" == "true" ]; then
        _disk_capacity_detection="${Green}开启${Font}"
    elif [ "${__disk_capacity_detection}" == "false" ]; then
        _disk_capacity_detection="${Red}关闭${Font}"
    else
        _disk_capacity_detection="${Red}错误${Font}"
    fi

    __xiaoya_connectivity_detection=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt)
    if [ "${__xiaoya_connectivity_detection}" == "true" ]; then
        _xiaoya_connectivity_detection="${Green}开启${Font}"
    elif [ "${__xiaoya_connectivity_detection}" == "false" ]; then
        _xiaoya_connectivity_detection="${Red}关闭${Font}"
    else
        _xiaoya_connectivity_detection="${Red}错误${Font}"
    fi

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}高级配置${Font}\n"
    echo -e "1、容器名称设置"
    echo -e "2、开启/关闭 容器运行额外参数添加             当前状态：${_container_run_extra_parameters}"
    echo -e "3、重置脚本配置"
    echo -e "4、开启/关闭 磁盘容量检测                     当前状态：${_disk_capacity_detection}"
    echo -e "5、开启/关闭 小雅连通性检测                   当前状态：${_xiaoya_connectivity_detection}"
    echo -e "6、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-6]:" num
    case "$num" in
    1)
        clear
        container_name_settings
        ;;
    2)
        if [ "${__container_run_extra_parameters}" == "false" ]; then
            echo 'true' > ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt
        else
            echo 'false' > ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt
        fi
        clear
        main_advanced_configuration
        ;;
    3)
        clear
        reset_script_configuration
        ;;
    4)
        if [ "${__disk_capacity_detection}" == "true" ]; then
            echo 'false' > ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt
        elif [ "${__disk_capacity_detection}" == "false" ]; then
            echo 'true' > ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt
        else
            echo 'true' > ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt
        fi
        clear
        main_advanced_configuration
        ;;
    5)
        if [ "${__xiaoya_connectivity_detection}" == "true" ]; then
            echo 'false' > ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt
        elif [ "${__xiaoya_connectivity_detection}" == "false" ]; then
            echo 'true' > ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt
        else
            echo 'true' > ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt
        fi
        clear
        main_advanced_configuration
        ;;
    6)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [1-6]'
        main_advanced_configuration
        ;;
    esac

}

function main_other_tools() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}其他工具${Font}\n"
    echo -e "1、安装/更新/卸载 Portainer                   当前状态：$(judgment_container "${portainer_name}")"
    echo -e "2、安装/更新/卸载 Auto_Symlink                当前状态：$(judgment_container "${auto_symlink_name}")"
    echo -e "3、查看系统磁盘挂载"
    echo -e "4、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-4]:" num
    case "$num" in
    1)
        clear
        main_portainer
        ;;
    2)
        clear
        main_auto_symlink
        ;;
    3)
        clear
        INFO "系统磁盘挂载情况:"
        show_disk_mount
        INFO "按任意键返回菜单"
        read -rs -n 1 -p ""
        clear
        main_other_tools
        ;;
    4)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [1-4]'
        main_other_tools
        ;;
    esac

}

function main_return() {

    cat /tmp/xiaoya_alist

    echo -e "1、安装/更新/卸载 小雅Alist                   当前状态：$(judgment_container "${xiaoya_alist_name}")"
    echo -e "2、安装/卸载 小雅Emby全家桶                   当前状态：$(judgment_container "${xiaoya_emby_name}")"
    echo -e "3、安装/更新/卸载 小雅助手（xiaoyahelper）    当前状态：$(judgment_container xiaoyakeeper)"
    echo -e "4、安装/更新/卸载 小雅Alist-TVBox             当前状态：$(judgment_container "${xiaoya_tvbox_name}")"
    echo -e "5、安装/更新/卸载 Onelist                     当前状态：$(judgment_container "${xiaoya_onelist_name}")"
    echo -e "6、其他工具 | Script info: ${DATE_VERSION} OS: ${_os},${OSNAME},${is64bit}"
    echo -e "7、高级配置 | Docker version: $(docker -v | sed "s/Docker version //g" | cut -d',' -f1)"
    echo -e "8、退出脚本 | Thanks: ${Sky_Blue}heiheigui,xiaoyaLiu,Harold,AI老G${Font}"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-8]:" num
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
        main_other_tools
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

function main() {
    clear
    main_return
}

function ci_test() {

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
    docker pull shenxianmq/auto_symlink:latest

}

function first_init() {

    root_need

    get_os

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

    if [ ! -f ${DDSREM_CONFIG_DIR}/data_downloader.txt ]; then
        if [ "$OSNAME" = "ugreen" ]; then
            echo 'wget' > ${DDSREM_CONFIG_DIR}/data_downloader.txt
        else
            echo 'aria2' > ${DDSREM_CONFIG_DIR}/data_downloader.txt
        fi
    fi

    if [ ! -f ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt ]; then
        echo 'true' > ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt
    fi

    if [ ! -f ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt ]; then
        echo 'true' > ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_emby_url.txt ]; then
        rm -rf ${DDSREM_CONFIG_DIR}/xiaoya_emby_url.txt
    fi
    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_emby_api.txt ]; then
        rm -rf ${DDSREM_CONFIG_DIR}/xiaoya_emby_api.txt
    fi

    if [ -f /tmp/xiaoya_alist ]; then
        rm -rf /tmp/xiaoya_alist
    fi
    if ! curl -sL https://ddsrem.com/xiaoya/xiaoya_alist -o /tmp/xiaoya_alist; then
        if ! curl -sL https://cdn.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/xiaoya_alist -o /tmp/xiaoya_alist; then
            curl -sL https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/xiaoya_alist -o /tmp/xiaoya_alist
            if ! grep -q 'alias xiaoya' /etc/profile; then
                echo -e "alias xiaoya='bash -c \"\$(curl -sLk https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/xiaoya_alist)\"'" >> /etc/profile
            fi
        else
            if ! grep -q 'alias xiaoya' /etc/profile; then
                echo -e "alias xiaoya='bash -c \"\$(curl -sLk https://cdn.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/xiaoya_alist)\"'" >> /etc/profile
            fi
        fi
    else
        if ! grep -q 'alias xiaoya' /etc/profile; then
            echo -e "alias xiaoya='bash -c \"\$(curl -sLk https://ddsrem.com/xiaoya_install.sh)\"'" >> /etc/profile
        fi
    fi

}

if [ ! "$*" ]; then
    first_init
    clear
    main
elif [ "$*" == test ]; then
    INFO "Test"
    ci_test
else
    first_init
    clear
    "$@"
fi
