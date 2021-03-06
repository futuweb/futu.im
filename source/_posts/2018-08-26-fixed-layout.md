---
title: 移动端页面滚动position:fixed;踩坑实记
subtitle: 这次接到了校招页面的需求，主要在移动端传播。
cover: /images/amyli/2018-08-26-fixed/merge.png
date: 2018-08-26 17:00
categories: [前端]
tags: [css]
author: AmyLi
---

## 背景: 回到顶部功能有bug
这次接到了校招页面的需求，主要在移动端传播。页面中有个回到顶部的按钮，固定在页面的底部。在电脑上测试完全正常，但是到了移动端的，用浏览器打开后，按钮居然时灵时不灵，然后在微信、QQ中打开，正常。呃，奇怪的问题，0—0！。
我将手机连接到电脑上进行调试，问题就暴露出来了。
<!-- more -->
![](/images/amyli/2018-08-26-fixed/merge.png)
<!-- ![img](/images/amyli/2018-08-26-fixed/2.png) -->
在页面的滚动中，goTop元素节点居然和背景图片分开了（居然还有这种现象），难怪点击没效果，根本没点击到元素节点上。多次滑动查看，发现节点和背景图脱离的情况，是由页面滚动时，网页的地址栏会显示和隐藏触发的。goTop按钮，采用的是fixed布局，而在滚动时，fixed定位不准了，在andriod和ios中均这样表现了。

PS：其实不准有bug我也是理解的，CSS中也不少见。但是为什么表现出了元素展示的视觉效果是符合预期的，但是实际节点的位置和展示的位置不一致（见上面左侧图片）？？？

## 通用解决方式
问题来了还是要解决的，然后去网上查。基本都是一种解决方式。移动端fixed定位不准是由页面根元素html滚动引起的，那么阻止它滚动就好了，将网页的窗体滚动改变为局部滚动，即增加设置：

```
html, body{
    width: 100%;
    height: 100%;
}
body{
    background-color: blue;
    position: fixed;
    top: 0;
    left:0;
    width: 100%;
    height: 100%;
}
/*主体部分*/
.main {
    height: 100%;
    overflow-y: auto;
    /*增加滑动的流畅性*/
    -webkit-overflow-scrolling: touch;
}
```
但是这种方法将网页整体滚动变成局部滚动，很可能会影响到后续的部分，需要谨慎的使用。对于我这里的问题，这个方法还是适用的，毕竟这是一个活动页面，影响范围有限，后续也不会有修改。
## 具体问题，具体解决
现在问题是能够解决了，但是（T—T），一来还要调整页面布局，二来我原来依赖window的scroll事件又要改动。有没有什么更简单点的方式勒? 回到具体问题，我只是想回到顶部按钮的功能可以正常使用，这样的原因是因为按钮的显示位置和实际位置不一致造成的，有没有什么办法能让元素的展示位置和实际位置一致勒。

回到顶部这样的功能属于很常见的功能，移动端的页面肯定是有的啊！然后我去找个几个网站，美图的校招官网、大漠老师的W3CPlus网站，都有回到顶部的功能，但是，这两个并没有处理移动端的这样问题。然后看到了CVTE的官网，也是有回到顶部的功能的，并且没有出现节点显示和实际节点不一致的情况。~（^_^）~

对比测试发现，我用的是bottom确定位置信息，CVTE是用top确定，一看之前两个网站，都是用bottom来确定的，然后我将bottom改为top，怎么滚动都没有发现节点脱节的情况。当然，换成top之后，fixed的定位问题还是存在的，但是总体来说影响不大，就这个功能而言，对页面效果要求不是特别严格的情况下，采用这种方式改动更小，影响更小。
## 其它
移动端fixed定位时，建议不要采用bottom值来确定元素的具体位置，会有一些奇怪的问题，或是直接非常定位不准，或是页面展示效果和实际节点一样。

当然采用top值确定具体位置，在页面滚动时，地址栏显隐时，位置也会不准，但是touchend触发后，还是会回到准确位置（真机测试：iponexX Safari，honor 7 chrome、自带浏览器，min note pro QQ浏览器、chrome）。

PS：上述测试中，fixed元素中只含有普通元素，不包含input，不包含有其他定位元素。
参考文档：http://efe.baidu.com/blog/mobile-fixed-layout/