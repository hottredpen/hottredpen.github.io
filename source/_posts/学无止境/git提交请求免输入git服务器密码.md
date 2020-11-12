---
title: git提交请求免输入git服务器密码
date: 2017-11-01 08:50:58
tags:
     - git
---

#### 背景

每次百度这内容，都要花费我不少时间

#### 客户端初始化

```
    git config --global user.name "yourname"  
    git config --global user.email "your@email.com"  
```


```
ssh-keygen -t rsa -C "XXX@company.com"
```

在git服务器下的git主目录下面的.ssh文件下添加（修改）
```
authorized_keys
```

重新启动sshd
```
service sshd restart
```