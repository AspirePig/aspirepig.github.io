---
title: wordpress迁移hexo
date: 2021-11-23 13:14:59
tags: 
  - wordpress
  - hexo
  - github
typora-root-url: ..
---

## 迁移原因

vps到期，忘记了续费，导致博客直接没了。

为了防止以后还会忘记续费，决定改用 hexo 做博客，并且属实白嫖了github  cloudflare-cdn。

## 步骤记录

### 1. 导出wordpress文章

使用工具-导出-所有内容 导出xml格式的文章，保存到本地用于后续使用

<img src="/assets/image-20211124140635988.png" alt="image-20211124140635988" style="zoom: 67%;" />

### 2. 创建Hexo项目

#### 2.1 安装 npm&git

- Node.js：[https://nodejs.org/zh-cn](https://link.zhihu.com/?target=https%3A//nodejs.org/zh-cn)
- Git：[https://git-scm.com/downloads](https://link.zhihu.com/?target=https%3A//git-scm.com/downloads)

下载 Node.js 和 Git 程序并安装，一路点 “下一步” 按默认配置完成安装。

安装完成后，Win+R 输入 cmd 并打开，依次输入 `node -v`、`npm -v` 和 `git --version` 并回车，如下图出现程序版本号即可。

#### 2.2 Github 创建 [username].github.io 仓库

<img src="/assets/image-20211124141319324.png" alt="image-20211124141319324" style="zoom: 80%;" />

#### 2.3 git ssh 配置

```bash
git config --global user.name "用户名"
```

生成 ssh 密钥对（默认生成在 用户家目录/.ssh 文件夹下，如之前生成过，此步骤可跳过）

```bash
ssh-keygen -t rsa   #一路回车
```

添加公钥到github:

进入 用户家目录 .ssh 目录(如Windows C:\Users\用户名\.ssh),复制 id_rsa.pub 文件内容。

登陆 GitHub ，进入 Settings 页面，选择左边栏的 SSH and GPG keys，点击 New SSH key。将复制的公钥粘贴后保存即可。

<img src="/assets/image-20211124142149199.png" alt="image-20211124142149199" style="zoom:80%;" />

测试：

在git bash 或 终端中输入 `ssh -T git@github.com` ，信任证书后，若出现 成功认证，即可。

#### 2.4 安装hexo

新建一个空文件夹，用于存放 hexo 项目文件

```bash
#安装 hexo
npm install -g hexo-cli
#初始化
hexo init
#安装组件
npm install
#生成页面
hexo g
#启动预览
hexo s
```

此时，正常情况下访问 `http://localhost:4000` 能看到本地博客

### 3.同步Hexo到github pages

```bash
#安装hexo-deployer-git
npm install hexo-deployer-git --save
```

修改项目根目录下的 **_config.yml** 文件

```yaml
deploy:
  type: git
  repository: git@github.com:用户名/用户名.github.io.git
  branch: main
```

修改完成后，运行 `hexo d` 将网站部署到 Github Pages上

此时，访问 `https://用户名.github.io` 应当可以看见Hexo网站。

### 4.绑定自定义域名

注册域名及解析域名到 github pages 的设置本文不做记录

打开博客所在 GitHub 仓库，Settings -> 下拉找到 GitHub Pages ->custom domain ，填入自己的域名，配置如下图。

进入本地博客 source 目录，创建 文件  CNAME ，内容为 自己的域名，如 xxx.cn

```bash
hexo clean   # 清除缓存文件等
hexo g       # 生成页面
hexo s       # 启动预览
```

完成后再次访问博客，应当会被自动重定向到我们的域名。

### 5.开启HTTPS

配置自己的域名后，需要我们手动开启 HTTPS。打开博客所在 GitHub 仓库，Settings -> 下拉找到 GitHub Pages -> 勾选 Enforce HTTPS。<img src="/assets/image-20211124144109626.png" alt="image-20211124144109626" style="zoom:80%;" />

过几分钟，应当可以看见博客使用https访问（原理是 github 帮我们申请了我们域名的免费https 证书）

### 6.使用 cloudflare 免费CDN加速访问（可选）

通过https://dash.cloudflare.com/sign-up链接进行注册，注册完成后，将自己的站点添加cloudflare

<img src="/assets/image-20211124144407583.png" alt="image-20211124144407583" style="zoom: 80%;" />

添加 DNS 记录，此处可直接通过 cname 的方式完成解析

<img src="/assets/image-20211124132055800.png" alt="image-20211124132055800" style="zoom:80%;" />

配置完成后，根据cloudflare的要求，需要将域名的DNS服务器改为cloudflare的地址，此处提供腾讯云注册域名修改方法，其他域名服务商请自行搜索修改方法。

腾讯云：访问 https://console.cloud.tencent.com/domain ，点击域名后方 管理 按钮

![image-20211124145102060](/assets/image-20211124145102060.png)

在页面下方点击修改即可,修改完成后需一定时间等待同步

<img src="/assets/image-20211124145205531.png" alt="image-20211124145205531" style="zoom: 67%;" />

配置cloudflare ssl，选择 Full或Full(strict) 模式

![image-20211124145339039](/assets/image-20211124145339039.png)

### 7.更换主题

- 在 [Themes | Hexo](https://link.zhihu.com/?target=https%3A//hexo.io/themes/) 选择一个喜欢的主题
- 在 github 搜索 Hexo themes，选择自己喜欢的主题，按照主题安装教程进行安装，此处不做记录

### 8.导入WordPress文章

首先，安装 `hexo-migrator-wordpress` 插件。

```bash
#安装插件
npm install hexo-migrator-wordpress --save
#导入WordPress文章
hexo migrate wordpress <source>
```

导入后，手动到 source/_post 目录查看markdown源文件(存在一些文章是空的情况)，解决图片附件链接是否正常(如果不是用的外链，此处需要将WordPress的 uploads 文件夹放到 public 文件夹中，并校对文件路径是否正确)

### 9.创建私有项目，同步&备份源文件

如有在多个设备编写博客的需求，或需要备份博客源文件，可采用 共享文件夹等方式实现。本博客本着与github俱存亡的理念，将源文件也同步到github 私有项目。

在github创建一个私有项目，随后将本地文件同步到github 私有项目中。

```bash
git init
git add .
git commit -m "update"
git remote add origin git@github.com:yourname/youremail.git
git push -u origin main
```

后面为了方便，创建了两个 bat 文件，一键 部署博客，一键 同步源文件。方便使用

### 10.配置 typora

考虑到免费图床需要实时网络，并且可能会倒闭。图片及附件直接放置在本地文件中，部署时同步到github中。

本文使用 typora 编辑器，配置方式如下：

1. 在source 目录下创建 assert 目录，用于存放附件

2. 配置typora如下

   ![image-20211124153253713](/assets/image-20211124153253713.png)

3. 修改 scaffolds 中的 post 默认模板，添加 `typora-root-url` 变量，值为 `..`  ,例如

   ```yaml
   title: {{ title }}
   date: {{ date }}
   tags:
   typora-root-url: ..
   ```



其他如主题的配置，也遇到一些问题，需要看主题的文档及issue 进行解决。

### 11.Mac 多平台协同配置

考虑到需要在mac上同步写博客，使用github 做同步（顺便把备份问题解决掉）

以下为操作步骤：

1. 首先在github上新建一个私有项目 myblog

2. 删除主题中带有 .git 的文件夹 (github 嵌套 的git项目源文件无法上传到github)

3. Windows：在本地文件中创建 .gitignore 文件，文件内容如下

   ```
   .DS_Store
   Thumbs.db
   db.json
   *.log
   node_modules/
   public/
   .deploy*/
   ```

3. Windows：在hexo项目根目录，初始化git，并将项目push到私有项目 myblog上

   ```bash
   git init
   git remote add origin git@github.com:AspirePig/myblog.git
   git add .
   git commit -m "update"
   git push -u origin main
   ```

5. Mac：安装好npm，hexo ，clone项目，并在其他目录初始化一个 hexo 项目，将其中的node_modules 目录拷贝到 clone 下来的 目录中

   ```bash
   sudo npm install -g hexo-cli  #安装hexo
   mkdir hexo_tmp && cd hexo_tmp
   hexo init   #初始化一个hexo项目
   cd ..
   git clone git@github.com:AspirePig/myblog.git
   cp -rf hexo_tmp/node_modules myblog/   #复制一个初始化好的node_modules
   cd myblog
   npm install  #自动安装好在Windows上安装过的模块
   #r如果安装慢，可以更改npm 源
   npm config set registry https://registry.npm.taobao.org
   ```

5. Mac：修改文章，测试各是否正常可用

   ```bash
   hexo g
   hexo s
   hexo d
   ```

6. 测试通过后，上传到git项目，并在Windows测试是否正常





## 参考链接

- https://zhuanlan.zhihu.com/p/60578464
- https://hexo.io/zh-cn/docs/migration.html#WordPress
- https://github.com/blinkfox/hexo-theme-matery/blob/develop/README_CN.md
- https://monkeywie.cn/2020/08/20/fast-github-page-with-cloudflare/
- https://blog.csdn.net/hehung/article/details/103430545
- https://blog.csdn.net/weixin_42474261/article/details/84476050





## TODO

- [x] 图床问题 ✅ 
- [ ] 资料修改完善 
- [x] 多电脑编辑 ✅
- [x] cdn加速 ✅
- [x] 留言板✅ gittalk，存在安全问题，使用小号注册