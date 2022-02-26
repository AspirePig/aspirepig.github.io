---
title: LockBit Batch Download
typora-root-url: ..
date: 2022-02-26 09:05:48
tags: 
 - Tor
 - javascript
 - python
 - darkweb
---

## LockBit2.0

LockBit 是一种采用强大的加密算法来使用户付费的加密病毒. 它使用各种分发方法来渗透目标计算机，例如垃圾邮件活动。, 网络钓鱼站点, 软件漏洞, 还是假的更新. 一旦进入, 它启动扫描过程以查找某些可能对用户有价值的文件类型 (相片, 视频和音频文件, 文件, 压缩文件, 等等). 然后, 病毒会对所有找到的文件进行编码，以便在解密之前无法访问它们. 获取解密软件, 受害者被要求支付加密货币赎金. 然而, 我们不建议您与这类人联系, 因为它可能导致欺诈或第二次病毒攻击. 

LockBit2.0 会公开数据以威胁企业，但公开的数据不支持批量及打包下载，只能自己下载。并且公开的地址在暗网中，因此本文使用 JavaScript 爬取所有文件夹及文件路径（因为浏览器上运行比Python脚本快。。。），在使用Python批量创建目录并下载。



## 爬取文件夹及文件名

对网页接口进行分析，写出以下脚本，直接在控制台中运行

```javascript
dir_list = []
file_list = []
count_http = 0

function htmlDecodeByRegExp(str){  
          var s = "";
          if(str.length == 0) return "";
          s = str.replace(/&amp;/g,"&");
          s = s.replace(/&lt;/g,"<");
          s = s.replace(/&gt;/g,">");
          s = s.replace(/&nbsp;/g," ");
          s = s.replace(/&#39;/g,"\'");
          s = s.replace(/&quot;/g,"\"");
          return s;  
}


function listdir(path,index = 0,otherpage=0){
	count_http = count_http + 1

	var settings = {
	  "url": "http://lockbitapt6vx57t3eeqjofwgcglmutr3a35nygvokja5uuccip4ykyd.onion/ajax/listing-post",
	  "method": "POST",
	  "timeout": 0,
	  "headers": {
	    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0",
	    "Accept": "application/json, text/javascript, */*; q=0.01",
	    "Accept-Language": "en-US,en;q=0.5",
	    "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
	    "X-Requested-With": "XMLHttpRequest",
	  },
	  "data": "explorer=true&sub_path=&split_idx="+index+"&folder_id=1130&full_path=" + encodeURIComponent(path),
	};

	$.ajax(settings).done(function (response) {
	  res = JSON.parse(response);
	  // console.log(res);
	  data = res.file_list
	if(res.files_amount > 14 && otherpage == 0){
		count = 0
		while( (count + 1) * 14 < res.files_amount){
			count = count + 1
			listdir(path, count, 1)
		}
	}
	for (i in data){
		pathname = data[i].match(/data-dir=\"(.*?)\">/)[1]
		pathname = htmlDecodeByRegExp(pathname)
		pathname = pathname.replace(/\/ /g,"\/")
		if (data[i].includes("file__name--folder")){
			dir_list.push(pathname)
			listdir(pathname)
		}
		else{
			file_list.push(pathname)
			// console.log(file_list.length)
		}
	}
	console.log(file_list.length)
	});
}

res = listdir("/pwmaadfile01")
```

爬取完成后， 右键复制元素将dir_list 和 file_list 保存到文件中（json格式）

这里有个小技巧，打开页面后下方的 数字即所有文件的总数

![image-20220226091736055](/assets/image-20220226091736055.png)



## 安装 Tor代理

1. 安装Tor浏览器，就会在 127.0.0.1:9150 上起一个socks代理端口 
2. 安装 Tor ，代理端口为 9050

以centos为例：

```bash
yum install epel-release
yum install tor
```

配置科学上网 ，如果是 V2[]Ray， 需要在服务端，将 sniffing 设置为 false

如果服务器本身在国外（建议这种方式，直接在国外服务器上进行下载速度更快），可直接开启 tor

