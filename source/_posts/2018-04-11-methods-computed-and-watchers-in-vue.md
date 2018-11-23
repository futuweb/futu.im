---
title: 【译】Vue 中的方法,计算和侦听者
subtitle: 工作中我喜欢用Vue的原因之一就是因为方法，计算属性和侦听者非常有用，并且他们之前差异的可读性很好。
cover: /images/2018-04-11-methods-computed-and-watchers-in-vue/cover.jpeg
date: 2018-04-11 10:00
categories: [前端]
tags: [Js,技术,Vue]
author: Diandian
---

工作中我喜欢用Vue的原因之一就是因为方法，计算属性和侦听者非常有用，并且他们之前差异的可读性很好。在理解这三者之前，我很难充分的利用Vue的全部功能。尽管如此，大多数人对这个框架感到困惑的也多集中在这三者之间的差异，所以让我们一起来深入研究下。
<!-- more -->

如果你想得到一个直接结论，或者你没有时间阅读整篇文章，这里给一些略长的小总结：

* Methods(方法)：顾名思义，就是方法的意思。这些方法是能操作对象的函数-通常是Vue实例本身或者Vue组件。


* Computed(计算)：这些计算属性可能乍看起来就像方法一样使用，但其实不是的。在Vue中，我们需要用`data`去响应我们想要的一个特定属性的变化。计算属性不仅可以定义一个与`data`使用方式相同的属性，并且可以有一些基于其依赖关系进行缓存的自定义逻辑。你可以将计算属性视为数据的另一个视图。


* Watchers(侦听者)：侦听者可以窥视数据变化。我们提供了一些钩子函数来监视Vue存储的一些属性。如果你想在数据变化时添加一些功能，或者对一些特定的更改做出响应，我们可以侦听这个属性并应用一些逻辑。这意味着侦听者的名字必须要与我们侦听的内容相匹配。

如果这么说让你听起来有些困惑，不要担心！我们将在下面进行更多的探讨希望能解答你的困惑。如果你已经熟悉vanilla Javascript,那么除了一两个注意事项外，方法对你来说是比较重要的。这可能会让你跳过`Comouted`和`Watchers`这两个部分。

### Methods（方法）

`方法`可能是你在使用Vue时经常用到的。其实它就是我们把一些函数方法挂到一个对象上，所以它实质上就是这样被命名的。它对于将功能连接到事件指令非常有用，甚至只要创建一小段逻辑就可以像其他函数一样复用。例如，你可以在另一个方法中调用方法。你也可以在生命周期钩子函数中调用这个方法。这是非常灵活的。

