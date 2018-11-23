---
title: 【译】JavaScript中的“this”是什么？
subtitle: 如果你用Javascript库构建东西，你可能会注意到一个特定的关键字`this`.
cover: /images/2018-06-05-what-is-this-in-javascript/cover.jpeg
date: 2018-06-05 10:30
categories: [前端]
author: Diandian
---
如果你用Javascript库构建东西，你可能会注意到一个特定的关键字`this`.

`this`在Javascript中使用是相当普遍的，但是有相当多的开发者都会花很多时间去理解this关键字在代码中到底有什么用途。

这篇文章中，我将会带你深入理解this。

<!-- more -->

在开始学习前，先确保你的电脑上已经安装了Node。打开命令行终端，运行node命令。

### 全局环境中的“this”

工作机制中的`this`并不总是特别容易理解。为了更好的理解`this`的工作方式，我们将开始把`this`放在不同的环境中。首先来看`全局`环境下的this。

全局环境中，`this`是全局对象，叫作`global`.
```
>this === global
true
```
但这只在`node`中，如果你试着运行相同的代码在Js文件中，我们将会得到false的输出。

为测试这个，我们创建一个文件index.js 并写上如下代码:

```
console.log(this===global)
```
然后用`node`运行这个文件：
```
$node index.js
false
```
这是因为在Js文件中，`this`等同于`module.exports`而不是`global`。

### 函数中的“this”

`this`函数内部的值通常由函数的调用来决定的。所以，在每个函数执行时，`this`可以有不同的值。

在你的`index.js`文件中，写一个非常简单的函数来检查`this`是否是等于全局对象。
```
function rajat() {
  console.log(this === global)
}
rajat()
```

如果用`node`运行代码，我们将会输出`true`.但是在文件的顶部添加`use strict`并再次运行它，我们将会得到`false`输出，因为现在的值`this`是`undefined`。

为了进一步解释这一点，我们来创建一个简单的函数来定义超级英雄的真是姓名和英雄姓名。

```
function Hero(heroName,realName){
    this.realName = realName;
    this.heroName = heroName;
}
const superman = Hero("Superman","Clark Kent");
console.log(superman);
```

请注意，这个函数不是在严格模式下编写的，`node`中运行代码我们不会得到期望的“Superman”和“Clark Kent”的值，而是`undefined`。

原因就是不是在严格模式下编写的，`this`指的是全局对象。

如果在严格模式下，会报错，因为Js不允许我们给`realName`和`heroName`赋值为`undefined`,这其实是好事，因为它阻止了我们创建全局变量。

最后，用首字母大写写入函数的名字，用`new`操作符，也就是我们说的构造函数。用以下代码代替上述代码片段的最后两行:

```
const superman = new Hero("Superman","Clark Kent");
console.log(superman);
```
`node index.js`再次运行该命令，将获得预期的输出。

### 构造函数中的"this"
Js没有特殊的构造函数，我们能做的就是用`new`操作符将函数调用转换为构造函数调用，如上面的部分所示。

当进行构造函数调用时，会创建一个新对象并赋值给`this`。然后在这个函数中隐式返回，除非我们有另一个明确返回的对象。

在`hero`函数中写下如下`return`

```
return {
    heroName:"Batman",
    realName:"Bruce Wayne",
}
```

`node`运行后，发现以上return语句会覆盖构造函数的调用。

return 语句不会覆盖构造函数调用的唯一场景是，如果return语句返回的不是对象，在这种情况下，返回的是原始值对象。

### 方法中的“this”

将函数作为对象方法调用时，`this`指向的是这个对象，然后该对象被称为函数调用的接收者。

这里，在`hero`对象中有个`dialogue`方法，`dialogue`中的`this`指向的是`hero`自己。所以`hero`被称为是`dialogue`方法调用的接收者。
```
const hero={
    heroName:"Batman",
    dialogue(){
        console.log(`I am ${this.heroName}!`);
    }
}
hero.dialogue();
```

这是一个非常简单的例子。但现实中，这个方法可能很难跟踪接收器。在下面写以下代码片段在`index.js`中。
```
const saying = hero.dialogue();
dialogue();
```

在这里，我们将`dialogue`调用赋值给另一个变量然后，将该变量作为函数调用。`node`中运行可以看到`this`返回的是`undefined`，因为该方法已经失去了接收器的轨道。`this`现在只想的是`global`，而不是`hero`。

接收器的丢失通常是发生在我们将方法作为回调传递给另一个时。我们可以通过包装函数，或者用`bind`方法来解决这个问题，以将`this`与特定的对象绑定。

### call() 和apply()

虽然函数的`this`值是隐式设置的，但我们也可以明确的`this`参数调用函数`call()`和`apply()`.

让我们重构下前面章节的代码：

```
function dialogue(){
    console.log(`I am ${this.heroName}`);
}
const hero={
    heroName:'Batman',
}
```

我们需要将`dialogue`函数与`hero`对象作为接收者进行连接。可以使用`call()`和`apply()`

