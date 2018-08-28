---
title: 移动端弹窗输入密码的那些事
date: 2018-08-28 15:30
categories: [前端]
author: Jin
---

该从何说起呢？我先理一理，东西有点多，怕把大家带沟里。那现在开门见山，先说一下是什么事吧。如题所说，其实就是在移动端浏览器的新股认购页面里面让用户输入交易密码。

不就是输入交易密码，心想看着很简单，做着也简单。

> 以下内容均已富途证券的新股认购模块为背景。

## 入坑前
很happy，果然和心里想的一样。新股认购上线没啥问题。视觉稿的输入交易密码大概就是下图的样子。新股认购的原稿找不到了，就找了一张bug单代替吧。很简单，只要校验输入的交易密码是否符合校验逻辑后提交，没有多余的操作。这样的设计其实前端要做的事并没有[多?]少。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_01.png)

> 旧版WEB输入交易密码

<!-- more -->

嗯，没错。今天说的就是我和上面那个不起眼的输入交易密码框的故事。

人生处处有惊喜。要是都是这么简单，那么也就没那么多事了。

## 入坑中
上线后没过多久。由于新股认购业务的发展需要，页面需要内嵌到App里面。心想应该也没问题，毕竟页面已经做了移动端适配的。

N天就这么过去了。突然有一天，负责App设计规范的同学找到了我。说新股认购页面的输入交易密码操作不符合App设计规范，需要进行修改。满脑子的？？？那我，当时就说啦，我这是按WEB这边的设计规范来做的啊。

先说说背景：是这样的，公司App和WEB都各有一套不同的设计规范，平时都不会有太多交集。但是一旦一个按WEB规范制作的页面内嵌到App里面，那就有问题了呀。因为根据WEB设计规范做出了的页面，内嵌到了App里面，就不一定符合App的设计规范。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_02.png)

> App 输入交易密码设计稿，可以看到和WEB完全不一样，这是原生App的输入框

好吧，这个规范设计交集让我踩到了。那怎么办呢，拉前端负责人，WEB设计负责人，App设计负责人，视觉负责人一起讨论呗。

吧唧吧唧吧唧吧唧吧唧吧唧吧唧吧唧吧唧吧唧吧唧吧唧吧唧吧唧吧唧！！

经过大家的讨论，最终决定修改WEB这边的规范，尝试使用弹窗输入交易密码，把WEB这边的输入交易密码改成和App的规范一致。也就是下面的弹窗输入交易密码的样子。

***交易密码是6位数字组合***

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_04.png)

> 新版-01 WEB输入交易密码

从上图可以看到，点击“立即认购”按钮，就会弹出输入交易密码的弹窗，然后点击弹窗进行输入（软键盘这个版本并没有自动拉起）。输入完成后，按右图的1，2步骤提交密码。


部分交易密码弹窗HTML：

```html
<div class="ui-dialog-body ui-form">
    <div class="ui-form-item" ng-class="{'ui-focus':focused}">
        <ul class="pwdList ui-form-text">
            <li ng-repeat="item in passwordList track by $index" ng-click="inputFocus()">
                <span ng-class="{'dot':item}"></span>
            </li>
        </ul>
    </div>
    <input type="text" name="txtPassword" ng-trim="false" ng-model="pwdValue" ng-change="updatePassword();" ng-focus="onFocus();" ng-blur="onBlur()" autocomplete="off" autocorrect="off" maxlength="6">
</div>
```

> 通过li展示交易密码输入的长度

原理就是把一个透明的`input`框放在`ul`上面，`ul`里面的`li`用来展示输入密码的长度。


上线没多久，有用户反馈不能提交交易密码。原因就是，ios在软键盘没有隐藏的情况下，点击"确认"提交按钮无效。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_06.png)

> 用户反馈，点击提交无效，这无解。。。求拯救

就这样，我成功入坑了。

上线第一版，总结上面的输入交易密码框在移动端存在的问题：

1. 不能自动拉起软键盘；
2. 软键盘没有隐藏时，无法正常提交交易密码问题；
3. 点击输入交易密码拉起的不是数字键盘；
4. 密码输入错误，没有重试机会，需要用户重新点击“立即认购”，弹出密码框。

