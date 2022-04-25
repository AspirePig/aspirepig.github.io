---
title: .git泄露利用工具
tags:
  - ctf
  - linux
  - python
  - web
id: '168'
categories:
  - - ctf
  - - python
  - - tools
date: 2016-12-25 14:20:51
---

介绍 git 在初始化代码库的时候，会在当前目录下面产生一个.git的隐藏目录文件，用来记录代码的变更等。 同时使用这个文件，可以恢复各个版本的代码。所以如果 .git 泄漏的话，就可能同时泄漏了源代码。 测试 先手工测试下，使用 google 搜索一个泄漏的 .git 文件。

```
google: ".git" intitle:"index of"
```

项目地址： [https://github.com/lijiejie/GitHack](https://github.com/lijiejie/GitHack) 用法示例

```
GitHack.py http://www.openssl.org/.git/
```

新增一个工具，可以获取历史版本记录 https://github.com/gakki429/Git\_Extract