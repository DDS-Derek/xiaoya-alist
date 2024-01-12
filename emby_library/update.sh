#!/bin/bash

emby_config_data=/data/config/data
emby_config_data_new=/data/config_data

function update_policy(){
	clear
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
	echo -e "开始获取EMBY用户信息"
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
    USER_URL="${EMBY_URL}/Users?api_key=${EMBY_API}"  
    response=$(curl -s "${USER_URL}")  
    USER_COUNT=$(echo "${response}" | jq '. | length')
    for((i=0;i<$USER_COUNT;i++))
    do
        read -r name <<< "$(echo "${response}" | jq -r ".[$i].Name")"  # 使用read命令读取名字  
        read -r id <<< "$(echo "${response}" | jq -r ".[$i].Id")"  # 使用read命令读取ID
        read -r policy <<< "$(echo "${response}" | jq -r ".[$i].Policy | to_entries | from_entries | tojson")"
		USER_URL_2="${EMBY_URL}/Users/$id/Policy?api_key=${EMBY_API}"
		curl -i -H "Content-Type: application/json" -X POST -d "$policy" "$USER_URL_2"
		echo -e "【$name】"用户策略更新成功！
		echo -e ""
		echo -e "——————————————————————————————————————————————————————————————————————————————————"
    done
	echo -e "所有用户策略更新成功！"
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
}

function update_config(){
    clear
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "小雅EMBY_CONFIG同步"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
	INFO "开始更新CONFIG"
	docker stop ${EMBY_NAME}
    if [ -f /root/xiaoya_emby_library_user.sql ]; then
	    rm -f /root/xiaoya_emby_library_user.sql
    fi
	sqlite3 ${emby_config_data_new}/library.db ".dump UserDatas" > /root/xiaoya_emby_library_user.sql
	rm -f ${emby_config_data_new}/library.db*
	cp -f ${emby_config_data}/library.db ${emby_config_data_new}/
	sqlite3 ${emby_config_data_new}/library.db "DROP TABLE IF EXISTS UserDatas;"
	sqlite3 ${emby_config_data_new}/library.db ".read /root/xiaoya_emby_library_user.sql"
	chmod 777 ${emby_config_data_new}/library.db*
	docker start ${EMBY_NAME}
	echo -e "——————————————————————————————————————————————————————————————————————————————————"
	echo -e "正在重启EMBY..."
	SINCE_TIME=$(date +"%Y-%m-%dT%H:%M:%S")
	CONTAINER_NAME=${EMBY_NAME}
	TARGET_LOG_LINE_OK="All entry points have started"
	TARGET_LOG_LINE_FAIL="sending all processes the KILL signal and exiting"
    while true; do
        line=$(docker logs --since "$SINCE_TIME" "$CONTAINER_NAME" | tail -n 1)
        echo $line
		if [[ "$line" == *"$TARGET_LOG_LINE_OK"* ]]; then
			echo -e "——————————————————————————————————————————————————————————————————————————————————"
			INFO "更新CONFIG完成，请确认emby已经正常启动（根据机器性能启动可能需要一点时间）"
		elif [[ "$line" == *"$TARGET_LOG_LINE_FAIL"* ]]; then
			echo -e "——————————————————————————————————————————————————————————————————————————————————"
			WARN "EMBY启动失败"
            INFO "正在恢复数据库并重启EMBY"
            docker stop ${EMBY_NAME}
            rm -f ${emby_config_data_new}/library.db*
            cp -f ${emby_config_data}/library.db ${emby_config_data_new}/
            docker start ${EMBY_NAME}
            INFO "已恢复数据库"
        fi
		sleep 3
    done
}

$1