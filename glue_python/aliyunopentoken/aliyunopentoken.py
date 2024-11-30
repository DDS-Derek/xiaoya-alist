#!/usr/local/bin/python3

import json
import requests
import time
import logging
import os
import threading
import sys
import qrcode
import argparse
from flask import Flask, send_file, render_template, jsonify


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


def poll_qrcode_status(data, log_print):
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
                if log_print:
                    logging.info('等待用户扫码...')
                time.sleep(2)
        else:
            if log_print:
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
    parser = argparse.ArgumentParser(description='AliyunPan Open Token')
    parser.add_argument('--qrcode_mode', type=str, help='扫码模式')
    args = parser.parse_args()
    logging.info('二维码生成中...')
    re_count = 0
    while True:
        re = requests.get('https://api.xhofe.top/alist/ali_open/qr', headers=headers)
        if re.status_code == 200:
            re_data = json.loads(re.content)
            sid = re_data['sid']
            qrCodeUrl = f"https://www.aliyundrive.com/o/oauth/authorize?sid={sid}"
            qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=5, border=4)
            qr.add_data(qrCodeUrl)
            qr.make(fit=True)
            img = qr.make_image(fill_color="black", back_color="white")
            img.save(qrcode_dir)
            if os.path.isfile(qrcode_dir):
                logging.info('二维码生成完成！')
                break
        else:
            if json.loads(re.text)['code'] == 'Too Many Requests':
                logging.warning("Too Many Requests 请一小时后重试！")
                os._exit(0)
        time.sleep(1)
        re_count += 1
        if re_count == 3:
            logging.error('二维码生成失败，退出进程')
            os._exit(1)
    if args.qrcode_mode == 'web':
        threading.Thread(target=poll_qrcode_status, args=(sid, True)).start()
        app.run(host='0.0.0.0', port=34256)
    elif args.qrcode_mode == 'shell':
        threading.Thread(target=poll_qrcode_status, args=(sid, False)).start()
        logging.info('请打开阿里云盘扫描此二维码！')
        qr.print_ascii(invert=True, tty=sys.stdout.isatty())
        while last_status != 1:
            time.sleep(1)
        if os.path.isfile(qrcode_dir):
            os.remove(qrcode_dir)
        os._exit(0)
    else:
        logging.error('未知的扫码模式')
        if os.path.isfile(qrcode_dir):
            os.remove(qrcode_dir)
        os._exit(1)
