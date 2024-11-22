#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC2086
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
# This is free software, licensed under the GNU General Public License v3.0.
#
# ——————————————————————————————————————————————————————————————————————————————————

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

    local run_image remove_image IMAGE_MIRROR pull_image
    if docker inspect ddsderek/runlike:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' ddsderek/runlike:latest 2> /dev/null | cut -f2 -d:)
        remote_sha=$(curl -s -m 10 "https://hub.docker.com/v2/repositories/ddsderek/runlike/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ "$local_sha" != "$remote_sha" ]; then
            docker rmi ddsderek/runlike:latest
            docker_pull "ddsderek/runlike:latest"
        fi
    else
        docker_pull "ddsderek/runlike:latest"
    fi
    INFO "获取 ${1} 容器信息中..."
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp ddsderek/runlike "${@}" > "/tmp/container_update_${*}"
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

function pull_run_glue() {

    if docker inspect xiaoyaliu/glue:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/glue:latest 2> /dev/null | cut -f2 -d:)
        remote_sha=$(curl -s -m 10 "https://hub.docker.com/v2/repositories/xiaoyaliu/glue/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
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
        docker run -i \
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
        docker run -i \
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

function pull_run_glue_xh() {

    BUILDER_NAME="xiaoya_builder_$(date +%S%N | cut -c 7-11)"

    if docker inspect xiaoyaliu/glue:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/glue:latest 2> /dev/null | cut -f2 -d:)
        remote_sha=$(curl -s -m 10 "https://hub.docker.com/v2/repositories/xiaoyaliu/glue/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
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
        docker run -itd \
            --security-opt seccomp=unconfined \
            --name=${BUILDER_NAME} \
            --net=host \
            -v "${MEDIA_DIR}:/media" \
            -v "${CONFIG_DIR}:/etc/xiaoya" \
            ${extra_parameters} \
            -e LANG=C.UTF-8 \
            xiaoyaliu/glue:latest \
            "${@}" > /dev/null 2>&1
    else
        docker run -itd \
            --security-opt seccomp=unconfined \
            --name=${BUILDER_NAME} \
            --net=host \
            -v "${MEDIA_DIR}:/media" \
            -v "${CONFIG_DIR}:/etc/xiaoya" \
            -e LANG=C.UTF-8 \
            xiaoyaliu/glue:latest \
            "${@}" > /dev/null 2>&1
    fi

    timeout=20
    start_time=$(date +%s)
    end_time=$((start_time + timeout))
    while [ "$(date +%s)" -lt $end_time ]; do
        status=$(docker inspect -f '{{.State.Status}}' "${BUILDER_NAME}")
        if [ "$status" = "exited" ]; then
            break
        fi
        sleep 1
    done

    status=$(docker inspect -f '{{.State.Status}}' "${BUILDER_NAME}")
    if [ "$status" != "exited" ]; then
        docker kill ${BUILDER_NAME} > /dev/null 2>&1
    fi
    docker rm ${BUILDER_NAME} > /dev/null 2>&1

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
    if curl -siL -m 10 http://127.0.0.1:5678/d/README.md | grep -v 302 | grep -e "x-oss-" -e "x-115-request-id" > /dev/null 2>&1; then
        xiaoya_addr="http://127.0.0.1:5678"
    elif curl -siL -m 10 http://${docker0}:5678/d/README.md | grep -v 302 | grep -e "x-oss-" -e "x-115-request-id" > /dev/null 2>&1; then
        xiaoya_addr="http://${docker0}:5678"
    else
        if [ -s ${CONFIG_DIR}/docker_address.txt ]; then
            docker_address=$(head -n1 ${CONFIG_DIR}/docker_address.txt)
            if curl -siL -m 10 ${docker_address}/d/README.md | grep -v 302 | grep -e "x-oss-" -e "x-115-request-id" > /dev/null 2>&1; then
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

function wait_emby_start() {

    start_time=$(date +%s)
    CONTAINER_NAME=${EMBY_NAME}
    TARGET_LOG_LINE_SUCCESS="All entry points have started"
    while true; do
        line=$(docker logs "$CONTAINER_NAME" 2>&1 | tail -n 10)
        echo "$line"
        if [[ "$line" == *"$TARGET_LOG_LINE_SUCCESS"* ]]; then
            break
        fi
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [ "$elapsed_time" -gt 600 ]; then
            WARN "Emby 未正常启动超时 10 分钟，终止脚本！"
            return 1
        fi
        sleep 3
    done

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

    if [ "$OSNAME" = "ugos" ] || [ "$OSNAME" = "ugos pro" ]; then
        INFO "wget 下载模式"
        pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/${1}"
    else
        INFO "aria2c 下载模式"
        pull_run_glue aria2c -o "${1}" --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${xiaoya_addr}/d/元数据/${1}"
    fi

    if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
        ERROR "存在 ${MEDIA_DIR}/temp/${1}.aria2 文件，下载不完整！"
        return 1
    fi

    INFO "设置目录权限..."
    chmod 777 "${MEDIA_DIR}"/temp/"${1}"
    chown 0:0 "${MEDIA_DIR}"/temp/"${1}"

    INFO "${1} 下载完成！"

    if docker container inspect "${RESILIO_NAME}" > /dev/null 2>&1; then
        INFO "Resilio 关闭中..."
        docker stop ${RESILIO_NAME}
    fi

    INFO "开始解压 ${1} ..."

    if [ "${1}" == "all.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        all_size=$(du -k ${MEDIA_DIR}/temp/all.mp4 | cut -f1)
        if [[ "$all_size" -le 30000000 ]]; then
            ERROR "all.mp4 下载不完整，文件大小(in KB):$all_size 小于预期"
            return 1
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
            return 1
        else
            INFO "pikpak.mp4 文件大小验证正常"
            pull_run_glue 7z x -aoa -mmt=16 /media/temp/pikpak.mp4
        fi

        INFO "设置目录权限..."
        chmod 777 -R "${MEDIA_DIR}"/xiaoya
    elif [ "${1}" == "115.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        __115_size=$(du -k ${MEDIA_DIR}/temp/115.mp4 | cut -f1)
        if [[ "$__115_size" -le 16000000 ]]; then
            ERROR "115.mp4 下载不完整，文件大小(in KB):$__115_size 小于预期"
            return 1
        else
            INFO "115.mp4 文件大小验证正常"
            pull_run_glue 7z x -aoa -mmt=16 /media/temp/115.mp4
        fi

        INFO "设置目录权限..."
        chmod 777 -R "${MEDIA_DIR}"/xiaoya
    fi

    if docker container inspect "${RESILIO_NAME}" > /dev/null 2>&1; then
        docker start ${RESILIO_NAME}
    fi

    INFO "${1} 更新完成"

}

function sync_emby_config() {

    MEDIA_DIR=$1
    if [ "$2" ]; then
        EMBY_URL=$(cat $2/emby_server.txt)
        CONFIG_DIR=$2
    else
        EMBY_URL=$(cat /etc/xiaoya/emby_server.txt)
        CONFIG_DIR=/etc/xiaoya
    fi
    if [ "$3" ]; then
        EMBY_NAME=$3
    else
        EMBY_NAME=emby
    fi
    if [ "$4" ]; then
        RESILIO_NAME=$4
    else
        RESILIO_NAME=resilio
    fi
    if [ "$5" ]; then
        EMBY_APIKEY=$5
    else
        EMBY_APIKEY=e825ed6f7f8f44ffa0563cddaddce14d
    fi

    SQLITE_COMMAND="docker run -i \
        --security-opt seccomp=unconfined \
        --rm \
        --net=host \
        -v $MEDIA_DIR/config/data:/emby/config/data \
        -e LANG=C.UTF-8 \
        xiaoyaliu/glue:latest"
    SQLITE_COMMAND_2="docker run -i \
        --security-opt seccomp=unconfined \
        --rm \
        --net=host \
        -v $MEDIA_DIR/config/data:/emby/config/data \
        -v /tmp/emby_user.sql:/tmp/emby_user.sql \
        -v /tmp/emby_library_mediaconfig.sql:/tmp/emby_library_mediaconfig.sql \
        -e LANG=C.UTF-8 \
        xiaoyaliu/glue:latest"
    SQLITE_COMMAND_3="docker run -i \
        --security-opt seccomp=unconfined \
        --rm \
        --net=host \
        -v $MEDIA_DIR/temp/config/data:/emby/config/data \
        -e LANG=C.UTF-8 \
        xiaoyaliu/glue:latest"
    EMBY_COMMAND="docker run -i \
        --security-opt seccomp=unconfined \
        --rm \
        --net=host \
        -v /tmp/emby.response:/tmp/emby.response \
        -e LANG=C.UTF-8 \
        xiaoyaliu/glue:latest"

    if docker inspect xiaoyaliu/glue:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/glue:latest 2> /dev/null | cut -f2 -d:)
        remote_sha=$(curl -s -m 10 "https://hub.docker.com/v2/repositories/xiaoyaliu/glue/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ ! "$local_sha" == "$remote_sha" ]; then
            docker rmi xiaoyaliu/glue:latest
            if docker pull xiaoyaliu/glue:latest; then
                INFO "镜像拉取成功！"
            else
                ERROR "镜像拉取失败！"
                return 1
            fi
        fi
    else
        if docker pull xiaoyaliu/glue:latest; then
            INFO "镜像拉取成功！"
        else
            ERROR "镜像拉取失败！"
            return 1
        fi
    fi

    INFO "保留用户 Policy 中..."
    status=$(docker inspect -f '{{.State.Status}}' "${EMBY_NAME}")
    if [ "$status" == "exited" ]; then
        docker start "${EMBY_NAME}"
        if ! wait_emby_start; then
            return 1
        fi
    fi
    curl -s "${EMBY_URL}/Users?api_key=${EMBY_APIKEY}" > /tmp/emby.response

    INFO "Emby 关闭中..."
    docker stop "${EMBY_NAME}"

    sleep 4

    INFO "导出数据库中..."
    ${SQLITE_COMMAND} sqlite3 /emby/config/data/library.db ".dump UserDatas" > /tmp/emby_user.sql
    ${SQLITE_COMMAND} sqlite3 /emby/config/data/library.db ".dump ItemExtradata" > /tmp/emby_library_mediaconfig.sql

    INFO "备份数据中..."
    files=(
        "library.db"
        "library.db-shm"
        "library.db-wal"
    )
    for file in "${files[@]}"; do
        src_file="$MEDIA_DIR/config/data/$file"
        dest_file="$src_file.backup"
        if [ -f "$src_file" ]; then
            if [ -f "$dest_file" ]; then
                rm -f "$dest_file"
            fi
            mv -f "$src_file" "$dest_file"
        fi
    done

    INFO "清理旧数据..."
    rm -f $MEDIA_DIR/temp/config.mp4

    test_xiaoya_status

    extra_parameters="--workdir=/media/temp"
    if [ "$OSNAME" = "ugos" ] || [ "$OSNAME" = "ugos pro" ]; then
        INFO "绿联NAS使用 wget 下载"
        pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/config.mp4"
    else
        INFO "使用 aria2 下载"
        pull_run_glue aria2c -o config.mp4 --continue=true -x6 --conditional-get=true --allow-overwrite=true "${xiaoya_addr}/d/元数据/config.mp4"
    fi
    if [ -f "${MEDIA_DIR}/temp/config.mp4.aria2" ]; then
        ERROR "存在 ${MEDIA_DIR}/temp/config.mp4.aria2 文件，下载不完整！"
        return 1
    fi
    # 在temp下面解压，最终新config文件路径为temp/config
    if pull_run_glue 7z x -aoa -mmt=16 config.mp4; then
        INFO "下载解压元数据完成"
    else
        ERROR "解压元数据失败"
        return 1
    fi

    if ${SQLITE_COMMAND_3} sqlite3 /emby/config/data/library.db ".tables" | grep Chapters3 > /dev/null; then
        cp -f $MEDIA_DIR/temp/config/data/library.db* $MEDIA_DIR/config/data/
        ${SQLITE_COMMAND} sqlite3 /emby/config/data/library.db "DROP TABLE IF EXISTS UserDatas;"
        ${SQLITE_COMMAND_2} sqlite3 /emby/config/data/library.db ".read /tmp/emby_user.sql"
        ${SQLITE_COMMAND} sqlite3 /emby/config/data/library.db "DROP TABLE IF EXISTS ItemExtradata;"
        ${SQLITE_COMMAND_2} sqlite3 /emby/config/data/library.db ".read /tmp/emby_library_mediaconfig.sql"
        INFO "保存用户信息完成"
        INFO "文件复制中..."
        mkdir -p $MEDIA_DIR/config/cache
        mkdir -p $MEDIA_DIR/config/metadata
        cp -rf $MEDIA_DIR/temp/config/cache/* $MEDIA_DIR/config/cache/
        cp -rf $MEDIA_DIR/temp/config/metadata/* $MEDIA_DIR/config/metadata/
        rm -rf $MEDIA_DIR/temp/config/*
        INFO "文件复制完成"
        chmod -R 777 \
            $MEDIA_DIR/config/data \
            $MEDIA_DIR/config/cache \
            $MEDIA_DIR/config/metadata
        INFO "Emby 重启中..."
        docker start ${EMBY_NAME}
        sleep 30
    else
        ERROR "解压数据库不完整，跳过复制..."
        INFO "恢复旧数据中..."
        for file in "${files[@]}"; do
            src_file="$MEDIA_DIR/config/data/$file"
            dest_file="$src_file.backup"
            if [ -f "$dest_file" ]; then
                mv -f "$dest_file" "$src_file"
            fi
        done
        return 1
    fi

    if ! wait_emby_start; then
        return 1
    fi

    USER_COUNT=$(${EMBY_COMMAND} jq '.[].Name' /tmp/emby.response | wc -l)
    for ((i = 0; i < USER_COUNT; i++)); do
        if [[ "$USER_COUNT" -gt 50 ]]; then
            WARN "用户超过 50 位，跳过更新用户 Policy！"
            return 1
        fi
        id=$(${EMBY_COMMAND} jq -r ".[$i].Id" /tmp/emby.response)
        name=$(${EMBY_COMMAND} jq -r ".[$i].Name" /tmp/emby.response)
        policy=$(${EMBY_COMMAND} jq -r ".[$i].Policy | to_entries | from_entries | tojson" /tmp/emby.response)
        USER_URL_2="${EMBY_URL}/Users/$id/Policy?api_key=${EMBY_APIKEY}"
        status_code=$(curl -s -w "%{http_code}" -H "Content-Type: application/json" -X POST -d "$policy" "$USER_URL_2")
        if [ "$status_code" == "204" ]; then
            INFO "成功更新 $name 用户Policy"
        else
            ERROR "返回错误代码 $status_code"
            return 1
        fi
    done

}

function compare_metadata_size() {

    pull_run_glue_xh xh --headers --follow --timeout=10 -o /media/headers.log "${xiaoya_addr}/d/元数据/${1}"
    REMOTE_METADATA_SIZE=$(cat ${MEDIA_DIR}/headers.log | grep 'Content-Length' | awk '{print $2}')
    rm -f ${MEDIA_DIR}/headers.log

    if [ -f "${MEDIA_DIR}/temp/${1}" ] && [ ! -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
        LOCAL_METADATA_SIZE=$(du -b "${MEDIA_DIR}/temp/${1}" | awk '{print $1}')
    else
        LOCAL_METADATA_SIZE=0
    fi

    INFO "${1} REMOTE_METADATA_SIZE: ${REMOTE_METADATA_SIZE}"
    INFO "${1} LOCAL_METADATA_SIZE: ${LOCAL_METADATA_SIZE}"

    if
        [ "${REMOTE_METADATA_SIZE}" != "${LOCAL_METADATA_SIZE}" ] &&
            [ -n "${REMOTE_METADATA_SIZE}" ] &&
            awk -v remote="${REMOTE_METADATA_SIZE}" -v threshold="2147483648" 'BEGIN { if (remote > threshold) print "1"; else print "0"; }' | grep -q "1"
    then
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
        if ! update_media "all.mp4"; then
            ERROR "all.mp4 元数据更新失败！"
        fi
    fi

    compare_metadata_size "pikpak.mp4"
    if [ "${__COMPARE_METADATA_SIZE}" == "1" ]; then
        INFO "跳过 pikpak.mp4 更新"
    else
        if ! update_media "pikpak.mp4"; then
            ERROR "pikpak.mp4 元数据更新失败！"
        fi
    fi

    compare_metadata_size "115.mp4"
    if [ "${__COMPARE_METADATA_SIZE}" == "1" ]; then
        INFO "跳过 115.mp4 更新"
    else
        if ! update_media "115.mp4"; then
            ERROR "115.mp4 元数据更新失败！"
        fi
    fi

    INFO "全部媒体元数据更新完成！"

}

function detection_config_update() {

    if [ "${FORCE_UPDATE_CONFIG}" == "yes" ]; then
        sync_emby_config ${MEDIA_DIR} ${CONFIG_DIR} ${EMBY_NAME} ${RESILIO_NAME} ${EMBY_APIKEY}
    else
        compare_metadata_size "config.mp4"
        if [ "${__COMPARE_METADATA_SIZE}" == "1" ]; then
            INFO "跳过 config.mp4 更新"
        else
            sync_emby_config ${MEDIA_DIR} ${CONFIG_DIR} ${EMBY_NAME} ${RESILIO_NAME} ${EMBY_APIKEY}
        fi
    fi

}

function detection_xiaoya_version_update() {

    REMOTE_XIAOYA_VERSION=$(curl -skL https://docker.xiaoya.pro/version.txt | head -n 1 | sed "s/\r$//g")

    if ! echo "${REMOTE_XIAOYA_VERSION}" | awk -F '[^0-9.]' '{print NF-1}' | grep -q '^0$'; then
        REMOTE_XIAOYA_VERSION=error
    fi

    docker cp ${XIAOYA_NAME}:/version.txt ${MEDIA_DIR}
    if [ -f "${MEDIA_DIR}/version.txt" ]; then
        LOCAL_XIAOYA_VERSION=$(cat ${MEDIA_DIR}/version.txt | head -n 1 | sed "s/\r$//g")
        rm -f cat ${MEDIA_DIR}/version.txt
    else
        LOCAL_XIAOYA_VERSION="error"
    fi

    INFO "REMOTE_XIAOYA_VERSION: ${REMOTE_XIAOYA_VERSION}"
    INFO "LOCAL_XIAOYA_VERSION: ${LOCAL_XIAOYA_VERSION}"

    if [ "${REMOTE_XIAOYA_VERSION}" == "${LOCAL_XIAOYA_VERSION}" ] ||
        [ "${REMOTE_XIAOYA_VERSION}" == "" ] ||
        [ "${LOCAL_XIAOYA_VERSION}" == "error" ] ||
        [ "${REMOTE_XIAOYA_VERSION}" == "error" ] ||
        [ -z "${REMOTE_XIAOYA_VERSION}" ]; then
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
            if [ ! "${local_sha}" == "${remote_sha}" ] && [ -n "${remote_sha}" ] && [ -n "${local_sha}" ]; then
                if ! container_update "${XIAOYA_NAME}"; then
                    ERROR "小雅容器更新失败！"
                fi
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
            if [ ! "${local_sha}" == "${remote_sha}" ] && [ -n "${remote_sha}" ] && [ -n "${local_sha}" ]; then
                if ! container_update "${XIAOYA_NAME}"; then
                    ERROR "小雅容器更新失败！"
                fi
            else
                INFO "跳过小雅容器更新"
            fi
        fi
    fi

}

function main() {

    cat << EOF
可添加参数解释：
1. --auto_update_all_pikpak：是否开启all,pikpak,115自动下载更新（yes开启，no关闭）（可选，默认开启）
2. --auto_update_config：是否开启config自动同步（yes开启，no关闭）（可选，默认开启）
3. --force_update_config：强制同步config（yes开启，no关闭）（可选，默认关闭）
4. --media_dir：媒体库路径
5. --config_dir：小雅配置文件路径（可选，默认/etc/xiaoya）
6. --xiaoya_name：小雅容器名（可选，默认xiaoya）
7. --resilio_name：resilio容器名（可选，默认resilio）
8. --emby_name：emby容器名（可选，默认emby）
9. --emby_apikey: emby api key（可选）

EOF

    INFO "小雅配置目录：${CONFIG_DIR}"
    INFO "媒体库目录：${MEDIA_DIR}"
    INFO "Emby 容器名称：${EMBY_NAME}"
    INFO "Resilio 容器名称：${RESILIO_NAME}"
    INFO "小雅容器名称：${XIAOYA_NAME}"

    _os=$(uname -s)
    _os_all=$(uname -a)
    if [ "${_os}" == "Darwin" ]; then
        OSNAME='macos'
        DDSREM_CONFIG_DIR=/etc/DDSRem
        stty -icanon
    # 必须先判断的系统
    # 绿联旧版UGOS 基于 OpenWRT
    elif [ -f /etc/openwrt_version ] && echo -e "${_os_all}" | grep -Eqi "UGREEN"; then
        OSNAME='ugos'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    # 绿联UGOS Pro 基于 Debian
    elif grep -Eqi "Debian" /etc/os-release && grep -Eqi "UGOSPRO" /etc/issue; then
        OSNAME='ugos pro'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    # fnOS 基于 Debian
    elif grep -Eqi "Debian" /etc/os-release && grep -Eqi "fnOS" /etc/issue; then
        OSNAME='fnos'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    # OpenMediaVault 基于 Debian
    elif grep -Eqi "openmediavault" /etc/issue || grep -Eqi "openmediavault" /etc/os-release; then
        OSNAME='openmediavault'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    # FreeNAS（TrueNAS CORE）基于 FreeBSD
    elif echo -e "${_os_all}" | grep -Eqi "FreeBSD" | grep -Eqi "TRUENAS"; then
        OSNAME='truenas core'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    # TrueNAS SCALE 基于 Debian
    elif grep -Eqi "Debian" /etc/issue && [ -f /etc/version ]; then
        OSNAME='truenas scale'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif [ -f /etc/synoinfo.conf ]; then
        OSNAME='synology'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif [ -f /etc/openwrt_release ]; then
        OSNAME='openwrt'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "QNAP" /etc/issue; then
        OSNAME='qnap'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif [ -f /etc/unraid-version ]; then
        OSNAME='unraid'
        DDSREM_CONFIG_DIR=/mnt/user/appdata/DDSRem
        # 目录迁移
        if [ ! -d "${DDSREM_CONFIG_DIR}" ]; then
            mkdir -p "${DDSREM_CONFIG_DIR}"
        fi
        local FILES_LIST PATHS_LIST
        FILES_LIST=(
            "xiaoya_alist_tvbox_config_dir.txt"
            "xiaoya_alist_media_dir.txt"
            "xiaoya_alist_config_dir.txt"
            "resilio_config_dir.txt"
            "portainer_config_dir.txt"
            "onelist_config_dir.txt"
            "container_run_extra_parameters.txt"
            "auto_symlink_config_dir.txt"
            "data_downloader.txt"
            "disk_capacity_detection.txt"
            "xiaoya_connectivity_detection.txt"
            "image_mirror.txt"
            "image_mirror_user.txt"
            "default_network.txt"
        )
        PATHS_LIST=(
            "container_name"
            "data_crep"
        )
        for __file in "${FILES_LIST[@]}"; do
            if [ -f "/etc/DDSRem/${__file}" ]; then
                INFO "迁移文件 ${__file} 中..."
                mv "/etc/DDSRem/${__file}" "${DDSREM_CONFIG_DIR}/${__file}"
            fi
        done
        for __path in "${PATHS_LIST[@]}"; do
            if [ -d "/etc/DDSRem/${__path}" ]; then
                INFO "迁移文件夹 ${__path} 中..."
                if [ -d "${DDSREM_CONFIG_DIR}/${__path}" ]; then
                    # 默认保留 /etc/DDSRem 的配置项
                    # shellcheck disable=SC2115
                    rm -rf "${DDSREM_CONFIG_DIR}/${__path}"
                fi
                mv "/etc/DDSRem/${__path}" "${DDSREM_CONFIG_DIR}/${__path}"
            fi
        done
    elif grep -Eqi "LibreELEC" /etc/issue || grep -Eqi "LibreELEC" /etc/*-release; then
        OSNAME='libreelec'
        DDSREM_CONFIG_DIR=/storage/DDSRem
        ERROR "LibreELEC 系统目前不支持！"
        exit 1
    elif grep -Eqi "openSUSE" /etc/*-release; then
        OSNAME='opensuse'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "FreeBSD" /etc/*-release; then
        OSNAME='freebsd'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "EulerOS" /etc/*-release || grep -Eqi "openEuler" /etc/*-release; then
        OSNAME='euler'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "CentOS" /etc/issue || grep -Eqi "CentOS" /etc/*-release; then
        OSNAME='centos'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Fedora" /etc/issue || grep -Eqi "Fedora" /etc/*-release; then
        OSNAME='fedora'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Rocky" /etc/issue || grep -Eqi "Rocky" /etc/*-release; then
        OSNAME='rocky'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "AlmaLinux" /etc/issue || grep -Eqi "AlmaLinux" /etc/*-release; then
        OSNAME='almalinux'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Arch Linux" /etc/issue || grep -Eqi "Arch Linux" /etc/*-release; then
        OSNAME='archlinux'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Amazon Linux" /etc/issue || grep -Eqi "Amazon Linux" /etc/*-release; then
        OSNAME='amazon'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Debian" /etc/issue || grep -Eqi "Debian" /etc/os-release; then
        OSNAME='debian'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eqi "Ubuntu" /etc/os-release; then
        OSNAME='ubuntu'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    elif grep -Eqi "Alpine" /etc/issue || grep -Eq "Alpine" /etc/*-release; then
        OSNAME='alpine'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    else
        OSNAME='unknow'
        DDSREM_CONFIG_DIR=/etc/DDSRem
    fi

    INFO "OS: ${_os},${OSNAME}"
    INFO "脚本配置文件路径：${DDSREM_CONFIG_DIR}"
    if [ ! -f "${DDSREM_CONFIG_DIR}/image_mirror.txt" ]; then
        echo 'docker.io' > ${DDSREM_CONFIG_DIR}/image_mirror.txt
    fi

    test_xiaoya_status

    # all.mp4 和 pikpak.mp4 和 115.mp4
    if [ "${AUTO_UPDATE_ALL_PIKPAK}" == "yes" ]; then
        detection_all_pikpak_update
    else
        INFO "all.mp4 pikpak.mp4 115.mp4 更新已关闭"
    fi
    # config.mp4
    if [ "${AUTO_UPDATE_CONFIG}" == "yes" ]; then
        if ! detection_config_update; then
            ERROR "Emby config sync 运行失败！"
        else
            INFO "Emby config sync 运行成功！"
        fi
    else
        INFO "Emby config sync 已关闭"
    fi
    # xiaoya image
    detection_xiaoya_image_update
    sleep 20
    # xiaoya version
    detection_xiaoya_version_update

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
    --emby_apikey=*)
        EMBY_APIKEY="${1#*=}"
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
    --force_update_config=*)
        FORCE_UPDATE_CONFIG="${1#*=}"
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

if [ -z ${EMBY_APIKEY} ]; then
    EMBY_APIKEY=e825ed6f7f8f44ffa0563cddaddce14d
fi

if [ -z ${RESILIO_NAME} ]; then
    RESILIO_NAME=resilio
fi

if [ -z ${XIAOYA_NAME} ]; then
    XIAOYA_NAME=xiaoya
fi

if [ -z ${AUTO_UPDATE_CONFIG} ]; then
    AUTO_UPDATE_CONFIG=yes
fi

if [ -z ${FORCE_UPDATE_CONFIG} ]; then
    FORCE_UPDATE_CONFIG=no
fi

if [ -z ${AUTO_UPDATE_ALL_PIKPAK} ]; then
    AUTO_UPDATE_ALL_PIKPAK=yes
fi

main
