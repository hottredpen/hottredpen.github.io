---
title: 解决使用JWT时报Cannot handle token prior to的问题
date: 2018-01-12 13:28:56
tags:
     - JWT时间问题
---

#### 背景
使用JWT时，因为本地时间和服务器上的时间不一致，导致的请求发送失败

#### 解决方法

在`vendor\firebase\php-jwt\src\JWT.php`中的第113行左右添加如下的代码
```
echo '<br /> payload->iat = '. $payload->iat . '<br />and time() = '.time() . "<br />leeway= ". self::$leeway;
```
会打印出
```
payload->iat = 1447702275  
and time() = 1447702211  
leeway= 0
```
通过时间差计算出和服务器的差值，并调整本地的时间
