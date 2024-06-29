#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC2086
# shellcheck disable=SC1091
# shellcheck disable=SC2154
# shellcheck disable=SC2004
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
DATE_VERSION="v1.6.7-2024_06_28_20_14"
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

mirrors=(
    "docker.io"
    "registry-docker-hub-latest-9vqc.onrender.com"
    "docker.fxxk.dedyn.io"
    "docker.chenby.cn"
    "dockerproxy.com"
    "hub.uuuadc.top"
    "docker.jsdelivr.fyi"
    "docker.registry.cyou"
    "dockerhub.anzu.vip"
    "docker.luyao.dynv6.net"
)

function root_need() {
    if [[ $EUID -ne 0 ]]; then
        ERROR '此脚本必须以 root 身份运行！'
        exit 1
    fi
}

function ___install_docker() {

    if ! command -v docker; then
        WARN "docker 未安装，脚本尝试自动安装..."
        wget -qO- get.docker.com | bash
        if command -v docker; then
            INFO "docker 安装成功！"
        else
            ERROR "docker 安装失败，请手动安装！"
            exit 1
        fi
    fi

}

function packages_apt_install() {

    if ! command -v ${1}; then
        WARN "${1} 未安装，脚本尝试自动安装..."
        apt update -y
        if apt install -y ${1}; then
            INFO "${1} 安装成功！"
        else
            ERROR "${1} 安装失败，请手动安装！"
            exit 1
        fi
    fi

}

function packages_yum_install() {

    if ! command -v ${1}; then
        WARN "${1} 未安装，脚本尝试自动安装..."
        if yum install -y ${1}; then
            INFO "${1} 安装成功！"
        else
            ERROR "${1} 安装失败，请手动安装！"
            exit 1
        fi
    fi

}

function packages_zypper_install() {

    if ! command -v ${1}; then
        WARN "${1} 未安装，脚本尝试自动安装..."
        zypper refresh
        if zypper install ${1}; then
            INFO "${1} 安装成功！"
        else
            ERROR "${1} 安装失败，请手动安装！"
            exit 1
        fi
    fi

}

function packages_apk_install() {

    if ! command -v ${1}; then
        WARN "${1} 未安装，脚本尝试自动安装..."
        if apk add ${1}; then
            INFO "${1} 安装成功！"
        else
            ERROR "${1} 安装失败，请手动安装！"
            exit 1
        fi
    fi

}

function packages_pacman_install() {

    if ! command -v ${1}; then
        WARN "${1} 未安装，脚本尝试自动安装..."
        if pacman -Sy --noconfirm ${1}; then
            INFO "${1} 安装成功！"
        else
            ERROR "${1} 安装失败，请手动安装！"
            exit 1
        fi
    fi

}

function packages_need() {

    if [ "$1" == "apt" ]; then
        packages_apt_install curl
        packages_apt_install wget
        ___install_docker
    elif [ "$1" == "yum" ]; then
        packages_yum_install curl
        packages_yum_install wget
        ___install_docker
    elif [ "$1" == "zypper" ]; then
        packages_zypper_install curl
        packages_zypper_install wget
        ___install_docker
    elif [ "$1" == "apk_alpine" ]; then
        packages_apk_install curl
        packages_apk_install wget
        packages_apk_install docker
    elif [ "$1" == "pacman" ]; then
        packages_pacman_install curl
        packages_pacman_install wget
        packages_pacman_install docker
    else
        if ! command -v curl; then
            ERROR "curl 未安装，请手动安装！"
            exit 1
        fi
        if ! command -v wget; then
            ERROR "wget 未安装，请手动安装！"
            exit 1
        fi
        if ! command -v docker; then
            ERROR "docker 未安装，请手动安装！"
            exit 1
        fi
    fi

}

function get_os() {

    if command -v getconf > /dev/null 2>&1; then
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
        stty -icanon
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
        ERROR "LibreELEC 系统目前不支持！"
        exit 1
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

function show_disk_mount() {

    df -h | grep -E -v "Avail|loop|boot|overlay|tmpfs|proc" | sort -nr -k 4

}

function judgment_container() {

    if docker container inspect "${1}" > /dev/null 2>&1; then
        local container_status
        container_status=$(docker inspect --format='{{.State.Status}}' "${1}")
        case "${container_status}" in
        "created")
            echo -e "${Blue}已创建${Font}"
            ;;
        "running")
            echo -e "${Green}运行中${Font}"
            ;;
        "paused")
            echo -e "${Blue}已暂停${Font}"
            ;;
        "restarting")
            echo -e "${Blue}重启中${Font}"
            ;;
        "removing")
            echo -e "${Blue}删除中${Font}"
            ;;
        "exited")
            echo -e "${Yellow}已停止${Font}"
            ;;
        "dead")
            echo -e "${Red}不可用${Font}"
            ;;
        *)
            echo -e "${Red}未知状态${Font}"
            ;;
        esac
    else
        echo -e "${Red}未安装${Font}"
    fi

}

function return_menu() {

    INFO "是否返回菜单继续配置 [Y/n]"
    answer=""
    t=60
    while [[ -z "$answer" && $t -gt 0 ]]; do
        printf "\r%2d 秒后将自动退出脚本：" $t
        read -r -t 1 -n 1 answer
        t=$((t - 1))
    done
    [[ -z "${answer}" ]] && answer="n"
    if [[ ${answer} == [Yy] ]]; then
        clear
        "${@}"
    else
        echo -e "\n"
        exit 0
    fi

}

function docker_pull() {

    retries=0
    max_retries=3

    IMAGE_MIRROR=$(cat "${DDSREM_CONFIG_DIR}/image_mirror.txt")

    if docker inspect "${1}" > /dev/null 2>&1; then
        INFO "发现旧 ${1} 镜像，删除中..."
        docker rmi "${1}" > /dev/null 2>&1
    fi

    while [ $retries -lt $max_retries ]; do
        if docker pull "${IMAGE_MIRROR}/${1}"; then
            INFO "${1} 镜像拉取成功！"
            break
        else
            WARN "${1} 镜像拉取失败，正在进行第 $((retries + 1)) 次重试..."
            retries=$((retries + 1))
        fi
    done

    if [ $retries -eq $max_retries ]; then
        ERROR "镜像拉取失败，已达到最大重试次数！"
        ERROR "请进入主菜单选择数字 ${Sky_Blue}9 6${Font} 进入 ${Sky_Blue}Docker镜像源选择${Font} 配置镜像源地址！"
        exit 1
    else
        if [ "${IMAGE_MIRROR}" != "docker.io" ]; then
            docker tag "${IMAGE_MIRROR}/${1}" "${1}" > /dev/null 2>&1
            docker rmi "${IMAGE_MIRROR}/${1}" > /dev/null 2>&1
        fi
        return 0
    fi

}

function container_update() {

    local run_image remove_image IMAGE_MIRROR pull_image
    if docker inspect assaflavie/runlike:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' assaflavie/runlike:latest | cut -f2 -d:)
        remote_sha=$(curl -s "https://hub.docker.com/v2/repositories/assaflavie/runlike/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ "$local_sha" != "$remote_sha" ]; then
            docker rmi assaflavie/runlike:latest
            docker_pull "assaflavie/runlike:latest"
        fi
    else
        docker_pull "assaflavie/runlike:latest"
    fi
    INFO "获取 ${1} 容器信息中..."
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp assaflavie/runlike "${@}" > "/tmp/container_update_${*}"
    run_image=$(docker container inspect -f '{{.Config.Image}}' "${@}")
    remove_image=$(docker images -q ${run_image})
    local retries=0
    local max_retries=3
    IMAGE_MIRROR=$(cat "${DDSREM_CONFIG_DIR}/image_mirror.txt")
    while [ $retries -lt $max_retries ]; do
        if docker pull "${IMAGE_MIRROR}/${run_image}"; then
            INFO "${1} 镜像拉取成功！"
            break
        else
            WARN "${1} 镜像拉取失败，正在进行第 $((retries + 1)) 次重试..."
            retries=$((retries + 1))
        fi
    done
    if [ $retries -eq $max_retries ]; then
        ERROR "镜像拉取失败，已达到最大重试次数！"
        return 1
    else
        if [ "${IMAGE_MIRROR}" != "docker.io" ]; then
            pull_image=$(docker images -q "${IMAGE_MIRROR}/${run_image}")
        else
            pull_image=$(docker images -q "${run_image}")
        fi
        if ! docker stop "${@}" > /dev/null 2>&1; then
            if ! docker kill "${@}" > /dev/null 2>&1; then
                docker rmi "${IMAGE_MIRROR}/${run_image}"
                ERROR "更新失败，停止 ${*} 容器失败！"
                return 1
            fi
        fi
        INFO "停止 ${*} 容器成功！"
        if ! docker rm --force "${@}" > /dev/null 2>&1; then
            ERROR "更新失败，删除 ${*} 容器失败！"
            return 1
        fi
        INFO "删除 ${*} 容器成功！"
        if [ "${pull_image}" != "${remove_image}" ]; then
            INFO "删除 ${remove_image} 镜像中..."
            docker rmi "${remove_image}" > /dev/null 2>&1
        fi
        if [ "${IMAGE_MIRROR}" != "docker.io" ]; then
            docker tag "${IMAGE_MIRROR}/${1}" "${1}" > /dev/null 2>&1
            docker rmi "${IMAGE_MIRROR}/${1}" > /dev/null 2>&1
        fi
        if bash "/tmp/container_update_${*}"; then
            rm -f "/tmp/container_update_${*}"
            INFO "${*} 更新成功"
            return 0
        else
            ERROR "更新失败，创建 ${*} 容器失败！"
            return 1
        fi
    fi

}

function wait_emby_start() {

    start_time=$(date +%s)
    CONTAINER_NAME="$(cat "${DDSREM_CONFIG_DIR}"/container_name/xiaoya_emby_name.txt)"
    TARGET_LOG_LINE_SUCCESS="All entry points have started"
    while true; do
        line=$(docker logs "$CONTAINER_NAME" 2>&1 | tail -n 10)
        echo -e "$line"
        if [[ "$line" == *"$TARGET_LOG_LINE_SUCCESS"* ]]; then
            break
        fi
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [ "$elapsed_time" -gt 600 ]; then
            WARN "Emby 未正常启动超时 10 分钟！"
            break
        fi
        sleep 3
    done

}

function wait_jellyfin_start() {

    start_time=$(date +%s)
    CONTAINER_NAME="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt)"
    while true; do
        if [ "$(docker inspect --format='{{json .State.Health.Status}}' "${CONTAINER_NAME}" | sed 's/"//g')" == "healthy" ]; then
            break
        fi
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [ "$elapsed_time" -gt 900 ]; then
            WARN "Jellyfin 未正常启动超时 15 分钟！"
            break
        fi
        sleep 10
        INFO "等待 Jellyfin 初始化完成中..."
    done

}

function wait_xiaoya_start() {

    start_time=$(date +%s)
    TARGET_LOG_LINE_SUCCESS="success load storage: [/©️"
    while true; do
        line=$(docker logs "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" 2>&1 | tail -n 10)
        echo -e "$line"
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ "$line" == *"$TARGET_LOG_LINE_SUCCESS"* ]]; then
            if [ "$elapsed_time" -gt 20 ]; then
                break
            fi
        fi
        if [ "$elapsed_time" -gt 300 ]; then
            WARN "小雅alist 未正常启动超时 5 分钟！"
            break
        fi
        sleep 3
    done

}

