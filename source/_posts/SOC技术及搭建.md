---
title: SOC技术及搭建
typora-root-url: ..
date: 2022-04-24 09:06:29
tags:
 - ES
 - filebeat
 - JIRA
 - HIDS
 - NIDS
---



## 背景

使用到的组件：

kibana—security模块

zeek：开源流量检测

suricata：开源流量检测

wazuh：开源HIDS

packetbeat：终端网络抓包

openEDR：收集Windows network、process、file 信息

winlogbeat：收集Windows日志信息

filebeat：传输日志





## 架构图

![image-20220503105655223](/assets/image-20220503105655223.png)
