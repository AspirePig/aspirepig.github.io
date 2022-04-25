---
title: 使用python发送通过qq邮箱服务器发送邮件
tags:
  - misc
  - python
  - tools
id: '184'
categories:
  - - misc
  - - python
  - - tools
date: 2017-01-11 21:06:14
---

```
# coding:utf8
import smtplib
from smtplib import SMTP_SSL
from email.header import Header
from email.mime.text import MIMEText

mail_info = {
    "from": "xxx@qq.com",
    "to": "xxx@qq.com",
    "hostname": "smtp.qq.com",
    "username": "xxx@qq.com",
    "password": "xxx",
    "mail_subject": "test",
    "mail_text": "hello, this is a test email, sended by py",
    "mail_encoding": "utf-8"
}

if __name__ == '__main__':
    # 这里使用SMTP_SSL就是默认使用465端口
    smtp = SMTP_SSL(mail_info["hostname"])
    smtp.set_debuglevel(1)

    smtp.ehlo(mail_info["hostname"])
    smtp.login(mail_info["username"], mail_info["password"])

    msg = MIMEText(mail_info["mail_text"], "plain", mail_info["mail_encoding"])
    msg["Subject"] = Header(mail_info["mail_subject"], mail_info["mail_encoding"])
    msg["from"] = mail_info["from"]
    msg["to"] = mail_info["to"]

    smtp.sendmail(mail_info["from"], mail_info["to"], msg.as_string())

    smtp.quit()
```

更多例子[https://github.com/michaelliao/learn-python/tree/master/email](https://github.com/michaelliao/learn-python/tree/master/email)