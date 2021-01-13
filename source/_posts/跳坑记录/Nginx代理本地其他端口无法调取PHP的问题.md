---
title: nginx代理无法执行PHP的问题
category: [跳坑记录]
date: 2021-01-13 09:21:14
tags: 
    - nginx
---


### 说明
因为客户特殊，只能给了80端口且不随便给开二级域名

主无服务，端口:80
```
server {
    listen 80;
    listen 443 ssl;
    server_name example.com;
    root /var/www/html;
    index index.php index.html;

    location  / {
        if ( !-e $request_filename ){
             rewrite ^(.*)$ /index.php?s=$1 last;
             break;
        }
    }

    ## 代理本地服务
    ## 问题出在这个位置（下文有正确的配置）
    location /proxy/ {  
        proxy_pass https://localhost:8144/;
    }   
    
    
    
    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /$document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
```
辅助服务,端口:8144
```
server {
    listen 8144;
    server_name localhost;
    root /var/www/tools;
    index index.php index.html;

    location  / {
        if ( !-e $request_filename ){
             rewrite ^(.*)$ /index.php?s=$1 last;
             break;
        }
    } 
    
    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /$document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
```

如上配置
会出现一下情况
- 1、静态资源能正常访问，如:example.com/proxy/test.txt
- 2、php文件，在example.com/test.php能访问，但是example.com/proxy/test.php会出现404
- 3、本地 curl example.com/proxy/test.php 能访问

也就是 通过nginx访问example.com/proxy/test.php时，实际没有走 代理。匹配到了下面的 location ~ \.php$ 了

通过查阅 nginx 的语法
```
= 开头表示精确匹配

^~ 开头表示uri以某个常规字符串开头，理解为匹配 url路径即可。nginx不对url做编码，因此请求为/static/20%/aa，可以被规则^~ /static/ /aa匹配到（注意是空格）。

~ 开头表示区分大小写的正则匹配

~*  开头表示不区分大小写的正则匹配

!~和!~*分别为区分大小写不匹配及不区分大小写不匹配 的正则

/ 通用匹配，任何请求都会匹配到。

多个location配置的情况下匹配顺序为（参考资料而来，还未实际验证）：

首先匹配 =，其次匹配^~, 其次是按文件中顺序的正则匹配，最后是交给 / 通用匹配。当有匹配成功时候，停止匹配，按当前匹配规则处理请求。
```

例子，有如下匹配规则：

```

location = / {精确匹配，必须是127.0.0.1/

 规则A

}

location = /login {精确匹配，必须是127.0.0.1/login

 规则B

}

location ^~ /static/ {非精确匹配，并且不区分大小写，比如127.0.0.1/static/js.

 规则C

}

location ~ \.(gif|jpg|png|js|css)$ {区分大小写，以gif,jpg,js结尾

 规则D

}

location ~* \.png$ {不区分大小写，匹配.png结尾的

 规则E

}

location !~ \.xhtml$ {区分大小写，匹配不已.xhtml结尾的

 规则F

}

location !~* \.xhtml$ {

 规则G

}

location / {什么都可以

规则H

}
```
那么产生的效果如下：

访问根目录/， 比如http://localhost/ 将匹配规则A

访问 http://localhost/login 将匹配规则B，http://localhost/register 则匹配规则H

访问 http://localhost/static/a.html 将匹配规则C

访问 http://localhost/a.gif, http://localhost/b.jpg 将匹配规则D和规则E，但是规则D顺序优先，规则E不起作用， 而 http://localhost/static/c.png 则优先匹配到 规则C

访问 http://localhost/a.PNG 则匹配规则E， 而不会匹配规则D，因为规则E不区分大小写。

访问 http://localhost/a.xhtml 不会匹配规则F和规则G，http://localhost/a.XHTML不会匹配规则G，因为不区分大小写。规则F，规则G属于排除法，符合匹配规则但是不会匹配到，所以想想看实际应用中哪里会用到。

访问 http://localhost/category/id/1111 则最终匹配到规则H，因为以上规则都不匹配，这个时候应该是nginx转发请求给后端应用服务器，比如FastCGI（php），tomcat（jsp），nginx作为方向代理服务器存在。


所以最上面的配置应该是
```
server {
    listen 80;
    listen 443 ssl;
    server_name example.com;
    root /var/www/html;
    index index.php index.html;

    location  / {
        if ( !-e $request_filename ){
             rewrite ^(.*)$ /index.php?s=$1 last;
             break;
        }
    }

    ## 代理本地服务
    ## 前面加上 ^~ 这样就不会将代理的php匹配到当前的php反向代理了
    location ^~ /proxy/ {  
        proxy_pass https://localhost:8144/;
    }   
    
    
    
    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /$document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
```

### 参考资料
[详解 nginx location ~ .*\.(js|css)?$ 什么意思？
](https://www.cnblogs.com/feiyuanxing/archive/2004/01/13/4668818.html)