function check_quark_cookie() {

    if [[ ! -f "${CONFIG_DIR}/quark_cookie.txt" ]] && [[ ! -s "${CONFIG_DIR}/quark_cookie.txt" ]]; then
        return 1
    fi
    local cookie user_agent url headers response status state_url sign_daily_reward sign_daily_reward_mb
    cookie=$(head -n1 "${CONFIG_DIR}/quark_cookie.txt")
    user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) quark-cloud-drive/2.5.20 Chrome/100.0.4896.160 Electron/18.3.5.4-b478491100 Safari/537.36 Channel/pckk_other_ch"
    url="https://drive-pc.quark.cn/1/clouddrive/config?pr=ucpro&fr=pc&uc_param_str="
    headers="Cookie: $cookie; User-Agent: $user_agent; Referer: https://pan.quark.cn"
    response=$(curl -s -D - -H "$headers" "$url")
    status=$(echo "$response" | grep -i status | cut -f2 -d: | cut -f1 -d,)
    if [ "$status" == "401" ]; then
        ERROR "无效夸克 Cookie"
        return 1
    else
        state_url="https://drive-m.quark.cn/1/clouddrive/capacity/growth/info?pr=ucpro&fr=pc&uc_param_str="
        response=$(curl -s -H "$headers" "$state_url")
        sign_daily_reward=$(echo "$response" | cut -f6 -d\{ | cut -f4 -d: | cut -f1 -d,)
        sign_daily_reward_mb=$(echo "$sign_daily_reward 1024 1024" | awk '{printf "%.2f\n", $1 / ($2 * $3)}')
        if [ $sign_daily_reward_mb ]; then
            INFO "有效夸克 Cookie"
            INFO "夸克签到获取 $sign_daily_reward_mb MB"
            return 0
        else
            ERROR "请求失败，请检查 Cookie 或网络连接是否正确。"
            return 1
        fi
    fi

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
        INFO "读取配置目录中..."
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

function data_crep() { # container_run_extra_parameters

    local MODE="${1}"
    local DATA="${2}"
    local DIR="${DDSREM_CONFIG_DIR}/data_crep"

    if [ "${MODE}" == "read" ] || [ "${MODE}" == "r" ]; then
        if [ -f "${DIR}/${DATA}.txt" ]; then
            cat ${DIR}/${DATA}.txt | head -n1
        else
            echo "None"
        fi
    elif [ "${MODE}" == "write" ] || [ "${MODE}" == "w" ]; then
        echo "${extra_parameters}" > ${DIR}/${DATA}.txt
    else
        return 1
    fi

}

function install_xiaoya_alist() {

    if [ ! -d "${CONFIG_DIR}" ]; then
        mkdir -p "${CONFIG_DIR}"
    else
        if [ -d "${CONFIG_DIR}"/mytoken.txt ]; then
            rm -rf "${CONFIG_DIR}"/mytoken.txt
        fi
    fi

    if [ ! -d "${CONFIG_DIR}/data" ]; then
        mkdir -p "${CONFIG_DIR}/data"
    fi

    files=("mytoken.txt" "myopentoken.txt" "temp_transfer_folder_id.txt")
    for file in "${files[@]}"; do
        if [ ! -f "${CONFIG_DIR}/${file}" ]; then
            touch "${CONFIG_DIR}/${file}"
        fi
    done

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

    if [ ! -f "${CONFIG_DIR}/pikpak.txt" ]; then
        INFO "是否继续配置 PikPak 账号密码 [Y/n]（默认 n 不配置）"
        read -erp "PikPak_Set:" PikPak_Set
        [[ -z "${PikPak_Set}" ]] && PikPak_Set="n"
        if [[ ${PikPak_Set} == [Yy] ]]; then
            touch ${CONFIG_DIR}/pikpak.txt
            INFO "输入你的 PikPak 账号（手机号或邮箱）"
            INFO "如果手机号，要\"+区号\"，比如你的手机号\"12345678900\"那么就填\"+8612345678900\""
            read -erp "PikPak_Username:" PikPak_Username
            INFO "输入你的 PikPak 账号密码"
            read -erp "PikPak_Password:" PikPak_Password
            echo -e "\"${PikPak_Username}\" \"${PikPak_Password}\"" > ${CONFIG_DIR}/pikpak.txt
        fi
    fi

    if [ ! -f "${CONFIG_DIR}/quark_cookie.txt" ] || ! check_quark_cookie; then
        INFO "是否配置 夸克 Cookie [Y/n]（默认 n 不配置）"
        read -erp "Cookie:" choose_cookie
        [[ -z "${choose_cookie}" ]] && choose_cookie="n"
        if [[ ${choose_cookie} == [Yy] ]]; then
            touch ${CONFIG_DIR}/quark_cookie.txt
            while true; do
                INFO "输入你的 夸克 Cookie"
                read -erp "Cookie:" quark_cookie
                echo -e "${quark_cookie}" > ${CONFIG_DIR}/quark_cookie.txt
                if check_quark_cookie; then
                    break
                fi
            done
        fi
    fi

    if command -v ifconfig > /dev/null 2>&1; then
        localip=$(ifconfig -a | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1)
    else
        localip=$(ip address | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1 | cut -f1 -d"/")
    fi
    INFO "本地IP：${localip}"

    if [ "${SET_NET_MODE}" == true ]; then
        INFO "是否使用host网络模式 [Y/n]（默认 n 不使用）"
        read -erp "NET_MODE:" NET_MODE
    fi
    [[ -z "${NET_MODE}" ]] && NET_MODE="n"
    if [ ! -s "${CONFIG_DIR}"/docker_address.txt ]; then
        echo "http://$localip:5678" > "${CONFIG_DIR}"/docker_address.txt
    fi
    docker_command=("docker run" "-itd")
    if [[ ${NET_MODE} == [Yy] ]]; then
        docker_image="xiaoyaliu/alist:hostmode"
        docker_command+=("--network=host")
    else
        docker_image="xiaoyaliu/alist:latest"
        docker_command+=("-p 5678:80" "-p 2345:2345" "-p 2346:2346")
    fi
    if [[ -f ${CONFIG_DIR}/proxy.txt ]] && [[ -s ${CONFIG_DIR}/proxy.txt ]]; then
        proxy_url=$(head -n1 "${CONFIG_DIR}"/proxy.txt)
        docker_command+=("--env HTTP_PROXY=$proxy_url" "--env HTTPS_PROXY=$proxy_url" "--env no_proxy=*.aliyundrive.com")
    fi
    docker_command+=("-v ${CONFIG_DIR}:/data" "-v ${CONFIG_DIR}/data:/www/data" "--restart=always" "--name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" "$docker_image")
    docker_pull "$docker_image"
    eval "${docker_command[*]}"

    wait_xiaoya_start

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
    IMAGE_NAME="$(docker inspect --format='{{.Config.Image}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)")"
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
    docker rmi "${IMAGE_NAME}"
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

function judgment_xiaoya_alist_sync_data_status() {

    if command -v crontab > /dev/null 2>&1; then
        if crontab -l | grep 'xiaoya_data_downloader' > /dev/null 2>&1; then
            echo -e "${Green}已创建${Font}"
        else
            echo -e "${Red}未创建${Font}"
        fi
    elif [ -f /etc/synoinfo.conf ]; then
        if grep 'xiaoya_data_downloader' /etc/crontab > /dev/null 2>&1; then
            echo -e "${Green}已创建${Font}"
        else
            echo -e "${Red}未创建${Font}"
        fi
    else
        echo -e "${Red}未知${Font}"
    fi

}

function uninstall_xiaoya_alist_sync_data() {

    if command -v crontab > /dev/null 2>&1; then
        crontab -l > /tmp/cronjob.tmp
        sed -i '/xiaoya_data_downloader/d' /tmp/cronjob.tmp
        crontab /tmp/cronjob.tmp
        rm -f /tmp/cronjob.tmp
    elif [ -f /etc/synoinfo.conf ]; then
        sed -i '/xiaoya_data_downloader/d' /etc/crontab
    fi

}

function main_xiaoya_alist() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Alist${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、创建/删除 定时同步更新数据（${Red}功能已弃用，只提供删除${Font}）  当前状态：$(judgment_xiaoya_alist_sync_data_status)"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-4]:" num
    case "$num" in
    1)
        clear
        get_config_dir
        SET_NET_MODE=true
        install_xiaoya_alist
        return_menu "main_xiaoya_alist"
        ;;
    2)
        clear
        update_xiaoya_alist
        return_menu "main_xiaoya_alist"
        ;;
    3)
        clear
        uninstall_xiaoya_alist
        return_menu "main_xiaoya_alist"
        ;;
    4)
        clear
        if command -v crontab > /dev/null 2>&1; then
            if crontab -l | grep xiaoya_data_downloader > /dev/null 2>&1; then
                for i in $(seq -w 3 -1 0); do
                    echo -en "即将删除同步定时任务${Blue} $i ${Font}\r"
                    sleep 1
                done
                uninstall_xiaoya_alist_sync_data
                clear
                INFO "已删除"
            else
                INFO "功能已弃用，目前只提供删除！"
            fi
        elif [ -f /etc/synoinfo.conf ]; then
            if grep 'xiaoya_data_downloader' /etc/crontab > /dev/null 2>&1; then
                for i in $(seq -w 3 -1 0); do
                    echo -en "即将删除同步定时任务${Blue} $i ${Font}\r"
                    sleep 1
                done
                uninstall_xiaoya_alist_sync_data
                clear
                INFO "已删除"
            else
                INFO "功能已弃用，目前只提供删除！"
            fi
        else
            INFO "功能已弃用，目前只提供删除！"
        fi
        return_menu "main_xiaoya_alist"
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-4]'
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
        if [ "$local_sha" != "$remote_sha" ]; then
            docker rmi xiaoyaliu/glue:latest
            docker_pull "xiaoyaliu/glue:latest"
        fi
    else
        docker_pull "xiaoyaliu/glue:latest"
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
            -e TZ=Asia/Shanghai \
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
            -e TZ=Asia/Shanghai \
            xiaoyaliu/glue:latest \
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

