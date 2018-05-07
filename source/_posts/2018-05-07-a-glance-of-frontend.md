---
title: 大前端分享总结
date: 2018-05-07 17:49:51
tags: [JS]
categories: [前端]
author: Suny
---

本文是一篇分享记录，虽以大前端为题，内容并不局限于前端的范畴，确切的说，算是对当前js(ECMAScript)能力的概括。

<!--more-->

下图为本文主要结构，原始分享PPT可[点击此处查看](https://prezi.com/p/rs70y0ozmnnk/)

![](/images/2018-05-07-a-glance-of-frontend/1.png)

分享往往从历史故事开始。
1995年，javascript诞生；1998年左右，ajax得到应用；2006年，jQuery第一个版本面世；2009年，nodejs & angular.js；再后来，HTML5,CSS3...

最初，js被设计用于网页表单验证，随着互联网的发展，跑在浏览器上的页面承载了越来越多的功能，为了满足各种需求，js不得不不断的进化，变得越来越完善；不满于被浏览器所限制，Nodejs使得其脱离了浏览器的桎梏，从此蛟龙入海，大显神威。

## Web

Web应用采用B/S结构，寄生于浏览器中，有浏览器和服务器两个端，分别对应于前端和后端。

#### HTML5

作为浏览器中能够运行的唯一一种脚本语言，js当然显得有恃无恐。以浏览器提供的API(BOM,DOM)作为土壤，一个个js脚本文件辛勤地耕作着...

用户总是喜新厌旧的，每天对着千篇一律的页面，难免会失去兴致，所以，是时候加一点佐料了。

现代浏览器开放了许多先进的新特性，用于补充网页的能力，使得js可以操作更加接近底层的系统与硬件，如：

1. 用于本地存储数据的 localStorage,sessionStorage
2. 用于开启辅助线程的 Web Worker
3. 用于消息推送的 notification
4. 用于绘制图像的 canvas,WebGl

等等等...

#### Nodejs

对于只能运行在浏览器上这一点，js肯定是心有不甘的，就像一个叛逆的少年，离家出走的想法不止一次的出现在脑海里，终于有一天，远走，去了他乡。当然，离开意味着成长。

Nodejs是一种基于V8引擎的js运行环境，提供了许多模块。其中：fs模块，使得js拥有了操作文件的能力；http模块，使得js拥有了编写后端逻辑的能力...

Nodejs有如下特性：异步，事件驱动，非阻塞I/O
基于这些特性，产生了如下优点：高并发，适合I/O密集型应用
然而，Nodejs并不是银弹，也是有些缺点的，比如：不适合CPU密集型应用
目前，Nodejs主要应用于如下场景：Web应用接入层，RESTful API，前端构建

点此查看[Nodejs官方介绍](http://nodejs.cn/)

## Mobile

随着智能手机的普及，移动端应用几乎成为每个互联网产品的标配。移动应用可以分为如下三种类型：原生应用(native app)， 网页应用(web app)，混合应用(hybrid app)。

#### Hybird

混合应用是基于webview的，native的webview控件将native外壳与web内容组合起来,形成了混合模式的移动应用。此类应用平衡了native与web之间的优缺点，目前比较流行。

优点：跨平台、多种设备兼容、升级快速和维护方便
缺点：交互体验和性能都会比native app差一点
与native app之间的通讯：JSBridge,JSPatch

具体可参看[浅谈 Hybrid App](https://zhuanlan.zhihu.com/p/21387961)

#### Native

一份代码，同时编译成不同安装包(Android,Ios)，然后提交到对应的应用市场，供用户下载，安装和使用。

相关技术：NativeScript, React Native, Weex

#### PWA

作为下一代web应用模型，pwa旨在突破 web 平台本身对 web 应用固有的桎梏：客户端软件（即网页）需要下载所带来的网络延迟，与 Web 应用依赖浏览器作为入口所带来的体验问题。

相关技术背景：Web App Manifest, Service Worker, Push Notification。

可参看[下一代 Web 应用模型 — Progressive Web App](https://zhuanlan.zhihu.com/p/25167289)

## Desktop & OS

在桌面端，js的能力已经纵深到桌面应用甚至是桌面系统。

#### electron

Electron 是一个使用 JavaScript, HTML 和 CSS 构建跨平台的桌面应用的框架

目前 Electron 官网上已经列出了将近500个左右的应用，详细可查看[Electron官网应用](https://electronjs.org/apps)

#### chrome os

Chrome OS是一款Google开发的基于PC的操作系统。
[Chrome OS演示](https://www.bilibili.com/video/av279438/)

## Others

那么，js还能做些什么呢？？？
游戏：Unity5, cocos
插件：sketch, photoshop, greasemonkey
硬件：cylon
或许更多...
