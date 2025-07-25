---
title: logstatsh/wazuh采集日志
typora-root-url: ..
date: 2025-07-23 12:41:22
tags: [filebeat, wazuh, logstatsh, elk]
---

本文以 阿里云 https://www.alibabacloud.com/help/zh/oss/user-guide/logging oss-accesslog 为例，

记录两种方法解析该日志

```
192.168.0.1 - - [03/Jan/2021:14:59:49 +0800] "GET /example.jpg HTTP/1.0" 200 999131 127 "http://www.aliyun.com/product/oss" "curl/7.15.5" "examplebucket.oss-cn-hangzhou.aliyuncs.com" "5FF16B65F05BC932307A3C3C" "true" "16571836914537****" "GetObject" "examplebucket" "example.jpg" 999131 88 "-" 302 "16571836914537****" - "cdn" "standard" "-" "-" "LTAI****************"
```

# 1.Filebeat + logstatsh

使用 filebeat 采集，转发到 logstatsh 进行解析拆字段，以下是配置文件

## 1Filebeat:

```yaml
filebeat.inputs:
- type: log
  enabled: true
  paths: ["G:\\oss-logs2\\*.log"]
  fields_under_root: true
  fields:
    log_type: ossaccesslog

output.logstash:
  hosts: ["127.0.0.1:5044"]
```

## 2 Logstatsh:

```json
input {
  beats {
    port => 5044
  }
}

filter {
  # 如果你的日志是JSON格式，可以这样解析
  if [message] =~ /^{.*}$/ {
    json {
      source => "message"
      target => "json_content"
    }
  }

  # 对于普通文本日志，可以使用grok模式解析
  grok {
    match => { "message" => '%{IPORHOST:client_ip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:method} %{URIPATHPARAM:request} HTTP/%{NUMBER:http_version}" %{NUMBER:status_code} %{NUMBER:bytes_sent} %{NUMBER:response_time} "%{DATA:referrer}" "%{DATA:user_agent}" "%{DATA:host}" "%{DATA:request_id}" "%{DATA:cache_hit}" "%{DATA:ssl_protocol}" "%{DATA:operation}" "%{DATA:bucket}" "%{DATA:key}" %{NUMBER:object_size} %{NUMBER:server_time} "%{DATA:error_code}" %{NUMBER:request_length} "%{DATA:request_id_2}" %{DATA:signature} "%{DATA:storage_class}" "%{DATA:version_id}" "%{DATA:requester}"' }
  }
  #https://grokdebugger.com/
  # 日期处理
  date {
    match => ["timestamp", "dd/MMM/yyyy:HH:mm:ss Z"]
    locale => "en"
    target => "@timestamp"
    timezone => "Asia/Shanghai"
  }

  # 移除不需要的字段
  mutate {
    remove_field => ["beat", "input", "source", "offset", "prospector"]
  }
}


  # 可选：同时输出到控制台用于调试

output {
  elasticsearch {
    hosts => ["http://192.168.137.134:9200"]
    index => "ossaccesslogs-%{+YYYY.MM.dd}"
    template_name => "oss_access_logs_template"
    template_overwrite => true
  }
}
```

## 3 ES创建对应的index template:

```json
PUT _index_template/oss_access_logs_template
{
  "index_patterns": ["oss-access-logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 3,
      "number_of_replicas": 1,
      "index.lifecycle.name": "oss_logs_policy",
      "index.codec": "best_compression"
    },
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "client_ip": { "type": "ip" },
        "timestamp": { 
          "type": "date",
          "format": "strict_date_optional_time||epoch_millis"
        },
        "method": { "type": "keyword" },
        "request": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
        "http_version": { "type": "keyword" },
        "status_code": { "type": "integer" },
        "bytes_sent": { "type": "long" },
        "response_time": { "type": "long", "doc_values": true },
        "referrer": { "type": "keyword" },
        "user_agent": { 
          "type": "text",
          "fields": { "keyword": { "type": "keyword", "ignore_above": 1024 } }
        },
        "host": { "type": "keyword" },
        "request_id": { "type": "keyword" },
        "cache_hit": { "type": "boolean" },
        "ssl_protocol": { "type": "keyword" },
        "operation": { "type": "keyword" },
        "bucket": { "type": "keyword" },
        "key": { 
          "type": "text",
          "fields": { "path": { "type": "keyword" } }
        },
        "object_size": { "type": "long" },
        "server_time": { "type": "long" },
        "geoip": {
          "properties": {
            "country_name": { "type": "keyword" },
            "location": { "type": "geo_point" }
          }
        }
      }
    }
  }
}
```



先启动 logstatsh:

```
logstash -f G:\tools\logstash-7.17.13\config\my.conf
```

