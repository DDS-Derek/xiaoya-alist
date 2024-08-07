#!/usr/local/bin/python3

import json
import requests
import time
import logging
import os
import threading
import sys
from PIL import Image
from io import BytesIO
from flask import Flask, send_file, render_template, jsonify
from urllib.parse import urlparse


app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
last_status = 0
if sys.platform.startswith('win32'):
    qrcode_dir = 'qrcode.png'
else:
    qrcode_dir= '/aliyunopentoken/qrcode.png'


headers = {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, br, zstd",
    "Accept-Language": "zh-CN,zh;q=0.9",
    "Content-Type": "application/json",
    "Origin": "https://alist.nn.ci",
    "Referer": "https://alist.nn.ci/",
    "Sec-Ch-Ua": '"Not)A;Brand";v="99", "Google Chrome";v="127", "Chromium";v="127"',
    "Sec-Ch-Ua-Mobile": "?0",
    "Sec-Ch-Ua-Platform": '"Windows"',
    "Sec-Fetch-Dest": "empty",
    "Sec-Fetch-Mode": "cors",
    "Sec-Fetch-Site": "cross-site",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36"
}
headers_2 = {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, br, zstd",
    "Accept-Language": "zh-CN,zh;q=0.9",
    "Content-Length": "111",
    "Content-Type": "application/json",
    "Origin": "https://alist.nn.ci",
    "Priority": "u=1, i",
    "Referer": "https://alist.nn.ci/",
    "Sec-CH-UA": '"Not)A;Brand";v="99", "Google Chrome";v="127", "Chromium";v="127"',
    "Sec-CH-UA-Mobile": "?0",
    "Sec-CH-UA-Platform": '"Windows"',
    "Sec-Fetch-Dest": "empty",
    "Sec-Fetch-Mode": "cors",
    "Sec-Fetch-Site": "cross-site",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36"
}


def poll_qrcode_status(data):
    global last_status
    while True:
        re = requests.get(f"https://api.xhofe.top/proxy/https://open.aliyundrive.com/oauth/qrcode/{data}/status", headers=headers)
        if re.status_code == 200:
            re_data = json.loads(re.text)
            if re_data['status'] == "LoginSuccess":
                authCode = re_data['authCode']
                data_2 = {"code": authCode,"grant_type": "authorization_code" ,"client_id": "" ,"client_secret": ""}
                re = requests.post('https://api.xhofe.top/alist/ali_open/code', json=data_2, headers=headers_2)
                if re.status_code == 200:
                    re_data = json.loads(re.text)
                    refresh_token = re_data['refresh_token']
                    if sys.platform.startswith('win32'):
                        with open('myopentoken.txt', 'w') as f:
                            f.write(refresh_token)
                    else:
                        with open('/data/myopentoken.txt', 'w') as f:
                            f.write(refresh_token)
                    logging.info('扫码成功, opentoken 已写入文件！')
                    last_status = 1
                    break
            else:
                logging.info('等待用户扫码...')
                time.sleep(2)
        else:
            logging.info('等待用户扫码...')
            time.sleep(2)


@app.route("/")
def index():
    return render_template('index.html')


@app.route('/image')
def serve_image():
    return send_file(qrcode_dir, mimetype='image/png')


@app.route('/status')
def status():
    if last_status == 1:
        return jsonify({'status': 'success'})
    elif last_status == 2:
        return jsonify({'status': 'failure'})
    else:
        return jsonify({'status': 'unknown'})


@app.route('/shutdown_server', methods=['GET'])
def shutdown():
    if os.path.isfile(qrcode_dir):
        os.remove(qrcode_dir)
    os._exit(0)


if __name__ == '__main__':
    if os.path.isfile(qrcode_dir):
        os.remove(qrcode_dir)
    logging.info('二维码生成中...')
    while True:
        re = requests.get('https://api.xhofe.top/alist/ali_open/qr', headers=headers)
        if re.status_code == 200:
            re_data = json.loads(re.content)
            qrCodeUrl = re_data['qrCodeUrl']
            # sid = re_data['sid']
            re = requests.get(qrCodeUrl, headers=headers)
            if re.status_code == 200:
                image_stream = BytesIO(re.content)
                image = Image.open(image_stream)
                image.save(qrcode_dir)
                path = urlparse(qrCodeUrl).path.split('/')
                components = path
                value_after_qrcode = components[components.index('qrcode') + 1]
                if os.path.isfile(qrcode_dir):
                    logging.info('二维码生成完成！')
                    break
                else:
                    time.sleep(1)
        else:
            if json.loads(re.text)['code'] == 'Too Many Requests':
                logging.warning("Too Many Requests 请一小时后重试！")
                os._exit(0)
    threading.Thread(target=poll_qrcode_status, args=(value_after_qrcode,)).start()
    app.run(host='0.0.0.0', port=34256)
