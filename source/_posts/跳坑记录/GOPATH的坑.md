---
title: GOPATH的坑
category: [跳坑记录]
date: 2020-12-29 16:52:14
tags: 
    - go
---

首先使用go env查看当前环境变量，新手入门出现找不到包的情况大多是环境环境的问题。只需要关注GOROOT和GOPATH即可。

- GOROOT：简单来说就是GO的安装目录，这个影响不大。
- GOPATH：表示GO的工作目录，出现找不到包的情况大概率就是这里出了问题。

![112233](http://image.jk-kj.com/mweb/2021/01/08/16100732082162112233.png)

Golang 的代码必须放置在一个 workspace 中。一个 workspace 是一个目录，此目录中包含几个子目录：

- src 目录。包含源文件，源文件被组织为包（一个目录一个包）
- pkg 目录。包含包目标文件（package objects）
- bin 目录。包含可执行的命令

包源文件（package source）被编译为包目标文件（package object），命令源文件（command source）被编译为可执行命令（command executable）。使用 go 命令进行构建生成的包目标文件位于 pkg 目录中，生成的可执行命令位于 bin 目录中。开发 Golang 需要设置一个环境变量 GOPATH，此环境变量用于指定 workspace 的路径，另外，也可以把 workspace 的 bin 目录加入到 PATH 环境变量中去。

一般一些临时的go项目，我们会 临时用如下,进行添加
```
export GOPATH=$GOPATH:/Users/xxxx/go/leafserver
```