---
title: 【译】vue 自定义指令的魅力
subtitle: 在你初次接触一个新的Javascript框架时，会像第一次进糖果店的孩子一样。
date: 2017-10-31 10:00
categories: [前端]
tags: [JS,技术]
author: Diandian
---

在你初次接触一个新的Javascript框架时，会像第一次进糖果店的孩子一样。给啥拿啥，而更直接点，有些东西可以让你更容易成为一个开发者。不可避免的是，我们在用框架时都会有一个同感，就是总有些场景是框架不能帮我们完成的。

[Vue](https://vuejs.org/)框架的漂亮之处在于它的功能非常强大，虽然这个框架的指令不够面面俱到，但也能在开发上助你一臂之力了，因为创建一个自定义指令是很轻松的。

<!-- more -->

## 什么是指令？

我在[Vue.js guide](https://css-tricks.com/guides/vue/)中写过指令的一篇[文章](https://css-tricks.com/intro-to-vue-1-rendering-directives-events/)，现在再一起复习下。

指令是可以写在DOM元素的小命令，他们以`v-`为前缀，vue就能识别这是一个指令并保持语法的一致性。如果你需要对HTML进行底层操作的话，这种方式是非常有用的。

如果你已经用过vue或者angular的话，对于`v-if`,`v-else`,`v-show`等指令就会比较熟悉了，但是我还是要介绍一些基础的知识，如果你更想直接看例子，可以直接看后文就好了。

以下是使用指令的几种方法，以及示例，这些例子并不规范，它们只是示例。这里的`example`代替了实际的指令。

`v-example` - 会实例化一个指令，但这个指令没有参数。如果不传参数会比较不灵活，但是这样就已经操作DOM元素的能力了。

`v-example="value"` - 这样可以传值到指令中，指令会根据`value`值来操作html。

```html
<div v-if="stateExample">stateExample为true时会显示</div>
```

`v-example="'string'"` - 使用字符串作为表达式。

```html
<p v-html="'<strong>this is an example of a string in some text<strong> '"></p>
```

`v-example:arg="value"` - 这里可以传参数（`arg`），在下面的例子中，我们绑定一个`class`，然后给这个`class`设置样式。


```html
<div v-bind:class="someClassObject"></div>
```

`v-example:arg.modifier="value"` - 使用修饰符（`modifier`），下面的例子可以在`click`事件上调用`preventDefault()`;

```html
<button v-on:submit.prevent="onSubmit"></button>
```

## 了解自定义指令

现在对指令有了大概的了解后，我们再来学习下如何创建一个自定义指令。自定义指令的典型例子就是创建一个`scroll`事件的指令，下面让我们一起来看一下。

首先创建一个单纯的全局指令（它还没有做任何事情）。

```javascript
vue.directive('tack');
```

根据这个指令HTML就是这样的：

```html
<p v-tack>This element has a directive on it</p>
```

指令定义函数提供了几个钩子函数 (可选)：

1. `bind`-只调用一次，指令第一次绑定到元素时调用。
2. `insert`-被绑定元素插入父节点时调用。
3. `update`-所在组件的 VNode 更新时调用，但是可能发生在其子元素的 VNode 更新之前。
4. `componentUpdated`-所在组件的 VNode 及其子元素的 VNode 全部更新时调用。
5. `unbind`-只调用一次，指令与元素解绑时调用。

![hookArguments](/images/2017-10-31-vue-cutom-directive/01.svg)

我认为这五个钩子函数中`bind`和`update`是最有用的。

他们中的每一个都有可以用的`el`,`binding`和`vnode`参数，除了`update`和`componentUpdated`之外，还会暴露`oldVnode`，以区分传递的旧值和新值。

- `el` 指令所绑定的元素，可以用来直接操作 DOM 。
- `binding` 一个对象，包含以下属性：`name`,`value`,`oldValue`,`expression`,`arg`和`modifiers`。
- `vnode` Vue 编译生成的虚拟节点。

`binding`和`vnode`都是只读。

## 创建一个自定义指令

了解了自定义指令概念后，来看下如何使用一个自定义指令，下面用一个例子来实现我们刚才所说的：

```javascript
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

这样就可以了，但是还不够灵活。如果能接受参数以便后续更新它的表现或者进行复用的话就会更加灵活。让我们看下如何实现让这个元素离页面顶部有一定的距离：

```javascript
Vue.directive('tack',{
    bind(el,binding,vnode){
        el.style.position = 'fixed';
        el.style.top = binding.value + 'px';
    }
})
```

```html
<div id="app">
    <p>向下滚动页面</p>
    <p v-tack="70">我固定在离顶部70px的地方</p>
</div>
```

完成后的CodePen展示：(如无法展示效果，点击[链接](https://codepen.io/sdras/pen/0959829d6dfd86f6a1e06be2fd424ec7)查看)

<iframe id="cp_embed_0959829d6dfd86f6a1e06be2fd424ec7" src="//codepen.io/sdras/embed/0959829d6dfd86f6a1e06be2fd424ec7?height=265&amp;theme-id=1&amp;slug-hash=0959829d6dfd86f6a1e06be2fd424ec7&amp;default-tab=result&amp;user=sdras&amp;embed-version=2&amp;pen-title=Simple%20custom%20directive" scrolling="no" frameborder="0" height="265" allowtransparency="true" allowfullscreen="true" name="CodePen Embed" title="Simple custom directive" class="cp_embed_iframe " style="width: 100%; overflow: hidden; height: 100%;"></iframe>

假设我们想要区分偏离的70px是在顶部还是左侧，可以通过传递一个参数来实现：

```html
<p v-tack:left="70">现在我会在距离左侧70px的地方</p>
```

```javascript
Vue.directive('tack',{
    bind(el,binding,vnode){
        el.style.position = 'fixed';
        const s = (binding.arg == 'left'?'left':top);
        el.style[s] = binding.value + 'px';
    }
})
```

完成后的CodePen展示：(如无法展示效果，点击[链接](https://codepen.io/sdras/pen/4dfeb0b4f8ac1158236d3b9fea71cc9a)查看)

<iframe id="result-iframe" sandbox="allow-scripts allow-pointer-lock allow-same-origin allow-popups allow-modals allow-forms" src="https://s.codepen.io/sdras/fullembedgrid/4dfeb0b4f8ac1158236d3b9fea71cc9a?type=embed&amp;animations=run" allowtransparency="true" frameborder="0" scrolling="yes" allowfullscreen="true" name="CodePen Preview for Simple directive with arg" title="CodePen Preview for Simple directive with arg" data-src="https://s.codepen.io/sdras/fullembedgrid/4dfeb0b4f8ac1158236d3b9fea71cc9a?type=embed&amp;animations=run"></iframe>

你也可以使用多个值，像自带指令一样用：

```html
<p v-tack="{top:'40',left:'100'}">我固定在离顶部40px、左侧100px的地方</p>
```

然后这两个值将会在指令上同时生效：

```javascript
Vue.directive('tack',{
    bind(el,binding,vnode){
        el.style.position = 'fixed';
        el.style.top = binding.value.top+'px';
        el.style.left = binding.value.left+'px';
    }
})
```

完成后的CodePen展示：(如无法展示效果，点击[链接](https://codepen.io/sdras/pen/b307a9dd0449ad8563fb489d9ae4ab95)查看)

<iframe id="cp_embed_b307a9dd0449ad8563fb489d9ae4ab95" src="//codepen.io/sdras/embed/b307a9dd0449ad8563fb489d9ae4ab95?height=265&amp;theme-id=1&amp;slug-hash=b307a9dd0449ad8563fb489d9ae4ab95&amp;default-tab=result&amp;user=sdras&amp;embed-version=2&amp;pen-title=Simple%20directive%20with%20two%20values" scrolling="no" frameborder="0" height="265" allowtransparency="true" allowfullscreen="true" name="CodePen Embed" title="Simple directive with two values" class="cp_embed_iframe " style="width: 100%; overflow: hidden; height: 100%;"></iframe>

我们还可以编写更复杂的东西，我们可以根据自定义指令来创建和修改方法。这里，我们简单创建一个滚动动画小例子：

```javascript
Vue.directive('scroll',{
    inserted:function(el,binding){
        let f = function(evt){
            if(binding.value(evt,el)){
                 window.removeEventListener('scroll',f);
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

```html
<div class="box" v-scroll="handleScroll">
    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. A atque amet harum aut ab veritatis earum porro praesentium ut corporis. Quasi provident dolorem officia iure fugiat, eius mollitia sequi quisquam.</p>
</div>
```

完成后的CodePen展示：(如无法展示效果，点击[链接](https://codepen.io/sdras/pen/5ca1e0c724d7d900603d8898b5551189)查看)

<iframe id="result-iframe" sandbox="allow-scripts allow-pointer-lock allow-same-origin allow-popups allow-modals allow-forms" src="https://s.codepen.io/sdras/fullembedgrid/5ca1e0c724d7d900603d8898b5551189?type=embed&amp;animations=run" allowtransparency="true" frameborder="0" scrolling="yes" allowfullscreen="true" name="CodePen Preview for Custom Scroll Directive" title="CodePen Preview for Custom Scroll Directive" data-src="https://s.codepen.io/sdras/fullembedgrid/5ca1e0c724d7d900603d8898b5551189?type=embed&amp;animations=run"></iframe>

以上都是很简单的代码来实现效果，在实际的开发中，你可以创建更高级灵活的自定义指令。

在一个实际构建过程中，我会将指令代码放在`main.js`中，这个文件位于`src`目录下（如果你使用的是vue-cli这样的工具的话），这样`App.vue`及以`.vue`后缀名的文件都可以引入使用。你当然也可以使用其他的方式，但这是我认为在实现整个App过程中最灵活的方式。

如果你想了解有关Vue框架的更多知识，请查看[guide](https://css-tricks.com/guides/vue/).

原文：[The Power of Custom Directives in Vue](https://css-tricks.com/power-custom-directives-vue/)

作者：[SARAH DRASNER ](https://css-tricks.com/author/sdrasner/)

译者：[Diandian](https://futu.im/author/Diandian)
