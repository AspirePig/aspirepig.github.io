---
title: linux 一键搭建ss服务端
tags:
  - bash
  - linux
  - misc
  - python
id: '207'
categories:
  - - linux
  - - misc
  - - python
date: 2017-02-14 15:27:35
---

Debian参考https://teddysun.com/392.html 安装方式：

```
wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks.sh
```

```
chmod +x shadowsocks.sh
```

```
./shadowsocks.sh 2>&1  tee shadowsocks.log
```