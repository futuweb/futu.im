---
title: 【译】如何专业的构建Vue组件
subtitle: Vue遵循模型-视图-视图-模型系统。
cover: /images/2018-07-25-how-to-build-vue-components-like-a-pro/2.png
date: 2018-07-25 10:30
categories: [前端]
author: Diandian
---


![](/images/2018-07-25-how-to-build-vue-components-like-a-pro/1.png)
<!-- more -->
Vue是目前发展最快的Javascript框架之一。Vue被描述为是用于构建交互式界面的“直观、快速、可组合”的MVVM，它已经成为开发者最喜欢的交互式Web开发的JavaScript框架。在2014年开始在Github上已经有97K的关注了。

与基于旧的模型-视图-控制器架构的Angular不同，Vue遵循模型-视图-视图-模型系统。

![](/images/2018-07-25-how-to-build-vue-components-like-a-pro/2.png)

Vue的另一个好处是它是单个文件组件。这意味着你可以在单个`.vue`文件中编写`模板`，`脚本`和`样式`。

```
<template>
    <p>{{greeting}}</p>
<template>

<script>
    module.exports = {
        data:function(){
            return {
                greeting:'hello'
            }
        }
    }
</script>

<style>
    p{
        font-size:2em;
        text-align:center;
    }
</style>

```
在这篇文章中，我会讲述构建高级Vue应用程序时需要用到的一些实践经验

