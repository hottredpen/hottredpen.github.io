---
title: centos7安装2个版本的php
category: [学无止境]
tags: [ centos ]
date: 2021-07-15 16:51:53
---

### 安装php

```
wget https://www.php.net/distributions/php-7.3.29.tar.gz
tar -xzvf php-7.3.29.tar.gz
cd php-7.3.29
```

```
./configure --prefix=/usr/local/php73 \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--enable-mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--enable-mysqlnd-compression-support \
--with-iconv-dir \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-mbstring \
--enable-intl \
--enable-ftp \
--with-gd \
--enable-gd-jis-conv \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--with-gettext \
--disable-fileinfo \
--enable-opcache \
--with-pear \
--enable-maintainer-zts \
--with-ldap=shared \
--without-gdbm
```
中间安装cmake-3.13.2 和 libzip-1.5.2
接着
```
make && make install 
```

验证
```
[root@kmtserver /root]#/usr/local/php73/bin/php --version
PHP 7.3.29 (cli) (built: Jul 15 2021 13:22:48) ( ZTS )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.3.29, Copyright (c) 1998-2018 Zend Technologies
```

### php-fpm
从源码中复制php.ini-production 到`/usr/local/php73/lib/`下并改名为php.ini

```
cd /usr/local/php73/etc/
cp php-fpm.conf.default php-fpm.conf
cd /usr/local/php73/etc/php-fpm.d
cp www.conf.default www.conf
```
因为已经在本机了有php7.2了，9000端口已经被占用了
修改www.conf将新端口指向 9001

### 安装php的redis拓展
先进入redis的源码目录

```
wget https://github.com/phpredis/phpredis/archive/refs/tags/5.3.4.zip

unzip ./5.3.4.zip
cd phpredis-5.3.4

/usr/local/php73/bin/phpize #用phpize生成configure配置文件
./configure --with-php-config=/usr/local/php73/bin/php-config #配置
make #编译
make install #安装
```

安装成功后提示
```
Installing shared extensions:     /usr/local/php73/lib/php/extensions/no-debug-zts-20180731/
```

在`/usr/local/php73/lib/php.ini`添加extension
```
extension=redis
```
重启php-fpm

