---
title: 读linux 私房菜记（2）
tags:
  - bash
  - linux
  - misc
id: '208'
categories:
  - - linux
  - - misc
date: 2017-02-16 13:19:38
---

基础正规表示法：

1.  ^word    意义:待搜寻的字符串(word)在行首
2.  word$    意义:待搜寻的字符串(word)在行尾
3.     .   代表『一定有一个任意字符』的字符
4.     \\    跳脱字符，将特殊符号的特殊意义去除
5.  \* 重复零个到无穷多个的前一个 RE 字符
6.  \[list\] 字符集合的 RE 字符，里面列出想要撷取的字符
7.  \[n1-n2\]   字符集合的 RE 字符，里面列出想要撷取的字符范围
8.  \[^list\]   字符集合的 RE 字符，里面列出不要的字符串或范围
9.  \\{n,m\\}   意义:连续 n 到 m 个的『前一个 RE 字符』 意义:若为 \\{n\\} 则是连续 n 个的前一个 RE 字符 意义:若是 \\{n,\\} 则是连续 n 个以上的前一个 RE 字符
10.  sed 工具   sed \[-nefr\] \[动作\]

延伸正规表示法：

1.  重复『一个或一个以上』的前一个 RE 字符
2.  ? 『零个或一个』的前一个 RE 字符
3.  用或( or )的方式找出数个字符串
4.  ()找出『群组』字符串
5.  ()+ 多个重复群组的判别
6.  工具  print  awk    pr

Shell Script 的学习

1.  source 执行与 sh 执行的差异：前者当前bash执行   后者fork出一个新的子程序后执行
2.  test 指令  以及\[  \]的使用
3.  if...then  ;  case....esac ;  funtion   ; while do  done ;until do done   ;  for  do  done ;
4.  Shell Script 追踪与debug

Linux 账号与群组

1.  有效与初始群组  有效群组的观察使用groups   切换使用newgrp  群组名
2.  新增成员 useradd   删除成员 userdel
3.  查询使用者使用  id  ；w ; who; last; lastlog
4.  与使用者对谈 write;mesg;wall

例行性工作排程(at cron)

1.  仅执行一次的工作排程at   allow deny等文件
2.  循环执行的工作排程  cron  \* \* \* \* \* 命令
3.  可唤醒停机期间的工作任务  anacron

      grep -rni "content" \*   迭代遍历目录下文件中保护该字符串的文件