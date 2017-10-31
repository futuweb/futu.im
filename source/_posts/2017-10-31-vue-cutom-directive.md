---
title: 【译】vue 自定义指令的魅力
date: 2017-10-31 10:00
category: 翻译
tags: [JS,技术]
author: Diandian
---

当你开始学习一个新的Javascript框架时，会像一个初次来糖果店的孩子一样，你可以接受所有的东西，只有当你能轻松的运用这个框架去开发时，才会知道哪些好用哪些不好用。不可避免的是，对于框架，大家都有一个共识就是总会有框架覆盖不到的地方。

[Vue](https://vuejs.org/)的漂亮之处在于它的功能非常强大，即使这个框架的指令不够面面俱到，你也可以正常使用它，因为你可以很轻松的创建一个自定义指令。

<!-- more -->

## 什么是指令？

我在[Vue.js guide](https://css-tricks.com/guides/vue/)中写过指令的[Post](https://css-tricks.com/intro-to-vue-1-rendering-directives-events/)，但是再让我们一起复习下。

指令是可以附加在DOM元素的小命令，他们以`v-`为前缀的标记来告诉代码库这是个指令，来保持语法的一致性。如果你需要对HTML进行底层访问来控制一些行为这种方式是非常有用的。

在这里，我想说你可能已经对一些vue或者angular的`v-if`,`v-else`,`v-show`等指令比较熟悉了，但是我还是要介绍一些基础的，如果你更想直接看例子，可以下滑到页面下面一点看就好了，也能理解这些概念。

以下我将通过例子来介绍几种使用指令的一些方法，这些例子可能不够规范，只是用例而已。这里的例子代替了实际的指令。

`v-example`-是一个实例化指令，但是不接受任何参数。如果不传参数会比较不灵活，但是也可以从DOM元素中删除一些功能。

`v-example="value"`-这将传递一个值到指令中，并且这个指令会根据这个值计算出要做什么。

```html
<div v-if="stateExample">I will show up if stateExample is true</div>
```

`v-example="'string'"`-这是使用了一个字符串作为表达式。

```html
<p v-html="'<strong>this is an example of a string in some text<strong> '"></p>
```

`v-example:arg="value"`-  这里允许我们将参数传递给指令，在下面的例子中，我们绑定一个类，然后给这个对象添加样式来单独存储。


```html
<div v-bind:class="someClassObject"></div>
```

`v-example:arg.modifier="value"`-这里允许我们使用修饰符，下面的例子可以在click事件上调用preventDefault();

```html
<button v-on:submit.prevent="onSubmit"></button>
```

### 了解自定义指令

现在我们已经知道了所有我们可以用的指令，然后现在让我们一起来分解下如何使用自己编写的自定义指令来实现。可以使用自定义指令的一个很好的例子就是滚动事件，所以让我们看看如何来写这个。

如果只是创建一个全局指令是很容易的（因为它没有做什么）。

```js
vue.directive('task');
```

根据这个指令HTML就是这样的：

```html
<p v-tack>This element has a directive on it</p>
```

我们有几个钩子，每个钩子都有几个参数可以选择，这些钩子如下：

1、`bind`-当指令绑定到元素上时使用。

2、`insert`-当将元素插入到DOM的父级元素时会使用这个钩子。

3、`update`-当父元素更新但是子元素还没有更新时这个钩子将被调用。

4、`componentUpdated`-当组件及其子组件被更新时，就会调用这个钩子。

5、`unbind`-当删除这个指令时，这个钩子将被调用。

![hookArguments](https://cdn.css-tricks.com/wp-content/uploads/2017/04/custom-directives-flat.svg)

就个人而言，我发现最有用的绑定和更新就是这五个。

他们中的每一个都有可以用的`el`,`binding`和`vnode`参数，除了`update`和`componentUpdated`之外，还会暴露`oldVnode`,以区分传递的旧值和新值。

`el`,就是你所期望的，绑定所依赖的元素；`binding`是个对象，包含了传入钩子的参数，有很多可用的参数，包括`name`,`value`,`oldValue`,`expression`,`arg`和`modifiers`；`vnode`有一个更不同寻常的用例，它可用于你需要直接引用到虚拟DOM中的节点，`binding`和`vnode`都被视为只读。

### 创建一个自定义指令

现在我们已经理解了自定义指令，现在开始研究如何使用一个自定义指令，让我们用第一个例子来实现我们刚才所说的：

```js
Vue.directive('tack',{
    bind(el,binding,vnode){
        el.style.position = 'fixed'
    }
})
```
相对应的HTML就是：

```html
<p v-tack>I will now be tacked onto the page</p>
```

这样是可以的，但是如果不传值不更新不复用的话就会显得太不灵活了，让我们看下如何实现让这个元素离页面顶部有一定的距离：

Js
```js
Vue.directive('tack',{
    bind(el,binding,vnode){
        el.style.position = 'fixed';
        el.style.top = binding.value + 'px';
    }
})
```

HTML
```html
<div id="app">
    <p>Scroll down the page</p>
    <p v-tack="70">stick me 70px from the top of page</p>
</div>
```

完成后的CodePen展示：

<iframe id="cp_embed_0959829d6dfd86f6a1e06be2fd424ec7" src="//codepen.io/sdras/embed/0959829d6dfd86f6a1e06be2fd424ec7?height=265&amp;theme-id=1&amp;slug-hash=0959829d6dfd86f6a1e06be2fd424ec7&amp;default-tab=result&amp;user=sdras&amp;embed-version=2&amp;pen-title=Simple%20custom%20directive" scrolling="no" frameborder="0" height="265" allowtransparency="true" allowfullscreen="true" name="CodePen Embed" title="Simple custom directive" class="cp_embed_iframe " style="width: 100%; overflow: hidden; height: 100%;"></iframe>

假设我们想要区分是否偏离顶部或者左边的70px,可以通过传递一个参数来实现：

HTML

```html
<p v-tack:left="70">I‘ll now be offset from the left instead of the top</p>
```

JS

```js
Vue.directive('tack',{
    bind(el,binding,vnode){
        el.style.position = 'fixed';
        const s = (binding.arg == 'left'?'left':top);
        el.style[s] = binding.value + 'px';
    }
})
```

完成后的CodePen展示：

<iframe id="result-iframe" sandbox="allow-scripts allow-pointer-lock allow-same-origin allow-popups allow-modals allow-forms" src="https://s.codepen.io/sdras/fullembedgrid/4dfeb0b4f8ac1158236d3b9fea71cc9a?type=embed&amp;animations=run" allowtransparency="true" frameborder="0" scrolling="yes" allowfullscreen="true" name="CodePen Preview for Simple directive with arg" title="CodePen Preview for Simple directive with arg" data-src="https://s.codepen.io/sdras/fullembedgrid/4dfeb0b4f8ac1158236d3b9fea71cc9a?type=embed&amp;animations=run"></iframe>

你也可以使用多个值，像常规指令一样用：

HTML

```html
<p v-tack="{top:'40',left:'100'}">Stick me 40px from the top of the page and 100px from the left of the page</p>
```

然后将会有两个值同时作用于该指令：

JS

```js
Vue.directive('tack',{
    bind(el,binding,vnode){
        el.style.position = 'fixed';
        el.style.top = binding.value.top+'px';
        el.style.left = binding.value.left+'px';
    }
})
```

完成后的CodePen展示：

<iframe id="cp_embed_b307a9dd0449ad8563fb489d9ae4ab95" src="//codepen.io/sdras/embed/b307a9dd0449ad8563fb489d9ae4ab95?height=265&amp;theme-id=1&amp;slug-hash=b307a9dd0449ad8563fb489d9ae4ab95&amp;default-tab=result&amp;user=sdras&amp;embed-version=2&amp;pen-title=Simple%20directive%20with%20two%20values" scrolling="no" frameborder="0" height="265" allowtransparency="true" allowfullscreen="true" name="CodePen Embed" title="Simple directive with two values" class="cp_embed_iframe " style="width: 100%; overflow: hidden; height: 100%;"></iframe>

我们还可以编写更复杂的东西，我们可以根据自定义指令来创建和修改方法。这里，我们用少量的代码来创建一个滚动时的动画来做一个示例：

JS

```js
Vue.directive('scroll',{
    inserted:function(el,binding){
        let f = function(evt){
            if(binding.value(evt,el)){
                 window.removeEventListener(‘scroll’,f);
            }
        }
        window.addEventListener('scroll',f);
    }
});

//main app

new Vue({
    el:'#app',
    methods:{
        handleScroll:function(evt,el){
            if(window.scrollY>50){
                TweenMax.to(el,1.5,{
                    y:-10,
                    opacity:1,
                    ease:sine.easeOut
                })
            }
            return window.scrollY>100;
        }
    }
});
```

HTML

```html
<div class="box" v-scroll="handleScroll">
    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. A atque amet harum aut ab veritatis earum porro praesentium ut corporis. Quasi provident dolorem officia iure fugiat, eius mollitia sequi quisquam.</p>
</div>
```

完成后的CodePen展示：

<iframe id="result-iframe" sandbox="allow-scripts allow-pointer-lock allow-same-origin allow-popups allow-modals allow-forms" src="https://s.codepen.io/sdras/fullembedgrid/5ca1e0c724d7d900603d8898b5551189?type=embed&amp;animations=run" allowtransparency="true" frameborder="0" scrolling="yes" allowfullscreen="true" name="CodePen Preview for Custom Scroll Directive" title="CodePen Preview for Custom Scroll Directive" data-src="https://s.codepen.io/sdras/fullembedgrid/5ca1e0c724d7d900603d8898b5551189?type=embed&amp;animations=run"></iframe>

以上，我们都是用很简单的代码让大家看起来很容易，在实际的应用中，你可以为你的团队项目创建更高级灵活的自定义指令。

在一个实际的构建过程中，我们将指令代码放在`“main.js”`中，这个文件位于`“src”`目录的根目录下（如果你使用的是Vue-cli版本）的`"App.vue"`和其他应用程序里。components目录里的`.vue`文件都可以引入它。同时其他的方法也可以使用它，这是自定义指令在整个应用程序里最灵活的体现。

如果你想了解有关Vue框架的更多知识，请查看[guide](https://css-tricks.com/guides/vue/).

原文：[The Power of Custom Directives in Vue](https://css-tricks.com/power-custom-directives-vue/)

作者：[SARAH DRASNER ](https://css-tricks.com/author/sdrasner/)

译者：[Diandian]()
