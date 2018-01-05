---
title: 记一次linux上大文件的转移
date: 2017-12-13 12:43:08
tags: 
    - linux 
    - scp
    - rsync
    - 打包
    - 断点续传
---


### 背景

服务器的内容转到另一台服务器

### 过程

#### 首先进行了打包
```
tar -cvf ./kod.tar ./kod3.1
```
打完包，发现有3个多G
就尝试打包压缩
```
tar -zcvf ./kod2.tar.gz ./kod3.1
```
结果还是3G多，只压缩了200M


#### 进行传输
```
scp ./kod.tar root@192.168.60.168:/tmp
```

开始有5M/s的速度，可慢慢地变得只有800K/s
最气人的是在60%时的时候居然出现了`stalled`

#### 排查问题

```


When transferring large files(for example mksysb images) using scp through a firewall, the scp connection stalls.
Cause:

The reason for scp to stall, is because scp greedily grabs as much bandwith of the network as possible when it transfers files, any delay caused by the network switch of the firewall can easily make the TCP connection stalled.
Solution:

There’s a solution to this problem: Add “-l 8192″ to the scp command.

Adding the option “-l 8192″ limits the scp session bandwith up to 8192 Kbit/second, which seems to work safe and fast enough (up to 1 MB/second):

```

#### 解决问题
在原有的命令行上加上了` -l 8192 `可以维持在1M/s
```
scp -l 8192 ./kod.tar root@192.168.60.168:/tmp
```

开始速度也有6M/s，后面速度一直维持在1M/s，中间无`stalled`


如果是` -l 16000 `则维持在2M/s，以此类推

#### 解压
```
tar -xvf kod.tar
```
或者
```
tar -zxvf kod.tar.gz
```


#### 补充
因为转移的文件有很多，而且都很大，我们不可能一直开者等待它传完，这就需要后台运行

先输入密码进行传输
然后用`ctrl+z`,将当前进程挂起到后台暂停运行，执行一些别的操作
然后用 `bg` 来将挂起的进程放在后台(也可以用 `fg` 来将挂起的进程重新放回前台)继续运行
```
[root@pvcent107 build]# scp -l 8192 ./kod.tar root@192.168.60.168:/tmp
---------ctrl+zx
[1]+  Stopped                 scp -l 8192 ./kod.tar root@192.168.60.168:/tmp
[root@pvcent107 build]# bg %1
[1]+ scp -l 8192 ./kod.tar root@192.168.60.168:/tmp &
[root@pvcent107 build]# jobs
[1]+  Running                 scp -l 8192 ./kod.tar root@192.168.60.168:/tmp &
[root@pvcent107 build]# disown -h %1
[root@pvcent107 build]# ps -ef |grep kod
root      5790  5577  1 10:04 pts/3    00:00:00 scp -l 8192 ./kod.tar root@192.168.60.168:/tmp
root      5824  5577  0 10:05 pts/3    00:00:00 grep kod
```

#### 注意
有时jobs会有多个，注意自己的文件大小是否正常，我就别坑了1次，没传输完成（完成了一个jobs），以为完成了就进行解压缩了。

#### 400G个文件打包

之前想着。。。400G的文件需要切分-，-！可是用了切分时，却始终没有获取完整的包，好几次我都相信我的总包才80G

最后用了整包打包
```
nohup tar -cjf kod.tar.bz2 ./kod >/dev/null 2>&1 &
```
打完包发现才有400G+.......我的天，整整打包了一天一夜

#### 400G的传输
scp 已经无法满足，因为万一中间来个服务器重启，或者其他因素那over了，那流量可就白白流失了
最后采用了`rsync`
```
rsync -P --rsh=ssh ./kod_all.tar.bz2 112.13.14.156:/data/ 
```
然后输入密码
再ctrl+z 暂停
再bg %1  放入后台（假设当前后台允许索引为1）
然后用jobs查看
如果你当前退出过当前终端，jobs已经无法查看到后台运行的进程，只能用ps
```
ps -ef |grep kod
```
会有如下的显示
```
root     175100 174758 47 08:10 pts/2    00:15:13 rsync -P --rsh=ssh ./kod_all.tar.bz2 112.13.91.176:/data/
root     183245 174758  0 08:42 pts/2    00:00:00 grep --color=auto kod
```

其中`00:15:13`指本次断点续传进行的时间。
当传输了200G以后，继续进行断点续传，这个时间会有好长一段时间是不更新的（作者认为它在寻找上一次的断点，因为文件大了寻找的时间会久一点），如果你这个时候马上关闭总端，很有可能本次传输就没执行，我就被坑了一次，一觉醒来一点就没传。。。

#### rsync与scp的差异
用scp时，这边传多少，另一个服务器就显示文件实时大小
而用rsync时，另一个服务器不实时显示文件大小，只有将这边的进程暂时kill掉，才能知道到底传了多少（可能我这个办法比较粗暴）
```
kill -9 175100
```

#### 400G的解压
```
nohup tar -xjf ./kod_all.tar.bz2 > /dev/null 2>&1 &
```
其他查看操作同上面

### 其他，拆分打包（失败了）

```
nohup tar -cjf - kod/ |split -b 10000m - kod.tar.bz2. >/dev/null 2>&1 &
```
它会生成
```
-rw-r--r-- 1 Administrator 197121   5242880 十二 27 08:39 kod.tar.bz2.aa
-rw-r--r-- 1 Administrator 197121   5242880 十二 27 08:39 kod.tar.bz2.ab
-rw-r--r-- 1 Administrator 197121   5242880 十二 27 08:39 kod.tar.bz2.ac
-rw-r--r-- 1 Administrator 197121   5242880 十二 27 08:39 kod.tar.bz2.ad
-rw-r--r-- 1 Administrator 197121   5242880 十二 27 08:39 kod.tar.bz2.ae
-rw-r--r-- 1 Administrator 197121   5242880 十二 27 08:39 kod.tar.bz2.af
-rw-r--r-- 1 Administrator 197121   5242880 十二 27 08:39 kod.tar.bz2.ag
```
后面默认2位，字符逐渐增加
它的解压
```
nohup cat pinkephp.tar.bz2.* | tar -xj &
```

### 参考

https://linux.cn/article-7170-1.html

http://blog.csdn.net/tdstds/article/details/24870535

http://blog.csdn.net/eroswang/article/details/5555415/