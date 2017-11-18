---
title: 使用hexo和github搭建blog
date: 2017-10-01 09:30:29
tags: 
     - hexo 
     - github
---


### 背景
继续用hexo

让自己专注于写作

### github准备

一、注册github账号并登录进入个人中心。

![](http://upload-images.jianshu.io/upload_images/1764427-b97c2df83796c007.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

二、点击Respositories，然后New,新建一个仓库，如下图，注意仓库名必须为 你的用户名.github.io，例如我的用户名imwillxue，仓库名为imwillxue.github.io。

![](http://upload-images.jianshu.io/upload_images/1764427-f8fa147884c7f4ec.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 本地git

一、创建blog文件名
```
    mkdir blog
    cd blog
    touch README.md
    git init
    git add README.md
    git commit -m "first commit"
    git remote add origin https://github.com/your-user-name/your-user-name.github.io.git
    git push -u origin master
```

二、本地建立一个博客源码分支
```
    在本地新建一个分支： 
        git branch hexo
    切换到你的新分支: 
        git checkout hexo
    将新分支发布在github上： 
        git push origin hexo
```

### Hexo创建

一、进入blog
```
npm install hexo
hexo init <folder>
如果指定 <folder>，便会在目前的资料夹建立一个名为 <folder> 的新资料夹；否则会在目前资料夹初始化。
npm install
npm install hexo-deployer-git
hexo g  生成网站
hexo s  启动本地服务器
```

网站会执行在http://localhost:port （port 预设为 4000，可在 _config.yml 设定）

###  Hexo和Github关联
```
1.  修改_config.yml中的deploy参数，分支应为master；
2.  hexo generate -deploy(可以简化为hexo g -d) 生成推送到github的master分支
此时访问your-user-name.github.io即可查看生成的站点内容
```

### Hexo源码备份
1.  进入本地的blog文件夹下
2.  git clone https://github.com/your-user-name/your-user-name.github.io.git
此时显示分支为hexo
3.  git add --all
4.  git commit -m "blog source commit"
5.  git push origin hexo
至此博客源代码就备份到了hexo分支上面。

### 后期维护以及博客更新

在本地对博客进行修改（添加新博文、修改样式等等）后，通过下面的流程进行管理。

    依次执行git add .、git commit -m "..."、git push origin hexo指令将改动推送到GitHub（此时当前分支应为hexo）；
    然后再执行hexo g -d发布网站到master分支上。
