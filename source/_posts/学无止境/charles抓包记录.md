---
title: charles抓包记录
category: [学无止境]
tags: [charles]
date: 2021-03-05 09:59:53
---


1、先打开charles

2、查看pc的ip地址

3、在手机端与pc同wifi下（或者mac提供的热点wifi），手动设置代理一般为 pc 的ip 加8888端口

4、这样就能抓包普通的http请求了

5、抓包https，需要手机端安装charles证书
https://www.cnblogs.com/xiaozi/p/9229615.html

6、安装完后，可能还会出现“SSL handshake failed - Remote host closed connection during handshake”
https://www.neglectedpotential.com/2017/04/trusting-custom-root-certificates-on-ios-10-3/
在`通用`->`关于本机`->`证书信任设置`中开启对刚才证书的信任