---
title: 【译】澄清对AMP的十个误解
subtitle: AMP 是一套开源的 web 组件格式和类库。
cover: /images/2017-08-23-misconceptions-about-amp/2.png
date: 2017-08-23 10:30
categories: [前端]
tags: [AMP]
author: TooBug
---

## 1. AMP是一个新的渲染引擎/编程语言

AMP 是一套开源的 web 组件格式和类库。与其它类库或者框架相比，AMP 最大的区别在于，它采用了白名单策略，来约定你可以做什么。

为什么要限制一些东西的使用呢？这是因为一些看起来很无辜的小代码很容易拖慢网站的性能。而且一段时间后回来排查这些性能问题会是一件非常困难的事情。这就像你在德国的 Autobahn 快速路上开车，却只在右道行走，不知道最左边的道路才是更快的。AMP 就是这样一种技术，强迫你走到最左边的快速道路，并且保证你前方的道路是没有障碍的。

AMP 带来的并不只有限制，它还提供了很多的自定义标签，这些标签都有各自内置的功能。当你使用这些自定义标签，并遵守一些其它的规则，那么 AMP 将通过一些手段保证你的网站速度是非常快的。这些手段主要包括强制静态布局、高效率资源加载和一些其它的优化。

AMP 有一份文档，规定了什么样的标签是兼容的，什么样的标签是不兼容的。它还发布了一个内置的验证工具，可以让你看到当前页面的是否符合 AMP 文档的要求。需要强调的是，从技术上来说，即使不遵守所有的规定，AMP 页面也能运行得很好，只是你的页面无法通过 AMP 验证（从性能上来说，不遵守 AMP 规定到一定程度的时候，AMP做的性能改进也会全部失效，另外如果有一些东西是要求与 AMP 页面协作的，那么你的页面可能无法正常显示 ）。但同时，这也意味着 AMP 所强调的一些特性全部没有了。

<!-- more -->

### 还有更多解释吗？

真的没有了。AMP 只是一套 web 组件生态系统而已。但是，因为可以很容易通过编程的方式来确定一个页面是合法的 AMP，就可以做更多炫酷的事情了。比如：

