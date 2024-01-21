#!/bin/bash

EMBY_URL=$1
EMBY_API=$2

USER_URL="${EMBY_URL}/Users?api_key=${EMBY_API}"  
response=$(curl -s "${USER_URL}")  
USER_COUNT=$(echo "${response}" | jq '. | length')
for(( i=0 ; i < $USER_COUNT ; i++ ))
do
    read -r name <<< "$(echo "${response}" | jq -r ".[$i].Name")"  
    read -r id <<< "$(echo "${response}" | jq -r ".[$i].Id")"
    read -r policy <<< "$(echo "${response}" | jq -r ".[$i].Policy | to_entries | from_entries | tojson")"
    USER_URL_2="${EMBY_URL}/Users/$id/Policy?api_key=${EMBY_API}"
    curl -i -H "Content-Type: application/json" -X POST -d "$policy" "$USER_URL_2"
done