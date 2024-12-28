# pylint: disable=C0114
# pylint: disable=C0116
# pylint: disable=C0103
#!/usr/local/bin/python3

import time
import os
import logging
import json
import uuid
import hashlib
import base64
import random
import argparse
import sys

import requests
import qrcode
from flask import Flask, jsonify, render_template, request
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad


logging.basicConfig(level=logging.INFO)
app = Flask(__name__)
timestamp = str(requests.get('http://api.extscreen.com/timestamp', timeout=10).json()['data']['timestamp'])
unique_id = uuid.uuid4().hex
wifimac = str(random.randint(10**11, 10**12 - 1))
headers = {
    "token": "6733b42e28cdba32",
    'User-Agent': 'Mozilla/5.0 (Linux; U; Android 9; zh-cn; SM-S908E Build/TP1A.220624.014) AppleWebKit/533.1 (KHTML, like Gecko) Mobile Safari/533.1',  # noqa: E501
    'Host': 'api.extscreen.com'
}


def h(char_array, modifier):
    unique_chars = list(dict.fromkeys(char_array))
    numeric_modifier = int(modifier[7:])
    transformed_string = "".join([chr(abs(ord(c) - (numeric_modifier % 127) - 1) + 33 if abs(ord(c) - (numeric_modifier % 127) - 1) < 33 else  # noqa: E501
                                         abs(ord(c) - (numeric_modifier % 127) - 1)) for c in unique_chars])
    return transformed_string


def decrypt(ciphertext, iv, t, _unique_id, _wifimac):
    try:
        key = generate_key(t, _unique_id, _wifimac)
        cipher = AES.new(key.encode('utf-8'), AES.MODE_CBC, iv = bytes.fromhex(iv))
        decrypted = unpad(cipher.decrypt(base64.b64decode(ciphertext)), AES.block_size)
        dec = decrypted.decode('utf-8')
        return dec
    except Exception as error:
        print("Decryption failed", error)
        raise error


def get_params(t, _unique_id, _wifimac):
    params = {
        'akv': '2.8.1496',
        'apv': '1.3.8',
        'b': 'samsung',
        'd': _unique_id,
        'm': 'SM-S908E',
        'mac': '',
        'n': 'SM-S908E',
        't': t,
        'wifiMac': _wifimac,
    }
    return params


def generate_key(t, _unique_id, _wifimac):
    params = get_params(t, _unique_id, _wifimac)
    sorted_keys = sorted(params.keys())
    concatenated_params = "".join([params[key] for key in sorted_keys if key != "t"])
    hashed_key = h(list(concatenated_params), t)
    return hashlib.md5(hashed_key.encode('utf-8')).hexdigest()


def get_qrcode_url():
    data = requests.post('http://api.extscreen.com/aliyundrive/qrcode', data={
        'scopes': ','.join(["user:base", "file:all:read", "file:all:write"]),
        "width": 500,
        "height": 500,
    }, headers={**get_params(timestamp, unique_id, wifimac), **headers}, timeout=10).json()['data']
    _qr_link = "https://www.aliyundrive.com/o/oauth/authorize?sid=" + data['sid']
    return {'qr_link': _qr_link, 'sid': data['sid']}


def check_qrcode_status(_sid):
    status = 'NotLoggedIn'
    _auth_code = None
    while status != 'LoginSuccess':
        time.sleep(3)
        result = requests.get(f'https://openapi.alipan.com/oauth/qrcode/{_sid}/status', timeout=10).json()
        status = result['status']
        if status == 'LoginSuccess':
            _auth_code = result['authCode']
    return {'auth_code': _auth_code}


def get_token(code):
    token_data = requests.post('http://api.extscreen.com/aliyundrive/v3/token', data={
        'code': code,
    }, headers={**get_params(timestamp, unique_id, wifimac), **headers}, timeout=10).json()['data']
    ciphertext = token_data['ciphertext']
    iv = token_data['iv']
    token_data = decrypt(ciphertext, iv, timestamp, unique_id, wifimac)
    parsed_json = json.loads(token_data)
    refresh_token = parsed_json['refresh_token']
    if sys.platform.startswith('win32'):
        file_path = ""
    else:
        file_path = "/data/"
    with open(f"{file_path}myopentoken.txt", "w", encoding='utf-8') as file:
        file.write(refresh_token)
    logging.info('myopentoken.txt 文件更新成功！')
    with open(f"{file_path}open_tv_token_url.txt", "w", encoding='utf-8') as file:
        file.write("https://alipan-tv-token.pages.dev/refresh")
    logging.info('open_tv_token_url.txt 文件更新成功！')


@app.route('/')
def main_page():
    return render_template('qrcode.html')


@app.route('/get_qrcode', methods=['GET'])
def get_qrcode():
    return jsonify(get_qrcode_url())


@app.route('/check_qrcode/<sid>', methods=['GET'])
def check_qrcode(sid):
    return jsonify(check_qrcode_status(sid))


@app.route('/get_tokens', methods=['POST'])
def get_tokens():
    _auth_code = request.json.get('auth_code')
    get_token(_auth_code)
    return jsonify({'status': 'completed'})


@app.route('/shutdown_server', methods=['GET'])
def shutdown():
    os._exit(0)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='AliyunPan TV Token')
    parser.add_argument('--qrcode_mode', type=str, required=True, help='扫码模式')
    args = parser.parse_args()
    if args.qrcode_mode == 'web':
        app.run(host='0.0.0.0', port=34256)
    elif args.qrcode_mode == 'shell':
        date = get_qrcode_url()
        qr_link = date['qr_link']
        _sid = date['sid']
        qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=5, border=4)
        qr.add_data(qr_link)
        qr.make(fit=True)
        logging.info('请打开阿里云盘扫描此二维码！')
        qr.print_ascii(invert=True, tty=sys.stdout.isatty())
        auth_code = check_qrcode_status(_sid)['auth_code']
        get_token(auth_code)
    else:
        logging.error('未知的扫码模式')
        os._exit(1)
