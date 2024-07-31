#!/bin/bash

ver="202407272055"

upgrade_url="https://xiaoyahelper.ddsrem.com/aliyun_clear.sh"
upgrade_url_backup="http://xiaoyahelper.zngle.cf/aliyun_clear.sh"
tg_push_api_url="https://xiaoyapush.ddsrem.com"

hash_function() {
    str="$1"
    hash=0

    # DJB2 hash algorithm
    i=0
    while [ "$i" -lt "${#str}" ]; do
        char=$(printf "%s" "$str" | cut -c "$((i + 1))")
        char_value=$(printf "%d" "'$char")
        hash=$(((hash * 33) ^ char_value))
        hash=$((hash & 0xFFFFFF))
        i=$((i + 1))
    done

    hash=$((hash & 0xFFFFFF)) # 4-byte integer (32-bit)
    echo "$hash"
}

# Function to convert a 4-byte integer to IP address
int_to_ip() {
    ip=""
    for i in 0 1 2 3; do
        octet=$((($1 >> (8 * (3 - i))) & 0xFF))
        if [ -z "$ip" ]; then
            ip="$octet"
        else
            ip="$ip.$octet"
        fi
    done
    echo "$ip"
}

# Function to hash a string and convert it to IP address
hash_to_ip() {
    input_string="$1"
    hashed_value=$(hash_function "$input_string")
    hashed_ip=$(int_to_ip "$hashed_value")
    echo "$hashed_ip" | sed 's/^0\./1\./g'
}

