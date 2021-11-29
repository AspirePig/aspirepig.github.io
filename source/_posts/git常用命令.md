---
title: git常用命令
tags:
  - git
  - github
  - tools
id: '297'
categories:
  - - github
  - - tools
date: 2017-09-03 22:28:38
---

```
git init   //初始化本地仓库

git  add  //添加文件到暂存区

git add .  //添加工作区所有修改过的或新建的文件到暂存区（删除除外）

git commit -m "提交描述"   //提交暂存区的内容到版本中

git status  //查看git状态

git log  //查看提交日志  --graph可以查看分支合并图

git reset --hard HEAD~N/HEAD^/前六位指纹  //版本回退

git reflog  //记录每一次git命令

git diff  //比较是工作目录和暂存区域快照(index)之间的差异

git reset HEAD file   //暂存区的修改撤销掉（unstage），重新放回工作区

git checkout -- 文件   //回到最近的一次git commit 或 git add 时

git rm  //删除文件

git mv  //移动，重命名文件目录或软连接

git pull --rebase origin master  //分支衍合

链接远程仓库方法见上一篇文章https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/misc/267.html

git clone git@github.com:用户名/项目名.git   //从远程仓库克隆项目到本地

git checkout -b 分支名 //创建并切换分支，相当于如下命令
git branch 分支名
git checkout 分支名

git branch  //查看当前分支

git checkout master  //切换到master分区

git merge 分支名  //合并某分支到当前分支

git merge --no-ff -m "merge with no-ff" dev  //强制禁用快速合并模式
git branch -d  分支名  //删除分支

git stash   //暂时存储工作区

git stash list  //查看存储的工作区

git stash apply  //恢复工作区（不删除）

git stash drop  //删除暂存工作区的内容

git stash pop   //恢复暂存区的内容并删除

stashgit branch -D  <分支名>  //强制删除分支

git remote -v //查看远程仓库信息

git push origin master  //推送maste分区到origin远程库

git branch --set-upstream dev origin/dev  //设置分支与远程库分支的绑定

git tag v1.0  //给commit打标签  -d：删除标签

git tag -a v0.1 -m "version 0.1 released" 3628164  //创建带有指定说明的标签 

git show <tagname> //显示信息

git push origin <tagname>  //推送标签到远程
git push origin --tags   //推送所有标签到远程

git push origin :refs/tags/v0.9  //删除远程标签  需要先删除本地标签

git config --global color.ui true  //命令显示颜色

git add -f App.class   //强制添加到git
git check-ignore -v App.class   //检查.gitignore

git config --global alias.st status  //配置别名示例

不删除本地删除远程的方法
git rm -r --cached a/2.txt // 删除a目录下的2.txt文件 
git commit -m "删除a目录下的2.txt文件" // commit
git push 

git push -f   //强制上传，覆盖原数据
```