---
title: 【译】Css流式布局
subtitle: 流式布局在前端发展中出现好几年了。然而流式排版的概念还比较新，尚未得到充分的探索。
cover: /images/2018-03-27-css-poly-fluid-sizing/1-can-i-use-viewports-opt.png
date: 2018-03-27 10:00
categories: [前端]
tags: [CSS,技术]
author: Diandian
---

流式布局在前端发展中出现好几年了。然而流式排版的概念还比较新，尚未得到充分的探索。目前为止，大多数开发者对于流式布局的认知还停留在对ViewPort设置最小和最大尺寸。

在这篇文章中，我们将从另一个层面来看，我们将会从浏览器支持性能和基本的代数出发，通过多个断点和预定义的字体大小来创建可扩展的流式排版。最好的部分是你可以通过使用Sass来自动完成这一切。
<!-- more -->

在SMASHINGMAG上的更多阅读：

[Truly Fluid Typography With vh And vw Units](https://www.smashingmagazine.com/2016/05/fluid-typography/)
[Typographic Patterns In HTML Email Newsletter Design](https://www.smashingmagazine.com/2015/08/typographic-patterns-in-html-newsletter-email-design/)
[The Good, The Bad And The Great Examples Of Web Typography](https://www.smashingmagazine.com/2014/12/the-good-the-bad-and-the-great-examples-of-web-typography/)
[Tools And Resources For A More Meaningful Web Typography](https://www.smashingmagazine.com/2016/03/meaningful-web-typography/)

当与设计师合作web网页设计时，通常会接收到多个Sketch或Photoshop设计稿（每个断点都有一个）。在该设计中，元素（像h1标题元素）在每个断点都会有不同的大小。例如：

- 在小布局中h1可能是22px
- 在中等布局中h1可能是24px
- 在大布局中h1可能是34px

可以通过[media queries](https://developer.mozilla.org/en-US/docs/Web/CSS/Media_Queries/Using_media_queries)来限定css最小值来实现
```css
h1{
    font-size:22px;
}
@media(min-width:576px){
    h1{
        font-size:22px;
    }
}
@media(min-width:768px){
    h1{
        font-size:24px;
    }
}
@media(min-width:992px){
    h1{
        font-size:34px;
    }
}
```

![media-query-opt](/images/2018-03-27-css-poly-fluid-sizing/media-query-opt.gif)

这是很好的开始，但是你只是设置了设计者指出的断点处的字体大小。如果你问：“850px宽的视口字体大小是多少？” 设计者会怎么回答呢。这个答案在多数示例中是24px到34px之间，但是在这里，通过以上css看，是24px，这估计是设计者从未想过的问题。

这里你可以选择去计算应该是多大，并添加另一个断点。这是很简单的。但是其他的解决方案呢？字体大小在800px宽的视口多少？900px多少？935多少？显然，设计师不会为每个可能的解决方案提供完整的布局。即使他们这样做了，是否要为设计人员所需的不同字体大小添加数十或者数百个断点呢？当前不是。

你的布局已经跟随视口的宽度流畅进行缩放了，如果你的排版可预测的与您的流体布局一起缩放，这不是很好吗？我们还能做些什么来改进这一点？

### Viewport Units可以吗？
 
[视口单元](https://developer.mozilla.org/en-US/docs/Web/CSS/length#Viewport-percentage_lengths)是朝着正确的方向迈出的又一步，他们允许您的文本可以流畅的调整布局。并且现在[浏览器支持](http://caniuse.com/#search=viewport)的也很棒。

![1-can-i-use-viewports-opt](/images/2018-03-27-css-poly-fluid-sizing/1-can-i-use-viewports-opt.png)

但是，Viewport单元的可行性非常依赖于网页的原创创意设计。只需要使用vw设置字体大小并完成就可以。
```css
h1{
    font-size:2vw;
}
```

![viewport-opt](/images/2018-03-27-css-poly-fluid-sizing/viewport-opt.gif)

但这只会在你的设计稿考虑到这一点时才有效。设计师会选择文字大小敲好是他每个设计稿宽度的2%吗？当然不是。让我们来计算每个断点所需要的vw值：

- 22px size @ 576px wide = 22⁄576\*100 = 3.82vw 
- 24px size @ 768px wide = 24⁄768\*100 = 3.13vw 
- 34px size @ 992px wide = 34⁄992\*100 = 3.43vw

他们很接近但是却不完全相同。所以你需要使用媒体查询来在文本大小之间切换，并且仍然会跳转。并考虑这个奇怪的副作用：

@767px,3.82%的视口宽度是29px。如果视口宽1px，字体大小会突然下降到24px。下面的调整视口大小的动画能演示这种不良副作用：


![viewport-2-opt](/images/2018-03-27-css-poly-fluid-sizing/viewport-2-opt.gif)


这种字体大小的巨大变化几乎不是设计师所设想的。那么我们如何解决这个问题呢？

### 统计线性回归？

等等，什么？是的，这是一篇关于CSS的文章，但是一些基本的数学可以为解决我们的问题提供一个韩浩的解决方案。

首先，让我们在图表上绘制出我们的分辨率和响应的文字大小：


![2-scatter-plot-font-size-opt](/images/2018-03-27-css-poly-fluid-sizing/2-scatter-plot-font-size-opt.png)
这里你可以看到在定义的视口宽度里设计者指定的文字大小的散点图。X轴是视口宽度，Y轴是字体大小。看到那条线，这就是所谓的趋势线。这是根据提供的数据为任何视口宽度匹配内插字体大小值的方法。

### 趋势线是这一切的关键

如果你可以根据这个趋势图设置你的字体大小，那么你就会有一个可以平滑缩放的h1,这些分辨率将接近设计者的预期。首先，我们来看看数学，直线由以下等式定义：



![3-linear-equation-definition-opt](/images/2018-03-27-css-poly-fluid-sizing/3-linear-equation-definition-opt.png)


- m = 斜率
- b = y-截距
- x = 当前viewport宽度
- y = `font-size`的结果

这是确定斜率和Y截距的几种方法。当涉及多个值时，常用的方法是最小二乘法。

![4-least-squares-fit-opt](/images/2018-03-27-css-poly-fluid-sizing/4-least-squares-fit-opt.png)
运行以上运算，就可以得到趋势方程。

### 那我们在CSS中要怎么用呢？

好的，这在数学上是想当复杂的运算。那我们如何在前端Web开发中实际使用这些呢？需要用到CSS calc()，这样，一个相当新的CSS技术可以得到很好的应用。


![5-can-i-use-calc-opt](/images/2018-03-27-css-poly-fluid-sizing/5-can-i-use-calc-opt.png)

你可以这样运用趋势方程式：

```scss
h1{
    font-size:calc({slope}*100vw+{y-intercept}px);
}
```

一旦查找到你的斜率和y-截距，你就赋值。

注意：你必须将斜率乘以100，因为你的斜率是用的视口宽度的1/100的vw单位。

### 这个可以自动化吗？

我将最小二乘法运用到一个易于使用的Sass函数中：
```scss
//最小二乘法
//计算提供值的最小二乘拟合线性回归
//@param {map} $ map  - 视口宽度和大小值组合的Sass值
//返回线性方程作为calc()函数
//@example
// font-size:least-squares-fit((576px:24px,768px:24px,992px:34px));
//@作者Jake Wilson <jake.e.wilson@gmail.com>
@function least-squeres-fit($map){
    //获取提供的断点数
    $length:length(map-keys($map));
    //如果断点数<2就报错
    @if($length<2){
        @error "leastSquaresFit() $map must be at least 2 values"
    }
    //计算平均值
    $resTotal:0;
    $valueTotal:0;
    @each $res,$value in $map {
        $resTotal: $resTotal + $res;
        $valueTotal: $valueTotal + $value;
    }
    $resMean: $resTotal/$length;
    $valueMean: $valueTotal/$length;
    // 计算其他的
    $multipliedDiff: 0;
    $squaredDiff: 0;
    @each $res, $value in $map {

    // 与平均值的区别
    $resDiff: $res - $resMean;
    $valueDiff: $value - $valueMean;

    //相乘差异的相加
    $multipliedDiff: $multipliedDiff + ($resDiff * $valueDiff);

    // 分辨率差异的平方和
    $squaredDiff: $squaredDiff + ($resDiff * $resDiff);
  }

  // 计算斜率
  $m: $multipliedDiff / $squaredDiff;

  // 计算Y轴截距
  $b: $valueMean - ($m * $resMean);

  // 返回CSS计算公式
  @return calc(#{$m*100}vw + #{$b});

}

}

```
这真的有用吗？[打开这个CodePen](https://codepen.io/jakobud/pen/LyZJRB)然后调整你的浏览器窗口。起效了！字体大小非常接近原始设计的要求，并且它们可以平滑的与你的布局进行比例缩放。

不可否认，这不是完美的。这些值接近原始设计，但并不是完全匹配。这是因为线性趋势线是在特定视口宽度下特定字体大小的近似值。这是线性回归的继承。在结果中总会有一些错误。这是对简单性和准确性的权衡。另外，请记住，文字大小越多，趋势线中的错误就越多。

那我们能不能做到更好呢？

### 多项式最小二乘拟合

为了获取更准确的趋势线，您需要查看更高级的主题，如多项式回归趋势线，就像这样：

![6-polynomial-regression-opt](/images/2018-03-27-css-poly-fluid-sizing/6-polynomial-regression-opt.png)

现在看起来就更接近了，比我们的直线更精确。一个基本的多项式回归公式如下：

![7-polynomial-equation-opt](/images/2018-03-27-css-poly-fluid-sizing/7-polynomial-equation-opt.png)

你想要的曲线越精确，公式就越复杂。不幸的是，你不能再CSS中这样做。`calc()`根本没有办法计算这样的高级数学公式。具体而言，你不能计算指数：

```scss
font-size:calc(3vw*3vw);/*在css中不生效*/
```

所以，我们只能用线性方程直到`calc()`能支持这种类型的非线性数学。那除此之外，我们还有什么可改进的呢？

### 断点和多个线性方程组

如果我们只计算没对断点直接的直线会怎么样呢？像这样：



![8-linear-regression-opt](/images/2018-03-27-css-poly-fluid-sizing/8-linear-regression-opt.png)

所以在这个例子中，我们将计算22px和24px之间的直线，然后在计算24px和34px之间的直线，Sass是这样的：

```scss
// SCSS
h1 {
  @media (min-width:576px) {
    font-size: calc(???);
  }
  @media (min-width:768px) {
    font-size: calc(???);
  }
}
```

我们可以用最小二乘拟合方法计算calc()值，但由于它只是2个点之间的直线，所以可以大大简化数学运算。还记得直线的公式吗？



![9-linear-equation-opt](/images/2018-03-27-css-poly-fluid-sizing/9-linear-equation-opt.png)
既然我们只说到2点，那么找到斜率（m）和y截距（b）并不重要：


![10-slope-linear-equation-opt](/images/2018-03-27-css-poly-fluid-sizing/10-slope-linear-equation-opt.png)

这是一个sass功能：
```scss
/// 线性插值
/// 计算两点直接的直线
/// @param $map --一个视口宽度和尺寸值的Sass地图
/// @returns 作为calc()函数的线性方程
/// @example
///   font-size: linear-interpolation((320px: 18px, 768px: 26px));
/// @作者 Jake Wilson <jake.e.wilson@gmail.com>
@function linear-interpolation($map) {
  $keys: map-keys($map);
  @if (length($keys) != 2) {
    @error "linear-interpolation() $map must be exactly 2 values";
  }
  // 斜率
  $m: (map-get($map, nth($keys, 2)) - map-get($map, nth($keys, 1)))/(nth($keys, 2) - nth($keys,1));

  // y-轴截距
  $b: map-get($map, nth($keys, 1)) - $m * nth($keys, 1);

  // 确定这个标志是积极或者消极的
  $sign: "+";
  @if ($b < 0) {
    $sign: "-";
    $b: abs($b);
  }

  @return calc(#{$m*100}vw #{$sign} #{$b});
}
```

现在，只需要在Sass中的多个断点上使用线性插值函数即可。另外，让我们投入一些最小和最大的`font-size`：

```scss
// SCSS
h1 {
  // 最小 font-size
  font-size: 22px;
  // 字体大小在 576 - 768之间
  @media (min-width:576px) {
    $map: (576px: 22px, 768px: 24px);
    font-size: linear-interpolation($map);
  }
  // 字体大小在 768 - 992之间
  @media (min-width:768px) {
    $map: (768px: 24px, 992px: 34px);
    font-size: linear-interpolation($map);
  }
  // 最大 font-size
  @media (min-width:992px) {
    font-size: 34px;
  }
}
```
他会生成这样的CSS：

```scss
h1 {
  font-size: 22px;
}
@media (min-width: 576px) {
  h1 {
    font-size: calc(1.04166667vw + 16px);
  }
}
@media (min-width: 768px) {
  h1 {
    font-size: calc(4.46428571vw - 10.28571429px);
  }
}
@media (min-width: 992px) {
  h1 {
    font-size: 34px;
  }
}
```

<!--插入图片-->

### css尺寸的圣杯？

让我们把这一切都包装在一个很好的Sass mixin中（对于懒惰和高效！）。我们正在创造这种方法Poly Fluid Sizing:

```scss
/// poly-fluid-sizing
/// 通过多个断点生成线性插值大小值
/// @param $property - 一个字符串CSS属性名称
/// @param $map - 视口单位和尺寸值对的Sass map
/// @requires 函数线性插值
/// @requires 函数 map-sort
/// @example
///   @include poly-fluid-sizing('font-size', (576px: 22px, 768px: 24px, 992px: 34px));
/// @作者 Jake Wilson <jake.e.wilson@gmail.com>
@mixin poly-fluid-sizing($property, $map) {
  // 获取提供的断点值
  $length: length(map-keys($map));

  // 断点小于< 2报错
  @if ($length < 2) {
    @error "poly-fluid-sizing() $map requires at least values"
  }

  // 按视口宽度排序 (key)
  $map: map-sort($map);
  $keys: map-keys($map);

  //最小值
  #{$property}: map-get($map, nth($keys,1));

  // 通过断点来看插值大小
  @for $i from 1 through ($length - 1) {
    @media (min-width:nth($keys,$i)) {
      $value1: map-get($map, nth($keys,$i));
      $value2: map-get($map, nth($keys,($i + 1)));
      // 如果值不相等，执行线性插值
      @if ($value1 != $value2) {
        #{$property}: linear-interpolation((nth($keys,$i): $value1, nth($keys,($i+1)): $value2));
      } @else {
        #{$property}: $value1;
      }
    }
  }

  // 最大值
  @media (min-width:nth($keys,$length)) {
    #{$property}: map-get($map, nth($keys,$length));
  }
}
```

这个Sass mixin在下面的Github gists中需要一些Sass函数：
- [linear-interpolation](https://gist.github.com/Jakobud/7414f91142e0f540f221a3e3cafdf856)
- [map-sort](https://gist.github.com/Jakobud/a0ac11e80a1de453cd86f0d3fc0a1410)
- [list-sort](https://gist.github.com/Jakobud/744b98b629abe018766f6d506a2e92ae)
- [list-remove](https://gist.github.com/Jakobud/ec056b52f3673cc369dc97f2c2428424)
 
`poly-fluid-sizing（）`类将对每对视口宽度执行线性插值并设置最小和最大尺寸。您可以将其导入到任何Sass项目中，并轻松使用它，而无需知道任何背后的数学。这是使用此方法的最终[CodePen](https://codepen.io/jakobud/pen/vmKLYb)。


### 一些注释

- 这种方法提供的不仅仅是`font-size`,也适用于任何unit/length属性（`margin`,`padding`等）你可以将所需要的属性名称作为字符串传给类函数就可以。
- 视口宽度+尺寸值对的Sass映射可以按任意顺序传递到`poly-fluid-sizing()`类函数中。它将根据视口宽度从最低到最高对值自动进行排序。所以你可以像这样传递一个值，就会生效：
```scss
 $map: (576px: 22px, 320px: 18px, 992px: 34px, 768px: 24px);
  @include poly-fluid-sizing('font-size', $map);
```

这种方法的一个限制是你不能将mixed units传到类函数中。例如，`3em` @ `576px`宽度。Sass不知道怎么做数学运算。

### 总结

这是我们能做的最好的吗？ Poly Fluid是CSS中流体单元大小的圣杯？也许。 CSS目前支持非线性[animation](https://developer.mozilla.org/en-US/docs/Web/CSS/animation-timing-function)和[transition](https://developer.mozilla.org/en-US/docs/Web/CSS/transition-timing-function)定时功能，所以可能[有机会](http://i0.kym-cdn.com/photos/images/newsfeed/000/840/283/350.png)`calc（）`也会支持它。如果真的会发生，非线性多项式回归可能值得再看一遍。但也许不是......线性缩放可能会更好。

我在2017年初[开始探索这个想法](http://stackoverflow.com/questions/42014594/linear-scaling-between-2-font-sizes-using-calc-and-vw)，并最终开发了上述解决方案。从那以后，我看到一些开发者提出了类似的想法和不同的难题。我认为是时候分享我的方法和我是如何实现。Viewport units。Calc（）。Sass。Breakpoints。这些都不是新鲜事。它们都在不同浏览器存在很久了（具有不同程度的支持）。我只用了一种尚未完全探索的方式。面对你每天使用的工具不要害怕，要想办法突破以更好的提高个人技能。




原文：[Fluid Responsive Typography With CSS Poly Fluid Sizing](https://www.smashingmagazine.com/2017/05/fluid-responsive-typography-css-poly-fluid-sizing/)

作者：[Vitaly Dulenko](https://www.smashingmagazine.com/author/jake-wilson/)

译者：[Diandian](https://futu.im/author/Diandian)
