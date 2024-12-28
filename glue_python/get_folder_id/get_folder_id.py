# pylint: disable=C0114
#!/usr/local/bin/python3

import os
import json
import logging
import argparse

import requests
from aligo import Aligo


def write_to_file(file_path, data):
    """
    数据写入文件
    """
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(data)


def get_refresh_token(path):
    """
    获取 refresh_token
    """
    with open(f'{path}/mytoken.txt', encoding='utf-8') as file:
        return file.readline().strip()


def update_refresh_token(path):
    """
    更新 refresh_token
    """
    file_path = os.path.join(os.path.expanduser("~"), ".aligo", "aligo.json")
    try:
        with open(file_path, encoding='utf-8') as file:
            data = json.load(file)
            aligo_refresh_token = data.get("refresh_token")
            if not aligo_refresh_token:
                logging.error("读取 Refresh Token 失败")
                return False
    except Exception as e: # pylint: disable=W0718
        logging.error("读取 Refresh Token 发生错误：%s", e)
        return False
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.54 Safari/537.36",  # noqa: E501
        "Content-Type": "application/json",
        "Referer": "https://www.aliyundrive.com/"
    }
    data = {
        "refresh_token": aligo_refresh_token,
        "grant_type": "refresh_token"
    }
    try:
        response = requests.post("https://auth.aliyundrive.com/v2/account/token", headers=headers, json=data, timeout=10)  # noqa: E501
        response.raise_for_status()
        _refresh_token = response.json().get("refresh_token")
        if _refresh_token:
            with open(f"{path}/mytoken.txt", "w", encoding='utf-8') as file:
                file.write(_refresh_token)
            logging.info("刷新 Refresh Token 成功")
            return True
        else:
            logging.error("刷新 Refresh Token 失败")
            return False
    except requests.RequestException:
        logging.error("网络问题，无法刷新 Refresh Token")
        return False


def get_folder_id(client, drive_mode):
    """
    获取 folder id
    """
    if drive_mode == 'r':
        v2_user = client.v2_user_get()
        resource_drive_id = v2_user.resource_drive_id
        client.default_drive_id = resource_drive_id
    file_list = client.get_file_list()
    _folder_id = ''
    for folder in file_list:
        if folder.name == '小雅转存文件夹':
            _folder_id = folder.file_id
            break
    if not _folder_id:
        try:
            _folder_id = client.create_folder(name='小雅转存文件夹').file_id
        except Exception as e: # pylint: disable=W0718
            logging.error("创建 小雅转存文件夹 失败：%s", e)
            return None
    return _folder_id


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser(description='Get Folder ID')
    parser.add_argument('--drive_mode', type=str, required=True, help='选择操作盘类型，资源盘：r，备份盘：b')
    parser.add_argument('--data_path', type=str, required=True, help='小雅配置文件路径')
    args = parser.parse_args()
    refresh_token = get_refresh_token(args.data_path)
    try:
        ali = Aligo(refresh_token=refresh_token)
    except Exception as e: # pylint: disable=W0718
        logging.error("登入阿里云盘失败：%s", e)
    folder_id = get_folder_id(ali, args.drive_mode)
    if folder_id is not None:
        logging.info('阿里云盘转存目录 folder id: %s', folder_id)
        write_to_file(f'{args.data_path}/temp_transfer_folder_id.txt', folder_id)
        write_to_file(f'{args.data_path}/folder_type.txt', args.drive_mode)
    else:
        logging.error('自动获取 阿里云盘转存目录 folder id 失败，请手动获取！')
    if not update_refresh_token(args.data_path):
        logging.error('请手动更新 mytoken.txt 文件中的 Refresh Token')
