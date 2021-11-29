---
title: mac下命令行git链接github
tags:
  - github
  - misc
  - OS X
  - tools
id: '267'
categories:
  - - github
  - - misc
  - - OS X
  - - tools
date: 2017-09-03 14:45:51
---

### 第一步：注册GitHub账号，略过

### 第二步：mac上安装或更新git

> 检查是否安装了git，在终端中使用命令
> 
> ```
> git --version
> ```
> 
> 如果出现git版本，则已安装git，与[https://git-scm.com/downloads](https://git-scm.com/downloads)比较版本是否需要升级，若未安装，则直接下载安装

### 第三步：git使用ssh认证与连接

> 首先备份~/.ssh目录下的已有密钥（当然的确定自己是否已经安装了ssh） 接着配置git的username和useremail
> 
> ```
> git config --global user.name "xxx"
> 
> git config --global user.email "xxxt@qq.com"
> ```
> 
> 然后cd到~/.ssh文件夹下执行命令
> 
> ```
> ssh-keygen -t rsa -C “xxxxt@qq.com”
> ```
> 
> 执行完以后，在github的设置中新建一个ssh key，内容就是在~/.ssh中生成的id\_rsa.pub文件中的所有字符。 ![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2017/09/0970DF90-221C-4031-B602-4B8AEA26FD8F-256x300.jpg)![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2017/09/81CCA7FB-DB7A-4BAF-B325-C95017510633.jpg)

### 第四步：测试是否连接成功

> 在github上新建一个仓库（先不勾选产生README.md），接着本地终端cd进入自己项目文件夹执行以下命令
> 
> ```
> git init      //初始化
> git add *    //添加所有文件
> git commit -m "描述"  
> ```
> 
> 然后在github仓库中上找到ssh方式连接的地址 ![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2017/09/85879FD3-AE88-46CF-808E-19CD1A45A165.jpg) 复制连接，在终端中执行命令
> 
> ```
> git remote add origin git@github.com:AspirePig/test.git   //关联项目
> ```
> 
> push项目到github
> 
> ```
> git push -u origin master
> ```
> 
>