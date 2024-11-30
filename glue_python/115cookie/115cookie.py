#!/usr/local/bin/python3

__author__ = "ChenyangGao <https://chenyanggao.github.io>"
__license__ = "GPLv3 <https://www.gnu.org/licenses/gpl-3.0.txt>"

from flask import Flask, render_template, jsonify
import threading
import time
import os
import base64
import logging
import argparse
import qrcode
import sys
from PIL import Image
from io import BytesIO
from enum import Enum
from json import loads
from urllib.parse import urlencode
from urllib.request import urlopen, Request


app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
last_status = 0


AppEnum = Enum("AppEnum", {
    "web": 1, 
    "ios": 6, 
    "115ios": 8, 
    "android": 9, 
    "115android": 11, 
    "115ipad": 14, 
    "tv": 15, 
    "qandroid": 16, 
    "windows": 19, 
    "mac": 20, 
    "linux": 21, 
    "wechatmini": 22, 
    "alipaymini": 23, 
})


def get_enum_name(val, cls):
    if isinstance(val, cls):
        return val.name
    try:
        if isinstance(val, str):
            return cls[val].name
    except KeyError:
        pass
    return cls(val).name


def get_qrcode_token():
    """获取登录二维码，扫码可用
    GET https://qrcodeapi.115.com/api/1.0/web/1.0/token/
    :return: dict
    """
    api = "https://qrcodeapi.115.com/api/1.0/web/1.0/token/"
    return loads(urlopen(api).read())


def get_qrcode_status(payload):
    """获取二维码的状态（未扫描、已扫描、已登录、已取消、已过期等）
    GET https://qrcodeapi.115.com/get/status/
    :param payload: 请求的查询参数，取自 `login_qrcode_token` 接口响应，有 3 个
        - uid:  str
        - time: int
        - sign: str
    :return: dict
    """
    api = "https://qrcodeapi.115.com/get/status/?" + urlencode(payload)
    return loads(urlopen(api).read())


def post_qrcode_result(uid, app="web"):
    """获取扫码登录的结果，并且绑定设备，包含 cookie
    POST https://passportapi.115.com/app/1.0/{app}/1.0/login/qrcode/
    :param uid: 二维码的 uid，取自 `login_qrcode_token` 接口响应
    :param app: 扫码绑定的设备，可以是 int、str 或者 AppEnum
        app 至少有 23 个可用值，目前找出 13 个：
            - 'web',         1, AppEnum.web
            - 'ios',         6, AppEnum.ios
            - '115ios',      8, AppEnum['115ios']
            - 'android',     9, AppEnum.android
            - '115android', 11, AppEnum['115android']
            - '115ipad',    14, AppEnum['115ipad']
            - 'tv',         15, AppEnum.tv
            - 'qandroid',   16, AppEnum.qandroid
            - 'windows',    19, AppEnum.windows
            - 'mac',        20, AppEnum.mac
            - 'linux',      21, AppEnum.linux
            - 'wechatmini', 22, AppEnum.wechatmini
            - 'alipaymini', 23, AppEnum.alipaymini
        还有几个备选：
            - bios
            - bandroid
            - qios（登录机制有些不同，暂时未破解）

        设备列表如下：

        | No.    | ssoent  | app        | description            |
        |-------:|:--------|:-----------|:-----------------------|
        |     01 | A1      | web        | 网页版                 |
        |     02 | A2      | ?          | 未知: android          |
        |     03 | A3      | ?          | 未知: iphone           |
        |     04 | A4      | ?          | 未知: ipad             |
        |     05 | B1      | ?          | 未知: android          |
        |     06 | D1      | ios        | 115生活(iOS端)         |
        |     07 | D2      | ?          | 未知: ios              |
        |     08 | D3      | 115ios     | 115(iOS端)             |
        |     09 | F1      | android    | 115生活(Android端)     |
        |     10 | F2      | ?          | 未知: android          |
        |     11 | F3      | 115android | 115(Android端)         |
        |     12 | H1      | ipad       | 未知: ipad             |
        |     13 | H2      | ?          | 未知: ipad             |
        |     14 | H3      | 115ipad    | 115(iPad端)            |
        |     15 | I1      | tv         | 115网盘(Android电视端) |
        |     16 | M1      | qandriod   | 115管理(Android端)     |
        |     17 | N1      | qios       | 115管理(iOS端)         |
        |     18 | O1      | ?          | 未知: ipad             |
        |     19 | P1      | windows    | 115生活(Windows端)     |
        |     20 | P2      | mac        | 115生活(macOS端)       |
        |     21 | P3      | linux      | 115生活(Linux端)       |
        |     22 | R1      | wechatmini | 115生活(微信小程序)    |
        |     23 | R2      | alipaymini | 115生活(支付宝小程序)  |
    :return: dict，包含 cookie
    """
    app = get_enum_name(app, AppEnum)
    payload = {"app": app, "account": uid}
    api = "https://passportapi.115.com/app/1.0/%s/1.0/login/qrcode/" % app
    return loads(urlopen(Request(api, data=urlencode(payload).encode("utf-8"), method="POST")).read())


