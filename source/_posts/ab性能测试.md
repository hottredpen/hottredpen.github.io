---
title: ab性能测试
date: 2017-10-25 15:19:00
tags:
     - 测试
---


### 背景
早先在CPK项目时，因为有用户反应页面打不开，后来采用了CDN和静态页，那段时间也用ab测试工具测试过速度,但用了之后就没深入了解（主要是没写笔记做记录，忘记了）
之后因为离职去应聘时，一个面试官问过ab测试，且对我当时的一个开源项目进行了简单的压力测试。因为采用了pjax，没用静态页，首页的测试并不理想，之后打算着将TP的静态页部分改进下，满足pjax时也能调用。
在laravel，TP5，YII2等框架性能据说都有不错的提升时，自己用TP3.2开源的项目就显得十分的老旧。如何对比速度上的差异，也就只能先记录下TP3.2时的速度，用新框架的速度来进行对比。

### 参考地址
作者：橙子酱
链接：http://www.jianshu.com/p/43d04d8baaf7
來源：简书

### 关于压力测试的概念

#### 吞吐率（Requests per second）
概念：服务器并发处理能力的量化描述，单位是reqs/s，指的是某个并发用户数下单位时间内处理的请求数。某个并发用户数下单位时间内能处理的最大请求数，称之为最大吞吐率。
计算公式：总请求数 / 处理完成这些请求数所花费的时间，即
```
Request per second = Complete requests / Time taken for tests
```
以100并发 100次请求，各大网站的对比(20171025)
```
百度(www.baidu.com)   80~88
知乎(www.zhihu.com)   75~85
QQ(www.qq.com)        25~35
微博（www.weibo.com） 20~25
```

#### 并发连接数（The number of concurrent connections）
概念：某个时刻服务器所接受的请求数目，简单的讲，就是一个会话。

#### 并发用户数（The number of concurrent users，Concurrency Level）
概念：要注意区分这个概念和并发连接数之间的区别，一个用户可能同时会产生多个会话，也即连接数。

#### 用户平均请求等待时间（Time per request）
计算公式：处理完成所有请求数所花费的时间/ （总请求数 / 并发用户数），即
```
Time per request = Time taken for tests /（ Complete requests / Concurrency Level）
```

#### 服务器平均请求等待时间（Time per request: across all concurrent requests）
计算公式：处理完成所有请求数所花费的时间 / 总请求数，即
```
Time taken for / testsComplete requests
```
可以看到，它是吞吐率的倒数。
同时，它也 等于 用户平均请求等待时间/并发用户数，即
```
Time per request / Concurrency Level
```

```
百度(www.baidu.com)   1100~1300  11.00~13.00
知乎(www.zhihu.com)   1100~1300  11.00~13.00
QQ(www.qq.com)        3200~3500  32.00~35.00
微博（www.weibo.com）  4000~5000  40.00~50.00
```


------

### 单次测试结果的说明

```
Concurrency Level: 100                 //并发请求数
Time taken for tests: 50.872 seconds   //整个测试持续的时间
Complete requests: 1000                //完成的请求数
Failed requests: 0                     //失败的请求数

Total transferred: 13701482 bytes      //整个场景中的网络传输量
HTML transferred: 13197000 bytes       //整个场景中的HTML内容传输量

Requests per second: 19.66 [#/sec] (mean)   //吞吐率，大家最关心的指标之一，相当于 LR 中的每秒事务数，后面括号中的 mean 表示这是一个平均值
Time per request: 5087.180 [ms] (mean)      //用户平均请求等待时间，大家最关心的指标之二，相当于 LR 中的平均事务响应时间，后面括号中的 mean 表示这是一个平均值
Time per request: 50.872 [ms] (mean, across all concurrent requests)   //服务器平均请求处理时间，大家最关心的指标之三

Transfer rate: 263.02 [Kbytes/sec] received   //平均每秒网络上的流量，可以帮助排除是否存在网络流量过大导致响应时间延长的问题

```



### 关于登录的问题

有时候进行压力测试需要用户登录，怎么办？
请参考以下步骤：
```
    先用账户和密码登录后，用开发者工具找到标识这个会话的Cookie值（Session ID）记下来
```
```
    如果只用到一个Cookie，那么只需键入命令：
    ab －n 100 －C key＝value http://test.com/
```
```
    如果需要多个Cookie，就直接设Header：
    ab -n 100 -H “Cookie: Key1=Value1; Key2=Value2” http://test.com/
```

### 如何防止别人用ab之类的测试软件恶意请求自己的网站

网友回答：
```
目前此类软件可以很真实的模拟浏览器请求，所以在少量的请求下，基本上是屏蔽不了的。
但是，使用此类软件请求你的网站通常都有其他目的，会产生大量重复的请求。
可以通过单位时间的请求次数进行控制，相同IP或者相同的userAgint产生的异常请求通过程序判断来禁止。
但是即便程序做了判断，请求已经进入处理阶段依然会影响性能，所以还要配合其他的处理方式，重复响应最好用缓存的方式来实现，避免过多的消耗CPU；确诊的问题IP应该在防火墙端就进行屏蔽。
```
```
nginx的话可以用HttpLimitReqModule
此模块能通过特定的客户端标识（如IP，UA等）来限制客户端在一定时间内的访问频次，比你在程序里控制要省资源得多。
```
