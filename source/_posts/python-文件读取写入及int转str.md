---
title: python 文件读取写入及int转str
tags:
  - python
id: '385'
categories:
  - - python
date: 2018-01-21 13:38:30
---

读取写入文件：

```
打开函数
file_object = open("filename",'mode')

读取函数
file_object.read(size)  #读取指定大小字符，未指定这是整个文件
file_object.readline()  #读取一行
file_object.readlines()  #读取全文，自动分行
file_object.write()  #写入文件，关闭时才会从缓冲区写入
file_object.close()  #关闭文件
```

* * *

int,str互转

```
text = str(1234)
text = '1234' 
num = int('1234')
num = 1234
```

在import了os，sys模块后，使用str将int转为string会报错 原因1：变量名不可重复用  2：已经被预先定义 可以使用

bytes(\[int\]) #int转为str

若是需要转为Unicode编码，需要在前面写上

**import** os
**import** sys

reload(sys)
sys.setdefaultencoding(**'utf-8'**)