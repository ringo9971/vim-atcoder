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

### インストール
#### dein

```
[[plugins]]
repo = 'ringo9971/vim-atcoder'
```

#### NeoBundle

```
NeoBundle 'ringo9971/vim-atcoder'
```

#### Vundle

```
Plugin 'ringo9971/vim-atcoder'
```

### 使い方
```
[abc||arc||agc]
 └ [コンテスト番号]
    ├ A.cpp 
    ├ B.cpp 
    ├ C.cpp 
    └ D.cpp
```
というディレクトリ構成上で

```
:AtCoder
```
### 設定項目
```
let g:atcoder_login = 0 (デフォルトは0)
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

* C++ (g++ -std = gnu++1y -O2)
* Vim script (開発途中)