function unzip_appoint_xiaoya_emby_jellyfin() {

    if [ "${2}" == "emby" ]; then
        file_name="all.mp4"
    elif [ "${2}" == "jellyfin" ]; then
        file_name="all_jf.mp4"
    fi

    get_config_dir

    get_media_dir

    if [ "${1}" == "${file_name}" ]; then
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

    if [ "${1}" == "${file_name}" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        all_size=$(du -k ${MEDIA_DIR}/temp/${file_name} | cut -f1)
        if [[ "$all_size" -le 30000000 ]]; then
            ERROR "${file_name} 下载不完整，文件大小(in KB):$all_size 小于预期"
            exit 1
        else
            INFO "${file_name} 文件大小验证正常"
            pull_run_glue 7z x -aoa -mmt=16 /media/temp/${file_name} ${UNZIP_FOLD}/* -o/media/xiaoya
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
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-10]:" num
    case "$num" in
    1)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_unzip_xiaoya_all_emby
        else
            download_unzip_xiaoya_all_emby
        fi
        return_menu "main_download_unzip_xiaoya_emby"
        ;;
    2)
        clear
        unzip_xiaoya_all_emby
        return_menu "main_download_unzip_xiaoya_emby"
        ;;
    3)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_xiaoya_emby "all.mp4"
        else
            download_xiaoya_emby "all.mp4"
        fi
        return_menu "main_download_unzip_xiaoya_emby"
        ;;
    4)
        clear
        unzip_xiaoya_emby "all.mp4"
        return_menu "main_download_unzip_xiaoya_emby"
        ;;
    5)
        clear
        unzip_appoint_xiaoya_emby "all.mp4" "emby"
        return_menu "main_download_unzip_xiaoya_emby"
        ;;
    6)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_xiaoya_emby "config.mp4"
        else
            download_xiaoya_emby "config.mp4"
        fi
        return_menu "main_download_unzip_xiaoya_emby"
        ;;
    7)
        clear
        unzip_xiaoya_emby "config.mp4"
        return_menu "main_download_unzip_xiaoya_emby"
        ;;
    8)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_xiaoya_emby "pikpak.mp4"
        else
            download_xiaoya_emby "pikpak.mp4"
        fi
        return_menu "main_download_unzip_xiaoya_emby"
        ;;
    9)
        clear
        unzip_xiaoya_emby "pikpak.mp4"
        return_menu "main_download_unzip_xiaoya_emby"
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
    0)
        clear
        main_xiaoya_all_emby
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-10]'
        main_download_unzip_xiaoya_emby
        ;;
    esac

}

function download_wget_unzip_xiaoya_all_jellyfin() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}/temp"
    if [ -d "${MEDIA_DIR}/config" ]; then
        rm -rf ${MEDIA_DIR}/config
    fi

    test_disk_capacity

    mkdir -p "${MEDIA_DIR}/xiaoya"
    mkdir -p "${MEDIA_DIR}/temp"
    chown 0:0 "${MEDIA_DIR}"
    chmod 777 "${MEDIA_DIR}"

    INFO "开始下载解压..."

    extra_parameters="--workdir=/media/temp"
    if pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/Jellyfin/config_jf.mp4"; then
        if [ -f "${MEDIA_DIR}/temp/config_jf.mp4.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/config_jf.mp4.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "config_jf.mp4 下载成功！"
        fi
    else
        ERROR "config_jf.mp4 下载失败！"
        exit 1
    fi
    if pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/Jellyfin/all_jf.mp4"; then
        if [ -f "${MEDIA_DIR}/temp/all_jf.mp4.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/all_jf.mp4.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "all_jf.mp4 下载成功！"
        fi
    else
        ERROR "all_jf.mp4 下载失败！"
        exit 1
    fi
    if pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/Jellyfin/PikPak_jf.mp4"; then
        if [ -f "${MEDIA_DIR}/temp/PikPak_jf.mp4.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/PikPak_jf.mp4.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "PikPak_jf.mp4 下载成功！"
        fi
    else
        ERROR "PikPak_jf.mp4 下载失败！"
        exit 1
    fi

    start_time1=$(date +%s)

    config_size=$(du -k ${MEDIA_DIR}/temp/config_jf.mp4 | cut -f1)
    if [[ "$config_size" -le 3200000 ]]; then
        ERROR "config_jf.mp4 下载不完整，文件大小(in KB):$config_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media"
    pull_run_glue 7z x -aoa -mmt=16 temp/config_jf.mp4
    mv ${MEDIA_DIR}/jf_config ${MEDIA_DIR}/config

    all_size=$(du -k ${MEDIA_DIR}/temp/all_jf.mp4 | cut -f1)
    if [[ "$all_size" -le 30000000 ]]; then
        ERROR "all_jf.mp4 下载不完整，文件大小(in KB):$all_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media/xiaoya"
    pull_run_glue 7z x -aoa -mmt=16 /media/temp/all_jf.mp4

    pikpak_size=$(du -k ${MEDIA_DIR}/temp/PikPak_jf.mp4 | cut -f1)
    if [[ "$pikpak_size" -le 14000000 ]]; then
        ERROR "PikPak_jf.mp4 下载不完整，文件大小(in KB):$pikpak_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media/xiaoya"
    pull_run_glue 7z x -aoa -mmt=16 /media/temp/PikPak_jf.mp4

    end_time1=$(date +%s)
    total_time1=$((end_time1 - start_time1))
    total_time1=$((total_time1 / 60))
    INFO "解压执行时间：$total_time1 分钟"

    INFO "设置目录权限..."
    INFO "这可能需要一定时间，请耐心等待！"
    chmod -R 777 "${MEDIA_DIR}"

}

function download_unzip_xiaoya_all_jellyfin() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}/temp"
    if [ -d "${MEDIA_DIR}/config" ]; then
        rm -rf ${MEDIA_DIR}/config
    fi

    test_disk_capacity

    mkdir -p "${MEDIA_DIR}/xiaoya"
    mkdir -p "${MEDIA_DIR}/temp"
    chown 0:0 "${MEDIA_DIR}"
    chmod 777 "${MEDIA_DIR}"

    INFO "开始下载解压..."

    extra_parameters="--workdir=/media/temp"
    if pull_run_glue aria2c -o config_jf.mp4 --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${xiaoya_addr}/d/元数据/Jellyfin/config_jf.mp4"; then
        if [ -f "${MEDIA_DIR}/temp/config_jf.mp4.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/config_jf.mp4.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "config_jf.mp4 下载成功！"
        fi
    else
        ERROR "config_jf.mp4 下载失败！"
        exit 1
    fi
    if pull_run_glue aria2c -o all_jf.mp4 --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${xiaoya_addr}/d/元数据/Jellyfin/all_jf.mp4"; then
        if [ -f "${MEDIA_DIR}/temp/all_jf.mp4.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/all_jf.mp4.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "all_jf.mp4 下载成功！"
        fi
    else
        ERROR "all_jf.mp4 下载失败！"
        exit 1
    fi
    if pull_run_glue aria2c -o PikPak_jf.mp4 --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${xiaoya_addr}/d/元数据/Jellyfin/PikPak_jf.mp4"; then
        if [ -f "${MEDIA_DIR}/temp/PikPak_jf.mp4.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/PikPak_jf.mp4.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "PikPak_jf.mp4 下载成功！"
        fi
    else
        ERROR "PikPak_jf.mp4 下载失败！"
        exit 1
    fi

    start_time1=$(date +%s)

    config_size=$(du -k ${MEDIA_DIR}/temp/config_jf.mp4 | cut -f1)
    if [[ "$config_size" -le 3200000 ]]; then
        ERROR "config_jf.mp4 下载不完整，文件大小(in KB):$config_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media"
    pull_run_glue 7z x -aoa -mmt=16 temp/config_jf.mp4
    mv ${MEDIA_DIR}/jf_config ${MEDIA_DIR}/config

    all_size=$(du -k ${MEDIA_DIR}/temp/all_jf.mp4 | cut -f1)
    if [[ "$all_size" -le 30000000 ]]; then
        ERROR "all_jf.mp4 下载不完整，文件大小(in KB):$all_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media/xiaoya"
    pull_run_glue 7z x -aoa -mmt=16 /media/temp/all_jf.mp4

    pikpak_size=$(du -k ${MEDIA_DIR}/temp/PikPak_jf.mp4 | cut -f1)
    if [[ "$pikpak_size" -le 14000000 ]]; then
        ERROR "PikPak_jf.mp4 下载不完整，文件大小(in KB):$pikpak_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media/xiaoya"
    pull_run_glue 7z x -aoa -mmt=16 /media/temp/PikPak_jf.mp4

    end_time1=$(date +%s)
    total_time1=$((end_time1 - start_time1))
    total_time1=$((total_time1 / 60))
    INFO "解压执行时间：$total_time1 分钟"

    INFO "设置目录权限..."
    INFO "这可能需要一定时间，请耐心等待！"
    chmod -R 777 "${MEDIA_DIR}"

}

function unzip_xiaoya_all_jellyfin() {

    get_config_dir

    get_media_dir

    if [ -d "${MEDIA_DIR}/config" ]; then
        rm -rf ${MEDIA_DIR}/config
    fi
    mkdir -p "${MEDIA_DIR}/xiaoya"

    INFO "开始解压..."

    start_time1=$(date +%s)

    config_size=$(du -k ${MEDIA_DIR}/temp/config_jf.mp4 | cut -f1)
    if [[ "$config_size" -le 3200000 ]]; then
        ERROR "config_jf.mp4 下载不完整，文件大小(in KB):$config_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media"
    pull_run_glue 7z x -aoa -mmt=16 temp/config_jf.mp4
    mv ${MEDIA_DIR}/jf_config ${MEDIA_DIR}/config

    all_size=$(du -k ${MEDIA_DIR}/temp/all_jf.mp4 | cut -f1)
    if [[ "$all_size" -le 30000000 ]]; then
        ERROR "all_jf.mp4 下载不完整，文件大小(in KB):$all_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media/xiaoya"
    pull_run_glue 7z x -aoa -mmt=16 /media/temp/all_jf.mp4

    pikpak_size=$(du -k ${MEDIA_DIR}/temp/PikPak_jf.mp4 | cut -f1)
    if [[ "$pikpak_size" -le 14000000 ]]; then
        ERROR "PikPak_jf.mp4 下载不完整，文件大小(in KB):$pikpak_size 小于预期"
        exit 1
    fi
    extra_parameters="--workdir=/media/xiaoya"
    pull_run_glue 7z x -aoa -mmt=16 /media/temp/PikPak_jf.mp4

    end_time1=$(date +%s)
    total_time1=$((end_time1 - start_time1))
    total_time1=$((total_time1 / 60))
    INFO "解压执行时间：$total_time1 分钟"

    INFO "设置目录权限..."
    INFO "这可能需要一定时间，请耐心等待！"
    chmod -R 777 "${MEDIA_DIR}"

    INFO "解压完成！"

}

function download_xiaoya_jellyfin() {

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

    if pull_run_glue aria2c -o "${1}" --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${xiaoya_addr}/d/元数据/Jellyfin/${1}"; then
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

function download_wget_xiaoya_jellyfin() {

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

    if pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/Jellyfin/${1}"; then
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

function unzip_xiaoya_jellyfin() {

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

    if [ "${1}" == "config_jf.mp4" ]; then
        extra_parameters="--workdir=/media"

        if [ -d "${MEDIA_DIR}/config" ]; then
            rm -rf ${MEDIA_DIR}/config
        fi

        config_size=$(du -k ${MEDIA_DIR}/temp/config_jf.mp4 | cut -f1)
        if [[ "$config_size" -le 3200000 ]]; then
            ERROR "config_jf.mp4 下载不完整，文件大小(in KB):$config_size 小于预期"
            exit 1
        else
            INFO "config_jf.mp4 文件大小验证正常"
            pull_run_glue 7z x -aoa -mmt=16 temp/config_jf.mp4
            mv ${MEDIA_DIR}/jf_config ${MEDIA_DIR}/config
        fi

        INFO "设置目录权限..."
        chmod 777 "${MEDIA_DIR}"/config
    elif [ "${1}" == "all_jf.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        all_size=$(du -k ${MEDIA_DIR}/temp/all_jf.mp4 | cut -f1)
        if [[ "$all_size" -le 30000000 ]]; then
            ERROR "all_jf.mp4 下载不完整，文件大小(in KB):$all_size 小于预期"
            exit 1
        else
            INFO "all_jf.mp4 文件大小验证正常"
            pull_run_glue 7z x -aoa -mmt=16 /media/temp/all_jf.mp4
        fi

        INFO "设置目录权限..."
        chmod 777 "${MEDIA_DIR}"/xiaoya
    elif [ "${1}" == "PikPak_jf.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        pikpak_size=$(du -k ${MEDIA_DIR}/temp/PikPak_jf.mp4 | cut -f1)
        if [[ "$pikpak_size" -le 14000000 ]]; then
            ERROR "PikPak_jf.mp4 下载不完整，文件大小(in KB):$pikpak_size 小于预期"
            exit 1
        else
            INFO "PikPak_jf.mp4 文件大小验证正常"
            pull_run_glue 7z x -aoa -mmt=16 /media/temp/PikPak_jf.mp4
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

function main_download_unzip_xiaoya_jellyfin() {

    __data_downloader=$(cat ${DDSREM_CONFIG_DIR}/data_downloader.txt)

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}下载/解压 元数据${Font}\n"
    echo -e "1、下载并解压 全部元数据"
    echo -e "2、解压 全部元数据"
    echo -e "3、下载 all_jf.mp4"
    echo -e "4、解压 all_jf.mp4"
    echo -e "5、解压 all_jf.mp4 的指定元数据目录【非全部解压】"
    echo -e "6、下载 config_jf.mp4"
    echo -e "7、解压 config_jf.mp4"
    echo -e "8、下载 PikPak_jf.mp4"
    echo -e "9、解压 PikPak_jf.mp4"
    echo -e "10、当前下载器【aria2/wget】                  当前状态：${Green}${__data_downloader}${Font}"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-10]:" num
    case "$num" in
    1)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_unzip_xiaoya_all_jellyfin
        else
            download_unzip_xiaoya_all_jellyfin
        fi
        return_menu "main_download_unzip_xiaoya_jellyfin"
        ;;
    2)
        clear
        unzip_xiaoya_all_jellyfin
        return_menu "main_download_unzip_xiaoya_jellyfin"
        ;;
    3)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_xiaoya_jellyfin "all_jf.mp4"
        else
            download_xiaoya_jellyfin "all_jf.mp4"
        fi
        return_menu "main_download_unzip_xiaoya_jellyfin"
        ;;
    4)
        clear
        unzip_xiaoya_jellyfin "all_jf.mp4"
        return_menu "main_download_unzip_xiaoya_jellyfin"
        ;;
    5)
        clear
        unzip_appoint_xiaoya_emby_jellyfin "all_jf.mp4" "jellyfin"
        return_menu "main_download_unzip_xiaoya_jellyfin"
        ;;
    6)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_xiaoya_jellyfin "config_jf.mp4"
        else
            download_xiaoya_jellyfin "config_jf.mp4"
        fi
        return_menu "main_download_unzip_xiaoya_jellyfin"
        ;;
    7)
        clear
        unzip_xiaoya_jellyfin "config_jf.mp4"
        return_menu "main_download_unzip_xiaoya_jellyfin"
        ;;
    8)
        clear
        if [ "${__data_downloader}" == "wget" ]; then
            download_wget_xiaoya_jellyfin "PikPak_jf.mp4"
        else
            download_xiaoya_jellyfin "PikPak_jf.mp4"
        fi
        return_menu "main_download_unzip_xiaoya_jellyfin"
        ;;
    9)
        clear
        unzip_xiaoya_jellyfin "PikPak_jf.mp4"
        return_menu "main_download_unzip_xiaoya_jellyfin"
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
        main_download_unzip_xiaoya_jellyfin
        ;;
    0)
        clear
        main_xiaoya_all_jellyfin
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-10]'
        main_download_unzip_xiaoya_jellyfin
        ;;
    esac

}

function install_emby_embyserver() {

    cpu_arch=$(uname -m)
    INFO "开始安装Emby容器....."
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        image_name="emby/embyserver"
        ;;
    "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        image_name="emby/embyserver_arm64v8"
        ;;
    *)
        ERROR "目前只支持amd64和arm64架构，你的架构是：$cpu_arch"
        exit 1
        ;;
    esac
    docker_pull "${image_name}:${IMAGE_VERSION}"
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
            -e TZ=Asia/Shanghai \
            --restart=always \
            "${image_name}:${IMAGE_VERSION}"
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
            -e TZ=Asia/Shanghai \
            --restart=always \
            "${image_name}:${IMAGE_VERSION}"
    fi

}

function install_amilys_embyserver() {

    cpu_arch=$(uname -m)
    INFO "开始安装Emby容器....."
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        image_name="amilys/embyserver"
        ;;
    "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        image_name="amilys/embyserver_arm64v8"
        ;;
    *)
        ERROR "目前只支持amd64和arm64架构，你的架构是：$cpu_arch"
        exit 1
        ;;
    esac
    docker_pull "${image_name}:${IMAGE_VERSION}"
    if [ -n "${extra_parameters}" ]; then
        docker run -itd \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
            -v "${MEDIA_DIR}/config:/config" \
            -v "${MEDIA_DIR}/xiaoya:/media" \
            -v ${NSSWITCH}:/etc/nsswitch.conf \
            --add-host="xiaoya.host:$xiaoya_host" \
            ${NET_MODE} \
            ${extra_parameters} \
            -e UID=0 \
            -e GID=0 \
            -e TZ=Asia/Shanghai \
            --restart=always \
            "${image_name}:${IMAGE_VERSION}"
    else
        docker run -itd \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
            -v "${MEDIA_DIR}/config:/config" \
            -v "${MEDIA_DIR}/xiaoya:/media" \
            -v ${NSSWITCH}:/etc/nsswitch.conf \
            --add-host="xiaoya.host:$xiaoya_host" \
            ${NET_MODE} \
            -e UID=0 \
            -e GID=0 \
            -e TZ=Asia/Shanghai \
            --restart=always \
            "${image_name}:${IMAGE_VERSION}"
    fi

}

function install_lovechen_embyserver() {

    INFO "开始安装Emby容器....."

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

    docker_pull "lovechen/embyserver:4.7.14.0"
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
            -e TZ=Asia/Shanghai \
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
            -e TZ=Asia/Shanghai \
            --restart=always \
            lovechen/embyserver:4.7.14.0
    fi

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

    cpu_arch=$(uname -m)
    INFO "您的架构是：$cpu_arch"
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        INFO "请选择使用的Emby镜像 [ 1:amilys/embyserver | 2:emby/embyserver | 3:lovechen/embyserver(不推荐！目前不能直接同步config数据，且还存在一些已知问题未修复) ]（默认 2）"
        read -erp "IMAGE:" IMAGE
        [[ -z "${IMAGE}" ]] && IMAGE="2"
        if [[ ${IMAGE} == [1] ]]; then
            CHOOSE_EMBY=amilys_embyserver
        elif [[ ${IMAGE} == [2] ]]; then
            CHOOSE_EMBY=emby_embyserver
        elif [[ ${IMAGE} == [3] ]]; then
            CHOOSE_EMBY=lovechen_embyserver
        else
            ERROR "输入无效，请重新选择"
            choose_emby_image
        fi
        ;;
    "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        INFO "请选择使用的Emby镜像 [ 1:amilys/embyserver | 2:emby/embyserver | 3:lovechen/embyserver(不推荐！目前不能直接同步config数据，且还存在一些已知问题未修复) ]（默认 2）"
        read -erp "IMAGE:" IMAGE
        [[ -z "${IMAGE}" ]] && IMAGE="2"
        if [[ ${IMAGE} == [1] ]]; then
            CHOOSE_EMBY=amilys_embyserver
        elif [[ ${IMAGE} == [2] ]]; then
            CHOOSE_EMBY=emby_embyserver
        elif [[ ${IMAGE} == [3] ]]; then
            CHOOSE_EMBY=lovechen_embyserver
        else
            ERROR "输入无效，请重新选择"
            choose_emby_image
        fi
        ;;
    *)
        ERROR "全家桶 Emby 目前只支持 amd64 和 arm64 架构，你的架构是：$cpu_arch"
        exit 1
        ;;
    esac

}

function get_nsswitch_conf_path() {

    if [ -f /etc/nsswitch.conf ]; then
        NSSWITCH="/etc/nsswitch.conf"
    else
        CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
        if [ -d "${CONFIG_DIR}/nsswitch.conf" ]; then
            rm -rf ${CONFIG_DIR}/nsswitch.conf
        fi
        echo -e "hosts:\tfiles dns" > ${CONFIG_DIR}/nsswitch.conf
        echo -e "networks:\tfiles" >> ${CONFIG_DIR}/nsswitch.conf
        NSSWITCH="${CONFIG_DIR}/nsswitch.conf"
    fi
    INFO "nsswitch.conf 配置文件路径：${NSSWITCH}"

}

function get_xiaoya_hosts() { # 调用这个函数必须设置 $MODE 此变量

    if ! grep -q xiaoya.host ${HOSTS_FILE_PATH}; then
        if [ "$MODE" == "host" ]; then
            echo -e "127.0.0.1\txiaoya.host\n" >> ${HOSTS_FILE_PATH}
            xiaoya_host="127.0.0.1"
        elif [ "$MODE" == "bridge" ]; then
            echo -e "$docker0\txiaoya.host\n" >> ${HOSTS_FILE_PATH}
            xiaoya_host="$docker0"
        fi
    else
        if [ "$MODE" == "host" ]; then
            if grep -q "^${docker0}.*xiaoya\.host" ${HOSTS_FILE_PATH}; then
                sed -i '/xiaoya.host/d' ${HOSTS_FILE_PATH}
                echo -e "127.0.0.1\txiaoya.host\n" >> ${HOSTS_FILE_PATH}
            fi
        elif [ "$MODE" == "bridge" ]; then
            if grep -q "^127\.0\.0\.1.*xiaoya\.host" ${HOSTS_FILE_PATH}; then
                sed -i '/xiaoya.host/d' ${HOSTS_FILE_PATH}
                echo -e "$docker0\txiaoya.host\n" >> ${HOSTS_FILE_PATH}
            fi
        fi
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
        INFO "hosts 文件格式设置正确！"
    else
        WARN "hosts 文件格式设置错误！"
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

    INFO "${XIAOYA_HOSTS_SHOW}"

    response="$(curl -s -o /dev/null -w '%{http_code}' http://${xiaoya_host}:5678)"
    if [[ "$response" == "302" || "$response" == "200" ]]; then
        INFO "hosts 文件设置正确，本机可以正常访问小雅容器！"
    else
        response="$(curl -s -o /dev/null -w '%{http_code}' http://${xiaoya_host}:5678)"
        if [[ "$response" == "302" || "$response" == "200" ]]; then
            INFO "hosts 文件设置正确，本机可以正常访问小雅容器！"
        else
            ERROR "hosts 文件设置错误，本机无法正常访问小雅容器！"
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

    if [ -f "${MEDIA_DIR}/config/data/device.txt" ]; then
        INFO "检测到存在 device.txt 文件！"
        if grep -q "1999bfd1661041cd85ff5e260bc04c06" ${MEDIA_DIR}/config/data/device.txt; then
            INFO "删除 device.txt 文件中..."
            rm -f ${MEDIA_DIR}/config/data/device.txt
        fi
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

        if [ -n "${version}" ]; then
            IMAGE_VERSION="${version}"
        else
            IMAGE_VERSION=4.8.0.56
        fi

        if [ "${image}" == "emby" ]; then
            install_emby_embyserver
        else
            # 因为amilys embyserver arm64镜像没有4.8.0.56这个版本号，所以这边规定只能使用latest
            cpu_arch=$(uname -m)
            case $cpu_arch in
            "x86_64" | *"amd64"*)
                install_amilys_embyserver
                ;;
            "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
                WARN "amilys/embyserver_arm64v8镜像无法指定版本号，忽略镜像版本号设置，默认拉取latest镜像！"
                IMAGE_VERSION=latest
                install_amilys_embyserver
                ;;
            *)
                ERROR "全家桶 Emby 目前只支持 amd64 和 arm64 架构，你的架构是：$cpu_arch"
                exit 1
                ;;
            esac
        fi

    else
        choose_emby_image

        choose_network_mode

        get_xiaoya_hosts

        INFO "如果需要开启Emby硬件转码请先返回主菜单开启容器运行额外参数添加 -> 72"
        container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
        if [ "${container_run_extra_parameters}" == "true" ]; then
            local RETURN_DATA
            RETURN_DATA="$(data_crep "r" "install_xiaoya_emby")"
            if [ "${RETURN_DATA}" == "None" ]; then
                INFO "请输入其他参数（默认 --device /dev/dri:/dev/dri --privileged -e GIDLIST=0,0 -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all ）"
                read -erp "Extra parameters:" extra_parameters
                [[ -z "${extra_parameters}" ]] && extra_parameters="--device /dev/dri:/dev/dri --privileged -e GIDLIST=0,0 -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all"
                data_crep "write" "install_xiaoya_emby"
            else
                INFO "已读取您上次设置的参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
                read -erp "Extra parameters:" extra_parameters
                [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
            fi
        fi

        get_nsswitch_conf_path

        while true; do
            if [ "${CHOOSE_EMBY}" == "amilys_embyserver" ]; then
                cpu_arch=$(uname -m)
                if [[ $cpu_arch == "aarch64" || $cpu_arch == *"arm64"* || $cpu_arch == *"armv8"* || $cpu_arch == *"arm/v8"* ]]; then
                    WARN "amilys/embyserver_arm64v8镜像无法指定版本号，默认拉取latest镜像！"
                    IMAGE_VERSION=latest
                    break
                fi
            fi
            INFO "请选择 Emby 镜像版本 [ 1；4.8.0.56 | 2；latest ]（默认 1）"
            read -erp "CHOOSE_IMAGE_VERSION:" CHOOSE_IMAGE_VERSION
            [[ -z "${CHOOSE_IMAGE_VERSION}" ]] && CHOOSE_IMAGE_VERSION="1"
            case ${CHOOSE_IMAGE_VERSION} in
            1)
                IMAGE_VERSION=4.8.0.56
                break
                ;;
            2)
                IMAGE_VERSION=latest
                break
                ;;
            *)
                ERROR "输入无效，请重新选择"
                ;;
            esac
        done

        case ${CHOOSE_EMBY} in
        emby_embyserver)
            install_emby_embyserver
            ;;
        lovechen_embyserver)
            install_lovechen_embyserver
            ;;
        amilys_embyserver)
            install_amilys_embyserver
            ;;
        esac

    fi

    set_emby_server_infuse_api_key

    wait_emby_start

    sleep 2

    if ! curl -I -s http://$docker0:2345/ | grep -q "302"; then
        INFO "重启小雅容器中..."
        docker restart "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
        wait_xiaoya_start
    fi

    INFO "Emby安装完成！"

}

function install_jellyfin_xiaoya_all_jellyfin() {

    get_docker0_url

    MODE=bridge

    get_xiaoya_hosts

    get_nsswitch_conf_path

    echo "http://$docker0:6909" > "${CONFIG_DIR}"/jellyfin_server.txt

    if [ ! -f "${CONFIG_DIR}"/infuse_api_key.txt ]; then
        echo "e825ed6f7f8f44ffa0563cddaddce14d" > "${CONFIG_DIR}"/infuse_api_key.txt
    fi

    cpu_arch=$(uname -m)
    INFO "您的架构是：$cpu_arch"
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        docker_pull "nyanmisaka/jellyfin:240220-amd64-legacy"
        docker run -d \
            --name "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt)" \
            -v ${NSSWITCH}:/etc/nsswitch.conf \
            --add-host="xiaoya.host:$xiaoya_host" \
            -v "${MEDIA_DIR}/config:/config" \
            -v "${MEDIA_DIR}/xiaoya:/media" \
            -v "${MEDIA_DIR}/config/cache:/cache" \
            --user 0:0 \
            -p 6909:8096 \
            -p 6920:8920 \
            -p 1909:1900/udp \
            -p 7369:7359/udp \
            --privileged=true \
            --restart=always \
            -e TZ=Asia/Shanghai \
            nyanmisaka/jellyfin:240220-amd64-legacy
        ;;
    "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        docker_pull "nyanmisaka/jellyfin:240220-arm64"
        docker run -d \
            --name "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt)" \
            -v ${NSSWITCH}:/etc/nsswitch.conf \
            --add-host="xiaoya.host:$xiaoya_host" \
            -v "${MEDIA_DIR}/config:/config" \
            -v "${MEDIA_DIR}/xiaoya:/media" \
            -v "${MEDIA_DIR}/config/cache:/cache" \
            --user 0:0 \
            -p 6909:8096 \
            -p 6920:8920 \
            -p 1909:1900/udp \
            -p 7369:7359/udp \
            --privileged=true \
            --restart=always \
            -e TZ=Asia/Shanghai \
            nyanmisaka/jellyfin:240220-arm64
        ;;
    *)
        ERROR "全家桶 Jellyfin 目前只支持 amd64 和 arm64 架构，你的架构是：$cpu_arch"
        exit 1
        ;;
    esac

    wait_jellyfin_start

    sleep 4

    if ! curl -I -s http://$docker0:2346/ | grep -q "302"; then
        INFO "重启小雅容器中..."
        docker restart "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
        wait_xiaoya_start
    fi

    INFO "Jellyfin 安装完成！"
    if command -v ifconfig > /dev/null 2>&1; then
        localip=$(ifconfig -a | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1)
    else
        localip=$(ip address | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1 | cut -f1 -d"/")
    fi
    INFO "请浏览器访问 ${Sky_Blue}http://${localip}:2346${Font} 登入 Jellyfin，用户名：${Sky_Blue}ailg${Font}   密码：${Sky_Blue}5678${Font}"

}

function install_xiaoya_notify_cron() {

    if [ ! -f ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt ]; then
        INFO "请输入Resilio-Sync配置文件目录"
        WARN "注意：Resilio-Sync 并且必须安装，本次获取目录只用于存放日志文件！"
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

    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        local RETURN_DATA
        RETURN_DATA="$(data_crep "r" "install_xiaoya_notify_cron")"
        if [ "${RETURN_DATA}" == "None" ]; then
            INFO "请输入其他参数（默认 无 ）"
            read -erp "Extra parameters:" extra_parameters
            data_crep "w" "install_xiaoya_notify_cron"
        else
            INFO "已读取您上次设置的参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
        fi
    fi

    # 组合定时任务命令
    CRON="${minu} ${hour} */${sync_day} * *   bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh)\" -s \
--auto_update_all_pikpak=${auto_update_all_pikpak} \
--auto_update_config=${auto_update_config} \
--media_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt) \
--config_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt) \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt) \
${extra_parameters} >> \
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
        docker_pull "ddsderek/xiaoya-cron:latest"
        CRON_PARAMETERS="--auto_update_all_pikpak=${auto_update_all_pikpak} \
--auto_update_config=${auto_update_config} \
--media_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt) \
--config_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt) \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt) \
${extra_parameters}"
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
        local RETURN_DATA
        RETURN_DATA="$(data_crep "r" "install_xiaoya_resilio")"
        if [ "${RETURN_DATA}" == "None" ]; then
            INFO "请输入其他参数（默认 无 ）"
            read -erp "Extra parameters:" extra_parameters
            data_crep "w" "install_xiaoya_resilio"
        else
            INFO "已读取您上次设置的参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
        fi
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
    docker_pull "linuxserver/resilio-sync:latest"
    if [ -n "${extra_parameters}" ]; then
        docker run -d \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)" \
            ${mem_set} \
            ${log_opinion} \
            -e PUID=0 \
            -e PGID=0 \
            -e TZ=Asia/Shanghai \
            -p ${HT_PORT}:8888 \
            -p ${SYNC_PORT}:${SYNC_PORT} \
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
            -p ${SYNC_PORT}:${SYNC_PORT} \
            -v "${CONFIG_DIR}:/config" \
            -v "${CONFIG_DIR}/downloads:/downloads" \
            -v "${MEDIA_DIR}:/sync" \
            --restart=always \
            linuxserver/resilio-sync:latest
    fi

    if [ "${SYNC_PORT}" != "55555" ]; then
        start_time=$(date +%s)
        while true; do
            if [ -f "${CONFIG_DIR}/sync.conf" ]; then
                sed -i "/\"listening_port\"/c\    \"listening_port\": ${SYNC_PORT}," ${CONFIG_DIR}/sync.conf
                docker restart "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)"
                break
            fi
            current_time=$(date +%s)
            elapsed_time=$((current_time - start_time))
            if ((elapsed_time >= 300)); then
                break
            fi
            sleep 1
        done
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
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_resilio
        return_menu "main_resilio"
        ;;
    2)
        clear
        update_resilio
        return_menu "main_resilio"
        ;;
    3)
        clear
        unisntall_resilio
        return_menu "main_resilio"
        ;;
    0)
        clear
        main_xiaoya_all_emby
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
        main_resilio
        ;;
    esac

}

