---
title: 【译】如何像Pro一样构建Vue组件
date: 2018-07-25 10:30
categories: [前端]
author: Diandian
---


![](/images/2018-07-25-how-to-build-vue-components-like-a-pro/1.png)
<!-- more -->
Vue是目前发展最快的Javascript框架之一。Vue被描述为是用于构建交互式界面的“直观、快速。可组合”的MVVM，Vue已经成为每个开发者最喜欢的用于开发交互式Web应用程序和界面的JavaScript框架。自2014年发布已经有97K关注者。

与基于旧的模型-视图-控制器架构的Angular不同，Vue遵循模型-视图-视图-模型系统。

![](/images/2018-07-25-how-to-build-vue-components-like-a-pro/2.png)

关于Vue的另一个好处是它有单个文件组件。这意味着你可以在单个`.vue`文件中编写`模板`，`脚本`和`样式`。

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
在这篇文章中，我将描述构建高级Vue应用程序时可能需要记住的一些最佳实践。

### 应用设置
你可以选择多种不同的方式来创建Vue应用程序。如果你是一个新手，你可以查看[JS Fiddle Hello World](https://jsfiddle.net/chrisvfritz/50wL7mdz/)示例来试用Vue。

在这篇文章中，我将用Vue CLI创建一个Vue项目。首先，在系统中打开命令终端并编写以下命令安装Vue CLI：

```
$ npm install --global @vue/cli
```
你现在可以创建一个Vue项目！让我们试试：

```
$ vue create vue-app
$ cd vue-app
```
这样我们就建立了一个叫vue-app的Vue项目。你可以叫其他名字。

### 用vue-class-component建立Vue组件

看下顶部的代码，你可以看到有个返回对象的`data`函数，如果你想传递处理程序，需要编写`method`对象。

`vue-class-component`允许开发者直接将数据属性和处理程序作为属性添加到类中，这样可以减少组件开发过程。

在代码编辑器中加开项目目录（I ❤️ VS Code）。在你的src文件夹中，你会注意到App.vue和main.js。

有`React`开发经验的人可以把`main.js`看成是React的`index.js`。意味着这是你运行`yarn serve`或`yarn build`时，真正运行的文件。

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

基本上，我们首先从public/index.html文件中获取一个“app”作为id的div元素，然后在其中渲染App组件。

你现在需要再App.vue文件中创建此App组件。打开App.vue文件，把代码替换成：

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
这里，我首先创建了一个简单的模板，里面有带有信息的div。脚本中引入Vue package和Component 从vue-class-component.你还需要再项目中安装此软件包。

```
$ yarn add vue-class-component
```
接下来，我用Component函数包装App类。此函数有一个可以传入选项的对象。

如果你使用的是Vs Code，你将看到你App上有错误。这是因为默认的Vs Code  不接受实验装饰器。要解决这个问题，需要创建一个叫jsconfig.json的新文件。这个文件中告诉Vue编辑器徐云在代码中使用实验装饰器。

```
{
    "compileOptions":{
        "exprimentalDecorators":true
    }
}
```

重新加载编辑器，这个错误将会消失！

现在回答这个问题，“为什么我用vue-class-component而不用vue的传统组件？”

在传统组件中，你需要编写一个返回对象的`data`函数。要改变组件中的任何东西，就要编写像`onClick`之类的`methods`。

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

但是在`vue-class-component`,你可以直接写`onClick`方法，剩下的要做的就是链接到模板。您可以通过在模板h1标记内编写`@click="onClick"`来完成这个操作。

用`yarn serve` 命令行运行Vue应用程序，你将看到它的工作方式如下：

![](/images/2018-07-25-how-to-build-vue-components-like-a-pro/3.gif)

### 用vue-property-decorator定义你的道具
你还可以用`vue-property-decorator`直接在类上定义属性。这也是通过一个简单的@Prop装饰器完成的。这种prop声明方法可以让我们保持简单的类。

首先，在项目中安装vue-property-decorator包：

```
$ yarn add vue-property-decorator
```
关于这个包的另一个好处是它还包含了`vue-class-component`。因此，你可以从`vue-property-decorator`包中导入`Component`。

在App.vue文件中，重新代码，如下：

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

在这里，我首先从'vue-property-decoratoe'包中导入`Component`和`Prop`。然后在App类中，我使用@Prop修饰器来设置消息的默认值。

就是这样！您现在讲消息传递给我们的代码，他也有一个默认值。

### 使用Vue插槽定义内容在组件中的位置

Vue的`slots` 可以告诉代码你想要内容在组件中的位置。现在这可能听起来有点混乱，通过一些代码看下slots 到底做了什么

回到main.js文件中，在render中重写代码像这样：
```
render:h=>(
    <App>
        <h1>Superman</h1>
    </App>
)
```
如果在浏览器中查看该应用程序，你可以看到没有任何更改。这是因为你没有App.vue文件中模板内的新文本指定的任何位置，这是插槽发挥作用的地方。

在App.vue的模板中，写两个插槽包装原始h1标签。

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

你的应用仍然无法呈现新文字。那是因为编译器现在不知道将新文本放到哪个插槽。我希望文本位于底部插槽中。我给这个插槽一个footer的名字。

转到main.js文件，将slot="footer"的属性添加到新文本中，然后，这将呈现新文本。

但是，你的渲染方法现在有点笨拙。让我们看下如何使用插槽处理它。

### 使用插槽创建布局

你同样可以用`slots`来创建自定义布局，可用于指定应放置每个应用或组件的位置。

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
接下来，进入`App.vue`文件并删除模板内标记的内容，然后在`script`标签内，导入港股创建的`Layout.vue`,如：
```
import Layout from './components/Layout';
```
你还需要告诉`Component`装饰器您正在使用`Layout`作为组件。

```
export default Component({
    components:{Layout}
});
```
你现在将`布局`用作`模板`标记内的组件。还需要添加一些文本标签。

```
<template>
  <Layout>
    <h1 slot="header">How To Build Vue Apps Like A Pro 😎</h1>
    <h2 slot="body"> by Rajat S</h2>
    <h3 slot="footer">Technical Content Writer</h3>
  </Layout>
</template>
```

确保已添加具有适当名称的插槽属性，否则将无法呈现文本标记。

### 使用Vue插槽传递Props

通过将组件和`插槽`组合，你可以使用`slot-scope`将组件的数据传递到插槽。您可以将props从父组件传递到子组件，而不是耦合在一起。

转到`App.vue`文件并在`模板`标记内部，将`Layout`包装在`Settings`标记内。

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

`script`标签内，首先从`vue-class-component`包导入Vue和Component装饰器。

然后，在Component装饰器中创建一个Header类。类里面包含想传递给Header的prop。

### 传递参数给功能模板

功能模板允许你创建有模板标记的组件，并且暴露props给模板。

在src/components 文件夹中，创建一个Header.vue的新文件，在其中编写代码：

```
<template>
    <h1 slot="header">{{props.header}}</h1>
</template>
```

这里的`功能`一词表示该文件只有一个简单的`模板`。对于`Body.vue`和`Footer.vue`文件重复此操作。

返回`App.vue`文件并重写`模板`。

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

并且告诉`Component`装饰器你正字用这个组件。

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

但这个代码仍然不生效，因为刚写的import 语句不对。要解决这个问题，需要再src/component中创建一个名为index.js的新文件。

```
export {default as Header} from ‘./Header.vue’;
export {default as Body} from ‘./Body.vue’;
export {default as Footer} from ‘./Footer.vue’;

```
有了这个，你已经在Vue创建了功能模板，允许我们将props从父组件传递到子组件，不必编写大量代码。

### Vue组件使用Bit
Bit是一个用于多个应用程序或项目中共享组件的平台，同时保持他们同步。当使用Vue.js组件时，Bit是一种很好的协作方式，可以开发不同项目的组件，组织他们，同步更新。

(Bit)[https://bitsrc.io/]

### 结论

Vue是一种全球范围内广泛被应用的Web开发软件技术，Vue实际上是一个Javascript框架，其中包含用于构建用户界面的各种可选工具。

Vue成功的背后一个主要因素是它易于学习，并且使用它构建精彩的应用程序更加容易。

我希望这篇文章能够帮助你更好的理解Vue以及如何使用它来构建更好的应用程序。

原文：[https://blog.bitsrc.io/how-to-build-vue-components-like-a-pro-fd89fd4d524d](https://blog.bitsrc.io/how-to-build-vue-components-like-a-pro-fd89fd4d524d)

译者：[Diandian](https://futu.im/author/Diandian)

作者：[Rajat S](https://blog.bitsrc.io/@geeky_writer_)

