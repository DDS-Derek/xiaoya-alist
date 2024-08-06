#!/usr/local/bin/python3

import asyncio
import os
import shutil
import subprocess
import time
from multiprocessing import Process
from flask import Flask, send_file, render_template, jsonify
from playwright.async_api import async_playwright
from typing import Dict, Union, List
from pyvirtualdisplay import Display


app = Flask(__name__)
filename = 'screenshot.png'


async def save_cookies(page) -> None:
    cookie = await page.context.cookies()
    with open(f'cookies.txt', 'w', encoding='utf-8') as f:
        f.write(str(cookie))


async def save_screenshot():
    print("正在进行Playwright初始化...")
    os.environ['PLAYWRIGHT_BROWSERS_PATH'] = './firefox'
    result = subprocess.run(['playwright', 'install', 'firefox'])
    if result.returncode != 0:
        print("Playwright 安装失败！")
    async with async_playwright() as p:
        context = await p.firefox.launch_persistent_context(
            './firefox_user_data',
            headless=True,
            slow_mo=50
        )
        page = await context.new_page()
        await page.goto('https://pan.quark.cn/')
        await asyncio.sleep(3)
        await page.screenshot(path='screenshot.png')
        initial_url = page.url
        while page.url == initial_url:
            await asyncio.sleep(1)
        await save_cookies(page)
        print('用户已扫码并登陆！')
        await context.close()


def cookies_str_to_dict(cookies_str: str) -> Dict[str, str]:
    cookies_dict = {}
    cookies_list = cookies_str.split('; ')
    for cookie in cookies_list:
        key, value = cookie.split('=', 1)
        cookies_dict[key] = value
    return cookies_dict


def transfer_cookies(cookies_list: List[Dict[str, Union[str, int]]]) -> Dict[str, str]:
    cookies_dict = {}
    for cookie in cookies_list:
        if 'quark' in cookie['domain']:
            cookies_dict[cookie['name']] = cookie['value']
    return cookies_dict


def dict_to_cookie_str(cookies_dict: Dict[str, str]) -> str:
    cookie_str = '; '.join([f"{key}={value}" for key, value in cookies_dict.items()])
    return cookie_str


def check_cookies() -> Union[None, Union[Dict[str, str], str]]:
    try:
        with open(f'cookies.txt', 'r') as f:
            content = f.read()

        if content and '[' in content:
            saved_cookies = eval(content)
            cookies_dict = transfer_cookies(saved_cookies)
            timestamp = int(time.time())
            if 'expires' in cookies_dict and timestamp > int(cookies_dict['expires']):
                return None
            return cookies_dict
        else:
            return content.strip()
    except Exception as e:
        print(f"Error checking cookies: {e}")
        return None


def get_cookies() -> Union[str, None]:
    cookie = check_cookies()
    if isinstance(cookie, dict):
        return dict_to_cookie_str(cookie)
    elif isinstance(cookie, str):
        return cookie


@app.route("/")
def show_html():
    return render_template('index.html')


@app.route('/image')
def serve_image():
    return send_file('screenshot.png', mimetype='image/png')


@app.route('/status')
def status():
    if os.path.isfile('last_status.txt'):
        with open('last_status.txt', 'r') as file:
            last_status = int(file.read())
    else:
        last_status = 0
    if last_status == 1:
        return jsonify({'status': 'success'})
    elif last_status == 2:
        return jsonify({'status': 'failure'})
    else:
        return jsonify({'status': 'unknown'})


@app.route('/shutdown_server', methods=['GET'])
def shutdown():
    if os.path.isfile('last_status.txt'):
        os.remove('last_status.txt')
    os._exit(0)


def run_flask():
    while True:
        if os.path.isfile('screenshot.png'):
            break
    app.run(host='0.0.0.0', port=34256)


def run_display():
    try:
        _display = Display(visible=False, size=(1024, 768), extra_args=[os.environ['DISPLAY']])
        _display.start()
    except Exception as err:
        print(f"DisplayHelper init error: {str(err)}")


def main():
    if os.path.isdir('./firefox_user_data'):
        shutil.rmtree('./firefox_user_data')
    if os.path.isfile('cookies.txt'):
        os.remove('cookies.txt')
    if os.path.isfile('screenshot.png'):
        os.remove('screenshot.png')
    if os.path.isfile('last_status.txt'):
        os.remove('last_status.txt')
    asyncio.run(save_screenshot())
    cookies = get_cookies()
    with open(f'quark_cookie.txt', 'w', encoding='utf-8') as f:
        f.write(str(cookies))
    with open('last_status.txt', 'w', encoding='utf-8') as f:
        f.write('1')
    time.sleep(2)
    # shutil.rmtree('./firefox')
    if os.path.isdir('./firefox_user_data'):
        shutil.rmtree('./firefox_user_data')
    if os.path.isfile('cookies.txt'):
        os.remove('cookies.txt')
    if os.path.isfile('screenshot.png'):
        os.remove('screenshot.png')
    print("您的 夸克Cookie 已写入 quark_cookie.txt 文件！")


if __name__ == '__main__':
    Process(target=main).start()
    Process(target=run_flask).start()
