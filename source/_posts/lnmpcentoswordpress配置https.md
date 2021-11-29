---
title: lnmp+centos+WordPress配置https
tags:
  - misc
id: '366'
categories:
  - - misc
date: 2017-12-17 15:54:24
---

环境：centOS7.0+lnmp搭建Apache下的Web服务，运行WordPress

#### 腾讯云给出的方法

#### 1.1 获取证书

Apache文件夹内获得证书文件 1\_root\_bundle.crt，2\_www.domain.com\_cert.crt 和私钥文件 3\_www.domain.com.key, 1\_root\_bundle.crt 文件包括一段证书代码 “-----BEGIN CERTIFICATE-----”和“-----END CERTIFICATE-----”, 2\_www.domain.com\_cert.crt 文件包括一段证书代码 “-----BEGIN CERTIFICATE-----”和“-----END CERTIFICATE-----”, 3\_www.domain.com.key 文件包括一段私钥代码“-----BEGIN RSA PRIVATE KEY-----”和“-----END RSA PRIVATE KEY-----”。

#### 1.2 证书安装

编辑Apache根目录下 conf/httpd.conf 文件， 找到 `#LoadModule ssl_module modules/mod_ssl.so` 和 `#Include conf/extra/httpd-ssl.conf`，去掉前面的`#`号注释； 编辑Apache根目录下 conf/extra/httpd-ssl.conf 文件，修改如下内容：

```
<VirtualHost www.domain.com:443>
    DocumentRoot "/var/www/html"
    ServerName www.domain.com
    SSLEngine on
    SSLCertificateFile /usr/local/apache/conf/2_www.domain.com_cert.crt
    SSLCertificateKeyFile /usr/local/apache/conf/3_www.domain.com.key
    SSLCertificateChainFile /usr/local/apache/conf/1_root_bundle.crt
</VirtualHost>
```

配置完成后，重新启动 Apache 就可以使用`https://www.domain.com`来访问了。

* * *

前面是腾讯云给出的配置方法，如果无法正常执行，则去掉 conf/extra/httpd-ssl.conf 中添加的代码，改用lnmp vhost add 添加完虚拟主机后，在 conf/vhost中刚生成的\*.conf文件中的内容修改为如下配置信息

```
NameVirtualHost *:443
<VirtualHost *:443>
ServerAdmin webmaster@example.com
php_admin_value open_basedir "/home/wwwroot:/tmp/:/var/tmp/:/proc/"
DocumentRoot "/home/wwwroot"
ServerName example.com
SSLEngine on
SSLCertificateFile /usr/local/apache/conf/2_example.com.crt
SSLCertificateKeyFile /usr/local/apache/conf/3_example.com.key
SSLCertificateChainFile /usr/local/apache/conf/1_example.com.crt
ErrorLog "/home/wwwlogs/y-error_log"
CustomLog "/home/wwwlogs/y-access_log" combined
<Directory "/home/wwwroot">
    SetOutputFilter DEFLATE
    Options FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
    DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
```

重启Apache服务，则可以通过https方式访问。

### 3\. 设置WordPress以HTTPS方式全局访问

1.进入WP后台，进入设置-常规 将WordPress地址（URL）、站点地址（URL）两项修改为：https。 通过上面的设置，绝大部分导航中的链接就由wordpress系统自动改为HTTPS版本。 2、对于正文中的内部链接需要手工修改，修改的方法有两种： 1）直接在数据库中更新，更新的sql如下：

> ```
> update wp_posts set post_content = replace(post_content, ‘http://example.com/’,‘https://example.com/’)
> ```

对于数据库不熟悉的站长不推荐这种方法，对数据库错误的更新对网站可能是毁灭性的打击，建议更新前最好备份数据库。 2） 登录和后台强制开启SSL 通过修改WP-config.php文件，直接在文件末尾加入以下两行代码： /\* 强制后台和登录使用 SSL \*/

> ```
> define('FORCE_SSL_LOGIN', true);
> define('FORCE_SSL_ADMIN', true);
> ```

## 整站301跳转

在.htaccess文件添加如下代码：

> ```
> RewriteEngine On
> RewriteCond %{SERVER_PORT} 80
> RewriteRule ^(.*)$ https://www.watch-life.net/$1 [R=301,L]
> RewriteCond %{HTTP_HOST} ^watch-life.net [NC]
> RewriteRule ^(.*)$ https://www.watch-life.net/$1 [L,R=301]
> ```

以上代码，更换相应的域名即可使用。注意修改或增加配置代码后，需要重启web 服务器。重启后，访问原来HTTP的版本，看是否301跳转为HTTPS的版本。