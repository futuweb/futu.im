---
title: passive 事件监听
date: 2017-06-06 10:30
category: 翻译
tags: [JS,技术]
author: Linda
---
# passive事件监听

passive事件监听，是[DOM规范](https://dom.spec.whatwg.org/#dom-eventlisteneroptions-passive)的新特性，它允许开发者通过避免滚动来阻止touch和wheel事件监听，而选择更好的滚动性能。开发者可以通过```{passive:true}```来表明他们不会调用```preventDefault```，注释掉touch和wheel监听。这个特性出现在[Chrome51](https://www.chromestatus.com/features/5745543795965952)，[FireFox49](https://bugzilla.mozilla.org/show_bug.cgi?id=1266066)，[登陆了Webkit](https://bugs.webkit.org/show_bug.cgi?id=158601)。

看看下面的passive事件监听的并行操作视频：

[demo video](https://www.youtube.com/watch?v=NPM6172J22g)
<!-- more -->

## 问题所在

对于web的优秀体验，流畅的滑动性能是必须的，尤其在触屏设备上。所有现代浏览器在重JavaScript运行的时候，有一个允许滚动流畅进行的线性滚动特性，但是这个优化因为需要等待```touchstart```  ```touchmove```操作的结果，会部分失败。```touchstart```等操作在事件中可能会通过调用[preventDefault()](https://www.w3.org/TR/touch-events/#the-touchstart-event)完全阻止滚动。当有作者确定要阻止滚动的特定场景时，解析显示web上的多数的touch时间处理函数实际上从来不调用```preventDefault()```，所以浏览器经常不需要性的阻断滚动。例如，在安卓Chrome中，80%的阻止滚动的touch事件实际上从未阻止过。这些事件中的10%在滚动前添加了多于100毫秒的延迟。在1%的滚动中会添加至少500毫秒的毁灭性延迟。

许多开发者了解到[在document中简单添加一个空的touch处理函数](http://rbyers.github.io/janky-touch-scroll.html)会对滚动性能有显著负面影响很惊讶。开发者很合理的期望监听一个事件的操作[不应该有任何负面影响](https://dom.spec.whatwg.org/#observing-event-listeners)。

这里的基本问题不是限制touch事件。[wheel事件](https://w3c.github.io/uievents/#events-wheelevents)也遭遇同样的问题。作为对比，[指针事件处理函数](https://w3c.github.io/pointerevents/)设计为从不延迟滚动（即使开发者可以通过touch-action css特性声明滚动），所以不用面临这个问题。基本上，passive事件监听建议带来了touch和wheel事件的性能特性。

这个建议，提供了作者指明在处理函数注册时，处理函数是否在事件中调用```preventDefault()```的方法(是否需要一个[可以取消](https://dom.spec.whatwg.org/#dom-event-cancelable)的事件)。当在包含可取消事件特定的点上没有touch或wheel处理函数时，用户代理空闲到可以立即开始滚动事件，不用等待JavaScript。那就是，passive监听对性能没有意外的负面影响。

## 事件监听选项

首先，我们需要对事件监听附加额外信息的机制。```addEventListener```中的```capture```参数是最贴近的例子，但是它的用法十分不透明：

```js
document.addEventListener('touchstart', handler, true);
```

[EventListenerOptions](https://dom.spec.whatwg.org/#dictdef-eventlisteneroptions)让大家更明确的写这段代码：

```js
document.addEventListener('touchstart', handler, {capture: true});
```

这是新（扩展）语法 -指定你希望监听调用[在捕获阶段还是冒泡阶段](http://javascript.info/bubbling-and-capturing#capturing)。

## 解决方案：passive选项

现在我们在事件处理函数注册时，对于指定选项有了扩展语法，我们可以添加一个新```passive```选项，可以前置声明监听函数在事件中从不调用```preventDefault()```。如果它调用，用户代理会忽略请求（理想状态生成至少一个控制台警告），就像它已经用```Event.cancelable=false```调用过一样。开发者可以通过查询```Event.defaultPrevented```在调用```preventDefault()```之前和之后确认这个。例如：

```js
addEventListener(document, "touchstart", function(e) {
    console.log(e.defaultPrevented);  // will be false
    e.preventDefault();   // does nothing since the listener is passive
    console.log(e.defaultPrevented);  // still false
}, Modernizr.passiveeventlisteners ? {passive: true} : false);
```

现在比起在有touch或wheel监听时不得不阻止滚动来说，浏览器只需要在有non-passive监听时（看下[TouchEvents spec](https://w3c.github.io/touch-events/#cancelability)）做这个。
passive监听无负面影响。

通过标记touch或wheel监听为passive，开发者可以承诺处理函数不用调用preventDefault()来使滚动失效。这使得浏览器能够立刻响应滚动，不用等待JavaScript，以此为用户保证可靠的流畅滚动体验。

## 特性检测

由于老式浏览器会把```capture```的第三个参数传的任何对象看作```true```值，开发者用这个API时，使用特性检测或[polyfill](https://github.com/WebReflection/dom4)就很重要，以避免不可预期的结果。对于指定选项的特性检测可以像下面这样：

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

[Modernizr](https://modernizr.com/)也是运作在[这个](https://github.com/Modernizr/Modernizr/issues/1894)检测上的，但还没发布。有一个围绕为字典成员特性检测提供更简洁API的[开放标准讨论](https://github.com/heycam/webidl/issues/107)。

## 移除取消事件的需求

有作者故意想要通过取消所有touch或wheel事件让滚动不可用的情况。这些包含：

1.平移或缩放地图

2.全屏游戏

在这些情况下，由于滚动自身是被一直阻止的，现有行为（阻止滚动优化）完全够。在这些情况下没有使用passive监听的需求，即使通常添加```touch-action: none```CSS规则来使你的意图清晰，是个好想法（例如支持浏览器pointer事件，但不是touch事件）。

然而，在一系列场景中，事件不需要阻塞滚动。例如：

1.只想知道用户最后活跃是在什么时间的用户动态监控

2.隐藏一些活动UI（像工具栏）的```touchstart```处理函数。

3.改变UI元素样式的```touchstart```和```touchend```处理函数（不阻止onclick事件）。

在这些场景下，不改其他代码，```passive```选项可以加上去（要有适当的特性检测），致使有了显著的更流畅的滑动体验。

有一些在确定条件下，处理函数只想阻止滑动的，更复杂的场景，就像：

1.横向滑动转传送带，打散一个物体或展示抽屉，但仍然允许垂直滚动。

1).这种情况下，使用```touch-action: pan-y```声明式的使沿水平轴的滚动失效，不必须调用```preventDefault()```。

2).为了继续在所有浏览器中可以正常运行，```preventDefault()```的调用应当在缺少特定的```touch-action```的条件下使用（Safari9现在只支持 ```touch-action:manipulation```）。

2.一个在水平滚轮事件滑动的UI元素（就像YouTube的声音调节滑动条），不会改变滚垂直滚轮的行为。由于对于wheel来说没有```touch-action```的等价事件，这个情况只能用非passive滚轮监听来实现。

3.事件代理模式的添加监听的代码，不会知道用户是否会取消事件。

1).这里的一个选项是单独代理passive和非passive监听（就好像他们是完全不同种类的事件一样）。

2).像上面那样发挥```touch-action```的影响力也是可以的。

## 调试及权衡利益

通过设置chrome://flags/#passive-listener-default(chrome 52)强制touch/wheel作为passive监听,可以迅速了解优势（及潜在的破坏）。这使得做边对边对比容易许多，像[这个视频中的](https://twitter.com/RickByers/status/719736672523407360)。

如何使用Chrome开发者工具识别阻塞滚动的监听，可以看[这个视频](https://www.youtube.com/watch?v=6-D_3yx_KVI)。你可以[监测事件时间戳](https://www.youtube.com/watch?v=6-D_3yx_KVI)来测量自然情况的滚动闪动，使用[Chromium的跟踪系统](https://www.chromium.org/developers/how-tos/trace-event-profiling-tool)来查看调试时滚动的输入延迟记录。

Chrome工作组在研究性能时间轴API及更多开发工具特性的提案，以帮助web开发者获得更好的看清这个问题。

## 减少和打破长运行JS仍然很重要

当一个页面展现出大量的滚动卡顿，是指示某些地方有潜在的性能问题。Passive 事件监听没有对潜在问题做事情，但我们仍然强烈鼓励开发者确保他们的应用在低性能设备上能在[指导范围](https://developers.google.com/web/fundamentals/performance/rail?hl=en)内。如果你的网站有每次跑大于100ms的逻辑，仍然会在tap和click响应上感觉很缓慢。passive事件监听只是允许开发者解耦了映射到滚动性能的JS响应问题和监控输入事件的请求。特别的，第三方分析库的开发者现在可以有自信，他们的轻量级事件监听的使用，不会从根本上改变，使用了他们代码的页面所看到的性能特性。

## 深入阅读及讨论

更多细节看[这里](https://github.com/WICG/EventListenerOptions)的链接。有问题的话，看[这里](https://github.com/WICG/EventListenerOptions/issues)的讨论，或者联系[@RickByers](https://twitter.com/RickByers/)。

原文：[https://github.com/WICG/EventListenerOptions/blob/gh-pages/explainer.md](https://github.com/WICG/EventListenerOptions/blob/gh-pages/explainer.md)

译者：[Linda](https://github.com/LindaWhite)

作者：[RByers](https://github.com/RByers)

