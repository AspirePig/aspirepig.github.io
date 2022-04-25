---
title: HackTheBox-Devzat
typora-root-url: ..
date: 2021-12-29 14:37:18
tags: HTB
---

## 简介

hostname：Devzat.htb

ip:10.10.11.118

Os:linux

```
echo "10.10.11.118 Devzat.htb" >> /etc/hosts
```

## 信息收集

### nmap

```
nmap -sS -A -sC -sV -p- --min-rate 500 10.10.11.118
```

```
PORT      STATE    SERVICE VERSION
22/tcp    open     ssh     (protocol 2.0)
|_ssh-hostkey: ERROR: Script execution failed (use -d to debug)
80/tcp    open     http    Apache httpd 2.4.41 ((Ubuntu))
|_http-methods: No Allow or Public header in OPTIONS response (status code 302)
|_http-title: Did not follow redirect to http://devzat.htb/
8000/tcp  open     ssh     (protocol 2.0)
|_ssh-hostkey: ERROR: Script execution failed (use -d to debug)
```



### gobuster

fuzz dir

```
gobuster dir -u http://Devzat.htb/ -t 80 -w directory-list-2.3-medium.txt -e 
```





## 立足点







## 提权

