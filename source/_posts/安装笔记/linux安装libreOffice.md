---
title: centos6安装libreOffice
date: 2021-07-02 13:31:21
tags: 
    - centos
---

下载:

访问 https://www.libreoffice.org/download/download/
选择 Linux x86_64(rpm) 的版本
下载得到 LibreOffice_7.0.6_Linux_x86-64_rpm.tar.gz (目前最新版为 7.0.6)
安装:

删除: 在安装之前，先删除已经安装的 LibreOffice: 
```
yum remove libreoffice*
```
解压: 
```
tar -xvf LibreOffice_7.0.6_Linux_x86-64_rpm.tar.gz
```
安装:
```
cd LibreOffice_7.0.6_Linux_x86-64_rpm/RPMS
yum localinstall *.rpm
```
查看:
`which libreoffice7.0` 看到路径为 `/usr/bin/libreoffice7.0`
`ll /usr/bin/libreoffice7.0` 得到 `/opt/libreoffice7.0/program/soffice`，说明安装到了 `/opt/libreoffice7.0`
依赖:
执行下面几条命令安装需要的库:
```
yum install cairo -y
yum install cups-libs -y
yum install libSM -y
```