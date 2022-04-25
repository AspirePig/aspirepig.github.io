---
title: apache虚拟主机设置laravel目录到public下出现500
tags: []
id: '394'
categories:
  - - linux
date: 2018-03-16 10:02:02
---

在使用laravel（5.5）搭建网站的时候，使用lnmp的vhost add，直接定位到laravel/public目录。重启Apache服务后出现500 原因可能有以下几点

1.  storage;bootstrap/cache无权限
2.  虚拟主机配置中的**open\_basedir也被设置到了public目录下，导致php无法访问上层目录**
3.  没有配置转发规则