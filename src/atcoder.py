import vim
import requests
from bs4 import BeautifulSoup


def getText(url):
    import argparse
    parser = argparse.ArgumentParser()

    session = requests.session()

    res = session.get("http://atcoder.jp/login")
    page = BeautifulSoup(res.text, 'lxml')
    csrf_token = page.find(attrs={'name': 'csrf_token'}).get('value')
    login_info = {
        "csrf_token": csrf_token,
        "username": vim.eval('g:atcoder_name'),
        "password": vim.eval('g:atcoder_pass'),
    }
    session.post("http://atcoder.jp/login", data=login_info)

    page = session.get(url)

    page = BeautifulSoup(page.text, 'lxml').find_all(class_ = "part")
    s = vim.bindeval('s:')
    s['text'] = str(page)
