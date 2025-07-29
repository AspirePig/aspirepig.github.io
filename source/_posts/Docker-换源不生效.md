---
title: Docker 换源不生效
typora-root-url: ..
date: 2025-07-26 21:07:10
tags: [docker]
---

# Docker换源不生效





无论你是否有代理节点，想要docker配置的镜像源生效，一定要**额外添加上一个Proxy**！！！！（可以是你的宿主机），你的代理节点可以不用接外网，但是一定要配置，**只有配置了代理节点后，docker 才会优先走你自己配置的镜像源**

首先，我们要有一个代理的软件，然后找到这个软件监听的端口，这个代理软件可以不工作，只要启动后挂在后台运行那里就行。 找到这个软件监听的端口



## linux:

```json
{
 "dns": ["8.8.8.8", "8.8.4.4"],
 "registry-mirrors": [
        "https://docker.m.daocloud.io/",
        "https://huecker.io/",
        "https://dockerhub.timeweb.cloud",
        "https://noohub.ru/",
        "https://dockerproxy.com",
        "https://docker.mirrors.ustc.edu.cn",
        "https://docker.nju.edu.cn",
        "https://xx4bwyg2.mirror.aliyuncs.com",
        "http://f1361db2.m.daocloud.io",
        "https://registry.docker-cn.com",
        "http://hub-mirror.c.163.com"
    ],
 "proxies": {
        "http-proxy": "http://192.168.137.1:7890",
        "https-proxy": "http://192.168.137.1:7890"
  }
}
```



## windows:

![image-20250726210814019](/assets/image-20250726210814019.png)
