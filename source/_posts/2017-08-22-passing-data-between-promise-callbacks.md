---
title: 【译】在Promise回调之间传值的方法
date: 2017-08-22 13:00:00
categories: [前端]
tags: [JavaScript,Promise,异步]
author: TooBug
---

在基于 Promise 编写的代码中，经常会有很多回调函数，它们都有各自的变量作用域。那么如果我们需要在这些回调函数之间共享数据，要怎么办呢？本文总结了一些方法。

## 1. 问题

下面的代码演示了使用 Promise 回调时经常碰到的一类问题：变量`connection`（A）在一个作用域中存在，但是需要被另一个作用域访问（B和C）：

```javascript
db.open()
.then(connection => { // (A)
    return connection.select({ name: 'Jane' });
})
.then(result => {
    // Process result
    // Use `connection` to make more queries (B)
})
···
.catch(error => {
    // handle errors
})
.finally(() => {
    connection.close(); // (C)
});
```

在这段代码中，我们使用了 ES 规范中的`Promise.prototype.finally()`。它提供了和`try`语句的`finally`分支类似的功能。

<!-- more -->

## 2. 解决方法：副作用

第一种解决方法是将要共享的值`connection`存入这些回调函数的上级作用域（A）：

```javascript
let connection; // (A)
db.open()
.then(conn => {
    connection = conn;
    return connection.select({ name: 'Jane' });
})
.then(result => {
    // Process result
    // Use `connection` to make more queries (B)
})
···
.catch(error => {
    // handle errors
})
.finally(() => {
    connection.close(); // (C)
});
```

因为`connection`的定义在回调函数的外面，所以 B 和 C 都能访问它。

## 3. 解决方法：嵌套作用域

上面例子的同步版本，看起来是这样的：

```javascript
try {
    const connection = await db.open();
    const result = await connection.select({ name: 'Jane' });
    ···
} catch (error) {
    // handle errors
} finally {
    connection.close();
}
```

同步版本的代码中，使得`connection`在函数内部可用的方法是将声明提前到上级作用域中：

```javascript
const connection = await db.open();
try {
    const result = await connection.select({ name: 'Jane' });
    ···
} catch (error) {
    // handle errors
} finally {
    connection.close();        
}
```

> 译注：`try...catch`中，`catch`和`finally`可以共享`try`中的变量，所以此处将`connection`移到外部定义，对于同步代码来说，是非必需的。

我们可以在 Promise 中做同样的事情——将 Promise 链起来：

```javascript
db.open() // (A)
.then(connection => { // (B)
    return connection.select({ name: 'Jane' }) // (C)
    .then(result => {
        // Process result
        // Use `connection` to make more queries
    })
    ···
    .catch(error => {
        // handle errors
    })
    .finally(() => {
        connection.close();
    });    
})
```

这段代码有两个 Promise 链：

- 第一个开始于 A ，`connection`是`db.open()`的结果
- 第二个被包裹在 B 处的`.then()`中，从 C 处开始，注意 C 处的`return`将两个 Promise 连接起来了

你可能已经注意到了，不管是同步版本还是异步版本的代码，如果`db.open()`同步抛出一个错误，这个错误将不能被`catch`处理。有[一篇专门的关于 `Promise.try()`](http://2ality.com/2017/08/promise-try.html)将演示在异步版本中如何修复这个问题。在同步版本的代码中，你可以将`db.open()`移入`try`中即可。

## 4. 解决方法：返回多值

下面将演示另一种在回调函数之间传值的方法。但是它不是任何时候都能工作，尤其是你不能将它用于前面演示的数据库操作中。我们来看一个它能工作的例子。

我们面临一个相似的问题：在 Promise 链中，需要将`intermediate`的值从 A 处的回调传递到 B 处的回调。

```javascript
return asyncFunc1()
.then(result1 => { // (A)
    const intermediate = ···;
    return asyncFunc2();
})
.then(result2 => { // (B)
    console.log(intermediate);
    ···
});
```

我们使用`Promise.all()`从第一个回调函数中传递多个值给第二个回调函数，从而解决这个问题：

```javascript
return asyncFunc1()
.then(result1 => {
    const intermediate = ···;
    return Promise.all([asyncFunc2(), intermediate]); // (A)
})
.then(([result2, intermediate]) => {
    console.log(intermediate);
    ···
});
```

注意，在 A 处返回一个数组是不行的，因为`.then()`会获得一个Promise，一个值。使用`Promise.all()`时，内部会使用`Promise.resolve()`来保证数组元素都是 Promise ，并且在它们全部被满足（fulfill）时，将它们的值组成一个数组传递给作为下一个回调的参数。

这种方法的局限性在于你不能传值到`.catch()`或者`.finally()`回调中。

最后，这种方法还可以在`Promise.all()`中传入一个对象（不仅仅可以是数组），这样每一个返回的值都有一个标签。

> 译注：`Promise.all()`目前并不支持传入对象，作者应该是希望支持这样一种使用方式。

## 5. 相关链接

- 在 Exploring ES6 的"[Promises for asynchronous programming](http://exploringjs.com/es6/ch_promises.html)"章节，有关于 Promise 链的更多内容
- [ES提案：`Promise.prototype.finally()`](http://2ality.com/2017/07/promise-prototype-finally.html)
- [ES提案：`Promise.try()`](http://2ality.com/2017/08/promise-try.html)

作者：Dr. Axel Rauschmayer

原文链接：<http://2ality.com/2017/08/promise-callback-data-flow.html>
