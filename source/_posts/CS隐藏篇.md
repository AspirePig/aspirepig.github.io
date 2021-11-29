---
title: CS隐藏篇
typora-root-url: ..
date: 2021-11-29 09:49:34
Tags:
  - cs
  - nginx
  - cdn
  - 云函数
---

近期工作频繁用到cs，于是向古月大表哥要了一份CS隐藏教程，再结合一些其他教程，操作了一把。

## 1.修改默认端口

修改cs 默认端口，修改方法比较简单，直接修改 teamserver 文件中`cobaltstrike.server_port ` 参数即可

## 2.替换默认证书

CS启动后，会使用默认的keystore，该证书直接将 cs 相关字样写在证书信息中，因此需要我们自己创建一个自定义的keystore，防止资产探测及其他平台对IP进行打标

```
#使用keytool生成自定义证书，执行后，需要设置证书密码
keytool -keystore cobaltstrike.store -storepass sslvpn -keypass sslvpn -genkey -keyalg RSA -alias baidu.com -dname "CN=(ZhongGuo), OU=(EE), O=(CF), L=(BeiJing), ST=(HaiDian), C=(CN)"

#查看生成的自定义证书信息
keytool -list -v -keystore CobaltStrike.store
```

修改 teamserver 文件中keystore的密码为我们刚刚设置的密码

```bash
java -XX:ParallelGCThreads=4 -Dcobaltstrike.server_port=自定义端口 -Djavax.net.ssl.keyStore=./cobaltstrike.store -Djavax.net.ssl.keyStorePassword=证书密码 -server -XX:+AggressiveHeap -XX:+UseParallelGC -classpath ./cobaltstrike.jar server.TeamServer $*
```

## 3.使用Nginx做反代

以上两步操作，主要是用于隐藏 cs自己启动的端口信息，防止被外部资产探测平台标记。

使用Nginx反代，是为了防止我们创建的 监听器 被探测到并被标记（beacon）。此处也可以通过反编译cs代码，修改相关逻辑，防止被探测识别。可参考文章：https://cloud.tencent.com/developer/article/1764340

为了简单，此处使用了 防火墙+Nginx 反代的操作进行隐藏，以下为详细步骤：

### iptables禁止外部访问

首先，假设我们将 https的监听端口放在44321，如下创建监听器

<img src="/assets/image-20211129101509628.png" alt="image-20211129101509628" style="zoom:67%;" />

创建完成后，使用iptables对该端口限制只能 127.0.0.1 访问

```bash
iptables -AINPUT -s 127.0.0.1 -ptcp --dport 44321 -j ACCEPT
iptables -AINPUT -ptcp --dport 44321 -j DROP
```

#### 配置Nginx

首先安装Nginx，安装后，默认配置应当在 /etc/nginx 下。

```bash
yum install nginx
```

安装完成后，为了使用https，我们可以自签或者申请免费的https证书。 由于后续使用了cloudflare cdn，cloudflare 直接替我们申请了https 证书。此处记录自签名证书生成过程

生成key 和 crt 文件，放置在Nginx配置目录

```
openssl genrsa -out ca.key 2048
openssl req -new -x509 -key ca.key -out server.crt -days 365
```

修改Nginx配置，此处 监听在443端口，并且通过 user-agent 参数对访问源进行屏蔽（当前使用的jQuery profile，下文会将如何修改profile文件，此处可按实际情况修改）。

为了 CS 能够获取到 客户端真实IP，添加 `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;` 

```nginx
server {
  listen 443;
  server_name  _;
  ssl on;
  ssl_certificate   ./server.crt;
  ssl_certificate_key  ./ca.key;
  ssl_session_timeout 5m;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

  #set_real_ip_from 0.0.0.0/0;
  #real_ip_header CF-Connecting-IP;

  location ~* {
    if ($http_user_agent != "你的jQuery profile配置文件中的UA") {
    	proxy_pass          http://127.0.0.1:12345;
    	}
    #proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass          https://127.0.0.1:44321;
	}
}

```

到这一步，生成相关的木马，应当是可以正常上线的。

但当前也还存在着一些问题，如证书不可信（此处Nginx使用免费的，受信任的证书）、域名暴露、IP暴露、域名信誉度低等。

## 4.cloudflare CDN

使用CDN可以隐藏真实IP，cloudflare 注册及启用cdn不再此介绍，可参考另一篇文章 https://aspirepig.cn/2021/11/23/wordpress-qian-yi-hexo/ 中第六部分 **6.使用 cloudflare 免费CDN加速访问（可选）**

配置完成后，此处我们配置禁用缓存，防止产生某些回连问题。

在规则页面，点击创建页面规则，创建完成后如下

![image-20211129104215784](/assets/image-20211129104215784.png)



## 5.cloudflare 云函数

cloudflare 有一个workers，可使用JavaScript语言实现自定义函数，免费用户每天有10万的请求量。

![image-20211129103521015](/assets/image-20211129103521015.png)

点击create service

<img src="/assets/image-20211129103557801.png" alt="image-20211129103557801" style="zoom:67%;" />

输入我们想要自定义的域名，选择 http handler

<img src="/assets/image-20211129103655311.png" alt="image-20211129103655311" style="zoom:67%;" />

创建 service，然后点击快速编辑，输入自定义代码，修改其中的上游地址

```
let upstream = 'https://cdn.xxxx.xx'

addEventListener('fetch', event => {
    event.respondWith(fetchAndApply(event.request));
})
async function fetchAndApply(request) {
    constipAddress = request.headers.get('cf-connecting-ip') || '';
    let requestURL = newURL(request.url);
    let upstreamURL = newURL(upstream);
    requestURL.protocol = upstreamURL.protocol;
    requestURL.host = upstreamURL.host;
    requestURL.pathname = upstreamURL.pathname + requestURL.pathname;
let new_request_headers = newHeaders(request.headers);
    new_request_headers.set("X-Forwarded-For", ipAddress);
    let fetchedResponse = await fetch(
        newRequest(requestURL, {
            method: request.method,
            headers: new_request_headers,
            body: request.body
        })
    );
    let modifiedResponseHeaders = newHeaders(fetchedResponse.headers);
    modifiedResponseHeaders.delete('set-cookie');
    returnnewResponse(
        fetchedResponse.body,
        {
            headers: modifiedResponseHeaders,
            status: fetchedResponse.status,
            statusText: fetchedResponse.statusText
        }
    );
}

```

## 6.修改profile文件

profile文件中，可以自定义交互的payload，自定义参数等，具体修改此处不做记录。可参考以下两个仓库：

```
https://github.com/threatexpress/malleable-c2  #jQuery profile
https://github.com/rsmudge/Malleable-C2-Profiles
```

假设使用 jQuery 文件，服务端启动命令如下

```
./teamserver.sh ip password jquery.profile
```



------

附 [CobaltStrike4.0用户手册_中文翻译](/assets/CobaltStrike4.0用户手册_中文翻译.pdf)

- [ ] 腾讯云 云函数
- [ ] 定制profile文件

