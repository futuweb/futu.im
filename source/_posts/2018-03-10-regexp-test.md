---
title: 正则表达式RegExp.prototype.test方法使用不当笔记
subtitle: 遇到了`RegExp.prototype.test`方法使用不当的问题。
date: 2018-03-10 12:00
categories: [前端]
tags: [web前端,RegExp,regexp.test,javascript]
author: Jin
---

最近在做项目的时候，遇到了`RegExp.prototype.test`方法使用不当的问题。

场景是这样的，有一个输入框，我需要用正则表达式判断输入的字符串是不是以特定字符串打头的。例如：以`upload/`开头的。

代码大概就是这个样子：

```js
let txt = $('#input').val();
if ( /^upload\//img.test(txt) ){
    console.log('is ok');
}else{
    console.log('is not ok');
}
```

<!-- more -->

要是这样就好了，就不会有什么问题了。上面也说了，不一定都是以`upload/`开头，可能是其它的`aaa/bbb`开头也说不定。也就是说不能以字面量的形式使用了，必须改为构造函数的方式使用。

好吧，那就改成下面这样：

```js
let txt = $('#input').val();
let regExp = new RegExp('^upload/' , 'img');
if ( regExp.test(txt) ){
    console.log('is ok');
}else{
    console.log('is not ok');
}
```

## 问题出现
现在问题要出现了。因为我需要把上面的代码进行优化调整，打包成函数。最后改成了下面的样子：

```js
//全局公共变量
const PREFIX = 'upload';
const FOLDER_REGEXP = new RegExp('^' + PREFIX + '/' , 'img');
/**
 * [testUploadPrefix 判断是不是以PREFIX开头的文件夹]
 * @param  {[string]} folder [输入的文件夹目录]
 * @return {[boolean]}        [true | false]
 */
function testUploadPrefix(folder){
    return FOLDER_REGEXP.test(folder);
}
```

把需要匹配的字符串和正则表达式都移动到了函数体外，定义为全局变量。把判断逻辑封装成一个独立的函数。看似一切正常，不是吗。

后面通过案例测试了一遍：

![regexp.test](/images/2018-03-10-regexp-test/01.png)

函数正确执行看不出有问题啊。。。。。 可惜大错特错。

===================== 分割线 =====================

当再次执行多次的时候问题就出现了。

![regexp.test](/images/2018-03-10-regexp-test/02.png)

`testUploadPrefix('upload/test')`应该一直返回`true`才对，可是居然会返回`false`不可思议啊。

## 问题分析
那问题出在哪里了呢。很显然看似一切正常的`RegExp.prototype.test`方法肯定另有玄机。好吧，那只好去查看一番。

### RegExp.prototype.test 描述
当想要知道一个模式是否存在于一个字符串中时，就可以使用`test`方法，返回一个布尔值，存在返回`true`否则返回`false`。 `test()`和`exec()`一样，在相同的全局正则表达式实例上多次调用`test`方法将会越过之前的匹配。


上面的这两句话，可能前一句很好理解。匹配到了就返回`true`，否则返回`false`。 关键在后半句，什么是**全局正则表达式实例**？

全局正则表达式实例：就是设置了`g`参数的表达式。

例如：

```js
let regex = /^upload\//g;
new RegExp('^upload/', 'g');
```

上面的这两个案例就是设置了全局匹配。

### 当设置全局标志的正则使用test()
如果正则表达式设置了全局标志，`test()`的执行会改变正则表达式`lastIndex`属性。连续的执行`test`方法，后续的执行将会从 `lastIndex`处开始匹配字符串，(`exec()`同样改变正则本身的`lastIndex`属性值)。

-- 摘自《[RegExp](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/RegExp/test)》

结合自己写的代码，也就是说会改变`FOLDER_REGEXP`的起始匹配位置。来看看是不是真的。

![regexp.test](/images/2018-03-10-regexp-test/03.png)

果然，会改变下一次匹配的开始的起始位置。

## 问题解决
那既然问题都知道了，就可以找方法解决啦。

其实方法很简单，去掉`g`参数即可。

![regexp.test](/images/2018-03-10-regexp-test/04.png)