这里有一个简单的演示：[点击链接](https://codepen.io/sdras/pen/caf96f7c14dc52323b97dd9845a0bf64)

```
//HTML
<code class="language-css"><div id="app">
  <button @click="tryme">Try Me</button>
  <p>{{ message }}</p>
</div>
```

```
//JS
new Vue({
  el: '#app',
  data() {
    return {
      message: null
    }
  },
  methods: {
    tryme() {
      this.message = Date()
    }
  }
})
```

我们也可以直接在指令本身中执行这个逻辑，如`<button @click="message = Date()">Try Me</button>`
这在小示例中是非常有效的。但是，随着应用程序越来越复杂，对于上面这种常见的方法是将其分解出来更加清晰。Vue允许你在指令中表达逻辑也是有限制的-例如,表达式可以，但语句不行。

你可能会注意到，我们可以在该组件或Vue实例中访问这个方法，并且可以调用任何一条数据，在本例中就是`this.message`.你不需要用像在指令中调用函数的方法。例如：不需要这样`@click=”methodName()”`，除非你要传一个参数，像这样`@click=”methodName(param)”`。

使用指令调用方法也挺好的，因为我们有一些事件修饰符。其中一个常用的例子就是`.prevent`,它将在提交事件中阻止页面重新加载。

```
//HTML
<form v-on:submit.prevent="onSubmit"></form>
```
[还有更多可以学习下](https://vuejs.org/v2/api/?#v-on)。

### Computed (计算属性)

计算属性对于处理已存在的数据非常有价值。无论何时，当你需要对大量数据进行排序并且不想在每次按键时重新进行运算，请考虑使用计算属性。

一些常用的场景例如：
* 在用户输入时更新大量的信息，例如过滤列表。
* 从Vuex商店中收集信息
* 表单验证
* 数据可视化需要依赖于用户查看的内容而变化

计算属性是理解学习Vue的一个重要部分。它们是基于依赖关系进行缓存的计算，并且在依赖关系变化时进行更新。如果使用得当会非常高效。有很多大型的组件库都是为了处理这种逻辑，然而现在只需要几行代码就能解决。

计算属性并不想方法那样使用，尽管起初它们长的差不多-你在函数中声明一些逻辑并返回-但是这个函数的名字变成了一个属性，然后你将在程序中应用它，如`data`。

如果我们需要根据用户输入的内容来筛选这些人的名单，那么我们将如何做到这一点。为了看起来简单些，你可以减少一些基本概念。首先，列表数据将会把存储在数据中的名称在模板中输出：
```
//JS
new Vue({
  el: '#app',
  data() {
    return {
      names: [
        'Evan You',
        'John Lindquist',
        'Jen Looper',
        'Miriam Suzanne',
        ...
      ]
    }
  }
})
```
```
//HTML
<div id="app">
  <h1>Heroes</h1>
  <ul>
    <li v-for="name in names">
      {{ name }}
    </li>
  </ul>
</div>
```
效果见 [链接](https://codepen.io/sdras/pen/ea95375f04cfd68ec0c245b17de2f93f)

现在让我们为这些名称创建一个过滤器。我们先创建一个有`v-model`的input,该输入起初回事个空字符串，但是我们将使用它来匹配和过滤我们的列表。我们将调用`findName`这个属性，你可以在输入和`data`中看到这个引用。

```
//HTML
<label for="filtername">Find your hero:</label>
<input v-model="findName" id="filtername" type="text" />
```

```
//JS
data() {
  return {
    findName: '',
    names: [
      'Evan You',
      'John Lindquist',
      ...
    ]
  }
}
```
现在我们可以创建计算属性，根据用户输入的内容来过滤名称，因此我们的`findName`属性中的任何内容都会被使用。你会注意这里我用了正则表达式来确保用户输入大小写都没关系，因为用户输入时通常不会大写。

```
//JS
computed: {
  filteredNames() {
    let filter = new RegExp(this.findName, 'i')
    return this.names.filter(el => el.match(filter))
  }
}
```
现在我们将更新模板中使用的内容输出：

```
//HTML
<ul>
  <li v-for="name in names">
    {{ name }}
  </li>
</ul>
```
变成这样
```
//HTML
<ul>
  <li v-for="name in filteredNames">
    {{ name }}
  </li>
</ul>
```
这将会在每次按键时为我们进行过滤，我们只需要添加几行代码就能达到这个效果，而不必加载任何其他的库。

效果如下  [链接](https://codepen.io/sdras/pen/3d453a8f33aee923b043cf24e3e39b39)

我在使用它时，不知道节省了多少时间，如果你在用Vue但是[还没有探索过这个功能](https://vuejs.org/v2/guide/computed.html#Computed-Properties)，那么赶紧去使用吧，你会感谢我的。

### Watchers(侦听者)

Vue具有很好的抽象性，任何一个曾经做过程序员的都会告诉你，抽象是一种痛，因为最终你会遇到一个他们无法解决的用例。然而，这种情况是可以解释的，因为Vue能够更深入的访问反应系统，我们可以利用它来侦听正在改变的事物。这个可能是很有用的，因为作为应用程序开发人员，我们负责的大部分事情都是变化的。

Watchers还允许我们编写更多的声明性代码。你不用再去追踪一切。Vue已经在做这件事了，所以你可以访问它所追踪的任何属性的变化，例如：`data`,`computed`或者`props`。

当一个属性发生变化时，侦听者非常适合执行适用于别的东西的逻辑（我第一次听到这个是从[Chris Fritz](https://twitter.com/chrisvfritz)那里，他说他也是从别人那里听到的☺️）这不是一个硬性的原则-你完全可以使用侦听者来引用属性本身的逻辑，但是这是区别侦听者和计算属性不同的一个很好的方式，当我们将要用到的引用属性改变时。

我们来看看最简单的例子，就能了解这其中发生了啥。

[视频链接](https://s3.amazonaws.com/media-p.slid.es/videos/75854/3KviniJX/watcher.mp4)

```
//JS
new Vue({
  el: '#app', 
  data() {
    return {
      counter: 0
    }
  },
  watch: {
    counter() {
      console.log('The counter has changed!')
    }
  }
})
```
正如上面代码中看到的那样，我们将`counter`存储在`data`中，并且使用该属性名称作为函数名称，我们就可以侦听它了，当我们在`watche`中引用`counter`时，就可以观察到这个属性的变化了。

### Watchers的过度状态

如果状态足够相似，你甚至可以简单的将状态转换为侦听者。这里看下我用Vue画的一个表格。当数据发生变化时，观察者将更新它并且能在两者之间简单的转换。

SVG对于这样的场景也使用，因为它也是用数学建立的。

[效果链接](https://codepen.io/sdras/pen/OWZRZL)

```
//JS
watch: {
  selected: function(newValue, oldValue) {

    var tweenedData = {}

    var update = function () {
      let obj = Object.values(tweenedData);
      obj.pop();
      this.targetVal = obj;
    }

    var tweenSourceData = { onUpdate: update, onUpdateScope: this }

    for (let i = 0; i < oldValue.length; i++) {
      let key = i.toString()
      tweenedData[key] = oldValue[i]
      tweenSourceData[key] = newValue[i]
    }

    TweenMax.to(tweenedData, 1, tweenSourceData)
  }
}
```

这里发生了什么呢？

* 首先我们创建了一个虚拟对象，它将跟随动画库变化更新。

* 然后我们有一个更新的函数，在tween step中调用这个函数。我们用这个来推动数据。

* 然后我们创建一个对象来保存元数据和更新事件的函数

* 我们创建一个for循环，然后将当前索引变成一个字符串。
* 然后我们可以在目标虚拟对象上进行tween ,但是我们只会对特定的关键点执行这个操作。

我们也可以在观察者中使用动画来创建类似于这个时间差的表盘。我旅行了一段时间，我所有的同事都在不同的地方，所以我想要用一种方式来追踪我们当地的时间，以及白天时间/晚上时间变化的意义。

[效果链接](https://codepen.io/sdras/pen/RZGqxR)

在这里，我们正在侦听checked属性，并且我们将使用包含时间线动画的不同方法来改变色调和饱和度以及基于与当前时间的相对关联的一些其他元素。正如前面提到的那样 - 变化发生在下拉菜单上，但我们正在执行的是在其他地方应用的逻辑。

```
//JS
watch: {
  checked() {
    let period = this.timeVal.slice(-2),
      hr = this.timeVal.slice(0, this.timeVal.indexOf(':'));

    const dayhr = 12,
      rpos = 115,
      rneg = -118;

    if ((period === 'AM' && hr != 12) || (period === 'PM' && hr == 12)) {
      this.spin(`${rneg - (rneg / dayhr) * hr}`)
      this.animTime(1 - hr / dayhr, period)
    } else {
      this.spin(`${(rpos / dayhr) * hr}`)
      this.animTime(hr / dayhr, period)
    }

  }
},
```
关于watchers还有一些其他有趣的事情,例如：我们可以将属性的新版本和旧版本作为参数进行访问，如果我们想侦听嵌套对象，我们可以指定`deep`。更多详情看指引，[本指南中提供了许多有用的信息](https://vuejs.org/v2/guide/computed.html#Watchers)。

您可以看到侦听者对于实时更新的任何内容-无论是表单输入，异步更新还是动画都可以发挥非常有用的作用。如果你很好奇Vue是如何做到的，那么[这部分指南](https://vuejs.org/v2/guide/reactivity.html)是非常有用的。如果你想了解更多的响应，推荐我喜欢的[Andre Staltz的博文](https://gist.github.com/staltz/868e7e9bc2a7b8c1f754)和Mike Bostock的[更好的编码方式](https://medium.com/@mbostock/a-better-way-to-code-2b1d2876a3a0)

### 总结

我希望这是一个关于如何使用的指引，并且能提高你使用Vue进行应用程序开发的效率。有一个数据统计，我们用70%的时间去阅读代码，而只用了30%的时间来写。个人而言，作为一个维护者我喜欢这一点，我可以看之前没有见过的代码库，并且能够通过`methods`,`computed`和`watchers`的区别用法来了解作者的意图。



原文：[Methods, Computed, and Watchers in Vue.js](https://css-tricks.com/methods-computed-and-watchers-in-vue-js/)

作者：[SARAH DRASNER ](https://css-tricks.com/author/sdrasner/)

译者：[Diandian](https://futu.im/author/Diandian)
