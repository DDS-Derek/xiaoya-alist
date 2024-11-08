from flask import Flask, request, Response
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad
import json
import base64
import requests
import requests
import json
import uuid
import hashlib
import base64
import random


app = Flask(__name__)
headers = {
    "token": "6733b42e28cdba32",
    'User-Agent': 'Mozilla/5.0 (Linux; U; Android 9; zh-cn; SM-S908E Build/TP1A.220624.014) AppleWebKit/533.1 (KHTML, like Gecko) Mobile Safari/533.1',
    'Host': 'api.extscreen.com'
}


def h(char_array, modifier):
    unique_chars = list(dict.fromkeys(char_array))
    numeric_modifier = int(modifier[7:])
    transformed_string = "".join([chr(abs(ord(c) - (numeric_modifier % 127) - 1) + 33 if abs(ord(c) - (numeric_modifier % 127) - 1) < 33 else
                                         abs(ord(c) - (numeric_modifier % 127) - 1)) for c in unique_chars])
    return transformed_string


def decrypt(ciphertext, iv, t, unique_id, wifimac):
    try:
        key = generate_key(t, unique_id, wifimac)
        cipher = AES.new(key.encode('utf-8'), AES.MODE_CBC, iv = bytes.fromhex(iv))
        decrypted = unpad(cipher.decrypt(base64.b64decode(ciphertext)), AES.block_size)
        dec = decrypted.decode('utf-8')
        return dec
    except Exception as error:
        print("Decryption failed", error)
        raise error


def get_params(t, unique_id, wifimac):
    params = {
        'akv': '2.8.1496',
        'apv': '1.3.8',
        'b': 'samsung',
        'd': unique_id,
        'm': 'SM-S908E',
        'mac': '',
        'n': 'SM-S908E',
        't': t,
        'wifiMac': wifimac,
    }
    return params


def generate_key(t, unique_id, wifimac):
    params = get_params(t, unique_id, wifimac)
    sorted_keys = sorted(params.keys())
    concatenated_params = "".join([params[key] for key in sorted_keys if key != "t"])
    hashed_key = h(list(concatenated_params), t)
    return hashlib.md5(hashed_key.encode('utf-8')).hexdigest()


@app.route('/oauth/alipan/token', methods=['POST'])
def oauth_token():
    data = request.get_json()
    refresh_token = data.get('refresh_token', None)
    if not refresh_token:
        return Response(json.dumps({"error": "No refresh_token provided"}), status=400, mimetype='application/json')

    req_body = {
        "refresh_token": refresh_token
    }

    timestamp = str(requests.get('http://api.extscreen.com/timestamp').json()['data']['timestamp'])
    unique_id = uuid.uuid4().hex
    wifimac = str(random.randint(10**11, 10**12 - 1))

    resp = requests.post("http://api.extscreen.com/aliyundrive/v3/token", data=req_body, headers={**get_params(timestamp, unique_id, wifimac), **headers})
    if resp.status_code == 200:
        resp_data = resp.json()
        ciphertext = resp_data["data"]["ciphertext"]
        iv = resp_data["data"]["iv"]

        token_data = decrypt(ciphertext, iv, timestamp, unique_id, wifimac)
        token = json.loads(token_data)
        return Response(json.dumps(token), status=200, mimetype='application/json')
    else:
        return Response(resp.content, status=resp.status_code, mimetype='application/json')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=34278)