## 挖坑中...
针对上面出现的问题，优先决定处理问题2和问题4。因为已经影响了正常业务流程体验。这样优化版就开始了。

为了解决问题2，大家（又是那一波人）讨论决定删除“取消”和“确认”按钮，改为自动提交（也就是当用户输入密码位数到达6位，即自动发起后端Ajax请求）。这样就可以保证不影响业务。对于问题4，提供二次弹窗输入交易密码，使得整个业务操作流程更加流畅。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_07.png)

> 新版-02 点击“立即认购”，弹出输入交易密码框，输入完后自动提交，提交完发现密码错误提示“重试”

优化后的版本，更加美观和高效了，最重要的是用户体验也爽了。没有"确认"按钮的交易密码弹窗HTML：

```html
<div class="ui-dialog-box passwordBox" ng-class="{'ui-show': isShowPwd}" ng-show="isShowPwd">
    <div class="ui-dialog ui-center">
        <div class="ui-dialog-header">
            <h3 class="ui-dialog-header-title">{{dtitle||'请输入富途交易密码'}}</h3>
        </div>
        <div class="ui-dialog-body ui-form">
            <div class="ui-form-item" ng-class="{'ui-focus':focused}">
                <ul class="pwdList ui-form-text">
                    <li ng-repeat="item in passwordList track by $index" ng-click="inputFocus()">
                        <span ng-class="{'dot':item}"></span>
                    </li>
                </ul>
            </div>
            <input type="text" name="txtPassword" ng-trim="false" ng-model="pwdValue" ng-change="updatePassword();" ng-focus="onFocus();" ng-blur="onBlur()" autocomplete="off" autocorrect="off" maxlength="6">
        </div>
        <i class="ui-icon ui-dialog-close icon-close" ng-click="closeClick()"></i>
    </div>
</div>
```

就这样，填了自己埋下的2个坑。同时，又给自己挖了2个坑。

没过多久，客服同学反馈过来说，Android用户点击“立即认购”按钮后，弹出交易密码框，点击输入交易密码时发现（这个时候，还没有做自动拉起软键盘），软键盘挡住了输入框。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_08.jpg)

> 点击输入交易密码，软键盘挡住了交易密码框，我的天呀。。。。

第二个问题是测试的时候，发现自动提交交易密码后，软键盘并没有自动隐藏。被测试同学提了bug。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_09.png)

> 呜呜呜呜呜呜呜呜，bug。移动端咋这么多破事。

刚解决2个问题，又来2个。

只能怪自己太想当然，得好好反省。总结一下，现在存在的问题：

1. 不能自动拉起软键盘；
2. android机交易密码框被软键盘挡住；
3. 点击输入交易密码拉起的不是数字键盘；
4. 自动提交代码后，软键盘没有自动隐藏。

好吧，还是四个问题。

## 填坑中...
再来排一次问题优先级，还是问题2和问题4需要优先处理。

### 问题2 android机交易密码框被软键盘挡住解决办法
我们都知道，当我们在页面输入数据的时候。一般软键盘拉起的时候，都会把对应的输入框往上移一段。保证输入框在页面的可视范围内。正常情况如下图左边图1，但是有的浏览器在弹出软键盘后，会挡住输入框，如下图右2。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_10.png)

> 左1正常，右2有问题 

解决的方法就是：

```css
.pwd-wrapper{
    position:fixed;//主要是这个
    top: 10px; //这个
    z-index:999;
}
```

弹窗原本就是`fixed`，通过设置弹窗的`top`属性，把交易密码弹窗放到页面的最上面。这样就避免弹窗被软键盘挡住。

可能你会觉得这样很不协调，弹窗没有上下居中。其实只有存在问题的浏览器才会不居中，但比起软键盘挡住了交易密码框，要好得多了。除此之外，正常的浏览器，尽管我上面写了`top:10px`看起来好像没有上下居中对齐，但是结果确实正常的上下居中对齐。

这让我相信了，一句话，没问题的怎么都没问题；有问题的，没问题那也是有问题。

好了，问题2就这样愉快的解决了。

### 问题4 软键盘没有自动隐藏
这个应该很好解决。也就是让输入框失去焦点就可以了。

```js
$('input[name="txtPassword"]').blur();
```

是不是这个问题很白吃呀。这么简单，那时候为什么没有加，我记得加了呀。

