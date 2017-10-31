---
title: 记一次在vue中使用axios，参数没有序列化
date: 2017-11-01 07:22:16
tags:
    - vue 
    - axios
---

#### 背景

开始用vue写项目，可是用axios进行get操作没问题，进行post操作时，post的值始终没有传过来

直到搜索到“qs序列化”关键词，才发现其中的缘由

#### 参考

Kouss博客 http://kouss.com/3884.html

#### 内容

设置了headers中Content-Type为application/x-www-form-urlencoded数据格式，post发起的请求仍为json类型，并没有序列化。
郁闷的是用JSON.stringify无效。

<img src="http://s.kouss.com/wp-content/uploads/2017/01/f413b81288.png">

这个Form Data后台取不到数据，正常的Form Data数据应该是key：val
最终解决方法：使用qs

```
var qs = require('qs')
Vue.prototype.$http = axios.create({
    baseURL: 'http://chaozhi.hk',
    timeout: 10000,
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    transformRequest: [function (data) {
        data = qs.stringify(data)
        return data
    }]
})
```