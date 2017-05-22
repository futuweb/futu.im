---
title: CSS动画 vs Web动画API
date: 2017-05-08 12:22
category: 翻译
tags: [JS,技术,css,animation]
author: Timi
---

上周，我写了篇关于[如何用css制作bitsofcode的logo动画](https://bitsofco.de/how-i-animated-the-bitsofcode-logo/)的文章。有人建议说可以试着去比较一下css动画和web动画API，于是就有了今天这篇文章。

<!-- more -->

## web动画API简介
像上周一样，我先简单介绍一下web动画API。web动画API为开发者们提供了一个直接用JavaScript操作浏览器动画引擎的方法。

### 创建一个动画
我们可以用`Element.animate()`函数来创建一个动画，它接受两个入参`keyframes`和`options`。

```js
element.animate(keyframes, options);
```

#### keyframes关键帧
`keyframes`对象表示动画时间轴中的一些关键事件。有两种方法去写这个对象。让我们以一个名为`grow`的动画为例，此动画会将元素放大两倍。这里是用css `@keyframes`的实现：

```css
@keyframes grow {
    0% {
        transform: none;
    }
    100% {
        transform: scale(2);
    }
}
```

`keyframes`的第一种表示方法是通过对象，对象的每个属性对应相应的css动画属性，属性的值是一个数组，里面是我们想表现的css动画对应的值，每个值可以看做时间轴上的一点。

```js
const growKeyframes = {
    transform: ['none', 'scale(2)'];
}
```

第二种`keyframes`的表示方法是用数组，数组每个元素表示相应时间轴上的一点，这样可以讲css属性和值与这点对应。

```js
const growKeyframes = [  
    { transform: 'none' },
    { transform: 'scale(2)' }
]
```

默认情况下，每个点在时间轴上是等分的。比方说时间轴上如果有5个点，那么每个点之间的动效时间都等于20%的总时间。

如果我们想调节时间，可以在`keyframes`的第二种写法里加上`offset`属性，值是一个0到1之间的数，代表动画运行的时间点。用一下css举例：

```css
@keyframes alteredGrow {
    0% { transform: none; }
    10% { transform: scale(1.5); }
    30% { transform: scale(1.9); }
    100% { transform: scale(2); }
}
```

考虑到不等分的时间点，我们可以这样写：

```js
const alteredGrowKeyframes = [  
    { transform: 'none' },
    { transform: 'scale(1.5)', offset: 0.1 },
    { transform: 'scale(1.9)', offset: 0.3 },
    { transform: 'scale(2)' }
]
```

#### options选项
`animate()`函数的第二个参数是包含一些特殊选项的对象。此对象可以用来精确定义对应css动效的所有属性，有九个值可以定义：

| 选项 | 描述 |
| :-------- | :-------- | 
| *id* | 动画的唯一标识 |
| *delay* | 动画开始前的延时，对应css的`animation-delay`属性 |
| *duration* | 动画所需总时间，对应css的`animation-duration`属性 |
| *iterations* | 动画播放次数，对应css的`animation-iteration-count`属性 |
| *direction* | 动画运行的方向，对应css的`animation-direction`属性 |
| *easing* | 动画关键帧之间的过渡效果，对应css的`animation-timing-function`属性 |
| *fill* | 动画播放前后时的停留状态，对应css的`animation-fill-mode`属性 |
| *endDelay* | 动画结束后的延时时间 |
| *iterationStart* | 动画的开始播放点 |

以`alteredGrow`这个动画举例，用css我们设置总时间为3秒，无限循环，互换方向，延时2秒开始：

```css
.animated-element {
    animation-name: alteredGrow;
    animation-duration: 3s;
    animation-iteration-count: infinite;
    animation-direction: alternate;
    animation-delay: 2s;
}
```

用web动画API，我们可以这样写：

```js
const alteredGrowOptions = {  
    duration: 3000,
    iterations: Infinity,
    direction: 'alternate',
    delay: 2000
};
```

### 使用动画
将动画应用到一个元素是通过调用其本身的`animate()`方法，并传入`keyframes`和`options`参数。

```js
const element = document.querySelector('.animated-element');  
element.animate(alteredGrowKeyframes, alteredGrowOptions);
```

方法一被调用，动画会自动开始播放。不过我们也可以通过`play()`和`pause()`方法来控制动画的开始和暂停。

```js
const element = document.querySelector('.animated-element');  
const myAnimation = element.animate(alteredGrowKeyframes, alteredGrowOptions);

myAnimation.pause();  
myAnimation.play(); 
```

### 浏览器支持
<iframe src="//caniuse.bitsofco.de/embed/index.html?feat=web-animation&amp;periods=future_1,current,past_1" frameborder="0" width="100%" height="500px"></iframe>

## bitsofcode Logo动画
我重构了一下之前的css动画，比较如下：

<video width="640" controls="" muted="" playsinline="" poster="http://res.cloudinary.com/ireaderinokun/video/upload/v1493313196/Animating_bitsofcode_pa16yn.jpg">  
    <source type="video/webm" src="http://res.cloudinary.com/ireaderinokun/video/upload/v1493313196/Animating_bitsofcode_pa16yn.webm">
    <img src="http://res.cloudinary.com/ireaderinokun/video/upload/v1493313196/Animating_bitsofcode_pa16yn.jpg">
</video>

### 创建时间轴
logo左半部分（bitso）动画效果概况如下：
 
1. 左移
2. 回到中央
3. 中央停留，等待右半部分的动画
4. 左移
5. 旋转
6. 慢速旋转
7. 恢复旋转前的位置
8. 回到中央
 
以上步骤对应如下时间轴：

![timeline](https://bitsofco.de/content/images/2017/04/timline-bitsofcode.png)

根据时间轴可以写出`keyframes`对象:

```js
const logoSectionLeftKeyframes = [  
  { transform: 'none' },
  { offset: 0.125, transform: 'translateX(-15px)' },
  { offset: 0.25, transform: 'none' },
  { offset: 0.5, transform: 'none' },
  { offset: 0.625, transform: 'translateX(-15px)' },
  { offset: 0.67, transform: 'translateX(-15px) rotate(-10deg)' },
  { offset: 0.72, transform: 'translateX(-15px) rotate(-10deg)' },
  { offset: 0.82, transform: 'translateX(-15px) rotate(-15deg)' },
  { offset: 0.875, transform: 'translateX(-15px)' },
  { transform: 'none' }
];
```

因为需要使用`offset`属性，我决定用数组形式表示`keyframes`。

### 设置Options
每段动画对应的options很简单，运行3秒，无限循环。

```js
const logoSectionOptions = {  
  duration: 3000,
  iterations: Infinity
};
```

### 应用动画
用web API实现动画比用css繁琐很多，因为我希望只有当logo被hover或focus的时候才运行动画，但之前也提到过默认情况下，动画一被应用是自动运行的。

为了实现这一效果，我先创建了一个动画，立马暂停，然后为动画的播放和暂停加上时间监听。除此之外，因为每个单词会应用上独立的动画，我必须同时处理很多动画，实现如下：

```js
// 保存所有动画的数组
const animations = [];

function playLogoAnimation() {  
  animations.map((animation) => animation.play())
}

function pauseLogoAnimation() {  
  animations.map((animation) => {
      animation.pause();
      animation.currentTime = 0; // 将动画恢复为初始状态
  })
}

function createLogoAnimation() {  
  const logoSectionLeftEls = Array.from( document.querySelectorAll('.logo-section-left') );
  logoSectionLeftEls.forEach((el) => animations.push(el.animate(logoSectionLeftKeyframes, logoSectionTiming)))

  // 省略logo中间及右边部分的动画代码 …

  // 立即暂停动画
  pauseLogoAnimation();
}

createLogoAnimation();

// 动画播放及暂停的时间监听
const siteTitleLink = document.querySelector('.site__title a');  
siteTitleLink.addEventListener('mouseover', playLogoAnimation);  
siteTitleLink.addEventListener('mouseout', pauseLogoAnimation);  
siteTitleLink.addEventListener('keyup', (e) => {  
  if ( e.keyCode === 9 ) playLogoAnimation();
});
siteTitleLink.addEventListener('keydown', (e) => {  
  if ( e.keyCode === 9 ) pauseLogoAnimation();
});
```

完成后的CodePen展示：
<iframe id="cp_embed_MmJOzR" src="//codepen.io/ire/embed/MmJOzR?height=400&amp;theme-id=21401&amp;slug-hash=MmJOzR&amp;default-tab=result&amp;user=ire&amp;embed-version=2&amp;pen-title=MmJOzR" scrolling="no" frameborder="0" height="400" allowtransparency="true" allowfullscreen="true" name="CodePen Embed" title="MmJOzR" class="cp_embed_iframe " style="width: 100%; overflow: hidden;"></iframe>

## CSS动画 vs Web动画API
使用css还是js动画很大程度上取决于这个动画本身的情况。一般来说，css动画多用于一些小的UI有关的动画展示，比如tooltip之类的。Web动画API会被用在更复杂，需要更多细微控制的场景。以下是仅对logo动画而言两者的比较。

### 性能
css和js动画的性能根据所用的不同动画属性会产生很大的差异。一般建议仅在`transform`和`opacity`属性上应用动画效果，因为它们可以在浏览器的子线程中运行，不影响浏览器主线程。

> 改变`transform`不会触发重排，这点很棒，这意味着这一操作可以被GPU的合成线程大大加速。
> —— [CSS Triggers](https://csstriggers.com/transform)

由于我的动画只用到了`transform`属性，所以并不能看出这两种实现方法之间的显著差别。用火狐的开发者工具，我测量了它们两者的帧率，即使在关闭主线程动画的情况下，两者的帧率也都是60帧每秒。

除此之外我没有什么其他的方法去评估两者的性能了。如果你知道更好的方法请务必评论告诉我。

### 开发体验
仅针对这个动画而言，我个人觉得css动画比web动画API更容易实现，主要原因是js要绑定很多播放，暂停的操作。如果我去做一些更复杂的动画，例如游戏的话，web动画API肯定是首选项。但就这个动画来说css写起来更简单一些。



原文：[CSS Animations vs the Web Animations API: A Case Study](https://bitsofco.de/css-animations-vs-the-web-animations-api/)

作者：[Ire Aderinokun](https://ireaderinokun.com/)

译者：[Timi](http://tianq.space/posts/2017/CSS动画%20vs%20web动画API/)


