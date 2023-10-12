---
title: SOC_ES7.17.13
typora-root-url: ..
date: 2023-10-11 19:35:28
tags: [elk, soc]
---



# 0x00 序言

搭建SOC完整架构尝试

架构图如下

![image-20231011175154949](/assets/image-20231011175154949.png)



# 0x01 环境准备

概述 整个文档可以查看wazuh all in one 安装文档

https://documentation.wazuh.com/current/deployment-options/elastic-stack/all-in-one-deployment/index.html

卸载文档：

https://documentation.wazuh.com/current/user-manual/uninstall/elastic-stack.html

```
VM1:Ubuntu 22.04.3 LTS
```



# 0x02 Ubuntu VM安装

此处不做过多详细介绍，网上教程很多

下载 ISO https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso.torrent

下载后在 VMware 中安装，配置如图

<img src="/assets/image-20231011164338357.png" alt="image-20231011164338357" style="zoom: 80%;" />



安装过程中，记得安装 openssh 服务，完成安装后，修改 Root 可SSH 登陆。

```bash
root@soc:~# cat /etc/ssh/sshd_config | grep -i root
PermitRootLogin yes


#修改时区
timedatectl set-timezone Asia/Shanghai
systemctl restart systemd-timesyncd

#清除所有防火墙规则
ufw disable
iptables -F
iptables -X
```

# 0x03 ES+Kibana 安装

经过查询官方文档 https://documentation.wazuh.com/current/integrations-guide/index.html 和https://documentation.wazuh.com/4.5/deployment-options/elastic-stack/index.html 得知， filebeat集成的方式仅支持 到Wazuh 4.5.3 and Elastic Stack 7.17.13

高于次版本需使用 Logstash 进行集成

因此，此处安装 ES Kibana 均为 7.17.13

### 1. ElasticSearch 安装

直接访问 https://www.elastic.co/guide/en/elasticsearch/reference/7.17/deb.html#deb-repo

根据文档执行下列命令

```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

sudo apt-get install apt-transport-https

echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

sudo apt-get update && sudo apt-get install elasticsearch=7.17.13
```

配置yml文件

```bash
vim /etc/elasticsearch/elasticsearch.yml


cluster.name: my-application
node.name: node-1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
cluster.initial_master_nodes: ["node-1"]

```

操作 elasticsearch

```bash
#设置开机自启
systemctl enable elasticsearch.service

#启动 es
systemctl start elasticsearch.service

#停止es
systemctl stop elasticsearch.service

#查看es状态
systemctl status elasticsearch.service
```

访问测试：

![image-20231011204105441](/assets/image-20231011204105441.png)



额外配置

```
vim /etc/security/limits.conf   # 在最后面追加下面内容

esuser hard nofile 65536
esuser soft nofile 65536

vim /etc/sysctl.conf    # 在最后面追加下面内容

vm.max_map_count=655360

sysctl -p
```





#### 2.Kibana安装

直接访问 https://www.elastic.co/guide/en/kibana/7.17/deb.html#deb-repo

根据文档执行下列命令**(安装ES的时候已经执行过，这无需执行这几行，直接执行最后一行安装即可)**

```bash
sudo apt-get update && sudo apt-get install kibana=7.17.13
```

配置yml文件

```bash
#cat /etc/kibana/kibana.yml

server.port: 5601
server.host: "0.0.0.0"
server.name: "kibana"
elasticsearch.hosts: ["http://localhost:9200"]
kibana.index: ".kibana"
kibana.defaultAppId: "home"

pid.file: /run/kibana/kibana.pid

logging:
  appenders:
    file:
      type: file
      fileName: /var/log/kibana/kibana.log
      layout:
        type: json
  root:
    appenders:
      - default
      - file

xpack.encryptedSavedObjects.encryptionKey: iGhu317CGomTQ3UH1nQwYF7yZ8asWPKHHYMwjBUJ
xpack.security.encryptionKey: iGhu317CGomTQ3UH1nQwYF7yZ8asWPKHHYMwjBUJ
xpack.reporting.encryptionKey: iGhu317CGomTQ3UH1nQwYF7yZ8asWPKHHYMwjBUJ

```

操作 elasticsearch

```bash
#设置开机自启
systemctl enable kibana.service

#启动 es
systemctl start kibana.service

#停止es
systemctl stop kibana.service

#查看es状态
systemctl status kibana.service
```

访问测试：

<img src="/assets/image-20231011204040638.png" alt="image-20231011204040638" style="zoom:80%;" />

至此，已经完成ES和Kibana的安装,我们的数据存储和浏览的核心组件。



后续将会讲解如何引入其他组件，如数据采集、数据处理、规则判断、告警生命周期。



