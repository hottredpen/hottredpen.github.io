# 

[TOC]

### 定义结构体
// 在src/server/msg/lobby.proto下定义结构体
在script/protocol/lobby.proto下定义结构体
ChatREQ // 消息发送
ChatACK // 消息送达
```go
// 基础用户信息id头像昵称
message UserBaseInfo{
    string Uid = 1;
    string NickName = 2;
    string Avatar = 3;
}
// 消息体 
// 如 type=text  ContentJson={text:"你好"}
// 如 type=image  ContentJson={image:"xxx.png",height:100,width:100}
// 因为不同的type,ContentJson的结构不同，所以为字符串类型
message ChatMessage{
    string Type = 1;
    string ContentJson = 2;
}
// 消息发送
message ChatREQ {
	ChatMessage Message=1;
    uint32 ToId=2;
    string ToType=3;
}
// 消息送达
message ChatACK {
	UserBaseInfo From=1;
	ChatMessage  Message=2;
    uint32 ToId=3;
    string ToType=4;
}
```

### 生成**.pb.go
ps：需要本机有protobuf环境安装

```
protoc --proto_path=IMPORT_PATH --go_out=DST_DIR path/to/file.proto

```
目前我是放在当前目录下面的
在src/server/msg目录下执行
```
protoc --go_out=./ *.proto
```
如果是给php用的
```
protoc --php_out=./ *.proto

```

### 注册到消息处理器
src/server/msg/msg.go
```go
package msg

import (
	"github.com/name5566/leaf/network/protobuf"
)

// 使用 Protobuf 消息处理器
var Processor = protobuf.NewProcessor()

func init() {
	Processor.Register(&Test{})
	Processor.Register(&UserLogin{})
	Processor.Register(&UserRegister{})
	Processor.Register(&UserResult{})
	Processor.Register(&UserST{})
	Processor.Register(&ChatREQ{})
	Processor.Register(&ChatACK{})
}

```
### 在路由中监听ChatREQ
src/server/gate/router.go
```go
package gate

import (
	"server/game"
	"server/msg"
)

func init() {
	// 这里指定消息 路由到 game 模块
	msg.Processor.SetRouter(&msg.Test{}, game.ChanRPC)
	msg.Processor.SetRouter(&msg.UserLogin{}, game.ChanRPC)
	msg.Processor.SetRouter(&msg.UserRegister{}, game.ChanRPC)
	msg.Processor.SetRouter(&msg.ChatREQ{}, game.ChanRPC)
}

```
### 在handle中进行业务处理
src/server/game/internal/handler.go
```go
func init() {
	// 向当前模块（game 模块）注册 消息处理函数
	handler(&msg.Test{}, handleTest)
	handler(&msg.UserLogin{}, handleUserLogin)
	handler(&msg.UserRegister{}, handleUserRegister)
	handler(&msg.ChatREQ{}, handleChatREQ)
}
```
```go
func handleChatREQ(args []interface{}){
	m := args[0].(*msg.ChatREQ)
	a := args[1].(gate.Agent)
	log.Debug("receive GetMessage message:%v", m.GetMessage())

	myInfo := &msg.UserBaseInfo{
		Uid:"11",
		NickName:"张三",
		Avatar:"sss.png",
	}
	
	retBuf := &msg.ChatACK{
		From : myInfo,
		Message : m.GetMessage(),
		ToId : m.GetToId(),
		ToType : m.GetToType(),
	}
	// 给发送者回应一个 Test 消息
	a.WriteMsg(retBuf)
}
```

### 客户端用相同的lobby.proto去生成protocol.js
ps需客户端安装protobufjs
```
npm install -g protobufjs
```
在所在目录执行以下命令生成protocol.js
```
pbjs -t static-module -w commonjs -o protocol.js lobby.proto
```

修改文件内的
```
// var $protobuf = require("protobufjs/minimal");
var $protobuf = window.protobuf;
```

把protocol.js转成ts的
```
pbts -o protocol.d.ts protocol.js
```

### 客户端发送消息
```ts
        messageservice.ready(()=>{
            messageservice.sendChatTest()
        })
```
```ts
    public sendChatTest(){
        console.log('=====sendChatTest')
        this._sendBuffMsg('ChatREQ',{Message:{'Type':'text','ContentJson':'{text:"laiba"}'},ToId:123,ToType:"chat"})
    }
```
```ts
    // 对接 leaf 的发送
    private _sendBuffMsg(proName:string,data:{}){
        let msgid = WebsocketService.ProtocolId[proName]
        let message = msg[proName].create(data); 
        let buffer  = msg[proName].encode(message).finish();
        //leaf 前两位为协议序号，故需包装一下
        let addtag_buffer = WebsocketService.protoBufAddtag(msgid,buffer);
        this.ws.send(addtag_buffer)
    }
```

### 客户端接受消息
```ts
export class WebsocketService {

    public ws:WebSocket

    static ProtocolId={
        Test:0,
        ChatREQ:5,
        ChatACK:6,
        // TestEchoACK:1234,// protocol/test 内的demo
    }

    private offline_callback_arr:Array<Function>;

    constructor() {
        this.offline_callback_arr = []
        this.init();
    }
    /**
     * 初始化参数
     */
    private init() {
        let self = this
        let ws = new WebSocket("ws://x.x.x.x:3653");
        this.ws = ws
        ws.binaryType = "arraybuffer";

        ws.onopen = (evt) => {
            console.log("Connection open ...");
            if(this.offline_callback_arr.length > 0){
                this.offline_callback_arr.forEach( callback => {
                    console.log('发送离线时的事件')
                    callback()
                })
                this.offline_callback_arr = []
            }
        };

        ws.onmessage = function(evt) {

            if (evt.data instanceof ArrayBuffer ){
                // leaf的解析
                // leaf 前两位为协议序号，需要解一下啊协议序号
                let retdata = WebsocketService.parseProtoBufId(evt);  
                let id = retdata.id;
                let data = retdata.data;
                self.dealMessage(id,data);

            }else{
                console.log("Require array buffer format")
            }

        };

        ws.onclose = function(evt) {
            console.log("Connection closed.");
        };

    }
```
```ts
    dealMessage(id: number,data: Uint8Array ){
        switch(id){
            case WebsocketService.ProtocolId.Test:
                this.dealTest(data)
                break;
            case WebsocketService.ProtocolId.ChatACK:
                this.dealChatACK(data)
                break;
            default:
                break;
        }
    }
    dealChatACK(data: Uint8Array){
        console.log("get ChatACK message!");
        let message = msg.ChatACK.decode(data);
        console.log(message);
    }
```
### 效果
![1111](http://image.jk-kj.com/mweb/2021/01/21/161121787608371111.jpg)