```
dialogue.call(hero)
// or
dialogue.apply(hero)
```

但是如果你使用`call`和`apply`在非严格模式下，那么`null`或`undefined`使用`call`和`apply`将会被Js引擎忽略。这是通常建议用严格模式编写代码的原因之一。

### bind()

当我们将方法作为回调传递给另一个函数时，会有丢失方法预期接收者的风险，this会被设置为全局对象。

`bind()`方法可以允许我们将`this`参数永久的绑定到一个值上。因此在下面的代码片段中，`bind`将创建一个新的`dialogue`函数，并且将`this`值设置为`hero`。

```
const hero={
    heroName:"Batman",
    dialogue(){
    console.log(`I am ${this.heroName}`);
    }
};
setTimeout(hero.dialogue.bind(hero), 1000);
```

这样，`this`就不会被`call`和`apply`改变。

### 箭头函数中的“this”

使用箭头函数与使用其他类型的JS函数完全不同，箭头函数中，使用this会指向封闭的上下文中的值。

箭头函数会永久的捕捉到`this`的值，来阻止`apply`和`call`改变它。

为了解释箭头函数中`this`如何生效的，我们编写以下代码方便理解：

```
const batman = this;
const bruce=()=>{
    console.log(this === batman);
};
bruce();
```
这里讲`this`赋值给一个变量，然后对比该值和箭头函数中`this`的值。`node  index.js`运行后应该会有`true`的输出。

箭头函数的`this`值不能被明确设置。此外，箭头函数将会忽略我们试图用`call，apply，bind`方法传递给`this`值。箭头函数始终会引用创建箭头函数时的值。

箭头函数不能用作构造函数。因此，我们不能在箭头函数中将属性赋值给`this`。

那么箭头函数能为`this`做什么？

箭头函数可以帮助我在回调函数中访问`this`。为了解释这个问题，看下我写的`counter`对象。

```
const counter={
    count:0,
    increase(){
        setInterval(function(){
            console.log(++this.count);
        },1000);
    }
}
counter.increase();
```
`node  index.js`运行后，发现会给出`NaNs`列表，这是因为`this.count`不是指的`counter`对象，实际上是`global`对象。

为了使用这个计数器，我们用箭头函数重写它。

```
const counter = { 
  count：0，
  increase（）{ 
    setInterval（（）=> { 
      console.log（++ this.count）; 
    }，1000）; 
  }，
}; 
counter.increase（）;
```

现在在`increase`方法中`this`指向`counter`，结果就是正确的了。

注意：不要用`this.count+1`代替`++this.count`。这两者中的前者只会增加一次计数值，会在每次迭代中返回该值。

### 类中的“this”
类是所有JS应用程序中最重要的部分。让我们来看下类中的this。

一个类通常包含一个`constructor`，在这里`this`可以指向一个新创建的对象。

但是在方法中，如果该方法是普通函数，`this`也可以引用任何其他值。就像一个方法，类也会失去接收者的轨道。

让我们重新创建一个`Hero`函数作为类函数。这个类将包含一个构造函数和一个`dialogue`方法。最后，我们创建一个类的实例并调用该`dialogue`方法。

```
class Hero{
    constructor(heroName){
        this.heroName = heroName;
    }
    dialogue(){
        console.log(`I am ${this.heroName}`)
    }
}
const batman = new Hero("Batman");
batman.dialogue();
```

`this`在`constructor`指向的是新创建的那个实例`class`。当我们调用`batman.dialogue()`时，我们把调用`dialogue()`作为方法让`batman`作为`this`的接收者。

但如果我们存储`dialogue()`的指向，并作为函数调用它，那么我们将会失去该方法的接收者并且`this`指向的是`undefined`。

```
const say = batman.dialogue();
say();
```
这个错误原因是因为JS类隐式的处于严格模式。我们调用say()，一个没有任何自动绑定的函数。为了解决这个问题，我们需要手动bind()将dialogue()功能绑定到batman。

```
const say=batman.dialogue.bind(batman);
say();
```
也可以在constructor方法内部进行这种绑定。

### 总结
我们需要在Js中使用this，就像我们需要英语的代词一样，用这两句话。

- 拉贾特喜欢DC漫画。
- Rajat也喜欢Marvel电影。
 
我们使用代词来组合这两个句子。所以这两句话变成：

Rajat喜欢DC漫画，他 也喜欢漫威漫画

这个短短的语法课很好的解释了this在JS中的重要性，就像代词如何he连接这两个句子一样。this是再次提及同一事物的捷径。

我希望这篇文章能消除你在Js中对this的困惑，并且在JS代码中能很好的使用this。


原文：[https://blog.bitsrc.io/what-is-this-in-javascript-3b03480514a7](https://blog.bitsrc.io/what-is-this-in-javascript-3b03480514a7)

译者：[Diandian](https://futu.im/author/Diandian)

作者：[Rajat S](https://blog.bitsrc.io/@geeky_writer_)

