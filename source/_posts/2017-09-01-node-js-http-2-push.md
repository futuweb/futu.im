---
title: 【译】Node.js之HTTP/2服务器推送
subtitle: Node.js v8.4+版本发布带来了体验版的HTTP/2
cover: /images/2017-09-01-node-js-http-2-push/1.png
date: 2017-09-01 20:00
categories: [Node.js]
tags: [HTTP/2,Nodejs,JavaScript,Server Push]
author: Jin
---

Node.js v8.4+版本发布带来了体验版的HTTP/2，你可以自己通过设置参数`--expose-http2`启动。

这篇文章，我将介绍HTTP/2最重要的一方面服务器推送并且创建一个小的Node.js程序案例来使用它。

## 关于HTTP/2
HTTP/2 的目的是通过支持完整的请求与响应复用来减少延迟，通过有效压缩 HTTP 标头字段将协议开销降至最低，同时增加对请求优先级和服务器推送的支持。

更多关于HTTP/2内容，请查看文章[HTTP/2](https://developers.google.com/web/fundamentals/performance/http2/)。

<!-- more -->

## 服务器推送
HTTP/2 服务器推送（Server Push）允许服务器在浏览器请求之前将资源发送到浏览器。

> 在我们转到HTTP/2之前，我们来看看它如何与HTTP/1配合使用：

在HTTP/1中，客户端向服务器发送一个请求，服务器返回一个包含许多外部资源（.js，.css等文件）链接的HTML文件。当浏览器处理这个初始HTML文件时，它开始解析这些链接，并分别加载它们。

查看下面的demo加载过程的图像。 请注意时间表上的独立请求以及这些请求的启动：

![http/1](/images/2017-09-01-node-js-http-2-push/1.png)

*HTTP/1资源加载*

这是HTTP/1的工作原理，这就是我们如何开发这么多年的应用程序。**为什么要改变它呢？**


当前方法的问题是用户必须等待浏览器解析响应，发现链接并获取资源。 这会延迟渲染并增加加载时间。 有一些解决方案，如内联一些资源，但也使得初始响应越来越大。

> 这是HTTP/2服务器推送功能进入视线的地方，因为服务器可以在浏览器请求之前将资源发送到浏览器。

看看下面的图片，通过HTTP/2提供相同服务的网站。查看时间轴和启动器。 你可以看到HTTP/2复用减少了请求数量，并且资源与初始请求一起立即发送。

![http/2](/images/2017-09-01-node-js-http-2-push/2.png)

*HTTP/2服务器推送*

让我们看看今天如何在Node.js中使用HTTP/2服务器推送，来加快客户端的加载时间。

## 一个Node.js HTTP/2服务器推送案例
通过加载内置的`http2`模块，我们可以创建我们的服务器，就像我们使用`https`模块一样。

有趣的部分是在请求`index.html`时推送其他资源：

```js
const http2 = require('http2')  
const server = http2.createSecureServer(  
  { cert, key },
  onRequest
)

function push (stream, filePath) {  
  const { file, headers } = getFile(filePath)
  const pushHeaders = { [HTTP2_HEADER_PATH]: filePath }

  stream.pushStream(pushHeaders, (pushStream) => {
    pushStream.respondWithFD(file, headers)
  })
}

function onRequest (req, res) {  
  // Push files with index.html
  if (reqPath === '/index.html') {
    push(res.stream, 'bundle1.js')
    push(res.stream, 'bundle2.js')
  }

  // Serve file
  res.stream.respondWithFD(file.fileDescriptor, file.headers)
}
```

这样`bundle1.js`和`bundle2.js`资源即使在它要求它们之前也会被发送到浏览器。

你可以查看完整的案例：[https://github.com/RisingStack/http2-push-example](https://github.com/RisingStack/http2-push-example)

## HTTP/2 & Node

> HTTP/2可以帮助我们在很多方面优化我们的客户端与服务器之间的通信。

通过服务器推送，我们可以将资源发送到浏览器，减少用户的初始加载时间。

原文：[https://blog.risingstack.com/node-js-http-2-push/](https://blog.risingstack.com/node-js-http-2-push/)

译者：[Jin](https://github.com/Yi-love)

作者：[Péter Márton](https://twitter.com/slashdotpeter)