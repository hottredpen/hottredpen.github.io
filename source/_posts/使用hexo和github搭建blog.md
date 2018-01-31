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

二、点击Respositories，然后New,新建一个仓库，如下图，注意仓库名必须为 
```
<your-name>.github.io
```
例如我的用户名hottredpen，仓库名为
```
hottredpen.github.io。
```
注意:如果此处不注意看，后面都白搭

![](http://upload-images.jianshu.io/upload_images/1764427-f8fa147884c7f4ec.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 本地git

一、创建blog_tmp文件名(临时用)
```
    mkdir blog_tmp
    cd blog_tmp
    touch README.md
    git init
    git add README.md
    git commit -m "first commit"
    git remote add origin https://github.com/your-name/your-name.github.io.git
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

#### 一、全局安装hexo
只有全局安装了才能用hexo命令
```
npm install hexo -g
```

#### 二、初始化一个项目blog（正式）

```
hexo init blog
npm install
npm install hexo-deployer-git
hexo g  生成网站
hexo s  启动本地服务器
```

网站会执行在http://localhost:port （port 预设为 4000，可在 _config.yml 设定）
### 尝试写一篇博客
```
hexo new 'test'
```
随便写点啥,然后运行
```
hexo g 
hexo s
```

###  Hexo和Github关联

#### 一、将blog_tmp下的git的仓库转移到blog下
```
cd blog_tmp 
mv .git ../blog
```
进入blog目录
```
cd blog
```

#### 二、确保现在所处hexo分支
```
git branch
```
可以看到现在在hexo分支（如果没有请自行切换成hexo分支）
查看状态
```
git status
```
会发现许多红的的未添加文件

#### 二、将博客源码推送到git的hexo分支上

```
git add .
git commit -m "init"
git push origin hexo
```

#### 三、配置hexo博客的推送git地址

1.  修改_config.yml中的deploy参数；
```
deploy:
  type: git
  repo: https://github.com/your-name/your-name.github.io.git
  branch: master
```

`ps:冒号后面有个空格`

2.  推送到github的master分支
```
hexo g -d
```
或者
```
hexo generate -deploy
```

此时访问your-name.github.io即可查看生成的站点内容


### 后期维护以及博客更新

在本地对博客进行修改（添加新博文、修改样式等等）后，通过下面的流程进行管理。

依次执行
```
hexo new "新博客"
git status
git add .
git commit -m "..."
git push origin hexo
```
然后再执行
```
hexo g -d
```
发布网站到master分支上。
