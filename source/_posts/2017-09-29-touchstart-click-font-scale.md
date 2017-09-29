---
title: 记一次活动开发遇到的问题
date: 2017-09-29 20:00
category: [javascript，技术]
tags: [touchstart/click/禁止调整字体大小]
author: AlanZhang
---

## 写在最前

最近给公司做了个自适应的的费用介绍页，主要是关于收费标准的调整，老板表示很重视，适用人群也很多，所以也反馈得到几个不常遇到的问题，这里记录一下，不当之处，欢迎指正。

## 1.  touchstart 与 click

#### 问题背景

对于需要自适应的页面，为了在事件绑定时做到自适应，通过能力检测来判断当前可以绑定的事件类型。如果全部使用click，则回到移动端最原始的300ms延迟问题。

使用时，一直这么写：

```
var tap = 'ontouchstart' in window ? 'touchstart' : 'click';
wrap.addEvenListener(tap,function(){
    signUp();
});
```

对于大部分的浏览器都可适用，在此之前也没有接收到不可用的反馈，直到这次，有位重要客户反馈页面上的所有tab都无法点击，展开收起等效果均无法生效；我测试了多台设备，仍然无法重新问题。

<!-- more -->

#### 问题原因

如背景中提到的，问题最终定位在绑定的 "点击"事件上，只是能力检测浏览器环境支持的特性，但是忽略了用户操作的多样性，开发的时候对用户操作有太多的预期，归纳起来就是：

- 有些PC 设备屏幕 为触摸屏，同时支持touchstart和click事件；
- 用户触发touchstart事件，默认必然会导致触发click事件，但是触发click事件，不一定会导致touchstart事件被触发；
- 此类设备外接鼠标时，通过上面的绑定方式，会绑定touchstart事件，但是鼠标操作只能触发click，touchstart不会触发；

#### 解决办法

至此，问题的原因已经非常明确，关键在于确定不同设置上“点击”事件的类型。

总结起来，分为如下几种：

##### 1. 均使用click事件
**优点**： 自适应时，不同设备均支持，没有兼容性问题，开发成本低；

**缺点**： 移动端存在300ms的延迟问题（同事表示一般感觉不出来）


##### 2. 通过UA判断设备是否为移动端，再确认事件类型
    
```
function isMobile() {
    return navigator.userAgent.match(/(blackberry|configuration\/cldc|hp |hp-|htc |htc_|htc-|iemobile|kindle|midp|mmp|motorola|mobile|nokia|opera mini|opera |Googlebot-Mobile|YahooSeeker\/M1A1-R2D2|android|iphone|ipod|mobi|palm|palmos|pocket|portalmmm|ppc;|smartphone|sonyericsson|sqh|spv|symbian|treo|up.browser|up.link|vodafone|windows ce|xda |xda_)/i) ? true : false;
}
 var tap = isMobile() ? 'touchstart' : 'click';
```

**优点：** 自适应时，开发成本低，通过设备类型确定点击事件类型，能满足绝大部分问题，用户操作也比较符合预期；
**缺点：** 不能满足所有情况，用户给ipad设备（认定为移动设备），外接鼠标进行操作，这种方式就不起作用（PS：你非要这么做，我也无FUCK说）。

##### 3. 全部使用click，通过fastclick解决300毫秒的延迟问题

```
//引入fastclick
var FastClick = require('tool-fastclick');
//页面初始化时调用
new FastClick(document.body);
```

**优点：** 开发成本低也比较低，也不会出现1，2中问题 
**缺点**： 额外引入三方库，fastclick是否会有其他的坑？这点不能保证

> tool-fastclickfork至fastclick，对其中存在的问题进行了一部分修复，比如：同个页面有多个select框选择时，会跳选项的bug

##### 4. 完全之策：呵呵

## 2. webview字体放大导致页面布局混乱的问题

#### 问题背景

很多webview提供了调整页面字体大小的功能，以MobileQQ、WeiXin、Android内置浏览器为主；调整字体只会导致字体显示大小发生改变，但是其他元素的大小不受影响。对于页面机构稍微复杂一点的结构，会导致页面布局乱掉，主要表现为文版不居中，原本同一行的元素折行等。