“明明就是隔壁那位在整理成弹窗密码组件时JavaScript事件没加对位置嘛。。。。”。>_> ，开玩笑的。

## 前端黑科技的降临
通过一顿猛如虎的操作，用户体验上升了不少有没有。笔芯。。。。

可以松一口气了。然后再来慢慢解决上面还剩下的2个问题。

1. 不能自动拉起软键盘；
2. 点击输入交易密码拉起的不是数字键盘。

想着，要不先优化拉起的不是数字键盘的问题吧。

### 解决输入交易密码没有拉起数字键盘问题
如果没有对`input`做特殊类型设置的话，一般都会根据用户的设置选择的语言来展示软键盘。

#### Input 设置type="text" 方案
一直以来都是使用的`type="text"`的输入框。所以点击弹窗拉起的软键盘是可以输入中文的，这显然和交易密码要求的数字不符合。

默认弹窗输入部分代码：

```html
 <div class="ui-dialog-body ui-form">
    <div class="noticeInfo">{{notice}}</div>
    <div class="ui-form-item" ng-class="{'ui-focus':focused}">
        <ul class="pwdList ui-form-text">
            <li ng-repeat="item in passwordList track by $index" ng-click="inputFocus()">
                <span ng-class="{'dot':item}"></span>
            </li>
        </ul>
    </div>
    <input type="text" name="txtPassword" ng-trim="false" ng-model="pwdValue" ng-change="updatePassword();" ng-focus="onFocus();" ng-blur="onBlur()" autocomplete="off" autocorrect="off" maxlength="6">
</div>
```

在`type="text"`的基础上，通过添加`pattern="[0-9]*"`，发现ios可以正常拉起了数字键盘，android上也不是中文输入法。

***开心，这个方案可以接受。***

代码修改如下：

```html
<input type="text" pattern="[0-9]*" name="txtPassword" ng-trim="false" ng-model="pwdValue" ng-change="updatePassword();" ng-focus="onFocus();" ng-blur="onBlur()" autocomplete="off" autocorrect="off" maxlength="6">
```

只需要做一点小改动，软键盘的展示已经符合了预期。对比如下图所示。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_11.png)

> 左图为默认type="text" , 右图为type="text" pattern="[0-9]*"

尝试使用`type="number"` 和`type="password"`。发现效果并没有上面使用`<input type="text" pattern="[0-9]*">` 的效果好。

测试代码如下：
```html
<!-- type = number -->
<input type="number" name="txtPassword" ng-trim="false" ng-model="pwdValue" ng-change="updatePassword();" ng-focus="onFocus();" ng-blur="onBlur()" autocomplete="off" autocorrect="off" maxlength="6">
<!-- type= password -->
<input type="password" name="txtPassword" ng-trim="false" ng-model="pwdValue" ng-change="updatePassword();" ng-focus="onFocus();" ng-blur="onBlur()" autocomplete="off" autocorrect="off" maxlength="6">
```

可以看到`type="number"`弹出的是数字键盘；但不是9宫格的，`type="password"`弹出的是字母，就更不用说了，效果一般。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_12.png)

> 左图为默认type="number" , 右图为type="password"

最后，经过对比，决定使用`<input type="text" pattern="[0-9]*">` 格式。起码ios拉起的是9宫格，android拉起的是数字键盘。

就这样，优化走一波。。。。。。。

#### 有问题的一般都是老板们的手机
正当我喝着橙汁，听着小曲儿，撸着代码的时候。产品发来了一张图。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_13.jpg)

> 当用户设置搜狗为默认输入法

什么？？？？？？？？？拉起的软键盘居然时搜狗输入法，这一定是广告。

大概问了一下前因后果，原来是VVIP客户呀，难怪输入法都有特殊待遇。这就尴尬了，我总不能让客户去修改系统的默认输入法吧。

拉着一票人一起讨论呗，呱唧呱唧呱唧呱唧呱唧呱唧呱唧呱唧呱唧！！！！！

通过讨论，得以下几个方案：

1. 改为`<input type="password">`格式，这样就可以拉起原生输入法，但是就不一定时数字键盘了
2. 找客户端同学帮忙看能不能限制输入法；这样做App里面正常，但是浏览器里面还是会有问题
3. 自己实现密码输入键盘，想挖坑的方案

