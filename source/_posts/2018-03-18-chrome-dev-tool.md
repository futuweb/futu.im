---
title: 【译】使用chrome dev tool的代码覆盖率功能
date: 2018-03-28 15:00
category: 翻译
tags: [chrome tools]
author: Linda
---

代码覆盖率功能最终完成了实验，列入了[Chrome Canary](https://www.google.com/chrome/browser/canary.html)，意味着它很快会变成普遍可用的。这是一个与javascript css一起工作时很有用的，令人兴奋的特性，我想我可以演示一个快速的例子来解释它是如何有用的。
更新：代码覆盖率的特性正在登录标准Chrome。如果你更新到了最近的版本，就不用Canary了！

<!-- more -->

## 它是做什么的？
代码覆盖率使得运行web app的时候，对于每个Js/Css文件，都可以看到哪行代码运行了，哪行没有运行。
![运行覆盖](https://futu.im//images/chrome-dev-tool/1.png)
这里，我运行一个简单的静态页面--然后Chrome生成了这个CSS\JS断点文件。右面的工具栏展示了每个文件的相对尺寸，红色部分显示了没有用的代码，绿色显示了运行了了的代码。
记录代码覆盖率的工作与开发工具的timeline的方法是类似的-打个点，然后会正常的作用到网站上。记录完成后，Chrome会做一些计算，然后生成结果。这里，我很好奇网站有多少没有用到的css，我导航到了各类的子页面以确认我击中了所有的css"代码路径"。足够确定--这里有很大的提升空间，因为我网站的97%的css代码都没有用到!
![运行覆盖](https://futu.im//images/chrome-dev-tool/2.png)
Chrome也允许你钻研一个单独文件的代码覆盖率。这里，左边红色/绿色的指示条显示哪行具体的代码运行了，哪行没有运行。记录下当观察压缩的文件时，可以按下左下的按钮，来“美化”代码。
## 为什么它有用？
当在做一个很复杂的或者长期的项目时，很容易堆积死代码。如果使用webpack或其他JS编译系统，有工具可以阻止大部分死代码流入生产环境。但是对于CSS，这样做有一点欺骗成分。在Chrome里面用这个覆盖工具是一个可以快速浏览在运送多少额外代码，哪些文件要优化。
## 怎么获取？
下载[Chrome Canary](https://www.google.com/chrome/browser/canary.html)或者等几个星期，等普通Chrome支持它。
很难保证前端dev是最新的版本。加入我们的每周的邮件列表来了解新的工具，库和最佳实践，可以帮助你构建更好的应用。
# 插件：LogRocket,web应用的DVR
![logrocket](https://futu.im//images/chrome-dev-tool/3.png)
LogRocket是一个前端的日志工具，可以帮助重现问题，就像他们在你自己的浏览器里面出现一样。而不是去猜测错误发生的原因，或者向用户索要屏幕快照或者日志下载，LogRecket可以重现会话来快速定位哪里出错了。它在任何应用上都可以完美的运行，不管什么框架，也有插件可以记录来自Redux，Vuex 和@ngrx/store额外上下文。
另外，为了记录Redux行为和状态，LogRocket记录了console日志，Javascript报错，stacktrace，带有头信息和内容的网络请求/响应，浏览器meta数据，和客户日志。也可以让DOM提交记录页面上的HTML和CSS，重建最复杂的单页面应用像素级完美录像。


很难保证前端dev是最新的版本。加入我们的每周的邮件列表来了解新的工具，库和最佳实践，可以帮助你构建更好的应用。

译者：[Linda](https://github.com/Linda)

作者：[Ben Edlstein](https://blog.logrocket.com/@edelstein?source=post_header_lockup)
