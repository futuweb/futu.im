---
title: 记一次企业微信webview bug排查
date: 2018-07-24 10:40
categories: [前端]
author: TooBug
---

## 背景

咱们在企业微信上开发了一个简单的选课系统，用于让公司内的同学在企业微信上进行选课。昨天下午HR的同学很开心地推送了8月份的课程列表，让大家报名。然后就炸锅了：企业微信中点击课程没反应，报不了名！


收到消息第一时间感觉确认了一下问题，发现Mac下使用完全没有任何问题。于是打听了一下，出问题的都是Windows电脑的企业微信。直接使用Chrome浏览器访问或者在手机企业微信上访问都是没有问题的。

那就简单啦，赶紧引导大家在浏览器或者手机企业微信上访问。问题解决！顺便感慨一下：狡兔三窟真重要啊，还好我们及早打通了OA登录，在各种环境下都可以登录使用。

当然，夜深人静的时候，作为一名靠谱的前端工程师，还是要老老实实查问题的。于是诞生此文，流水账，记录bug排查的全程并揭秘原因。

<!-- more -->

## TLDR

> Too Long, Didn't Read
>
> 太长了，不想读

好的，说重点：

1. Windows企业微信某个版本的webview有bug，导致`'ontouchstart' in windows`为true，事实上它并不支持触控事件。
2. 这会导致第三方库`iscroll`产生误差，认为这是一个触控设置，从而错误地将`disableMouse`设为`true`，进而忽略`mousedown/mouseup`事件，导致内部不向外发出`click`事件。
3. 最终导致外层绑定的`click`事件处理函数不触发，点击无效。

## 排查过程

### 重现

首先，想办法重现。

打开虚拟机，下载企业微信，登录、开应用，一顿操作猛如虎，然后……没发现问题。

重现失败。

接下来找反馈方。您的系统是什么版本？您的企业微信是什么版本？您是什么网络？得知是旧版企业微信。于是赶紧让组里小伙伴确认一下，是不是有问题的升级一下就没有问题了。

是。

锁定问题范围：旧版本Windows企业微信下页面出现点击无效。

虚拟机下载了一个旧版本企业微信，覆盖安装，再次登录、开应用，一顿操作猛如虎，然后果然看到了问题所在。

接下来，想办法在开发环境重现问题。开启本机环境，配置hosts访问本机，问题依旧，重现成功。

### 确认问题

再接下来，确认问题来源。

因为企业微信没有调试工具或者调试接口，只能先引入`vconsole`模块，确保日志能被看到。

```sh
npm install vconsole
```

```javascript
var VConsole = require('vconsole');
new VConsole();
```

展示一下项目的Vue代码：

```vue
<template>
    <div class="content">
        <div class="listWrapper" ref="wrapper">
            <ul>
                <li v-for="course in courseList" @click="chooseCourse">{{course.name}}</li>
            </ul>
        </div>
    </div>
</template>

<script>
import IScroll from 'iscroll';

export default {
    created(){
        this.scroll = new IScroll(this.$refs.wrapper, {
            click: true,
            tap: true,
            wheel: true,
            mouseWheel: true,
        })
    },
    methods:{
        chooseCourse(){

        }
    }
}
</script>
```

核心逻辑是，`.listWrapper`部分会被`iscroll`模块处理，以便能够方便地使用无限滚动、滚动加载等功能。

于是将`@click`分别绑定到`.listWrapper`内部和外部，发现外部的点击可以响应，内部的点击无法响应。

问题被进一步缩小范围：`iscroll`导致的元素点击事件不触发。

接下来就想到将代码中初始化过的`iscroll`实例对象的`options`属性打印出来进行对比，看看是否初始化的时候环境检测结果有些不一样。果然发现了一点区别：

没有问题的浏览器上：

```
disableMouse: true
disablePointer: false
disableTouch: true
```

有问题的浏览器上：

```
disableMouse: true
disablePointer: true
disableTouch: false
```

可以看到`disablePointer`和`disableTouch`的值是不一样的。开始翻看`iscroll`的源码<https://github.com/cubiq/iscroll/blob/master/build/iscroll.js>，发现它的基本逻辑：

构造函数`IScroll()`从第317行开始，首先处理了选项的合并。

第331行有三个关键的选项：

```javascript
disablePointer : !utils.hasPointer,
disableTouch : utils.hasPointer || !utils.hasTouch,
disableMouse : utils.hasPointer || utils.hasTouch,
```

于是，往回翻，找到`utils`中这几个东东的定义：

```javascript
hasTouch: 'ontouchstart' in window,
hasPointer: !!(window.PointerEvent || window.MSPointerEvent), // IE10 is prefixed
```

因此`hasTouch`和`hasPointer`的值不同会导致上述选项`disableTouch`和`disableMouse`的不同。再接下来就简单了，将这两个值分别打印出来，很快就能发现，正是旧版企业微信的`hasTouch`判断失误，导致了后续`disableMouse`为`true`，导致鼠标事件相关处理函数没有被调用。

### 修复

超级简单，只需要在调用的时候传入`disableMouse:false`即可。

```javascript
this.scroll = new IScroll(this.$refs.wrapper, {
    disableMouse: false,
    click: true,
    tap: true,
    wheel: true,
    mouseWheel: true,
})
```

### 复盘

问题解决了，自然要回想一下，是什么导致了这个问题，我还能做点什么。

导致问题的直接原因是：企业微信的webview有一个bug，明明不支持触控，但是在`'ontouchstart' in window`时却返回了`true`。又因为新版本的企业微信已经没有了这个问题，所以要反馈给企业微信也是一件无意义的事情了。

另一个有一些关系的原因是：引入了一些没有把握的第三方库。事实上我们对于第三方库的引入一直非常谨慎，但这个系统因为早期并不是一个正式的项目，因此有些随意了。

再接下来就是记录一下这整个过程，整理成本文，虽然并不知道对其他人是否有一些思路上的借鉴意义。

值得一提的是，在修复的过程中，发现`iscroll`的源码早已不是我很多年前看的时候的样子了，整个模块划分非常清晰，所以代码读起来很容易。接下来有空的时候我应该会再仔细读一下它的代码，关于事件的检测、分发还是做得挺有意思的。

修复的过程让我想到了知乎上看过的一个问题：我去修电脑，别人只飞了一根线，却要了我100元，合理吗？下面有个回答：线值0.5元，知道怎么飞这根线值99.5元。

对工程师来说也一样，修复的过程只有一行代码，但找到这个方案的过程却并不容易。比如我，因为这个问题的出现，半夜11点半才下班。
