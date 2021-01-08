---
title: linux安装软件时的configure
category: [学无止境]
tags: [linux]
date: 2020-11-28 10:02:53
---

源码的安装一般由3个步骤组成：配置(configure)、编译(make)、安装(make install)。

`Configure`是一个可执行脚本，它有很多选项，在待安装的源码路径下使用命令`./configure –help`输出详细的选项列表。

其中`–prefix`选项是配置安装的路径，如果不配置该选项，安装后可执行文件默认放在`/usr/local/bin`，库文件默认放在`/usr/local/lib`，配置文件默认放在`/usr/local/etc`，其它的资源文件放在`/usr/local/share`，比较凌乱。

如果配置–prefix，如：
```sh
./configure --prefix=/usr/local/test
```
可以把所有资源文件放在`/usr/local/test`的路径中，不会杂乱。
```
./configure --prefix=/usr/local/test
make 编译（时间有点久）
make check 检测编译（时间有点久,一般可不选）
sudo make install 安装
xxx —version 检测是否安装成功
```


用了—prefix选项的另一个好处是卸载软件或移植软件。当某个安装的软件不再需要时，只须简单的删除该安装目录，就可以把软件卸载得干干净净；移植软件只需拷贝整个目录到另外一个机器即可（相同的操作系统）。

当然要卸载程序，也可以在原来的make目录下用一次`make uninstall`，但前提是make文件指定过uninstall。


### make check 效果(以protocol为例)
![wer](http://image.jk-kj.com/mweb/2020/12/28/16091222754950wer.png)
