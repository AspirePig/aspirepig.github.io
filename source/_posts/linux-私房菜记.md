---
title: 读linux 私房菜记（1）
tags:
  - bash
  - linux
  - misc
id: '205'
categories:
  - - linux
  - - misc
date: 2017-02-13 13:19:37
---

第四章：初识Linux

1.  几个重要的热键 Tab：命名补全与文件（夹）名补全 Ctrl-c：停止 Ctrl-d：相当于exit，停止输入 shift-\[page up/down\]：前后翻页
2.  man page与info page
3.  简单的文本编辑器nano
4.  正确关机的方法sync-shutdown/poweroff/reboot/halt

第五章：文件权限与目录配置

1.  拥有者  群组  其他人  root 的概念 用户的身份与群组记录文件/etc/passwd   密码则是在/etc/shadow
2.  文件权限的概念
    
    drwxr-xr-x    5            flypig staff 170          2 10 23:01 Public
    
    【权限】      连接 数   拥有者     群组   文件容量     修改日期    文档名 d                 rwx r-x r-x 文档类型    拥有者权限      拥有者所在组权限      其他人权限 正规文件：- 目录：d 连接档：l 区块设备档：b 字符设备文件：c 资料接口文件：s 数据输送文件：p
3.  chgrp:改变所属群组 chown:改变所有者 chmod:改变文件权限，SUID,SGID,SBIT等等

第六章：文件内容的查阅

1.  cat - tac   nl   more - less   head - tail   od（查阅非纯文本文档）
2.  touch 修改文件时间或建立新文件
3.  umask预设权限
4.  文件隐藏属性以及特殊权限SUID,SGID,SBIT
5.  file命令观察文件的类型
6.  脚本文件名搜索：which command 搜索文件：whereis   【-bsmu】文件名
7.  挂载mount   unmount  开机自动挂载/etc/fstab

第八章：打包备份

1.  打包：tar -zcv -f filename.tar.gz 要被压缩的文件或文件夹 查询：tar -ztv -f filename.tar.gz 解压：tar -zxv -f filename.tar.gz  -C 预解压的目录
2.  Vim 一般指令模式常用命令 Ctrl + f = Page Down      Ctrl + b = Page Up （数字0）= Home 移动到行首   $ = End 移动到行尾 G 移动到文件最后一行     gg=1G移动到文件第一行 /word 光标向下搜索word这个词       ?word 光标向上搜索word这个词 :n1,n2s/word1/word2/g      行n1到行n2之间使用word2替代word1    g后面加c需确认 x = del 删除后面一个字符     X向前删除一个字符 dd删除一整列    ndd删除连续n行    yy复制光标所在行    nyy复制光标向下n行 p 光标下粘贴     P光标上粘贴    u撤销上一个动作      Ctrl+r=.（小数点） 重做上一个动作
3.  vim额外功能 v字符选择    V行选择     Ctrl+v  区块选择（可选长方形） :sp  窗口拆分 ~/.vimrc或者~/.viminfo vim的环境设定

认识与学习bash

1.  命令别名 alias  ll='ls -al'           取消  unalias   ll   若设定永久生效改~/.bashrc  或者.bash\_profile
2.  history -c 清楚当前shell中所有历史命令
3.  bash 进站欢迎信息  /etc/issue   /etc/motd(所有用户登入会显示)
4.  通配符遇特殊符号   \*匹配无穷多个任意字符   ?有且仅有一个   \[abcd\] 其中一个  \[^abc\]反向选择 \[ 0-9\] 顺序编码内的文字
5.  数据流重导向   $?    &&      
6.  管线命令： 截取：cut   grep   排序：sort   wc   uniq   双向重导向：tee 字符转换： tr  col    join   paste   expand 分区命令 ：split   参数代换：xargs     stdin和stdout可以使用  -   替代