function once_sync_emby_config() {

    if command -v crontab > /dev/null 2>&1; then
        COMMAND_1=$(crontab -l | grep 'xiaoya_notify' | sed 's/^.*-s//; s/>>.*$//' | sed 's/--auto_update_all_pikpak=yes/--auto_update_all_pikpak=no/g')
        if [[ $COMMAND_1 == *"--force_update_config"* ]]; then
            if [[ $COMMAND_1 == *"--force_update_config=no"* ]]; then
                COMMAND_1="${COMMAND_1/--force_update_config=no/--force_update_config=yes}"
            fi
        else
            COMMAND_1="$COMMAND_1 --force_update_config=yes"
        fi
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
        COMMAND_1=$(grep 'xiaoya_notify' /etc/crontab | sed 's/^.*-s//; s/>>.*$//' | sed 's/--auto_update_all_pikpak=yes/--auto_update_all_pikpak=no/g')
        if [[ $COMMAND_1 == *"--force_update_config"* ]]; then
            if [[ $COMMAND_1 == *"--force_update_config=no"* ]]; then
                COMMAND_1="${COMMAND_1/--force_update_config=no/--force_update_config=yes}"
            fi
        else
            COMMAND_1="$COMMAND_1 --force_update_config=yes"
        fi
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
            container_update xiaoya-cron
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

function install_xiaoya_emd() {

    get_media_dir

    while true; do
        INFO "请输入您希望的爬虫同步间隔"
        WARN "循环时间必须大于12h，为了减轻服务器压力，请用户理解！"
        read -erp "请输入以小时为单位的正整数同步间隔时间（默认：12）：" sync_interval
        [[ -z "${sync_interval}" ]] && sync_interval="12"
        if [[ "$sync_interval" -ge 12 ]]; then
            break
        else
            ERROR "输入错误，请重新输入。同步间隔时间必须为12以上的正整数。"
        fi
    done
    cycle=$((sync_interval * 60 * 60))

    INFO "是否开启重启容器自动更新到最新程序 [Y/n]（默认 n 不开启）"
    WARN "需要拥有良好的上网环境才可以更新成功，要能访问 Github 和 Python PIP 库！"
    read -erp "RESTART_AUTO_UPDATE:" RESTART_AUTO_UPDATE
    [[ -z "${RESTART_AUTO_UPDATE}" ]] && TG="n"
    if [[ ${RESTART_AUTO_UPDATE} == [Yy] ]]; then
        RESTART_AUTO_UPDATE=true
    else
        RESTART_AUTO_UPDATE=false
    fi

    while true; do
        INFO "请选择镜像版本 [ 1；latest | 2；beta ]（默认 1）"
        read -erp "CHOOSE_IMAGE_VERSION:" CHOOSE_IMAGE_VERSION
        [[ -z "${CHOOSE_IMAGE_VERSION}" ]] && CHOOSE_IMAGE_VERSION="1"
        case ${CHOOSE_IMAGE_VERSION} in
        1)
            IMAGE_VERSION=latest
            break
            ;;
        2)
            IMAGE_VERSION=beta
            break
            ;;
        *)
            ERROR "输入无效，请重新选择"
            ;;
        esac
    done

    extra_parameters=
    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        local RETURN_DATA
        RETURN_DATA="$(data_crep "r" "install_xiaoya_emd")"
        if [ "${RETURN_DATA}" == "None" ]; then
            INFO "请输入运行参数（默认 --media /media ）"
            WARN "如果需要更改此设置请注意容器目录映射，默认媒体库路径映射到容器内的 /media 文件夹下！"
            WARN "警告！！！ 默认请勿修改 /media 路径！！！"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters="--media /media"
            data_crep "write" "install_xiaoya_emd"
        else
            INFO "已读取您上次设置的运行参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
            WARN "如果需要更改此设置请注意容器目录映射，默认媒体库路径映射到容器内的 /media 文件夹下！"
            WARN "警告！！！ 默认请勿修改 /media 路径！！！"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
        fi
    else
        extra_parameters="--media /media"
        data_crep "write" "install_xiaoya_emd"
    fi
    script_extra_parameters="${extra_parameters}"

    extra_parameters=
    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        local RETURN_DATA_2
        RETURN_DATA_2="$(data_crep "r" "install_xiaoya_emd_2")"
        if [ "${RETURN_DATA_2}" == "None" ]; then
            INFO "请输入运行容器额外参数（默认 无 ）"
            read -erp "Extra parameters:" extra_parameters
            data_crep "w" "install_xiaoya_emd_2"
        else
            INFO "已读取您上次设置的运行容器额外参数：${RETURN_DATA_2} (默认不更改回车继续，如果需要更改请输入新参数)"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA_2}
        fi
    fi
    run_extra_parameters="${extra_parameters}"

    docker_pull "ddsderek/xiaoya-emd:${IMAGE_VERSION}"

    docker run -d \
        --name=xiaoya-emd \
        --restart=always \
        --net=host \
        -v "${MEDIA_DIR}/xiaoya:/media" \
        -e "CYCLE=${cycle}" \
        -e "RESTART_AUTO_UPDATE=${RESTART_AUTO_UPDATE}" \
        -e TZ=Asia/Shanghai \
        ${run_extra_parameters} \
        ddsderek/xiaoya-emd:${IMAGE_VERSION} \
        ${script_extra_parameters}

    INFO "安装完成！"

}

