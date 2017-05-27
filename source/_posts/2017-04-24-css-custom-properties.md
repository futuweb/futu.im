---
title: 【译】下一代CSS--CSS自定义属性(CSS变量)使用
date: 2017-04-24 10:30
category: 翻译
tags: [CSS,技术]
author: Jin
---

今日，在web开发中使用css预处理器已经成为一种标准。预处理器其中最大的优势就是可以让开发者自定属性。
这可以有效的帮助你避免复制和粘贴代码，并且它简化了开发和重构。

我们使用预处理器来保存颜色，字体参数，布局详情 -- 一些我们在CSS中经常使用到的东西。

但是预处理器变了有一些不足之处：
1. 你不能动态的改变它们；
2. 它们没有`DOM`结构方面的能力；
3. 它们不能被`JavaScript`读取和改变。

作为这些和其他问题的银弹,社区发明CSS自定义属性。本质上，它们看起来和工作都很像`CSS`变量，命名也是非常的语义化。

自定义属性为web开发开辟了一片新的天地。

进一步阅读:
* [自定义元素详细介绍](https://www.smashingmagazine.com/2014/03/introduction-to-custom-elements/)
* [Houdini: 你可能没有听过那些在`CSS`开发中令人兴奋的事](https://www.smashingmagazine.com/2016/03/houdini-maybe-the-most-exciting-development-in-css-youve-never-heard-of/)
* [加速你的页面的11个技巧：你需要知道所有关于谷歌加速移动页面的技巧](https://www.smashingmagazine.com/2016/02/everything-about-google-accelerated-mobile-pages/)
* [一个更好的iOS架构:深入理解模型-视图-控制器模式](https://www.smashingmagazine.com/2016/05/better-architecture-for-ios-apps-model-view-controller-pattern/)

<!-- more -->

## 语法：自定义属性声明和使用
最普遍的问题就是当你学习一个新的预处理器或者一个新框架的时候都必须去学习新的语法。

每个预处理器都会使用不同的方式去声明变量。通常，都会以一个通配符开始--例如，Sass的`$`和LESS的`@`。

CSS自定义属性已相同的方式并且以`--`开头引入一个声明属性。但好处是你只需学习这个语法一次并且它是跨浏览器的。

你可能会问，“为什么不使用一个已经存在的语法？”

[查看原因](http://www.xanthir.com/blog/b4KT0)，简单来说，它提供了一个方式来使用自定义属性在任何的预处理器中。这种方式，我们可以提供和使用自定义属性，并且我们的预处理器将不会编译它们，所以这些属性将会被直接输出到CSS中。并且你可以在预处理器复用这些原生的每一个变量，我将在下文进行描述。

> 关于这个名字：因为寓意和目标非常相似，有时候自定义属性被叫做CSS变量，虽然正确的名字是CSS自定义属性，继续阅读，你会发现这样描述它们会更好。

所以，定义一个变量而不是一个普通的CSS属性如`color`或者`padding`,只需要提供一个自定义名称属性以`--`开头：

```css
.box{
  --box-color:#4d4e53;
  --box-padding:0 10px;
}
```

属性的值可以是任意有效的CSS值：颜色，字符串，布局值，甚至是表达式。

有效的自定义属性例子：

```css
:root{
  --main-color: #4d4e53;
  --main-bg: rgb(255, 255, 255);
  --logo-border-color: rebeccapurple;

  --header-height: 68px;
  --content-padding: 10px 20px;

  --base-line-height: 1.428571429;
  --transition-duration: .35s;
  --external-link: "external link";
  --margin-top: calc(2vh + 20px);

  /* Valid CSS custom properties can be reused later in, say, JavaScript. */
  --foo: if(x > 5) this.width = 10;
}
```

这个案例中你不能保证`:root`会被匹配到，在HTML的那些具有更高特性的`html`中会被匹配到。

与其它的CSS属性相比，自定义属性有相同的层级关系但是是动态的。这意味着他们可以随时改变,并且由浏览器来处理相应的改变。

使用变量的时候，你必须使用CSS的`var()`函数并且传入对应的属性名称：

```css
.box{
  --box-color:#4d4e53;
  --box-padding: 0 10px;

  padding: var(--box-padding);
}
.box div{
  color: var(--box-color);
}
```

### 变量声明及使用案例
`var()`函数有一种方便的使用方式可以提供默认值。假如你不确定自定义属性什么时候被定义并且需要提供一个值作为后备时你就应该使用。很简单只需要传入第二个参数即可：

```css
.box{
  --box-color:#4d4e53;
  --box-padding: 0 10px;
  /* 10px is used because --box-margin is not defined. */
  margin: var(--box-margin, 10px);
}
```

和你想的一样，你可以覆盖原有变量的声明为新的变量：

```css
.box{
  /* The --main-padding variable is used if --box-padding is not defined. */
  padding: var(--box-padding, var(--main-padding));
  --box-text: 'This is my box';
  /* Equal to --box-highlight-text:'This is my box with highlight'; */
  --box-highlight-text: var(--box-text)' with highlight';
}
```

## 操作符: +, -, *, /
我们在对变量进行操作时想使用基本的操作，这与我们习惯了的预处理器和其他语言一样。对于这个，CSS提供了`calc()`函数，这使得浏览器会在自定义属性的值发生改变的时候重新执行表达式：

```css
:root{
  --indent-size: 10px;
  --indent-xl: calc(2*var(--indent-size));
  --indent-l: calc(var(--indent-size) + 2px);
  --indent-s: calc(var(--indent-size) - 2px);
  --indent-xs: calc(var(--indent-size)/2);
}
```

如果你试着使用少单位的值这是有问题的。但是，`calc()`比较友好，会正常执行，`var()`不会执行：

```css
:root{
  --spacer: 10;
}
.box{
  padding: var(--spacer)px 0; /* DOESN'T work */
  padding: calc(var(--spacer)*1px) 0; /* WORKS */
}
```

## 作用域和继承
在开始讨论CSS自定义属性的作用域，先让我们回顾一下JavaScript和预处理器的作用域，这样可以更好的理解其中的不同。

我们知道，例如，JavaScript变量（`var`）, 函数限制作用范围。

使用`let`和`const`我们有一个类似的情况，但是它们是局部的块级作用域变量。

一个`JavaScript`闭包可用访问外部的函数变量--作用域链。闭包有3个作用域链，它可以通过以下方式：

* 自己的作用域
* 外部函数作用域变量
* 全局作用域变量

![javaScript closure](/images/2017-04-24-css-custom-properties/0422_01.jpg)

这个比喻和预处理器很相似。让我们来使用一下Sass因为今天它可能已经很普遍了。

在Sass中，有2种类型的变量：本地和全局。

一个全局变量可以被声明以为的任意选择器或者方式使用（例如：`mixin`）。另外，其它变量为局部变量。

任何嵌套块代码可以访问上级变量（在 JavaScript中）。

![sass variable](/images/2017-04-24-css-custom-properties/0422_02.jpg)

这就意味着，在Sass中,变量的作用域完全依赖于代码的结构。

然而，CSS自定义属性默认是继承的，就像其它的CSS属性一样，通过它们的级联关系。

你通常不可能会有一个自定义属性的全局变量是声明在选择器之外的--这是无效的在CSS里。自定义的CSS属性的全局作用域是定义在`:root`中的，因此属性是全局有效的。

让我们使用自己的语法知识来编写HTML和CSS的Sass案例。我们将使用原生的CSS自定义属性创建demo。首先HTML:

```html
global
<div class="enclosing">
  enclosing
  <div class="closure">
    closure
  </div>
</div>
```

这是对应的CSS:

```css
:root {
  --globalVar: 10px;
}
.enclosing {
  --enclosingVar: 20px;
}
.enclosing .closure {
  --closureVar: 30px;
  font-size: calc(var(--closureVar) + var(--enclosingVar) + var(--globalVar));
  /* 60px for now */
}
```

### 自定义属性更改会立即应用到所有实例
到目前为止,我们还没有看到任何和Sass变量不同的地方。然而,让我们在使用变量后重新给他赋值：

在这个Sass案例中，这没有影响：

```sass
$closureVar: 30px; // local variable
font-size: $closureVar +$enclosingVar+ $globalVar;
// 60px, $closureVar: 30px is used
$closureVar: 50px; // local variable
```

但是在CSS中，计算的值会改变，因为`font-size`的值时重新计算的通过改变`--closureVar`的值：

```css
.enclosing .closure {
  --closureVar: 30px;
  font-size: calc(var(--closureVar) + var(--enclosingVar) + var(--globalVar));
  /* 80px for now, --closureVar: 50px is used */
  --closureVar: 50px;
}
```

这是第一个巨大的差异：如果你重新给一个自定义属性赋值，浏览器会重新计算所有的变量并且`calc()`表达式会被调用。

### 预处理器不会和DOM结构有关联关系
假设我们想要使用的默认`font-size`字体大小,除了`highlighted`class存在的地方。

HTML这样写:
```html
<div class="default">
  default
</div>
<div class="default highlighted">
  default highlighted
</div>
```

CSS我们使用自定义属性：

```css
.highlighted {
  --highlighted-size: 30px;
}
.default {
  --default-size: 10px;
  /* Use default-size, except when highlighted-size is provided. */
  font-size: var(--highlighted-size, var(--default-size));
}
```

因为第二个HTML元素的`default`的class后面紧跟着`highlighted`class，`highlighted`class里面的属性会被应用到元素上。

这个案例中，意味着`--highlighted-size: 30px;`将被应用，也就是说`font-size`属性将使用`--highlighted-size`的值。

现在,让我们尝试使用Sass实现同样的事情:

```sass
.highlighted {
  $highlighted-size: 30px;
}
.default {
  $default-size: 10px;
  /* Use default-size, except when highlighted-size is provided. */
  @if variable-exists(highlighted-size) {
    font-size: $highlighted-size;
  }
  @else {
    font-size: $default-size;
  }
}
```

这是因为所有Sass计算和处理发生在编译时间,当然,它不知道任何关于DOM结构,完全依赖于代码的结构。

就像你看到的一样，自定义属性在变量作用域和CSS属性添加到级联关系中都是有优势，DOM结构关联以及遵循CSS规则和其它属性一样。


第二部分我们要讨论的话题是DOM结构关联和动态性。

## CSS-关键词和`all`属性
CSS自定义属性是服从相同的CSS规则在使用CSS自定义属性的时候。这意味着你可以分配人意的通用的CSS关键字给它：

* `inherit`
    使用这个CSS关键字的值将继承父亲元素
*  `initial`
    这个值在CSs文档中有详细描述（在这个案例中自定义属性是空的值）
*  `unset`
    使用这个继承的值如果属性是普通继承（在案例中是自定义属性）或者初始化值如果属性没有使用继承。
*  `revert`
    这个重置属性默认值建立在客户端的样式表上（在这个案例中自定义属性是空的值）

这里有个例子：

```css
.common-values{
  --border: inherit;
  --bgcolor: initial;
  --padding: unset;
  --animation: revert;
}
```

考虑其它案例。假设你想创建一个组件并且想确认没有其它的样式或自定义属性被无意的应用到这里（一个模块化的CSS解决方案在这种情况下通常被用于样式）

但是现在这里有另外的方式：使用`all`[CSS属性](https://developer.mozilla.org/en/docs/Web/CSS/all)。这可以快速重置CSS属性。

同样使用CSS关键字，我们可以这样做：

```css
.my-wonderful-clean-component{
  all: initial;
}
```

这个可以重置我们所有的组件。

不幸的是，`all`关键字[不能重置自定义属性](https://drafts.csswg.org/css-variables/#defining-variables)。有一个[正在进行的讨论](https://github.com/w3c/webcomponents/issues/300#issuecomment-144551648)是否要添加`--`前缀,将重置所有CSS自定义属性。

因此,在未来,一个完整的重置可能是这样的:

```css
.my-wonderful-clean-component{
  --: initial; /* reset all CSS custom properties */
  all: initial; /* reset all other CSS styles */
}
```


## CSS自定义属性的用例
有许多使用的自定义属性。我将展示最有趣的。

### 模仿不存在的CSS规则
这些CSS变量的名称是“自定义属性”,那么为什么不使用它们来模拟不存在的属性呢?

这里有很多: `translateX/Y/Z`,`background-repeat-x/y`(还没有跨浏览器兼容的),`box-shadow-color`。

让我们试着让最后一个属性工作。在我们的案例中，当鼠标放上去的时候改变盒子的影子的颜色。我们只想遵循DRY原则（不重复`boxshadw`属性），所以不会改变`:hover`部分的整个`box-shadow`的值，我们只需要修改自定义属性的值：

```css
.test {
  --box-shadow-color: yellow;
  box-shadow: 0 0 30px var(--box-shadow-color);
}
.test:hover {
  --box-shadow-color: orange;
  /* Instead of: box-shadow: 0 0 30px orange; */
}
```

### 颜色主题
一个最普遍的案例就是使用自定义属性来定义应用程序的主题颜色。自定义属性可以用来解决这类问题。因此，提供一个简单的颜色主题给组件。

这里是我们[按钮组件的代码](https://codepen.io/malyw/pen/XpRjNK):

```css
.btn {
  background-image: linear-gradient(to bottom, #3498db, #2980b9);
  text-shadow: 1px 1px 3px #777;
  box-shadow: 0px 1px 3px #777;
  border-radius: 28px;
  color: #ffffff;
  padding: 10px 20px 10px 20px;
}
```

假设我们想要切换颜色主题。

首先，我们将所有的颜色变量扩展为自定义CSS属性并且从写我们的组件。因此，[结果是一样的](https://codepen.io/malyw/pen/EZmgmZ)：

```css
.btn {
  --shadow-color: #777;
  --gradient-from-color: #3498db;
  --gradient-to-color: #2980b9;
  --color: #ffffff;

  background-image: linear-gradient(
    to bottom,
    var(--gradient-from-color),
    var(--gradient-to-color)
  );
  text-shadow: 1px 1px 3px var(--shadow-color);
  box-shadow: 0px 1px 3px var(--shadow-color);
  border-radius: 28px;
  color: var(--color);
  padding: 10px 20px 10px 20px;
}
```

这一切是我们所需要的。这样，我们可以覆盖颜色变量为指定的切换颜色并且在需要的时候应用它们。例如，我们可以添加一个全局的切换HTML主题的`inverted`的class（添加在`body`元素）并且在应用的时候改变颜色：

```css
body.inverted .btn{
  --shadow-color: #888888;
  --gradient-from-color: #CB6724;
  --gradient-to-color: #D67F46;
  --color: #000000;
}
```

这中行为在不能有重复代码的前提下CSS预处理器是没办法实现的。预处理器,你总是需要覆盖的实际值和规则,这经常导致额外的CSS。

CSS自定义属性,解决方案是尽可能的干净,避免复制和粘贴,因为只重新定义变量的值。


## 在JavaScript中使用CSS自定义属性
以前，从CSS发送数据到JavaScript时,我们常常不得不求助于[技巧](https://blog.hospodarets.com/passing_data_from_sass_to_js),通过写入纯CSS的JSON格式的值,然后从JavaScript读取它。

现在,我们可以很容易地使用JavaScript读取CSS变量，分别使用我们熟知的`.getPropertyValue()`方法和`.setProperty()`方法进行读取和写入，像平常的CSS属性一样使用:

```js
/**
* Gives a CSS custom property value applied at the element
* element {Element}
* varName {String} without '--'
*
* For example:
* readCssVar(document.querySelector('.box'), 'color');
*/
function readCssVar(element, varName){
  const elementStyles = getComputedStyle(element);
  return elementStyles.getPropertyValue(`--${varName}`).trim();
}

/**
* Writes a CSS custom property value at the element
* element {Element}
* varName {String} without '--'
*
* For example:
* readCssVar(document.querySelector('.box'), 'color', 'white');
*/
function writeCssVar(element, varName, value){
  return element.style.setProperty(`--${varName}`, value);
}
```

假设我们有一个媒体查询列表值:

```css
.breakpoints-data {
  --phone: 480px;
  --tablet: 800px;
}
```

因为我们只是想重用它们在JavaScript中——例如,在`Window.matchMedia()`,我们可以很容易地从CSS中获取它们:

```js
const breakpointsData = document.querySelector('.breakpoints-data');

// GET
const phoneBreakpoint = getComputedStyle(breakpointsData)
  .getPropertyValue('--phone');
```

JavaScript如何操控自定义属性,我创建了一个交互式3D的CSS立方体演示,响应用户的操作。

它不是很困难。我们只需要添加一个简单的背景颜色，然后将五个立方体面临的相关值进行变换使用`transform`属性:`translateZ()`,`translateY()`,`rotateX()`和`rotateY()`。

为了提供正确的视角,我添加了一个页面容器:

```css
#world{
  --translateZ:0;
  --rotateX:65;
  --rotateY:0;

  transform-style:preserve-3d;
  transform:
    translateZ(calc(var(--translateZ) * 1px))
    rotateX(calc(var(--rotateX) * 1deg))
    rotateY(calc(var(--rotateY) * 1deg));
}
```

唯一缺少的是交互性。demo在鼠标移动的时候需要改变X和Y视角（`--rotateX` 和 `--rotateY`)并且鼠标滚动时要放大和缩小(`--translateZ`)。

这是JavaScript的代码:

```js
// Events
onMouseMove(e) {
  this.worldXAngle = (.5 - (e.clientY / window.innerHeight)) * 180;
  this.worldYAngle = -(.5 - (e.clientX / window.innerWidth)) * 180;
  this.updateView();
};
onMouseWheel(e) {
  /*…*/

  this.worldZ += delta * 5;
  this.updateView();
};
// JavaScript -> CSS
updateView() {
  this.worldEl.style.setProperty('--translateZ', this.worldZ);
  this.worldEl.style.setProperty('--rotateX', this.worldXAngle);
  this.worldEl.style.setProperty('--rotateY', this.worldYAngle);
};
```

从本质上讲,我们已经改变了CSS自定义属性的值。其他(旋转和缩放)是由CSS。

提示：一个最简单的办法调试CSS自定义属性的值就是把它的值展示到当前的CSS内容里面（例如字符串),那么浏览器将自动显示当前应用的值：

```css
body:after {
  content: '--screen-category : 'var(--screen-category);
}
```

你可以查看这个[CSS演示](https://codepen.io/malyw/pen/oBWMOY)(没有HTML或JavaScript)。(调整窗口的浏览器自动反映CSS定义属性值更改。)

## 浏览器支持
[所有的主流浏览器已经支持](http://caniuse.com/#feat=css-variables)CSS自定义属性：

![css-variables](/images/2017-04-24-css-custom-properties/0422_03.jpg)


意味着,你可以开始使用它们。

如果你需要支持老式浏览器,你可以学习语法和用法示例,考虑可能的切换方法或同时使用CSS自定义属性和预处理器变量。


当然,我们需要能够检测支持CSS和JavaScript提供后备或增强。

这是很简单的。对于CSS,可以使用一个虚拟`@supports[条件](https://developer.mozilla.org/en/docs/Web/CSS/@supports)查询功能:

```css
@supports ( (--a: 0)) {
  /* supported */
}
@supports ( not (--a: 0)) {
  /* not supported */
}
```

在JavaScript中,可以使用相同的CSS.supports()静态方法查询自定义属性:

```js
const isSupported = window.CSS &&
    window.CSS.supports && window.CSS.supports('--a', 0);

if (isSupported) {
  /* supported */
} else {
  /* not supported */
}
```

我们看到,CSS自定义属性仍然不支持所有的浏览器。知道了这一点,你可以逐步提高你的应用程序通过检查它们是否支持CSS自定义属性。

例如，你可以生成2份CSS文件：一份包含CSS自定义属性另一份不包含它们，在内联属性中(不久我们将讨论)。


默认加载没有包含CSS自定义属性的样式的文件。然后通过JavaScript判断是否支持CSS自定义属性来进行切换版本：

```html
<!-- HTML -->
<link href="without-css-custom-properties.css"
    rel="stylesheet" type="text/css" media="all" />
```

```js
// JavaScript
if(isSupported){
  removeCss('without-css-custom-properties.css');
  loadCss('css-custom-properties.css');
  // + conditionally apply some application enhancements
  // using the custom properties
}
```

这只是一个例子。下面您将看到,有更好的选择。

## 怎么开始使用它们
根据最近的[调查](https://ashleynolan.co.uk/blog/frontend-tooling-survey-2016-results),Sass依然是开发社区预处理器的首选。

因此,让我们考虑如何开始在Sass中使用CSS自定义属性使或准备它们。

我们有以下选择。

### 1.手动检查代码的支持
这个方法的一个优点的手动检查代码是否支持自定义属性是它工作,我们现在能做的就是使用这个方法(别忘了我们现在在使用Sass):

```sass
$color: red;
:root {
  --color: red;
}
.box {
  @supports ( (--a: 0)) {
    color: var(--color);
  }
  @supports ( not (--a: 0)) {
    color: $color;
  }
}
```

这个方法有许多缺点,尤其是代码变得复杂,并复制和粘贴变得相当难以维护。


### 2.使用一个插件,自动生成目标CSS
今天PostCSS生态系统提供了很多的插件。一半以上的对自定义属性都可以保证输出的CSS正常工作，假设你只提供全局变量(即你只声明或改变CSS内自定义属性`:root`选择器),所以他们的值很容易内联化。


案例：[postcss-custom-properties](https://github.com/postcss/postcss-custom-properties).

这个插件提供了几个优点:它使语法工作;PostCSS兼容所有的基础设施,它不需要配置。

然而，这也有缺点。这个插件需要您使用CSS定义属性，所以，而你的项目并没有准备从使用Sass变量中切换过来。同样,你不会有多大的控制转换,因为它是在Sass完成编译之后操作CSS。最后，插件没有提供很多的调试信息。


### 3.[CSS-VARS MIXIN](https://github.com/malyw/css-vars)
在我的大多数项目中，我已经开始使用CSS自定义属性并且尝试了许多策略:

1. 从Sass切换到下一代CSS在使用PostCss前提下。
2. 从Sass变量转换到纯CSS自定义属性。
3. 使用CSS变量Sass检测它们是否支持。

根据以上的经验,我开始寻找一个解决方案,来满足我的要求:

1. 在Sass中需要使用简单。
2. 它应该直接使用,语法必须尽可能接近原生CSS自定义属性。
3. 内联CSS输出值切换到CSS变量应该很容易。
4. 团队成员熟悉CSS可以使用自定义属性的解决方案。
5. 应该有一个方法对使用的变量的边界情况有调试信息。

因此,我创建了`css-vars`,`Sass mixin`,你可以在[Github上](https://github.com/malyw/css-vars)找到。使用它,你可以开始使用CSS自定义属性的语法。


## 使用css-vars Mixin
声明变量(s),使用mixin如下:

```sass
$white-color: #fff;
$base-font-size: 10px;

@include css-vars((
  --main-color: #000,
  --main-bg: $white-color,
  --main-font-size: 1.5*$base-font-size,
  --padding-top: calc(2vh + 20px)
));
```

使用这些变量,使用var()函数:

```css
body {
  color: var(--main-color);
  background: var(--main-bg, #f00);
  font-size: var(--main-font-size);
  padding: var(--padding-top) 0 10px;
}
```

这给了你一种可以控制CSS都是从一个文件输出的能力(从Sass)并开始熟悉语法。另外,您可以重用Sass变量与mixin和逻辑。

当你想要支持的浏览器使用CSS变量,那么所有你要做的就是在Sass中添加支持:

```sass
$css-vars-use-native: true;
```

而不是在完成编译的CSS中调整,因为mixin将开始注册自定义属性,var()实例产生的CSS没有任何转换。这意味着你必须完全转向CSS定制属性,我们已经讨论了所有的优势。

如果你想打开有用的调试信息,添加以下:

```sass
$css-vars-debug-log: true;
```

这将给你:

* 使用未定义变量，写log。
* 重新分配变量时，写log。
* 当一个变量没有定义但传递使用默认值，打印信息。


## 结论
现在你知道更多关于CSS的自定义属性，包括它的语法，优势，以及好的使用案例和如何使用JavaScript进行交互。

您已经了解了如何检测他们是否支持,它们与CSS预处理器变量的不同，和如何使用CSS变量直到它们支持跨浏览器。

这是正确的时间开始使用CSS自定义属性和准备在浏览器中使用它们。

原文：[https://www.smashingmagazine.com/2017/04/start-using-css-custom-properties/](https://www.smashingmagazine.com/2017/04/start-using-css-custom-properties/)

译者：[Jin](https://github.com/Yi-love)

作者：[Serg Hospodarets](https://www.smashingmagazine.com/author/serghospodarets/)

