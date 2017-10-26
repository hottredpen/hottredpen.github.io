---
title: vue选项数据
date: 2017-10-27 06:47:41
tags:
	- vue2
---



### data

初级理解：对象必须是纯粹的对象(含有零个或多个的key/value对)，这里面的数据最好都是在视图层显示的数据（静态变量）
中级理解：
高级理解：

其他：
如果说不是在视图层展示的变量。可以定义在外面或者放在vm对象上。

```
    let abc = ''  
    export default {  
        data() {  
            return {  
                bar: 'bar'  
            }  
        },  
        methods: {  
            testFn() {  
                // abc  
            }  
        }  
    }  
```

### props

初级理解：props 可以是数组或对象，用于接收来自父组件的数据。
中级理解：组件实例的作用域是孤立的。这意味着不能 (也不应该) 在子组件的模板内直接引用父组件的数据。父组件的数据需要通过 prop 才能下发到子组件中。
高级理解：

其他：

子组件要显式地用 props 选项声明它预期的数据：
```
Vue.component('child', {
  // 声明 props
  props: ['message'],
  // 就像 data 一样，prop 也可以在模板中使用
  // 同样也可以在 vm 实例中通过 this.message 来使用
  template: '<span>{{ message }}</span>'
})
```
然后我们可以这样向它传入一个普通字符串：
```
<child message="hello!"></child>
```
结果：
```
hello!
```

### propsData

简单理解:创建实例时传递 props。主要作用是方便测试。(无父级时)


### computed
简单理解：computed，计算属性将被混入到 Vue 实例中。所有 getter 和 setter 的 this 上下文自动地绑定为 Vue 实例。不过计算属性也用函数来替代。（动态变量）


### methods
 methods 将被混入到 Vue 实例中。可以直接通过 VM 实例访问这些方法，或者在指令表达式中使用。方法中的 this 自动绑定为 Vue 实例。

