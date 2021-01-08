# 

cocos creater 的protobuf接收和处理消息:

获取protobufjs
```
npm install protobufjs
```
找到下载的protobuf.js

path: /usr/local/lib/node_modules/protobufjs/dist

将protobuf.js拖到creator工程中并导入为插件


1.proto编译成静态文件:
把msg.proto 复制到client文件夹下,把proto文件编译成静态文件使用:
```
pbjs -t static-module -w commonjs -o msg.js msg.proto
pbts -o msg.d.ts msg.js
```

把msg.js 和msg.d.ts拷贝到cocos项目中的 assets\script\protocol文件夹中


