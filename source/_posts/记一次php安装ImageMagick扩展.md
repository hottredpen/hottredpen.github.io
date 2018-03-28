---
title: 记一次php安装ImageMagick扩展
date: 2018-03-19 14:01:27
tags:
    - imagick
    - ImageMagick
    - php
---

### 背景
将pdf转png图片

### 参考

在wamp server环境下安装php_imagick拓展
http://www.smallerpig.com/673.html
windows php安装ImageMagick扩展
http://blog.csdn.net/livelinux/article/details/50319853
Centos 安装ImageMagick 与 imagick for php步骤详解
https://www.cnblogs.com/xingmeng/p/4268043.html#undefined


### 本机wamp下安装php_imagick拓展

#### 步骤

1.在php安装目录的ext文件夹下新建imagick文件夹
2.将该文件夹的路径添加到系统路径(path值).
3.从网址http://windows.php.net/downloads/pecl/releases/imagick/下载对应php版本的imagick(phpinfo中看php version,Compiler ，Architecture，这三个属性)
4.这里需要注意的是下载的文件区别,我们从文件名中来区分,例如php_imagick-3.2.0b2-5.5-nts-vc11-x86.zip

    其中5.5是对应的php版本.
    nts值代表该文件适用于IIS,ts代表该文件适用于Apache,
    VC11和VC9是编译器的版本.我们可以适用phpinfo()命令来查看我们机器上php适用的是哪个版本(如图1)
    x86代表适用32位系统,x64代表适用64位系统

5.下载好对应的zip文件后,将所有文件解压到我们第一步新建的imagick文件夹!

6.添加php_imagick.dll的完整路径到php.ini文件中.例如:extension=C:\wamp\bin\php\php5.5.12\ext\ext\imagick\php_imagick.dll

7.重启wamp服务器

8.运行phpinfo看看是不是已经成功添加拓展了

9.查看phpinfo中，查看ImageMagick supported formats内的值

输入phpinfo()看到imagick，就算装成功了，但这个时候还不能用，你会看到ImageMagick number of supported formats 为0，ImageMagick supported formats no value，还要安装ImageMagick ，phpinfo里面会写出要安装那个版本的，如：
```
ImageMagick 6.9.3-7 Q16 x64 2016-03-27 http://www.imagemagick.org 
```

然后去下载这个ImageMagick 6.9.3-7 Q16 x64 版本的安装

记得版本要对得上号，要不然就会出现ImageMagick supported formats no value

安装完后重启，再输入phpinfo,就会看到ImageMagick supported formats不是空的了，这个时候就算安全成功

###  Centos 安装ImageMagick 

#### 1. 依次运行以下命令
```
yum install ImageMagick

yum install ImageMagick-devel

yum install php-pear [for PECL]
```
```
yum -y install php-devel
```

#### 2. 安装C编译器
```
yum install gcc
```
如果装不了gcc就用这个命令：
```
yum install gcc gcc-c++ autoconf automake
```

#### 3. 安装imagick
```
pecl install imagick
```

#### 4. 加载imagick到php

在/etc/php.ini 加上extension=imagick.so

#### 5. 重启service httpd restart

#### 6. 使用 phpinfo() 或运行 php -m | grep imagick 来查看是否安装成功

### mac 上安装

#### 安装php的imagick拓展
```
brew reinstall php56-imagick --build-from-source
```

#### 安装ghostscript
```
brew install ghostscript
```

### linux上安装 
这次被坑惨了，linux是最近新的服务器里面没有安装过GD库，这个导致我后面多个坑

第一次安装走的是
https://www.cnblogs.com/xingmeng/p/4268043.html#undefined
里面的方法，
```
yum install ImageMagick
yum install ImageMagick-devel
yum install php-pear
yum -y install php-devel
yum install gcc
yum install gcc gcc-c++ autoconf automake
pecl install imagick


```
加载imagick到php
在/etc/php.ini 加上extension=imagick.so

重启service httpd restart

使用 phpinfo() 或运行 php -m | grep imagick 来查看是否安装成功

这次
```
Imagick, ImagickDraw, ImagickPixel, ImagickPixelIterator,(ImagickKernel  不知道为什么没有这个，本机和mac上都有)  
```

结果提示错误，具体忘记了，估计是因为GD库没有引起的
之后照着
http://blog.csdn.net/snow_small/article/details/79173575
进行了编译安装
1、安装ImageMagic
```
    [root@localhost download]# wget http://www.imagemagick.org/download/ImageMagick.tar.gz  

    [root@localhost download]# tar -xzvf ImageMagick  
    [root@localhost download]# cd ImageMagick-7.0.7-22/  
    [root@localhost ImageMagick-7.0.7-22]# ./configure --prefix=/usr/local/imagemagick  
    [root@localhost ImageMagick-7.0.7-22]# make  
    [root@localhost ImageMagick-7.0.7-22]# make install 
```

2、检查是否安装成功

```
    [root@localhost ImageMagick-7.0.7-22]# /usr/local/imagemagick/bin/convert -version  
    Version: ImageMagick 7.0.7-22 Q16 x86_64 2018-01-26 http://www.imagemagick.org  
    Copyright: © 1999-2018 ImageMagick Studio LLC  
    License: http://www.imagemagick.org/script/license.php  
    Features: Cipher DPC HDRI OpenMP   
    Delegates (built-in): fontconfig freetype jng jpeg png x xml zlib  
```


### 我的坑

但是报下面这个错误
```
Postscript delegate failed
```
是`ghostscript`没安装，可实际是安装的在`/usr/bin/gs`中，但apache死活说找不到（是权限问题），网上有个解决方案是把'/usr/local/bin/gs'做软连接到`/usr/bin/gs`,可是我这边的情况刚好是倒过来的。

一狠心把`ghostscript`给卸载了，重新编译安装了gs，这次真出现在了`/usr/local/bin/gs`,建立了个软连接，真把这个问题解决了。

这次因为没有安装GD库，用的png版本太老，`Delegates (built-in): fontconfig freetype jng jpeg (png 没显示) x xml zlib  `

一直提示
`no decode delegate for this image format PNG`
因为没有安装GD库，我在编译`ImageMagick-7.0.7-22`时没有将`png`编译进行

直到手动添加了png库，才最终发现没有安装GD库