function update_xiaoya_emd() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新小雅元数据定时爬虫${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update xiaoya-emd

}

function unisntall_xiaoya_emd() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅元数据定时爬虫${Blue} $i ${Font}\r"
        sleep 1
    done

    docker stop xiaoya-emd
    docker rm xiaoya-emd
    docker rmi ddsderek/xiaoya-emd:latest

    INFO "小雅元数据定时爬虫卸载成功！"

}

function main_xiaoya_emd() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅元数据定时爬虫${Font}\n"
    echo -e "${Sky_Blue}小雅元数据定时爬虫由 https://github.com/Rik-F5 更新维护，在此表示感谢！"
    echo -e "具体详细配置参数请看项目README：https://github.com/Rik-F5/xiaoya_db${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_xiaoya_emd
        return_menu "main_xiaoya_emd"
        ;;
    2)
        clear
        update_xiaoya_emd
        return_menu "main_xiaoya_emd"
        ;;
    3)
        clear
        unisntall_xiaoya_emd
        return_menu "main_xiaoya_emd"
        ;;
    0)
        clear
        main_xiaoya_all_emby
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
        main_xiaoya_emd
        ;;
    esac

}

function uninstall_xiaoya_all_emby() {

    INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
    read -erp "Clean config:" CLEAN_CONFIG
    [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅Emby全家桶${Blue} $i ${Font}\r"
        sleep 1
    done
    IMAGE_NAME="$(docker inspect --format='{{.Config.Image}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)")"
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)"
    docker rmi "${IMAGE_NAME}"
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

