---
title: 在mac上通过Homebrew安装redis
date: 2017-10-22 14:10:57
tags: 
     - redis
     - mac
---

#### 安装命令
~~~
brew install redis
~~~

安装完成后提示
~~~
To have launchd start redis now and restart at login:
  brew services start redis
  Or, if you don't want/need a background service you can just run:
    redis-server /usr/local/etc/redis.conf
    ==> Summary
    🍺  /usr/local/Cellar/redis/4.0.2: 11 files, 2.7MB, built in 23 seconds
~~~

执行提示
~~~
brew services start redis
~~~
完成后提示
~~~
Cloning into '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-services'...
remote: Counting objects: 12, done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 12 (delta 0), reused 7 (delta 0), pack-reused 0
Unpacking objects: 100% (12/12), done.
Checking connectivity... done.
Tapped 0 formulae (39 files, 53.5KB)
==> Successfully started `redis` (label: homebrew.mxcl.redis)
~~~

ok~redis 已经启动
