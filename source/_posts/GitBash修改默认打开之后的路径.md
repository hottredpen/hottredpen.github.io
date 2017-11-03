---
title: GitBash修改默认打开之后的路径
date: 2017-11-03 08:58:26
tags:
    - git
---

#### 背景

在公司windows下用gitbash，每次打开都要切换到D盘指定目录，非常费时，网上搜了一下果真有对应方法

#### 参考

http://blog.csdn.net/zzfenglin/article/details/54646541

#### 实现方法

在“Git Bash”快捷方式上点击鼠标右键，然后选择“属性”，会弹出如下截图的提示框：

<img src="http://img.blog.csdn.net/20170121165353158">

我们可以看到在“目标”后面的输入框中有操作的命令，在命令的最后是“--cd-to-home”，就是这条命令在快捷方式打开的时候切换到“/c/Users/Administrator”路径了。

 

假如，我们想把默认路径修改为“D:\android_workspace”，那我们需要操作两步：

1.将“目录”后面输入框中命令结尾部分去掉，即删掉“--cd-to-home”。

2.将“起始位置”后面的输入框中的内容修改为我们想要的默认路径“D:\android_workspace”（注意：这个路径是根据你自己代码工程的位置而定的）

修改之后的操作截图如下：

<img src="http://img.blog.csdn.net/20170121165423783">

修改之后，点击“确定”，然后重新打开“Git Bash”，就会自动切换到我们想要的路径