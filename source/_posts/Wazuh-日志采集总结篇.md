---
title: Wazuh 日志采集 总结篇
typora-root-url: ..
date: 2025-07-26 09:21:28
tags: [wazuh, elk]
---

## 1.概览

首先放一张 wazuh的架构

![image-20250726201256415](/assets/image-20250726201256415.png)

目前看到的wazuh日志采集方式如下，后文将对每一种方式做一个大概讲解及测试

| **收集方式**                 | **配置示例**                                                 | **适用场景**                        | **支持格式**                  | **备注**                                                     |
| :--------------------------- | :----------------------------------------------------------- | :---------------------------------- | :---------------------------- | :----------------------------------------------------------- |
| **本地日志文件监控**         | `<localfile><location>/var/log/example.log</location><log_format>syslog</log_format></localfile>` | Linux/Windows 日志文件              | `syslog`、`json`、`plaintext` | 支持通配符（`*.log`）和动态文件名（`log-%Y-%m-%d.log`）      |
| **Windows事件日志**          | `<localfile><location>Security</location><log_format>eventlog</log_format></localfile>` | Windows 安全日志、应用日志          | `eventlog`（传统日志）        | 适用于监控登录、权限变更等安全事件                           |
| **Windows事件通道**          | `<localfile><location>Microsoft-Windows-PowerShell/Operational</location><log_format>eventchannel</log_format></localfile>` | Windows 系统/应用事件通道           | `eventchannel`                | 适用于监控 PowerShell、打印服务等高级日志                    |
| **远程Syslog接收**           | `<remote><connection>syslog</connection><allowed-ips>192.168.1.0/24</allowed-ips></remote>` | 防火墙、路由器、交换机等网络设备    | `syslog`（UDP/TCP）           | 需配置防火墙允许514/1514端口                                 |
| **JSON日志解析**             | `<localfile><log_format>json</log_format><location>/var/log/app.json</location></localfile>` | 现代应用（如Docker、K8s、Suricata） | `json`                        | 支持嵌套字段，自动提取关键字段                               |
| **命令输出收集**             | `<localfile><log_format>full_command</log_format><command>df -h</command><frequency>300</frequency></localfile>` | 系统状态监控（磁盘、进程、网络）    | 命令行输出                    | 可定时执行（`frequency` 单位为秒）                           |
| **REST API 提交**(4.6及以上) | `POST /events HTTP/1.1`（发送至 `http://wazuh-server:55000/events`） | 自定义脚本、云服务日志              | `json`                        | 需认证（API密钥或JWT）该功能4.6及以上采用，本文使用 4.5 暂不支持 |
| **Unix Socket 注入**         | `echo '{"log":"test"}' > /var/ossec/queue/sockets/queue`     | 高性能本地日志注入                  | `json`/`plaintext`            | 需确保Wazuh有socket写入权限                                  |




## 2.本地日志

### 2.1本地日志文件