但是，上面的所有的方案都不好。况且产品，产品老大也不同意啊。怎么办呢？？？ 

齐心协力上网搜呀，看看哪些网站有拉起软键盘是原生数字键盘的, 终于扒到了一个。

代码很简单：

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_14.png)

劳资，看到这行代码的时候，差点一屁股坐到了地上。什么！！！还有这种操作，黑科技呀有没有。反正我是信了。还等什么，赶紧试一试。

部分代码如下：

```html
<div class="ui-dialog-body ui-form">
    <div class="noticeInfo">{{notice}}</div>
    <div class="ui-form-item" ng-class="{'ui-focus':focused}">
        <ul class="pwdList ui-form-text">
            <li ng-repeat="item in passwordList track by $index" ng-click="inputFocus()">
                <span ng-class="{'dot':item}"></span>
            </li>
        </ul>
    </div>
    <input type="tel" pattern="[0-9]*" name="txtPassword" ng-trim="false" ng-model="pwdValue" ng-change="updatePassword();" ng-focus="onFocus();" ng-blur="onBlur()" autocomplete="off" autocorrect="off" maxlength="6">
</div>
```

居然真的可以了，有没有。使用`type="tel"`真的可以做到弹起的是原生的9宫格键盘。看来打电话还是亲爹的。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_15.jpg)
>  设置输入框 `type="tel"`

这种操作一定要拿小本本记下来。

```sh
git commit -a '为了用户密码安全，默认拉起原生9宫格键盘'
```

完事。

### 如何自动拉起软键盘
原来的软键盘一直都没有自动拉起来。交互逻辑是下面这个样子，用户必须手动点击输入框，才会拉起软键盘。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_16.png)

> 不能自动拉起软键盘

现在想实现成可以在用户点击“立即认购”按钮之后，可以自动拉起软键盘。如下图所示。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_17.png)

> 自动拉起软键盘

一般的做法就是在“立即认购”按钮上添加`click`事件，一旦"立即认购"按钮被点击，就触发交易密码框的`focus`事件。

尝试实现：

修改认购按钮html：

```html
<button type="submit" class="ui-btn"  ng-click="submitApply()">立即认购</button>
```

通过JavaScript事件进行处理。

```js
$scope.submitApply = function(){
    //密码框聚焦
    $input.focus();
    $scope.focused = true;//设置flag
}
```

这种方法，在网上也有一大把。虽然pc端可以正常执行，但是在移动端却不能正常拉起软键盘。

***结论：直接focus()行不通，需要进行深入研究。***


#### 利用Input聚焦可以拉起软键盘的特征

既然，软键盘只有在用户手动`touch`输入框`foucus`的时候才会弹起。是不是可以在原有的基础上，尝试把“立即认购”按钮也改成`input`输入框，同时使用原有按钮做背景。

案例走一波，修改按钮结构为以下格式：

```html
<div class="sub-container">
    <button type="submit" class="ui-btn" ng-class="{'ui-btn-loading': !isCanApplyNewStock}" ng-disabled="!render.agreement||!isCanApplyNewStock" ng-click="submitApply()">立即认购</button>
    <input type="tel" pattern="[0-9]*" class="trade-pwd" ng-click="submitApply()">
</div>
```

做法：也就是把一个透明的`input`框放在认购按钮上面，当用户点击的时候，其实是点击的是`input`输入框。猜想：这个时候，因为点击的是输入框，所以软键盘就会拉起来，同时执行上面的`submitApply()`函数，可以把光标聚焦到交易密码框上。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_18.png)

> 按钮结构

通过真机进行测试，发现居然可以正常拉起软键盘。猜想成立。

![pwd](/images/2018-08-27-input-pwd-on-mobile-browser-dialog/pwd_19.png)

> 正常拉起数字软键盘

实践说明，通过一个`input`输入框，拉起软键盘后，可以通过JavaScript执行`focus()`聚焦到其他输入框，并保证软键盘不会收起，并且可以正常对聚焦的输入框进行输入。

走一波。。。。

## 总结
总体上，都是一些输入框上的操作，知道了原理，其实也挺简单的，求安慰，呜呜呜呜呜。坑都踩了，还等什么，赶紧去优化你的输入框吧。

如果有好的建议，欢迎大家留言交流。