function uninstall_xiaoya_all_jellyfin() {

    OLD_MEDIA_DIR=$(docker inspect \
        --format='{{range .Mounts}}{{if eq .Destination "/config"}}{{.Source}}{{end}}{{end}}' \
        "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt)" |
        sed 's!/[^/]*$!!')
    INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
    INFO "配置文件路径：${OLD_MEDIA_DIR}"
    read -erp "Clean config:" CLEAN_CONFIG
    [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅Jellyfin全家桶${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt)"
    cpu_arch=$(uname -m)
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        docker rmi nyanmisaka/jellyfin:240220-amd64-legacy
        ;;
    "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        docker rmi nyanmisaka/jellyfin:240220-arm64
        ;;
    esac
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        rm -rf "${OLD_MEDIA_DIR}"
    fi

    INFO "Jellyfin 全家桶卸载成功！"

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
    echo -e "9、安装/更新/卸载 小雅元数据定时爬虫          当前状态：$(judgment_container xiaoya-emd)"
    echo -e "10、卸载Emby全家桶"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-10]:" num
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
        INFO "Emby 全家桶安装完成！ "
        return_menu "main_xiaoya_all_emby"
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
        return_menu "main_xiaoya_all_emby"
        ;;
    4)
        clear
        WARN "此功能已弃用！"
        return_menu "main_xiaoya_all_emby"
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
        return_menu "main_xiaoya_all_emby"
        ;;
    8)
        clear
        get_config_dir
        bash -c "$(curl -sLk https://ddsrem.com/xiaoya/emby_config_editor.sh)" -s ${CONFIG_DIR}
        main_xiaoya_all_emby
        ;;
    9)
        clear
        main_xiaoya_emd
        ;;
    10)
        clear
        uninstall_xiaoya_all_emby
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-10]'
        main_xiaoya_all_emby
        ;;
    esac

}

