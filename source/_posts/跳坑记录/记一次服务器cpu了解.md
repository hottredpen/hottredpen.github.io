---
title: 记一次服务器cpu了解
date: 2019-05-30 09:33:57
tags: CPU
---

### 背景
自己写的php代码,执行mysql时,占用了很大的CPU,排查问题修改代码后,发现公司服务器已经没有这个问题,连续请求,mysql的内存不会增加。但是客户的机子上,连续请求还是会出现这个问题。

经排查后，应该是客户服务器上的CPU处理速度跟不上,导致mysql执行效率跟不上,被阻塞住。导致CPU会因为请求数量的累加而上升。而公司服务器因为处理速度快,即使请求速不断累加,其CPU的值也上升很少。

### 参考
在linux 下怎么查看服务器的cpu和内存的硬件信息
https://zhidao.baidu.com/question/155943069.html
intel xeon(skylake) platinum 8163 性能评测 阿里云第四代ECS服务器
https://yq.aliyun.com/articles/622603