# 0x04 wazuh-server安装

Wazuh 架构图：

本文主要使用 wazuh 做日志收集、规则判断

![image-20231011182108967](/assets/image-20231011182108967.png)



访问 https://documentation.wazuh.com/current/installation-guide/wazuh-server/step-by-step.html

根据文档执行安装命令如下：

```bash
apt-get install gnupg apt-transport-https

curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg


echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

apt-get update && apt-get -y install wazuh-manager=4.5.3

#打开archives.json
vim /var/ossec/etc/ossec.conf
<logall_json>yes</logall_json>


#设置开机自启动并启动wazuh manager
systemctl daemon-reload
systemctl enable wazuh-manager
systemctl start wazuh-manager

#查看wazuh 状态
systemctl status wazuh-manager
```

Wazuh 启动后，需要将Wazuh的日志，发送到ES，此处使用 FileBeat 进行转发

要确保Wazuh将警报记录到/var/ossec/logs/alers/alerts.json，请检查Wazuh服务器配置/var/ossec/etc/ossec.conf文件中的 jsonout_output 选项是否设置为yes。

#### FileBeat 安装与配置

```bash
apt-get -y install filebeat=7.17.13

#下载wazuh编辑好的filebeat yml文件
curl -so /etc/filebeat/filebeat.yml https://packages.wazuh.com/4.5/tpl/wazuh/filebeat/filebeat.yml

#编辑配置文件
vim /etc/filebeat/filebeat.yml

```

修改后文件内容如下

```
# Wazuh - Filebeat configuration file
output.elasticsearch:
  hosts: ["127.0.0.1:9200"]
  protocol: http
#  username: ${username}
#  password: ${password}
#  ssl.certificate_authorities:
#    - /etc/filebeat/certs/root-ca.pem
#  ssl.certificate: "/etc/filebeat/certs/filebeat.pem"
#  ssl.key: "/etc/filebeat/certs/filebeat-key.pem"
setup.template.json.enabled: true
setup.template.json.path: '/etc/filebeat/wazuh-template.json'
setup.template.json.name: 'wazuh'
setup.ilm.overwrite: true
setup.ilm.enabled: false

filebeat.modules:
  - module: wazuh
    alerts:
      enabled: true
    archives:
      enabled: true

logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
  permissions: 0644

logging.metrics.enabled: false

seccomp:
  default_action: allow
  syscalls:
  - action: allow
    names:
    - rseq

```



下载 wazuh alerts索引template

```bash
curl -so /etc/filebeat/wazuh-template.json https://raw.githubusercontent.com/wazuh/wazuh/4.5/extensions/elasticsearch/7.x/wazuh-template.json
chmod go+r /etc/filebeat/wazuh-template.json


#下载 wazuh module
curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.2.tar.gz | tar -xvz -C /usr/share/filebeat/module


#启动filebeat
systemctl daemon-reload
systemctl enable filebeat
systemctl start filebeat
```

查看Kibana，可以看到 alerts的日志了

![image-20231011205448375](/assets/image-20231011205448375.png)



# 0x05 Kibana-Wazuh-Plugin安装

访问 https://documentation.wazuh.com/4.5/deployment-options/elastic-stack/index.html#packages-list-elk 查找对应版本的离线安装包

```bash
cd /tmp
wget https://packages.wazuh.com/4.x/ui/kibana/wazuh_kibana-4.5.3_7.17.13-1.zip

cd /usr/share/kibana

sudo /usr/share/kibana/bin/kibana-plugin install file:///tmp/wazuh_kibana-4.5.3_7.17.13-1.zip

chown kibana:kibana -R /usr/share/kibana/

systemctl restart kibana

```

重启kibana后，可以查看到 wazuh 插件

<img src="/assets/image-20231011210732211.png" alt="image-20231011210732211" style="zoom:80%;" />



# 0x06 Wazuh-agent安装

测试在 Kali 安装 wazuh-agent

可参考文档 https://documentation.wazuh.com/current/installation-guide/wazuh-agent/index.html

```
curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.5.3-1_amd64.deb && sudo WAZUH_MANAGER='192.168.137.134' dpkg -i ./wazuh-agent.deb

sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

再次查看 kibana，可以看到 agent 已经上线

![image-20231011211432342](/assets/image-20231011211432342.png)





# 0x06 Wazuh-decoders&rules

语法文档：https://documentation.wazuh.com/current/user-manual/ruleset/ruleset-xml-syntax/index.html

#### 1.自定义decoder & rule

参考文档 https://documentation.wazuh.com/current/user-manual/ruleset/custom.html

> 自定义的rule id应当使用  100000 到120000 
>
> 示例日志

```
Dec 25 20:45:02 MyHost example[12345]: User 'admin' logged from '192.168.1.100'
```

在 `/var/ossec/etc/decoders/local_decoder.xml` 中插入如下新的 decoder

```
<group name="custom_rules_example,">
  <rule id="100010" level="0">
    <program_name>example</program_name>
    <description>User logged</description>
  </rule>
