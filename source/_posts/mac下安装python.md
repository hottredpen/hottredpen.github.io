---
title: mac下安装python
date: 2017-10-07 16:29:03
tags: 
     - 安装
     - python
     - mac
---

知乎上说，不要在mac自带的python里折腾，怕折腾蹦了影响系统

用brew 安装，且自带pip

### 安装python2 & python3

```
brew install python
```
```
brew install python3
```
```
This formula installs a python2 executable to /usr/local/bin.
If you wish to have this formula's python executable in your PATH then add
the following to ~/.zshrc:
  export PATH="/usr/local/opt/python/libexec/bin:$PATH"

  Pip and setuptools have been installed. To update them
    pip2 install --upgrade pip setuptools

    You can install Python packages with
      pip2 install <package>

      They will install into the site-package directory
        /usr/local/lib/python2.7/site-packages

	See: https://docs.brew.sh/Homebrew-and-Python.html
```

#### 设置PATH
vim ~/.zshrc 加入
`export PATH="/usr/local/opt/python/libexec/bin:$PATH"`


#### 验证PATH设置成功

输入`which python`
如果显示 `/usr/local/opt/python/libexec/bin/python`则说明成功

#### 如何使用系统的python

如果有需要想使用一下系统的Python，输入`/usr/bin/python`即可
