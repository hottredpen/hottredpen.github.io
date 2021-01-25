# 

目前只能是客户端 为经过压缩的发送 json数据给后端，因为easayswoole 的 swoole_websocket_frame $frame
会根据长度进行裁剪

比如客户端发送二进制
```
Uint8Array(27) [0, 5, 10, 15, 10, 4, 116, 101, 120, 116, 18, 7, 115, 115, 115, 115, 115, 115, 115, 16, 123, 26, 4, 99, 104, 97, 116]
上面待办的文字是以下字符串的压缩
{"Message":{"Type":"text","ContentJson":"sssssss"},"ToId":123,"ToType":"chat"}
```
通过
swoole_websocket_frame后被裁剪成
```
object(Swoole\WebSocket\Frame)#186 (4) {
  ["fd"]=>
  int(1)
  ["data"]=>
  string(27) "

textsssssss{chat"
  ["opcode"]=>
  int(2)
  ["finish"]=>
  bool(true)
}
```
但是这个27是转换成字符串的长度