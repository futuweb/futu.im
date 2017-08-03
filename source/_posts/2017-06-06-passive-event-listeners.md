---
title: passive 事件监听
date: 2017-06-06 10:30
category: 翻译
tags: [JavaScript,事件,性能]
author: Linda
---

# passive事件监听

passive事件监听，是[DOM规范](https://dom.spec.whatwg.org/#dom-eventlisteneroptions-passive)的新特性，它可以让开发者选择不阻止touch和wheel事件监听，从而获得更好的滚动性能。开发者可以在监听touch和wheel事件时指定`{passive:true}`来表明他们不会调用`preventDefault`。这个特性出现在[Chrome51](https://www.chromestatus.com/features/5745543795965952)，[FireFox49](https://bugzilla.mozilla.org/show_bug.cgi?id=1266066)，[以及Webkit](https://bugs.webkit.org/show_bug.cgi?id=158601)。看看下面的passive事件监听的效果对比视频：

[demo video](https://www.youtube.com/watch?v=NPM6172J22g)

<!-- more -->

## 问题所在

对于web，尤其是移动设备上的web来说，流畅的滚动性能会直接决定用户体验。所有现代浏览器都有一个单独的线程处理页面滚动，即使是在JavaScript运行的时候也能流畅地滚动，但是这个优化有局限性，因为在需要等待`touchstart`和 `touchmove`操作的结果时就无法进行优化。这是因为`touchstart`等事件处理函数中可能会调用[preventDefault】()](https://www.w3.org/TR/touch-events/#the-touchstart-event)完全阻止滚动。在实际开发中，确实有需要阻止滚动的场景，但是分析结果表明，web上的多数的touch事件处理函数实际上从来不调用`preventDefault()`，所以浏览器通常不需要阻止滚动。例如，在安卓Chrome中，对滚动性能造成影响的情况中，有80%的事件都没有被阻止 。有10%的情况导致滚动延迟多于100毫秒。1%的情况导致延迟至少500毫秒，简直是毁灭性的影响。

许多开发者注意到[在document中简单添加一个空的touch处理函数](http://rbyers.github.io/janky-touch-scroll.html)会对滚动性能有非常明显的负面影响。他们觉得很惊讶，监听一个事件的操作[不应该有任何负面影响](https://dom.spec.whatwg.org/#observing-event-listeners)。

同样的问题并不只出现在touch事件上。[wheel事件](https://w3c.github.io/uievents/#events-wheelevents)也遭遇同样的问题。与它们不同，[指针事件处理函数](https://w3c.github.io/pointerevents/)被设计为不影响滚动（尽管开发者仍然可以通过`touch-action`这个CSS属性阻止滚动），所以不用面临这个问题。大体上讲，passive事件监听就是将指针事件的性能带给了touch和wheel事件。

这个提案允许开发者在注册事件处理函数时，指明是否会在处理函数中调用`preventDefault()`的方法(是否需要一个[可以取消](https://dom.spec.whatwg.org/#dom-event-cancelable)的事件)。当touch或wheel事件处理函数并没有需要包含可取消事件时，浏览器就可以在不等待JavaScript执行的情况下，立即开始滚动。也就是，passive监听的事件处理函数对性能没有负面影响。

## EventListenerOptions（事件监听选项）

首先，我们需要对事件监听附加额外信息的机制。`addEventListener`中的`capture`参数是最类似的例子，但是它的用法并不是十分明了：

```javascript
document.addEventListener('touchstart', handler, true);
```

[EventListenerOptions](https://dom.spec.whatwg.org/#dictdef-eventlisteneroptions)让大家可以以一种更明了的方式指定参数：

```javascript
document.addEventListener('touchstart', handler, {capture: true});
```

这是指定你希望[在捕获阶段还是冒泡阶段](http://javascript.info/bubbling-and-capturing#capturing)监听事件的新语法，它是一种扩展的语法。

## 解决方案：passive 选项

在有了扩展语法之后，我们在注册事件处理时，就可以添加一个新`passive`选项，用于提前声明监听函数在事件中从不调用`preventDefault()`。如果它调用，浏览器会忽略请求（并很机智地在控制台警告），就像它已经调用过`Event.cancelable=false`一样。开发者可以通过在调用`preventDefault()`之前和之后查看`Event.defaultPrevented`来进行确认。例如：

```js
addEventListener(document, "touchstart", function(e) {
		console.log(e.defaultPrevented);  // will be false
		e.preventDefault();   // does nothing since the listener is passive
		console.log(e.defaultPrevented);  // still false
}, Modernizr.passiveeventlisteners ? {passive: true} : false);
```

现在，相比只要有touch或wheel监听就不得不阻止滚动来说，浏览器只需要在有non-passive监听时（参见[TouchEvents spec](https://w3c.github.io/touch-events/#cancelability)）才阻止滚动。也就是说passive监听可以解决性能问题。

通过指定touch或wheel监听为passive的，开发者就是在承诺处理函数不调用`preventDefault()`来取消滚动。这使得浏览器能够立刻响应滚动，不用等待JavaScript，以此为用户保证流畅滚动体验。

## 特性检测

由于老旧浏览器会把第三个参数`capture`传的任何对象看作`true`值，开发者用这个API时，需要使用特性检测或[polyfill](https://github.com/WebReflection/dom4)，以避免预期之外的结果。对于指定选项的特性检测可以像下面这样：

```js
// Test via a getter in the options object to see if the passive property is accessed
var supportsPassive = false;
try {
	var opts = Object.defineProperty({}, 'passive', {
		get: function() {
			supportsPassive = true;
		}
	});
	window.addEventListener("test", null, opts);
} catch (e) {}

// Use our detect's results. passive applied if supported, capture will be false either way.
elem.addEventListener('touchstart', fn, supportsPassive ? { passive: true } : false); 
```

为了更简洁，可以使用[Detect It](https://github.com/rafrex/detect-it)的特性检测，例如:

```js
	elem.addEventListener('touchstart', fn,
		detectIt.passiveEvents ? {passive:true} : false);
```

[Modernizr](https://modernizr.com/)正在处理[这个](https://github.com/Modernizr/Modernizr/issues/1894)特性检测，但还没发布。此外有一个关于字典成员特性检测是否提供更简洁API的[开放标准讨论](https://github.com/heycam/webidl/issues/107)。

## 消除取消事件的需求

有一些场景是开发者想要取消所有touch或wheel事件让滚动不可用的情况。这些包含：

1.平移或缩放地图
2.全屏游戏

在这些情况下，由于滚动自身是被一直阻止的，现有行为完全能够满足（没有滚动优化）。在这些情况下没有必要使用passive监听，虽然一般还是会添加`touch-action: none`CSS属性来显式表达你的意图（例如可以更好地支持那些有pointer事件，但没有touch事件的浏览器）。

然而，在一系列场景中，事件处理函数根本不需要阻塞滚动。例如：

1. 只想知道用户最后活跃是在什么时间的用户动态监控
2. 隐藏一些活动UI（像工具栏）的`touchstart`处理函数。
3. 改变UI元素样式的`touchstart`和`touchend`处理函数（不阻止onclick事件）。

在这些场景下，可以不修改其他代码，直接添加`passive`选项上去（要有适当的特性检测），滑动体验会明显变得更流畅。

还有一些更复杂的场景，只想在一些确定的条件下阻止滑动，例如：

1. 在横向滑动的时候去切换轮播图、移动一个条目，或者切换某个元素展示隐藏，但是仍然允许纵向滚动。
	1. 这种情况下，可以使用`touch-action: pan-y`来声明不需要横向滚动，不需要调用`preventDefault()`。
	2. 为了在所有浏览器中可以正常运行，`preventDefault()`的调用应当在缺少特定的`touch-action`属性支持的条件下使用（Safari9现在只支持 `touch-action:manipulation`）。
2. 一个需要使用横向滚动事件来滑动的UI元素（就像YouTube的声音调节滑动条），但不会改变滚垂直滚轮的行为。由于对于`wheel`来说没有`touch-action`的等价事件，这个情况只能用non-passive滚轮监听来实现。
3. 事件代理模式下添加的监听代码，不会知道用户是否会取消事件。
	1. 一个可用的方法是单独代理passive和non-passive监听（就好像他们是完全不同种类的事件一样）。
	2. 像上面那样发挥`touch-action`的影响力也是可以的。

## 调试及权衡利益

通过`chrome://flags/#passive-listener-default`(chrome 52)强制设置touch/wheel为`passive`监听，可以快速了解它的优势（以及可能造成的问题）。这使得你能够自己做更直观的对比，像[这个视频中的](https://twitter.com/RickByers/status/719736672523407360)那样。

如何使用Chrome开发者工具识别阻塞滚动的监听，可以看[这个视频](https://www.youtube.com/watch?v=6-D_3yx_KVI)。你可以[监测事件时间戳](https://www.youtube.com/watch?v=6-D_3yx_KVI)来衡量滚动的性能，也可以使用[Chromium的跟踪系统](https://www.chromium.org/developers/how-tos/trace-event-profiling-tool)来查看调试时滚动的输入延迟（InputLatency）记录。

Chrome工作组正在准备关于[Performance Timeline API](https://code.google.com/p/chromium/issues/detail?id=543598)及[更多开发工具](https://code.google.com/p/chromium/issues/detail?id=520659)特性的提案，以帮助web开发者更好的看清这个问题。

## 减少和打断长时间运行的JS仍然很重要

当一个页面展现出大量的滚动卡顿，就表示某些地方有潜在的性能问题。`passive`事件监听没有对潜在问题做事情，所以我们仍然强烈建议开发者确保他们的应用在低性能设备上能满足[性能指导范围](https://developers.google.com/web/fundamentals/performance/rail?hl=en)。如果你的网站有的逻辑每次运行都大于100ms，那么仍然会在tap和click响应上感觉很缓慢。`passive`事件监听只是允许开发者解耦了映射到滚动性能的JS响应问题和监控输入事件的请求。特别值得一提的是，第三方库的开发者现在可以更有自信一点说，他们对轻量级事件监听的使用，不会对使用了他们代码的页面的性能造成明显的改变。

## 深入阅读及讨论

更多细节看[这里](https://github.com/WICG/EventListenerOptions)的链接。有问题的话，看[这里](https://github.com/WICG/EventListenerOptions/issues)的讨论，或者联系[@RickByers](https://twitter.com/RickByers/)。

原文：[https://github.com/WICG/EventListenerOptions/blob/gh-pages/explainer.md](https://github.com/WICG/EventListenerOptions/blob/gh-pages/explainer.md)

译者：[Linda](https://github.com/LindaWhite)

作者：[RByers](https://github.com/RByers)

