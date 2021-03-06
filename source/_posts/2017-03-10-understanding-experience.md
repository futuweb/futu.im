---
title: 某个程序员眼中的用户体验设计
subtitle: 在公司的图书角找到了一本漂亮，纸质很好的书。
cover: /images/2017-03-10-understanding-experience/cover.jpg
date: 2017-03-10 10:00
tags: [用户体验设计]
categories: [设计]
author: Young
---

## 概述

作为一名半路出家的前端工程师，大概开发移动端网页有两年时间了吧，虽然交互设计不是我的工作内容，但也或多或少的踩了一些坑，然后根据这些坑记录了一些小总结，比如：

+ 移动网页中输入项最好在页面顶部，关联搜索等复杂交互最好是单独新开页面，不应该和其它交互杂糅在一起；
+ 移动网页中需要交互触发的元素不应该设计的太小，设计的太小对于手指操作来说很困难；
+ 移动网页中某个交互不应该对页面元素以及布局产生突然变化，容易让用户很困惑；如果某个交互导致页面变化很大则应该用新开的页面的方式展现；
+ 移动网页的交互不仅仅包括其内部本身的一些交互，还包括和任何可能出现该网页的APP软件的交互；简单来说，设计和实现一个移动网页其实还要考虑该网页在当前流行APP中分享的文案、图标等；
+ 异常反馈很重要，不仅仅指产品设计时的异常情况，还包括程序运行时的各种异常（这里需要开发尽可能的考虑清楚并反馈给产品），尽可能的给用户清晰的反馈；
+ 最好对用户在页面的操作有一定的反馈，比如点击按钮等。

都是些零零散散的东西，直到前不久在公司的图书角找到了一本漂亮，纸质很好的书《匠心体验-智能手机与平板电脑的用户体验设计》：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/understanding-experience-0.jpg">

<!--more-->

## 前言

首先得声明一下这只是某个程序员粗略浏览《匠心体验-智能手机与平板电脑的用户体验设计》之后为方便和加深自己理解而记录的读后感，主要内容基本可以概括为：从一个适合自己理解的角度来简要复述上述书籍的内容。

因此你不可能在后续的内容中发现细致深入的知识点，甚至看到最后你还可能还会感觉这个角度完全不适合你。

## 详解

第一章作者从视觉、触觉、听觉、感知等方面，阐述了智能手机和平板电脑在用户体验设计中应该遵循的规则和注意事项。

看完之后...

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/understanding-experience-1.jpg">

作者从哪几个方面阐述来着...

知其然不知其所以然就会出现这样的情况了，如果不能系统的了解并转化成自己的知识，就只能停留在死记硬背的程度。

工作四年了，在这四年的屡次面试中，不管是JAVA开发工程师还是前端开发工程师，大部分情况下都能遇到一道面试题，`请尽可能详细的阐述从浏览器中输入url地址到浏览器渲染出页面的过程`。

这里既不讨论这道题的答案也不讨论这道题作为面试题的意义，我只是感觉这个问题本身描述了一种方法，从头到尾系统了解某个事物的方法。

那么对比某个用户使用智能手机或者平板电脑浏览网页或者APP的行为，是不是可以从头到尾可以分成以下几个步骤来理解呢？

### 有一天在某个无聊的会议上你准备掏出手机

移动终端的使用情景比较特殊，用户往往在时间紧张的情况下使用，即在移动过程中或者在需要分散注意力的时候使用。

> 比如公交上、地铁上、某些会议期间、餐厅里边等（不排除存在特例，但是至少大部分移动终端的使用情景是这样的）。

既然这样我们是不是得让我们的网页或者APP做到`适应分散注意力的环境`，在书中作者基于`聚焦点原理`列出了以下几点建议：

+ 屏幕上突出显示聚焦点；
+ 通过动画创造临时聚焦点；