function main_xiaoya_all_jellyfin() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Jellyfin全家桶${Font}\n"
    echo -e "${Sky_Blue}Jellyfin 全家桶元数据由 AI老G 更新维护，在此表示感谢！"
    echo -e "Jellyfin 全家桶安装前提条件："
    echo -e "1. 硬盘140G以上（如果无需完整安装则 60G 以上即可）"
    echo -e "2. 内存3.5G以上空余空间${Font}\n"
    echo -e "1、一键安装Jellyfin全家桶"
    echo -e "2、下载/解压 元数据"
    echo -e "3、安装Jellyfin"
    echo -e "4、卸载Jellyfin全家桶"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-4]:" num
    case "$num" in
    1)
        clear
        download_unzip_xiaoya_all_jellyfin
        install_jellyfin_xiaoya_all_jellyfin
        INFO "Jellyfin 全家桶安装完成！ "
        return_menu "main_xiaoya_all_jellyfin"
        ;;
    2)
        clear
        main_download_unzip_xiaoya_jellyfin
        ;;
    3)
        clear
        get_config_dir
        get_media_dir
        install_jellyfin_xiaoya_all_jellyfin
        return_menu "main_xiaoya_all_jellyfin"
        ;;
    4)
        clear
        uninstall_xiaoya_all_jellyfin
        return_menu "main_xiaoya_all_jellyfin"
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-4]'
        main_xiaoya_all_jellyfin
        ;;
    esac

}

function xiaoyahelper_install_check() {
    local URL="$1"
    if bash -c "$(curl --insecure -fsSL ${URL} | tail -n +2)" -s "${MODE}" ${TG_CHOOSE}; then
        if docker container inspect xiaoyakeeper > /dev/null 2>&1; then
            INFO "安装完成！"
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
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
        TG_CHOOSE="-tg"
    fi

    docker_pull "library/alpine:3.18.2"

    XIAOYAHELPER_URL="https://xiaoyahelper.ddsrem.com/aliyun_clear.sh"
    if xiaoyahelper_install_check "${XIAOYAHELPER_URL}"; then
        return 0
    fi
    XIAOYAHELPER_URL="https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh"
    if xiaoyahelper_install_check "${XIAOYAHELPER_URL}"; then
        return 0
    fi
    ERROR "安装失败！"
    return 1

}

