# pylint: disable=C0114
#!/usr/local/bin/python3

import json
import base64
import time
import logging
import os
import threading
import sys
import argparse

import requests
import qrcode
from flask import Flask, send_file, render_template, jsonify


app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
LAST_STATUS = 0
if sys.platform.startswith('win32'):
    QRCODE_DIR = 'qrcode.png'
else:
    QRCODE_DIR= '/aliyuntoken/qrcode.png'


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
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36"  # noqa: E501
}


# pylint: disable=W0603
def poll_qrcode_status(_data, log_print):
    """
    循环等待扫码
    """
    global LAST_STATUS
    while True:
        _re = requests.post('https://api.xhofe.top/alist/ali/ck', json=_data, headers=headers, timeout=10)
        if _re.status_code == 200:
            _re_data = json.loads(_re.text)
            if _re_data['content']['data']['qrCodeStatus'] == 'CONFIRMED':
                h = _re_data['content']['data']['bizExt']
                c = json.loads(base64.b64decode(h).decode('gbk'))
                refresh_token = c['pds_login_result']['refreshToken']
                if sys.platform.startswith('win32'):
                    with open('mytoken.txt', 'w', encoding='utf-8') as f:
                        f.write(refresh_token)
                else:
                    with open('/data/mytoken.txt', 'w', encoding='utf-8') as f:
                        f.write(refresh_token)
                logging.info('扫码成功, refresh_token 已写入文件！')
                LAST_STATUS = 1
                break
            else:
                if log_print:
                    logging.info('等待用户扫码...')
                time.sleep(2)


@app.route("/")
def index():
    """
    网页扫码首页
    """
    return render_template('index.html')


@app.route('/image')
def serve_image():
    """
    获取二维码图片
    """
    return send_file(QRCODE_DIR, mimetype='image/png')


@app.route('/status')
def status():
    """
    扫码状态获取
    """
    if LAST_STATUS == 1:
        return jsonify({'status': 'success'})
    elif LAST_STATUS == 2:
        return jsonify({'status': 'failure'})
    else:
        return jsonify({'status': 'unknown'})


@app.route('/shutdown_server', methods=['GET'])
def shutdown():
    """
    退出进程
    """
    if os.path.isfile(QRCODE_DIR):
        os.remove(QRCODE_DIR)
    os._exit(0)


if __name__ == '__main__':
    if os.path.isfile(QRCODE_DIR):
        os.remove(QRCODE_DIR)
    parser = argparse.ArgumentParser(description='AliyunPan Refresh Token')
    parser.add_argument('--qrcode_mode', type=str, required=True, help='扫码模式')
    args = parser.parse_args()
    logging.info('二维码生成中...')
    re_count = 0
    while True:
        re = requests.get('https://api.xhofe.top/alist/ali/qr', headers=headers, timeout=10)
        if re.status_code == 200:
            re_data = json.loads(re.content)
            t = str(re_data['content']['data']['t'])
            codeContent = re_data['content']['data']['codeContent']
            ck = re_data['content']['data']['ck']
            data = {"ck": ck, "t": t}
            qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=5, border=4)
            qr.add_data(codeContent)
            qr.make(fit=True)
            img = qr.make_image(fill_color="black", back_color="white")
            img.save(QRCODE_DIR)
            if os.path.isfile(QRCODE_DIR):
                logging.info('二维码生成完成！')
                break
        time.sleep(1)
        re_count += 1
        if re_count == 3:
            logging.error('二维码生成失败，退出进程')
            os._exit(1)
    if args.qrcode_mode == 'web':
        threading.Thread(target=poll_qrcode_status, args=(data, True)).start()
        app.run(host='0.0.0.0', port=34256)
    elif args.qrcode_mode == 'shell':
        threading.Thread(target=poll_qrcode_status, args=(data, False)).start()
        logging.info('请打开阿里云盘扫描此二维码！')
        qr.print_ascii(invert=True, tty=sys.stdout.isatty())
        while LAST_STATUS != 1:
            time.sleep(1)
        if os.path.isfile(QRCODE_DIR):
            os.remove(QRCODE_DIR)
        os._exit(0)
    else:
        logging.error('未知的扫码模式')
        if os.path.isfile(QRCODE_DIR):
            os.remove(QRCODE_DIR)
        os._exit(1)
