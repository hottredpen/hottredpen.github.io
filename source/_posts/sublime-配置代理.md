---
title: sublime 配置代理
date: 2017-10-24 09:45:10
tags:
	- 代理
	- sublime
---


#### 背景

今天安装sublime插件时居然出现了，无法连接的错误
```
Package Control: Attempting to use Urllib downloader due to WinINet error: Error downloading channel. Connection refused (errno 12029) during HTTP write phase of downloading https://packagecontrol.io/channel_v3.json.
Package Control: Error downloading channel. URL error [WinError 10060] 由于连接方在一段时间后没有正确答复或连接的主机没有反应，连接尝试失败。 downloading https://packagecontrol.io/channel_v3.json.
```

查了一下，需要配置代理（前段时间都可以用的，今天就被墙了？好吧，我配置代理）

#### 配置代理

打开 `Preferences > Package Settings > Package Control > Settings - User 菜单``

添加两行:
~~~
"http_proxy": "http://127.0.0.1:1080",
"https_proxy": "http://127.0.0.1:1080"
~~~

127.0.0.1:1080为我本地的Shadowsocks代理地址