</group>
```

在 `/var/ossec/etc/decoders/local_decoder.xml` 中插入如下新的 rule

```
<group name="custom_rules_example,">
  <rule id="100010" level="0">
    <program_name>example</program_name>
    <description>User logged</description>
  </rule>
</group>
```

执行 `/var/ossec/bin/wazuh-logtest`

```
#输入
Dec 25 20:45:02 MyHost example[12345]: User 'admin' logged from '192.168.1.100'

**Phase 1: Completed pre-decoding.
        full event: 'Dec 25 20:45:02 MyHost example[12345]: User 'admin' logged from '192.168.1.100''
        timestamp: 'Dec 25 20:45:02'
        hostname: 'MyHost'
        program_name: 'example'

**Phase 2: Completed decoding.
        name: 'example'
        dstuser: 'admin'
        srcip: '192.168.1.100'

**Phase 3: Completed filtering (rules).
        id: '100010'
        level: '0'
        description: 'User logged'
        groups: '['custom_rules_example']'
        firedtimes: '1'
        mail: 'False'


#重启 wazuh agent ，使该decoder和rules 生效
systemctl restart wazuh-manager
```



#### 2.修改已有rule

修改时，建议将原有的规则直接拷贝出来到 自定义规则下`/var/ossec/etc/rules/` ，使用 `overwrite="yes"` tag将原因规则覆盖，防止升级导致规则丢失。

示例修改 ssh rule 5710：

1. 拷贝 `/var/ossec/ruleset/rules/0095-sshd_rules.xml` 中的 5710规则

   ```
   <group name="syslog,sshd,">
     ...
     <rule id="5710" level="5">
       <if_sid>5700</if_sid>
       <match>illegal user|invalid user</match>
       <description>sshd: Attempt to login using a non-existent user</description>
       <mitre>
         <id>T1110</id>
       </mitre>
       <group>invalid_login,authentication_failed,pci_dss_10.2.4,pci_dss_10.2.5,pci_dss_10.6.1,gpg13_7.1,gdpr_IV_35.7.d,gdpr_IV_32.2,hipaa_164.312.b,nist_800_53_AU.14,nist_800_53_AC.7,nist_800_53_AU.6,tsc_CC6.1,tsc_CC6.8,tsc_CC7.2,tsc_CC7.3,</group>
     </rule>
     ...
   </group>
   ```

2. 粘贴到自定义规则文件中 `/var/ossec/etc/rules/local_rules.xml` ,并设置 `overwrite="yes"`

```
<group name="syslog,sshd,">
  <rule id="5710" level="10" overwrite="yes">
    <if_sid>5700</if_sid>
    <match>illegal user|invalid user</match>
    <description>sshd: Attempt to login using a non-existent user</description>
    <mitre>
      <id>T1110</id>
    </mitre>
    <group>invalid_login,authentication_failed,pci_dss_10.2.4,pci_dss_10.2.5,pci_dss_10.6.1,gpg13_7.1,gdpr_IV_35.7.d,gdpr_IV_32.2,hipaa_164.312.b,nist_800_53_AU.14,nist_800_53_AC.7,nist_800_53_AU.6,tsc_CC6.1,tsc_CC6.8,tsc_CC7.2,tsc_CC7.3,</group>
  </rule>
