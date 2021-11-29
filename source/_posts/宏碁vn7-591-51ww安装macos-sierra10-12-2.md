---
title: 宏碁vn7 591 51ww安装黑苹果macOS Sierra(10.12.2)
tags:
  - misc
  - OS X
  - tools
id: '201'
categories:
  - - misc
  - - OS X
date: 2017-02-11 15:01:17
---

安装所用到文件以及方法来自[http://blog.163.com/deadbull@126/blog/static/1669599372015123006778/](http://blog.163.com/deadbull@126/blog/static/1669599372015123006778/)

以下只是记录一下自己安装的过程，留份防忘

笔记本    ：  Acer VN7-591G-51ww

架构       ：  haswell CPU        ：  Intel(R) Core(TM) i5-4210H 内存       ：  DDR3-1600 8G 显卡       ：  Intel HD 4600 + NVIDIA GeForce GTX 860M 声卡       ：  Realtek ALC283 @ Intel Lynx Point PCH - High Definition Audio Controller \[C-2\] WLAN     ：  Qualcomm Atheros AR5BWB222 Wireless  LAN        ：  Realtek RTL8168/8111 PCI-E Gigabit Ethernet Adapter

硬盘       ：  SSD（120GB）+HD（1T）

引导环境 ：  UEFI+GPT+CLOVER

1.  首先，下载下来  Clover3961\_U\_macOS S 10.12.2(16C67)正式版  （链接: https://pan.baidu.com/s/1eSbvNrG 密码: ns2a）和一些工具（用到再做说明）
2.  在win的环境下，使用transmac 11.9 将U盘（大于8g）格式化成hfs+格式，并且将镜像刻录进去
3.  刻录完成后，替换里面的efi文件夹即可，之后可以用这个U盘来安装os x系统，最好提前分一个efi分区，且要大于200M，否则磁盘工具里面无法抹除硬盘
4.  在进入安装的时候，终端里面设置date：
    
    ```
    date 122014102015.30
    ```
    
    关闭SIP：
    
    ```
    csrutil disable
    ```
    
5.  进入系统后，终端设置允许安装任何来源程序
    
    ```
    sudo spctl --master-disable
    ```
    
6.  挂载efi分区，将efi文件复制进去
7.  接着配置声卡驱动：使用AppleHDA PatcherV1.6版本以上，生成自己声卡的相关文件（右边笔记本选项里面选择的alc283）点patch后桌面生成一个MironAudio文件夹，aDummyHDA.kext和CodecCommander.kext放在了/L/E文件夹下面，AppleHDA.kext放在了/S/L/E文件夹下面，放完之后使用Kext\_Utility重建缓存，修复权限。将efi里面的config.plist（使用的文本编辑器手动添加）和dsdt打上了给出的补丁（使用的maciasl）。重启即可
8.  蓝牙默认打开，关闭按钮灰色不可选，浪费不了多少电。wifi无解，大神说换DW1830三天线，支持ac双频，而且可以使用hanoff，具体参考原贴中链接。  更新：后来某宝买了dw1830，让老板送了一根天线，三天到货。拆机装上，clover里面放入了蓝牙的驱动（wifi免驱动）参考原文链接
9.  使用软件的版本 clover configrator请升级到4.32.1版本以上 kext utility请升级到2.6.6版本及以上
10.  关于iMessage和FaceTime登录的问题，我使用的是一个很多人用过的三码，具体使用方法见这个视频 [http://v.youku.com/v\_show/id\_XMTI4MDE3MDY4MA==.html](http://v.youku.com/v_show/id_XMTI4MDE3MDY4MA==.html)
11.  后来发现在win下重启过来声卡驱动不了了，必须在os x下重启一次才生效。后来在这错的command.kest里面加了一个dsdt-alc283的补丁，详见这几个帖子
    
    ```
    https://github.com/RehabMan/EAPD-Codec-Commander/commit/2f03e9d51a70c68642cec020d3afe54bd2a6385e
    ```
    
    放在CodecCommander.kext/contents/  里面就可以了
12.  10.12 SSD 开启TRIM
    
    ```
    sudo trimforce enable
    ```
    
13.  附带pcbeta  hosts
    
    ```
    218.93.127.136 pcbeta.com 
    218.93.127.136 uc.pcbeta.com 
    218.93.127.136 m.pcbeta.com 
    218.93.127.136 web.pcbeta.com 
    218.93.127.136 i.pcbeta.com 
    218.93.127.136 bbs.pcbeta.com 
    218.93.127.136 www.pcbeta.com 
    218.93.127.136 mac.pcbeta.com 
    218.93.127.136 cdn.pcbeta.attachment.inimc.com 
    218.93.127.136 cdn.pcbeta.static.inimc.com 
    218.93.127.136 cdn.pcbeta.css.inimc.com 
    218.93.127.136 static.template.pcbeta.com
    ```
    
14.  挂载efi分区
    
    ```
    diskutil list
    sudo mkdir /Volumes/EFI/ && sudo mount -t msdos /dev/disk0s1 /Volumes/EFI
    ```