---
title: elementui引入iconfont
date: 2017-11-10 15:58:02
tags:
    - elementui
    - iconfont
---


### 背景

element官方的icon太少

### 参考

http://blog.csdn.net/b376924098/article/details/78286880#reply

CSS3 @font-face [http://www.w3cplus.com/content/css3-font-face]

### 过程

 - 去阿里巴巴矢量图，地址;http://www.iconfont.cn/
 - 进入网站登录账户后，新建一个项目
 - 选择一些自己要用到的图标如上图点击购物车按钮添加到购物车。


 <img src="http://img.blog.csdn.net/20171019170321456?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvYjM3NjkyNDA5OA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center">

 - 保存时，以yourprogect-icon命名
 - 并命名一个自己的字体名称，jkkjFontFamily
 - 在iconfont.css添加以下代码
```
[class^="jkkj-icon"], [class*=" jkkj-icon"] {
  font-family:"jkkjFontFamily" !important;
  /* 以下内容参照第三方图标库本身的规则 */
  font-size: 18px;
  font-style:normal;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```
效果类似于下图
<img src="http://img.blog.csdn.net/20171019171813100?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvYjM3NjkyNDA5OA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center">