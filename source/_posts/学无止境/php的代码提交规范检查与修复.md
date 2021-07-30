---
title: php的代码提交规范检查与修复
category: [学无止境]
tags: [ php ]
date: 2021-07-29 15:27:53
---


代码提交规范检查与修复
开始之前，我们需要安装 Composer 依赖：

```
composer require squizlabs/php_codesniffer --dev
composer require brainmaestro/composer-git-hooks --dev
```


效果
`./vendor/bin/phpcs --standard=PSR1,PSR2 src`

```
FILE: /Users/my/github.com/xxx/src/Kernel/Helpers.php
-----------------------------------------------------------------------------
FOUND 1 ERROR AFFECTING 1 LINE
-----------------------------------------------------------------------------
 47 | ERROR | [x] Expected 1 newline at end of file; 0 found
-----------------------------------------------------------------------------
PHPCBF CAN FIX THE 1 MARKED SNIFF VIOLATIONS AUTOMATICALLY
-----------------------------------------------------------------------------

Time: 193ms; Memory: 8MB
```