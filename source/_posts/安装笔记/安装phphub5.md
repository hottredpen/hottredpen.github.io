---
title: 安装phphub5
date: 2017-10-22 19:05:19
tags: 
     - laravel
---

#### 运行环境

Nginx 1.8+
PHP 5.6+
Mysql 5.7+
Redis 3.0+
Memcached 1.4+

#### 安装
~~~
git clone https://github.com/summerblue/phphub5.git
~~~

安装扩展包依赖
~~~
composer install
~~~

生成配置文件
~~~
cp .env.example .env
~~~

编辑env
选择数据库
数据库迁移
~~~
php artisan migrate

php artisan db:seed
~~~

