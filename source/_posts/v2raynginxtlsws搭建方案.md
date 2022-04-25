---
title: V2RAY+Nginx+TLS+ws搭建方案
tags: []
id: '598'
categories:
  - - linux
date: 2020-02-24 19:27:54
password: 9fc56569332932ef770770441eb011e8006bef813c989b7b8594d882a6926732
---

当前ss和ssr已经无法很好的隐藏，使用V2RAY可以伪装成各种协议，此处不再细说其好处和区别。以下为安装过程

## 0x00：安装V2RAY

Linux系统中直接使用以下命令进行一键安装：

`bash <(curl -L -s https://install.direct/go.sh)`

安装完成后，修改配置文件 `/etc/v2ray/config.json` 如下：

```
{
   "inbounds": \[
     {
       "listen": "127.0.0.1",
       "port": 2333,
       "protocol": "vmess",
       "settings": {
         "clients": \[
           {
             "id": "b1d53297-870d-4967-9ff0-f16aa315ddde",
             "alterId": 64
           }
         \]
       },
       "streamSettings": {
         "network": "ws",
         "wsSettings": {
         "path": "/blog"
         }
       }
     }
   \],
   "outbounds": \[
     {
       "protocol": "freedom",
       "settings": {}
     }
   \]
 }
```

V2RAY常用控制命令：

systemctl stauts v2ray
systemctl start v2ray
systemctl stop v2ray
systemctl restart v2ray
systemctl enable v2ray

## 0x01：https证书申请

此处我是直接从腾讯云申请的一年免费ssl证书，上传到VPS上，过程忽略

## 0x02：Nginx 配置

```
server
    {
    listen 443 ssl http2;
    server_name     myblog.aspirepig.cn;
    index index.html index.htm ;
    root  /home/wwwroot/v2ray;
    ssl_certificate /usr/local/nginx/conf/ssl/v2ray.crt;
    ssl_certificate_key /usr/local/nginx/conf/ssl/v2ray.key;
    ssl_session_timeout 5m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5";
    ssl_session_cache builtin:1000 shared:SSL:10m;
    # openssl dhparam -out /usr/local/nginx/conf/ssl/dhparam.pem 2048
    ssl_dhparam /usr/local/nginx/conf/ssl/dhparam.pem;


    location /blog {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:2333;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }
}
```

## 0x03：客户端配置

服务端启动后，客户端按刚才的配置进行填写，如图，需要注意id、alterid、path需与服务器配置对应

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2020/02/image-792x1024.png)