def get_qrcode(uid: str, /) -> str:
    """获取二维码图片（注意不是链接）
    :return: 一个文件对象，可以读取
    """
    return urlopen("https://qrcodeapi.115.com/api/1.0/web/1.0/qrcode?uid=" + uid)


def qrcode_token_url(uid: str, /) -> str:
    """获取二维码图片的扫码链接
    :return: 扫码链接 
    """
    return "http://115.com/scan/dg-" + uid


def poll_qrcode_status(qrcode_token):
    global last_status
    while True:
        time.sleep(1)
        resp = get_qrcode_status(qrcode_token)
        status = resp["data"].get("status")
        if status == 2:
            resp = post_qrcode_result(qrcode_token["uid"], "alipaymini")
            cookie_data = resp['data']['cookie']
            cookie_str = "; ".join("%s=%s" % t for t in cookie_data.items())
            if sys.platform.startswith('win32'):
                with open('115_cookie.txt', 'w') as f:
                    f.write(cookie_str)
            else:
                with open('/data/115_cookie.txt', 'w') as f:
                    f.write(cookie_str)
            logging.info('扫码成功, cookie 已写入文件！')
            last_status = 1
        elif status in [-1, -2]:
            logging.error('扫码失败')
            last_status = 2


@app.route('/')
def index():
    qrcode_token = get_qrcode_token()["data"]
    uid = qrcode_token["uid"]
    qrcode_image_io = get_qrcode(uid)
    qrcode_image = Image.open(qrcode_image_io)
    buffered = BytesIO()
    qrcode_image.save(buffered, format="PNG")
    qrcode_image_b64_str = base64.b64encode(buffered.getvalue()).decode('utf-8')
    threading.Thread(target=poll_qrcode_status, args=(qrcode_token,)).start()
    return render_template('index.html', qrcode_image_b64_str=qrcode_image_b64_str)


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
    os._exit(0)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='115 Cookie')
    parser.add_argument('--qrcode_mode', type=str, help='扫码模式')
    args = parser.parse_args()
    if args.qrcode_mode == 'web':
        app.run(host='0.0.0.0', port=34256)
    elif args.qrcode_mode == 'shell':
        qrcode_token = get_qrcode_token()["data"]
        threading.Thread(target=poll_qrcode_status, args=(qrcode_token,)).start()
        qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=5, border=4)
        qr.add_data(qrcode_token_url(qrcode_token["uid"]))
        qr.make(fit=True)
        logging.info('请打开 115网盘 扫描此二维码！')
        qr.print_ascii(invert=True, tty=sys.stdout.isatty())
        while last_status != 1 and last_status != 2:
            time.sleep(1)
        os._exit(0)
    else:
        logging.error('未知的扫码模式')
        os._exit(1)
