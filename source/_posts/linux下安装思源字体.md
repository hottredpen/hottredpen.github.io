---
title: linux下安装思源字体
date: 2017-12-07 12:46:14
tags: 
    - linux
    - 字体
---

### 背景

客户想让他的网站都显示思源字体

### 参考
思源全套字体
https://pan.baidu.com/s/1uJBBK




### 下载字体

下载思源全套字体（字体文件名称：NotoSansHans）
```
https://pan.baidu.com/s/1uJBBK
```

windows的字体比较多，其字体文件位于 C:\WINDOWS\Fonts,如果想额外安装也可以到这里找找

字体格式有ttf和otf等多重后缀，linux上ttf和oft都可以

### 移动文件到服务器指定位置
```
# mkdir /usr/share/fonts/NotoSansHans
# cp arial*.otf /usr/share/fonts/NotoSansHans/
或
# cp arial*.ttf /usr/share/fonts/NotoSansHans/
```

### 为刚加入的字体设置缓存使之有效
```
# cd /usr/share/font/NotoSansHans
# fc-cache -fv
```

### 使用

因为我在windows里先安装了思源字体，并在`Noto Sans S Chinese`中找到了思源字体，所以font-family中我用`Noto Sans S Chinese`
```
body {
    font-family: "Noto Sans S Chinese", Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    color: #777777;
    font-size: 14px;
}
```



