---
title: HTB学习
typora-root-url: ..
date: 2022-07-18 19:27:49
tags: HTB
---



1. ## PostgreSQL  run command

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
