---
title: vue选项生命周期钩子
date: 2017-10-27 13:45:00
tags:
    - vue2
---

### 生命周期钩子

所有的生命周期钩子自动绑定 this 上下文到实例中，因此你可以访问数据，对属性和方法进行运算。这意味着 你不能使用箭头函数来定义一个生命周期方法 (例如 created: () => this.fetchTodos())。这是因为箭头函数绑定了父上下文，因此 this 与你期待的 Vue 实例不同，this.fetchTodos 的行为未定义。
<img src="https://cn.vuejs.org/images/lifecycle.png">

#### beforeCreate

    类型：Function

在实例初始化之后，数据观测 (data observer) 和 event/watcher 事件配置之前被调用。

#### created

类型：Function

在实例创建完成后被立即调用。在这一步，实例已完成以下的配置：数据观测 (data observer)，属性和方法的运算，watch/event 事件回调。然而，挂载阶段还没开始，$el 属性目前不可见。

#### beforeMount

类型：Function

详细：

在挂载开始之前被调用：相关的 render 函数首次被调用。
该钩子在服务器端渲染期间不被调用。

#### mounted

类型：Function

详细：

el 被新创建的 vm.$el 替换，并挂载到实例上去之后调用该钩子。如果 root 实例挂载了一个文档内元素，当 mounted 被调用时 vm.$el 也在文档内。

注意 mounted 不会承诺所有的子组件也都一起被挂载。如果你希望等到整个视图都渲染完毕，可以用 vm.$nextTick 替换掉 mounted：
```
mounted: function () {
      this.$nextTick(function () {
        // Code that will run only after the
        // entire view has been rendered
      })
    }
```
该钩子在服务器端渲染期间不被调用。
```
    mounted () {
        this.$nextTick(() => {
            var dataComeinBar = echarts.init(document.getElementById('data_comein_bar'));

            var option = {
                ......
            };

            dataComeinBar.setOption(option);
            window.addEventListener('resize', function () {
                dataComeinBar.resize();
            });
        });
    }
```


#### beforeUpdate

类型：Function

详细：

数据更新时调用，发生在虚拟 DOM 重新渲染和打补丁之前。

你可以在这个钩子中进一步地更改状态，这不会触发附加的重渲染过程。

该钩子在服务器端渲染期间不被调用。

#### updated

类型：Function

详细：

由于数据更改导致的虚拟 DOM 重新渲染和打补丁，在这之后会调用该钩子。

当这个钩子被调用时，组件 DOM 已经更新，所以你现在可以执行依赖于 DOM 的操作。然而在大多数情况下，你应该避免在此期间更改状态。如果要相应状态改变，通常最好使用计算属性或 watcher 取而代之。

注意 updated 不会承诺所有的子组件也都一起被重绘。如果你希望等到整个视图都重绘完毕，可以用 vm.$nextTick 替换掉 updated：
```
    updated: function () {
      this.$nextTick(function () {
        // Code that will run only after the
        // entire view has been re-rendered
      })
    }
```
该钩子在服务器端渲染期间不被调用。

#### activated

类型：Function

详细：

keep-alive 组件激活时调用。

该钩子在服务器端渲染期间不被调用。

#### deactivated

类型：Function

详细：

keep-alive 组件停用时调用。

该钩子在服务器端渲染期间不被调用。

#### beforeDestroy

类型：Function

详细：

实例销毁之前调用。在这一步，实例仍然完全可用。

该钩子在服务器端渲染期间不被调用。

#### destroyed

类型：Function

详细：

Vue 实例销毁后调用。调用后，Vue 实例指示的所有东西都会解绑定，所有的事件监听器会被移除，所有的子实例也会被销毁。

该钩子在服务器端渲染期间不被调用。

#### errorCaptured

2.5.0+ 新增

类型：(err: Error, vm: Component, info: string) => ?boolean

详细：

当捕获一个来自子孙组件的错误时被调用。此钩子会收到三个参数：错误对象、发生错误的组件实例以及一个包含错误来源信息的字符串。此钩子可以返回 false 以阻止该错误继续向上传播。