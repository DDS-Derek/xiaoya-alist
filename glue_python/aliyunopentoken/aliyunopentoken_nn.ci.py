# pylint: disable=C0114
#!/usr/local/bin/python3

import time
import logging
import os
import threading
import sys
import argparse
import json

import qrcode
import requests
from flask import Flask, send_file, render_template, jsonify


app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
LAST_STATUS = 0
if sys.platform.startswith('win32'):
    QRCODE_DIR = 'qrcode.png'
else:
    QRCODE_DIR= '/aliyunopentoken/qrcode.png'


# pylint: disable=W0603
def poll_qrcode_status(data, log_print):
    """
    循环等待扫码
    """
    global LAST_STATUS
    while True:
        url = f"https://api-cf.nn.ci/proxy/https://open.aliyundrive.com/oauth/qrcode/{data}/status"
        _re = requests.get(url, timeout=10)
        if _re.status_code == 200:
            _re_data = json.loads(_re.text)
            if _re_data['status'] == "LoginSuccess":
                auth_code = _re_data['authCode']
                data_2 = {"code": auth_code, "grant_type": "authorization_code", "client_id": "", "client_secret": ""}
                _re = requests.post('https://api-cf.nn.ci/alist/ali_open/code', json=data_2, timeout=10)
                if _re.status_code == 200:
                    _re_data = json.loads(_re.text)
                    refresh_token = _re_data['refresh_token']
                    if sys.platform.startswith('win32'):
                        with open('myopentoken.txt', 'w', encoding='utf-8') as f:
                            f.write(refresh_token)
                    else:
                        with open('/data/myopentoken.txt', 'w', encoding='utf-8') as f:
                            f.write(refresh_token)
                    logging.info('扫码成功, opentoken 已写入文件！')
                    LAST_STATUS = 1
                    break
                else:
                    if json.loads(_re.text)['code'] == 'Too Many Requests':
                        logging.warning("Too Many Requests 请一小时后重试！")
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
    parser = argparse.ArgumentParser(description='AliyunPan Open Token')
    parser.add_argument('--qrcode_mode', type=str, required=True, help='扫码模式')
    args = parser.parse_args()
    logging.info('二维码生成中...')
    RE_COUNT = 0
    while True:
        re = requests.get('https://api-cf.nn.ci/alist/ali_open/qr', timeout=10)
        if re.status_code == 200:
            re_data = json.loads(re.content)
            sid = re_data['sid']
            qr_code_url = f"https://www.aliyundrive.com/o/oauth/authorize?sid={sid}"
            qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=5, border=4)
            qr.add_data(qr_code_url)
            qr.make(fit=True)
            img = qr.make_image(fill_color="black", back_color="white")
            img.save(QRCODE_DIR)
            if os.path.isfile(QRCODE_DIR):
                logging.info('二维码生成完成！')
                break
        else:
            if json.loads(re.text)['code'] == 'Too Many Requests':
                logging.warning("Too Many Requests 请一小时后重试！")
                os._exit(0)
        time.sleep(1)
        RE_COUNT += 1
        if RE_COUNT == 3:
            logging.error('二维码生成失败，退出进程')
            os._exit(1)
    if args.qrcode_mode == 'web':
        threading.Thread(target=poll_qrcode_status, args=(sid, True)).start()
        app.run(host='0.0.0.0', port=34256)
    elif args.qrcode_mode == 'shell':
        threading.Thread(target=poll_qrcode_status, args=(sid, False)).start()
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
