---
title: MITRE ATT&CK学习-Navigator
typora-root-url: ..
date: 2021-12-03 09:35:21
tags:
 - APT
 - MITRE
---

在上文中，主要了解了 MITRE ATT&CK 攻击模型的一些概念，本文将记录 MITRE的Navigator 工具基础使用。 Navigator 项目地址：https://github.com/mitre-attack/attack-navigator

# ATT&CK® Navigator

> The ATT&CK Navigator is designed to provide basic navigation and annotation of [ATT&CK](https://attack.mitre.org/) matrices, something that people are already doing today in tools like Excel. We've designed it to be simple and generic - you can use the Navigator to visualize your defensive coverage, your red/blue team planning, the frequency of detected techniques or anything else you want to do. The Navigator doesn't care - it just allows you to manipulate the cells in the matrix (color coding, adding a comment, assigning a numerical value, etc.). We thought having a simple tool that everyone could use to visualize the matrix would help make it easy to use ATT&CK.
>
> The principal feature of the Navigator is the ability for users to define layers - custom views of the ATT&CK knowledge base - e.g. showing just those techniques for a particular platform or highlighting techniques a specific adversary has been known to use. Layers can be created interactively within the Navigator or generated programmatically and then visualized via the Navigator.

正如介绍所说，Navigator作为一个攻击矩阵导航器，做了能够在Excel中能做的事。作为一个可视化的页面，可以标注颜色、分数、备注等，可用于红/蓝队构建自己的攻击/防御路线。

如果要查看在线版，可直接访问 https://mitre-attack.github.io/attack-navigator/ ，可导入APT组织的矩阵图，或创建自己的矩阵图

以下为本地安装方法：

## 1.安装

前置条件： node.js 8 +

```bash
sudo npm install -g @angular/cli
git clone https://github.com/mitre-attack/attack-navigator.git
cd attack-nav	igator/nav-app/
npm install 
```

然后就可以在 http://localhost:4200/ 查看安装完成的页面

![image-20211203125439560](/assets/image-20211203125439560.png)



## 2.使用

点击 create New Layer，可以创建一个新的视图，选择我们想要创建的视图后，将会加载json文件

加载完成后，顶部工具栏，可供我们对矩阵进行修改、标注、导出

![image-20211203125934378](/assets/image-20211203125934378.png)



同时，Navigator支持导入本地或远程的json文件，或创建自定义的视图。

比如可以在github中查找知名APT组织的相关矩阵图，如 APT29（可直接从 MITRE官网该组织描述页面中下载json文件或直接在线浏览 ）

如 https://attack.mitre.org/groups/G0016/ 页面中，按钮如下：

![image-20211203130400861](/assets/image-20211203130400861.png)

具体页面中的操作，本文不做介绍，可自行探索
