---
title: Nginx代理webSocket经常中断
category: [跳坑记录]
date: 2021-01-26 12:55:14
tags: 
    - nginx
---
只要配置这几个参数就好
```
proxy_connect_timeout; 
proxy_read_timeout; 
proxy_send_timeout;
```

```
    location ^~ /websocket {
    	proxy_pass http://127.0.0.1:9002;
        proxy_redirect    off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_http_version 1.1;
        proxy_connect_timeout 4s; #配置点1
        proxy_read_timeout 600s; #配置点2，这段时间内没有任何发送也不断掉
        proxy_send_timeout 12s; #配置点3
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
```