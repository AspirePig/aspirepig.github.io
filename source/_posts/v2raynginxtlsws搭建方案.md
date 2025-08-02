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

系统 ubuntu 22



Linux系统中直接使用以下命令进行一键安装：

`bash <(curl -L -s https://install.direct/go.sh)` 已失效

最新 https://github.com/v2fly/fhs-install-v2ray/blob/master/README.zh-Hans-CN.md

安装完成后，修改配置文件 `/usr/local/etc/v2ray/config.json` 如下：

```json
{
   "inbounds": [
     {
       "listen": "127.0.0.1",
       "port": 10800,
       "protocol": "vmess",
       "settings": {
         "clients": [
           {
             "id": "b1d53297-870d-4967-9ff0-f16aa315ddde",
             "alterId": 64
           }
         ]
       },
       "streamSettings": {
         "network": "ws",
         "wsSettings": {
         "path": "/blog"
         }
       }
     }
   ],
   "outbounds": [
     {
       "protocol": "freedom",
       "settings": {}
     }
   ]
 }
```

V2RAY常用控制命令：

systemctl status v2ray
systemctl start v2ray
systemctl stop v2ray
systemctl restart v2ray
systemctl enable v2ray

## 0x01：https证书申请

此处我是直接从腾讯云申请的一年免费ssl证书，上传到VPS上，过程忽略

或者使用自签证书

https://github.com/michaelliao/itranswarp.js/blob/master/conf/ssl/gencert.sh

```
./gencert.sh  注意更改脚本 1024 为 2048，否则出现密钥长度不够



#!/bin/sh

# create self-signed server certificate:
read -p "Enter your domain [www.example.com]: " DOMAIN
echo "Create server key..."
openssl genrsa -des3 -out $DOMAIN.key 2048
echo "Create server certificate signing request..."
SUBJECT="/C=US/ST=Mars/L=iTranswarp/O=iTranswarp/OU=iTranswarp/CN=$DOMAIN"
openssl req -new -subj $SUBJECT -key $DOMAIN.key -out $DOMAIN.csr
echo "Remove password..."
mv $DOMAIN.key $DOMAIN.origin.key
openssl rsa -in $DOMAIN.origin.key -out $DOMAIN.key
echo "Sign SSL certificate..."
openssl x509 -req -days 3650 -in $DOMAIN.csr -signkey $DOMAIN.key -out $DOMAIN.crt
echo "TODO:"
echo "Copy $DOMAIN.crt to /etc/nginx/ssl/$DOMAIN.crt"
echo "Copy $DOMAIN.key to /etc/nginx/ssl/$DOMAIN.key"
echo "Add configuration in nginx:"
echo "server {"
echo "    ..."
echo "    listen 443 ssl;"
echo "    ssl_certificate     /etc/nginx/ssl/$DOMAIN.crt;"
echo "    ssl_certificate_key /etc/nginx/ssl/$DOMAIN.key;"
echo "}"
```

## 0x02：Nginx 配置

```
server {
    server_name xxx;
    listen 443 ssl;
    root /var/www/html;
    autoindex on;
    ssl_certificate /etc/nginx/ssl/xxx.crt;
    ssl_certificate_key /etc/nginx/ssl/xxx.key;

    error_page 404 /404.html;
        location = /40x.html {
    }

    error_page 500 502 503 504 /50x.html;
        location = /50x.html {
    }

    location /blog {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10800;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
    }
}

```

重启nginx



## 0x03：客户端配置

服务端启动后，客户端按刚才的配置进行填写，如图，需要注意id、alterid、path需与服务器配置对应

