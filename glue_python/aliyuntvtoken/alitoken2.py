#!/usr/local/bin/python3

from flask import Flask, jsonify, render_template, request
import requests
import time
import os
import logging
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad
import base64
import json

logging.basicConfig(level=logging.INFO)

app = Flask(__name__)

def decrypt_AES256_CBC_PKCS7(ciphertext, key, iv):
    key = key[:32]
    key = key.ljust(32, "\0")
    decoded_ciphertext = base64.b64decode(ciphertext)
    iv = bytes.fromhex(iv)
    cipher = AES.new(key.encode('utf8'), AES.MODE_CBC, iv=iv)
    decrypted_data = cipher.decrypt(decoded_ciphertext)
    unpadded_data = unpad(decrypted_data, AES.block_size)
    return unpadded_data.decode('utf8')

@app.route('/')
def main_page():
    return render_template('qrcode.html')

@app.route('/get_qrcode', methods=['GET'])
def get_qrcode():
    data = requests.post('http://api.extscreen.com/aliyundrive/qrcode', data={
        'scopes': ','.join(["user:base", "file:all:read", "file:all:write"]),
        "width": 500,
        "height": 500,
    }).json()['data']
    qr_link = "https://www.aliyundrive.com/o/oauth/authorize?sid=" + data['sid']
    return jsonify({'qr_link': qr_link, 'sid': data['sid']})

@app.route('/check_qrcode/<sid>', methods=['GET'])
def check_qrcode(sid):
    status = 'NotLoggedIn'
    auth_code = None
    while status != 'LoginSuccess':
        time.sleep(3)
        result = requests.get(f'https://openapi.alipan.com/oauth/qrcode/{sid}/status').json()
        status = result['status']
        if status == 'LoginSuccess':
            auth_code = result['authCode']
    return jsonify({'auth_code': auth_code})

@app.route('/get_tokens', methods=['POST'])
def get_tokens():
    code = request.json.get('auth_code')
    token_data = requests.post('http://api.extscreen.com/aliyundrive/v2/token', data={
        'code': code,
    }).json()['data']
    ciphertext = token_data['ciphertext']
    iv = token_data['iv']
    key = "^(i/x>>5(ebyhumz*i1wkpk^orIs^Na."
    token_data = decrypt_AES256_CBC_PKCS7(ciphertext, key, iv)
    parsed_json = json.loads(token_data)
    refresh_token = parsed_json['refresh_token']
    with open("/data/myopentoken.txt", "w") as file:
        file.write(refresh_token)
    logging.info('myopentoken.txt 文件更新成功！')
    with open("/data/open_tv_token_url.txt", "w") as file:
        file.write("https://alitv.sakurapy.de/token")
    logging.info('open_tv_token_url.txt 文件更新成功！')
    return jsonify({'status': 'completed'})

@app.route('/shutdown_server', methods=['GET'])
def shutdown():
    os._exit(0)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=34256)
