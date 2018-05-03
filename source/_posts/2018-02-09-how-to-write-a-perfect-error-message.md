---
title: 【译】如何做好错误提示
date: 2018-02-09 10:00
categories: [设计]
tags: [JS,技术]
author: Diandian
---

![errormessage](/images/2018-02-09-how-to-write-a-perfect-error-message/1.png)

没有什么系统是不会出错的。有时候是用户误操作导致的错误，有时候是系统本身报错。面对报错，用正确的方式来处理报错信息是非常重要的，这对于提高用户体验是很关键的。

错误信息提示有三块重要部分要注意：
<!-- more -->

- 错误信息要清晰
- 错误信息的正确位置
- 良好的视觉效果

### 错误文字信息清晰明了

#### 1、错误的信息一定要清晰
错误信息应该要很清楚的表明问题是什么，为什么会出现，需要用户怎么去做。要把错误信息想象成是与用户的一种对话交流-看起来像是专门为用户设计的。确保错误信息是有礼貌的，易懂的，友好的并且非行业术语。

![errormessage](/images/2018-02-09-how-to-write-a-perfect-error-message/2.png)

#### 2、错误信息需要有用
仅仅把错误信息展示出来是不够的，要告诉用户如何快速的解决这个问题。
例如：Microsoft描述了错误是什么并且提供了错误信息的解决方案，帮助你快速的解决这个问题。

![errormessage](/images/2018-02-09-how-to-write-a-perfect-error-message/3.png)

#### 3、错误信息需要具体问题具体分析
很多时候，网站对所有的验证状态只使用一个错误提示。邮件输入框为空-提示“请输入有效的电子邮箱地址”，没有用“@”符号-提示“请输入有效的电子邮箱地址”。MailChimp会以另外一种方式进行处理-他们对于邮箱验证有三种错误信息提示。第一种是提交时验证输入框是否为空。另外两种是验证“@”和“.”符号。（然而“请输入内容”不是个很好的错误提示示例，因为并没有说清楚要输入什么样的内容）最好是给用户实际点的提示而不是通用的提示。

![errormessage](/images/2018-02-09-how-to-write-a-perfect-error-message/4.png)

#### 4、错误信息需要礼貌
用户即使操作有误也不要责怪他们，对用户要礼貌，让用户觉得舒适。其实这也是提高品牌声誉的好机会，同时也可以设置有自己特色的错误提示。

![errormessage](/images/2018-02-09-how-to-write-a-perfect-error-message/5.png)

#### 5、适当的用些幽默的方式
错误提示中用幽默的方式要慎重。首先保证错误提示应该要有内容且有用。然后为了改善用户体验可以适当用些幽默的方式。

![errormessage](/images/2018-02-09-how-to-write-a-perfect-error-message/6.png)

### 错误提示要放在合适的位置

一个好的错误提示是在需要时出现。要避免错误汇总或直接把错误信息放在UI元素的旁边。

![errormessage](/images/2018-02-09-how-to-write-a-perfect-error-message/7.png)

### 为错误提示设计一个合适的视觉

错误提示应该要明显些。使用文字或背景有对比的颜色，这样更容易让用户一眼看到和阅读。

通常，会用红色来显示错误提示。有时候可以用下橙色或者黄色，相对来说红色会让人觉得紧张。不管哪种颜色，要确保错误提示清晰，与背景色有明显的对比。为了改善色盲患者的体验，可以在颜色旁边加一个相关的图标提示。

![errormessage](/images/2018-02-09-how-to-write-a-perfect-error-message/8.png)

### 总结

总之，错误提示是改善用户体验，提升品牌声誉和产品个性的重要机会。要注意做好错误提示的每个方面-文案提示，错误提示位置，和UI视觉，这样才可以做到万无一失。


原文：[How to Write a Perfect Error Message](https://uxplanet.org/how-to-write-a-perfect-error-message-da1ca65a8f36)

作者：[Vitaly Dulenko](https://uxplanet.org/@atko_o)

译者：[Diandian](https://futu.im/author/Diandian)
