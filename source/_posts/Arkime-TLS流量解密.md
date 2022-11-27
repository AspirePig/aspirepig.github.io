---
title: Arkime+TLS流量解密
typora-root-url: ..
date: 2022-08-01 15:05:31
tags: Arkime
---



## 

下载 PolarProxy







## 修改 Arkime 配置

编辑/opt/arkime/etc/config.ini，添加"pcapReadMethod = pcap-over-ip-server"，将Arkime配置为监听PCAP连接。

启动 arkime

```
sudo systemctl start arkimecapture.service
```

查看是否监听

```
ss -antp | grep 57012
```



## 安装 PolarProxy

 https://www.netresec.com/?page=PolarProxy

创建用户

```
sudo adduser --system --shell bin/bash proxyuser
sudo mkdir /var/log/PolarProxy
sudo chown proxyuser:root /var/log/PolarProxy/
sudo chmod 0775 /var/log/PolarProxy/
sudo su - proxyuser
mkdir ~/PolarProxy
cd ~/PolarProxy/
curl https://www.netresec.com/?download=PolarProxy | tar -xzf -
exit
```

复制配置文件

```
sudo cp /home/proxyuser/PolarProxy/PolarProxy.service /etc/systemd/system/PolarProxy.service
```

修改配置文件

修改/etc/systemd/system/PolarProxy.service，在ExecStart命令的末尾添加"--pcapoveripconnect 127.0.0.1:57012" 并修改监听端口及转发端口，实现 80 443 代理：

```
ExecStart=/home/proxyuser/PolarProxy/PolarProxy -v -p 443,443 -p 80,80 -x /var/log/PolarProxy/polarproxy.cer -f /var/log/PolarProxy/proxyflows.log -o /var/log/PolarProxy/ --certhttp 10080 --socks 1080 --httpconnect 8080 --pcapoveripconnect 127.0.0.1:57012 --allownontls
```

启动服务

```
sudo systemctl enable PolarProxy.service
sudo systemctl start PolarProxy.service
```



使用curl测试

```
curl --resolve www.baidu.com:443:192.168.65.129 https://www.baidu.com/ --header "Host: www.baidu.com"
```

![image-20220801162119337](/assets/image-20220801162119337.png)

在arkime中可以看见数据包明文即成功。



## 信任证书

centos 7 参考如下：

```
cp /var/log/PolarProxy/polarproxy.cer /etc/pki/ca-trust/source/anchors
ln -s /etc/pki/ca-trust/source/anchors/polarproxy.cer /etc/ssl/certs/polarproxy.cer
update-ca-trust
```

win10 参考如下：

https://mos86.com/40020.html、



## 遗留问题

但是当前遇到的问题是需要让设备访问的所有域名走代理，当前只能代理 443 80

第一个问题：安装 内部dns服务器，将所有域名解析到该代理

```
address=/#/192.168.65.129
```

![image-20220801171923612](/assets/image-20220801171923612.png)





HTTP代理有两种方式：

一种是充当中间人

另一个总是建立隧道，之后只做转发，加密的https流量仍然是加密的
