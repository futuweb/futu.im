---
title: 【译】使用async/await玩函数式编程
date: 2017-05-06 14:00
category: 翻译
tags: [aysnc/await]
author: Jin
---

[Async/await](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function)使得像[`for`循环，`if`表达式和`try/catch`等这样的块级命令结构可以很容易的结合异步行为](http://thecodebarbarian.com/common-async-await-design-patterns-in-node.js.html)。不同的是，它对功能结构的处理与`forEach`，`map`，`reduce`和`filter`等函数不同。`async`异步功能结构的行为是乎令人费解。这篇文章，我将向你展示在JavaScript的内置数组函数封装为`async`异步函数时遇到的一些陷阱以及如何解决它。

> 注意：以下的代码只在Node v.7.6.0+版本测试通过，以下例子只供参考和学习。我不建议在生产中使用它。

<!-- more -->

## 动机和 `forEach`
`forEach`会同步的顺序的为数组的每一个元素都执行一次函数。例如，下面的JavaScript代码会打印`[0-9]`：

```js
function print(n) {
  console.log(n);
}

function test() {
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].forEach(print);
}

test();
```

不幸的是，异步函数就变得微妙起来。以下JavaScript代码会反序输出`[0-9]`：

```js
async function print(n) {
  // Wait 1 second before printing 0, 0.9 seconds before printing 1, etc.
  await new Promise(resolve => setTimeout(() => resolve(), 1000 - n * 100));
  // Will usually print 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 but order is not strictly
  // guaranteed.
  console.log(n);
}

async function test() {
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].forEach(print);
}

test();
```

尽管2个函数都是异步的，Node.js不会等到第一个`print()`执行完成后再去执行下一个！
可以就只使用一个`await`吗？看看效果：

```js
async function test() {
  // SyntaxError: Unexpected identifier
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].forEach(n => { await print(n); });
}
```

不能像上面只使用一个`await`，不然你就是[Star Fox](http://knowyourmeme.com/memes/i-can-t-let-you-do-that-starfox)，这样写有语法问题的，因为`await`必须在`async`当前代码作用域内。在这一点上，你可以放弃,改为使用[非标准`Promise.series()`函数](https://www.npmjs.com/package/promise-series)。假如你意识到`async`函数只是返回`Promise`函数，那么你可以在`.reduce()`中使用`Promise`的链式调用来实现一个顺序的`forEach()`。

```js
async function print(n) {
  await new Promise(resolve => setTimeout(() => resolve(), 1000 - n * 100));
  console.log(n);
}

async function test() {
  // This is where the magic happens. Each `print()` call returns a promise,
  // so calling `then()` chains them together in order and prints 0-9 in order.
  await [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].
    reduce((promise, n) => promise.then(() => print(n)), Promise.resolve());
}

test();
```

你完全可以把这个函数改成名为`forEachAsync`的函数：

```js
async function print(n) {
  await new Promise(resolve => setTimeout(() => resolve(), 1000 - n * 100));
  console.log(n);
}

Array.prototype.forEachAsync = function(fn) {
  return this.reduce((promise, n) => promise.then(() => fn(n)), Promise.resolve());
};

async function test() {
  await [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].forEachAsync(print);
}

test();
```

## `map()`和`filter()`的链式调用
JavaScript有一个很大的优势那就是数组方法是可以链式调用的。下面的代码主要做的事是，根据你提供的`id`数组分别到数据库`db1`和`db2`查询到你想要的对应`id`的文本内容，过滤掉`db2`数据库的部分，然后把`db1`剩下的部分保存到`db2`数据库。虽然希望你乎略业务功能，但是里面还是有很多的中间值。

```js
const { MongoClient } = require('mongodb');

async function copy(ids, db1, db2) {
  // Find all docs from db1
  const fromDb1 = await db1.collection('Test').find({ _id: { $in: ids } }).sort({ _id: 1 }).toArray();
  // And db2
  const fromDb2 = await db2.collection('Test').find({ _id: { $in: ids } }).sort({ _id: 1 }).toArray();

  // Find all docs from db1 that aren't in db2
  const toInsert = [];
  for (const doc of fromDb1) {
    if (!fromDb2.find(_doc => _doc._id === doc._id)) {
      toInsert.push(doc);
      console.log('Insert', doc);
    }
  }
  // And insert all of them
  await db2.collection('Test').insertMany(toInsert);
}

async function test() {
  const db1 = await MongoClient.connect('mongodb://localhost:27017/db1');
  const db2 = await MongoClient.connect('mongodb://localhost:27017/db2');
  await db1.dropDatabase();
  await db2.dropDatabase();

  const docs = [
    { _id: 1 },
    { _id: 2 },
    { _id: 3 },
    { _id: 4 }
  ];
  await db1.collection('Test').insertMany(docs);
  // Only insert docs with _id 2 and 4 into db2
  await db2.collection('Test').insertMany(docs.filter(doc => doc._id % 2 === 0));

  await copy(docs.map(doc => doc._id), db1, db2);
}

test();
```

函数体希望做到尽可能的干净——你只需要这样做`ids.map().filter().forEach()`，但是`map()`，`filter()`和`each()`中的任何一个都需要封装为异步函数。我们上面已经实现过`forEachAsync()`，照葫芦画瓢，实现`mapAsync()`和`filterAsync()`应该不会很难。

```js
Array.prototype.mapAsync = function(fn) {
  return Promise.all(this.map(fn));
};

Array.prototype.filterAsync = function(fn) {
  return this.mapAsync(fn).then(_arr => this.filter((v, i) => !!_arr[i]));
};
```

然而，链式调用却会出现问题。你怎么同时链式调用`mapAsync()`和`filterAsync()`？你可能会考虑用`then()`，但是这样调用不够整洁。相反，你应该创建一个`AsyncArray`的类并且接受和保存一个`Promise`实例，这个`Promise`实例最终会返回一个数组。并且在这个类添加上我们创建的`mapAsync`，`filterAsync`和`forEachAsync`方法：

```js
class AsyncArray {
  constructor(promise) {
    this.$promise = promise || Promise.resolve();
  }

  then(resolve, reject) {
    return new AsyncArray(this.$promise.then(resolve, reject));
  }

  catch(reject) {
    return this.then(null, reject);
  }

  mapAsync(fn) {
    return this.then(arr => Promise.all(arr.map(fn)));
  }

  filterAsync(fn) {
    return new AsyncArray(Promise.all([this, this.mapAsync(fn)]).then(([arr, _arr]) => arr.filter((v, i) => !!_arr[i])));
  }

  forEachAsync(fn) {
    return this.then(arr => arr.reduce((promise, n) => promise.then(() => fn(n)), Promise.resolve()));
  }
}
```

通过使用`AsyncArray`，就可以链式的调用`mapAsync()`，`filterAsync()`和`forEachAsync()`，因为每个方法都会返回`AsyncArray`本身。现在我们再来看看上面的例子的另一种实现：

```js
async function copy(ids, db1, db2) {
  new AsyncArray(Promise.resolve(ids)).
    mapAsync(function(_id) {
      return db1.collection('Test').findOne({ _id });
    }).
    filterAsync(async function(doc) {
      const _doc = await db2.collection('Test').findOne({ _id: doc._id });
      return !_doc;
    }).
    forEachAsync(async function(doc) {
      console.log('Insert', doc);
      await db2.collection('Test').insertOne(doc);
    }).
    catch(error => console.error(error));
}

async function test() {
  const db1 = await MongoClient.connect('mongodb://localhost:27017/db1');
  const db2 = await MongoClient.connect('mongodb://localhost:27017/db2');
  await db1.dropDatabase();
  await db2.dropDatabase();

  const docs = [
    { _id: 1 },
    { _id: 2 },
    { _id: 3 },
    { _id: 4 }
  ];

  await db1.collection('Test').insertMany(docs);
  // Only insert docs with _id 2 and 4 into db2
  await db2.collection('Test').insertMany(docs.filter(doc => doc._id % 2 === 0));

  await copy(docs.map(doc => doc._id), db1, db2);
}

test();
```

## 封装 `reduce()`
现在我们已经封装了`mapAsync()`，`filterAsync()`和`forEachAsync()`，为什么不以相同的方式实现`reduceAsync()`？

```js
reduceAsync(fn, initial) {
    return Promise.resolve(initial).then(cur => {
      return this.forEachAsync(async function(v, i) {
        cur = await fn(cur, v, i);
      }).then(() => cur);
    });
  }
```

看看`reduceAsync()`如何使用：

```js
async function test() {
  const db = await MongoClient.connect('mongodb://localhost:27017/test');
  await db.dropDatabase();

  const docs = [
    { _id: 1, name: 'Axl' },
    { _id: 2, name: 'Slash' },
    { _id: 3, name: 'Duff' },
    { _id: 4, name: 'Izzy' },
    { _id: 5, name: 'Adler' }
  ];

  await db.collection('People').insertMany(docs);

  const ids = docs.map(doc => doc._id);

  const nameToId = await new AsyncArray(Promise.resolve(ids)).
    reduceAsync(async function (cur, _id) {
      const doc = await db.collection('People').findOne({ _id });
      cur[doc.name] = doc._id;
      return cur;
    }, {});
  console.log(nameToId);
}

test();
```

到这里，我们已经可以异步的使用`map()`，`filter()`，`reduce()`和`forEach()`函数，但是需要自己进行封装函数并且里面的`Promise`调用链很复杂。我很期待，有一个人能写出一个`Promise`版的库来无缝操作数组。函数式编程使得同步操作数组变得清洁和优雅，通过链式调用省掉了很多不必要的中间值。添加帮助库，操作`Promise`版的数组确实有点让人兴奋。

> `Async/Await`虽然用处非常大，但是如果你使用的是Node.js 4+或者是Node.js 6+ 长期稳定版（[Node.js 8 延迟发布](https://github.com/nodejs/CTC/issues/99)），引入[co](http://npmjs.org/package/co)你仍然可以在使用类似的函数式编程模式中使用ES6 generator。如果你想深入研究`co`并且想自己写一个类似的库，你可以点击查看我写的这本书：[《The 80/20 Guide to ES2015 Generators》](http://es2015generators.com/)


原文：[http://thecodebarbarian.com/basic-functional-programming-with-async-await.html](http://thecodebarbarian.com/basic-functional-programming-with-async-await.html)

译者：[Jin](https://github.com/Yi-love)

作者：[Valeri Karpov](https://github.com/vkarpov15)






