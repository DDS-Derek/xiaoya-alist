function get_embyurl(){
    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_emby_url.txt ]; then
        OLD_EMBY_URL=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_emby_url.txt)
        INFO "已读取小雅Emby地址：${OLD_EMBY_URL} (默认不更改回车继续，如果需要更改请输入新地址)"
        read -ep "请输入: " EMBY_URL
        [[ -z "${EMBY_URL}" ]] && EMBY_URL=${OLD_EMBY_URL}
        echo ${EMBY_URL} > ${DDSREM_CONFIG_DIR}/xiaoya_emby_url.txt
    else
        INFO "请输入你的小雅Emby的内网访问地址，如：http://192.168.1.1:2345"
        read -ep "请输入: " EMBY_URL
        touch ${DDSREM_CONFIG_DIR}/xiaoya_emby_url.txt
        echo ${EMBY_URL} > ${DDSREM_CONFIG_DIR}/xiaoya_emby_url.txt
    fi
}

function get_embyapi(){
    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_emby_api.txt ]; then
        OLD_EMBY_API=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_emby_api.txt)
        INFO "已读取小雅Emby的API密钥：${OLD_EMBY_API} (默认不更改回车继续，如果需要更改请输入新的API密钥)"
        read -ep "请输入: " EMBY_API
        [[ -z "${EMBY_API}" ]] && EMBY_API=${OLD_EMBY_API}
        echo ${EMBY_API} > ${DDSREM_CONFIG_DIR}/xiaoya_emby_api.txt
    else
        INFO "请输入小雅Emby的API密钥"
        read -ep "请输入: " EMBY_API
        touch ${DDSREM_CONFIG_DIR}/xiaoya_emby_api.txt
        echo ${EMBY_API} > ${DDSREM_CONFIG_DIR}/xiaoya_emby_api.txt
    fi
}

function install_emby_library(){

    get_media_dir

    get_embyapi

    get_embyurl

    INFO "请输入小雅Emby的容器名（默认 $(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) ）"
    read -ep "EMBY_NAME:" EMBY_NAME
    [[ -z "${EMBY_NAME}" ]] && EMBY_NAME="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)"

    INFO "请输入计划时间，例：30 6 * * *，这个代表每天6点30分，注意，数字和*之前都有空格，格式一定要正确！（默认 30 6 * * * ）"
    read -ep "CRON:" CRON
    [[ -z "${CRON}" ]] && CRON="30 6 * * *"

    INFO "是否自动删除旧Emby容器重新配置 [Y/n]（默认 y）"
    read -ep "REMOVE:" REMOVE
    [[ -z "${REMOVE}" ]] && REMOVE="y"
    if [[ ${REMOVE} == [Yy] ]]; then
        docker stop ${EMBY_NAME}
        docker rm ${EMBY_NAME}
        if [ ! -d ${MEDIA_DIR}/config_data ]; then
            mkdir -p ${MEDIA_DIR}/config_data
        fi
        cp -rf ${MEDIA_DIR}/config/data/* ${MEDIA_DIR}/config_data/
        MOUNT="-v ${MEDIA_DIR}/config_data:/config/data"
        install_emby_xiaoya_all_emby
    fi
    if [[ ${REMOVE} == [Nn] ]]; then
        INFO "请手动删除Emby容器，并添加一个目录映射：-v ${MEDIA_DIR}/config_data:/config/data"
        read -ep "按任意键继续..." abcdefg
    fi

    INFO "开始安装xiaoya-emby-library-update..."
    docker run -itd \
        --name=xiaoya-emby-library-update \
        -v ${MEDIA_DIR}:/data \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        --net=host \
        -e EMBY_NAME=${EMBY_NAME} \
        -e EMBY_API=${EMBY_API} \
        -e EMBY_URL=${EMBY_URL} \
        -e "CRON=${CRON}" \
        --restart=always \
        ddsderek/xiaoya-emby-library:latest

    INFO "安装完成！"

}

function uninstall_emby_library(){

    for i in `seq -w 3 -1 0`
    do
        echo -en "即将开始卸载自动同步Emby数据库${Blue} $i ${Font}\r"  
    sleep 1;
    done
    docker stop xiaoya-emby-library-update
    docker rm xiaoya-emby-library-update
    docker ddsderek/xiaoya-emby-library:latest
    INFO "卸载成功！"

}

function main_emby_library(){

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}自动同步Emby数据库${Font}\n"
    echo -e "1、安装"
    echo -e "2、卸载"
    echo -e "3、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -ep "请输入数字 [1-3]:" num
    case "$num" in
        1)
        clear
        install_emby_library
        ;;
        2)
        clear
        uninstall_emby_library
        ;;
        3)
        clear
        main_xiaoya_all_emby
        ;;
        *)
        clear
        ERROR '请输入正确数字 [1-3]'
        main_emby_library
        ;;
        esac

}