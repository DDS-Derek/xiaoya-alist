#!/usr/bin/bash

if [ "$1" ]; then
	EMBY_NAME=$1
else	
	EMBY_NAME=emby
fi

if [ "$2" ]; then
	RESILIO_NAME=$2
else	
	RESILIO_NAME=resilio
fi

EMBY_URL=$(cat /etc/xiaoya/emby_server.txt)

media_lib=/media
if [ ! -d "$media_lib/config_sync" ]; then
	mkdir "$media_lib/config_sync"
fi

echo "Emby 和 Resilio关闭中 ...."
docker stop "${EMBY_NAME}"
docker stop "${RESILIO_NAME}"

echo "检查同步数据库完整性..."
sleep 4
if sqlite3 $media_lib/config_sync/data/library.db ".tables" | grep Chapters3 > /dev/null ; then
	curl -s "${EMBY_URL}/Users?api_key=e825ed6f7f8f44ffa0563cddaddce14d" > /tmp/emby.response
	echo -e "\033[32m同步数据库数据完整\033[0m"
	sqlite3 $media_lib/config/data/library.db ".dump UserDatas" > /tmp/emby_user.sql
	sqlite3 $media_lib/config/data/library.db ".dump ItemExtradata" > /tmp/emby_library_mediaconfig.sql
	rm "$media_lib/config/data/library.db*"
	cp "$media_lib/config_sync/data/library.db*" "$media_lib/config/data/"
	sqlite3 $media_lib/config/data/library.db "DROP TABLE IF EXISTS UserDatas;"
	sqlite3 $media_lib/config/data/library.db ".read /tmp/emby_user.sql"
	sqlite3 $media_lib/config/data/library.db "DROP TABLE IF EXISTS ItemExtradata;"
    sqlite3 $media_lib/config/data/library.db ".read /tmp/emby_library_mediaconfig.sql"	
	echo "保存用户信息完成"
	cp -rf "$media_lib/config_sync/cache/*" "$media_lib/config/cache/"
	cp -rf "$media_lib/config_sync/metadata/*" "$media_lib/config/metadata/"
	chmod -R 777 \
		"$media_lib/config/data" \
		"$media_lib/config/cache" \
		"$media_lib/config/metadata"
	echo "复制 config_sync 至 config 完成"
	echo "Emby 和 Resilio 重启中 ...."
	docker start "${EMBY_NAME}"
	docker start "${RESILIO_NAME}"	
else
	echo -e "\033[35m同步数据库不完整，跳过复制...\033[0m"
	echo "Emby 和 Resilio 重启中 ...."
	docker start "${EMBY_NAME}"
    docker start "${RESILIO_NAME}"
	exit 0
fi

start_time=$(date +%s)
CONTAINER_NAME=${EMBY_NAME}
TARGET_LOG_LINE_SUCCESS="All entry points have started"
while true; do
	line=$(docker logs "$CONTAINER_NAME" 2>&1| tail -n 10)
	echo "$line"
	if [[ "$line" == *"$TARGET_LOG_LINE_SUCCESS"* ]]; then
        break
	fi
	current_time=$(date +%s)
	elapsed_time=$((current_time - start_time))
	if [ "$elapsed_time" -gt 300 ]; then
		echo "Emby未正常启动超时 5分钟，终止执行更新用户Policy"
		exit
	fi	
	sleep 3
done

USER_COUNT=$(jq '.[].Name' /tmp/emby.response |wc -l)
for ((i = 0; i < USER_COUNT; i++))
do
	if [[ "$USER_COUNT" -gt 9 ]]; then
		exit
	fi
	read -r id <<< "$(jq -r ".[$i].Id" /tmp/emby.response)"
	read -r name <<< "$(jq -r ".[$i].Name" /tmp/emby.response)"
	read -r policy <<< "$(jq -r ".[$i].Policy | to_entries | from_entries | tojson" /tmp/emby.response)"
	USER_URL_2="${EMBY_URL}/Users/$id/Policy?api_key=e825ed6f7f8f44ffa0563cddaddce14d"
    	status_code=$(curl -s -w "%{http_code}" -H "Content-Type: application/json" -X POST -d "$policy" "$USER_URL_2")
    	if [ "$status_code" == "204" ]; then
        	echo "成功更新 $name 用户Policy"
    	else
        	echo "返回错误代码 $status_code"
    	fi
done