```
tor --hash-password mypassword
# 修改配置
vi /etc/tor/torrc

# 修改或新增以下配置，也可不修改
Socks5Proxy 127.0.0.1:1080 #通过代理连接
ExcludeNodes {cn},{hk},{mo},{kp},{ir},{sy},{pk},{cu},{vn} #屏蔽某些节点
strictnodes 1 # 严格节点模式
ControlPort 9051 # 指定端口
HashedControlPassword [密码] # 填入上一步获得的密码
MaxCircuitDirtiness 10 # 设置更换ip的频率
SOCKSPort 9050 # Default: Bind to localhost:9050 for local connections.  
SOCKSPort 0.0.0.0:9150 # Bind to this address:port too.

# 运行
systemctl start tor

# 查看日志，是否100%done，表示成功
journalctl -f -o cat -u tor

#检查端口
ss -antp
```



## 批量创建目录并下载

使用Python批量创建目录 并下载，但当前需要注意 ，Session半个小时会失效（无论网络是否活动），因此需要每半个小时替换Session。

并且需要升级 requests模块到支持 socks的版本 `pip3 install requests[socks]`

Tips： 此处需要使用 socks5h 才能支持通过 代理解析域名，普通的socks5 不会通过代理解析域名。

```python
import os
import json
from urllib.parse import quote
# pip install requests[socks]
import requests
session = requests.session()
session.proxies = {'http': 'socks5h://127.0.0.1:9150', 'https': 'socks5h://127.0.0.1:9150'}
Cookie = 'res=5F431B0E27E2CCDD4681EB38C7AB6811DFE6E93E41917; PHPSESSID=2n13bfpq195uhdokquul3vb87m'


def creat_dir():
    with open("dirnames.txt") as f:
        dirs = json.load(f)
        for d in dirs:
            os.makedirs((d[1:].replace(" ","_")))

def downloadfiles():
    with open("peter.txt") as f:
        files = json.load(f)
        count = 0
        for file in files:
            sysfile = file[1:].replace(" ", "_")
            if os.path.exists(sysfile):
                count = count + 1
                continue
            print("start download: {}/{} ==> {}".format(count + 1, len(files), file))
            downloadlink = "http://lockbitapt6vx57t3eeqjofwgcglmutr3a35nygvokja5uuccip4ykyd.onion/ajax/listing-post?file-download=true&folder-id=1130&data-dir="+quote(file[1:])

            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.5',
                'Referer': 'http://lockbitapt6vx57t3eeqjofwgcglmutr3a35nygvokja5uuccip4ykyd.onion/post/2tlXutWhY9uckIv2620ab34bc0764',
                'Connection': 'keep-alive',
                'Cookie': Cookie,
                'Upgrade-Insecure-Requests': '1',
                'Sec-Fetch-Dest': 'document',
                'Sec-Fetch-Mode': 'navigate',
                'Sec-Fetch-Site': 'same-origin',
                'Sec-Fetch-User': '?1',
                'Pragma': 'no-cache',
                'Cache-Control': 'no-cache'
            }

            response = session.get(downloadlink, headers=headers )
            if "lockbitapt6vx57t3eeqjofwgcglmutr3a35nygvokja5uuccip4ykyd" in response.text:
                print("session out time,please replace the active cookie, and delete the downloaded link.")
                print("current line number: {}".format(count))
                exit()
            with open(sysfile, "wb") as code:
                code.write(response.content)
            count = count + 1
            print(sysfile + "====OK({}/{})".format(count, len(files)))
            



if __name__ == "__main__":
    #creat_dir()
    downloadfiles()

```



首先执行  creat_dir() 函数 批量创建好目录， 再执行  downloadfiles() 函数进行下载



## 全自动化想法

该网站使用了 Nginx-Lua-Anti-DDoS  做人机校验，实现原理是 让浏览器去计算一个复杂结果，表现为打开网站，展示 DDOS 页面，需要等待7秒后跳转到真正页面，之后会设置一个 有效 Session。

当前有两个想法：

1. 研究具体实现原理，实现直接Python请求获取有效Session
2. 使用 selenium 模拟打开网站，等待浏览器获取到有效Session后，再通过selenium获取 Session值，返回给脚本。
