# vim-atcoder

AtCoderのテストケースを自動で通すプラグインです。<br>
ポップアップウインドウを使っているためVimのバージョン8.1.1561が必須です。

### 機能
AtCoderのテストケースのチェック

![scrennshot0](screenshot/screenshot0.jpg)
![scrennshot1](screenshot/screenshot1.jpg)
### 必須
* curl
* gcc
* vim 8.1.1561


### 使い方

ディレクトリ構成
```
.
├─ abc
│   ├ 169
│   │  ├ A.cpp 
│   │  ├ B.cpp 
│   │  ├ C.cpp 
│   │  └ D.cpp
│   ├ 170
│   │  :
│      
├─ arc
:   :
```


| コマンド                     | 説明                        |
|------------------------------|-----------------------------|
| :AtCoder                     | テストケース確認            |
| :AtCoderCurl `url`           | テストケース確認            |
| :AtCoderSubmit               | submit                      |
| :AtCoderAddTestCase          | テストケースの追加          |
| :AtCoderDeleteTestCase `num` | `num`番目のテストケース削除 |



### 設定項目
```
let g:atcoder_login = 0
```
1にすることでログインができる(レートがつくコンテストはログインしないと問題が見れない
)
```
let g:atcoder_name = [ユーザー名]
let g:atcoder_pass = [パスワード]
```
ログインに必要

```
let g:atcoder_directory = [任意のフォルダ]
```

### 対応言語

* C++ (g++ -std=gnu++17 -O2)
* Vim script (開発途中)