本部分内容可以参考[1. 配置agent.conf of windows group](https://blog.161695.xyz/2025/07/23/logstatsh-shi-yong-grok-cai-ji-ri-zhi/#toc-heading-6)， 收集本地的日志文件。



### 2.2本地事件日志

本部分内容可以参考[使用 Wazuh 直接监控进程创建（无需 Sysmon）](https://blog.161695.xyz/2023/10/11/soc-es7/?a=1#toc-heading-18)

![image-20250726095138220](/assets/image-20250726095138220.png)

### 2.3 window事件通道

本部分内容可以参考 [2.使用Sysmon+ Wazuh 监控进程/网络创建](https://blog.161695.xyz/2023/10/11/soc-es7/?a=1#toc-heading-19)

![image-20250726095203907](/assets/image-20250726095203907.png)



## 3.远程Syslog接收

适用于 防火墙、路由器、交换机等网络设备，可以配置 syslog 转发。**但还是建议将syslog 日志转发到可以安装 wazuh agent的服务器，存储为文件，再由agent采集syslog日志，这样方便日志定位及存储。 日志格式也会更加完整，并且可以添加labels 标签**（参考[转发系统日志事件 - 您的环境 ·Wazuh 文档](https://documentation.wazuh.com/4.5/cloud-service/your-environment/send-syslog-data.html)）

3.1开启端口监听

在 Wazuh manager配置，监听 TCP 端口 514 上的 syslog 消息

`<ossec_config> /var/ossec/etc/ossec.conf`

```xml
<remote>
  <connection>syslog</connection>
  <port>514</port>
  <protocol>tcp</protocol>
  <allowed-ips>192.168.137.15/24</allowed-ips>
  <local_ip>192.168.137.134</local_ip>
</remote>
```

收到日志，后续可以根据program name 编写decoder 和rule

![image-20250726110813887](/assets/image-20250726110813887.png)



示例2，雷池 WAF 配置 syslog 日志转发， 解析生成告警(没有授权，发现配置无法保存，无法进行后续测试。。)

![image-20250726131754202](/assets/image-20250726131754202.png)

示例3，Jumpserver syslog日志转发

config.txt

```
SYSLOG_ENABLE=True
SYSLOG_ADDR=192.168.137.134:514
```

日志样例：

```
jumpserver: login_log - {"backend": "Password", "backend_display": "密码", "city": "局域网", "datetime": "2025/07/26 22:53:12 +0800", "id": "8b74dac9-05f3-469a-9238-e1551fd8e422", "ip": "192.168.137.1", "mfa": {"label": "禁用", "value": 0}, "reason": "", "reason_display": "", "status": {"label": "成功", "value": true}, "type": {"label": "Web", "value": "W"}, "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36", "username": "Administrator(admin)"}
```



wazuh 监听udp 514 , 因为 jumpsserver用的是udp端口

```xml
  <remote>
    <connection>syslog</connection>
    <port>514</port>
    <protocol>udp</protocol>
    <allowed-ips>192.168.137.15/24</allowed-ips>
    <local_ip>192.168.137.134</local_ip>
  </remote>
```

![image-20250726225605328](/assets/image-20250726225605328.png)



继续日志解析：

```xml
<decoder name="jumpserver">
    <prematch type="pcre2">^jumpserver</prematch>
</decoder>


<decoder name="jumpserver_decoder">
  <parent>jumpserver</parent>
  <prematch type="pcre2">\S+ - </prematch>
  <plugin_decoder offset="after_prematch">JSON_Decoder</plugin_decoder>
</decoder>


<decoder name="jumpserver_decoder">
  <parent>jumpserver</parent>
  <regex type="pcre2">^jumpserver: (\S+) - </regex>
  <order>logtype</order>
</decoder>
```

![image-20250727134749853](/assets/image-20250727134749853.png)



发现 archive.json 已经正确解析日志了，但是ES中无法查询到数据，推测是JSON自动分配字段的时候和Index的mapping有冲突，无法写入数据

查询日志，发现是 
```
"failed to parse date field [2025/07/27 13:29:31 +0800] with format [dd/MMM/yyyy:HH:mm:ss Z]
failed to parse field [data.action] of type [keyword] in document with id 'Q0JoSpgBnF7oeTEmyjCL'.
```

这样改会有很多问题，还是建议使用脚本对数据再套一层， 存入本地文件再重新读取。



## 4.JSON日志解析

此处更多讲解 JSON 日志解析，偏向日志的内容。而不是采集方式，因为可以通过各种方式收集 JSON日志，如本地文件、API接口获取、syslog 转发 带有JSON的日志 等等

还是以雷池告警为例，调用API，可以获取JSON格式的 alert

```python
import requests

url = "https://192.168.137.138:9443/api/open/records"

payload = {}
headers = {
  'X-SLCE-API-TOKEN': 'PqlDSVFG7BZFnC2O6ezrYeajGFlbb1ad',
  'accept': 'application/json'
}

response = requests.request("GET", url, headers=headers, data=payload， verify=False)

print(response.text)

```

### 4.1 REST API提交 

该功能 4.6及以上才有 {protocol}://{host}:{port}/events， 本文使用4.5不支持该方式，不在本文讨论，如需了解可查看该文档

https://documentation.wazuh.com/4.6/user-manual/api/reference.html#tag/Events



### 4.2 Unix Socket 注入

根据文档 [标准OSSEC报文格式 - 开发 ·Wazuh 文档](https://documentation.wazuh.com/4.5/development/message-format.html)，需要构造相应的数据格式，连接unix socket ，将数据发送进去。

```
<Queue>:<Location>:<Message>

1:/var/log/syslog:Nov  9 16:06:26 localhost salute: Hello world.
```

其中 Queue 解释 (一般都用1或2)

- Queue

  1-byte event type. It defines the decoding mode for *Analysis daemon*.The most common queue types are:

  **1** Local file log, including Syslog messages, Windows event logs, outputs from commands, OpenSCAP results and custom logs.

  **2** Remote Syslog messages, received by the Syslog server at *Remote daemon*.

  **4** Secure messages. They are events from *Remote daemon* to *Analysis daemon*, that contain a standard OSSEC message plus the source agent ID.

  **8** Syscheck event. *Analysis daemon* parses it using the Syscheck decoder.

  **9** Rootcheck event. *Analysis daemon* parses it using the Rootcheck decoder.

使用python3 测试写入

```
import socket
from socket import AF_UNIX, SOCK_DGRAM

SOCKET_ADDR = '/var/ossec/queue/sockets/queue'
sock = socket.socket(AF_UNIX, SOCK_DGRAM)
sock.connect(SOCKET_ADDR)

event_string = '1:k8s:test'
sock.send(event_string.encode())
sock.close()
```

或 socat

```
echo '1:k8s:test' | sudo -u wazuh socat - UNIX-SENDTO:/var/ossec/queue/sockets/queue
```

或nc

```
echo '1:k8s:test' | sudo -u wazuh nc -uU /var/ossec/queue/sockets/queue
```

成功在wazuh读取到

![image-20250726160520564](/assets/image-20250726160520564.png)

接下来需要使用API请求雷池接口获取告警数据，再构造成wazuh unix socket 接口格式，传递给wazuh

```python
import requests
import socket
import json
from socket import AF_UNIX, SOCK_DGRAM


def fetch_logs():
  url = "https://192.168.137.138:9443/api/open/records"
  headers = {
    'X-SLCE-API-TOKEN': 'PqlDSVFG7BZFnC2O6ezrYeajGFlbb1ad',
    'accept': 'application/json'
  }
  response = requests.get(url, headers=headers, verify=False)
  if response.status_code == 200:
    return response.json().get('data', {}).get('data', [])
  else:
    print(f"Error fetching logs: {response.status_code}")
    return []


def send_to_wazuh(logs):
  SOCKET_ADDR = '/var/ossec/queue/sockets/queue'

  try:
    sock = socket.socket(AF_UNIX, SOCK_DGRAM)
    sock.connect(SOCKET_ADDR)

    for log in logs:
      # 构造Wazuh要求的格式：1:leichiwaf:json数据
      wazuh_format = f"1:leichiwaf:{json.dumps(log)}"
      sock.send(wazuh_format.encode())
      print(f"Sent: {wazuh_format[:100]}...")  # 打印前100字符避免过长

  except Exception as e:
    print(f"Error sending to Wazuh: {str(e)}")
  finally:
    sock.close()


if __name__ == "__main__":
  # 1. 获取日志
  logs = fetch_logs()

  if logs:
    print(f"Fetched {len(logs)} logs")
    # 2. 发送到Wazuh
    send_to_wazuh(logs)
  else:
    print("No logs fetched")
```

成功将日志写入，并且自动按照json格式拆分了字段。

![image-20250726161735687](/assets/image-20250726161735687.png)



编辑自定义decoder 

```xml
<decoder name="leichiwaf">
  <parent>json</parent>
  <prematch>^{\s*"site_uuid"</prematch>
  <use_own_name>true</use_own_name>
  <plugin_decoder>JSON_Decoder</plugin_decoder>
</decoder>
```

编写自定义rule

```xml
<group name="leichiwaflog">
  <rule id="100500" level="12">
    <decoded_as>leichiwaf</decoded_as>
    <description>$(host) is suffer the attack from $(src_ip).</description>
  </rule>
</group>
```

重新执行python脚本，可以看到decoder和rule正常执行

![image-20250726174829476](/assets/image-20250726174829476.png)

不过JSON日志进来后存在字段无法修改的问题，可以有以下两种方法:

1. python脚本获取到告警先给json日志套壳，防止字段冲突
2. 不使用 wazuh的 JSON_Decoder , 使用 正则进行匹配并设置字段名称



## 5.命令输出收集

- `full_command`将已执行命令的输出读取为单行条目。
- `command`将已执行命令的输出读取为多行条目。

如果要使用远程配置的方式执行命令，需要修改agent的以下文件

```
local_internal_options.conf
```

> - For the Command module:
>
>   > ```
>   > wazuh_command.remote_commands=1
>   > ```
>
> - For the Logcollector module:
>
>   > ```
>   > logcollector.remote_commands=1
>   > ```

配置agent.conf文件

```xml
  <localfile>
    <log_format>full_command</log_format>
    <command>tasklist</command>
    <frequency>120</frequency>
  </localfile>
  
  <localfile>
    <log_format>command</log_format>
    <command>tasklist</command>
    <frequency>150</frequency>
  </localfile>
```

![image-20250726195641015](/assets/image-20250726195641015.png)





## 6.总结

各种接收日志的方式，目前来看直接给wazuh syslog 或者 socket吐数据并不是最好的办法。 因为wazuh的decoder 并不是十分的灵活。 并且可能存在各种各样的解析问题。

如果需要直接使用 syslog/socket的，建议还是前面套一个logstatsh或者先使用脚本对数据重新构造，这样规避 Index mapping问题和 降低decoder 编写复杂度。



注：

父decoder 并不会将提取的字段继承给 子 decoder，因此需要编写多次子decoder ，以此对字段进行解析

```xml
<decoder name="testabc">
  <prematch>^Some_Static_Pattern</prematch>
</decoder>

<decoder name="testabc-fields">
  <parent>testabc</parent>
  <regex>field1=(\S+) field2=(\S+)</regex>
  <order>field_one, field_two</order>
</decoder>
<decoder name="testabc-fields">
  <parent>testabc</parent>
  <regex>additional_field=(\S+)</regex>
  <order>field3</order>
</decoder>
```

![image-20250727143657502](/assets/image-20250727143657502.png)
