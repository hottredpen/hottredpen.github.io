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

