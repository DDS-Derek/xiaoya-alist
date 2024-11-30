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
import random
from flask import Flask, send_file, render_template, jsonify


app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
last_status = 0
if sys.platform.startswith('win32'):
    qrcode_dir = 'qrcode.png'
else:
    qrcode_dir= '/uc_cookie/qrcode.png'


def cookiejar_to_string(cookiejar):
    cookie_string = ""
    for cookie in cookiejar:
        cookie_string += cookie.name + "=" + cookie.value + "; "
    return cookie_string.strip('; ')


def poll_qrcode_status(token, log_print):
    global last_status
    while True:
        __t = int(time.time() * 1000)
        data = {
            'client_id': 381,
            'v': 1.2,
            'request_id': __t,
            'token': token
        }
        re = requests.post(f'https://api.open.uc.cn/cas/ajax/getServiceTicketByQrcodeToken?__dt={random.randint(100, 999)}&__t={__t}', data=data)
        if re.status_code == 200:
            re_data = json.loads(re.content)
            if re_data['status'] == 2000000:
                logging.info('扫码成功！')
                service_ticket = re_data['data']['members']['service_ticket']
                re = requests.get(f'https://drive.uc.cn/account/info?st={service_ticket}')
                if re.status_code == 200:
                    uc_cookie = cookiejar_to_string(re.cookies)
                    if sys.platform.startswith('win32'):
                        with open('uc_cookie.txt', 'w') as f:
                            f.write(uc_cookie)
                    else:
                        with open('/data/uc_cookie.txt', 'w') as f:
                            f.write(uc_cookie)
                    logging.info('扫码成功，UC Cookie 已写入文件！')
                last_status = 1
                break
            elif re_data['status'] == 50004002:
                logging.error('二维码无效或已过期！')
                last_status = 2
                break
            elif re_data['status'] == 50004001:
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
    parser = argparse.ArgumentParser(description='UC Cookie')
    parser.add_argument('--qrcode_mode', type=str, help='扫码模式')
    args = parser.parse_args()
    logging.info('二维码生成中...')
    __t = int(time.time() * 1000)
    data = {
        'client_id': 381,
        'v': 1.2,
        'request_id': __t
    }
    re = requests.post(f'https://api.open.uc.cn/cas/ajax/getTokenForQrcodeLogin?__dt={random.randint(100, 999)}&__t={__t}', data=data)
    if re.status_code == 200:
        token = json.loads(re.content)['data']['members']['token']
        qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=5, border=4)
        qr.add_data(f'https://su.uc.cn/1_n0ZCv?uc_param_str=dsdnfrpfbivesscpgimibtbmnijblauputogpintnwktprchmt&token={token}&client_id=381&uc_biz_str=S%3Acustom%7CC%3Atitlebar_fix')
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")
        img.save(qrcode_dir)
        logging.info('二维码生成完成！')
    else:
        logging.error('二维码生成失败，退出进程')
        os._exit(1)
    if args.qrcode_mode == 'web':
        threading.Thread(target=poll_qrcode_status, args=(token,True,)).start()
        app.run(host='0.0.0.0', port=34256)
    elif args.qrcode_mode == 'shell':
        threading.Thread(target=poll_qrcode_status, args=(token,False,)).start()
        logging.info('请打开 UC浏览器 APP 扫描此二维码！')
        qr.print_ascii(invert=True, tty=sys.stdout.isatty())
        while last_status != 1 and last_status != 2:
            time.sleep(1)
        if os.path.isfile(qrcode_dir):
            os.remove(qrcode_dir)
        os._exit(0)
    else:
        logging.error('未知的扫码模式')
        if os.path.isfile(qrcode_dir):
            os.remove(qrcode_dir)
        os._exit(1)
