---
title: vue指令
date: 2017-10-27 08:16:58
tags:
    - vue2
---


#### v-text
预期：string

更新元素的 textContent。如果要更新部分的 textContent ，需要使用 {{ Mustache }} 插值。

```
<span v-text="msg"></span>
<!-- 和下面的一样 -->
<span>{{msg}}</span>
```

#### v-html
预期：string

更新元素的 innerHTML 。注意：内容按普通 HTML 插入 - 不会作为 Vue 模板进行编译 。如果试图使用 v-html 组合模板，可以重新考虑是否通过使用组件来替代。

在网站上动态渲染任意 HTML 是非常危险的，因为容易导致 XSS 攻击。只在可信内容上使用 v-html，永不用在用户提交的内容上。

```
<div v-html="html"></div>
```

#### v-show
预期：any


不同的是带有 v-show 的元素始终会被渲染并保留在 DOM 中。v-show 只是简单地切换元素的 CSS 属性 display。
```
<h1 v-show="ok">Hello!</h1>
```

#### v-if
预期：any

#### v-else

#### v-else-if
预期：any

```
<div v-if="Math.random() > 0.5">
  Now you see me
</div>
<div v-else>
  Now you don't
</div>
```

```
<div v-if="type === 'A'">
  A
</div>
<div v-else-if="type === 'B'">
  B
</div>
<div v-else-if="type === 'C'">
  C
</div>
<div v-else>
  Not A/B/C
</div>
```


#### v-for
预期：Array | Object | number | string

基于源数据多次渲染元素或模板块。此指令之值，必须使用特定语法 alias in expression ，为当前遍历的元素提供别名：

```
<div v-for="item in items">
  {{ item.text }}
</div>
```

另外也可以为数组索引指定别名 (或者用于对象的键)：

```
<div v-for="(item, index) in items"></div>
<div v-for="(val, key) in object"></div>
<div v-for="(val, key, index) in object"></div>
```

#### v-on

缩写：@    【注意可缩写】

修饰符：

    .stop - 调用 event.stopPropagation()。
    .prevent - 调用 event.preventDefault()。
    .capture - 添加事件侦听器时使用 capture 模式。
    .self - 只当事件是从侦听器绑定的元素本身触发时才触发回调。
    .{keyCode | keyAlias} - 只当事件是从特定键触发时才触发回调。
    .native - 监听组件根元素的原生事件。
    .once - 只触发一次回调。
    .left - (2.2.0) 只当点击鼠标左键时触发。
    .right - (2.2.0) 只当点击鼠标右键时触发。
    .middle - (2.2.0) 只当点击鼠标中键时触发。
    .passive - (2.3.0) 以 { passive: true } 模式添加侦听器

```
<!-- 方法处理器 -->
<button v-on:click="doThis"></button>
<!-- 对象语法 (2.4.0+) -->
<button v-on="{ mousedown: doThis, mouseup: doThat }"></button>
<!-- 内联语句 -->
<button v-on:click="doThat('hello', $event)"></button>
<!-- 缩写 -->
<button @click="doThis"></button>
<!-- 停止冒泡 -->
<button @click.stop="doThis"></button>
<!-- 阻止默认行为 -->
<button @click.prevent="doThis"></button>
<!-- 阻止默认行为，没有表达式 -->
<form @submit.prevent></form>
<!--  串联修饰符 -->
<button @click.stop.prevent="doThis"></button>
<!-- 键修饰符，键别名 -->
<input @keyup.enter="onEnter">
<!-- 键修饰符，键代码 -->
<input @keyup.13="onEnter">
<!-- 点击回调只会触发一次 -->
<button v-on:click.once="doThis"></button>
```


在子组件上监听自定义事件 (当子组件触发“my-event”时将调用事件处理器)：

```
<my-component @my-event="handleThis"></my-component>
<!-- 内联语句 -->
<my-component @my-event="handleThis(123, $event)"></my-component>
<!-- 组件中的原生事件 -->
<my-component @click.native="onClick"></my-component>
```

#### v-bind

缩写：:    【注意可缩写】
预期：any (with argument) | Object (without argument)

修饰符：

    .prop - 被用于绑定 DOM 属性 (property)。(差别在哪里？)
    .camel - (2.1.0+) 将 kebab-case 特性名转换为 camelCase. (从 2.1.0 开始支持)
    .sync (2.3.0+) 语法糖，会扩展成一个更新父组件绑定值的 v-on 侦听器。


```
<!-- 绑定一个属性 -->
<img v-bind:src="imageSrc">
<!-- 缩写 -->
<img :src="imageSrc">
<!-- 内联字符串拼接 -->
<img :src="'/path/to/images/' + fileName">
<!-- class 绑定 -->
<div :class="{ red: isRed }"></div>
<div :class="[classA, classB]"></div>
<div :class="[classA, { classB: isB, classC: isC }]">
<!-- style 绑定 -->
<div :style="{ fontSize: size + 'px' }"></div>
<div :style="[styleObjectA, styleObjectB]"></div>
<!-- 绑定一个有属性的对象 -->
<div v-bind="{ id: someProp, 'other-attr': otherProp }"></div>
<!-- 通过 prop 修饰符绑定 DOM 属性 -->
<div v-bind:text-content.prop="text"></div>
<!-- prop 绑定。“prop”必须在 my-component 中声明。-->
<my-component :prop="someThing"></my-component>
<!-- 通过 $props 将父组件的 props 一起传给子组件 -->
<child-component v-bind="$props"></child-component>
<!-- XLink -->
<svg><a :xlink:special="foo"></a></svg>
```


#### v-model

预期：随表单控件类型不同而不同。

限制：

    <input>
    <select>
    <textarea>
    components

修饰符：

    .lazy - 取代 input 监听 change 事件
    .number - 输入字符串转为数字
    .trim - 输入首尾空格过滤


#### v-pre

用法：

跳过这个元素和它的子元素的编译过程。可以用来显示原始 Mustache 标签。跳过大量没有指令的节点会加快编译。

示例：
```
<span v-pre>{{ this will not be compiled }}</span>
```

#### v-cloak

用法：

这个指令保持在元素上直到关联实例结束编译。和 CSS 规则如 [v-cloak] { display: none } 一起用时，这个指令可以隐藏未编译的 Mustache 标签直到实例准备完毕。

示例：
```
[v-cloak] {
  display: none;
}

<div v-cloak>
  {{ message }}
</div>

不会显示，直到编译结束。
```

#### v-once

只渲染元素和组件一次。随后的重新渲染，元素/组件及其所有的子节点将被视为静态内容并跳过。这可以用于优化更新性能。
```
<!-- 单个元素 -->
<span v-once>This will never change: {{msg}}</span>
<!-- 有子元素 -->
<div v-once>
  <h1>comment</h1>
  <p>{{msg}}</p>
</div>
<!-- 组件 -->
<my-component v-once :comment="msg"></my-component>
<!-- `v-for` 指令-->
<ul>
  <li v-for="i in list" v-once>{{i}}</li>
</ul>
```