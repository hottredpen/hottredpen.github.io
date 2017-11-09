---
title: node-sass安装不成功的解决方法
date: 2017-11-09 15:55:24
tags:
    - nodejs
---

#### 背景

每次安装node-sass都被墙导致安装不成功

#### 参考
http://blog.csdn.net/qq_35440678/article/details/51909327

#### 方法

直接用淘宝的镜像安装成功

```
npm install -g cnpm --registry=https://registry.npm.taobao.org
cnpm install node-sass
```