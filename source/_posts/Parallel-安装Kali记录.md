---
title: Parallel 安装Kali记录
typora-root-url: ..
date: 2021-12-08 09:01:07
tags:
 - HTB
 - Mac
---

## 折腾原因

最近开始看HTB，发现很多都需要使用到kali里面的工具，于是在 安装 VMwareFusion 直接下载虚拟机镜像 和 使用 parallel 之间选择了通过 parallel安装(不想再装个VMwareFusion了😂)



### 前期准备

- kali iso镜像：https://www.kali.org/get-kali/

- parallel desktop



### 安装系统

选择 graph install

![image-20211208091120649](/assets/image-20211208091120649.png)

其他没啥好说的，类似安装linux系统的步骤。

### 安装 Parallels tools

点击右上角 安装 paralleltools 按钮，将会加载驱动盘 

![image-20211208094309859](/assets/image-20211208094309859.png)

由于权限问题，需将文件复制出来进行安装

```
#右键打开终端
mkdir /root/pt
cp -r /media/cdrom0 /root/pt
cd /root/pt
./install.sh
```

![image-20211208095355377](/assets/image-20211208095355377.png)

出现报错，然后开始解决

```
vim  /etc/apt/sources.list

deb http://mirrors.ustc.edu.cn/kali kali-rolling main non-free contrib
deb-src http://mirrors.ustc.edu.cn/kali/ kali-rolling main contrib non-free

apt-get update
apt-get install libelf-dev
apt-get install dkms
apt-get install printer-driver-postscript-hp  #这个好像没成功，也没管

```

开始解决 缺少 linux-headers 的问题

可以到  http://old.kali.org/kali/pool/main/l/linux/ 下载对应版本

### 开启ssh

```
vim /etc/ssh/sshd_config
```

![image-20211208102727047](/assets/image-20211208102727047.png)

保存退出，重启服务

```
service ssh restart 
ssh -antp
update-rc.do ssh enable   #开启开机自启
```

使用 ssh登陆后，上传刚刚下载的三个文件，依次安装

```
dpkg -i linux-kbuild-5.10_5.10.46-4kali1_amd64.deb     
dpkg -i linux-headers-5.10.0-kali9-common_5.10.46-4kali1_all.deb 
dpkg -i linux-headers-5.10.0-kali9-amd64_5.10.46-4kali1_amd64.deb
```

安装完成后，重新执行 ./install 等待congratulation 提示，再重启即可



## 参考连接

- https://www.cnblogs.com/artwalker/p/13235757.html
