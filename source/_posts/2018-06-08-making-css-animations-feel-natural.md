---
title: 【译】如何让CSS动画更自然
date: 2018-06-08 19:30
categories: [前端]
author: evanyan
---
在过去，设计师负责设计，程序员负责编码。他们间互不干涉。但随着CSS中transitions和animations的到来，设计和编码的界限模糊了。设计师描述设计，而程序员把设计师的描述翻译成具体代码--这种合作模式不再像过去那么简单。为了高效地协作，设计师必须懂点代码，而程序员必须懂点设计。

<!-- more -->

举个例子，假设一位设计师要求开发人员实现一个如下所示的盒子反弹动画，在没有跨界知识和通用标准表述的情况下，设计师和程序员的沟通会有少许信息丢失。程序员没有足够的信息去了解设计师的意图，设计师也不知道他们到底可以选择什么。这样的沟通会有信息缺失，你最后完成的效果可能是下面这样的：

<iframe height='450' scrolling='no' title='Bouncing Box 1' src='//codepen.io/pulpexploder/embed/apxRbK/?height=265&theme-id=dark&default-tab=result&embed-version=2' frameborder='no' allowtransparency='true' allowfullscreen='true' style='width: 100%;'>See the Pen <a href='https://codepen.io/pulpexploder/pen/apxRbK/'>Bouncing Box 1</a> by Brandon Gregory (<a href='https://codepen.io/pulpexploder'>@pulpexploder</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>

这样的效果并不会令人兴奋。虽然这已经符合动画效果的基本标准，但我们绝对可以做得更好。

首先要看的是animation-timing-function属性。在上面的例子中，我们对此属性赋值linear，这意味着盒子以相同的速度不断运动。在某些情况下，这是可取的；然而，在现实世界中，运动通常不是线性的。

一个简单的解决方法是改变animation-timing-function属性。这使得每个动画的开始部分和结束部分比中间部分稍慢，这会令一些动画更自然。以下是启用了缓动功能的方块：

<iframe height='450' scrolling='no' title='Bouncing Box 2' src='//codepen.io/pulpexploder/embed/bgJmde/?height=265&theme-id=dark&default-tab=result&embed-version=2' frameborder='no' allowtransparency='true' allowfullscreen='true' style='width: 100%;'>See the Pen <a href='https://codepen.io/pulpexploder/pen/bgJmde/'>Bouncing Box 2</a> by Brandon Gregory (<a href='https://codepen.io/pulpexploder'>@pulpexploder</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>

这只是一个小小的改进，所以我们仍有很多工作要做。同一时间内一次又一次地出现相同的动画，令方块看起来仍然机械又僵硬。在反弹之间增加一点点延迟，可让动画看起来更自然些：

<iframe height='450' scrolling='no' title='Bouncing Box 3' src='//codepen.io/pulpexploder/embed/YNMJXb/?height=265&theme-id=dark&default-tab=result&embed-version=2' frameborder='no' allowtransparency='true' allowfullscreen='true' style='width: 100%;'>See the Pen <a href='https://codepen.io/pulpexploder/pen/YNMJXb/'>Bouncing Box 3</a> by Brandon Gregory (<a href='https://codepen.io/pulpexploder'>@pulpexploder</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>

现在这个动画看起来就像盒子自己在跳跃，而不是简单地被上下移动。跳跃之间有一点蓄力和停滞，模仿了活着的生物做同样的事情时会有的表现。尽管我们没有提供盒子跳跃的设计参考，但我们都对生物跳跃的表现有很好的了解。我们知道真实跳跃是什么样子，通过模仿，动画可以更自然。我们可以做更多的事情来让这种感觉变得更加突出。

如果你看动画片，你会注意到一些现实生活中的动作往往会被夸大、漫画化。做得好的话，这些动作就像在真实世界中一样自然，还带了些特有的魅力和个性。

在这个阶段，设计师和开发者之间的合作是至关重要的 -- 但许多设计师可能都不知道这些选择的存在，所以得提醒开发人员将这些选择提供给设计人员。

通过在方块上添加一些轻微的变形，我们可以令动画丰满许多：

<iframe height='450' scrolling='no' title='Bouncing Box 4' src='//codepen.io/pulpexploder/embed/YNMJyb/?height=265&theme-id=dark&default-tab=result&embed-version=2' frameborder='no' allowtransparency='true' allowfullscreen='true' style='width: 100%;'>See the Pen <a href='https://codepen.io/pulpexploder/pen/YNMJyb/'>Bouncing Box 4</a> by Brandon Gregory (<a href='https://codepen.io/pulpexploder'>@pulpexploder</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>

现在，盒子是一个活着的角色。仍有很多事情需要调整，但这已经比原来的动画更进一步 -- 以一种非常好的方式。

现在我们更进一步，在跳跃结束时添加一点反弹：

<iframe height='450' scrolling='no' title='Bouncing Box 5' src='//codepen.io/pulpexploder/embed/MJRPKE/?height=265&theme-id=dark&default-tab=result&embed-version=2' frameborder='no' allowtransparency='true' allowfullscreen='true' style='width: 100%;'>See the Pen <a href='https://codepen.io/pulpexploder/pen/MJRPKE/'>Bouncing Box 5</a> by Brandon Gregory (<a href='https://codepen.io/pulpexploder'>@pulpexploder</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>

第二次反弹让盒子看起来更有活着的感觉，但似乎仍然缺失了些东西。与其他成熟动画相比，这个反弹看起来很僵硬。我们需要再添加一点扭动：

<iframe height='450' scrolling='no' title='Bouncing Box 6' src='//codepen.io/pulpexploder/embed/QdPZNp/?height=265&theme-id=dark&default-tab=result&embed-version=2' frameborder='no' allowtransparency='true' allowfullscreen='true' style='width: 100%;'>See the Pen <a href='https://codepen.io/pulpexploder/pen/QdPZNp/'>Bouncing Box 6</a> by Brandon Gregory (<a href='https://codepen.io/pulpexploder'>@pulpexploder</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>

最终的微妙变形使得反弹看起来更加自然。总体而言，第一个例子中我们的基本线性反弹有了巨大的改善。

这正是我们正在寻找的东西，但我们仍可以用定制的三次Bézier曲线进一步调整移动速率：

<iframe height='450' scrolling='no' title='Bouncing Box 7' src='//codepen.io/pulpexploder/embed/ypYXwb/?height=265&theme-id=dark&default-tab=result&embed-version=2' frameborder='no' allowtransparency='true' allowfullscreen='true' style='width: 100%;'>See the Pen <a href='https://codepen.io/pulpexploder/pen/ypYXwb/'>Bouncing Box 7</a> by Brandon Gregory (<a href='https://codepen.io/pulpexploder'>@pulpexploder</a>) on <a href='https://codepen.io'>CodePen</a>.
</iframe>

如果设计人员和开发人员不都了解基本的动画原理和控制方式，那就不可能做出生动的动画。这篇文章只是抓住了这两个领域一些浅显的地方。如果您是网页设计师或与设计师合作的网页开发人员，我强烈建议您阅读这两个领域的内容。

对于动画原则，奥利约翰斯顿和弗兰克托马斯的《The Illusion of Life: Disney Animation》是一本伟大的入门书籍。学会关于动画原则的通用语言后，设计人员和开发人员之间的沟通和协作将变得更加容易。

对于CSS动画的控制和变化，其可能性几乎是无止境的，因为延迟和计时很容易调整。如前所述，如果您不喜欢现成的易用的定时功能，则可以使用cubic-bezier()来创建自己的定时功能。您还可以对动画做出调整，使其更接近于漫画或更接近于现实。重要的是，设计师和开发人员都要考虑这些变化，而不是盲目地沟通且不考虑用户体验。互相共享知识和互相协作可以将简单的动画变成很棒的动画。


原文：[https://css-tricks.com/making-css-animations-feel-natural/](https://css-tricks.com/making-css-animations-feel-natural/)

作者：[Brandon Gregory](https://css-tricks.com/author/brandongregory/)

译者：[evanyan](https://futu.im/author/evanyan)