---
title: 【译】复选框和切换按钮
date: 2018-08-22 10:30
categories: [设计]
author: Diandian
---

![图片](/images/2018-08-22-checkbox-and-toggle-switch/1.png)

<!-- more -->

表单自带的控件可以方便我们收集用户的输入。在表单设计时，恰当的使用合适的控件也是一项挑战。

`checkbox`有三种状态：未选择，选择和状态不确定的三种。最后一个状态表示子选项在父选项分组里并且子选项处于选择和未选择的中间状态。

`toggle`表示物理开关，允许用户打开或者关闭，就像开关灯一样。

`监听toggle开关实现了两个操作：选择和执行，然而checkbox只是选择一个选项，执行需要另外的控件来实现`。

在决定用checkbox还是toggle时，最好是关注具体的情景而不是功能。

以下是一些用例，以及在设计表单时决定用哪个控件的一些指引。

### 案例一：及时反馈

#### 以下这些情况需要用toggle

- 应用设置不需要有很明确的操作就可以即刻生效。
- 设置需要开/关或者显示/隐藏来展示效果。
- 用户选择后不必审核确认就可以执行生效。

![图片](/images/2018-08-22-checkbox-and-toggle-switch/2.png)

需要即刻响应时最好用toggle

### 案例二：设置需要确认
#### 以下这些情况需要用checkbox
- 应用设置需要用户确认和审核才能提交。
- 定义的设置生效之前需要有一些操作，比如点击提交，OK，或者下一步。
- 用户必须执行额外的操作才能使更改的变化生效。

![图片](/images/2018-08-22-checkbox-and-toggle-switch/3.png)

如果需要一些明确的操作才能使得应用失效，首选checkbox

### 案例三：多选
#### 以下这些情况需要用checkbox
- 在多选中用户需要选择一个或者多个选项。
- 如果用toggle的话，需要一个一个的点击，而每一次点击都需要有额外的时间等待才能看到效果。

![图片](/images/2018-08-22-checkbox-and-toggle-switch/4.png)

在列表中选择多个选项可使用checkbox

###  案例四：不确定的状态
#### 以下这些情况需要用checkbox
- 不确定选择状态时需要有多个子选项在父选项的分组里。这个不确定的状态意味着子选项是需要被选择的（不是全部都必选）。

![图片](/images/2018-08-22-checkbox-and-toggle-switch/5.png)

不确定的状态最好用checkbox展示


### 案例五：清晰的视觉
#### 以下这些情况需要用checkbox
- 有一种情况会让toggle的开关状态比较困惑，就是有时很难分清这个开关是展示状态还是需要操作。
- 需要提供一个清晰的选择和未选择的状态区别。

![图片](/images/2018-08-22-checkbox-and-toggle-switch/6.png)

有时候toggle不能很清晰的表示出它是一个状态还是需要操作。

### 需要选中相似的选项
#### 以下这些情况需要用checkbox
- 用户需要在选出列表中的相似选项

![图片](/images/2018-08-22-checkbox-and-toggle-switch/7.png)

在列表中选出相似的选项需要用checkbox

#### 以下这些情况需要用toggle
- 用户需要切换不同的特性或者操作。

![图片](/images/2018-08-22-checkbox-and-toggle-switch/8.png)

相互独立无交集的一些操作需要用toggle

### 选项单一独立
#### 以下这些情况需要用checkbox
- 不管这个选项的选择与否会记录一个是或者否的结果。  
- 当只有一个选项时，你可以选择也可以不选择，但是选不选择的效果区别比较明显。

![图片](/images/2018-08-22-checkbox-and-toggle-switch/9.png)

选择意味着表示是/否选择用checkbox

#### 以下这些情况需要用toggle
- 只有一个选择，并且开关代表不同的选择。

![图片](/images/2018-08-22-checkbox-and-toggle-switch/10.png)

用toggle能更好的表示出开关的选择

### 结论

在合适的情形下使用合适的控件可以使界面更加友好。因为表单可能会有比较多的选项需要选择，当用户点击选择这些选项来完善信息时会觉得很枯燥。以上这些例子可以帮助你在表单中添加控件时，可以更好的选择用checkbox和toggle。



原文：[https://uxplanet.org/checkbox-vs-toggle-switch-7fc6e83f10b8](https://uxplanet.org/checkbox-vs-toggle-switch-7fc6e83f10b8)

译者：[Diandian](https://futu.im/author/Diandian)

作者：[saadiam](https://uxplanet.org/@saadiam)

