---
title: CTF平台搭建
typora-root-url: ..
date: 2022-11-27 13:52:03
tags: 
 - ctfd
 - docker
---



平台:ununtu 20.4

组件：

- docker docker-compose
- ctfd https://github.com/CTFd/CTFd
- ctf-whale https://github.com/glzjin/CTFd-Whale
- open vpn : kylemanna/openvpn



## docker 安装

略过，网上教程较多 将docker-compose 也顺便装上

```
docker swarm init
docker node update --label-add "name=linux-1" $(docker node ls -q)
```



## open vpn

参考 http://www.kyo86.com/2022/10/08/openvpn/

open vpn 通过 docker安装

```
#创建newwork，后面靶机也放在这个network中，用户连接ovpn后可直接访问靶机
docker network create --driver bridge --subnet 172.18.0.0/24 --gateway 172.18.0.1 ovpn_network

docker pull kylemanna/openvpn

OVPN_DATA="ovpn-data-example"

#初始化数据
docker volume create --name $OVPN_DATA
docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://[ipordomain]
docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
```

修改 server 配置文件

`/var/lib/docker/volumes/ovpn-data-example/_data/openvpn.conf`

```
server 192.168.255.0 255.255.255.0
verb 3
key /etc/openvpn/pki/private/[修改为自己的ip].key
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/[修改为自己的ip].crt
dh /etc/openvpn/pki/dh.pem
tls-auth /etc/openvpn/pki/ta.key
key-direction 0
keepalive 10 60
persist-key
persist-tun

proto tcp
# Rely on Docker to do port mapping, internally always 1194
port 443
dev tun0
status /tmp/openvpn-status.log

user nobody
group nogroup
comp-lzo

### Route Configurations Below
route 192.168.254.0 255.255.255.0

### Push Configurations Below
# push "block-outside-dns"
# push "dhcp-option DNS 8.8.8.8"
# push "dhcp-option DNS 8.8.4.4"
# push "comp-lzo no"
push "route 172.18.0.0 255.255.255.0"

```



`/var/lib/docker/volumes/ovpn-data-example/_data/ovpn_env.sh` 中的 declare -x OVPN_DISABLE_PUSH_BLOCK_DNS=0 改为 1

继续操作启动  ovpn

```

docker run --name=openvpn -v $OVPN_DATA:/etc/openvpn -d -p 443:443/tcp --cap-add=NET_ADMIN --net  ctfd_frp-containers kylemanna/openvpn

#创建用户 .ovpn
docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full asp nopass
docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient asp > asp.ovpn

#检查 asp.ovpn  确保 端口 协议 正确  443 tcp
#注释asp.ovpn 中的 redirect-gateway def1

```



## ctfd & ctf-whale 安装 

修改ctf-whale 代码，集成在 ctfd中

修改 docker-compose 和 Dockfile 

修改为 靶机以容器启动，返回容器IP到前端，不直接暴露到公网

用户使用openvpn连接后进行访问

ctfd 版本： 3.5.0

```
git clone https://github.com/AspirePig/ctfd_with_docker
cd ctfd_with_docker
```

编译启动

```
docker-compose build
docker-compose up -d 
```

不出意外可以访问 http://ip:8000 进行初始化配置

![image-20221127144518490](/assets/image-20221127144518490.png)

测试

![image-20221127215258486](/assets/image-20221127215258486.png)





## 制作靶机

```
#导出镜像
docker export -o  pwcupload test2
#导入镜像
docker import -c 'CMD ["bash","/run.sh"]' pwcupload pwcupload:latest
#启动容器
docker run --name test1  -d  --net mynet pwcupload:latest 

#可以在/run.sh 中 将环境变量中的flag 写入文件
```



