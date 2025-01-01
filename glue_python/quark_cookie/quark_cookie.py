#!/usr/local/bin/python3
# pylint: disable=C0114

import json
import time
import logging
import os
import threading
import sys
import argparse
import uuid

import requests
import qrcode
from flask import Flask, send_file, render_template, jsonify


app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
LAST_STATUS = 0
stop_event = threading.Event()
if sys.platform.startswith('win32'):
    QRCODE_DIR = 'qrcode.png'
else:
    QRCODE_DIR = '/quark_cookie/qrcode.png'


def cookiejar_to_string(cookiejar):
    """
    转换 Cookie 格式
    """
    cookie_string = ""
    for cookie in cookiejar:
        cookie_string += cookie.name + "=" + cookie.value + "; "
    return cookie_string.strip('; ')


# pylint: disable=W0603
def poll_qrcode_status(_token, stop, log_print):
    """
    循环等待扫码
    """
    global LAST_STATUS
    while not stop.is_set():
        _re = requests.get(f'https://uop.quark.cn/cas/ajax/getServiceTicketByQrcodeToken?client_id=532&v=1.2&token={_token}&request_id={uuid.uuid4()}', timeout=10)  # noqa: E501
        if _re.status_code == 200:
            re_data = json.loads(_re.text)
            if re_data['status'] == 2000000:
                logging.info('扫码成功！')
                service_ticket = re_data['data']['members']['service_ticket']
                _re = requests.get(f'https://pan.quark.cn/account/info?st={service_ticket}&lw=scan', timeout=10)
                if _re.status_code == 200:
                    quark_cookie = cookiejar_to_string(_re.cookies)
                    headers = {
                        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) quark-cloud-drive/2.5.20 Chrome/100.0.4896.160 Electron/18.3.5.4-b478491100 Safari/537.36 Channel/pckk_other_ch",  # noqa: E501
                        "Referer": "https://pan.quark.cn",
                        "Cookie": quark_cookie
                    }
                    _re = requests.get('https://drive-pc.quark.cn/1/clouddrive/config?pr=ucpro&fr=pc&uc_param_str=', headers=headers, timeout=10)  # noqa: E501
                    if _re.status_code == 200:
                        quark_cookie += '; ' + cookiejar_to_string(_re.cookies)
                    else:
                        logging.error('获取 __puus 失败！')
                        LAST_STATUS = 2
                        break
                    if sys.platform.startswith('win32'):
                        with open('quark_cookie.txt', 'w', encoding='utf-8') as f:
                            f.write(quark_cookie)
                    else:
                        with open('/data/quark_cookie.txt', 'w', encoding='utf-8') as f:
                            f.write(quark_cookie)
                    logging.info('扫码成功，夸克 Cookie 已写入文件！')
                    LAST_STATUS = 1
                break
            elif re_data['status'] == 50004002:
                logging.error('二维码无效或已过期！')
                LAST_STATUS = 2
                break
            elif re_data['status'] == 50004001:
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
    parser = argparse.ArgumentParser(description='Quark Cookie')
    parser.add_argument('--qrcode_mode', type=str, required=True, help='扫码模式')
    args = parser.parse_args()
    logging.info('二维码生成中...')
    re = requests.get(f'https://uop.quark.cn/cas/ajax/getTokenForQrcodeLogin?client_id=532&v=1.2&request_id={uuid.uuid4()}', timeout=10)  # noqa: E501
    if re.status_code == 200:
        token = json.loads(re.text)['data']['members']['token']
        qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=5, border=4)
        qr.add_data(f'https://su.quark.cn/4_eMHBJ?token={token}&client_id=532&ssb=weblogin&uc_param_str=&uc_biz_str=S%3Acustom%7COPT%3ASAREA%400%7COPT%3AIMMERSIVE%401%7COPT%3ABACK_BTN_STYLE%400')
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")
        img.save(QRCODE_DIR)
        logging.info('二维码生成完成！')
    else:
        logging.error('二维码生成失败，退出进程')
        os._exit(1)
    try:
        if args.qrcode_mode == 'web':
            wait_status = threading.Thread(target=poll_qrcode_status, args=(token,stop_event,True,))
            wait_status.start()
            app.run(host='0.0.0.0', port=34256)
        elif args.qrcode_mode == 'shell':
            wait_status = threading.Thread(target=poll_qrcode_status, args=(token,stop_event,False,))
            wait_status.start()
            logging.info('请打开 夸克 APP 扫描此二维码！')
            qr.print_ascii(invert=True, tty=sys.stdout.isatty())
            while LAST_STATUS != 1 and LAST_STATUS != 2:
                time.sleep(1)
            if os.path.isfile(QRCODE_DIR):
                os.remove(QRCODE_DIR)
            if LAST_STATUS == 2:
                os._exit(1)
            os._exit(0)
        else:
            logging.error('未知的扫码模式')
            if os.path.isfile(QRCODE_DIR):
                os.remove(QRCODE_DIR)
            os._exit(1)
    except KeyboardInterrupt:
        if os.path.isfile(QRCODE_DIR):
            os.remove(QRCODE_DIR)
        stop_event.set()
        wait_status.join()
        os._exit(0)