![](https://i.imgur.com/mhsTxBa.png)

#### 问题原因

咨询了IOS和Android的同事，调整字体时，2个客户端的处理方式不同。

- IOS上通过给 body 设置 -webkit-text-size-adjust属性实现

    ![](https://i.imgur.com/qlUg3fJ.png)
 
- IOS上调整字体大小后body的操作

    ![](https://i.imgur.com/NZWgbb9.png)

- Android通过给webview 设置字体的缩放来完成

    ![](https://i.imgur.com/oG3YQav.png)
    ![](https://i.imgur.com/tGTIFnz.png)

#### 解决办法

- 针对IOS，调整字体大小本身只是改变html的css属性，因此可以通过覆盖样式来控制。
    
```
body {
    -webkit-text-size-adjust: 100% !important;
}
```
- 针对Android，由于是设置的webview容器本身的容器，因此无法通过前端来解决
- 在Android微信中，借助WeixinJSBridge 对象将webview的字体大小设置为默认大小。
```js
(function() {
    if (typeof WeixinJSBridge == "object" && typeof WeixinJSBridge.invoke == "function") {
        handleFontSize();
    } else {
        document.addEventListener("WeixinJSBridgeReady", handleFontSize, false);
    }
    function handleFontSize() {
        // 设置网页字体为默认大小
        WeixinJSBridge.invoke('setFontSizeCallback', { 'fontSize' : 0 });
        // 重写设置网页字体大小的事件
        WeixinJSBridge.on('menu:setfont', function() {
            WeixinJSBridge.invoke('setFontSizeCallback', { 'fontSize' : 0 });
        });
    }
 })();
```

#### 存在问题

- 对于微信客户端，禁止调整字体大小，只是调整无效，但是仍然存在调整字体大小的入口，这里的交互会达不到用户的预期。
- IOS中，可一劳永逸，通过样式直接覆盖即可。
- Android中，需webview提供接口通过jsbridge来重新设置webview的字体，目前只能在微信中实现。
- 很多Android设备如小米，荣耀的内置浏览器提供调整字体大小的功能，这种情况，没法处理。

#### AndroidQQ中解决方案

作为用户量庞大的APP之一，QQ也提供了禁止调整字体大小的方案，android qq中可以自定义webview显示的控件，通过在url中加入指定参数即可。见[如何定制手Q的Webview](http://wiki.open.qq.com/wiki/%E5%A6%82%E4%BD%95%E5%AE%9A%E5%88%B6%E6%89%8BQ%E7%9A%84Webview).

如：

 ![](https://i.imgur.com/zUyABtx.png)

理论上，<http://www.163.com/?_wv=128>访问这个链接，功能菜单中不会出现调整字体大小的按钮。

但是，但是，但是，所有的参数中，就只有【128隐藏字体项不生效】。已提交站点反馈，未收到回应。

（PS：心路历程：QQ上没提供jsbridge控制字体=心酸--->发现了这个解决方案=大喜--->实际测试无效=无语）。

#### 几种声音
对于这个问题，大概有怎么几种声音：

1. 微信，QQ等客户端既然提供调整字体的功能，必然是想用它来提供更好的体验，不应该禁用。
2. 字体缩放之后，页面会乱掉，根本原因在于页面的适应性不够，应该从代码层面去优化，而不是从容器的角度去做处理。
3. 既然用户选择用大字体来浏览页面，就应该承担页面布局乱掉的结果。

**个人观点：**

- 放大字体功能，对于文本内容占比多的页面很适用，用户根据自己设备尺寸或者视力可以调整到舒服的字体大小；但是对于重布局的页面，整个页面的表现很可能乱掉。开发时根据页面内容的类型来决定是否禁止即可。
- 如果从代码层面去做适应，仍然需要考虑页面布局的复杂度，例如：如果设计上某一行就是要放置4个按钮，放大字体后，按钮可能还在一行，但是文本很可能就出现折行、不居中。如果从代码层面上去完美解决这个问题，还需要设计上留出足够的空间，字体的缩放是从50%-200%（或者其他范围），同时还需要考虑设计上无法留出足够空间的情况...这种开发方式成本太大。
- 作为开发者，我内心是倾向于第3种声音的，但是从产品的角度考虑，这个锅不能丢给用户。但是有限时间中，只能从大部分人的都觉得ok的视觉体验为标准来展开开发，时间充足的情况再另做考虑（这可能吗？），这也许是产品、设计、开发、老板都比较能接受的结果，可以类比国内大部分网站在无障碍浏览上的工作量。

## 参考资料

- [如何定制手Q的Webview](http://wiki.open.qq.com/wiki/%E5%A6%82%E4%BD%95%E5%AE%9A%E5%88%B6%E6%89%8BQ%E7%9A%84Webview)
- [微信sdk](http://qydev.weixin.qq.com/wiki/index.php?title=%E5%BE%AE%E4%BF%A1JS-SDK%E6%8E%A5%E5%8F%A3#.E9.99.84.E5.BD.953-.E6.89.80.E6.9C.89JS.E6.8E.A5.E5.8F.A3.E5.88.97.E8.A1.A8)
- [禁用微信 webview 调整字体大小](https://zhuanlan.zhihu.com/p/21574121)\

## 最后

有人可能会对文章最前提到的收费介绍页比较感兴趣，来了，看[这里](https://www.futu5.com/about/commissionnew),富途港股佣金已经降至万分之3了，美股佣金0.0049美元/股，投资港美股正当时，赶紧[开个户，入点金](https://my.futu5.com/account/cashin#/)。

文章中可能加入了部分个人的观点，欢迎讨论。


