# ---
title: 使用GitHook同步跳坑笔记
category: [跳坑记录]
date: 2021-06-24 13:28:14
tags: 
    - git 
---

### 背景
同一台服务器内（git仓库和代码在同一台）,以前总是手动去更新代码，一直想用githook去同步，但想着这样直接更新线上代码不好，所以一直没去弄。

最近这台服务器渐渐变成了测试服务器，也就不存在直接更新代码的不好了，真想向svn那样直接看到效果。

所以弄一下git hook

没想到这也遇到了一些坑

### 参考

[使用 Git 同步部署代码（二） - Git Hook 同步](https://segmentfault.com/a/1190000018625437)

[Git error: “Host Key Verification Failed” when connecting to remote repository
](https://stackoverflow.com/questions/13363553/git-error-host-key-verification-failed-when-connecting-to-remote-repository)

### 为什么会入坑
1、一直用root账户使用服务器，但提交代码时，是以git身份更新
2、设置了git账户不能登录（当初配置的时候禁用了登录，所以不能收到具体的错误提示，一直在瞎猜）
3、设置目录的权限给了www

### 配置过程

git项目仓库在 hooks 目录下新建 post-update 文件，编辑完成后设置权限 chmod +x post-update， 文件如下
```
#!/bin/sh
unset GIT_DIR
DIR_ONE=/www/wwwroot/demo/  #正式目录
cd $DIR_ONE
git pull git_library master #新建项目 remote 默认是 origin
```

### 坑位
1、错误提示
```
remote: ------
remote: Host key verification failed.
remote: fatal: The remote end hung up unexpectedly
```
解决方法：
```
su git
// 接着到项目地址处，尝试执行
git pull origin master
// 会跳出是否允许 host的提示，选择yes

```
2、我的仓库地址,长这样（其实没什么问题，只是网络上的和我都不一样）
```
ssh://git@47.xx.xx.82:8080/home/git/data/company/xxx.git
```
3、错误提示2
```
error: insufficient permission for adding an object to repository database ./objects

[core]
fatal: failed to write object
error: 远程解包失败：unpack-objects abnormal exit
To ssh://47.xx.xx.82:8080/home/git/data/company/xxx.git
 ! [remote rejected] master -> master (n/a (unpacker error))
error: 推送一些引用到 'ssh://47.xx.xx.82:8080/home/git/data/company/xxx.git' 失败
```
解决方法:
因为项目目录的权限是www的。导致更新不了。
```
chown -R git:git ./xxxx
```


