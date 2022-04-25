---
title: os x安装homebrew及oh-my-zsh
tags:
  - OS X
  - tools
id: '437'
categories:
  - - OS X
  - - tools
date: 2018-07-07 11:05:37
---

*   安装homebrew(需要安装xcode)

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

*   更新homebrew

```
brew update
```

*   若是提示无权限，则将/usr/local归属者给当前用户

```
sudo chown -R $(whoami) /usr/local
```

*   更新好以后更新zsh,并切换终端为zsh,重启终端即可

```
brew install zsh && chsh -s /bin/zsh
```

*   安装oh-my-zsh

```
sh -c"$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

*   编辑配置文件~/.zshrc即可配置主题，添加打开终端的命令等（[主题列表](https://github.com/robbyrussell/oh-my-zsh/wiki/themes)）
*   安装自动补全插件incr，下载http://mimosa-pudica.net/src/incr-0.2.zsh放入~/.oh-my-zsh/custom/plugins/incr文件夹中。并在~/.zhsrc配置文件末尾添加

```
 source ~/.oh-my-zsh/plugins/incr/incr*.zsh
```

*   最后重启终端或执行source ~/.zshrc即可启用。
*   安装语法高亮：

```
#安装语法高亮插件
brew install zsh-syntax-highlighting  

#更改~/.zshrc,plugin中加入zsh-syntax-highlighting  ，并在文件末尾添加
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

*   然后配置自带终端界面，字体设置字号13

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/屏幕快照-2018-07-07-上午11.06.35.png)![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/07/屏幕快照-2018-07-07-上午11.06.47.png)