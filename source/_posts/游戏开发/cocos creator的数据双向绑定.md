---
title: cocos creator的数据双向绑定
category: [游戏开发]
tags: [ cocos ]
date: 2020-12-15 12:15:01
---


### 背景
平常开发vue项目，有双向绑定，数据和展示是分离的，不需要关系什么时候去更新view
但cocos中，view是需要自己去更新。搜索很久终于发现了一篇博客

### 参考
[CocosCreator开发中为什么get/set如此重要](https://cloud.tencent.com/developer/news/447233#)

### 使用
以下是自己在ts中是实践
```ts
    // 对msgEnemy变量进行的动态绑定，先定义一个私有变量
    private _msgEnemy:msg.Enemy = null  // 此处msg.Enemy是一个protobuf结构

    @property
    get msgEnemy():msg.Enemy{
        //console.log('get msgEnemy')
        return this._msgEnemy;
    }
    set msgEnemy(value:msg.Enemy){//set:必须无返回值类型
        //console.log('set msgEnemy')
        this._msgEnemy=value;
        this.node.getChildByName('progressBar').getChildByName('maxHP').getComponent(cc.Label).string = this._msgEnemy.MaxHP.toString()
        this.node.getChildByName('progressBar').getChildByName('HP').getComponent(cc.Label).string = this._msgEnemy.HP.toString()
        this.node.getChildByName('progressBar').getChildByName('bar').width = Math.ceil(this._msgEnemy.HP/this._msgEnemy.MaxHP)*100
    }
```

当进行血量减少时
```ts
    subHP(val){
        this.msgEnemy = Object.assign(this.msgEnemy,{HP:this.msgEnemy.HP - val}); // 只有整个替换才会触发set
    }
```

### 结语

使用 get/set 的好处
灵活控制读写权限
为抽象做准备
数据可靠性
可以实现 MVVM