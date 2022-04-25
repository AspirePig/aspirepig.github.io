---
title: 解决git太慢的方法
tags:
  - linux
  - python
id: '159'
categories:
  - - linux
  - - python
  - - tools
date: 2016-12-25 01:22:22
---

github.com 上有两种源码获取方式，一是 git clone，一是直接下载 master.zip，后者明显速度快于前者，可以考虑； 1.用 proxychains 这类透明代理，间接走系统中运行的代理工具中转； proxychains安装

```
git clone https://github.com/rofl0r/proxychains-ng.git
cd proxychains-ng
./configure
make && make install
cp ./src/proxychains.conf /etc/proxychians.conf
cd .. && rm -rf proxychains-ng
```

编辑proxychains配置

```
vim /etc/proxychains.conf
```

将socks4 127.0.0.1 9095改为

```
socks5  127.0.0.1 1080  //1080改为你自己的端口
```

使用方法

```
proxychains4 wget http://xxx.com/xxx.zip
```

2.用 git 内置代理，直接走系统中运行的代理工具中转，比如，你的 SS 本地端口是 1080，那么可以如下方式走代理

```
git config --global http.proxy socks5://127.0.0.1:1080
git config --global https.proxy socks5://127.0.0.1:1080
```

也可以如下方式停走代理

```
git config --global http.proxy ""
git config --global https.proxy ""
```

 

## 不装任何插件，终端中执行命令（配合ss使用）

```
export http_proxy="http://127.0.0.1:1087"
export https_proxy="http://127.0.0.1:1087"
```