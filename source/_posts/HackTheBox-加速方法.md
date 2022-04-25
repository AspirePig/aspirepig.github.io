---
title: HackTheBox 加速方法
typora-root-url: ..
date: 2021-12-07 16:42:46
tags:
 - HTB
 - linux
---



免费HTB，用自己的电脑通过OpenVPN总是连不上。于是计划通过 US的VPS进行中转

连通后访问流量路径：本地Mac 通过 L2TP/Ipsec 到达 vps，vps通过openvpn连接 HTB网络

虽然延迟仍然比较高 200-300ms，但是胜在稳定，以下记录搭建方式



## 安装openvpn client

vps为Ubuntu系统，安装通过 apt命令进行，非常快捷简单

```bash
sudo apt-get install openvpn
```

将从HTB 下载下来的openvpn 配置文件上传到vps，新开一个screen，连接到 HTB网络

```bash
screen -S openvpn
openvpn openvpn.ovpn
```

完成后，新开一个vps shell，测试能否正常访问 HTB 节点



## 安装L2TP/IPsec

开启 ipsec 支持

```
sudo modprobe af_key
```

通过docker 快速搭建 L2TP/IPsec,此处使用了项目https://github.com/hwdsl2/docker-ipsec-vpn-server

```bash
docker run \
    --name ipsec-vpn-server \
    --restart=always \
    -v ikev2-vpn-data:/etc/ipsec.d \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -d --privileged \
    hwdsl2/ipsec-vpn-server
```

执行完成后，通过会随机生成用户密码，通过docker日志进行查看

```bash
docker logs ipsec-vpn-server
```



## mac 配置 L2TP

在网络面板中新增一个 L2TP的链接，输入上面的通过日志查看的账号密码及预共享密钥即可，点击链接进行测试

![image-20211207165446054](/assets/image-20211207165446054.png)



## 添加路由

最后一步，需要手动添加路由，让HTB网络地址的流量默认通过L2TP 虚拟网卡进行转发

```bash
sudo -S route add -net 10.10.0.0/16 192.168.42.1
```



最后尽情测试吧
