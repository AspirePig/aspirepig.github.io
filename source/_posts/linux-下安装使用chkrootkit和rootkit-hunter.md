---
title: Linux 下安装使用chkrootkit和rootkit hunter
tags: []
id: '574'
categories:
  - - linux
date: 2018-12-08 21:19:59
---

## chkrootkit安装及使用

```bash
1.从官网下载
http://www.chkrootkit.org/
2.解压压缩包文件
tar -zxvf chkrootkit.tar.gz 
3.编译
make sense 
4.运行
./chkrootkit 
```

* * *

## rootkit hunter安装使用

```bash
1.下载最新文件
https://sourceforge.net/projects/rkhunter/files/
2.解压压缩包文件
tar -zxvf rkhunter-1.4.6.tar.gz
3.安装
./installer.sh --install
4.运行
rkhunter --check --sk
rkhunter -c --sk --rwo
```