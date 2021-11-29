---
title: openwrt固件路由器设置定时重启
tags:
  - linux
  - misc
  - tools
id: '188'
categories:
  - - linux
  - - misc
date: 2017-01-20 18:03:10
---

计划任务中添加命令

```
00 04 * * * sleep 10 && touch /etc/banner && reboot  //每天凌晨4点自动重启
```

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2017/01/1TG1HZIEBZ1DPVL4A2-300x121.png) 然后在ssh连接到路由器，执行

```
/etc/init.d/cron restart
```