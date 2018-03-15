---
title: ES6开发过程中的7个小技巧
date: 2018-03-14 12:00
category: JavaScript
tags: [web前端, es6, javascript]
author: Elly
---

![](https://cdn-images-1.medium.com/max/800/1*xmqGcZXL4t7mJoG1SBvErA.jpeg)

继原来的 [JavaScript hacks](https://hackernoon.com/javascript-hacks-for-hipsters-624d50c76e8e)之后，这儿有了些新的点子。在2018年码JavaScript其实是件非常有趣的事情。

<!-- more -->

### Hack #1 — 交换变量

用数组解构交换值。

```js
let a = 'world', b = 'hello';
[a, b] = [b, a];
console.log(a); // hello
console.log(b); // world

// Yes, it's magic!
```

### Hack #2 — Async/Await解构

数组解构非常好用，结合`async/await`去实现一个复杂的流程变得很简单。

```js
const [user, account] = await Promise.all([
    fetch('/user'),
    fetch('/account')
]);
```

### Hack #3 — 调试

很多人喜欢用`console.log`来调试，对这些人来说，下边的例子就是福音（是的，还有`console.table`）：

```js
const a = 5, b = 6, c = 7;
console.log({a, b, c});

// 输出一个对象：
// {
//    a: 5,
//    b: 6,
//    c: 7
// }
```

### Hack #4 — 一行流

对于数组的运算，语法可以非常的紧凑。

```js
// 找最大值
const max = (arr) => Math.max(...arr);
max([123, 321, 32]);  // 321

// 数组求和
const sum = (arr) => arr.reduce((a, b) => (a + b), 0);
sum([1, 2, 3, 4]); // 10
```

### Hack #5 — 数组链接

`spread operator`可以用来代替`concat`：

```js
const one = ['a', 'b', 'c'];
const two = ['d', 'e', 'f'];
const three = ['g', 'h', 'i'];

// 旧方法#1
const result = one.concat(two, three);
// 旧方法#2
const result = [].concat(one, two, three);
// 新方法
const result = [...one, ...two, ...three];
```

### Hack #6 — 复制

轻松克隆数组和对象：

```js
const obj = {...oldObj};
const arr = [...oldArr];
```

注意：这会创建一个浅拷贝。

### Hack #7 — 命名参数

通过解构使函数和函数调用更易读：

```js
const getStuffNotBad = (id, force, verbose) => {
    // ...do stuff
};

const getStuffAwesome = ({ id, name, force, verbose }) => {
  // ...do stuff
};

// 代码库中的其他地方... WTF是true，true吗？
getStuffNotBad(150, true, true)

// 代码库中的其他位置... I ❤ JS!!!
getStuffAwesome({ id: 150, force: true, verbose: true })
```

原文：[7 Hacks for ES6 Developers](https://medium.com/dailyjs/7-hacks-for-es6-developers-4e24ff425d0b)

作者：[Tal Bereznitskey](https://medium.com/@ketacode)

译者：[Elly](https://futu.im/author/Elly/)
