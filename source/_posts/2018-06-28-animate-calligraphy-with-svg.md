---
title: 【译】使用SVG动画书法
subtitle: stroke作用于fill属性的svg动画。
cover: /images/2018-06-28-animate-calligraphy-with-svg/cover.jpg
date: 2018-06-28 10:30
categories: [前端]
author: Diandian
---
在Stackoverflow上时常会有人问到有没有与[stroke-dashoffset技术](https://css-tricks.com/svg-line-animation-works/)相同效果 stroke作用于fill属性的svg动画。仔细去考虑下，这个问题实际上是想这样问：

<!-- more -->

> 我有一条线，但是因为它有不同的画法宽度，在SVG中他被定义为路径的填充。
> 
> 那我如果让这个“画笔”动画生成？

简言之，就是**你如何制作动画书法**？

![](/images/2018-06-28-animate-calligraphy-with-svg/1.svg)

*图片是一个动画书法的路径说明*

这个基本技巧相对比较简单：在书法的顶部画一条线路径，这样可以按照这个画笔线去选择笔画的宽度，覆盖整个书法。

在顶部的这条线将用于蒙版路径，然后应用`stroke-dashoffset`动画技术在蒙版路径上。这样看起来底部的路径就像是实时的在屏幕上书写的一样。

这是`mask`的例子，不是`clip-path`-这是行不通的。Clip-paths总是会引用填充区域的路径，但是会忽略`stroke`。

最简单的更改是设置`stroke:white`在蒙版路径，这样在白色区域以外的都会被隐藏，里面内容都不会被改变。

Codepen这个例子[书法书写：简单的例子](https://codepen.io/ccprog/pen/yjjmrB/)

这样看来是很简单，但当书法线重叠时，事情会变得棘手。这是在一个天真的实现中发生的事情：

Codepen这个例子[书法书写：错误的交叉点](https://codepen.io/ccprog/pen/zjaOjd/)

在交叉点处，蒙版展示了刷子交叉的部分，因此，书法必须被切分成不重叠的部分。按照绘图顺序堆叠，定义每个单独的蒙版路径。

![](/images/2018-06-28-animate-calligraphy-with-svg/2.svg)

*蒙版路径和书法画笔上的剪裁必须匹配*

最棘手的部分是保持图形是一个连续的路径。如果切割平滑路径，只要两个路径切线在它们的公共点有相同的方向，端点就会合在一起。笔划结束与此垂直，并且书法线中的切割完全对齐是很重要的。确保所有路径都有连续的方向。让每个路径一个接一个的连续动画。

虽然一些线条动画可以在长度上得到粗略的数学`stroke-dasharray`，但是这种情况需要精确的测量（尽管小的圆形都不能失误）。提醒一下，您可以在DevTools控制台中通过以下方式获取它们：

```JS
document.querySelector('#mask1 path').getTotalLength()
```
Codepen这个例子[书法书写：划分交叉点](https://codepen.io/ccprog/pen/VxdZGE/)

“一个接一个”的部分在CSS中写起来有些尴尬。最佳模式可能会给所有部分动画提供相同的开始时间和总持续时间，然后在`stroke-dashoffset`变化之间设置中间关键帧。

例如：

```CSS
@keyframes brush1 {
  0% { stroke-dashoffset: 160; } /* leave static */
  12% { stroke-dashoffset: 160; } /* start of first brush */
  44% { stroke-dashoffset: 0; }   /* end of first brush equals start of second */
  100% { stroke-dashoffset: 0; }   /* leave static */
}

@keyframes brush2 {
  0% { stroke-dashoffset: 210; } /* leave static */
  44% { stroke-dashoffset: 210; } /* start of second brush equals end of first */
  86% { stroke-dashoffset: 0; }   /* end of second brush */
  100% { stroke-dashoffset: 0; }   /* leave static */
}

```

再往下看，你会看到一个SMIL动画如何能够以更流畅和富有表现力的方式来定义时间。与CSS保持一致，用Sass完成的计算可能会非常有用，因为它可以处理一些数学问题。

![](/images/2018-06-28-animate-calligraphy-with-svg/3.svg)

*蒙版路径（左）及其应用（右）*

如果蒙版路径的曲线半径小于笔画宽度，则会出现类似的问题。当动画通过该曲线时，可能会发生中间状态严重歪斜的情况。

解决方法是将蒙版路径移出书法曲线。你只需要注意它的内边缘仍然覆盖着画笔。

只要切割边缘合在一起，您甚至可以切割蒙版路径并使两端不对齐。

![](/images/2018-06-28-animate-calligraphy-with-svg/4.svg)

*半径保持足够大*

Codepen这个例子[书法书写：划分交叉点](https://codepen.io/ccprog/pen/yjENdM/)

因此，你甚至可以绘制一些复杂的东西，比如这个例子中的阿拉伯字母：

Codepen这个例子[Tughra Mahmud II  -文字动画](https://codepen.io/ccprog/pen/xzKPMY/)

>最初的设计是奥斯曼帝国苏丹马哈茂德二世的图格拉。是一位不知名的19世纪书法家。矢量化版本由维基百科插画家Baba66完成。动画是我试图想象图形内阿拉伯字母的位置。它建立在Baba66的早期版本上。

以下代码片段显示了用于可重复的方式按顺序运行动画的高级方法。

```CSS
mask path {
  fill: none;
  stroke: white;
  stroke-width: 16;
}

.brush {
  fill: #0d33f2;
}
```

```HTML
<mask id="mask1" maskUnits="userSpaceOnUse">
  <path stroke-dasharray="160 160" stroke-dashoffset="160" d="...">
    <!-- animation begins after document starts and repeats with a click
         on the "repeat" button -->
    <animate id="animate1" attributeName="stroke-dashoffset"
             from="160" to="0" begin="1s;repeat.click" dur="1.6s" />
  </path>
</mask>
<mask id="mask2" maskUnits="userSpaceOnUse">
  <path stroke-dasharray="350 350" stroke-dashoffset="350" d="...">
    <!-- animation begins at the end of the previous one -->
    <animate id="animate2" attributeName="stroke-dashoffset"
             from="350" to="0" begin="animate1.end" dur="3.5s" />
  </path>
</mask>
<!-- more masks... -->
<mask id="mask15" maskUnits="userSpaceOnUse">
  <path stroke-dasharray="230 230" stroke-dashoffset="230" d="...">
    <!-- insert an artificial pause between the animations, as if the
         brush had been lifted -->
    <animate id="animate15" attributeName="stroke-dashoffset"
             from="230" to="0" begin="animate14.end+0.5s" dur="2.3s" />
  </path>
</mask>

<g class="brush">
  <path id="brush1" d="...">
    <!-- The mask is only applied  after document starts/repeats and until
         the animation has run. This makes sure the brushes are visible in
         renderers that do not support SMIL -->
    <set attributeName="mask" to="url(#mask1)"
         begin="0s;repeat.click" end="animate1.end;indefinite" />
  </path>
  <path id="brush2" d="...">
    <set attributeName="mask" to="url(#mask2)"
         begin="0s;repeat.click" end="animate2.end;indefinite" />
  </path>
  <!-- more paths... -->
  <path id="brush15" d="...">
    <set attributeName="mask" to="url(#mask2)"
         begin="0s;repeat.click" end="animate15.end;indefinite" />
  </path>
</g>

```

> 与我们看过的其他示例相比，此动画使用SMIL，这意味着它不适用于Internet Explorer和Edge。


原文：[https://css-tricks.com/animate-calligraphy-with-svg/](https://css-tricks.com/animate-calligraphy-with-svg/)

译者：[Diandian](https://futu.im/author/Diandian)

作者：[Claus Colloseus](https://css-tricks.com/author/ccprog/)

