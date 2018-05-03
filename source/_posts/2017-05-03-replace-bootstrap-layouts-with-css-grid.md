---
title: 【译】使用CSS Grid替换Bootstrap布局
date: 2017-05-03 10:30
categories: [前端]
author: Linda
---

3月份的时候，Mozilla发布了Firefox 52，加入了对CSS Grid布局的支持。如果不熟悉CSS Grid，它是一个二维的网页布局系统，允许开发者在浏览器中创建内部布局图案。这也就是说，可以只用几行的CSS很容易的重建熟悉的网格。也意味着我们可以用CSS和布局做很多之前不可能的东西...但会比之前的多一点点。

一条笔记：这文章原本不是CSS Grid的综合入门读物，并且假设读者对CSS Grid有个基本了解。如果对CSS Grid还不熟悉，推荐看看MDN上这篇不错的文章[CSS Grid Layout page](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout)。

<!-- more -->

web上的布局总是很复杂。web第一次被引入的时候，没有提供布局的方式。然后迎来了table布局（一个table套一个table套一个table）。这样很怪异，但是是可以运作的。当CSS在90年代后期被引入的时候，开发者可以开始用div和float进行设计和布局了。这最终使得框架和网格系统，需要解决所有的“陷阱”，比如清除浮动，负边距，响应式设计等。现在这状况持续了几年。现在有数千的[网格系统](https://github.com/search?utf8=%E2%9C%93&q=css+grid&type=)，但是他们都或多或少是一样的。

现在CSS Grid布局已经诞生，现在我来看看用CSS Grid来代替现有的网格框架完成页面布局是什么样的。为了这个实验，我选了流行的[Bootstrap框架](http://getbootstrap.com/)。

我以用Bootstrap创建一个基础网站为开始：
![css_layouts](/images/2017-css-grid/css_layouts.jpg)

代码在这里：
[布局实例](http://codepen.io/slightlyoffbeat/pen/dvEbLV)

让我们用CSS Grid来转换Bootstrap网格布局。

在Bootstrap中，`.container`类可以包裹任何东西，并且可以设置宽度约束。它也在左边和右边角添加`padding`，将所有东西都居中。这里没有太多要改的。像用Bootstrap一样，`.container`可以用CSS Grid来处理。我这样重新创建它：

```css
.container {
    margin-left: auto;
    margin-right: auto;
    padding-left: 15px;
    padding-right: 15px;
}
```

也可以添加响应断点，像下面代码这样：

```css
@media (min-width: 992px) {
    .container {
    	width: 970px;
     }
}
```

Bootstrap用`.row`类来包裹列，提供了左右的负`margin`来消除单列叠加的`padding`。像负边距这样的hack，在使用CSS Grid的时候不再需要了。但如果读过[文档](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout/Basic_Concepts_of_Grid_Layout)，会了解到CSS Grid需要一个网格容器。`.row`类是完美的地方。可以看下我做的，然后我们毁掉它:

```css
.row {
    display: grid;
    grid-template-columns: repeat(12, 1fr);
    grid-gap: 20px;
}
```

`display:grid` 创建了网格包裹容器。

`grid-template-colums`属性定义了网格的列。可以独立使用空间来定义每列，但是这里利用了`repeat`标记来定义等宽的12列。`1fr`是以每个独立列的宽度为参考的。MDN定义了新的`fr`单位，“代表在网格容器中可用空间的一小部分”。可以在MDN上了解更多[fr单位](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout/Basic_Concepts_of_Grid_Layout#The_fr_Unit)的相关信息。也可以了解更多[grid-template-columns](https://developer.mozilla.org/en-US/docs/Web/CSS/grid-template-columns)属性。

最后，`grid-gap`属性是一个定义了列间和多列行间的空间属性。可以把它想成水槽。这里可以了解更多[grid-gap](https://developer.mozilla.org/en-US/docs/Web/CSS/grid-gap)的信息。

剩下的都是列的class。Bootstrap用像`.col-md-6`或者`.col-lg-8`这样的列class来决定一个div跨多少列。它也让div浮动起来，并且在左右两侧添加padding来创建列之间的间隙。多亏了`.grid-column`属性，重建这些class很容易。例如，如果想重建`.col-md-6` class,可以用下面的代码：

```css
@media (min-width: 992px) {
    .col-md-6 {
    	grid-column: span 6;
    }
}
```

很简单，对吗？没有浮动，没有`padding`。就可以工作了。`grid-column`指定了一个条目的尺寸和位置。可以用`span`来指定这个独有的条目需要跨6列。沟壑会因包裹层的`grid-gap`属性被自动处理。这里可以了解更多[grid-column](https://developer.mozilla.org/en-US/docs/Web/CSS/grid-column)属性的信息。

如果把这些都放到一起会发生什么？网站看起来完全一样，但是我们可以完全移除Bootstrap的依赖并且使用内部的CSS Grid。

[在线实例](http://codepen.io/slightlyoffbeat/pen/NpVGyW)

这类实验是很有趣的练习，但是也会有点危险。借聪明的[philosopher Jeff Goldblum](https://en.wikiquote.org/wiki/Jurassic_Park_(film))话说：

“你...如此专注于是否能完成，却没有停下来想想是否应该做。”

我们不想通过把CSS Grid硬塞成限制它潜力的语法来限制它。我们可以很容易地重建Bootstrap网格，但CSS Grid比其他之前的网格系统强大很多。那是因为它是从底层建立的web内部解决方案。

我们不会再受困于12列从左浮动到右的网格了。想要在网格上清晰的位置放置元素，不依赖他们的HTML源位置吗？用起来。想要创建跨多列多行条目吗？这都不是问题。看看Mozilla的[Craig Cook](https://github.com/craigcook/)创建的展示各种布局模式的[示例](https://www.mozilla.org/en-US/developer/css-grid/)。可以试着用Bootstrap重建那些布局（提示：不可能）。我们只很浅层次的讨论了下CSS Grid可以做什么。  

如果想了解更多CSS Grid的东西，可以看看下面的文章：

[Mozilla CSS Grid Demo](https://www.mozilla.org/en-US/developer/css-grid/)
[CSS Grid documentation on MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout)
  
原文：[https://hacks.mozilla.org/2017/04/replace-bootstrap-layouts-with-css-grid/](https://hacks.mozilla.org/2017/04/replace-bootstrap-layouts-with-css-grid/)

译者：[Linda](https://github.com/LindaWhite)

作者：[Dan Brown](https://hacks.mozilla.org/author/dbrownmozilla-com/)

