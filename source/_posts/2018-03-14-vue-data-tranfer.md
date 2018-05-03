---
title: vue组件之间的数据传递
date: 2018-03-14 18:00
categories: [前端]
tags: [web前端, vue, javascript]
author: Elly
---

最近在整理项目中代码，在组件之间数据传递遇到了问题，所以做了这次总结，如有不对的地方，望指正。

## 父组件如何将数据传到子组件中

父组件可以通过`Prop`传递数据到子组件中。

### 这里需要注意的是：

- `Prop` 是单向绑定的：当父组件的属性变化时，将传导给子组件，但是反过来不会。这是为了防止子组件无意间修改了父组件的状态，来避免应用的数据流变得难以理解。

- 每次父组件更新时，子组件的所有 `Prop` 都会更新为最新值。这意味着你不应该在子组件内部改变 prop。如果你这么做了，Vue 会在控制台给出警告。

<!-- more -->

### 在两种情况下，我们很容易忍不住想去修改 prop 中数据：

- `Prop` 作为初始值传入后，子组件想把它当作局部数据来用；
 
解决方法：定义一个局部变量，并用 `prop` 的值初始化它：

```js
props: ['initialCounter'],
data: function () {
  return { counter: this.initialCounter }
}    
```

- `Prop` 作为原始数据传入，由子组件处理成其它数据输出。

解决方法： 定义一个计算属性，处理 prop 的值并返回：

```js
props: ['size'],
computed: {
  normalizedSize: function () {
    return this.size.trim().toLowerCase()
  }
}
```

PS：上边的内容是`vue`文档里边有说的，我只是把自己在项目中遇到的问题抽出来了。[链接](https://cn.vuejs.org/v2/guide/components.html#Prop)


栗子：

```html
// 父组件 index.vue
<template>
    <div class="content">
        <child :lists="lists"></child>
    </div>
</template>
<script>
    import child from './child.vue';
    export default {
        components: {
            child
        },
        data() {
            return {
                lists: []
            };
        },
        mounted() {
            this.lists = [{
                name: '01',
                content: 'hi,'
            }, {
                name: '02',
                content: 'my name is Ellyliang'
            }];
        }
    };
</script>

// 子组件 child.vue
<template>
    <ul class="content">
       <li v-for="(list, index) in getLists" :key="index" v-html="list.name + list.content"></li>
    </ul>
</template>
<script>
    export default {
        props: ['lists'],
        data() {
            return {
                getLists: this.lists
            };
        },
        mounted() {
            this.getLists.push({
                name: '03',
                content: '不要在乎内容，我就是测试'
            });
        }
    };
</script>
```

## 子组件如何将数据传到父组件中

子组件可通过`vm.$emit`将数据传递给父组件

### `vm.$emit`是啥

触发当前实例上的事件。附加参数都会传给监听器回调。 [链接](https://cn.vuejs.org/v2/api/#vm-emit)

栗子：

```html
// 父组件 index.vue
<template>
    <div class="content">
        <child :lists="lists" @listenToChild="getChildMsg"></child>
    </div>
</template>
<script>
    import child from './child.vue';
    export default {
        components: {
            child
        },
        data() {
            return {
                lists: []
            };
        },
        mounted() {
            this.lists = [{
                name: '01',
                content: 'hi,'
            }, {
                name: '02',
                content: 'my name is Ellyliang'
            }];
        },
        methods: {
            getChildMsg(val) {
                alert(val);  // 'hello'
            }
        }
    };
</script>

// 子组件 child.vue
<template>
    <div class="content">
        <ul class="lists">
            <li v-for="(list, index) in getLists" :key="index" v-html="list.name + list.content"></li>
        </ul>
    </div>
</template>
<script>
    export default {
        props: ['lists'],
        data() {
            return {
                getLists: this.lists
            };
        },
        mounted() {
            this.getLists.push({
                name: '03',
                content: '不要在乎内容，我就是测试'
            });
            
            setTimeout(() => {
                this.$emit('listenToChild', 'hello');
            }, 15000);
        }
    };
</script>
```

子组件给父组件传数据是不是也很方便。实现方法是就是在子组件中`$emit`数据，然后在父组件中通过事件`@事件名`接收值。

## Event Bus

事件巴士这种方法，不仅能处理父子组件传递，子父组件传递，还是处理平级组件之间的数值传递。其实现方法就是在全局`new`一个`vue`实例，然后传值给`bus`, 就是`let bus = new vue();`。通过这个全局的`bus`中的`$emit`, `$on`等等去实现数据的传递。这样处理有个问题，由于`event bus`处理数据传递很方便，不管在哪里都可以传递，这样导致滥用，从而导致代码很难去理解。

### Event Bus实现

```js
let bus = new Vue();
// 触发组件 A 中的事件
bus.$emit('id-selected', 1);
// 在组件 B 创建的钩子中监听事件
bus.$on('id-selected', function (id) {
// ...
});
```

具体组件的封装和使用，可参考[vue-bus](https://www.npmjs.com/package/vue-bus)。

## 除了以上3种方法，还有就是通过`vuex`去处理数据的传递，但是我还没有接触，大家要感兴趣，自己去学习。


