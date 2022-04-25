---
title: ubuntu安装中文man手册
tags:
  - linux
  - misc
id: '193'
categories:
  - - linux
  - - misc
date: 2017-01-23 21:43:03
---

man默认是英文的，但ubuntu的源里也有中文版的。以下是配置方法: 1)  终端输入

```
sudo apt-get install manpages-zh
```

2)  安装后修改配置文件

```
sudo gedit /etc/manpath.config
```

3)  将所有的/usr/share/man替换为/usr/share/man/zh\_CN 4)  保存即可。