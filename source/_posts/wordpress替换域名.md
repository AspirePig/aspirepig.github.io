---
title: WordPress替换域名
tags:
  - misc
id: '263'
categories:
  - - misc
date: 2017-07-22 20:57:07
---

```
UPDATE wp_options SET option_value = replace(option_value, 'http://old.cn','http://new.cn') ;
UPDATE wp_posts SET post_content = replace(post_content, 'http://old.cn','http://new.cn') ;
UPDATE wp_comments SET comment_content = replace(comment_content, 'http://old.cn', 'http://new.cn') ;
UPDATE wp_comments SET comment_author_url = replace(comment_author_url, 'http://old.cn', 'http://new.xxxx.cn') ;
```