---
title: Nessus crack&update
typora-root-url: ..
date: 2021-12-22 12:42:54
tags: linux
---



## 1.下载nessus安装包

访问 https://www.tenable.com/downloads/nessus 下载对应系统版本的nessus



## 2.安装

本文以 ubuntu 18.04 为例：

```
dpkg -i nessus.deb
```

启动 nessus

```
systemctl start nessusd
```

访问 https://xxx.xx:8834

选择 managed scanner

![image-20211222131635783](/assets/image-20211222131635783.png)

选择Tenable.sc然后Continue

![image-20211222131708884](/assets/image-20211222131708884.png)

设置nessus 账号和密码



## 3.更新插件包

获取 challenge code

```
/opt/nessus/sbin/nessuscli fetch --challenge
```

获取active code

http://www.tenable.com/products/nessus-home

访问 https://plugins.nessus.org/offline.php ，输入 challenge code  和 active code

下载 all-2.0.tar.gz 和license ，并将license放置到对应

![image-20211222171648569](/assets/image-20211222171648569.png)



使用nessus更新

```
./nessuscli update all.tar.gz
```

重新打开即可，可见当前没有scan权限，只有setting选项：

![image-20211222131915515](/assets/image-20211222131915515.png)

## 4.PJ激活

停止 nessus服务

```
systemctl stop nessusd
```

PLUGIN_SET 编号通过 上一步打开时进行获取

创建对应 plugin_feed_info.inc 文件

```
PLUGIN_SET = "202112201318";
PLUGIN_FEED = "ProfessionalFeed (Direct)";
PLUGIN_FEED_TRANSPORT = "Tenable Network Security Lightning"
```

使用该文件替换原始文件

```
copy plugin_feed_info.inc -rf /opt/nessus/lib/nessus/plugins/ #第一次先不用拷贝到这

copy plugin_feed_info.inc -rf /opt/nessus/var/nessus/
```

启动 nessus 

```
systemctl start nessusd
```

查看是否有 scan 功能

![image-20211222173724388](/assets/image-20211222173724388.png)
