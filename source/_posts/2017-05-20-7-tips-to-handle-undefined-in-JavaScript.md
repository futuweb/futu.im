---
title: 【译】7个处理javascript的`undefined`的tips
date: 2017-05-20 16:30
categories: [前端]
tags: [javascript,undefined]
author: Cynthia
---

在8年前，我刚开始学习javascript时，让我觉得有点奇怪的是，`undefined`和`null`同样代表空值。它们之间是否有明确的不同？它们看起来都定义为“空”，此外，比较`null==undefined`的结果是`true`。

大多数的现代语言如`Ruby`, `Python` 或`Java`只有一个空值(`nil`或`null`)，而这，似乎才是合理的。

<!-- more -->

在javascript中，当访问一个尚未初始化的变量或对象属性时，解释器会返回`undefined`。如下：

```js
let company;  
company;    // => undefined  
let person = { name: 'John Smith' };  
person.age; // => undefined 
```

另一方面，`null`代表一个缺失的对象引用。javascript自身不会将变量或对象属性设为`null`。  
一些像`String.prototype.match()`的原生方法可以返回`null`以表示为缺失对象。看一下这个例子：

```js
let array = null;  
array;                // => null  
let movie = { name: 'Starship Troopers',  musicBy: null };  
movie.musicBy;        // => null  
'abc'.match(/[0-9]/); // => null 
```

由于javascript是非常宽松的，所以开发者有可能访问到未初始化的值。我也有这样的坏习惯。

通常这样冒险的行为会产生`undefined`的相关错误，从而导致脚本闪电般结束。常见的相关错误有：

- `TypeError: 'undefined' is not a function`
- `TypeError: Cannot read property '<prop-name>' of undefined`
- 类似的*类型错误*。

JavaScript开发人员应该可以理解这个笑话里的讽刺：

```js
function undefined() {  
  // problem solved
}
```

为减少这类错误的风险，你必须了解`undefined`会在什么时候生成。更重要的是，要在你的程序中抑制它的出现和传播，以提高代码的健壮性。

让我们详细地探明`undefined`对代码安全性的影响。


## 1. 什么是`undefined`

javascript 有6种基本类型

- ***Boolean***: `true` or `false`
- ***Number***: `1`, `6.7`, `0xFF`
- ***String***: `"Gorilla and banana"`
- ***Symbol***: `Symbol("name")` (始于ES2015)
- ***Null***: `null`
- ***Undefined***: `undefined`.

和一种单独的对象类型：`{name: "Dmitri"}, ["apple", "orange"]`

