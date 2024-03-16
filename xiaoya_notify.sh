#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC2086
PATH=${PATH}:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/opt/homebrew/bin
export PATH

Green="\033[32m"
Red="\033[31m"
Yellow='\033[33m'
Font="\033[0m"
INFO="[${Green}INFO${Font}]"
ERROR="[${Red}ERROR${Font}]"
WARN="[${Yellow}WARN${Font}]"
Time=$(date +"%Y-%m-%d %T")
function INFO() {
    echo -e "${Time} ${INFO} ${1}"
}
function ERROR() {
    echo -e "${Time} ${ERROR} ${1}"
}
function WARN() {
    echo -e "${Time} ${WARN} ${1}"
}

function container_update() {

    docker pull containrrr/watchtower:latest
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        containrrr/watchtower:latest \
        --run-once \
        --cleanup \
        "${@}"
    docker rmi containrrr/watchtower:latest
    INFO "${*} 更新成功"

}

function pull_run_glue() {

    if docker inspect xiaoyaliu/glue:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/glue:latest | cut -f2 -d:)
        remote_sha=$(curl -s "https://hub.docker.com/v2/repositories/xiaoyaliu/glue/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ ! "$local_sha" == "$remote_sha" ]; then
            docker rmi xiaoyaliu/glue:latest
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
    if curl -siL http://127.0.0.1:5678/d/README.md | grep -v 302 | grep "x-oss-" > /dev/null 2>&1; then
        xiaoya_addr="http://127.0.0.1:5678"
    elif curl -siL http://${docker0}:5678/d/README.md | grep -v 302 | grep "x-oss-" > /dev/null 2>&1; then
        xiaoya_addr="http://${docker0}:5678"
    else
        if [ -s ${CONFIG_DIR}/docker_address.txt ]; then
            docker_address=$(head -n1 ${CONFIG_DIR}/docker_address.txt)
            if curl -siL ${docker_address}/d/README.md | grep -v 302 | grep "x-oss-" > /dev/null 2>&1; then
                xiaoya_addr=${docker_address}
            else
                ERROR "请检查xiaoya是否正常运行后再试"
                docker logs --tail 8 ${XIAOYA_NAME}
                exit 1
            fi
        else
            ERROR "请先配置 ${CONFIG_DIR}/docker_address.txt 后重试"
            exit 1
        fi
    fi

    INFO "连接小雅地址为 ${xiaoya_addr}"

}

function update_media() {

    INFO "开始更新 ${1}"

    chown 0:0 "${MEDIA_DIR}"/temp
    chmod 777 "${MEDIA_DIR}"/temp
    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))
    INFO "磁盘容量：${free_size_G}G"

    if [ -f "${MEDIA_DIR}/temp/${1}" ]; then
        INFO "清理旧 ${1} 中..."
        rm -f ${MEDIA_DIR}/temp/${1}
    fi

    INFO "开始下载 ${1} ..."

    extra_parameters="--workdir=/media/temp"

    _os_all=$(uname -a)
    if echo -e "${_os_all}" | grep -Eqi "UGREEN"; then
        INFO "wget 下载模式"
        pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/${1}"
    else
        INFO "aria2c 下载模式"
        pull_run_glue aria2c -o "${1}" --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${xiaoya_addr}/d/元数据/${1}"
    fi

    INFO "设置目录权限..."
    chmod 777 "${MEDIA_DIR}"/temp/"${1}"
    chown 0:0 "${MEDIA_DIR}"/temp/"${1}"

    INFO "${1} 下载完成！"

    docker stop ${RESILIO_NAME}

    INFO "开始解压 ${1} ..."

    if [ "${1}" == "all.mp4" ]; then
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
        chmod 777 -R "${MEDIA_DIR}"/xiaoya
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
        chmod 777 -R "${MEDIA_DIR}"/xiaoya
    fi

    docker start ${RESILIO_NAME}

    INFO "${1} 更新完成"

}

