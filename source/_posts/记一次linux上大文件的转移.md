---
title: 记一次linux上大文件的转移
date: 2017-12-13 12:43:08
tags: 
    - linux 
    - scp
---


### 背景

服务器的内容转到另一台服务器

### 过程

#### 1、首先进行了打包
```
tar -cvf ./kod.tar ./kod3.1
```
打完包，发现有3个多G
就尝试打包压缩
```
tar -zcvf ./kod2.tar.gz ./kod3.1
```
结果还是3G多，只压缩了200M


#### 2、进行传输
```
scp ./kod.tar root@192.168.60.168:/tmp
```

开始有5M/s的速度，可慢慢地变得只有800K/s
最气人的是在60%时的时候居然出现了`stalled`

#### 3、排查问题

```


When transferring large files(for example mksysb images) using scp through a firewall, the scp connection stalls.
Cause:

The reason for scp to stall, is because scp greedily grabs as much bandwith of the network as possible when it transfers files, any delay caused by the network switch of the firewall can easily make the TCP connection stalled.
Solution:

There’s a solution to this problem: Add “-l 8192″ to the scp command.

Adding the option “-l 8192″ limits the scp session bandwith up to 8192 Kbit/second, which seems to work safe and fast enough (up to 1 MB/second):

```

#### 4、解决问题
在原有的命令行上加上了` -l 8192 `
```
scp -l 8192 ./kod.tar root@192.168.60.168:/tmp
```
开始速度也有6M/s，后面速度一直维持在1M/s，中间无`stalled`