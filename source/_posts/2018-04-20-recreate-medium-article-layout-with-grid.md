---
title: 【译】CSS Grid重构Medium的文章布局
date: 2018-04-20 20:04:45
tags: [CSS, HTML]
author: Suny
---

当人们想起CSS Grid的时候，想到的通常是图片网格布局和全屏页面。然而，CSS Grid事实上也是一项很适用于文章布局的技术，它可以做一些以前很难完成的事情。

在本教程中，我将阐述怎样用CSS Grid去重构著名站点Medium的文章布局。

<!-- more -->

此文灵感来自于Scrimba上的免费CSS Grid教程。[点此查看](https://scrimba.com/g/gR8PTE)

![点击此图获取全部CSS Grid课程](/images/2018-04-20-recreate-medium-article-layout-with-grid/1.png)

在[本课程中的一个录屏](https://scrimba.com/p/pWqLHa/cdp76sD)中，我的同事[Magnus Holm](https://medium.com/@judofyr)阐述了怎样将CSS Grid用于文章布局。


## 内容部分


我们将从一个基本的HTML文件开始，包含Medium上文章的典型内容类型。例如：标题、段落、子标题、图片、引用等等。如下所示：

```html
<article>
<h1>Running any NPM package in the browser locally</h1>
<p>JavaScript has never had any official solution for distributing packages, and every web platform (Rails, Django etc) has their own idea of how to structure and package JavaScript. In the last few years NPM has started becoming the canonical way of distribution, with Webpack as the build system, but there’s no way to load NPM packages in the browser without a server-side component.</p>
<blockquote>
<p>Scrimba is a platform for interactive coding screencast where
you can run the code at any moment in time.</p>
</blockquote>
<figure>
<img src="https://mave.me/img/projects/full_placeholder.png">
</figure>
```

如果你不调整任何布局直接在浏览器中打开此文件，你看到的是这样子的：

![](/images/2018-04-20-recreate-medium-article-layout-with-grid/2.png)

一点也不美观。因此让我们一起用CSS Grid来调整一下吧。为了让大家都能跟得上，我们将一步一步来完成。

## 基本margins设置

我们要做的第一件事是将整个`<article>`标签变成一个grid容器，并设置至少三列。

```css
article {
    display: grid;
    grid-template-columns: 1fr 740px 1fr;
}
```

第一列和最后一列充当边缘部分并且自适应，它们大部分情况下包含着空白区域。中间一列固定为740px，将容纳文章的主体内容。

注意，我们没有定义行是因为每一行的高度都是由它们的自身内容所决定。文章中的每块内容（段落、图片、标题）自成一行。

下一步是确保网格中的所有内容默认开始于第二条纵向网格线。

```css
article > * {
    grid-column: 2;
}
```

现在我们得到如下结果：

![](/images/2018-04-20-recreate-medium-article-layout-with-grid/3.png)

我们立刻就发现它变得稍微好看一点了，因为两边的空白区域让文本更易于阅读了。

然而，将左右`margin`属性设置为`auto`也能实现这种效果，而且更简单。我们为什么要用CSS Grid呢？

好了，当我们想要模仿Medium上的图片的某些特性的时候，问题出现了。例如插入一张全屏宽的图片，像下面这样：

<p style="width: 100vw;margin-left:-webkit-calc(50% - 50vw);margin-left:calc(50% - 50vw);"><a href="/images/2018-04-20-recreate-medium-article-layout-with-grid/4.jpg" class="fancybox" rel="group"><img src="/images/2018-04-20-recreate-medium-article-layout-with-grid/4.jpg" alt=""></a></p>

如果我们之前用了`margin: 0 auto`, 我们将只能利用负边距（margins）来使得图片占据全屏宽度，这种方法显得很hack。

使用CSS Grid的话，可以很轻易的解决这个问题，我们只需要简单的用列来设置宽度。为了确保图片占据整个宽度，我们只需要将其跨度设置为从第一列到最后一列。

```css
article > figure {
    grid-column: 1 / -1;
    margin: 20px 0;
}
```

我们再设置一下上下边距，就得到了一幅漂亮的全屏宽的图片：

![](/images/2018-04-20-recreate-medium-article-layout-with-grid/5.png)

## 多列使用扩展

然而，这并没有为我们解决所有的问题，Medium上还有一些其他类型的布局需要我们考虑。我们一起来看几个：

### 中型尺寸图片

这是一种介于常规图片和全屏宽图片之间的图片，我们称之为中型尺寸图片。如下所示：

<p style="width: -webkit-calc(50vw + 50%);width: calc(50vw + 50%);margin-left:-webkit-calc(25% - 25vw);margin-left:calc(25% - 25vw);"><a href="/images/2018-04-20-recreate-medium-article-layout-with-grid/6.jpeg" class="fancybox" rel="group"><img src="/images/2018-04-20-recreate-medium-article-layout-with-grid/6.jpeg" alt=""></a></p>
<p style="text-align: center;"><strong>提示：</strong><em>在移动端，此类图片和全屏宽图片表现一致。本文中，我们只关注桌面端布局</em></p>

这将需要在我们现有的布局中至少新增两列。


### 引用

另外，在Medium上，如果你添加一条引用，文章的左侧也会出现一条垂直线

<p style="border-left: 3px solid rgba(0,0,0,.84);padding-left: 20px;margin-left: -23px;">← 注意这条垂直线，我们需要在我们的网格上额外新增一列来实现它。</p>

这需要在网格的左侧有一个小型的列，为了对称，我们将在右侧也加一个相同的列。

因此，为了支持 **引用** 和 **中间尺寸图片**，我们需要将容器宽度划分为7列而不是三列，如下所示：

```css
article {
    display: grid;
    grid-template-columns: 1fr 1fr 10px 740px 10px 1fr 1fr;
}
```

如果我们使用 Chrome 检查器，我们可以显式地看到背后的网格线（如下图所示），此外，我还增加了一些箭头来标识出不同的列，以便于识别。

![](/images/2018-04-20-recreate-medium-article-layout-with-grid/7.png)
<p style="text-align: center;"><em>我增加了箭头用于更好地识别不同列</em></p>

接下来，我们要做的第一件事是让所有的默认子项从第四条纵向网格线开始，而不是之前的第二条。

```css
article > * {
    grid-column: 4;
}
```

然后我们可以通过设置如下样式来创建中间尺寸图片：

```css
article > figure {
    grid-column: 2 / -2;
    margin: 20px 0;
}
```

在 Chrome 检查器下展示如下这样：

<p style="width: -webkit-calc(50vw + 50%);width: calc(50vw + 50%);margin-left:-webkit-calc(25% - 25vw);margin-left:calc(25% - 25vw);"><a href="/images/2018-04-20-recreate-medium-article-layout-with-grid/8.png" class="fancybox" rel="group"><img src="/images/2018-04-20-recreate-medium-article-layout-with-grid/8.png" alt=""></a></p>

通过设置如下样式可以轻松创建引用：

```css
article > blockquote {
    grid-column: 3 / 5;
    padding-left: 10px;
    color: #666;
    border-left: 3px solid black;
}
```

我们设置它的纵向跨度为从第三条网格线到第五条网格线。同时增加10px的左边距 `padding-left: 10px` 使得文本看起来像是从第四条网格线开始(第三列也是10px宽)。如下是在网格上的展示：

<p style="width: -webkit-calc(50vw + 50%);width: calc(50vw + 50%);margin-left:-webkit-calc(25% - 25vw);margin-left:calc(25% - 25vw);"><a href="/images/2018-04-20-recreate-medium-article-layout-with-grid/9.png" class="fancybox" rel="group"><img src="/images/2018-04-20-recreate-medium-article-layout-with-grid/9.png" alt=""></a></p>

### 侧面标记

现在还有最后一种类型需要支持。Medium上有一个非常好的标明文章中突出内容的方式。文本变绿，并在右上角产生一个高亮标记。

![](/images/2018-04-20-recreate-medium-article-layout-with-grid/10.png)


如果我们之前用的是 `margin: 0 auto` 而不是 CSS Grid的话，由于与文章中的其他元素的表现都不一样，右上角高亮标记文本元素的创建将会很麻烦。我们期望它出现在上一个元素的右侧而不是重起一行。如果我们没有使用CSS Grid，我们可能不得不用大量的 `position: absolute` 来实现这种效果。

使用 CSS Grid 就变得超级简单了。我们只需要设置这种元素从第五条网格线开始。

```css
.aside {
    grid-column: 5;
}
```

这样会自动将其置于文章的右侧。

![](/images/2018-04-20-recreate-medium-article-layout-with-grid/11.png)

就这样，现在我们已经用 CSS Grid 重构了Medium上文章布局的绝大部分，这实际上很简单。但请注意，我们还没有涉及到响应式，这部分需要重新写一篇文章。

[Scrimba上查看所有代码](https://scrimba.com/c/cedLJfW)



原文：[How to recreate Medium’s article layout with CSS Grid](https://medium.freecodecamp.org/how-to-recreate-mediums-article-layout-with-css-grid-b4608792bad1)

作者：[Per Harald Borgen](https://medium.freecodecamp.org/@perborgen)

译者：Suny