function once_xiaoyahelper() {

    INFO "是否使用Telegram通知 [Y/n]（默认 n 不使用）"
    read -erp "TG:" TG
    [[ -z "${TG}" ]] && TG="n"
    if [[ ${TG} == [Yy] ]]; then
        TG_CHOOSE="-tg"
    fi

    XIAOYAHELPER_URL="https://xiaoyahelper.ddsrem.com/aliyun_clear.sh"
    if bash -c "$(curl --insecure -fsSL ${XIAOYAHELPER_URL} | tail -n +2)" -s 1 ${TG_CHOOSE}; then
        INFO "运行完成！"
    else
        XIAOYAHELPER_URL="https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh"
        if bash -c "$(curl --insecure -fsSL ${XIAOYAHELPER_URL} | tail -n +2)" -s 1 ${TG_CHOOSE}; then
            INFO "安装完成！"
        else
            ERROR "安装失败！"
            exit 1
        fi
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

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅助手（xiaoyahelper）${Font}\n"
    echo -e "1、安装/更新"
    echo -e "2、一次性运行"
    echo -e "3、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_xiaoyahelper
        return_menu "main_xiaoyahelper"
        ;;
    2)
        clear
        once_xiaoyahelper
        ;;
    3)
        clear
        uninstall_xiaoyahelper
        return_menu "main_xiaoyahelper"
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
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

    INFO "是否使用内存优化版镜像 [Y/n]（默认 n 不使用）"
    read -erp "Native:" choose_native
    [[ -z "${choose_native}" ]] && choose_native="n"
    if [[ ${choose_native} == [Yy] ]]; then
        __choose_native="native"
    else
        __choose_native="latest"
    fi

    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        local RETURN_DATA
        RETURN_DATA="$(data_crep "r" "install_xiaoya_alist_tvbox")"
        if [ "${RETURN_DATA}" == "None" ]; then
            INFO "请输入其他参数（默认 无 ）"
            read -erp "Extra parameters:" extra_parameters
            data_crep "w" "install_xiaoya_alist_tvbox"
        else
            INFO "已读取您上次设置的参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
        fi
    fi

    if ls ${CONFIG_DIR}/*.txt 1> /dev/null 2>&1; then
        INFO "备份小雅配置数据中..."
        mkdir -p ${CONFIG_DIR}/xiaoya_backup
        cp -rf ${CONFIG_DIR}/*.txt ${CONFIG_DIR}/xiaoya_backup
        INFO "完成备份小雅配置数据！"
        INFO "备份数据路径：${CONFIG_DIR}/xiaoya_backup"
    fi

    docker_pull "haroldli/xiaoya-tvbox:latest"

    if [ -n "${extra_parameters}" ]; then
        docker run -itd \
            -p "${HT_PORT}":4567 \
            -p "${ALIST_PORT}":80 \
            -e ALIST_PORT="${ALIST_PORT}" \
            -e MEM_OPT="${MEM_OPT}" \
            -e TZ=Asia/Shanghai \
            -v "${CONFIG_DIR}:/data" \
            ${extra_parameters} \
            --restart=always \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)" \
            haroldli/xiaoya-tvbox:${__choose_native}
    else
        docker run -itd \
            -p "${HT_PORT}":4567 \
            -p "${ALIST_PORT}":80 \
            -e ALIST_PORT="${ALIST_PORT}" \
            -e MEM_OPT="${MEM_OPT}" \
            -e TZ=Asia/Shanghai \
            -v "${CONFIG_DIR}:/data" \
            --restart=always \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)" \
            haroldli/xiaoya-tvbox:${__choose_native}
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
    IMAGE_NAME="$(docker inspect --format='{{.Config.Image}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)")"
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)"
    docker rmi "${IMAGE_NAME}"
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
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_xiaoya_alist_tvbox
        return_menu "main_xiaoya_alist_tvbox"
        ;;
    2)
        clear
        update_xiaoya_alist_tvbox
        return_menu "main_xiaoya_alist_tvbox"
        ;;
    3)
        clear
        uninstall_xiaoya_alist_tvbox
        return_menu "main_xiaoya_alist_tvbox"
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
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

    docker_pull "msterzhang/onelist:latest"

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
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_onelist
        return_menu "main_onelist"
        ;;
    2)
        clear
        update_onelist
        return_menu "main_onelist"
        ;;
    3)
        clear
        uninstall_onelist
        return_menu "main_onelist"
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
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

    docker_pull "portainer/portainer-ce:${TAG}"

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
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_portainer
        return_menu "main_portainer"
        ;;
    2)
        clear
        update_portainer
        return_menu "main_portainer"
        ;;
    3)
        clear
        uninstall_portainer
        return_menu "main_portainer"
        ;;
    0)
        clear
        main_other_tools
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
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

    docker_pull "shenxianmq/auto_symlink:latest"

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
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_auto_symlink
        return_menu "main_auto_symlink"
        ;;
    2)
        clear
        update_auto_symlink
        return_menu "main_auto_symlink"
        ;;
    3)
        clear
        uninstall_auto_symlink
        return_menu "main_auto_symlink"
        ;;
    0)
        clear
        main_other_tools
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
        main_auto_symlink
        ;;
    esac

}

function main_casaos() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}CasaOS${Font}\n"
    echo -e "1、安装"
    echo -e "2、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-2]:" num
    case "$num" in
    1)
        clear
        curl -fsSL https://get.casaos.io | sudo bash
        return_menu "main_casaos"
        ;;
    2)
        clear
        casaos-uninstall
        return_menu "main_casaos"
        ;;
    0)
        clear
        main_other_tools
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-2]'
        main_casaos
        ;;
    esac

}

function main_docker_compose() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Docker Compose 小雅及全家桶${Font}\n"
    echo -e "${Sky_Blue}Docker Compose 安装方式由 https://link.monlor.com/ 更新维护，在此表示感谢！"
    echo -e "具体详细介绍请看项目README：https://github.com/monlor/docker-xiaoya${Font}\n"
    echo -e "1、安装"
    echo -e "2、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-2]:" num
    case "$num" in
    1)
        clear
        INFO "是否使用加速源 [Y/n]（默认 N）"
        read -erp "USE_PROXY:" USE_PROXY
        [[ -z "${USE_PROXY}" ]] && USE_PROXY="n"
        if [[ ${USE_PROXY} == [Yy] ]]; then
            export GH_PROXY=https://gh.monlor.com/ IMAGE_PROXY=ghcr.monlor.com
        fi
        bash -c "$(curl -fsSL ${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/main/install.sh)"
        return_menu "main_docker_compose"
        ;;
    2)
        clear
        INFO "是否使用加速源 [Y/n]（默认 N）"
        read -erp "USE_PROXY:" USE_PROXY
        [[ -z "${USE_PROXY}" ]] && USE_PROXY="n"
        if [[ ${USE_PROXY} == [Yy] ]]; then
            export GH_PROXY=https://gh.monlor.com/ IMAGE_PROXY=ghcr.monlor.com
        fi
        bash -c "$(curl -fsSL ${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/main/uninstall.sh)"
        return_menu "main_docker_compose"
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-2]'
        main_docker_compose
        ;;
    esac

}

function auto_choose_image_mirror() {

    for i in "${!mirrors[@]}"; do
        local output
        output=$(
            curl -s -o /dev/null -w '%{time_total}' --head --request GET "${mirrors[$i]}"
            echo $? > /tmp/curl_exit_status_${i} &
        )
        status[$i]=$!
        delays[$i]=$output
    done
    better_time=9999999999
    for i in "${!mirrors[@]}"; do
        local time_compare result
        wait ${status[$i]}
        result=$(cat /tmp/curl_exit_status_${i})
        rm -f /tmp/curl_exit_status_${i}
        if [ $result -eq 0 ]; then
            if [ "${mirrors[$i]}" == "docker.io" ]; then
                time_compare=$(awk -v n1="1" -v n2="$result" 'BEGIN {print (n1>n2)? "1":"0"}')
                if [ $time_compare -eq 1 ]; then
                    better_mirror=${mirrors[$i]}
                    better_time=0
                fi
            else
                time_compare=$(awk -v n1="$better_time" -v n2="$result" 'BEGIN {print (n1>n2)? "1":"0"}')
                if [ $time_compare -eq 1 ]; then
                    better_mirror=${mirrors[$i]}
                    better_time=${delays[$i]}
                fi
            fi
        fi
    done
    if [ -z "${better_mirror}" ]; then
        return 1
    else
        echo -e "${better_mirror}" > ${DDSREM_CONFIG_DIR}/image_mirror.txt
        if docker pull "${better_mirror}/library/hello-world:latest" &> /dev/null; then
            docker rmi "${better_mirror}/library/hello-world:latest" &> /dev/null
            return 0
        else
            return 1
        fi
    fi

}

function choose_image_mirror() {

    local num
    local current_mirror interface
    current_mirror="$(cat "${DDSREM_CONFIG_DIR}/image_mirror.txt")"
    declare -i s
    local s=0
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Docker镜像源选择\n${Font}"
    echo -ne "${INFO} 界面加载中...${Font}\r"
    interface="${Sky_Blue}绿色字体代表当前选中的镜像源"
    interface="${interface}\n选择镜像源后会自动检测是否可连接，如果预选镜像源都无法使用请自定义镜像源${Font}\n"
    local status=()
    for i in "${!mirrors[@]}"; do
        local output
        output=$(
            curl -s -o /dev/null -w '%{time_total}' --head --request GET "${mirrors[$i]}"
            echo $? > /tmp/curl_exit_status_${i} &
        )
        status[$i]=$!
        delays[$i]=$(printf "%.2f" $output)
    done
    for i in "${!mirrors[@]}"; do
        wait ${status[$i]}
        local result
        result=$(cat /tmp/curl_exit_status_${i})
        rm -f /tmp/curl_exit_status_${i}
        local color=
        local font=
        if [[ "${mirrors[$i]}" == "${current_mirror}" ]]; then
            color="${Green}"
            font="${Font}"
            s+=1
        fi
        if [ $result -eq 0 ]; then
            interface="${interface}\n$((i + 1))、${color}${mirrors[$i]}${font} (${Green}可用${Font} ${Sky_Blue}延迟: ${delays[$i]}秒${Font})"
        else
            interface="${interface}\n$((i + 1))、${color}${mirrors[$i]}${font} (${Red}不可用${Font})"
        fi
        z=$((i + 2))
    done
    if user_delay=$(curl -s -o /dev/null -w '%{time_total}' --head --request GET "$(cat "${DDSREM_CONFIG_DIR}/image_mirror_user.txt")"); then
        USER_TEST_STATUS="(${Green}可用${Font} ${Sky_Blue}延迟: ${user_delay}秒${Font})"
    else
        USER_TEST_STATUS="(${Red}不可用${Font})"
    fi
    if [ "${s}" == "1" ]; then
        interface="${interface}\n${z}、自定义源：$(cat "${DDSREM_CONFIG_DIR}/image_mirror_user.txt") ${USER_TEST_STATUS}"
    else
        interface="${interface}\n${z}、${Green}自定义源：$(cat "${DDSREM_CONFIG_DIR}/image_mirror_user.txt")${Font} ${USER_TEST_STATUS}"
    fi
    echo -e "${interface}\n0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-${z}]:" num
    if [ "${num}" == "0" ]; then
        clear
        "${1}"
    elif [ "${num}" == "${z}" ]; then
        clear
        INFO "请输入自定义源地址（当前自定义源地址为：$(cat "${DDSREM_CONFIG_DIR}/image_mirror_user.txt")，回车默认不修改）"
        read -erp "custom_url:" custom_url
        [[ -z "${custom_url}" ]] && custom_url=$(cat "${DDSREM_CONFIG_DIR}/image_mirror_user.txt")
        echo "${custom_url}" > ${DDSREM_CONFIG_DIR}/image_mirror.txt
        echo "${custom_url}" > ${DDSREM_CONFIG_DIR}/image_mirror_user.txt
    else
        for i in "${!mirrors[@]}"; do
            if [[ "$((i + 1))" == "${num}" ]]; then
                echo -e "${mirrors[$i]}" > ${DDSREM_CONFIG_DIR}/image_mirror.txt
                break
            fi
        done
    fi
    clear
    INFO "开始镜像源地址连通性测试..."
    local retries=0
    local max_retries=3
    IMAGE_MIRROR=$(cat "${DDSREM_CONFIG_DIR}/image_mirror.txt")
    while [ $retries -lt $max_retries ]; do
        if docker pull "${IMAGE_MIRROR}/library/hello-world:latest"; then
            INFO "地址连通性测试正常！"
            break
        else
            WARN "地址连通性测试失败，正在进行第 $((retries + 1)) 次重试..."
            retries=$((retries + 1))
        fi
    done
    if [ $retries -eq $max_retries ]; then
        ERROR "地址连通性测试失败，已达到最大重试次数，请选择镜像源或者自定义镜像源！"
    else
        docker rmi "${IMAGE_MIRROR}/library/hello-world:latest"
    fi
    INFO "按任意键返回 Docker镜像源选择 菜单"
    read -rs -n 1 -p ""
    clear
    choose_image_mirror "${1}"

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

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt ]; then
        xiaoya_jellyfin_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt)
    else
        echo 'jellyfin' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt
        xiaoya_jellyfin_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt)
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
    echo -e "8、更改 Jellyfin 容器名             （当前：${Green}${xiaoya_jellyfin_name}${Font}）"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-8]:" num
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
        change_container_name "xiaoya_jellyfin_name"
        ;;
    0)
        clear
        main_advanced_configuration
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-8]'
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
        main_return
    else
        return 0
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
    echo -e "6、Docker镜像源选择"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-6]:" num
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
        return_menu "main_advanced_configuration"
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
        choose_image_mirror "main_advanced_configuration"
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-6]'
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
    echo -e "4、安装/卸载 CasaOS"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-4]:" num
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
        main_casaos
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-4]'
        main_other_tools
        ;;
    esac

}

function main_return() {

    local out_tips
    cat /tmp/xiaoya_alist
    echo -ne "${INFO} 主界面加载中...${Font}\r"
    if ! curl -s -o /dev/null -w '%{time_total}' --head --request GET "$(cat "${DDSREM_CONFIG_DIR}/image_mirror.txt")" &> /dev/null; then
        if auto_choose_image_mirror; then
            out_tips="${Green}提示：已为您自动配置Docker镜像源地址为: $(cat "${DDSREM_CONFIG_DIR}/image_mirror.txt")${Font}\n"
        else
            out_tips="${Red}警告：当前环境无法访问Docker镜像仓库，请输入96进入Docker镜像源设置更改镜像源${Font}\n"
        fi
    fi
    echo -e "${out_tips}1、安装/更新/卸载 小雅Alist                   当前状态：$(judgment_container "${xiaoya_alist_name}")
2、安装/卸载 小雅Emby全家桶                   当前状态：$(judgment_container "${xiaoya_emby_name}")
3、安装/卸载 小雅Jellyfin全家桶               当前状态：$(judgment_container "${xiaoya_jellyfin_name}")
4、安装/更新/卸载 小雅助手（xiaoyahelper）    当前状态：$(judgment_container xiaoyakeeper)
5、安装/更新/卸载 小雅Alist-TVBox             当前状态：$(judgment_container "${xiaoya_tvbox_name}")
6、安装/更新/卸载 Onelist                     当前状态：$(judgment_container "${xiaoya_onelist_name}")
7、Docker Compose 安装/卸载 小雅及全家桶（实验性功能）
8、其他工具 | Script info: ${DATE_VERSION} OS: ${_os},${OSNAME},${is64bit}
9、高级配置 | Docker version: ${Blue}${DOCKER_VERSION}${Font} ${IP_CITY}
0、退出脚本 | Thanks: ${Sky_Blue}heiheigui,xiaoyaLiu,Harold,AI老G,monlor,Rik${Font}
——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-9]:" num
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
        main_xiaoya_all_jellyfin
        ;;
    4)
        clear
        main_xiaoyahelper
        ;;
    5)
        clear
        main_xiaoya_alist_tvbox
        ;;
    6)
        clear
        main_onelist
        ;;
    7)
        clear
        main_docker_compose
        ;;
    8)
        clear
        main_other_tools
        ;;
    9)
        clear
        main_advanced_configuration
        ;;
    96)
        clear
        choose_image_mirror "main_return"
        ;;
    0)
        clear
        exit 0
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-9]'
        main_return
        ;;
    esac
}

function first_init() {

    clear

    INFO "初始化中，请稍等...."

    root_need

    get_os

    CITY="$(curl -fsSL -m 10 -s http://ipinfo.io/json | sed -n 's/.*"city": *"\([^"]*\)".*/\1/p')"
    if [ -n "${CITY}" ]; then
        IP_CITY="IP City: ${Yellow}${CITY}${Font}"
    fi

    DOCKER_VERSION="$(docker -v | sed "s/Docker version //g" | cut -d',' -f1)"

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

    if [ ! -d ${DDSREM_CONFIG_DIR}/data_crep ]; then
        mkdir -p ${DDSREM_CONFIG_DIR}/data_crep
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

    if [ ! -f "${DDSREM_CONFIG_DIR}/image_mirror.txt" ]; then
        if ! auto_choose_image_mirror; then
            echo 'docker.io' > ${DDSREM_CONFIG_DIR}/image_mirror.txt
        fi
    fi
    if [ ! -f "${DDSREM_CONFIG_DIR}/image_mirror_user.txt" ]; then
        touch ${DDSREM_CONFIG_DIR}/image_mirror_user.txt
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
        if ! curl -sL https://fastly.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/xiaoya_alist -o /tmp/xiaoya_alist; then
            curl -sL https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/xiaoya_alist -o /tmp/xiaoya_alist
            if ! grep -q 'alias xiaoya' /etc/profile; then
                echo -e "alias xiaoya='bash -c \"\$(curl -sLk https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/xiaoya_alist)\"'" >> /etc/profile
            fi
        else
            if ! grep -q 'alias xiaoya' /etc/profile; then
                echo -e "alias xiaoya='bash -c \"\$(curl -sLk https://fastly.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/xiaoya_alist)\"'" >> /etc/profile
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
    main_return
else
    first_init
    clear
    "$@"
fi