- 合法的 AMP 可以使用免费、高速的缓存（例如[Google AMP Cache](https://developers.google.com/amp/cache/)）
- 基本可以确认合法的 AMP 页面速度很快，且对用户友好
- AMP 页面是“自包含”（self-contained）的（译注：指页面是完整、独立的），所以可以被嵌入第三方平台

这也允许第三方平台做一些很炫酷的事情：

- 出现在 Google 搜索的 Top Stories 轮播上
- 从 Pinterest 上链接到 AMP 页面
- 在 PWA 中使用 AMP 页面

## 2. AMP是Google的项目

AMP 最早是由出版行业和 Google 在2015年提出来的（当然，一些促使 AMP 诞生的体验问题，比如移动端 web 页面加载慢等，属于明显的行业内共性问题）。从一开始，它就是由出版行业、广告行业、技术提供者和平台提供方一起携手开发的，除了 Google 以外，参与者还包括 Twitter、Linkedin 和 Pinterest 。AMP 从提出来的第一天起就是一个通过 Github 进行开放协作的开源项目。到现在为止，AMP 接受了来自超过 200 名贡献者的 Pull Request，这些贡献者绝大部分不是 Google 的员工。

Google 确实有一支团队在全职为 AMP 项目工作，AMP 项目的大部分贡献也来自这个团队，但这个团队也是通过和其它人一样的[Intent to implement](https://github.com/ampproject/amphtml/blob/master/CONTRIBUTING.md#contributing-features)流程来工作。Google 团队也会将它们的[周会纪要](https://github.com/ampproject/amphtml/issues?utf8=%E2%9C%93&q=label%3A%22Meeting%20Notes%22%20)以及其它的文档发布出来，尽量保证外部贡献者都可以参与进来。

> 10月17日更新：针对这一点，外界有一些疑问和评论。上面这两段话仍然有效，但是我补充一个更精简的结论：AMP 项目当前的核心贡献者都是 Google 员工，所以 AMP 可以称作是 Google 领导（Google-led）的项目。但是它是被当作一个独立的开源项目来看待的，我们正在邀请开发者和社区参与进来一起贡献，让他们也变成核心贡献者，使 AMP 项目更加独立。

## 3. AMP需要Chrome才能运行

绝对不是这样！AMP 是一个跨平台、跨浏览器的类库，支持所有流行的移动浏览器和桌面浏览器的[最新两个版本](https://www.ampproject.org/learn/browsers/):

![AMP可以运行的浏览器](/images/2017-08-23-misconceptions-about-amp/1.png)

## 4. AMP 限制了我的布局和设计

你肯定会被 AMP 能做的事情惊讶到。AMP 确实限制了一些标签和对性能影响很大的 CSS 属性的使用，但是整体来看，在为站点编写样式时，受到的[限制非常小](https://www.ampproject.org/docs/guides/responsive/style_pages)。想写一个疯狂的 5 层 flexbox 嵌套布局？那就写吧。想基于伪元素写一个疯狂的 UI ？也 OK。

下面是一个我写的[AMP发展计划页面](https://paulbakaus.com/tutorials/css/flexbox-freebie-auto-growing-list-for-amp-roadmap/)：

<iframe height='265' scrolling='no' title='Flexy Steppy List' src='//codepen.io/pbakaus/embed/ezOQYa/?height=265&theme-id=0&default-tab=result&embed-version=2' frameborder='no' allowtransparency='true' allowfullscreen='true' style='width: 100%;'>See the Pen <a href='https://codepen.io/pbakaus/pen/ezOQYa/'>Flexy Steppy List</a> by Paul Bakaus (<a href='https://codepen.io/pbakaus'>@pbakaus</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>

## 5. AMP只适合轻量级页面

有几分道理，但也有误导性。这主要取决于你如何理解“轻量”。严格来说，AMP 的目标是静态内容。但我们所说的静态内容同样可以包含具有艺术气息的动画、侧边栏、灯箱广告、手风琴导航、轮播等等。你可以查看[AMPByExample](https://ampbyexample.com/)中的一些[高级例子](https://ampbyexample.com/#advanced)。

## 6. AMP只适用于移动端

诚然，AMP（Accelerated Mobile Pages）中的“Mobile”无助于澄清这个问题，但是这个说法还是跟事实完全不符。

AMP 是一个非常强大的跨平台解决方案，它希望出版行业和开发者将工程资源从细碎的多平台兼容支持中解放出来，将焦点放到创建伟大的新产品特性上，而这些产品特性可以被任何设备上的所有用户轻易访问到。

AMP本身是在[响应式设计](https://www.ampproject.org/docs/guides/responsive_amp)的概念支持下被创造出来的。目前有与 AMP 集成的平台大部分是聚焦移动端的，但是在桌面端，你也可以从 AMP 中获取得很多好处。

想知道如何使用 AMP 来处理不同分辨率和不同设备的话，可以看我的另一篇文章[“AMP中的'mobile'”](https://paulbakaus.com/2016/07/01/about-that-mobile-in-accelerated-mobile-pages/)。

## 7. 我现有的网站上无法使用AMP

我们已经澄清过第 4 点，并没有什么特别的理由让你现在的网站无法使用 AMP，因为当你读完第一个问题后，就知道了 AMP 只是一个 web 组件类库而已。事实上，[AMP项目主页](https://www.ampproject.org/)就是完全使用的 AMP：

![AMP项目主页使用的AMP](/images/2017-08-23-misconceptions-about-amp/2.png)

当然，和其它类库一样，[AMP并不适合每一个人](https://paulbakaus.com/2016/02/26/life-after-amp/)。在动手前想一想在[AMP的强制限制](https://www.ampproject.org/learn/how-amp-works/)（同时也带来好处）下，你的网站是否能正常运行。如果答案是肯定的，那么就切换到 AMP 吧。有一个基本的原则，如果你的网站没有静态内容，并且页面并不是最深层次的页面（译注：原文 leaf pages，leaf 指树状结构中的叶子节点，对应到网站一般指最深层次的页面，例如文章页），例如入口页，也就是用户从搜索中点进来的页面，那么 AMP 可能不适合你。

## 8. 如果我自己做优化，那AMP就没什么用

AMP 的优化是“无脑优化”，即使你身边没有web开发大师，它也能帮助你。我们对将网站性能优化到极致这件事情感到自信和骄傲。事实上，因为 AMP 是一个通用库，它可能会漏掉一些针对你的网站特殊场景下的优化策略，这意味着你自己的手工优化工作很可能会带来更好的性能。

但到今天为止，浏览器和一些大的平台例如 Google 搜索，仍然没有办法来确认你的网站是非常快速且对用户友好的。所以如果你选择自己做优化工作，你可能能得到一个非常快的网站，但是没有办法让其它人确信。而 AMP 的验证使得它对于第三方平台非常有吸引力。

## 9. AMP只对出版发行行业有好处

没错，如果你将你的新闻站点变成 AMP，就有机会出现在 Google 的 Top Stories 轮播上，并且 Google 会在移动端[搜索结果](https://search.googleblog.com/2016/09/search-results-are-officially-ampd.html)中使用一个内联的查看器来加速 AMP 页面。但是[eBay也创建了AMP页面](http://www.ebaytechblog.com/2016/06/30/browse-ebay-with-style-and-speed/)（[示例](http://m.ebay.com/sch/amp/16GB-iPhone-5s-Smartphones/9355/bn_341667/i.html)），尽管它们并不是新闻网站。

![AMP可以运行的浏览器](/images/2017-08-23-misconceptions-about-amp/3.png)

为什么 eBay 要选择AMP？[它们自己是这么说的](http://www.ebaytechblog.com/2016/06/30/browse-ebay-with-style-and-speed/)：

> AMP 的好处之一在于，它是一套构建移动端 web 页面的最佳实践的集合。我们之前已经在遵守这些最佳实践中的一部分，但是这些不同的做法分散在各个团队中，而且每个团队都有自己的偏好。AMP 的出现让我们可以更好地整理加固这个最佳实践的清单，并将它们作为常规开发周期中的一部分。

## 10. 我得在AMP和PWA中做出选择

AMP 和 PWA 是互补的技术，它们的使用场景完全不一样。如果将它们结合在一起使用，你就能使用它们创建出我认为目前最完美的内容站点：

1. 用户发现了你的内容的链接，点进来了
2. 内容被瞬间加载完毕，并且看起来很舒服
3. 阅读完之后，用户被邀请阅读更多内容，或者邀请用户使用一个更好体验的版本，它们由快速导航、通知推送、离线支持等技术支持
4. 当用户接受了你的邀请后，他们将被引导到一个可以安装到桌面的版本，这个版本的使用体验就像 App 一样

听起来非常棒对吧？你需要做的只是下面这些（或许有稍许变化）：

- 最深层面的页面（有内容的页面，而不是概览页面）使用 AMP 发布，以获得瞬间加载的体验
- 当用户浏览你的内容的时候，在这些AMP页面中使用[<amp-install-serviceworker>](https://www.ampproject.org/docs/reference/extended/amp-install-serviceworker.html)初始化缓存和 PWA 应用外壳（PWA app shell）
- 当用户点击网站上的其它链接的时候（例如，在类似 App 的体验中，点击底部的按钮），[Service Worker](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API/Using_Service_Workers)接管请求，然后加载[PWA应用外壳](https://developers.google.com/web/updates/2015/11/app-shell?hl=en)
- 最后，已经加载好的PWA应用外壳可以将 AMP 作为数据源嵌入到页面，这将使得你只需要为相同内容创建一个后台（既可以作为单独的AMP浏览，也可以作为 PWA 的数据源）

如果同时谈到 AMP 和 PWA 的话，还有更多话题可以说，所以请期待在这个主题上的后续深度文章吧。

## 总结

现在你有答案了。针对 10 个误解，我们给了 10 个澄清的答案，希望能给你一个对 AMP 更大更清晰的印象，也让你想清楚 AMP 对你来说是否适合。还有问题吗？[联系我吧](https://twitter.com/pbakaus)！

原文链接<https://paulbakaus.com/2016/10/13/debunked-10-misconceptions-about-amp/>

作者：Paul Bakaus (@pbakaus)