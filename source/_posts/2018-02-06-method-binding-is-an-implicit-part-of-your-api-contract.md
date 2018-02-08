---
title: 【译】对外提供API时做this的绑定
date: 2018-02-06 10:00
category: 翻译
tags: [JS,技术]
author: Diandian
---

有一天，在我研究[the Zendesk web widget race condition](https://www.bennadel.com/blog/3248-the-zendesk-web-widget-appears-to-have-a-small-hide-show-race-condition.htm)时，我最初想到的是在setTimeout()中执行被叫做“裸方法”引用的zEmbed对象方法。这种方式是可行的；但是，这让我对API文档产生怀疑。在Zendesk web widget文档中，没有提到它的方法可以被当做裸引用。为此，我有个疑问：不管可行与否，能这样用吗？越想这个问题，我越觉得从对象的创建到对象方法的继承，这里面不管文档中有没有提到，都是API文档中的重要部分。方法绑定对于Javacript的学习是很基本的，我想你应该也有很多种实现的方式。

<!-- more -->

通常，“裸方法”就是一个函数对象的直接引用。具体而言，就是当一个函数并非一个对象的属性（即方法）时，它将被当做一个函数来调用。从zEmbed的例子中看到，我所谓的“裸方法”就是在setTimeout()中直接调用show()和hide()api的方法。例如：

setTimeout(zEmbed.show,500);

这里要注意，我并没有执行show(),而是直接引用了函数“show”。请注意：当setTimeout()调用这个回调函数时-show()将会在zEmbed对象上下文之外执行。

这对zEmabed对象是可行的，因为show()和hide()是[使用闭包和静态绑定来连接它们的内部引用](https://www.bennadel.com/blog/1482-a-graphical-explanation-of-javascript-closures-in-a-jquery-context.htm)。这是方法很常见。很多Promise/Deferred库为了让resolve和reject方法直接引用，特意用这种方式（请参阅[jQuery Deffered](https://www.bennadel.com/blog/2125-the-power-of-closures---deferred-object-bindings-in-jquery-1-5.htm)，[AngularJs $q](https://www.bennadel.com/blog/2749-passing-q-defer-methods-around-as-naked-function-references-in-angularjs.htm)）。

注意：我不太确定上面的库一定是用了静态绑定，也许是在暴露方法之前call调用了或者用了.bind()方法.总之，结果都是一样的。

这里，一般对象框架时不会提的。也就是说，对象API不会去表现对象内部的实现机制。现在，你往往会觉得文档中没有的东西都是不可靠的。但是，我想说不管你在文档中是否提到构造函数，它都是API的重要部分。更有甚者，任何对构造函数的更改本质上也是对API的更改。


要了解对象结构-及其更改-如何影响代码的使用，我们来看一个Node.js的示例。首先，我们来创建一个模拟的zEmabed对象，它的内部引用使用了静态绑定：

[lexical.js](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08#file-lexical-js)hosted with ❤ by [GitHub](https://github.com)   [view raw](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08/raw/b4bc5811871d4a41824061661bd85ee0b01200ce/lexical.js)

```javascript
//引入核心模块
var chalk = require('chalk');
// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

// 这是一个模拟zEmbed对象的构造函数.
function ZEmbed(token){
    // 返回该对象的公共API
    //--
    // 注意：公共API是使用静态绑定的函数的集合
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
// 作为裸引用，这个特性是你的API对象的一部分

setTimeout(show,500);
setTimeout(hide,1000);
```

这里，你可以看到show()和hide()并没有使用“this”，“token”是用传参的形式。这样，当show()和hide()被直接调用时，就能获取token：

![Your method binding approach can affect the way your API is consumed](/images/2018-method-binding-is-an-implicit-part-of-your-api-contract/1.png)

当谈及对象结构时，这不是个全有或全无的方法。也就是说，我们可以创建一个对象，同时使用词法和基于上下文绑定的方法。例如，我们可以[通过每个方法返回的（this）进行链式调用](https://www.bennadel.com/blog/2798-using-method-chaining-with-the-revealing-module-pattern-in-javascript.htm)。

[mixed.js](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08#file-mixed-js) hosted with ❤ by [GitHub](https://github.com) [view raw](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08/raw/b4bc5811871d4a41824061661bd85ee0b01200ce/mixed.js)

```javascript
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
    // 为链式调用提供公共API（this）的引用
    return ({
        hide:hide,
        show:show
    })
    // ---
    // 公共方法
    // ---
    function hide(){
        console.log(chalk.red(`隐藏控件 ${token}`));
        //返回这个方法
        return(this);
    }
    function show(){
        console.log(chalk.green(`显示控件 ${token}`));
        //返回这个方法
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
//公共API。允许使用链式调用，但只有调用时可用
//公共API的上下文
setTimeout(
    ()=>{
        //尝试在API中使用链式调用
        console.log(chalk.bold("\n==Trying method chaining =="));
        zEmbed.show().hide();
        
        //尝试使用裸方法引用使用链式调用
        console.log(chalk.bold("\n== Trying NAKED method chaining =="));
        show().hide();
    },
    2000
);
```
在这种情况下，当show()和hide()方法返回(this)时，这个对象的方法被调用时会返回上下文绑定的引用。这使得show()和hide()函数具有两面性。一方面，token传参；另一方面，上下文绑定情况影响函数调用。以上代码输出的结果是：

![Your method binding approach can affect the way your API is consumed](/images/2018-method-binding-is-an-implicit-part-of-your-api-contract/2.png)

以上，裸函数引用依然被执行，但是，为了使用链式调用，我们必须执行zEmabed对象上下文中的方法(更确切的说是他的公共API)。否则，“this”指向不对，链式调用不生效。

现在，如果我们进一步看这个代码，并且用“类方法”代替词法绑定方法，那么裸函数引用的概念就更清晰了。

[context.js](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08#file-context-js) hosted with ❤ by [GitHub](https://github.com) [view raw](https://gist.github.com/bennadel/81040d2bd52c2bf84ac8a1f36d123a08/raw/b4bc5811871d4a41824061661bd85ee0b01200ce/context.js)

```javascript
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
        // 返回这个对象便于链式调用
        return(this);
    }
    show(){
        console.log(chalk.green(`显示控件 ${this.token}`));
        //返回这个对象便于链式调用
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

在这里，你可以看到我们不能再使用show()和hide()方法作为裸函数引用。这是因为如果这个方法在类的上下文之外调用的话，“this”引用与这个类实例无关。

所有这一切只是为了证明-作为Javascript的一个基本特征-你的内部对象结构直接影响你的API。而且，当你扩展内部对象结构时，是有破坏代码的风险。同样，对外提供API时做this的绑定是重要部分，而且，当你扩展你的内部结构时，你必须意识到它是否会造成本质变化。

原文：[Method Binding Is An Implicit Part Of Your API Contract (Whether You Like It Or Not)](https://www.bennadel.com/blog/3254-method-binding-is-an-implicit-part-of-your-api-contract-whether-you-like-it-or-not.htm)

作者：[Ben Nadel ](https://plus.google.com/108976367067760160494?rel=author
)

译者：[Diandian](https://futu.im/author/Diandian)
