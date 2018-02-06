---
title: 【译】对外提供API时做this的绑定
date: 2018-02-06 10:00
category: 翻译
tags: [JS,技术]
author: Diandian
---

有一天，在我研究[ the Zendesk web widget race condition](https://www.bennadel.com/blog/3248-the-zendesk-web-widget-appears-to-have-a-small-hide-show-race-condition.htm)时，我最初想到的是在setTimeout()里通过暴露zEmbed对象的方法来解决。这个方法是可以用的；同时，也让我想到了API文档。在Zendesk web widget文档中，没有提到这个方法是否可以分发来做裸参考。所以，提出这样一个问题：不管是否有效都能这样使用它吗？越想这个问题，我越觉得对象构造-和它继承方法绑定-是API的非常重要的一部分，不管你写没写。方法绑定是理解Javascripts的基础，我想你应该想让大家能用不同的方式使用它。

译者注：

Web Widget，中文可译作：小部件、小工具、微件、挂件等，是一小块可以在任意一个基于HTML的网页上执行代码构成的小部件，它的表现形式可能是视频、地图、新闻或小游戏等等。
竞态条件（race condition），从多进程间通信的角度来讲，是指两个或多个进程对共享的数据进行读或写的操作时，最终的结果取决于这些进程的执行顺序

<!-- more -->

通常，当我在探讨一个函数对象的直接引用时，会用“裸方法”这个术语。具体而言，“裸方法”就是一个作为没有作用域的“函数”和没有“对象方法”被调用时的方法。有一天我从zEmbed的例子中发现，“裸方法”解决方案是在setTimeout()中调用我研究的show()和hide()API方法作为裸引用。像这样：

setTimeout(zEmbed.show,500);

请注意：我没有调用show()-我直接引用了“show”函数。这样的话，当setTimeout()定时器调用这个回调函数-show()-它将会在zEmbed对象之外执行。

这对zEmabed对象是可行的，因为show()和hide()是[使用闭包和词法绑定来连接他们的内部引用](https://www.bennadel.com/blog/1482-a-graphical-explanation-of-javascript-closures-in-a-jquery-context.htm)。这是方法很常见。很多Promise/Deferred库为了让resolve和reject方法可以作为裸函数传递引入，特意用这种方式（请参阅[jQuery Deffered](https://www.bennadel.com/blog/2125-the-power-of-closures---deferred-object-bindings-in-jquery-1-5.htm)，[AngularJs $q](https://www.bennadel.com/blog/2749-passing-q-defer-methods-around-as-naked-function-references-in-angularjs.htm)）。

注意：我不太确定上面的库是使用了词法绑定，或者是否在暴露方法之前调用了.bind().总之，结果都是一样的。

但是，这个对象框架通常是不会明确阐述出来的。意思是，对象API的文档几乎从不讨论对象内部的实际机制。现在，你可能会说任何非文档的东西都是不可靠的。但是不管你在文档中是否有表示你用构造对象作为Javascript语言的基础，构造对象都是API的内置部分。更有甚者，对构造对象的内部改变实际上也是对API的“实质性更改”。


要了解对象结构-及其更改-如何影响代码的使用，我们来看一个Node.js的示例。首先，我们来创建一个模拟的zEmabed对象，它的内部引用使用了词法绑定：

[lexical.js](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08#file-lexical-js)hosted with ❤ by [GitHub](https://github.com)  
[view raw](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08/raw/b4bc5811871d4a41824061661bd85ee0b01200ce/lexical.js)
```
//引入核心模块
var chalk = require('chalk');
// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

// 这是一个模拟zEmbed对象的构造函数.
function ZEmbed(token){
    // 返回该对象的公共API
    //--
    // 注意：公共API是使用词法绑定的函数的集合
    // 目的是找到“类变量”
    return({
        hide:hide,
        show:show
    });
    //---
    // 公共方法
    //---
    function hide(){
        console.log(chalk.red(`隐藏控件 ${token}.`));
    }
    function show(){
        console.log(chalk.green(`显示控件 ${token}.`));
    }
}

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //
var zEmbed = new ZEmbed("9cf6672aaf");

// 让我们把这些方法从对象中分离出来，以便于更加清晰的进行绑定。
var show = zEmbed.show;
var hide = zEmbed.hide;

//  因为zEmbed 方法是用的静态绑定，所以这个方法可以被传递。
// 作为裸引用，这个特性是你的API对象的内置部分

setTimeout(show,500);
setTimeout(hide,1000);
```

这里，你可以看到show() 和hide()用词法绑定去找“token”实例属性来代替“this”关键字。这样，当show()和hide()方法通过裸函数调用时，结果就出来了：

![Your method binding approach can affect the way your API is consumed](/images/2018-method-binding-is-an-implicit-part-of-your-api-contract/1.png)

当谈及对象结构时，这也是个好方法。也就是说，我们可以创建一个对象，同时使用词法和基于上下文绑定的方法。例如，我们可以[通过每个方法返回的（this）来对之前的代码添加方法链](https://www.bennadel.com/blog/2798-using-method-chaining-with-the-revealing-module-pattern-in-javascript.htm)。

[mixed.js](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08#file-mixed-js) hosted with ❤ by [GitHub](https://github.com)
[view raw](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08/raw/b4bc5811871d4a41824061661bd85ee0b01200ce/mixed.js)
```
// 引入模块
var chalk = require("chalk");
// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

// 这是一个模拟zEmbed对象的构造函数
function ZEmbed(token){
    // 返回这个对象的公共API
    //--
    // 注意：公共API是使用词法绑定的函数集合
    // 为了找到“类变量”。然而公共方法会返回一个
    // 为方法链提供公共API（this）的引用
    return ({
        hide:hide,
        show:show
    })
    // ---
    // 公共方法
    // ---
    function hide(){
        console.log(chalk.red(`隐藏控件 ${token}`));
        //返回这个方法，以便于使用方法链
        return(this);
    }
    function show(){
        console.log(chalk.green(`显示控件 ${token}`));
        //返回这个方法，以便于使用方法链
        return(this);
    }
}
// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

var zEmbed = new ZEmbed('9cf6672aaf');
// 让我们把这些方法从对象中分离出来，以便于更加清晰的进行绑定。
var show = zEmbed.show;
var hide = zEmbed.hide;

//  因为zEmbed 方法是用的静态绑定，所以这个方法可以被传递。
// 作为裸引用，这个特性是你的对象API的一个内置部分

setTimeout(show,500);
setTimeout(hide,1000);
// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //
//即使zEmabed类方法使用词法绑定来查找类
//属性，他们也使用这个绑定来返回一个引用
//公共API。允许使用方法链，但只有调用时可用
//公共API的上下文
setTimeout(
    ()=>{
        //尝试在API中使用方法链
        console.log(chalk.bold("\n==Trying method chaining =="));
        zEmbed.show().hide();
        
        //尝试使用裸方法引用使用方法链
        console.log(chalk.bold("\n== Trying Naked Method chaining =="))
    }
)
```
在这种情况下，当show()和hide()方法返回(this)时，这个对象的方法被调用时会返回上下文绑定的引用。这使得show()和hide()函数具有双重性质。一方面，它们依然在词法上与“token”相关联；但，另一方面，它们是基于调用情况来进行上下文绑定的。这对于如何使用裸引用有直接的影响。而且，我们运行以上代码时，输出的结果是：

![Your method binding approach can affect the way your API is consumed](/images/2018-method-binding-is-an-implicit-part-of-your-api-contract/2.png)

正如你看到的那样，裸函数引用仍然可以在不中断的情况下自行调用，但是，为了使用方法链，我们必须调用zEmabed对象上下文中的方法(更确切的说是他的公共API)。否则，“this”引用不会绑定到正确的对象，并且链接方法不能被找到。

现在，如果我们进一步看这个代码，并且用“类方法”代替词法绑定方法，那么裸函数引用的概念就清楚了。

[context.js](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08#file-context-js) hosted with ❤ by [GitHub](https://github.com)
[view raw](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08/raw/b4bc5811871d4a41824061661bd85ee0b01200ce/context.js)
```
//引入模块
var chalk = require('chalk');
// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //
// 这是zEmabed的模拟类
// --
// 注意：对于传统的“类”，所有内部引用都使用“this”
// 这些方法全部位于类原型上，并没有词法绑定
//到任何其他方法或实例变量
class zEmbed{
    constructor(token){
        this.token = token;
    }
    // ---
    // 公共方法
    // ---
    hide(){
        console.log(chalk.red(`隐藏控件 ${this.token}`));
        // 返回这个对象便于方法链
        return(this);
    }
    show(){
        console.log(chalk.green(`显示控件 ${this.token}`));
        //返回这个对象便于方法链
        return(this);
    }
}
// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //
var zEmbed = new ZEmbed('9cf6672aaf');
// 让我们把这些方法从对象中分离出来，以便于更加清晰的进行绑定
var show = zEmbed.show;
var hide = zEmbed.hide;

// 因为zEmbed方法是传统类绑定的一部分，所以下面
// calls 会中止.这个方法会在预期上下文之外执行
setTimeout( show, 500 );
setTimeout( hide, 1000 );
```

正如你所看到的，这次，我们我们用更传统/原始的方法为实例设置原型并且在内部引用使用“this”关键字。现在，当我们使用类方法作为裸函数时，输出的是：

![Your method binding approach can affect the way your API is consumed](/images/2018-method-binding-is-an-implicit-part-of-your-api-contract/3.png)

在这里，你可以看到我们不能再使用show()和hide()方法作为裸函数引用。这是因为如果这个方法在类的上下文之外调用的话，“this”引用于这个类实例无关。

所有这一切只是为了证明-作为Javascript的一个基本特征-你的内部对象结构直接影响你的API如何被销毁。而且，当你扩展内部对象结构时，是有破坏代码的风险。同样，你的内部对象结构和你的方法绑定都是你的API内置部分，而且，当你扩展你的内部结构时，你必须意识到它是否会造成本质变化。

原文：[Method Binding Is An Implicit Part Of Your API Contract (Whether You Like It Or Not)](https://www.bennadel.com/blog/3254-method-binding-is-an-implicit-part-of-your-api-contract-whether-you-like-it-or-not.htm)

作者：[Ben Nadel ](https://plus.google.com/108976367067760160494?rel=author
)

译者：[Diandian](https://futu.im/author/Diandian)
