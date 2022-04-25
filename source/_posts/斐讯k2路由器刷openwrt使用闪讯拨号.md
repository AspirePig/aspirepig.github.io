---
title: 斐讯K2路由器刷openwrt使用闪讯拨号
tags:
  - linux
  - misc
  - tools
id: '211'
categories:
  - - linux
  - - misc
  - - tools
date: 2017-03-17 20:57:40
---

原文链接：[http://www.right.com.cn/forum/thread-191833-1-1.html](http://www.right.com.cn/forum/thread-191833-1-1.html) 支持的版本

```
V22.3.15.128
V22.3.15.232 
V22.3.17.148
V22.4.2.8 
V22.4.2.9
```

*   若是固件版本高于要求的版本，先下载v22.4.4.9在手动升级中导入固件并升级
*   固件版本达到要求以后在备份恢复中刷入tianbaoha\_breed\_ssh.dat，重启后密码变为tianbaoha
*   这个时候breed已经刷进去了，如果需要刷入其他固件，可以再手动升级中直接刷入
*   接下来是闪讯拨号设置：
*   刷入openwrt固件后，配置wan口为pppoe，并填好闪讯账号密码，设置好无线名称密码，去除闪讯心跳
*   使用winscp连接路由器，用户名root，密码admin
*   找到/etc/config目录下的network打开  在option passwd下面添加一行option pppd\_options 'plugin sxplugin.so'
*   找到/usr/lib/pppod/2.4.7目录，然后将对应地区的sxplugin.so文件拖进去。权限设置成0755   ALL DONE!重启GOOD LUCK!