</group>
```

3. 重启wazuh `systemctl restart wazuh-manager`

#### 3.修改已有decoder

覆盖 decoder 需要整个文件进行覆盖，并修改 loading list

例如想要 修改 `0310-ssh_decoders.xml` ， 步骤如下

1.  `cp /var/ossec/ruleset/decoders/0310-ssh_decoders.xml /var/ossec/etc/decoders` 

2. 编辑 `/var/ossec/etc/ossec.conf`，设置  `<decoder_exclude>` 如下

   ```
   <ruleset>
     <!-- Default ruleset -->
     <decoder_dir>ruleset/decoders</decoder_dir>
     <rule_dir>ruleset/rules</rule_dir>
     <rule_exclude>0215-policy_rules.xml</rule_exclude>
     <list>etc/lists/audit-keys</list>
   
     <!-- User-defined ruleset -->
     <decoder_dir>etc/decoders</decoder_dir>
     <rule_dir>etc/rules</rule_dir>
     <decoder_exclude>ruleset/decoders/0310-ssh_decoders.xml</decoder_exclude>
   </ruleset>
   ```

3. 编辑 `/var/ossec/etc/decoders/0310-ssh_decoders.xml`
4. 重启wazuh server `systemctl restart wazuh-manager`

测试 

![image-20231012110801694](/assets/image-20231012110801694.png)



# 0x07 Wazuh-日志采集



#### 1. Agent上报



#### 2.Syslog上报



#### 3. Windows事件日志



#### 4.Docker日志



# 0x07 Wazuh



# 0x08 Jira安装

此处暂时省略，使用 JIRA cloud 在线环境



#### 1.创建JRIA项目

JIRA 大致步骤：

1. 创建项目
2. 创建字段及字段方案
3. 创建工作流工作流方案
4. 创建屏幕及屏幕方案
5. 人员、权限
6. API服务

浅浅配置一下，大概如图。

![image-20231012123334491](/assets/image-20231012123334491.png)



需求：

> 我们需要自动将 wazuh alerts中rule.level > = 10 的 日志创建为一张ticket

方案有几种：

1. 使用脚本调用ES API查询数据，再请求 JIRA API 创建Ticket
2. 使用 kibana 自带 security/watcher 功能创建rule，并配置webhook、JRIA action，创建ticket
3. 使用 Elastalert，并调用脚本请求JIRA api创建ticket

需要使用到两个东西，一个是调用JIRA API，创建ticket ，参考文档

https://developer.atlassian.com/cloud/jira/platform/rest/v2/intro/#authentication

快速上手：参考 https://juejin.cn/post/7023617578324983839

另一个是使用脚本查询Elasticsearch，参考文档



#### 2.使用jIRA创建一个 Token

![image-20231012124606703](/assets/image-20231012124606703.png)



构造认证头

```bash
echo -n user@example.com:api_token_string | base64
```



构造 查询 请求测试

```bash
curl --location --request GET 'https://aspirepigsoc.atlassian.net/rest/api/2/search?jql=project%20%3D%20SOC' \
--header 'Authorization: Basic YXNwaXJlcGlxxxxx' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
```

测试能否正常调用API接口创建Ticket

```
curl --location --request POST 'https://aspirepigsoc.atlassian.net/rest/api/2/issue' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic YXNwaXJlcxxxx' \
--data-raw '{
  "fields": {
    "issuetype": {
      "id": "10010"
    },
    "project": {
      "id": "10001"
    },
    "summary": "test alert001",
    "description": "Description - Hevo is a No Code Data Pipeline"
  }
}'
```



![image-20231012133348832](/assets/image-20231012133348832.png)



#### 3.elastalert2安装与配置

查看文档进行安装：https://elastalert2.readthedocs.io/en/latest/running_elastalert.html#as-a-docker-container

由于需要使用 Python 3.11 ，此处使用 docker 安装方法.配置如下

创建目录: `/opt/elastalert/`

elastalert.yaml：

```
rules_folder: /opt/elastalert/rules

run_every:
  seconds: 30

buffer_time:
  minutes: 15

es_host: 192.168.137.134
es_port: 9200

writeback_index: elastalert_status

alert_time_limit:
  days: 2
```

soc.yaml

```
name: "soc"
type: "any"
index: "wazuh-alerts-4.x*"
is_enabled: true
realert:
  minutes: 0
buffer_time:
  minutes: 120
filter:
- range:
    rule.level:
      from: 9
      to: 15

include: ["rule.description", "full_log"]


alert:
  - command
  - debug
command: ["python3","/opt/elastalert/rules/test.py","{rule[description]}", "{full_log}"]
```

test.py

```
import sys
import requests
import json

url = "https://aspirepigsoc.atlassian.net/rest/api/2/issue"

payload = json.dumps({
  "fields": {
    "issuetype": {
      "id": "10010"
    },
    "project": {
      "id": "10001"
    },
    "summary": sys.argv[1],
    "description": sys.argv[2]
  }
})
headers = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
  'Authorization': 'Basic YXNwaXJlcGlnQGxxxx'
}

response = requests.request("POST", url, headers=headers, data=payload)

print(response.text)
```

创建完成后，启动容器

```yaml
#启动
docker run -d --name elastalert --restart=always \
-v $(pwd)/elastalert.yaml:/opt/elastalert/config.yaml \
-v $(pwd)/rules:/opt/elastalert/rules \
jertel/elastalert2 --verbose


docker logs -f elastalert
```

触发指定level的日志，查看是否正常创建 Ticket

![image-20231012172806105](/assets/image-20231012172806105.png)



到目前，已经可以自动化创建 Ticket 了，如果需要补充更多字段，就得需要更多时间去完成日志源，做wazuh 的decoder、ruleset， 做JIRA的页面显示自动化、字段、页面配置、做Elastalert的配置字段优化等等