fast_triger_update() {
    if [ ! -f /docker-entrypoint.sh ]; then
        return 0
    fi

    if [ ! $(($(date +%-M) % 5)) -eq 0 ]; then
        return 0
    fi

    if [ "$sche" -eq 0 ]; then
        local_ip_ver="$(hash_to_ip "$ver")"
        remote_ip_ver="$(ping -c 1 -W 1 xiaoyakeeper.u.1996999.xyz 2>&1 | grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | head -n1 | grep "^1\.")"
        if [ -z "$remote_ip_ver" ]; then
            return 0
        fi

        if [ "$local_ip_ver"x = "$remote_ip_ver"x ]; then
            return 0
        fi
    fi

    newsh=$(curl --connect-timeout 5 -m 5 -k -s "$upgrade_url" 2>/dev/null)
    if [ -z "$(echo "$newsh" | grep "^#!/bin/bash")" ]; then
        newsh=$(curl --connect-timeout 5 -m 5 -k -s "$upgrade_url_backup" 2>/dev/null)
    fi
    latest_ver=$(echo "$newsh" | grep "^ver=" | tr -d '"ver=')
    if [ "$latest_ver"x = x ] || [ "$ver"x = "$latest_ver"x ]; then
        return 0
    fi

    myecho "检测到新版本$latest_ver，即将自动重启容器升级，重启前会补做一次签到和清理"

    clear_aliyun_all_docker_pre_update
    sleep 60
    #docker restart xiaoyakeeper
    exit 0
}

g_p=$@
para() {
    i=$(echo ~$1 | tr -d '~' | tr '-' '~')
    if [ "$(echo ~$g_p | tr -d '~' | tr '-' '~' | grep -Eo "$i")"x = x ]; then
        return 1
    fi
    return 0
}

retry_command() {
    # 重试次数和最大重试次数
    retries=0
    max_retries=10
    local cmd="$1"
    local success=false
    local output=""

    while ! $success && [ $retries -lt $max_retries ]; do
        output=$(eval "$cmd" 2>&1)
        if [ $? -eq 0 ]; then
            success=true
        else
            retries=$(($retries + 1))
            echo "#Failed to execute command \"$(echo "$cmd" | awk '{print $1}')\", retrying in 1 seconds (retry $retries of $max_retries)..." >&2
            sleep 1
        fi
    done

    if $success; then
        echo "$output"
        return 0
    else
        echo "#Failed to execute command after $max_retries retries: $cmd" >&2
        echo "#Command output: $output" >&2
        return 1
    fi
}

#检查脚本更新
if which curl &>/dev/null; then
    newsh=$(retry_command "curl --connect-timeout 5 -m 5 -k -s \"$upgrade_url\" 2>/dev/null")
    if [ -z "$(echo "$newsh" | grep "^#!/bin/bash")" ]; then
        newsh=$(retry_command "curl --connect-timeout 5 -m 5 -k -s \"$upgrade_url_backup\" 2>/dev/null")
    fi
fi
latest_ver=$(echo "$newsh" | grep "^ver=" | tr -d '"ver=')
if [ ! "$latest_ver"x = x ] && [ ! "$ver"x = "$latest_ver"x ]; then
    filename=${0}
    dir=$(dirname "$filename")
    if [ "$dir"x = x ]; then
        filename="./$filename"
    fi
    if [ ! "$(echo "$dir" | awk -F/ '{print $1}')"x = x ]; then
        filename="./$filename"
    fi

    shell_cmd="sh"
    which "bash" >/dev/null
    if [ $? -eq 0 ]; then
        shell_cmd="bash"
    fi

    if [ -n "$(cat "$filename" | head -n 1 | grep "^#!/bin/bash")" ]; then
        echo "$newsh" >"$filename"
        chmod +x "$filename"
        echo "脚本已自动更新到最新版本$latest_ver"
        $shell_cmd $filename "$@"
        exit 0
    fi
fi

get_Header() {
    response=$(curl --connect-timeout 5 -m 5 -s -H "Content-Type: application/json" \
        -d '{"grant_type":"refresh_token", "refresh_token":"'$refresh_token'"}' \
        https://api.aliyundrive.com/v2/account/token)

    access_token=$(echo "$response" | sed -n 's/.*"access_token":"\([^"]*\).*/\1/p')

    HEADER="Authorization: Bearer $access_token"
    if [ -z "$HEADER" ]; then
        echo "获取access token失败" >&2
        return 1
    fi

    response="$(curl --connect-timeout 5 -m 5 -s -H "$HEADER" -H "Content-Type: application/json" -X POST -d '{}' "https://user.aliyundrive.com/v2/user/get")"

    lagacy_drive_id=$(echo "$response" | sed -n 's/.*"default_drive_id":"\([^"]*\).*/\1/p')

    drive_id=$(echo "$response" | sed -n 's/.*"resource_drive_id":"\([^"]*\).*/\1/p')

    if [ -z "$drive_id" ]; then
        drive_id=$lagacy_drive_id
    fi

    if [ "$folder_type"x = "b"x ]; then
        drive_id=$lagacy_drive_id
    fi

    if [ -z "$drive_id" ]; then
        echo "获取drive_id失败" >&2
        return 1
    fi

    echo "HEADER=\"$HEADER\""
    echo "drive_id=\"$drive_id\""
    return 0
}

get_rawList() {
    waittime=10
    if [ -n "$1" ]; then
        waittime="$1"
    fi
    _res=$(curl --connect-timeout 5 -m 5 -s -H "$HEADER" -H "Content-Type: application/json" -X POST -d '{"drive_id": "'$drive_id'","parent_file_id": "'$file_id'"}' "https://api.aliyundrive.com/adrive/v2/file/list")
    if [ ! $? -eq 0 ] || [ -z "$(echo "$_res" | grep "items")" ]; then
        echo "获取文件列表失败：folder_id=$file_id,drive_id=$drive_id" >&2
        return 1
    fi
    echo "$_res"
    #简单规避小雅转存后还没来得及获取直链就被删除的问题，降低发生概率
    sleep "$waittime"
    return 0
}

get_List() {
    _res=$raw_list

    #echo "$_res" | tr '{' '\n' | grep -v "folder" | grep -o "\"file_id\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"'
    echo "$_res" | tr '{' '\n' | grep -o "\"file_id\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"'
    return 0
}

get_Path() {
    _path="$(curl --connect-timeout 5 -m 5 -s -H "$HEADER" -H "Content-Type: application/json" -X POST -d "{\"drive_id\": \"$drive_id\", \"file_id\": \"$file_id\"}" "https://api.aliyundrive.com/adrive/v1/file/get_path" | grep -o "\"name\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"' | tr '\n' '/' | awk -F'/' '{for(i=NF-1;i>0;i--){printf("/%s",$i)}; printf("%s\n",$NF)}')"
    if [ -z "$_path" ]; then
        return 1
    fi
    echo "$_path"
    return 0
}

delete_File() {
    _file_id=$1
    _name="$(echo "$raw_list" | grep -o "\"name\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"' | grep -n . | grep "^$(echo "$raw_list" | grep -o "\"file_id\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"' | grep -n . | grep "$_file_id" | awk -F: '{print $1}'):" | awk -F: '{print $2}')"

    _res=$(curl --connect-timeout 5 -m 5 -s -H "$HEADER" -H "Content-Type: application/json" -X POST -d '{
  "requests": [
    {
      "body": {
        "drive_id": "'$drive_id'",
        "file_id": "'$_file_id'"
      },
      "headers": {
        "Content-Type": "application/json"
      },
      "id": "'$_file_id'",
      "method": "POST",
      "url": "/file/delete"
    }
  ],
  "resource": "file"
}' "https://api.aliyundrive.com/v3/batch" | grep "\"status\":204")
    if [ -z "$_res" ]; then
        return 1
    fi

    drive_root="资源盘"
    if [ "$folder_type"x = "b"x ]; then
        drive_root="备份盘"
    fi

    myecho "彻底删除文件：/$drive_root$path/$_name"

    return 0
}

get_docker_info() {
    if [ "$1"x != x ]; then
        get_docker_info | awk '"'$1'"==$1'
        return
    fi
    images=$(docker images --no-trunc)
    for line in $(docker ps | tail -n +2 | grep -v "xiaoyakeeper" | awk '{print $NF}'); do
        id=$(docker inspect --format='{{.Image}}' $line | awk -F: '{print $2}')
        echo "$line $(echo "$images" | grep $id | head -n 1)" | tr ':' ' ' | awk '{printf("%s %s %s\n",$1,$2,$5)}'
    done
}

get_Xiaoya() {
    get_docker_info | grep "xiaoyaliu/alist\|haroldli/xiaoya-tvbox\|ailg/alist" | awk '{print $1}'
}

# 签到是抄小雅的
get_json_value() {
    local json=$1
    local key=$2

    if [[ -z "$3" ]]; then
        local num=1
    else
        local num=$3
    fi

    local value=$(echo "${json}" | awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'${key}'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p)
    echo ${value}
}

get_Reward() {
    _res=$(curl --connect-timeout 5 -m 5 -s -H "$HEADER" -H "Content-Type: application/json" -X POST -d '{"signInDay": '$day'}' "https://member.aliyundrive.com/v1/activity/sign_in_reward?_rx-s=mobile" | grep "success")
    if [ -z "$_res" ]; then
        reurn 1
    fi
    _name=$(get_json_value "$_res" "name")
    _dsc=$(get_json_value "$_res" "description")
    echo "$_name-$_dsc" | tr -d ' '
    return 0
}

checkin() {
    local _refresh_token=$1
    local _token=$(curl --connect-timeout 5 -m 5 -s -X POST -H "Content-Type: application/json" -d '{"grant_type": "refresh_token", "refresh_token":                 "'"$_refresh_token"'"}' https://auth.aliyundrive.com/v2/account/token)
    local _access_token=$(get_json_value $_token "access_token")

    nick_name=$(get_json_value $_token "nick_name")

    if [ -z "$nick_name" ]; then
        nick_name="阿里云盘"
    fi

    _output="\n[$(date '+%Y/%m/%d %H:%M:%S')][$nick_name]的签到信息"

    HEADER="Authorization:Bearer $_access_token"

    local _sign=$(curl --connect-timeout 5 -m 5 -s -X POST -H "Content-Type: application/json" -H "$HEADER" -d '{"grant_type":           "refresh_token", "refresh_token": "'"$_refresh_token"'"}' https://member.aliyundrive.com/v1/activity/sign_in_list)

    local _fmt_sign=$(echo "$_sign" | tr -d '\n' | sed 's/{"day"/\n{"day"/g' | tr -d ' ')

    local _days=$(echo "$_fmt_sign" | grep '"status":"normal"' | grep '"isReward":false' | grep -Eo '"day":[0-9]{1,2}' | awk -F: '{print $2}' | sed '/^$/d')

    _today_cards=""
    for day in $_days; do
        _today_cards="$_today_cards\n$(retry_command "get_Reward" | grep "-")"
    done

    raw_cards=$(echo -e "$_today_cards" | tr -d ' ')
    _card=""
    for card in $(echo -e "$raw_cards" | sort | uniq | grep -v null); do
        _card="$(echo "$_card\n--$card：$(echo -e "$raw_cards" | grep "$card" | wc -l)张")"
    done

    if [ -n "$(echo -e "$_today_cards" | tr -d ' ' | sed '/^$/d')" ]; then
        _output="$_output\n$(echo -e "今日获得奖励：\n$_card" | sed '/^$/d')"
    fi

    _cards=$_today_cards
    for day in $(echo "$_fmt_sign" | grep -v '"status":"miss"' | grep -Eo '"day":[0-9]{1,2}'); do
        day_sign=$(echo "$_fmt_sign" | grep "$day")
        _cards="$_cards\n""$(get_json_value "$day_sign" "name")"-"$(get_json_value "$day_sign" "description")"
    done

    raw_cards=$(echo -e "$_cards" | tr -d ' ')
    _card=""
    for card in $(echo -e "$raw_cards" | sort | uniq | grep -v null); do
        _card="$(echo "$_card\n--$card：$(echo -e "$raw_cards" | grep "$card" | wc -l)张")"
    done

    local _signInCount=$(get_json_value "$_sign" "signInCount")

    local _success=$(echo $_sign | cut -f1 -d, | cut -f2 -d:)
    if [ "$_success"x = "true"x ]; then
        _output="$_output\n$(echo -e "本月累计签到$_signInCount天，获得奖励：\n$_card" | sed '/^$/d')"
        myecho -e "$_output"
        return 0
    else
        echo "阿里签到失败"
        return 1
    fi
}

aliyun_update_checkin_single() {
    tokens="$(retry_command "read_File $1")"
    echo "$tokens" | sed '/^$/d' | while read token; do
        retry_command "checkin $token"
        response=$(curl --connect-timeout 5 -m 5 -s -H "Content-Type: application/json" \
            -d '{"grant_type":"refresh_token", "refresh_token":"'$token'"}' \
            https://api.aliyundrive.com/v2/account/token)
        new_refresh_token=$(echo "$response" | sed -n 's/.*"refresh_token":"\([^"]*\).*/\1/p')
        if [ -n "$new_refresh_token" ]; then
            docker exec "$XIAOYA_NAME" sed -i 's/'"$token"'/'"$new_refresh_token"'/g' "/data/$1"
        fi
    done
}

aliyun_update_checkin() {
    aliyun_update_checkin_single "mycheckintoken.txt"
    aliyun_update_checkin_single "mytoken.txt"
}

_clear_aliyun() {
    #eval "$(retry_command "get_Header")"
    raw_list=$(retry_command "get_rawList")
    path=$(retry_command "get_Path")
    _list="$(get_List)"
    echo "$_list" | sed '/^$/d' | while read line; do
        retry_command "delete_File \"$line\""
    done
    return "$(echo "$_list" | sed '/^$/d' | wc -l)"
}

clear_aliyun() {
    eval "$(retry_command "get_Header")"
    raw_list=$(retry_command "get_rawList 0")
    _list="$(get_List)"
    if [ -z "$(echo "$_list" | sed '/^$/d')" ]; then
        return 0
    fi

    myecho -e "\n[$(date '+%Y/%m/%d %H:%M:%S')]开始清理小雅$XIAOYA_NAME转存"

    _res=1
    _filenum=0
    while [ ! $_res -eq 0 ]; do
        _clear_aliyun
        _res=$?
        _filenum=$(($_filenum + $_res))
    done

    myecho "本次共清理小雅$XIAOYA_NAME转存文件$_filenum个"

}

get_PostCmd() {
    pos=$(read_File mycmd.txt | grep -n "#xiaoyakeeper-$XIAOYA_NAME-begin\|#xiaoyakeeper-$XIAOYA_NAME-end" | awk -F: '{print $1}')
    if [ "$(echo "$pos" | wc -l)" -lt 2 ]; then
        return
    fi
    pos="$(echo "$pos" | tr '\n' ':')"
    begin="$(echo "$pos" | awk -F: '{print $1}')"
    end="$(echo "$pos" | awk -F: '{print $2}')"
    read_File mycmd.txt | head -n "$end" | tail -n +"$begin"
}

init_para() {
    XIAOYA_NAME="$1"
    refresh_token="$(retry_command "read_File mytoken.txt" | head -n1)"

    post_cmd="$(get_PostCmd)"
    #if [ -z "$post_cmd" ];then
    #post_cmd='docker restart "'$XIAOYA_NAME'" >/dev/null 2>&1'
    #fi

    file_id=$(retry_command "read_File temp_transfer_folder_id.txt")

    folder_type=$(read_File "folder_type.txt")

    _file_time="$(retry_command "read_File myruntime.txt" | grep -Eo "[0-9]{2}:[0-9]{2}" | tr '\n' ' ')"

    chat_id="$(retry_command "read_File mychatid.txt")"
    echo "  chat_id:$chat_id  " >&6

    run_time="$script_run_time"
    if [ -n "$_file_time" ]; then
        run_time="$_file_time"
    fi

}

clear_aliyun_realtime() {
    xiaoya_name="$(echo "$XIAOYA_NAME" | tr '-' '_')"
    #eval "_file_count_new_$xiaoya_name=$(docker logs $XIAOYA_NAME 2>&1 | grep https | grep security-token | wc -l)"
    eval "_file_count_new_$xiaoya_name=$(docker logs $XIAOYA_NAME 2>&1 | wc -l)"
    eval "_file_count_new=\"\$_file_count_new_$xiaoya_name\""
    eval "_file_count_old=\"\$_file_count_old_$xiaoya_name\""
    if [ "$_file_count_new"x != "$_file_count_old"x ]; then
        clear_aliyun
    fi
    eval "_file_count_old_$xiaoya_name=\"\$_file_count_new_$xiaoya_name\""
}

clear_aliyun_single_docker() {
    init_para "$1"
    copy_tvbox_files
    case "$run_mode" in
    0)
        for time in $(echo "$run_time" | tr ',' ' '); do
            if [ "$current_time" = "$time" ]; then
                clear_aliyun
                aliyun_update_checkin
                eval "$post_cmd"
                sche=1
            fi
        done
        ;;
    55)
        clear_aliyun_realtime
        for time in $(echo "$run_time" | tr ',' ' '); do
            if [ "$current_time" = "$time" ]; then
                clear_aliyun
                aliyun_update_checkin
                eval "$post_cmd"
                sche=1
            fi
        done
        ;;
    1)
        clear_aliyun
        aliyun_update_checkin
        ;;
    *)
        return 1
        ;;
    esac
}

clear_aliyun_all_docker_pre_update() {
    org_run_mode=$run_mode
    run_mode=1
    for line in $(echo -e "$dockers" | sed '/^$/d'); do
        clear_aliyun_single_docker "$line"
    done
    run_mode=$org_run_mode
}

clear_aliyun_all_docker() {
    dockers="$(get_Xiaoya)"
    current_time="$(date +%H:%M)"
    for line in $(echo -e "$dockers" | sed '/^$/d'); do
        clear_aliyun_single_docker "$line"
    done
}

copy_tvbox_files() {
    docker exec "$XIAOYA_NAME" bash -c 'copy_tvbox_files() {
    source_dir="/data"
    target_dir1="/www/tvbox"
    target_dir2="/www/tvbox/json"
    target_dir3="/www/tvbox/libs"
    target_dir4="/www/tvbox/cat"
    target_dir5="/www/tvbox/cat/libs"
    target_dir6="/www/tvbox/cat/lib"

    mkdir -p "$target_dir1"
    mkdir -p "$target_dir2"
    mkdir -p "$target_dir3"
    mkdir -p "$target_dir4"
    mkdir -p "$target_dir5"
    mkdir -p "$target_dir6"
    ali_tiken="$(cat /data/mytoken.txt)"

    copy_files_by_extension() {
        local ext=$1
        local target_dir=$2

        shopt -s nullglob
        local files=("$source_dir"/*."$ext")

        for file in "${files[@]}"; do
            file_name=$(basename "$file")
            target_file="$target_dir/$file_name"
            src_content="$(cat "$file" | sed "s/ALI_SHORT_TOKEN/$ali_tiken/g")"
            if [ -f "$target_file" ]; then
                dst_content="$(cat "$target_file")"
                if [ "$src_content"x != "$dst_content"x ]; then
                    echo "$src_content" > "$target_file"
                else
                    :
                fi
            else
                echo "$src_content" > "$target_file"
            fi
        done
    }
    
    recursive_copy() {
    local source="$1"
    local destination="$2"
    mkdir -p "$destination"

    for item in "$source"/*; do
        local filename=$(basename "$item")
        local dest_path="$destination/$filename"
        
        if [ -d "$item" ]; then
            if [ ! -d "$dest_path" ]; then
                mkdir "$dest_path"
            fi
            recursive_copy "$item" "$dest_path"
        elif [ -f "$item" ]; then
            src_content="$(cat "$item" | sed "s/ALI_SHORT_TOKEN/$ali_tiken/g")"
            if [ -f "$dest_path" ]; then
                dst_content="$(cat "$dest_path")"
                if [ "$src_content"x != "$dst_content"x ]; then
                    echo "$src_content" > "$dest_path"
                else
                    :
                fi
            else
                echo "$src_content" > "$dest_path"
            fi
        fi
    done
}

    recursive_copy "/data/tvbox" "/www/tvbox"
    copy_files_by_extension "json" "$target_dir1"
    copy_files_by_extension "json" "$target_dir2"
    copy_files_by_extension "js" "$target_dir3"
    copy_files_by_extension "json" "$target_dir4"
    copy_files_by_extension "js" "$target_dir4"
    copy_files_by_extension "js" "$target_dir5"
    copy_files_by_extension "js" "$target_dir6"
}

copy_tvbox_files'
}

docker_pull() {
    repo_tag="$1"
    mirrors="$(curl --insecure -fsSL https://ddsrem.com/xiaoya/all_in_one.sh | awk '/mirrors=\(/,/\)/' | sed -n 's/^[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p' | grep -v "docker\.io")"
    mirrors="$(
        for line in $mirrors; do
            curl -s -o /dev/null -m 4 -w '%{time_total} '$line'\n' --head --request GET "$line" &
        done
        wait
    )"
    mirrors="$(echo "$mirrors" | sort -n | awk '{print $2}')"
    repo="$(echo "$repo_tag" | awk -F: '{print $1}')"
    tag="$(echo "$repo_tag" | awk -F: '{print $2}')"
    old_image_id="$(docker images | grep "$repo" | grep "$tag" | grep -Eo "[0-9a-f]{6,128}")"
    for mirror in $mirrors; do
        echo "尝试使用镜像源拉取：$mirror/$repo_tag"
        docker tag "$repo_tag" "$mirror/$para_i" > /dev/null 2>&1
        docker rmi "$repo_tag" > /dev/null 2>&1
        docker pull "$mirror/$repo_tag"
        res=$?
        docker tag "$mirror/$repo_tag" "$repo_tag" > /dev/null 2>&1
        docker rmi "$mirror/$repo_tag" > /dev/null 2>&1
        if [ $res -eq 0 ]; then
            break
        fi
    done
    new_image_id="$(docker images | grep "$repo" | grep "$tag" | grep -Eo "[0-9a-f]{6,128}")"
    if [ "$new_image_id"x != "$old_image_id"x ];then
        docker tag "$old_image_id" "$repo:none" > /dev/null 2>&1
    fi
}

update_xiaoya() {
    sleep 60
    para_v="$(docker inspect --format='{{range $v,$conf := .Mounts}}-v {{$conf.Source}}:{{$conf.Destination}} {{$conf.Type}}~{{end}}' $XIAOYA_NAME | tr '~' '\n' | grep bind | sed 's/bind//g' | grep -Eo "\-v .*:.*" | tr '\n' ' ')"
    para_n="$(docker inspect --format='{{range $m, $conf := .NetworkSettings.Networks}}--network={{$m}}{{end}}' $XIAOYA_NAME | grep -Eo "\-\-network=host")"
    tag="latest"
    if [ "$(get_docker_info $XIAOYA_NAME | grep "ailg/alist")"x != x ]; then
        tag="test"
    fi
    if [ "$para_n"x != x ]; then
        tag="hostmode"
    fi
    para_p="$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}~{{$p}}{{$conf}} {{end}}' $XIAOYA_NAME | tr '~' '\n' | tr '/' ' ' | tr -d '[]{}' | awk '{printf("-p %s:%s\n",$3,$1)}' | grep -Eo "\-p [0-9]{1,10}:[0-9]{1,10}" | tr '\n' ' ')"
    para_i="$(get_docker_info $XIAOYA_NAME | awk '{print $2}'):$tag"
    para_e="$(docker inspect --format='{{range $p, $conf := .Config.Env}}~{{$conf}}{{end}}' $XIAOYA_NAME 2>/dev/null | sed '/^$/d' | tr '~' '\n' | sed '/^$/d' | awk '{printf("-e \"%s\"\n",$0)}' | tr '\n' ' ')"
    #docker pull "$para_i" 2>&1
    docker_pull "$para_i"
    cur_image=$(get_docker_info $XIAOYA_NAME | awk '{print $3}')
    latest_image=$(docker images --no-trunc | tail -n +2 | tr ':' ' ' | awk '{printf("%s:%s %s\n",$1,$2,$4)}' | grep "$para_i" | awk '{print $2}')

    if [ "$cur_image"x != "$latest_image"x ]; then
        docker stop "$XIAOYA_NAME"
        docker rm -v "$XIAOYA_NAME"
        eval "$(echo docker run -d "$para_n" "$para_v" "$para_p" "$para_e" --restart=always --name="$XIAOYA_NAME" "$para_i")"
    else
        docker restart "$XIAOYA_NAME"
    fi

    docker rmi -f $(docker images | grep "$(echo $para_i | awk -F: '{print $1}')" | grep none | grep -Eo "[0-9a-f]{6,128}") >/dev/null 2>&1
}

session="$((RANDOM % 90000000 + 10000000))"
gen_post_cmd_single() {
    init_para "$1"
    if [ "$cmd_delay" -eq 0 ]; then
        cmd='#tag:'$session'，命令只能写在以下begin和end之间，否则不会被执行
#xiaoyakeeper-'$XIAOYA_NAME'-begin
#update_xiaoya是一个内置命令，如果小雅镜像有更新则更新小雅容器，否则重启小雅容器。可以替换成你自己的命令，如果不懂则不建议修改。
update_xiaoya
#xiaoyakeeper-'$XIAOYA_NAME'-end
'
    else
        cmd='#tag:'$session'，命令只能写在以下begin和end之间，否则不会被执行
#xiaoyakeeper-'$XIAOYA_NAME'-begin
{
sleep '$cmd_delay'
#update_xiaoya是一个内置命令，如果小雅镜像有更新则更新小雅容器，否则重启小雅容器。可以替换成你自己的命令，如果不懂则不建议修改。
update_xiaoya
}&
#xiaoyakeeper-'$XIAOYA_NAME'-end
'
    fi
    write_File_ClearIfNoTag mycmd.txt "$cmd" "#tag:$session"
    #write_File mycmd.txt "$cmd"
}

gen_post_cmd_all() {
    if [ -f /docker-entrypoint.sh ]; then
        return 0
    fi
    dockers="$(get_Xiaoya)"
    cmd_delay=0
    for line in $(echo -e "$dockers" | sed '/^$/d'); do
        gen_post_cmd_single "$line"
        cmd_delay=$((cmd_delay + 600))
    done
}

install_env() {
    if [ ! -f /docker-entrypoint.sh ]; then
        return 0
    fi

    #http://mirrors.ustc.edu.cn/alpine/v3.18/main
    #http://mirrors.ustc.edu.cn/alpine/v3.18/community
    #echo 'https://mirrors.nju.edu.cn/alpine/v3.18/main
    #https://mirrors.nju.edu.cn/alpine/v3.18/community' > /etc/apk/repositories

    if ! docker --help &>/dev/null; then
        apk add docker-cli
    fi

    if ! docker --help &>/dev/null; then
        echo "安装docker工具失败"
        return 1
    fi

    if ! curl --help &>/dev/null; then
        apk add curl
    fi

    if ! curl --help &>/dev/null; then
        echo "安装curl工具失败"
        return 1
    fi

    if [ -z "$(date | grep "CST")" ]; then
        apk add tzdata
        cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        echo "Asia/Shanghai" >/etc/timezone
    fi
}

install_keeper() {
    #docker image prune -af
    #docker volume prune -f
    #docker volume prune -af 2>/dev/null
    dockers="$(get_Xiaoya)"
    XIAOYA_NAME="$(echo -e "$dockers" | sed '/^$/d' | head -n1)"
    #XIAOYA_ROOT="$(docker inspect --format='{{range $v,$conf := .Mounts}}{{$conf.Source}}:{{$conf.Destination}}{{$conf.Type}}~{{end}}' "$XIAOYA_NAME" | tr '~' '\n' | grep bind | sed 's/bind//g' | grep ":/data" | awk -F: '{print $1}')"

    #小雅文件夹有可能没权限，换一个目录作为临时目录
    #XIAOYA_ROOT="/var/run"

    if [ -z "$newsh" ] && [ -n "$(cat "$0" | head -n 1 | grep "^#!/bin/bash")" ]; then
        newsh="$(cat "$0")"
    fi

    if [ -z "$newsh" ]; then
        echo "网络问题，下载脚本失败，请多尝试几次、科学上网安装或下载TG群文件中的aliyun_clear.sh离线安装：bash ./aliyun_clear.sh 5，其中参数“5”是指模式5，可以改为其它模式"
        return 0
    fi

    #echo "$newsh" > "$XIAOYA_ROOT/aliyun_clear.sh"
    docker rm -f -v xiaoyakeeper >/dev/null 2>&1
    network="--network=host"
    if para -b; then
        network=""
    fi
    docker_pull "ddsderek/xiaoyakeeper:latest"
    docker run --name xiaoyakeeper --restart=always $network --privileged -v /var/run/docker.sock:/var/run/docker.sock -e TZ="Asia/Shanghai" -d ddsderek/xiaoyakeeper:latest sh -c "if [ -f /etc/xiaoya/aliyun_clear.sh ];then sh /etc/xiaoya/aliyun_clear.sh $1;else sleep 60;fi"
    docker exec xiaoyakeeper touch /docker-entrypoint.sh
    docker exec xiaoyakeeper sh -c "mkdir /etc/xiaoya > /dev/null 2>&1"
    #docker cp $XIAOYA_ROOT/aliyun_clear.sh xiaoyakeeper:/etc/xiaoya/aliyun_clear.sh
    echo "$newsh" | docker exec -i xiaoyakeeper sh -c 'cp /dev/stdin /etc/xiaoya/aliyun_clear.sh'

    docker exec xiaoyakeeper chmod +x "/etc/xiaoya/aliyun_clear.sh"
    #rm -f "$XIAOYA_ROOT/aliyun_clear.sh"
    docker restart xiaoyakeeper

    if [ -z "$(docker ps | grep xiaoyakeeper)" ]; then
        echo "启动失败，请把命令报错信息以及以下信息反馈给作者修改"
        echo "系统信息：$(uname -a)"
        echo "docker路径：$(which docker)"
        echo "docker状态：$(docker ps | grep xiaoyakeeper)"
        echo "docker运行日志："
        echo "$(docker logs --tail 10 xiaoyakeeper)"
    else
        echo "小雅看护docker(xiaoyakeeper)已启动"
    fi
}

read_File() {
    _r=0
    _res=""
    if docker exec "$XIAOYA_NAME" [ -f "/data/$1" ]; then
        _res="$(docker exec "$XIAOYA_NAME" cat "/data/$1")"
        _r=$?
    fi
    echo "$_res"
    return $_r
}

write_File() {
    docker exec "$XIAOYA_NAME" bash -c "echo -e \"$2\" > \"/data/$1\""
    return $?
}

apend_File() {
    docker exec "$XIAOYA_NAME" bash -c "echo -e \"$2\" >> \"/data/$1\""
    return $?
}

write_File_ClearIfNoTag() {
    if [ -z "$(read_File "$1" | grep "$3")" ]; then
        write_File "$1" ""
    fi
    apend_File "$1" "$2"
}

if ! install_env; then
    echo "小雅守护初始化失败，即将重试10次"
    retry_command "install_env"
    if ! install_env; then
        echo "重试10次后初始化失败，可能遇到了网络问题，1小时后将重启容器继续重试"
        sleep 3600
        exit 0
    fi
fi

run_mode=0
next_min=$(($(date +%s) + 60))
script_run_time="$(date -d "@$next_min" +'%H:%M')"

if [ -n "$1" ]; then
    run_mode="$1"
fi

if [ ! -f /docker-entrypoint.sh ]; then
    touch /var/run/xiaoyakeeper.pid
    kill -9 "$(cat /var/run/xiaoyakeeper.pid)" &>/dev/null
    echo $$ >/var/run/xiaoyakeeper.pid
fi

dockers="$(get_Xiaoya)"
if [ -z "$(echo -e "$dockers" | sed '/^$/d' | head -n1)" ]; then
    echo "你还没有安装小雅docker，请先安装！"
    exit 0
fi

get_ChatId() {
    code="$((RANDOM % 90000000 + 10000000))"
    echo "请先发送验证码$code给机器人@xiaoyahelper_bot，发送成功后请敲回车键继续，不发验证码直接敲回车表示用上次验证的账号推送，如果从来没有验证过则不推送。请2分钟内完成，超时自动跳过。"
    sleep 2
    read -t 120 line
    chat_id="$(curl --connect-timeout 5 -m 5 -H "User-Agent: xiaoyapush" $tg_push_api_url/getUpdates -d "$code" 2>/dev/null | sed 's/{"message_id"/\n{"message_id"/g' | grep "$code" | grep -Eo '"id":[0-9]{1,20}' | tail -n 1 | tr -d '"' | awk -F: '{print $2}')"
    if [ -z "$chat_id" ]; then
        return 0
    fi

    dockers="$(get_Xiaoya)"
    echo -e "$dockers" | sed '/^$/d' | while read line; do
        org_chat_id=$chat_id
        init_para "$line"
        chat_id=$org_chat_id
        write_File "mychatid.txt" "$org_chat_id"
    done
}

myecho() {
    echo "$@"
    echo "$@" >&6
}

push_msg() {
    _chat_id="$(echo "$@" | grep -Eo "chat_id:[0-9]{1,20}" | awk -F: '{print $2}' | tail -n 1)"
    if [ -n "$_chat_id" ]; then
        chat_id=$_chat_id
    fi
    text="$(echo "$@" | grep -v 'chat_id:')"
    if [ -n "$chat_id" ] && [ -n "$text" ]; then
        curl --connect-timeout 5 -m 5 -s -X POST -H "User-Agent: xiaoyapush;ver=$ver" -H 'Content-Type: application/json' -d '{"chat_id": '$chat_id',"text": "'"$text"'"}' "$tg_push_api_url/sendMessage" &>/dev/null
    fi
}

tmp_fifofile="./$$.fifo"
mkfifo $tmp_fifofile &>/dev/null
if [ ! $? -eq 0 ]; then
    mknod $tmp_fifofile p
fi
exec 6<>$tmp_fifofile
rm -f $tmp_fifofile

if para -tg; then
    get_ChatId
fi

start_push_proc() {
    {
        msg=""
        while [ -n "$(ps | sed "s/^/ /" | grep " $$ " | grep -v grep)" ]; do
            if read -t 20 -u 6 line; then
                msg="$msg\n$line"
            else
                if [ -n "$(echo -e "$msg" | tail -n +2)" ]; then
                    push_msg "$(echo -e "$msg" | tail -n +2)"
                fi
                msg=""
            fi
            sleep 1
        done
    } &
}

push_proc_keeper() {
    if ! which pgrep &>/dev/null; then
        return
    fi
    count=$(pgrep -P $$ -l | grep -v sleep | grep -v grep | wc -l)
    if [ $count -gt 1 ]; then
        return
    fi
    start_push_proc
}

if [ ! -f /docker-entrypoint.sh ]; then
    if [ "$run_mode" -eq 0 ] || [ "$run_mode" -eq 1 ]; then
        echo "你正在使用不推荐的模式$run_mode，建议使用模式3或模式5"
    fi
fi

start_push_proc
case "$run_mode" in
0 | 55)
    myecho -e "\n[$(date '+%Y/%m/%d %H:%M:%S')]小雅缓存清理(ver=$ver)运行中"
    while :; do
        sche=0
        push_proc_keeper
        clear_aliyun_all_docker
        fast_triger_update
        sleep $((60 - $(date +%s) % 60))
    done
    ;;
1)
    clear_aliyun_all_docker
    if [ -n "$chat_id" ]; then
        echo "等待完成消息推送中，马上结束运行"
        sleep 30
    fi
    ;;
2)
    echo "本模式已不再支持，建议使用模式3或模式4"
    ;;
3 | 4)
    gen_post_cmd_all
    install_keeper 0
    ;;
5)
    gen_post_cmd_all
    install_keeper 55
    ;;
*)
    echo "不支持的模式"
    ;;
esac

exec 6>&- >/dev/null 2>&1
