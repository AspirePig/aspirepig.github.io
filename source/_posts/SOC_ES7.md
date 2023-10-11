---
title: SOC_ES7.17.13
typora-root-url: ..
date: 2023-10-11 16:35:28
tags: [elk, soc]
---



# 0x00 序言

搭建SOC完整架构尝试

架构图如下

![image-20231011175154949](/assets/image-20231011175154949.png)



# 0x01 环境准备

概述

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

apt-get update && apt-get -y install wazuh-manager=4.5

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
      enabled: false

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

```
curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.5.3-1_amd64.deb && sudo WAZUH_MANAGER='192.168.137.134' dpkg -i ./wazuh-agent.deb

sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

再次查看 kibana，可以看到 agent 已经上线

![image-20231011211432342](/assets/image-20231011211432342.png)





# 0x06 Wazuh-decoder



#### 1. Agent上报



#### 2.Syslog上报



#### 3. Windows事件日志



#### 4.Docker日志



# 0x07 Wazuh-rule



# 0x08 Jira安装