+ 标明内容的主次关系；
> 前两点没什么好说的，但是在`标明内容的主次关系`中作者抨击了下`扁平化设计`，认为这种设计会导致页面中没有任何重点，所有元素都处于同一背景层，用户需要消耗更多精力来发现重要元素；
> 所谓`扁平化设计`维基百科给出的定义是`一种交互界面的设计理念，强调对于三维效果图像元素使用的最小化（其元素也包括阴影、渐变和纹理），亦专注于使用去除了冗余信息的图像元素，排版及纯色效果`；
> 虽然`扁平化设计`确实可能会存在重点不突出的问题，但是其实也有自身的优势，比如：画面看起来更为流线型、更能适应不同尺寸的屏幕、元素简单导致性能更高等；
> 暂且认为各有优劣吧，具体情况具体分析。

+ 预防用户分心
> 大致意思就是设计时得考虑用户分心的情况，比如某些提示信息在决定采用短暂显示的形式来保证页面更加简洁时，应当慎重一点，除非是一些不太重要的信息，即使用户没有看到也无关紧要。

### 之后你打开富途牛牛准备看下自己的收益情况

当用户看到移动端的屏幕时，需要使用`选择性注意`的能力，区分有用和无用的内容；屏幕上无用的信息越多，大脑选择耗费的`认知成本`就越大。

因此我们设计时就得考虑`怎样让用户更方便的获取信息`，在书中作者也列出了以下几点建议：

+ 清理屏幕，给内容让位；
> 这里引申出`交互时刻`的概念，即用户看到的屏幕内容、刚刚进行的操作、最终的目标等不同因素，决定了用户的需求也不一样。
> 比如以前总结的`关联搜索等复杂交互最好是单独新开页面`就是基于上述原理。

+ 让文字信息利于阅读。
> 专业的事还是交给专业的人来做，文字排版其实也涉及很多东西，这里暂且只列下书中作者提及的几点：1、把阅读内容分成小段；2、控制好背景和文字的对比度；3、优化文字大小；4、注意行间距与页边距等。

### 意外发现自己大赚了一笔，这时候你决定卖出股票落袋为安

用户通过触控与智能手机和平板电脑交流、下达指示、在屏幕上运行各种功能、享受服务......所以需要考虑这种操作模式的内在制约。

用户偏好使用左手还是右手、持握电话的习惯姿势、移动终端的尺寸大小等因素都存在差异，因此用户触及屏幕区域的难易程度也不尽相同，如下图所示：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/understanding-experience-2.jpg">

同样不过多展开，但是有一些很基础的点；

+ 足够大的活动区域
> 如果屏幕上元素过小，用户就难以避免的出现操作失误，另外这里的说的元素大小，并不一定是指元素显示出来的大小，而是包括了元素周围可以响应触摸的区域。
> 还要注意的是可触控区域并非越大越好，一旦超过了一定限度，反而会起相反的效果。

+ 在可触控区域之间拉开距离
> 可触控区域之间距离越近，用户同样就越难以避免的出现操作失误，但是距离越远就会浪费屏幕空间，所以这里也需要合理规划。

+ 功能可供性
> 功能可供性是事物自身特点所显示出的操作可能性，简单来说，凸起矩形一般就是可点击按钮，按钮上边文字是`买入`，那么点击这个按钮就能买入股票等。
> 功能可供性还有一点要注意的是，在设计界面的各种功能可供性元素时，切记不要出现错误操作指示，即形式上貌似可以操作，但实际上不可操作的元素。

### 你点击卖出股票然后被弹框告知“交易成功”

用户不可能百分百知道哪些元素可操作，哪些元素不可操作，既然如此，在用户操作后立即提供反馈显得非常重要。通过反馈，让用户知道系统已感知到他的行为，而且如果某个操作处理时间相对较长，提供反馈就更显得尤为重要，这样用户才不会对操作是否正确产生疑虑，从而避免进行没有意义的操作。

## 其它

上述小故事中仅仅涉及了《匠心体验-智能手机与平板电脑的用户体验设计》书中的一小部分基础知识点，还有大量关于`操作手势体验`、`传感器体验`、`声音体验`、`等待体验`、`情感体验`、`移动应用导航设计`、`移动应用效率问题`、`用户教学设计`等高端知识点，如果有兴趣可以查找相关资料详细了解。





