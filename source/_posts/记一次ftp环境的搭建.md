---
title: 记一次ftp环境的搭建
date: 2019-04-24 13:59:27
tags: ftp vsftp
---


### 背景
给客户的服务器上安装ftp环境

### 参考链接
Linux下如何进行FTP设置:vsftp
https://www.cnblogs.com/eagling/articles/4848669.html 
FTP主动模式和被动模式的区别
https://www.cnblogs.com/dancheblog/p/3799448.html
Linux Vsftpd 连接超时解决方法（被动模式）
https://blog.51cto.com/5468755/1594648

### 配置过程
vsftpd安装，执行以下命令： 

```
yum -y install vsftpd
```

我们选择了“vsftp配置虚拟用户”
使用vsftpd虚拟用户登录FTP服务器进行常见的操作。
首先安装FTP 虚拟用户需要用到的软件及认证模块
```
yum  install  pam*  libdb-utils libdb* –skip-broken  –y （Centos7）

yum install db4* -y （Centos6）
```
编辑`vim /etc/vsftpd/ftpusers.txt`
```
user001
user001
```
第一行为FTP虚拟用户，登录用户名，第二行为密码，第三行为用户名，依次类推。

创建并生成vsftpd数据库文件，生成数据库文件命令：

```
db_load -T -t hash -f /etc/vsftpd/ftpusers.txt /etc/vsftpd/vsftpd_login.db

chmod 700 /etc/vsftpd/vsftpd_login.db
```
配置PAM验证文件：

在配置文件vi  /etc/pam.d/vsftpd 行首加入如下两行认证语句：（如果是32位，lib64需改成lib，如果RedHat，加入的语句不一样，需注意）
```
auth        sufficient      /lib64/security/pam_userdb.so     db=/etc/vsftpd/vsftpd_login

account     sufficient      /lib64/security/pam_userdb.so     db=/etc/vsftpd/vsftpd_login
```
创建vsftpd映射本地用户：

所有的FTP虚拟用户需要使用一个系统用户，这个系统用户不需要密码，也不需要登录。主要用来做虚拟用户映射使用。

```
useradd -s /sbin/nologin ftpuser
```
修改vsftpd.conf配置文件：
```
anonymous_enable=NO

local_enable=YES

write_enable=YES

local_umask=022

dirmessage_enable=YES

xferlog_enable=YES

connect_from_port_20=YES

xferlog_file=/var/log/vsftpd.log

xferlog_std_format=YES

ascii_upload_enable=YES

ascii_download_enable=YES

listen=YES

guest_enable=YES

guest_username=ftpuser

pam_service_name=vsftpd

user_config_dir=/etc/vsftpd/vsftpd_user_conf


```
保存重启,service  vsftpd restart 即可使用虚拟用户登录，这时候所有的虚拟用户共同使用/home/ftpuser目录上传下载，如果想使用自己独立的目录，可以在/etc/vsftpd/vsftpd_user_conf目录创建各自的配置文件，如给admin创建独立的配置文件：
```
mkdir -p /etc/vsftpd/vsftpd_user_conf

vim  /etc/vsftpd/vsftpd_user_conf/user001，内容如下，建立自己的FTP目录。

local_root=/home/ftpuser/user001

write_enable=YES

anon_world_readable_only=YES

anon_upload_enable=YES

anon_mkdir_write_enable=YES

anon_other_write_enable=YES
```

以上内容是参照其他博文做的，到这个时候，我以为已经大功告成，结果
结果出现各种
500 Illegal PORT command
227 Entering Passive Mode...

一大堆问题，总之引出了 “主动和被动的问题”

看了半天，主动和被动的关系，决定采用“主动模式”（开始入坑）
当初为什么选主动，因为博文里说了主动，服务器安全些。而且在配置21端口和20端口的时候，移动云的虚拟防火墙把我坑了一把。
可是无论我怎么配，都搞不定。。。登录成功目录出不来

在最后发现了第三篇博文，被动模式（本想直接跳过去的，但看见他报的错误和我一模一样，抱着转被动试试看）

1,vi /etc/vsftpd/vsftpd.conf
```
pasv_enable=YES
pasv_min_port=61001    (注意端口和客户端的保持一致)
pasv_max_port=62000
anon_max_rate=1000000
local_max_rate=2000000
max_clients=10
max_per_ip=100
```
2、加载内核 ip_conntrack_ftp 和 ip_nat_ftp（终端执行）

modprobe ip_conntrack_ftp
modprobe ip_nat_ftp

3.配置 iptables 开放 61001 到 62000 端口

vi /etc/sysconfig/iptables  在*filter下加入下


-A OUTPUT -p tcp --sport 61001:62000 -j ACCEPT
-A INPUT -p tcp --dport 61001:62000 -j ACCEPT









### 过程遇到的坑

1、坑1---移动运的虚拟
21端口  在安全组里加了 没在虚拟防火墙中配置

2、坑2---主动模式的选择

3、坑3--- -A OUTPUT -p tcp --sport 61001:62000 -j ACCEPT 没有配置