function compare_metadata_size() {

    pull_run_glue xh --headers --follow -o /media/headers.log "${xiaoya_addr}/d/元数据/${1}"
    REMOTE_METADATA_SIZE=$(cat ${MEDIA_DIR}/headers.log | grep 'Content-Length' | awk '{print $2}')
    rm -f ${MEDIA_DIR}/headers.log

    if [ -f "${MEDIA_DIR}/temp/${1}" ] && [ ! -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
        LOCAL_METADATA_SIZE=$(du -b "${MEDIA_DIR}/temp/${1}" | awk '{print $1}')
    else
        LOCAL_METADATA_SIZE=0
    fi

    INFO "${1} REMOTE_METADATA_SIZE: ${REMOTE_METADATA_SIZE}"
    INFO "${1} LOCAL_METADATA_SIZE: ${LOCAL_METADATA_SIZE}"

    if [ ! "${REMOTE_METADATA_SIZE}" == "${LOCAL_METADATA_SIZE}" ] && [ -n "${REMOTE_METADATA_SIZE}" ] && [ "${REMOTE_METADATA_SIZE}" -gt 3221225472 ]; then
        __COMPARE_METADATA_SIZE=2
    else
        __COMPARE_METADATA_SIZE=1
    fi

}

function detection_all_pikpak_update() {

    compare_metadata_size "all.mp4"
    if [ "${__COMPARE_METADATA_SIZE}" == "1" ]; then
        INFO "跳过 all.mp4 更新"
    else
        update_media "all.mp4"
    fi

    compare_metadata_size "pikpak.mp4"
    if [ "${__COMPARE_METADATA_SIZE}" == "1" ]; then
        INFO "跳过 pikpak.mp4 更新"
    else
        update_media "pikpak.mp4"
    fi

    INFO "全部媒体元数据更新完成！"

}

function detection_config_update() {

    compare_metadata_size "config.mp4"
    if [ "${__COMPARE_METADATA_SIZE}" == "1" ]; then
        INFO "跳过 config.mp4 更新"
    else
        bash -c "$(curl http://docker.xiaoya.pro/sync_emby_config.sh)" -s ${MEDIA_DIR} ${CONFIG_DIR} ${EMBY_NAME} ${RESILIO_NAME}
    fi

}

function detection_xiaoya_version_update() {

    REMOTE_XIAOYA_VERSION=$(curl -skL https://docker.xiaoya.pro/version.txt | head -n 1 | sed "s/\r$//g")

    LOCAL_XIAOYA_VERSION=$(docker exec -it ${XIAOYA_NAME} cat /version.txt | head -n 1 | sed "s/\r$//g")

    INFO "REMOTE_XIAOYA_VERSION: ${REMOTE_XIAOYA_VERSION}"
    INFO "LOCAL_XIAOYA_VERSION: ${LOCAL_XIAOYA_VERSION}"

    if [ "${REMOTE_XIAOYA_VERSION}" == "${LOCAL_XIAOYA_VERSION}" ] || [ "${REMOTE_XIAOYA_VERSION}" == "" ]; then
        INFO "跳过小雅容器重启"
    else
        docker restart ${XIAOYA_NAME}
    fi

}

function detection_xiaoya_image_update() {

    if docker inspect xiaoyaliu/alist:latest > /dev/null 2>&1; then
        if docker inspect xiaoyaliu/alist:latest > /dev/null 2>&1; then
            local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/alist:latest | cut -f2 -d:)
            remote_sha=$(curl -s "https://hub.docker.com/v2/repositories/xiaoyaliu/alist/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
            INFO "remote_sha: ${remote_sha}"
            INFO "local_sha: ${local_sha}"
            if [ ! "${local_sha}" == "${remote_sha}" ]; then
                container_update "${XIAOYA_NAME}"
            else
                INFO "跳过小雅容器更新"
            fi
        fi
    elif docker inspect xiaoyaliu/alist:hostmode > /dev/null 2>&1; then
        if docker inspect xiaoyaliu/alist:hostmode > /dev/null 2>&1; then
            local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/alist:hostmode | cut -f2 -d:)
            remote_sha=$(curl -s "https://hub.docker.com/v2/repositories/xiaoyaliu/alist/tags/hostmode" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
            INFO "remote_sha: ${remote_sha}"
            INFO "local_sha: ${local_sha}"
            if [ ! "${local_sha}" == "${remote_sha}" ]; then
                container_update "${XIAOYA_NAME}"
            else
                INFO "跳过小雅容器更新"
            fi
        fi
    fi

}

while [[ $# -gt 0 ]]; do
    case "$1" in
    --config_dir=*)
        CONFIG_DIR="${1#*=}"
        shift
        ;;
    --media_dir=*)
        MEDIA_DIR="${1#*=}"
        shift
        ;;
    --emby_name=*)
        EMBY_NAME="${1#*=}"
        shift
        ;;
    --resilio_name=*)
        RESILIO_NAME="${1#*=}"
        shift
        ;;
    --xiaoya_name=*)
        XIAOYA_NAME="${1#*=}"
        shift
        ;;
    --auto_update_config=*)
        AUTO_UPDATE_CONFIG="${1#*=}"
        shift
        ;;
    --auto_update_all_pikpak=*)
        AUTO_UPDATE_ALL_PIKPAK="${1#*=}"
        shift
        ;;
    *)
        shift
        ;;
    esac
done

if [ -z ${MEDIA_DIR} ]; then
    ERROR "请配置媒体目录后重试！"
    exit 1
fi

if [ -z ${CONFIG_DIR} ]; then
    CONFIG_DIR=/etc/xiaoya
fi

if [ -z ${EMBY_NAME} ]; then
    EMBY_NAME=emby
fi

if [ -z ${RESILIO_NAME} ]; then
    RESILIO_NAME=resilio
fi

if [ -z ${XIAOYA_NAME} ]; then
    XIAOYA_NAME=xiaoya
fi

if [ -z ${AUTO_UPDATE_CONFIG} ]; then
    AUTO_UPDATE_CONFIG=true
fi

if [ -z ${AUTO_UPDATE_ALL_PIKPAK} ]; then
    AUTO_UPDATE_ALL_PIKPAK=true
fi

INFO "小雅配置目录：${CONFIG_DIR}"
INFO "媒体库目录：${MEDIA_DIR}"
INFO "Emby 容器名称：${EMBY_NAME}"
INFO "Resilio 容器名称：${RESILIO_NAME}"
INFO "小雅容器名称：${XIAOYA_NAME}"

test_xiaoya_status
# all.mp4 和 pikpak.mp4
if [ "${AUTO_UPDATE_CONFIG}" == "true" ]; then
    detection_all_pikpak_update
else
    INFO "all.mp4 和 pikpak.mp4 更新已关闭"
fi
# config.mp4
if [ "${AUTO_UPDATE_CONFIG}" == "true" ]; then
    detection_config_update
else
    INFO "Emby config sync 已关闭"
fi
# xiaoya version
detection_xiaoya_version_update
# xiaoya image
detection_xiaoya_image_update
