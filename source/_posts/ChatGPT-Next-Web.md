---
title: ChatGPT_Next_Web
typora-root-url: ..
date: 2023-10-11 16:07:02
tags: chatgpt
---

## 00 项目地址

https://github.com/Yidadaa/ChatGPT-Next-Web



## 01 ChatGPT-Next-web 搭建

使用docker搭建命令如下：

例如在这此处买账号带key https://www.51chatgpt.info/

```bash
docker run -d -p 80:3000 -e OPENAI_API_KEY=sk-6xxxxxx -e CODE=password  yidadaa/chatgpt-next-web
```



如果不能 F/Q 可使用以下两种方式:

第三方 API 服务

例如 https://openkey.cloud/

```bash
docker run -d -p 80:3000 -e OPENAI_API_KEY=sk-txxxxxx -e CODE=password -e BASE_URL=https://openkey.cloud yidadaa/chatgpt-next-web
```

配置代理的方式

```bash
docker run -d -p 80:3000 -e OPENAI_API_KEY=sk-6xxxxxx -e CODE=password -e PROXY_URL=http://localhost:7890 yidadaa/chatgpt-next-web
```



## 03 测试使用

搭建完成效果如图

![image-20231011161446196](/assets/image-20231011161446196.png)

