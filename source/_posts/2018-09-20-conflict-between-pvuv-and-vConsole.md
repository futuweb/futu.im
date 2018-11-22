---
title: 记一次pvuv与vConsole在IE上的打架
subtitle: 这周在开发一个答题测评需求，只有一个页面，很开心地写完了，然后一顿自测，各种浏览器安卓端IOS端，然后IE又没有让人失望地报错了，整个页面出不来。
date: 2018-09-20 16:59:16
categories: [前端]
author: WendySun
---


## 背景

这周在开发一个答题测评需求，只有一个页面，很开心地写完了，然后一顿自测，各种浏览器安卓端IOS端，然后IE又没有让人失望地报错了，整个页面出不来。先看下这个小婊砸：

<!-- more -->

![pwd](/images/2018-09-20-conflict-between-pvuv-and-vConsole/1.png)

看了下报错，这个`ua-parser.js`是什么，点进去再打个断点调试下，发现是将一个函数当成字符串去调用`toLowerCase`方法。函数是没有toLowerCase方法呀，难道冤枉IE了。

![pwd](/images/2018-09-20-conflict-between-pvuv-and-vConsole/2.png)

## 根因

看下调用堆栈，这个`str1`看样子应该是个字符串，怎么会出来一个函数咧，然后发现调用的地方是用for in来循环的，这个入参是个字符串数组，没毛病，但是此时的j很奇怪，值是`__symbol_iterator_key`，按道理应该只是0或者1，不过因为是for in留了个心眼，考虑是不是原型上的属性，把`map[i]`再点开来，果然看到一个叫这个名字的家伙。

![pwd](/images/2018-09-20-conflict-between-pvuv-and-vConsole/3.png)
![pwd](/images/2018-09-20-conflict-between-pvuv-and-vConsole/4.png)

元凶找到了，再就是找下这个是怎么来的，为什么亲爱的谷歌没有呢？

## 排查

不死心还是要怀疑IE，难道IE上的数组原型自带的？还可以被枚举出来？在控制台打了下`Array.prototype`看下，发现是自己想太多，回到谷歌同样的地方打断点看下，发现并没有`__symbol_iterator_key`这个属性，所以谷歌没有问题。

回到`ua-parser.js`，发现这个是页面上报组件`tool-pvuv`中引用的用于判断当前浏览器、操作系统、设备的库`user-agent-parser`，`tool-pvuv`中当前用的是0.6.0版本的。再看下调式过程中看到的这个数组的来历，发现就是简简单单写的一个数组常量，太没毛病了。

![pwd](/images/2018-09-20-conflict-between-pvuv-and-vConsole/5.png)

数据来源没问题，那就是页面其他js给数组原型加了`__symbol_iterator_key`这个属性，导致后面创建的数组都带有这个东西。看了下页面引用的库，嗯。。有点多，有的还是复制其他页面引用的公共库，不知道干啥的，咳咳，尴尬，确实给自己埋下了不少坑，填坑路漫漫~~

不过既然是页面加载的时候加上去的，全局搜下应该可以搜到吧，简单粗暴在整个工程中搜了一把`__symbol_iterator_key`，还真的找到了，看来这个才是元凶！！！

![pwd](/images/2018-09-20-conflict-between-pvuv-and-vConsole/6.png)

看了下是公共代码`commonMain.js`中打包了`vConsole`的代码，一坨压缩后的实在难看，然后又跑来IE上调试，==，还是谷歌吧，顺便吐槽IE这个调试，期间各种不响应问我要不要重启。。。回到正题，看下图所有疑问都有了答案，感觉一阵神清气爽，正是判断了这个`Symbol`有没有定义，导至出现谷歌与IE的区别，IE没有Symbol的实现，所以IE上面的数组原型就有了那个函数，看样子应该是提供了数组的`Iterator` 接口。

![pwd](/images/2018-09-20-conflict-between-pvuv-and-vConsole/7.png)

## 谁的锅

看问题导致的原因是`vConsole`里面的一段代码提供了在IE上的数组`Iterator`接口，所以才会出现IE上的报错，但是这个问题最应该改的应该还是`ua-parser.js`里面写的那个for in，而且for in中还没有判断是否是自有属性，这样一不小心就不知道遍历到哪里去了，上github上看了下最新的代码，果然已经修改成了最原始可靠的for循环，这样只需要更新下`pvuv`中引用的`user-agent-parser`就可以啦，已经知会pvuv的维护童鞋~~~