#!/usr/local/bin/python3

import json
import base64
import requests
import time
import logging
import os
import threading
import sys
from PIL import Image
import io
from flask import Flask, send_file, render_template, jsonify


app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
last_status = 0
if sys.platform.startswith('win32'):
    qrcode_dir = 'qrcode.png'
else:
    qrcode_dir= '/aliyuntoken/qrcode.png'


def poll_qrcode_status(data):
    global last_status
    ck = str(data['ck'])
    t = str(data['t'])
    while True:
        re = requests.get(f'https://aliyuntoken.vercel.app/api/state-query?ck={ck}&t={t}')
        if re.status_code == 200:
            re_data = json.loads(re.text)
            if re_data['data']['qrCodeStatus'] == 'CONFIRMED':
                refresh_token = re_data['data']['bizExt']['pds_login_result']['refreshToken']
                if sys.platform.startswith('win32'):
                    with open('mytoken.txt', 'w') as f:
                        f.write(refresh_token)
                else:
                    with open('/data/mytoken.txt', 'w') as f:
                        f.write(refresh_token)
                logging.info('扫码成功, refresh_token 已写入文件！')
                last_status = 1
                break
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
    while True:
        logging.info('二维码生成中...')
        re = requests.get('https://aliyuntoken.vercel.app/api/generate?img=true')
        if re.status_code == 200:
            re_data = json.loads(re.content)
            t = str(re_data['t'])
            codeContent = re_data['codeContent'].replace("data:image/png;base64,", "")
            ck = re_data['ck']
            image_bytes = base64.b64decode(codeContent)
            image = Image.open(io.BytesIO(image_bytes))
            image.save(qrcode_dir)
            data = {"ck": ck, "t": t}
            if os.path.isfile(qrcode_dir):
                logging.info('二维码生成完成！')
                break
            else:
                time.sleep(1)
    threading.Thread(target=poll_qrcode_status, args=(data,)).start()
    app.run(host='0.0.0.0', port=34256)
