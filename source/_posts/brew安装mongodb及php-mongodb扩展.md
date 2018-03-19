---
title: brew安装mongodb及php mongodb扩展
date: 2018-01-25 12:59:34
tags:
     - brew
     - mongodb
     - php拓展
---

### 背景
安装某laravel项目

### 参考
http://old.ruesin.com/system/mac/mac-mongodb-345.html

### 安装mongodb服务
```
brew install mongodb
```
```
==> Installing mongodb
==> Downloading https://homebrew.bintray.com/bottles/mongodb-3.4.10.high_sierra.
######################################################################## 100.0%
==> Pouring mongodb-3.4.10.high_sierra.bottle.tar.gz
==> Caveats
To have launchd start mongodb now and restart at login:
  brew services start mongodb
Or, if you don't want/need a background service you can just run:
  mongod --config /usr/local/etc/mongod.conf
==> Summary
```

### php 的 mongodb 扩展 
search一下
```
brew search mongo
```
```
brew install php71-mongo
```

#### 安装出错
```
NOTICE: PHP message: PHP Warning:  PHP Startup: mongodb: Unable to initialize module
Module compiled with build ID=API20160303,NTS
PHP    compiled with build ID=API20160303,NTS,debug
These options need to match
 in Unknown on line 0
<br />
<b>Warning</b>:  PHP Startup: mongodb: Unable to initialize module
Module compiled with build ID=API20160303,NTS
PHP    compiled with build ID=API20160303,NTS,debug
These options need to match
 in <b>Unknown</b> on line <b>0</b><br />
Unknown(0) : Warning - PHP Startup: mongodb: Unable to initialize module
Module compiled with build ID=API20160303,NTS
PHP    compiled with build ID=API20160303,NTS,debug
These options need to match


```

网上搜是需要重新安装编译
```
brew reinstall <formulaname> --build-from-source
```