### 应用设置
在这里，你可以选择不同的方式来创建Vue应用程序。如果你是一个新手，你可以查看[JS Fiddle Hello World](https://jsfiddle.net/chrisvfritz/50wL7mdz/)示例来体验Vue。

在这篇文章中，我会用Vue CLI创建一个Vue项目。首先，在系统中打开终端并编写以下命令安装Vue CLI：

```
$ npm install --global @vue/cli
```
你现在可以创建一个Vue项目了！让我们试试：

```
$ vue create vue-app
$ cd vue-app
```
这样我们就建立了一个叫vue-app的Vue项目。你也可以叫其他名字。

### 用vue-class-component建立Vue组件

看下顶部的代码，你可以看到`data`函数返回的是对象，如果你想做事件处理，需要编写`method`对象。

`vue-class-component`允许开发者直接将数据属性和事件处理作为类的属性来减少开发工作量。

用编辑器打开项目目录（I ❤️ VS Code）。在`src`文件夹中，会看到有`App.vue`和`main.js`。

有`React`开发经验的人可以把`main.js`看成是React的`index.js`。当运行`yarn serve`或`yarn build`时，这个文件就会执行。

重新写下你的main.js:
```
import 'tailwindcss/dist/tailwind.css';
import Vue from 'vue';
import App from './App';

new Vue({
    el:'#app',
    render:h=><App/>
})
```


首先获取`public/index.html`文件中id为"app"的div元素，然后启动`APP`组件。

然后在`App.vue`文件中创建此App组件。打开`App.vue`文件，把代码替换成：

```
<template>
    <h1 @click="onClick">
    {{message}}
    </h1>
</template>

<script>
import Vue from 'vue';
import Component from 'vue-class-component';

export default Component({})(
    class App extends Vue {
        message = 'Batman';
        
        onClick(){
            this.message = 'Bruce Wayne';
        }
    }
)

</script>
```
这里，我首先创建了一个简单的`template`，里面有一个`div`。`script`中引入`Vue`和`vue-class-component`中的`Component`.你还需要在项目中安装此软件包。

```
$ yarn add vue-class-component
```
接下来，我用`Component`函数包装`App`。此函数有一个可传入对象选项。

如果你使用的是Vs Code，你将看到你`App`上有错误。这是因为默认的Vs Code不支持对修饰器的实验。要解决这个问题，需要创建一个叫`jsconfig.json`文件。这个文件中告诉Vue编辑器允许使用修饰器实验。

```
{
    "compileOptions":{
        "exprimentalDecorators":true
    }
}
```

重启编辑器，这个错误就消失了！

现在回答这个问题，“为什么我用`vue-class-component`而不用Vue的传统组件？”

在传统组件中，你需要编写一个返回对象的`data`函数。要改变组件中的任何东西，就要编写像`onClick`之类的`方法`。

```
const TraditionalComp = {
    data(){
        return {message:"Batman"}
    },
    methods:{
        onClick(){
            this.message = "Bruce Wayne"
        }
    }
}
```

但是在`vue-class-component`,你可以直接写`onClick`方法，然后链接到模板文件。只要在模板`h1`标签内编写`@click="onClick"`就可以了。

用`yarn serve` 命令运行Vue应用程序，效果如下：

![](/images/2018-07-25-how-to-build-vue-components-like-a-pro/3.gif)

### 用vue-property-decorator来定义Props
你还可以用`vue-property-decorator`直接在类上定义属性。通过`@Prop()`装饰器就可以实现,这种prop声明方法可以让类看起来简洁。

首先，在项目中安装vue-property-decorator包：

```
$ yarn add vue-property-decorator
```
这个包的另一个好处是它还包含了`vue-class-component`。因此，你可以从`vue-property-decorator`包中引入`Component`。

在`App.vue`文件中，重新梳理代码，如下：

```
<template>
    <h1 @click="onClick">
        {{message}}
    </h1>
</template>

<script>
import Vue from 'vue';
import {Component,Prop} from 'vue-property-decorator';

export default Component({})(
    class App extends Vue{
        @Prop({default:'Batman'})
        message;
        
        onClick(){
            this.message = 'Bruce Wayne';
        }
    }
)
</script>
```

在这里，我首先从'vue-property-decoratoe'包中引入`Component`和`Prop`包。然后在App中，我使用`@Prop`修饰器来设置`message`的默认值。

这样！`message`就可以通过prop传递数据了，同是也有一个默认值。

### 使用Vue Slots定义内容在组件中的位置

Vue的`slots` 可以定义内容在组件中的位置。现在这可能听起来有点混乱，通过一些代码看下`slots`到底做了什么

回到main.js文件中，在render中重写代码像这样：
```
render:h=>(
    <App>
        <h1>Superman</h1>
    </App>
)
```
如果在浏览器中查看该应用程序，你可以看到没有任何更改。这是因为你没有`App.vue`中`template`内指定文本的位置，这是`slots`要做的

在`App.vue`的`template`中，写两个`slots`包装原来的`h1`标签。
```
<template>
    <div>
        <slot name="header"></slot>
        <h1 @click="onClick">
            {{message}}
        </h1>
        <slot name="footer"></slot>
    </div>
</template>
```

这时候仍然看不懂内容。那是因为编译器现在不知道将新文本放到哪个slot。我希望文本位于底部slot中。我给这个插槽一个`name`命名为`footer`。

再来看main.js文件，将slot="footer"的属性添加到新文本中，然后，就能看到内容了。

但是，这样的`渲染`方式显得不灵活。让我们看下如何用`slot`优化他

### 使用Slots创建布局

你也可以用`slots`来自定义布局，可用于指定每个应用程序和组件的位置。

在`src/components`文件夹中创建一个名为`Layout.vue`的新文件。在此文件中编写一个`template`，如下所示：

```
<template>
    <div>
        <slot name="header"></slot>
        <slot name="body"></slot>
        <slot name="footer"></slot>
    </div>
</template>
```
接下来，进入`App.vue`文件并删除`template`内的内容，然后在`script`标签内，引入`Layout.vue`：

```
import Layout from './components/Layout';
```
你还需要告诉`Component`装饰器您正在使用`Layout`作为组件。

```
export default Component({
    components:{Layout}
});
```
你现在可以在`template`中`Layout`组件，还需要去添加一些文本。

```
<template>
  <Layout>
    <h1 slot="header">How To Build Vue Apps Like A Pro 😎</h1>
    <h2 slot="body"> by Rajat S</h2>
    <h3 slot="footer">Technical Content Writer</h3>
  </Layout>
</template>
```

要确保添加的`slot`有相对应的名字，否则将看不到渲染

### 用Vue Slot来传递Props

通过将组件与`slots`相结合，你可以通过`slot-scope`来传递组件的数据。通过props将数据从父组件传到子组件，而不是耦合在一起。

再看`App.vue`文件和`template`标签内，将`Layout`写在`Settings`内。

```
<template>
    <Settings>
        <Layout slot-scope="{header}">
            <h1 slot="header">{{header}}</h1>
            <h2 slot="body"> by Rajat S</h2>
            <h3 slot="footer">Technical Content Writer</h3>
        </Layout>
    </Settings>
</template>
```

在`script`标签中引入`Setting`，

```
import Settings from './components/Settings.vue'
```

告诉`Component`装饰器你正在使用`Settings`组件。

```
export default Component({
    components:{Layout,Settings},
});
```

现在，你需要创建`Settings`组件。去`src/componets`创建一个`Settings.vue`的文件。像这样写：

```
<template>
    <div>
        <slot :header="header"></slot>
    </div>
</template>

<script>
    import Vue from 'vue';
    import Component from 'vue-class-component';
    export default Component({})(
        class Settings extends Vue{
            header='How To Build Vue Apps Like A Pro 😎';
        }
    )
</script>
```

在`template`标签内，`slot`在`div`里，在`slot`里面，我绑定了`:header=“header”`

`script`标签内，首先从`vue-class-component`包引入`Vue`包和`Component`装饰器。

然后，在`Component`装饰器中创建一个`Header`类。类里面包含需要传给header的数据。

### 传递参数给功能模板

功能模板允许你创建只有`template`标签的组件，并且暴露`props`给模板。

在`src/components`文件夹中，创建一个`Header.vue`的新文件：

```
<template functional>
    <h1 slot="header">{{props.header}}</h1>
</template>
```

这里的`functional`一词表示该文件只有一个的`template`。对于`Body.vue`和`Footer.vue`文件重复使用。

在`App.vue`文件并重写`template`。

```
<template>
  <Settings>
    <Layout slot-scope="{header, body, footer}">
      <Header slot="header" :header="header"></Header>
      <Body slot="body" :body="body"></Body>
      <Footer slot="footer" :footer="footer"></Footer>
    </Layout>
  </Settings>
</template>
```

在`script`中引入Header,Body,Footer文件。

```
import {header,Body,Footer} from './component';
```

告诉`Component`装饰器你正在使用这个组件。

```
export default Component({
    components:{
        Settings,
        Layout,
        Header,
        Body,
        Footer,
    }
})
```

但这个代码仍然不生效，因为刚写的import语句不对。要解决这个问题，需要再`src/component`中创建一个名为`index.js`的新文件。

```
export {default as Header} from ‘./Header.vue’;
export {default as Body} from ‘./Body.vue’;
export {default as Footer} from ‘./Footer.vue’;

```
这样，你就可以在Vue创建功能模板，并可以用props从父组件传参到子组件，同时省去了大量的代码

### Vue组件使用Bit
Bit是一个用于多个应用程序或项目中共享组件的平台，同时实时更新。当使用Vue.js组件时，Bit 是在开发不同的项目协作更新时一种非常棒的合作开发组件。

(Bit)[https://bitsrc.io/]

### 结论

Vue是在全球范围内被广泛应用的Web开发软件技术，Vue实际上是一个Javascript框架，其中包含用于构建用户界面的各种工具。

Vue成功的背后一个主要因素是它易于学习，并且使用它可以让构建精彩的应用程序更加容易。

我希望这篇文章能够帮助你更好的理解Vue以及如何使用它来构建更好的应用程序。

原文：[https://blog.bitsrc.io/how-to-build-vue-components-like-a-pro-fd89fd4d524d](https://blog.bitsrc.io/how-to-build-vue-components-like-a-pro-fd89fd4d524d)

译者：[Diandian](https://futu.im/author/Diandian)

作者：[Rajat S](https://blog.bitsrc.io/@geeky_writer_)

