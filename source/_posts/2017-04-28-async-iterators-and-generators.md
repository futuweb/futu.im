---
title: 异步迭代器及生成器
date: 2017-04-28 10:30
category: 翻译
tags: [JS,技术]
author: Linda
---
Chrome,Edge,Safari都支持了流式获取，有点像这样：

    async function getResponseSize(url) {
      const response = await fetch(url);
      const reader = response.body.getReader();
      let total = 0;
    
      while (true) {
    	const {done, value} = await reader.read();
    	if (done) return total;
    	total += value.length;
      }
    }


多亏有了async函数，使得这段代码的可读性不错（如果不熟悉，这里有个[说明](https://developers.google.com/web/fundamentals/getting-started/primers/async-functions)）。但是，还是有点难以理解。

值得庆幸的是，异步迭代器很快会到来，可以使得代码看上去更整洁：
    
    async function getResponseSize(url) {
      const response = await fetch(url);
      let total = 0;
    
      for await (const chunk of response.body) {
    	total += chunk.length;
      }
      return total;
    }
异步迭代器在Chrome Canary里面可用，启动时需要加上标志位```--js-flags=--harmony-async-iteration```。下面就看下怎么运行的，可以怎么使流迭代起来。
<!-- more -->

## Async iterators
最普遍的问题就是当你学习一个新的预处理器或者一个新框架的时候都必须去学习新的语法。





原文：[https://www.smashingmagazine.com/2017/04/start-using-css-custom-properties/](https://www.smashingmagazine.com/2017/04/start-using-css-custom-properties/)

译者：[Linda](https://github.com/LindaWhite)

作者：[Serg Hospodarets](https://www.smashingmagazine.com/author/serghospodarets/)