在启动 filebeat:

```
filebeat.exe -e
```



ES创建对应的Index patterns，可以在discover 中看到正确解析，并且使用该时间作为date排序

![image-20250723142732059](/assets/image-20250723142732059.png)



# 2.Wazuh

使用 wazuh agent 读取文件发送到wazuh-manager，使用wazuh来进行decoder和rule编写

## 1. 配置agent.conf of windows group

首先配置采集agent log， 需要文件具有可读权限

```xml
<agent_config>
	<localfile>
		<log_format>syslog</log_format>
		<location>C:\Users\admin\AppData\Local\Temp\test.log</location>
	</localfile>
</agent_config>
```



## 2. 编写对应的decoder

wazuh支持两种正则语法，OSRegex(更快但不支持回溯等操作) 和 PCRE2.

https://regex101.com/ 可在该网站调试 PCRE2 正则语法，bin/wazuh-regex 测试OSRegex语法

先使用wazuh-logtest 工具测试该日志，发现会当做 web-accesslog 进行decoder，并且自己在local_decoder.xml 里面编写的decoder无论是新增还是继承 web-accesslog 均无法执行。(所以最好还是syslog 日志好，带有program name 方便识别日志类型)

![image-20250725131751002](/assets/image-20250725131751002.png)

考虑原因，应该是 `0375-web-accesslog_decoders.xml` 执行优先级最高，匹配到日志前段符合就使用decoder 执行了。

因此在`/var/ossec/etc/decoders` 创建了文件 `0374-ali-oss-accesslog_decoders.xml`，这样优先级会比`0375-web-accesslog_decoders.xml` 更高

```xml
<decoder name="alicloud_oss_access_log">
    <type>web-log</type>
    <prematch type="pcre2">^(\S+) (\S+) (\S+) \[([^\]]+)\] "([A-Z]+) ([^ ]+) (HTTP\/[^"]+)" (\d+) (\d+) (\d+) "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" (\d+) (\d+) "([^"]*)" (\d+) "([^"]*)" (\S+) "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)"$</prematch>
    <regex type="pcre2">^(\S+) (\S+) (\S+) \[([^\]]+)\] "([A-Z]+) ([^ ]+) (HTTP\/[^"]+)" (\d+) (\d+) (\d+) "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" (\d+) (\d+) "([^"]*)" (\d+) "([^"]*)" (\S+) "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)"$</regex>
    <order>srcip, keepfield1, keepfield2, datetime, httpmethod, url, httpversion, status, SentBytes, RequestTime, Referer, UserAgent, HostName, RequestID, LoggingFlag, RequesterAliyunID, action, BucketName, ObjectName, ObjectSize, ServerCostTime, ErrorCode, RequestLength, user, DeltaDataSize, SyncRequest, StorageClass, TargetStorageClass, TransmissionAccelerationAccessPoint, AccessKeyID</order>
</decoder>

```

重启wazuh， 并更新文件内容。 这样获取到的日志就会被解析到各个字段上

![image-20250725120856439](/assets/image-20250725120856439.png)

尝试编写rule

```xml
<group name="aliosslog">
  <rule id="100400" level="6">
    <if_sid>31100</if_sid>
    <decoded_as>alicloud_oss_access_log</decoded_as>
    <field name="UserAgent">\.*curl\.*</field>
    <description>$(srcip) try to use curl request: $(UserAgent).</description>
  </rule>
</group>
```

在 wazuh-alerts 中可以查到触发告警

![image-20250725144618467](/assets/image-20250725144618467.png)



但是，会发现存在以下问题：

1. 除了wazuh的静态字段以外， 动态的字段都是 keywords类型，无法计算
2. 时间戳不对，使用的是wazuh存储日志的时间





## 3. 增加字段mapping并重建索引

可在ES中验证格式是否正确

```xml
GET _validate/query?format=yaml
{
  "query": {
    "range": {
      "timestamp": {
        "gte": "05/Jul/2025:14:00:00 +0800",
        "lte": "05/Jul/2025:15:00:00 +0800",
        "format": "dd/MMM/yyyy:HH:mm:ss Z"
      }
    }
  }
}
```

![image-20250725162232921](/assets/image-20250725162232921.png)

在wazuh 索引的templates中添加对应字段(如果没加对，日志进不去)



此处需要将数字设置为long， 才能存储比较大的数字。 后面在Index patterns中再设置成 bytes 即可

![image-20250725154551321](/assets/image-20250725154551321.png)

![image-20250725162940332](/assets/image-20250725162940332.png)

再重建索引，正常显示 datetime和sentbytes

![image-20250725163026877](/assets/image-20250725163026877.png)

