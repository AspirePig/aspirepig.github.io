---
title: gpt+uefi环境下安装win10+deepin双系统
tags:
  - linux
  - misc
id: '110'
categories:
  - - linux
  - - misc
date: 2016-12-23 17:16:28
---

配制清单：

*   机型  宏碁vn7-591-51ww
*   双硬盘：三星固态（win10）+自带机械硬盘（deepin）
*   环境：ssd分区为esp+win10系统盘+win10软件安装盘；机械硬盘deepin（boot+swap+/系统）分区+公共分区

安装过程：

1.  首先我是先装的win10，再装的deepin。装完后我电脑的引导很奇怪，不管怎么改都是直接启动了win10。easyuefi等也不行 然后知道了电脑直接引导了efi下的microsoft里面的efi文件，并没有优先 _efi\\boot_ 里面的efi。我是后来把microsoft整个文件夹放到了win10系统盘根目录下，把esp分区的efi中的microsoft文件夹删掉了，并且用grub的引导文件替换了boot里面默认的这样子就是要用linux的grub引导了。(17-2-29补充：后来发现顽固的win10自己在efi分区生成了一个Microsoft引导文件夹，于是直接把Microsoft里面的bootmgfw.efi给替换成了grub的引导sha什么的.efi)进入deepin系统，终端运行 ![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.comwp-content/uploads/2016/12/1-300x64.png)
    
    ```
    sudo gedit /etc/grub.d/40_custom   //添加efi引导文件
    ```
    
    ```
    sudo gedit /etc/default/grub   //这里可以更改默认启动顺序
    ```
    
    这个文件是可以自己添加引导，在下面加入类似这样的代码
    
    ```
    if [ "${grub_platform}" == "efi" ]; then
    menuentry "Windows 10" {
    set root='(hd0,gpt2)'
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
    fi
    ```
    
    set root中的是指efi引导所在分区，我的是再第一块硬盘第二个分区，所以写hd0,gpt2，接着更新下grub列表
    
    ```
    sudo update-grub
    ```
    
2.  引导是安装过后遇到的问题，安装deepin过程还是挺简单的。刻录在u盘里面，直接再uefi模式下启动安装就可以了。得先准备好一个空闲的分区，分配boot分区，swap交换分区，和根目录分区。
3.  装好系统后的一些小问题： 1.windows和linux会有时间差8个小时，可以再windows管理员权限的cmd中执行
    
    ```
    Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1
    ```
    
    2.需要用到科学上网，deepin的商店里面直接就有gui的shadowsockets可以安装，或者是githubclone下来自己装。装好后，我还配置了pac模式的科学上网。是用的是genpac 方法一： 终端运行
    
    ```
    git clone https://github.com/JinnLynn/GenPAC
    ```
    
    方法二： 需要现安装python-pip
    
    ```
    pip install genpac
    pip install --upgrade genpac
    ```
    
    安装好后，新建一个文件夹，用来放置自动生成的pac文件，建好以后cd进去，新建一个 user-rules.txt，之后执行
    
    ```
    genpac -p "SOCKS5 127.0.0.1:1080" --gfwlist-proxy="SOCKS5 127.0.0.1:1080" --output="autoproxy.pac" --gfwlist-url="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt" --user-rule-from="user-rules.txt"
    ```
    
    之后设置全局代理，如图 ![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.comwp-content/uploads/2016/12/2-300x221.png) 并且应用到系统
4.  chrome使用了adfree.player.online插件，firefox使用了adblock