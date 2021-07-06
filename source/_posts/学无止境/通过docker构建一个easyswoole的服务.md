---
title: 通过docker构建一个easyswoole的服务
category: [学无止境]
tags: [ docker ]
date: 2021-07-06 10:15:53
---

### 开始

新建easyswooletest目录，并在里面新建Dockerfile

Dockerfile
```
FROM centos:8

#version defined
ENV SWOOLE_VERSION 4.4.26
ENV EASYSWOOLE_VERSION 3.4.x

#install libs
RUN yum install -y curl zip unzip  wget openssl-devel gcc-c++ make autoconf git epel-release
RUN dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
#install php
RUN yum --enablerepo=remi install -y php74-php php74-php-devel php74-php-mbstring php74-php-json php74-php-simplexml php74-php-gd

RUN ln -s /opt/remi/php74/root/usr/bin/php /usr/bin/php \
    && ln -s /opt/remi/php74/root/usr/bin/phpize /usr/bin/phpize \
    && ln -s /opt/remi/php74/root/usr/bin/php-config /usr/bin/php-config

# composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer && chmod +x /usr/bin/composer
# use aliyun composer 由于最近阿里云镜像不稳定，废弃使用
# RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# swoole ext
RUN wget https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
    cd swoole \
    && phpize \
    && ./configure --enable-openssl \
    && make \
    && make install \
    ) \
    && sed -i "2i extension=swoole.so" /etc/opt/remi/php74/php.ini \
    && rm -r swoole

# Dir
WORKDIR /easyswoole
# install easyswoole
RUN cd /easyswoole \
    && composer require easyswoole/easyswoole=${EASYSWOOLE_VERSION} \
    && php vendor/easyswoole/easyswoole/bin/easyswoole install

EXPOSE 9501
```

以上面Dockerfile创建一个myeasyswooletest镜像
```
docker build -t myeasyswooletest .
```


安装完毕后,新建一个容器

```
docker run --name=mytest -ti -p 9501:9501 myeasyswooletest
```
-ti 启动容器后直接进入容器终端
-p 容器端口映射到外部端口


此时发现容器根目录中存在easyswoole项目目录，为了方便开发，需要做目录映射，由于直接映射会覆盖掉容器中对应目录的内容，需要在宿主机安装easyswoole再进行映射，因此这里先将容器中项目目录拷贝出来，再重新创建容器并映射目录

拷贝文件目录到宿主机中
```
docker cp {dockerId}:/easyswoole /www/wwwroot/myeasyswoolestest

```

关闭并删除容器
```
docker stop {dockerId}

docker rm {dockerId}
```

启动容器并映射目录
```
docker run -ti -p 9501:9501 --restart=always  -v /www/wwwroot/myeasyswooletest:/easyswoole myeasyswooletest7
```
-t:在新容器内指定一个伪终端或终端。

-i:允许你对容器内的标准输入 (STDIN) 进行交互。

-d:让容器在后台运行。

-P:将容器内部使用的网络端口映射到我们使用的主机上。

-p : 是容器内部端口绑定到指定的主机端口

-v：参数用于数据卷映射，/home/vpaas 是宿主机卷标，/usr/local/vpaas_file 是容器卷标

--name:  容器名称

vpaas:latest： 创建的镜像名

 

### 数据卷的作用：

docker 镜像启动的容器和宿主机可以看成两个不同的Linux系统，这两个文件系统之间传输文件就是用数据卷进行传输的。

宿主机将文件放入到 /home/vpaas 中，通过容器卷标  /usr/local/vpaas_file  就可以看到放入的文件，类似于文件夹共享。


### 进入容器
```
docker exec -it {dockerId} /bin/bash
```

在容器内安装---为了word转pdf
```
yum install -y libreoffice 
yum install -y unoconv
yum install -y ImageMagick
```

### 通过容器生成镜像
```
docker commit -m "安装word转pdf的依赖" {dockerId} newserver```
-m:提交的描述信息

-a: 指定镜像作者

e218edb10161：容器ID 

newserver:  指定要创建的目标镜像名


### 重新新建容器
```
docker run -ti -p 9501:9501 --restart=always  -v /www/wwwroot/myeasyswooletest:/easyswoole newserver
```

### 拷贝一个docx文件到容器内试试
```
docker cp /www/kkjj.docx {dockerId}:/www/
```

### 转换一下
```
soffice --headless --invisible --convert-to pdf kkjj.docx --outdir ./
```
发现有乱码（不支持中文）

### 将本地的中文字体放到一起，一起拷贝过去
```
docker cp /usr/share/fonts/chinese ae4c6f7a8b6d:/usr/share/fonts
```
中文可以显示了

### 将pdf转图片

```
convert  kkjj.pdf -resize 500% -quality 100 -sharpen 0x1.0 kkjj.png
```

### 将镜像发布出去
```
docker login
```

```
docker images
```

### 重命名镜像tag

```
docker tag 94998885c9d4 hottredpen/newserver
```
### 推送到自己的仓库
```
docker push hottredpen/newserver
```
