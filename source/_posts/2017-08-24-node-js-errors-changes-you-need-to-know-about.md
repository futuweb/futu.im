---
title: 【译】你需要知道的有关Node.js Error对象的变化
subtitle: 变化来自Node.js运行时抛出的错误。
date: 2017-08-24 20:00
categories: [Node.js]
tags: [Error,Nodejs,JavaScript]
author: Jin
---

### 概要
**变化来自Node.js运行时抛出的错误。**这些变化在Node.js V8+版本中开始生效，在后期的V9+版本中将继续存在。这将影响通过解析字符串消息判断错误的任何用户的代码。

### 什么和为什么？
**首先，为什么说这些变化是需要的，它们又是什么？**直到目前为止，Node.js抛出的大多数错误依然只有一个与它们相关的消息而已。如果你打算基于错误执行特定的操作，你只能通过将错误消息字符串与一个已知的字符串进行比较。结果可能是这样的：

![Error早期处理](/images/2017-08-24-node-js-errors-changes-you-need-to-know-about/1.png)

<!-- more -->

**像这样的代码从根本上来说是不应该经常出现的，因为在大多数情况下，当您从Node.js中获取错误时，您的代码可能只是简单地记录/显示错误消息，然后恢复到正常的代码流程。**然而，在需要的情况下，最终还是会依赖于特定的错误消息字符串。

现在你可能已经注意到，上面的例子中使用的消息判断中有一个错字。显然这也有可能发生在Node.js代码库中。**问题是当我们注意到打字错误并且想要在当前这个[语义化版本](http://semver.org/)修复它时。**这意味着更改将仅包含在下一个主要版本中，旧版本依然是错误的没有得到修改。在打字错误的情况下可能不是很大的事情，但是如果我们有一个错误或误导的信息，那么就需要多加注意了。

对消息字符串的严重依赖也对国际化构成了挑战。Node.js通过添加ICU和API来使应用程序代码来支持国际化，并取得了良好的进展。假如或者当我们想让Node.js返回的错误消息时是支持国际化的，我们需要保证能在不使用消息比较的情况下识别特定的错误。这是必须的，因为一旦本地化，消息本身就会根据用户设置的区域设置而改变。

**当前进行的更改是向Node.js API抛出的所有错误（Error）对象添加`code`属性。**这些代码在API文档中可以找到[https://nodejs.org/dist/latest/docs/api/errors.html#errors_node_js_error_codes](https://nodejs.org/dist/latest/docs/api/errors.html#errors_node_js_error_codes)（如果您为`master`分支生成一份文档，您将看到一个更大的列表）。

通过重写上面的例子：

![Error处理](/images/2017-08-24-node-js-errors-changes-you-need-to-know-about/2.png)

结果是如果/当消息在将来更改时，示例代码将不会受到影响，因为错误代码逻辑保持不变。

随着`code`属性的添加，错误的名称也被设置为包括错误代码`code`。 例如，对于常见错误：

* Error [error-code]
* TypeError [error-code]
* RangeError [error-code]

结果是使用`toString()`输出的错误将是以下格式：

* Error [error-code]: 消息
* TypeError [error-code]: 消息
* RangeError [error-code]: 消息

一旦上述的错误对象落地，是完全有时间更新消息字符串，而不必将更改标记为一个语义化版本。当我们准备好这样做时，还是存在一些争议的地方。如果您想了解讨论的详细内容，请查看此问题：[https://github.com/nodejs/node/issues/13937](https://github.com/nodejs/node/issues/13937)。

### 你需要做什么

* 对于代码库，您需要根据错误的消息字符串查找实例。
* 在不是绝对必要的情况下，删除依赖于消息字符串内容的实例。
* 添加错误代码后，更新代码库以使用错误代码而不是消息。 在需要支持多个版本的Node.js的情况下，您可以执行以下操作：

![Error兼容处理](/images/2017-08-24-node-js-errors-changes-you-need-to-know-about/3.png)

初始检查以查看错误`code`属性是否存在是确保我们只接受该消息的匹配，如果错误对象上没有`code`属性。 这样可以避免在可能具有相同消息的不同错误上进行匹配的任何可能性。

### 贡献仍然需要
虽然进行转换取得了很大进展（非常感谢那些已经加紧进行转换的人），但仍有工作要做。

James Snell创建的这个问题正在涵盖转型为新方法的进展：[https://github.com/nodejs/node/issues/11273](https://github.com/nodejs/node/issues/11273)。他也一起介绍了如何开始转换那个问题中列出的Node.js文件。我已经使用该指南进行了一些转换，这是一个很好的起点。

开始要找到一个尚未转换的文件（或多个），并且没有出现在PR(Pull Request)列表里面的。您可以通过首先验证在列表里的PR或者[https://github.com/nodejs/node/issues/11273](https://github.com/nodejs/node/issues/11273)中的文件的的评论。我还建议快速扫描开放的Node.js问题，看看是否有最近的PR覆盖您选择的文件，因为主要问题并不总是最新的。一旦您打开PR，必须用上面的`11273`问题链接进行评论，以便我们可以更新主列表。

PR更新错误消息之间往往会发生冲突，因此准备重新提交您的提交（甚至可能不止一次）但目前有一些合作者正在积极努力让他们及时审查/合并。

### 总结
更改来自Node.js运行时抛出的错误。 **我概述了是什么，为什么，并提出了一些建议，你应该做什么，现在准备好。** 我也希望你们中的一些能够帮助完成转换，我期待着在GitHub中见到你。

原文：[https://medium.com/the-node-js-collection/node-js-errors-changes-you-need-to-know-about-dc8c82417f65](https://medium.com/the-node-js-collection/node-js-errors-changes-you-need-to-know-about-dc8c82417f65)

译者：[Jin](https://github.com/Yi-love)

作者：[Michael Dawson](https://twitter.com/mhdawson1)