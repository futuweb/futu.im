---
title: 处理 Crocodile(NodeJs 脚手架)内存泄露经验小结
subtitle: Crocodile 是基于 koa2，集成了常用中间件，适用于富途 web 项目的接入层框架。
date: 2017-08-11 10:00:00
categories: [Node.js]
tags: [Node.js]
author: Mark
---

## 背景

### Crocodile

Crocodile 是基于 koa2，集成了常用中间件，适用于富途 web 项目的接入层框架。

使用 NodeJs 编写的服务一般都是常驻进程的，我们常常会听到 NodeJs 项目有内存泄露的情况，Crocodile 1.0.0 版本在使用过程中也发生了内存泄露。

<!-- more -->

### 发现问题

Crocodile 初步完成，web 组已有两个项目开始基于它进行开发，其中由 [@timi](/author/Timi/) 负责的项目提供了一个接口会被前端每秒钟轮询请求，这在开发阶段就带来了较大的请求量，也让项目内存泄露的问题很快暴露出来。

**项目在连续运行短短两天时间，内存占用已经增长到 1.8G，而且还在持续增长中**

![内存泄露](/images/2017-08-11-experience-of-handling-memory-leak-in-nodejs-project/1.png)


### 基础知识

>Node.js 进程的内存管理，都是有 V8 自动处理的，包括内存分配和释放。那么 V8 什么时候会将内存释放呢？

>在 V8 内部，会为程序中的所有变量构建一个图，来表示变量间的关联关系，当变量从根节点无法触达时，就意味着这个变量不会再被使用了，就是可以回收的了。
而这个回收是一个过程性的，从快速 GC 到 最后的 Full GC，是需要一段时间的。

### 处理过程

发现有内存泄露，我第一反应是有循环引用或者有持续增长的全局变量。

#### Review 业务代码

我们 review 业务代码后发现并没有上述两种情况，简单地在业务最后将几个变量置为 `null` 后观察发现内存增长放缓了，但是还是在稳步增长，并没有解决内存泄露。

#### 借助工具

Review 代码未果，我们决定使用 `heapdump`，dump 出一段时间内 Crocodile 项目进程的内存使用快照。
使用 chrome devtool 打开快照发现了 `context` 对象出现了循环引用，每次请求的 `context` 都没有被释放，一直占用内存：

![context对象循环引用](/images/2017-08-11-experience-of-handling-memory-leak-in-nodejs-project/2.png)

从内存快照中可以看到，`context` 对象被 `i18n`，`getRealIp`，`getHomeUrl` 这些对象或方法引用，而这些对象又被 `context` 所引用。Review Crocodile 代码发现，在 Crocodile 自定义中间件 BaseContext 和第三方中间件 `koa-i18n` 的定义都会导致循环引用。

**BaseContext**

![BaseContext](/images/2017-08-11-experience-of-handling-memory-leak-in-nodejs-project/3.png)

#### 解决问题

目前已将这两个中间件从 Crocodile 中移除，经过压测后发现内存泄露问题已解决，进程内存维持在一个稳定的值。

### 小结

在 koa 中间件中如果出现类似写法，都会造成循环引用而导致每次请求的 `context` 无法被释放：

```javascript
module.exports = () => {
    return async (context, next) => {
       context.attr = () => {
		   // do something
	   }
    };
};
```

在中间件中扩展 `context` 或者给 `context` 赋值一个方法都会出现循环引用，因为上面这种情况，`context` 将会持有该方法的引用，而该方法由于定义在中间件方法内部，虽然方法内部并没有使用 `context`，但该方法是可以使用 `context` 的，因此它持有 `context` 的引用，这样就形成循环引用了。

所以我们在编写 koa 中间件的时候一定要注意，扩展 `context` 时一定不能在中间件方法内部定义方法赋值给 `context` 的扩展属性！