在这6种基本类型中，`undefined`是一个特殊的值，它有自己的类型Undefined。[根据ECMAScript规范](https://www.ecma-international.org/ecma-262/7.0/#sec-undefined-value):

> **Undefined value** primitive value is used when a variable has not been assigned a value.(当一个变量没有被赋值时，`undefined`值作为原始值使用。)

规范明确定义了，在访问未初始化变量，不存在的对象属性，不存在的的数组元素等时，将得到`undefined`值。举例：

```js
let number;  
number;     // => undefined  
let movie = { name: 'Interstellar' };  
movie.year; // => undefined  
let movies = ['Interstellar', 'Alexander'];  
movies[3];  // => undefined
```

如上所示，当访问:

- 一个*未初始化*变量 `number`
- 一个*不存在的*对象属性 `movie.year`
- 或一个*不存在的*数组元素 `movies[3]`

会被赋值为`undefined`

ECMAScript规范定义了`undefined`值的类型：

> **Undefined type** is a type whose sole value is the `undefined` value.(Undefined类型的唯一值是`udnefined`)

从这个意义上讲，用`typeof`运算符操作一个`undefined`值，返回`'undefined'`字符串。

```js
typeof undefined === 'undefined'; // => true
```

当然，`typeof` 可以很好地验证一个变量是否为`undefined`值。

```js
let nothing;  
typeof nothing === 'undefined';   // => true 
```

## 2. 生成`undefined`的常见场景

### 2.1未初始化变量

>A declared variable that is not yet assigned with a value (**uninitialized**) is by default `undefined`.(一个未赋值(未初始化)的已声明的变量默认为`undefined`。)

一个平淡朴素的例子：

```js
let myVariable;  
myVariable; // => undefined
```

`myVariable`已声明，但未赋值，访问该变量得到的值为`undefined`。

解决未初始化变量问题的一个有效方法是尽可能的赋予初始值。在未初始化状态下的变量越少越好。理想情况是当你声明变量后应立刻赋值`const myVariable = 'Initial value'`，但这并不总是可能的。

**Tip 1：赞成使用`const`，其次`let`，告别`var`**

我认为，ECMAScript2015的最好的特性之一是使用`const`和`let`声明变量。这些声明是块级作用域（与旧的函数作用域的`var`相反），并且在声明语句前，变量都处于[临时死区](https://rainsoft.io/variables-lifecycle-and-why-let-is-not-hoisted/#5letvariableslifecycle)，这是一个很大的进步。

当一个变量只赋值一次，且不再改变时，我建议使用`const`声明。它创建了一个[不可变的绑定关系](https://mathiasbynens.be/notes/es6-const)。

`const`的特征之一是，你必须给*变量赋值*，`const myVariable = 'initial'`，该变量不会暴露在未初始化状态，所以是不可能访问到`undefined`。

让我们检查一下这个函数，验证一个单词是否为回文:

```js
function isPalindrome(word) {  
  const length = word.length;
  const half = Math.floor(length / 2);
  for (let index = 0; index < half; index++) {
    if (word[index] !== word[length - index - 1]) {
      return false;
    }
  }
  return true;
}
isPalindrome('madam'); // => true  
isPalindrome('hello'); // => false
```

`length`和`half`只被赋值一次，因此这些变量不会改变，所以似乎有理由将它们声明为`const`。

如果你需要重新绑定变量（即多次赋值），用`let`声明，无论如何尽可能给它赋予初始值，如`let index=0`.

那旧的`var`了？就ES2015而言，我建议是[停止使用它](https://medium.com/javascript-scene/javascript-es6-var-let-or-const-ba58b8dcde75#.hvdxtd30t)。

![忘记`var`，使用`const`或`let`](/images/2017-05-20-7-tips-to-handle-undefined-in-JavaScript/1.png)

`var`声明的问题是，在整个函数作用域内的[变量提升](https://rainsoft.io/javascript-hoisting-in-details/#hoistingandvar)。你在函数的尾部声明一个`var`变量，但仍可以在声明之前访问它：你将得到`undefined`。

```js
function bigFunction() {  
  // code...
  myVariable; // => undefined
  // code...
  var myVariable = 'Initial value';
  // code...
  myVariable; // => 'Initial value'
}
bigFunction();  
```

`myVariable`是可以访问的，但在声明行`var myVariable = 'Initial value'`之前为`undefined`。

相反，一个`let`(包括`const`)变量在声明语句之前都无法访问。这是因为变量在声明之前处于[临时死区](https://rainsoft.io/variables-lifecycle-and-why-let-is-not-hoisted/#5letvariableslifecycle)。这很好，因为你很少有机会得到`undefined`。

将上面的例子改为`let`(而不是`var`)，会抛出`ReferenceError`，因为在临时死区的变量是不可访问的。

```js
function bigFunction() {  
  // code...
  myVariable; // => Throws 'ReferenceError: myVariable is not defined'
  // code...
  let myVariable = 'Initial value';
  // code...
  myVariable; // => 'Initial value'
}
bigFunction(); 
```

进行不可变的绑定鼓励使用`const`，否则使用`let`，以确保尽可能少暴露未初始化变量。

**Tip 2: 增强内聚**

[内聚](https://en.wikipedia.org/wiki/Cohesion_(computer_science))描述了模块的元素(命名空间，类，方法，代码块)紧密联系的程度。对内聚的度量通常被描述为高内聚或低内聚。

高内聚是可取的，因为它建议设计模块的元素时只关注单任务，它使得模块：

- *专注和可理解的*：更容易理解模块所做的事情
- *可维护和易于重构*：模块的更改影响更少的模块
- *可重用*：专注于单个任务，使模块更易于重用
- *可测试的*：您将更容易地测试一个专注于单一任务的模块

![高内聚](/images/2017-05-20-7-tips-to-handle-undefined-in-JavaScript/2.svg)

高内聚和[低耦合](https://en.wikipedia.org/wiki/Loose_coupling)是设计良好的系统的特点。

代码块本身就可能被认为是一个小模块。为了从高内聚的好处中获益，你需要尽可能使变量靠近调用它的代码块。

例如，一个变量只在某块级作用域中使用，那就声明并允许变量只在那个块（使用`const`或`let`声明），不要将这变量暴露给外部的块级作用域，因为外面的块级作用域并不关心这个变量。

在函数中使用`for`循环是变量不必要延伸的典型例子：

```js
function someFunc(array) {  
  var index, item, length = array.length;
  // some code...
  // some code...
  for (index = 0; index < length; index++) {
    item = array[index];
    // some code...
  }
  return 'some result';
}
```

`index`，`item`，`length`在函数体的顶部就被声明，但它们却只在尾部时才被调用，那这种方法的有什么问题呢？

在顶部的声明和`for`语句的使用之间，`index`，`item`，`length`都没有初始化，且暴露为`undefined`，它们在整个函数作用域内有一个很长的生命周期，这是不合理的。

更好的方法是将这些变量尽可能地移到它们的使用位置附近：

```js
function someFunc(array) {  
  // some code...
  // some code...
  const length = array.length;
  for (let index = 0; index < length; index++) {
    const item = array[index];
    // some 
  }
  return 'some result';
}
```

`index`，`item`只存在于`for`语句的块级作用域中，在`for`语句外它们没有任何意义。 

`length`也在接近其使用的源代码时才声明。

为什么修改后的版本比初始版本更好？我们看：

- 变量不会暴露为未初始化状态，那你就没有访问到`undefined`的风险。
- 将变量尽可能地移动到它们的使用位置附近会增加代码的可读性。
- 高内聚的代码块在必要时更易于重构和提取到单独的函数中。

### 2.2访问不存在的属性

>When accessing a ***non-existing object property***, JavaScript returns `undefined`.(当访问一个不存在的属性，javascript返回`undefined`)

我们用例子演示一下：

```js
let favoriteMovie = {  
  title: 'Blade Runner'
};
favoriteMovie.actors; // => undefined
```

对象`favoriteMovie`只有一个属性`title`，当使用属性访问器`favoriteMovie.actors`访问一个不存在的对象属性`actors`时将返回`undefined`。

当访问一个不存在的属性时不会抛出错误。但试图从一个不存在的属性值中获取数据时，真正的问题就出现了。这是最常见的`undefined`的相关问题，这反映在众所周知的错误消息中：`TypeError: Cannot read property <prop> of undefined.`

让我们稍微修改前面的代码来说明`TypeError`的抛出：

```js
let favoriteMovie = {  
  title: 'Blade Runner'
};
favoriteMovie.actors[0];  
// TypeError: Cannot read property '0' of undefined
```

`favoriteMovie`没有属性`actors`，所以`favoriteMovie.actors`的值为`undefined`。

因此，访问表达式`favoriteMovie.actors[0]`，即求`undefined`值的第一项，就会抛出`TypeError`异常。

javascript允许访问不存在属性的宽容本质是混乱的来源：属性可能设置了，但也可能没有。绕过这个问题的理想方法是始终定义对象的属性以限制对象。

不幸的是，你通常无法控制你所使用的对象。在不同的场景中，这些对象可能具有不同的属性集，所以你必须手动处理这些情况。

让我们实现一个函数`append(array, toAppend)`，在数组的头部和/或尾部添加一个新元素，`toAppend`参数接受一个带有属性的对象。

- `first`:要添加到数组头部的元素
- `last`: 要添加到数组尾部的元素

该函数返回一个新的数组实例，不改变原数组（即它是一个[纯函数](https://medium.com/javascript-scene/master-the-javascript-interview-what-is-a-pure-function-d1c076bec976#.tyinnrzbi)）。

第一个版本的`append()`，有些天真，看起来像这样：

```js
function append(array, toAppend) {  
  const arrayCopy = array.slice();
  if (toAppend.first) {
    arrayCopy.unshift(toAppend.first);
  }
  if (toAppend.last) {
    arrayCopy.push(toAppend.last);
  }
  return arrayCopy;
}
append([2, 3, 4], { first: 1, last: 5 }); // => [1, 2, 3, 4, 5]  
append(['Hello'], { last: 'World' });     // => ['Hello', 'World']  
append([8, 16], { first: 4 });            // => [4, 8, 16] 
```

因为对象`toAppend`可以省略属性`first`或`last`，所以必须检查这些属性是否存在于`toAppend`中。

如果属性不存在，属性访问器则返回`undefined`，第一个诱惑出现，检查`first`和`last`属性是否存在,是通过验证它们是否为`undefined`。这我们在条件语句`if(toAppend.first){}`和`if(toAppend.last){}`中验证...

*没这么快*，这种方法有个严重的缺陷，`undefined`，以及`false`，`null`，`0`，`NaN`都是[falsy](https://developer.mozilla.org/en-US/docs/Glossary/Falsy)值。

在`append()`的实现中，函数不允许插入假值。

```js
append([10], { first: 0, last: false }); // => [10]
```

`0`和`false`都为*falsy*，因为`if(toAppend.first){}` 和 `if(toAppend.last){}`实际上和*falsy*比较，因此元素并没有插入数组中，函数返回初始数组`[10]`，没有被修改。

下面的提示解释了如何正确地检查属性的存在。

**Tip 3:检查属性是否存在**

幸运的是，javascript有一堆方法验证对象是否存在特殊属性

- `obj.prop!==undefined`:直接和`undefined`作比较
- `typeof obj.prop!=='undefined'`:验证属性值的类型
- `obj.hasOwnProperty('prop')`: 验证属性是否为对象的自身属性
- `'prop' in obj`: 验证属性是否为对象自身或继承的属性

我的建议是使用`in`运算符，它是一个简短且亲切的语法。`in`运算符的存在表明了一个明确的意图，即检查对象是否具有特定的属性，而不访问实际的属性值。

![为清晰的意图而偏爱明确的代码](/images/2017-05-20-7-tips-to-handle-undefined-in-JavaScript/3.png)

`obj.hasOwnProperty('prop')`也是一个不错的选择，它稍微比`in`操作符长，且只验证对象的自身属性。

那两种与`undefined`比较的方法可能有用...但对于我来说，`obj.prop !== undefined` 和 `typeof obj.prop !== 'undefined'`看起来冗余且怪异，而且直接处理`undefined`是一种存疑的做法。

让我们用`in`运算符改善一下`append(array，toAppend)`函数：

```js
function append(array, toAppend) {  
  const arrayCopy = array.slice();
  if ('first' in toAppend) {
    arrayCopy.unshift(toAppend.first);
  }
  if ('last' in toAppend) {
    arrayCopy.push(toAppend.last);
  }
  return arrayCopy;
}
append([2, 3, 4], { first: 1, last: 5 }); // => [1, 2, 3, 4, 5]  
append([10], { first: 0, last: false });  // => [0, 10, false] 
```

当相应的属性存在，`'first' in toAppend` (和 `'last' in toAppend`)为`true`，否则为`false`。

`in`运算符的使用解决了插入*falsy*元素`0`或`false`的问题。现在，插入这些元素在`[10]`的头部和尾部得到了预期的结果`[0, 10, false]`。

**Tip 4: 解构访问对象属性**

当访问一个对象属性时，有时如果属性不存在，则需要指出默认值。

你可以用三元运算符实现它：

```js
const object = { };  
const prop = 'prop' in object ? object.prop : 'default';  
prop; // => 'default' 
```
当要检查的属性数量增加时，三元运算符语法的使用会变得令人生畏。对于每个属性，您必须创建一个新的代码行来处理默认值。这类似的三元运算符的使用是丑陋的。

为了使用一种更优雅的方法，我们需要熟悉一下ES2015的新特征：*对象解构*（object destructuring）。

[对象解构](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment#Object_destructuring)允许将值从对象属性直接提取到变量中，并在属性不存在时设置默认值，是一种避免直接处理`undefined`的方法。

实际上，现在的属性提取看起来很短，更有意义：

```js
const object = {};  
const { prop = 'default' } = object;  
prop; // => 'default'
```

为观察事情的运行，让我们定义了一个有用的函数，它将字符串包含在引号中。`quote(subject, config)`接受第一个参数作为被包含的字符串，第二个参数`config`是一个对象，有这些属性：

- `char`: 引号字符，如`'`（单字符）或`"`（双字符），默认`"`。
- `skipIfQuoted`: boolean值，确认当字符串已经被引用，是否跳过引用，默认是`true`。

应用对象解构的好处，让我们实现`quote()`:

```js
function quote(str, config) {  
  const { char = '"', skipIfQuoted = true } = config;
  const length = str.length;
  if (skipIfQuoted
      && str[0] === char
      && str[length - 1] === char) {
    return str;
  }
  return char + str + char;
}
quote('Hello World', { char: '*' });        // => '*Hello World*'  
quote('"Welcome"', { skipIfQuoted: true }); // => '"Welcome"'
```

一行代码`const { char = '"', skipIfQuoted = true } = config`完成了从`config`中提取属性`char`和`skipIfQuoted`的解构赋值。  
如果`config`对象中没有对应的属性，解构赋值会设置默认值，`char`为`"`，`skipIfQuoted`为`false`(译者注：原文应该是写错了，应该是`true`)。

幸运的是，这个函数还有空间改进。

让我们将解构赋值移到参数部分。且给`config`参数设置一个默认值（一个空对象`{}`）.当默认设置够用时，跳过第二个参数。

```js
function quote(str, { char = '"', skipIfQuoted = true } = {}) {  
  const length = str.length;
  if (skipIfQuoted
      && str[0] === char
      && str[length - 1] === char) {
    return str;
  }
  return char + str + char;
}
quote('Hello World', { char: '*' }); // => '*Hello World*'  
quote('Sunny day');                  // => '"Sunny day"'
```

注意，在函数签名时解构赋值替代了`config`参数。我喜欢这，因为`quote()`短了一行。  
`={}`在解构赋值的右侧，保证了当第二个参数完全没有指定时，如`quote('Sunny day')`，一个空对象能起效。

对象解构是一种功能强大的特性，可以有效地处理对象的属性。我喜欢在访问的属性不存在时指定一个默认值作为返回值。这样，您可以避免和处理`undefined`的问题。


**Tip 5：使用默认属性填充对象**

如果没有像解析赋值那样为每个属性创建一个变量的必要的话，可以用默认值覆盖缺失某些属性的对象。

ES2015的`Object.assign(target, source1, source2, ...)`方法用于将所有可枚举的属性的值从一个或多个源对象复制到目标对象。它将返回目标对象。

例如，你需要访问对象`unsafeOptions`的属性，但它并不总是包含全部属性。

当从`unsafeOptions`访问不存在属性的时候，为避免`undefined`,我们需要做一些调整：

- 定义一个对象`defaults`，它包含所有默认属性。
- 调用`Object.assign({ }, defaults, unsafeOptions)`生成一个新的对象`options`。这个新对象接收`unsafeOptions`的所有属性，缺失的属性从`defaults`中获得。

```js
const unsafeOptions = {  
  fontSize: 18
};
const defaults = {  
  fontSize: 16,
  color: 'black'
};
const options = Object.assign({}, defaults, unsafeOptions);  
options.fontSize; // => 18  
options.color;    // => 'black' 
```

`unsafeOptions`只包含属性`fontSize`，对象`defaults`定义了属性`fontSize`和`color`的默认值。

`Object.assign()`的第一个参数作为目标对象`{}`，目标对象从源对象`unsafeOptions`中获得属性`fontSize`的值，从源对象`default`中获得属性`color`的值，这是因为`unsafeOptions`没有包含`color`。      
枚举源对象的顺序是很重要的：后面的源对象的相同属性会覆盖前者的。

你现在可以安全地访问`options`里的任何属性，包括最初不能在`unsafeOptions`中访问的`options.color`。

幸运的是，存在一种更简单、更轻松的方法来填充对象的默认属性。我建议使用一个新的JavaScript特性(现在在[阶段3](https://tc39.github.io/process-document/))，它允许[在对象初始化器中扩展属性](https://github.com/tc39/proposal-object-rest-spread).

不是调用`Object.assign()`，而是用对象扩展语句，从源对象中复制自身的所有可枚举的属性到目标对象中:

```js
const unsafeOptions = {  
  fontSize: 18
};
const defaults = {  
  fontSize: 16,
  color: 'black'
};
const options = {  
  ...defaults,
  ...unsafeOptions
};
options.fontSize; // => 18  
options.color;    // => 'black'
```

对象初始化器从源对象`defaults`和`unsafeOptions`中扩展属性。指定的源对象的顺序很重要：后面的源对象的属性会覆盖前者的。

用默认的属性值填充一个不完整的对象是一种有效的策略，可以使您的代码更安全、更健壮。无论什么情况，对象总要包含完整的属性集：那`undefined`不会生成。

### 2.3 函数参数

>The function parameters implicitly default to `undefined`.（函数参数隐式默认为`undefined`）

通常，一个用特定数量的参数定义的函数应该用相同数量的参数来调用。在这种情况下，参数得到您所期望的值：

```js
function multiply(a, b) {  
  a; // => 5
  b; // => 3
  return a * b;
}
multiply(5, 3); // => 15 
```

调用`multiply(5, 3)`使得参数`a`和`b`得到相应的值`5`和`3`。乘法按预期计算：`5 * 3 = 15`。

当你在调用时省略一个参数会发生什么事？函数内的参数会变成`undefined`。

让我们稍微改动一下之前的例子，使之只用一个参数调用函数。

```js
function multiply(a, b) {  
  a; // => 5
  b; // => undefined
  return a * b;
}
multiply(5); // => NaN
```

`function multiply(a, b) { }`含有两个参数`a`和`b`。     
`multiply(5) `的调用却只用一个参数执行：所以参数`a`为`5`，参数`b`为`undefined`。

**Tip 6：使用默认参数值**

有时，函数调用并不要求全部参数，你可以简单地为一些没有值的参数设定默认值。

回到之前的例子，让我们做一些改善。如果参数`b`是`undefined`的话，我们为之设定默认值`2`：

```js
function multiply(a, b) {  
  if (b === undefined) {
    b = 2;
  }
  a; // => 5
  b; // => 2
  return a * b;
}
multiply(5); // => 10  
```

函数只使用一个参数调用` multiply(5)`。最初，参数`a`为5，参数`b`为`undefined`。      
利用条件语句验证`b`是否为`undefined`，如果是，`b=2`将赋予默认值。

虽然提供的设置默认值方法是有效，但我不建议直接和`undefined`作比较。它有点冗余和看起来hack。

更好的方法是使用ES2015的新特性：[默认参数值](https://www.sitepoint.com/es6-default-parameters/)。它更简明，且没有直接与`undefined`比较。

修改之前的例子，使之使用默认参数`b`。这看起来更好了。

```js
function multiply(a, b = 2) {  
  a; // => 5
  b; // => 2
  return a * b;
}
multiply(5);            // => 10  
multiply(5, undefined); // => 10  
```

在[函数签名](https://developer.mozilla.org/en-US/docs/Glossary/Signature/Function)中，`b=2`保证了当`b`为`undefined`时，参数能默认为`2`。

ES2015的特性默认参数值直观且有表现能力，总是使用它，为可选参数设定默认值。

### 2.4函数返回值

>*Implicitly, without `return` statement, a JavaScript function returns `undefined`*.（没有`return`语句，javascript函数默认返回`undefined`）

在javascript中，函数没有任何`return`语句，则默认返回`undefined`。

```js
function square(x) {  
  const res = x * x;
}
square(2); // => undefined 
```

函数`square() `没有返回任何计算结果。所以调用函数的结果是`undefined`。

当`return`语句存在，但后面没有任何表达式，将得到一样的结果。

```js
function square(x) {  
  const res = x * x;
  return;
}
square(2); // => undefined 
```

`return;`语句被执行，但它没有返回任何表达式。调用的结果依然是`undefined`。

当然，如果指明`return`后的表达式，那将返回预期值。

```js
function square(x) {  
  const res = x * x;
  return res;
}
square(2); // => 4 
```

现在，函数调用的结果是`2`的平方`4`。

**Tip7：不要相信会自动插入分号**

在JavaScript中，下列语句必须要以分号(`;`)结束：

- 空语句
- `let`， `const`， `var`， `import`， `export`声明
- 表达式语句
- `debugger`语句
- `continue`语句和`break`语句
- `throw`语句
- `return`语句

如果你使用了上述的语句，请确保在句末指明一个分号。

```js
function getNum() {  
  // Notice the semicolons at the end
  let num = 1; 
  return num;
}
getNum(); // => 1
```

在`let`声明和`return`语句的最后，必须强制编写一个分号。

当你不想指明这些分号，会发生什么事？例如，为了减少源文件的大小。

在这种情况下，ECMAScript提供了[自动分号插入](http://www.ecma-international.org/ecma-262/6.0/index.html#sec-automatic-semicolon-insertion)(ASI)机制，它会自动插入你所缺失的分号。

在ASI的帮助下，你可以对之前的例子删除分号：

```js
function getNum() {  
  // Notice that semicolons are missing
  let num = 1
  return num
}
getNum() // => 1 
```

上述的文本是有效的javascript代码，缺失的分号会自动插入。

乍一看，它看起来很有前途，ASI机制可以让你跳过不必要的分号。您可以使JavaScript代码更小、更容易阅读。

这是ASI的一个小而恼人的陷阱，当换行符在`return`和`return`的表达式之间时`return \n expression`，ASI会自动在换行符前插入分号`return; \n expression`。

在函数中有语句`return;`代表什么？函数会返回`undefined`。如果你不是很清楚ASI机制的细节，意外返回的`undefined`是具有误导性的。

例如，我们研究一下调用`getPrimeNumbers()`后的返回结果。

```js
function getPrimeNumbers() {  
  return 
    [ 2, 3, 5, 7, 11, 13, 17 ]
}
getPrimeNumbers() // => undefined 
```

在`return`语句和数组字面量之间存在一个换行符，javascript会自动在`return`语句后插入分号，解析后的代码如下：

```js
function getPrimeNumbers() {  
  return; 
  [ 2, 3, 5, 7, 11, 13, 17 ];
}
getPrimeNumbers(); // => undefined
```

`return ;`语句使得`getPrimeNumbers()`函数返回`undefined`，而不是预期的数组。

通过移除`return`语句和数组字面量之间的换行符可以解决这个问题。

```js
function getPrimeNumbers() {  
  return [ 
    2, 3, 5, 7, 11, 13, 17 
  ];
}
getPrimeNumbers(); // => [2, 3, 5, 7, 11, 13, 17] 
```

我的建议是确切地研究ASI的[工作原理](http://www.bradoncode.com/blog/2015/08/26/javascript-semi-colon-insertion/)来避免这种情况。

当然，绝不在`return`语句和返回表达式之间换行。

### 2.5 `void`运算符

`void expression`对给定的表达式进行求值，并无论结果是什么，都返回`undefined`。

```js
void 1;                    // => undefined  
void (false);              // => undefined  
void {name: 'John Smith'}; // => undefined  
void Math.min(1, 3);       // => undefined 
```

`void`运算符的[一个用例](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/void#JavaScript_URIs)是向期望一个表达式的值是undefined的地方，插入会产生副作用的表达式。

## 3.数组中的`undefined`

当访问超过数组的边界索引的元素时，你会得到一个`undefined`值。

```js
const colors = ['blue', 'white', 'red'];  
colors[5];  // => undefined  
colors[-1]; // => undefined  
```

数组`colors`有3个元素，他们的有效索引是`0`，`1`和`2`。

因为没有数组元素的索引是`-1`和`5`，所以访问`colors[-1]`和`colors[5]`时返回`undefined`。

在javascript中，你可能遇到过所谓的稀疏数组。这是有缺口的数组，即一些索引的元素没有定义。

当在稀疏数组中访问一个缺口(也就是空隙)时，你也会得到`undefined`。

下面的例子生成了稀疏数组，并尝试访问它们的空隙:

```js
const sparse1 = new Array(3);  
sparse1;       // => [<empty slot>, <empty slot>, <empty slot>]  
sparse1[0];    // => undefined  
sparse1[1];    // => undefined  
const sparse2 = ['white',  ,'blue']  
sparse2;       // => ['white', <empty slot>, 'blue']  
sparse2[1];    // => undefined  
```

`sparse1`通过一个数字参数的数组构造函数的调用生成。它有3个空隙。

`sparse2`通过数组字面量生成，它缺少第二个元素。

当使用数组时，为避免获取到`undefined`，请确保使用有效的数组索引，并避免创建稀疏数组.

## 4.`undefined`和`null`的区别

一个合理的问题出现了:`undefined`和`null`之间的主要区别是什么?两个特殊值都表示一个空状态。

主要的区别是，`undefined`代表一个没有初始化的变量的值，`null`表示有意缺失的对象。

让我们在一些例子中探索这些区别：

```js
let number;  
number; // => undefined 
```

变量`number`是`undefined`，它清楚地表示一个未初始化的变量。

未初始化的对象属性被访问时，同样未初始化的概念也会发生。

```js
const obj = { firstName: 'Dmitri' };  
obj.lastName; // => undefined
```

因为对象`obj`中不存在属性`lastName`，Javascript正确地将`obj.lastName `定为`undefined`。

在其他情况下，您知道一个变量期望是一个对象或一个函数会返回一个对象。但是出于某种原因，你不能实例化这个对象。在这种情况下，`null`是丢失对象的一个有意义的指示器。

例如，函数`clone()`是用于克隆普通的对象，它预期返回一个对象：

```js
function clone(obj) {  
  if (typeof obj === 'object' && obj !== null) {
    return Object.assign({}, obj);
  }
  return null;
}
clone({name: 'John'}); // => {name: 'John'}  
clone(15);             // => null  
clone(null);           // => null 
```

然而，函数`clone()`可能会被非对象参数调用，像`5`或`null`（通常是原始值，`null`或`undefined`）.在这种情况下不可能生成一个克隆，因此它有理由返回`null` —— 缺失对象的指示器。

`typeof`操作符能对这两个值作出区别：

```js
typeof undefined; // => 'undefined'  
typeof null;      // => 'object'
```

[严格比较运算符](https://rainsoft.io/the-legend-of-javascript-equality-operator/#theidentityoperator)`===`能正确地区分`undefined`和`null`.

```javacript
let nothing = undefined;  
let missingObject = null;  
nothing === missingObject; // => false  
```

## 5.总结

`undefined`的存在是JavaScript的宽松本性的结果。它允许这些用法：

- 未初始化变量
- 不存在的对象属性或方法
- 访问边界索引的数组元素
- 不返回任何结果的函数的调用结果

通常，直接与`undefined`的比较是一种不好的做法，因为您可能依赖于上面提到的一种允许但不鼓励的实践。

一个有效的策略是尽可能减少代码中`undefined`关键字的出现。与此同时，要记住它的潜在出现，并通过应用好习惯来防止它的发生：

- 减少未初始化变量的使用
- 使变量生命周期缩短，并接近其使用源
- 无论如何，尽可能给变量赋值
- 支持`const`，否则使用`let`
- 为无关紧要的函数参数使用默认值
- 验证属性是否存在，或者用默认属性填充不安全的对象
- 避免使用稀疏数组

你对javascript中的`undefined`有什么看法，请在下面的评论中畅所欲言。



原文：[7 tips to handle undefined in JavaScript](https://rainsoft.io/7-tips-to-handle-undefined-in-javascript/)

译者：cynthia

作者：[Dmitri Pavlutin](https://rainsoft.io/author/dmitri-pavlutin/)