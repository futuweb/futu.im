---
title: 4中javascript的内存泄露及避免方法
date: 2017-05-09 10:30
category: 翻译
tags: [JS,技术]
author: Linda
---
这篇文章里面我们会讨论客户侧javascript代码中的常见种类的内存泄漏。也会学习如何用Chrome Development Tools来定位这些问题。继续阅读吧！

# 介绍

内存泄漏是每个开发者最终必须面对的问题。即使使用有内存管理的语言，也有内存可能会泄漏的情况。泄漏是很多问题的起因：变慢，崩溃，高延迟，甚至是一些和其他应用一起用所出现的问题。
	
## 内存泄漏是什么？

本质上，内存泄漏可以定义为一个应用，由于某些原因不再需要的内存没有被操作系统或者空闲内存池回收。编程语言支持多种管理内存的方式。这些方式可能会减少内存泄漏的几率。然而，某一块内存是否没有用到实际上是一个[不可判定的问题](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_Management#Release_when_the_memory_is_not_needed_anymore)。换句话说，只有开发者可以弄清一块内存是否可以被操作系统回收。某些编程语言提供了帮助开发者做这个的特性。其他一些语言期望开发者可以完全明确什么时候一块内存是没被使用的。Wikipedia有关于[手动](https://en.wikipedia.org/wiki/Manual_memory_management)和[自动](https://en.wikipedia.org/wiki/Manual_memory_management)内存管理的两篇不错的文章。
<!-- more -->

## Javascript中的内存管理

JavaScript是所谓的垃圾回收语言之一。垃圾回收语言，通过定期检查哪些事先被分配的内存块仍然可以被应用的其他部分“访问”到，来帮助开发者管理内存。换句话说，垃圾回收语言从“哪些内存是仍然被需要的？”到“哪些内存是仍然可以被应用的其他部分访问到的”减少了管理内存的问题。差异很微妙，但是很重要：当只有开发者知道一块分配了的内存将来会被需要，访问不到的内存可以在算法上被决策并标记为系统回收内存。

> 非垃圾回收语言通常通过其他技术来管理内存：明确的内存管理，当一块内存不需要时，开发者明确的告诉编译器；还有引用计数，用计数与每个内存块关联（当计数到0时，被系统收回）。这些技术有他们自己的协定（和潜在的泄漏原因）。

## JavaScript中的泄漏
在垃圾回收语言中，泄漏的主要原因是不必要的引用。为了理解什么是不必要的引用，首先需要理解垃圾回收器是如何决策一块内存是否可以被访问到的。

> “垃圾回收语言中的泄漏的主要原因是不必要的引用”。

## Mark-and-sweep

大多数垃圾回收器使用一种被称为mark-and-sweep的算法。这个算法包括下面的几步：

1.垃圾回收器建立一个根节点的列表。根节点通常是代码中一个一直在的引用对应的全局变量。在JavaScript中，window对象是一个可以作为根节点的全局变量的例子。window对象总是在线，所以垃圾回收器可以看重它并且它所有的子节点总是在线（即非垃圾）。


2.所有的根节点被检查并且标记为活跃（即非垃圾）。所有子节点也同样被递归检查。每个从根节点可以到达的节点不会被认为垃圾。


3.所有没被标记为活跃的内存块现在可以被认为是垃圾。回收器现在可以释放掉那块内存并且还给操作系统。

现代垃圾回收器通过不同方法提升了这个算法，但是本质是一样的：可访问到的内存块被标记出来，剩下的被认为是垃圾。
不必要的引用，是开发者知道他/她不会再需要的，但由于某些原因存在于活跃根节点的树上的内存块，所对应的引用。在JavaScript的上下文中，不必要的引用是代码中存在的不会再用到，指向一块本来可以被释放的内存的变量。一些人会证明这是开发者的错误。

所以想要理解哪些是JavaScript中最常见的泄漏，我们需要知道引用通常被忘记是通过哪些方式。

# 3种常见的JavaScript泄漏

## 1.意外的全局变量

JavaScript的目标是开发一种看起来像Java但足够自由的被初学者使用的语言。JavaScript自由的其中一种方式是它可以处理没有声明的变量：一个未声明的变量的引用在全局对象中创建了一个新变量。在浏览器的环境中，全局对象是window。也就是说：

```js
function foo(arg) {
    bar = "this is a hidden global variable";
}
```

实际上是：

```js
function foo(arg) {
    window.bar = "this is an explicit global variable";
}
```

如果```bar```是仅在```foo```函数作用域内承载引用，并且你忘记用```var```来声明的变量，一个意外的全局变量就被创建了。在这个例子中，泄漏一个单一字符串不会有太大害处，但这的确是不好的。
另一种意外全局变量被创建的方式是通过```this```：

```js
function foo() {
    this.variable = "potential accidental global";
}

// Foo called on its own, this points to the global object (window)
// rather than being undefined.
foo();
```
> 为了阻止这种错误发生，在你的Javascript文件最前面添加```'use strict;'```。这开启了解析JavaScript的阻止意外全局的更严格的模式。

全局变量的一个注意事项：

即使我们谈了不明的全局变量，仍然存在很多代码被显式的全局变量填充的情况。这是通过定义不可收集的情况（除非清零或重新赋值）。特别的，用来临时存储和处理大量信息的全局变量会引起关注。如果必须用全局变量来存储很多数据，在处理完之后，确保对其清零或重新赋值。 一个在与全局连接上增加内存消耗常见的原因是[缓存](https://en.wikipedia.org/wiki/Cache_(computing))。 缓存存储重复被使用的数据。为此，为了有效，缓存必须有其大小的上限。飙出限制的缓存可能会因为内容不可被回收，导致高内存消耗。

## 2.被遗忘的计时器或回调

在JavaScript中```setInterval```的使用相当常见。其他库提供观察者和其他工具以回调。这些库中大多数，在引用的实例变成不可访问之后，负责让回调的任何引用也不可访问。在setInterval的情况下，这样的代码很常见：

```js
var someResource = getData();
setInterval(function() {
    var node = document.getElementById('Node');
    if(node) {
        // Do stuff with node and someResource.
        node.innerHTML = JSON.stringify(someResource));
    }
}, 1000);
```  
这个例子表明了跳动的计时器可能发生什么：计时器使得节点或数据的引用不再被需要了。代表```node```的对象将来可能被移除，使得整个块在间隔中的处理不必要。然而，处理函数，由于间隔仍然是活跃的，不能被回收（间隔需要被停掉才能回收）。如果间隔处理不能被回收，它的依赖也不能被回收。那意味着可能存储着大量数据的```someResource```，也不能被回收。
观察者情况下，一旦不被需要（或相关的对象快要访问不到）就创建明确移除他们的函数很重要。在过去，这由于特定浏览器（IE6）不能很好的管理循环引用（下面有更多相关信息），曾经尤为重要。现如今，一旦观察对象变成不可访问的，即使收听者没有明确的被移除，多数浏览器可以并会回收观察者处理函数。然而，它保持了在对象被处理前明确的移除这些观察者的好实践。例如：

```js
var element = document.getElementById('button');

function onClick(event) {
    element.innerHtml = 'text';
}

element.addEventListener('click', onClick);
// Do stuff
element.removeEventListener('click', onClick);
element.parentNode.removeChild(element);
// Now when element goes out of scope,
// both element and onClick will be collected even in old browsers that don't
// handle cycles well.
```

一条关于对象观察者及循环引用的笔记

观察者和循环引用曾经是JavaScript开发者的祸患。这是由于IE垃圾回收的一个bug(或者设计决议)出现的情况。IE的老版本不能检测到DOM节点和JavaScript代码间的循环引用。 这是一个通常为观察到的保留引用（如同上面的例子）的观察者的典型。  也就是说，每次在IE中对一个节点添加观察者的时候，会导致泄漏。这是开发者在节点或空引用之前开始明确的移除处理函数的原因。 现在，现代浏览器（包括IE和MS Edge）使用可以剪裁这些循环和正确处理的现代垃圾回收算法。换言之，在使一个节点不可访问前，调用```removeEventLister```不是严格意义上必须的。

像Jquery一样的框架和库做了在处置一个节点前（当为其使用特定的API的时候）移除监听者的工作。这被在库内部处理，即使在像老版本IE一样有问题的浏览器里面跑，也会确保没有泄漏产生。

## 3. 超出DOM引用
有时存储DOM节点到数据结构中可能有用。假设你想要迅速的更新一个表格几行内容。存储每个DOM行节点的引用到一个字典或数组会起作用。当这发生是，两个对于同个DOM元素的引用被留存：一个在DOM树中，另外一个在字典中。如果在将来的某些点你决定要移除这些行，需要让两个引用都不可用。

```js
var elements = {
    button: document.getElementById('button'),
    image: document.getElementById('image'),
    text: document.getElementById('text')
};

function doStuff() {
    image.src = 'http://some.url/image';
    button.click();
    console.log(text.innerHTML);
    // Much more logic
}

function removeButton() {
    // The button is a direct child of body.
    document.body.removeChild(document.getElementById('button'));

    // At this point, we still have a reference to #button in the global
    // elements dictionary. In other words, the button element is still in
    // memory and cannot be collected by the GC.
}
```
对此的额外考虑，必须处理DOM树内的内部节点或叶子节点。假设你在JavaScript代码中保留了一个对于特定的表格内节点（一个td标签）的引用。在将来的某个点决定从DOM中移除这个表格，但是保留对于那个节点的引用。直观的，会假设GC会回收除那个节点之外的每个节点。在实践中，这不会发生的：这个单节点是那个表格的子节点，子节点保留对父节点引用。换句话说，来自JavaScript代码的表格元素的引用会引起在内存里存整个表格。当保留DOM元素的引用的时候，仔细考虑下。

## 4.闭包

一个JavaScript开发的关键点是闭包：从父级作用域捕获变量的匿名函数。很多开发者发现，由于JavaScript runtime的实现细节，有以一种微妙的方式泄漏的可能，[这种特殊的情况](https://blog.meteor.com/an-interesting-kind-of-javascript-memory-leak-8b47d2e7f156)：

```js
var theThing = null;
var replaceThing = function () {
  var originalThing = theThing;
  var unused = function () {
    if (originalThing)
      console.log("hi");
  };
  theThing = {
    longStr: new Array(1000000).join('*'),
    someMethod: function () {
      console.log(someMessage);
    }
  };
};
setInterval(replaceThing, 1000);
```

这个代码片段做了一件事：每次```replaceThing```被调用的时候，```theThing```获取到一个包括一个大数组和新闭包(```somMethod```)的新对象。同时，变量```unused```保留了一个有```originalThing```（```theThing```从之前的对```replaceThing```的调用）引用的闭包。已经有点疑惑了，哈？重要的是一旦一个作用域被在同个父作用域下的闭包创建，那个作用域是共享的。这种情况下，为闭包```somMethod```创建的作用域被```unused```共享了。```unused```有一个对```originalThing```的引用。即使```unused```从来没被用过，```someMethod```可以通过```theTing```被使用。由于```someMethod```和```unused```共享了闭包作用域，即使```unused```从来没被用过，它对```originalThing```的引用迫使它停留在活跃状态（不能回收）。当这个代码片段重复运行的时候，可以看到内存使用稳步的增长。GC运行的时候，这并不会减轻。本质上，一组关联的闭包被创建（同```unused```变量在表单中的根节点一起），这些闭包作用域中每个带了大数组一个非直接的引用，导致了大型的泄漏。

> 这是一个实现构件。一个可以处理这关系的闭包的不同实现是可以想象的，就如在[这篇博客](https://blog.meteor.com/an-interesting-kind-of-javascript-memory-leak-8b47d2e7f156)中解释的一样。

# 垃圾回收的直观行为

即使垃圾回收很方便，他们有自己的一套权衡方法。其中一个权衡是nondeterminism。也就是说，GC是不可预期的。通常不能确定什么时候回收器被执行。这意味着在一些情况下，需要比程序正在使用的更多的内存。其他情况下，短的暂停在特别敏感的应用中很明显。即使不确定性意味着不能确定回收什么时候执行，大多数GC实现共享在分配期间，普通的回收通行证模式。如果没有执行分配，大多数CG停留在休息状态。考虑下面的方案：

1.执行一组大型的分配。

2.多数元素（或所有）被标记为不可访问（假设我们置空了一个指向不再需要的缓存的引用）。

3.没有进一步的分配执行了。


在这个方案中，大多GC不会运行任何进一步的回收通行了。换言之，即使有可用于回收的，不可访问的引用，回收器不会要求他了。这不是严格的泄漏，但是也会导致比平常更高的内存使用率。
Google在 [JavaScript Memory Profiling docs, example #2](https://developer.chrome.com/devtools/docs/demos/memory/example2).文章中，提供了一个优秀的例子。

# Chrome内存分析工具概览

Chrome提供了一系列优秀的工具来分析JavaScript代码的内存使用。这两幅图域内存相关：timeline图及profile图。

Timeline视图

![css_layouts](/images/2017-memory-leaks/timeline.png)

timeline视图在发现代码中异常内存模式是必须的。假使在找大型泄漏，在回收之后，不与增长一样多收缩的，周期性跳跃，是一个红色标记。在这个截图中可以看到泄漏的对象的稳定增长是什么样的。即使在最后的大型回收之后，使用的内存的总量比在开始时高。节点数量也高。这都是代码中某处DOM节点泄漏的标志。

Profile视图

![css_layouts](/images/2017-memory-leaks/profiles.png)

这是你会花大部分时间看的视图。分析视图允许你获得一个快照，比较JavaScript代码中内存使用的快照。也允许记录一段时间的分配情况。在每个结果图中可以看不同种类的列表，但是我们任务中，关系最大的是总结列表和比较列表。
总结列表给我们不同对象的分配及汇总大小的概览：表面大小（一个具体类别的所有对象的总和）和保存大小（表面大小加上其他对象为这个对象留存的大小）。也给我们一个对象与其GC根节点有多远的概念。
对比列表给我们同样的信息，但是允许我们比较不同的快照。这个对于找泄漏十分有用。

## 示例：使用Chrome找内存泄漏

基本上有两种泄漏：引起内存使用周期性的增长的泄漏，以及只发生一次并不会引进一步内存增长的泄漏。很明显，当内存是周期性的，发现泄漏更容易。这些也是最棘手的问题：如果内存经过一段时间后增长，这类型的泄漏会最终引起浏览器变慢或停止执行脚本。当非周期性的泄漏在其他分配中大到足够明显，可以很容易的发现它们。通常情况并非如此，所以他们通常被忽视。在某种程度上，发生了一次的小泄漏可以被看作一个优化议题。然而，周期性的泄漏是bug，必须修复。

例如，我们会用[Chrome文档中的一个例子](https://developer.chrome.com/devtools/docs/demos/memory/example1)。下面贴出了全部代码：

```js
var x = [];

function createSomeNodes() {
    var div,
        i = 100,
        frag = document.createDocumentFragment();
    for (;i > 0; i--) {
        div = document.createElement("div");
        div.appendChild(document.createTextNode(i + " - "+ new Date().toTimeString()));
        frag.appendChild(div);
    }
    document.getElementById("nodes").appendChild(frag);
}
function grow() {
    x.push(new Array(1000000).join('x'));
    createSomeNodes();
    setTimeout(grow,1000);
}
```

当```grow```被调用的时候，会看上创建div节点，并添加到DOM。也会分配一个大数组，并添加到一个被全局变量引用的数组。这会引起可以用上面提到的内存工具发现的，稳定内存增长。

> 垃圾回收语言通常显示为震荡的内存使用模式。通常情况，如果代码在带分配内存的循环中的时候，是期望有这个的。我们会寻找，回收后不恢复到之前情况的，周期增长的内存。

## 找出内存是否在周期性的增长

时间轴视图对此很有用。在Chrome中打开[这个示例](https://developer.chrome.com/devtools/docs/demos/memory/example1)，打开开发者工具，到时间轴选项卡，选内存，点击记录按钮。然后到需要测的页面，点击“按钮”开始泄漏内存。等一小会停止记录，看下结果：

![css_layouts](/images/2017-memory-leaks/example-timeline.png)

> 这个例子每一秒会持续泄漏内存。在停止记录之后，在```grow```函数内打个断点，以阻止脚本迫使Chrome关闭页面。

这图中有两个明显的标志，可以看出我们在泄漏内存。节点（绿色线）和JS堆（蓝色线）的图表。节点在稳健增长，从未减少过。这是个重要的警告标志。

JS堆同样也展示了内存使用的稳健增长。由于垃圾收集器的影响，这更难看到了。可以看到最初的内存增长，跟随很厉害的减少，再然后是增长，之后是一个突刺，后续是内存的掉落。换言之，即使内存收集器成功收集了很多内存，其中一些还是被周期性的泄漏了。现在我们确定了有泄漏。让我们找到泄漏。

## 取得两张快照

为了发现泄漏，我们会来的Chrome开发者工具的profile部分。为将内存使用保持在可控的水平，在做这步之前重新加载下页面。我们会用到Take Heap Snapshot函数。
重新加载页面，在加载完成之后，就照一张堆的快照。我们会把这张快照作为基准图来使用。之后，再次点“按钮”。等几秒钟，然后拍第二张快照。在拍完快照之后，建议在脚本中打个断点，来阻止更多内存被使用。

![css_layouts](/images/2017-memory-leaks/example-snapshots-1.png)

有两种方法可以在两张快照中看到内存分配。可以选择Summary然后从右面选快照1和快照2分配的对象，或者选Comparison而不是Summary。在两种情况下我们可以看到在两张快照间被分配对象的列表。

在这种情况下很容易找到泄漏：他们很大。看下```(String)```构造函数的```Size Delta```。58个对象，8MB。这看上去有点可疑：新对象被分配了但是没有释放，8MB被消耗掉了。

如果我们打开```(String)```构造函数，我们会注意到在小块内存分配之间，有一些大块的分配。这些大块立刻引起了我们的注意。如果你选择他们其中单独一个，可以在retainer部分下面看到一些有趣的东西。

![css_layouts](/images/2017-memory-leaks/example-snapshots-2.png)

我们看到选中的分配是一个数组的一部分。按顺序，这数组被在全局```window```对象中的变量```x```引用。这给出了一个从大对象到它不能回收的根节点（```window```）的完整的路径。我们发现了潜在泄漏及在哪里引用的。

到目前为止还不错。但是我们的例子很简单：像这个例子中的大块分配
内存不是规范。幸运的是我们的例子也泄漏DOM节点，是更小些的泄漏。用上面的快照很容易发现这些节点，但是在更大的站点内，事情会更复杂。Chrome的最近几个版本提供了一个最适合我们任务的额外的工具：记录堆分配功能。

## 记录堆分配来发现泄漏
废除你之前打的断点，让脚本继续跑，回到Chrome开发者工具的Profile部分。现在点“记录堆分配”。当工具在跑时，你将注意到顶上图表中的蓝色尖刺。这代表分配。每一秒钟我们的代码会进行一次大型分配。让他跑几秒钟，然后停下来（别忘了打断点来阻止Chrome吃掉更多内存）。

![css_layouts](/images/2017-memory-leaks/example-recordedallocs-overview.png)

这幅图中可以看到这个工具的特性：选择时间轴的一段，看看在那个时间区间分配了什么。我们设置选中的块尽可能的离其中一个尖刺近。在列表中只显示了3个构造函数：其中一个是和大型泄漏```(String)```有关联的，下一个是和DOM分配有关系的，最后一个是```Text```构造函数（DOM包含文字的叶子节点的构造函数）。从列表里面选择```HTMLDivElement```构造函数其中一个，然后切到```Allocation stack```。

![css_layouts](/images/2017-memory-leaks/example-recordedallocs-selected.png)

呀！我们现在知道那个元素在哪里被分配的了（```grow```->```createSomeNodes```）。如果我们注意下图表中的每个尖刺，会注意到```HTMLDivElement```构造器被调用了很多次。如果我们回到我们的快照对比图，我们会注意到这个构造函数显示了很多分配，但是没有删除。换言之，它在没有GC允许回收其中的一些的情况下，稳定的分配内存。这样，会有个我们清楚的了解的对象在哪里分配的（```createSomeNodes```函数），泄漏叠加的信号。现在是回到代码的时候了，学习下，然后堵掉泄漏。

## 另一个有用的特性

在堆分配结果图里面，我们可以选“分配”视图而不是“总览”视图。

![css_layouts](/images/2017-memory-leaks/example-recordedallocs-list.png)

这个视图提供了我们一个函数和与之相关的内存分配列表。我们可以立即看到```grow```和```createSomeNodes```脱颖而出。选中```grow```的时候，我们可以看到相关对象的构造函数被其调用。我们注意到，我们到目前为止已经知道的对象的构造函数有泄漏的```(String)```，```HTMLDivElement```和```Text```。
这些工具的结合对查找泄漏很有帮助。用起来。在生产环境的网站跑跑不同的分析（比较理想的是非压缩或混淆的代码）。看看是否可以找到泄漏或留存时间长过其应有时间的对象（提示：这个更难找）。
> 用这个特性到Dev Tools ->Settings and Enable里面记录堆分配栈踪迹。在记录之前做这个很有必要。

# 结论

内存泄漏可以并确实发生在像JavaScript这样的垃圾回收语言中。这可以被忽视一段时间，最终会肆虐开来。由于这个原因，内存分析工具对查找内存泄漏有必要。跑分析工具应该是开发流程中的一环，尤其针对中型或大型应用。开始做这个来给予你的用户可能最好的体验。跑起来！

原文：[https://auth0.com/blog/four-types-of-leaks-in-your-javascript-code-and-how-to-get-rid-of-them/](https://auth0.com/blog/four-types-of-leaks-in-your-javascript-code-and-how-to-get-rid-of-them/)

译者：[Linda](https://github.com/LindaWhite)

作者：[Sebastián Peyrott](https://twitter.com/speyrott?lang=en)

