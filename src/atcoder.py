import vim
import requests
from bs4 import BeautifulSoup


def getText(url):
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


def submit(contest, diff, path):
    session = requests.session()

    res = session.get("http://atcoder.jp/login")
    page = BeautifulSoup(res.text, 'lxml')
    csrf_token = page.find(attrs={'name': 'csrf_token'}).get('value')
    login_info = {
        "csrf_token": csrf_token,
        "username": vim.eval('g:atcoder_name'),
        "password": vim.eval('g:atcoder_pass'),
    }
    r = session.post(LOGIN_URL, data=login_info)

    resp = session.get("https://atcoder.jp/contests/" + contest + "/submit")

    soup = BeautifulSoup(resp.text, "html.parser")
    session_id = soup.find("input", attrs={"type": "hidden"}).get("value")

    with open(path) as f:
        source = f.read()

    postdata = {
        "csrf_token": session_id,
        "data.TaskScreenName": contest + "_" + diff,
        "data.LanguageId": "4003",
        "sourceCode": source
    }

    resp = session.post("https://atcoder.jp/contests/" + contest + "/submit", data=postdata)

    print("done")
