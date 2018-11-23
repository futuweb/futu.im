---
title: 【译】异步迭代器及生成器
subtitle: 异步迭代器和常规迭代器的工作方式非常相似。
cover: /images/2017-04-28-async-iterators-and-generators/cover.png
date: 2017-04-28 10:30
categories: [前端]
author: Linda
---
Chrome，Edge，Safari都支持了流式获取，有点像这样：
	
```js
async function getResponseSize(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  let total = 0;

  while (true) {
	const {done, value} = await reader.read();
	if (done) return total;
	total += value.length;
  }
}
```

多亏有了async函数（如果不熟悉，这里有个[说明](https://developers.google.com/web/fundamentals/getting-started/primers/async-functions)），使得这段代码的可读性不错。但是，还是有点难以理解。

值得庆幸的是，异步迭代器很快会到来，可以使得代码看上去更整洁：

```js
async function getResponseSize(url) {
  const response = await fetch(url);
  let total = 0;

  for await (const chunk of response.body) {
	total += chunk.length;
  }
  return total;
}
```

异步迭代器在Chrome Canary里面可用，启动时需要加上标志位`--js-flags=--harmony-async-iteration`。下面就看下怎么运行的，可以怎么使流迭代起来。

<!-- more -->

## Async iterators


异步迭代器和常规迭代器的工作方式非常相似，但是异步迭代器涉及promise:
    
```js
async function example() {
  // Regular iterator:
  const iterator = createNumberIterator();
  iterator.next(); // Object {value: 1, done: false}
  iterator.next(); // Object {value: 2, done: false}
  iterator.next(); // Object {value: 3, done: false}
  iterator.next(); // Object {value: undefined, done: true}

  // Async iterator:
  const asyncIterator = createAsyncNumberIterator();
  const p = asyncIterator.next(); // Promise
  await p;// Object {value: 1, done: false}
  await asyncIterator.next(); // Object {value: 2, done: false}
  await asyncIterator.next(); // Object {value: 3, done: false}
  await asyncIterator.next(); // Object {value: undefined, done: true}
}
```

两种迭代器都有一个.return()方法，这个方法通知迭代器提早结束，并且做它需要做的清理工作。

## 迭代器&循环


直接使用迭代器对象的情况十分少见，通常在循环上用更合适，它是在幕后使用迭代器对象的：
    
```js
async function example() {
      // Regular iterator:
      for (const item of thing) {
    	// …
      }
    
      // Async iterator:
      for await (const item of asyncThing) {
    	// …
      }
}
```

for-of循环会通过调用`thing[Symbol.iterator]`取到对应的迭代器。而for-await循环在`asyncThing[Symbol.asyncIterator]`已经定义的情况下会通过调用它取到对应的迭代器，否则会回落到`asyncThing[Symbol.iterator]`。

一旦`asyncIterator.next()` resolve，for-await 会给出每个值。因为这里涉及了awaiting promise，在迭代过程中，主线程上其他事情可以执行。直到正进行的迭代完成，`asyncIterator.next()`才会被下个条目调用。这意味着要按顺序获得条目，并且循环的迭代不会重叠。

for-await可以回落到`Symbol.iterator`非常cool。这意味着它可作用于像数组这种常规可迭代的对象：
    
```js
async function example() {
  const arrayOfFetchPromises = [
    fetch('1.txt'),
    fetch('2.txt'),
    fetch('3.txt')
  ];

  // Regular iterator:
  for (const item of arrayOfFetchPromises) {
	console.log(item); // Logs a promise
  }

  // Async iterator:
  for await (const item of arrayOfFetchPromises) {
	console.log(item); // Logs a response
  }
}
```

在这种情况下，for-await从数组中取每个条目，并且等待它resolve。可以得到第一个响应，即使第二个响应仍然没有准备好，但是总是会按照正确的顺序获得响应。

## 异步生成器：创建你自己的异步迭代器


就像可以使用生成器来创建迭代器工厂一样，可以使用异步生成器来创建异步迭代器工厂。
异步生成器是一系列异步函数和生成器的混合体。假设我们想要生成一个返回随机数的迭代器，但是那些随机数来自一个web服务：

```js
// Note the * after "function"
async function* asyncRandomNumbers() {
  // This is a web service that returns a random number
  const url = 'https://www.random.org/decimal-fractions/?num=1&dec=10&col=1&format=plain&rnd=new';

  while (true) {
	const response = await fetch(url);
	const text = await response.text();
	yield Number(text);
  }
}
```

这个迭代器不会自然的结束--会一直获取数字。庆幸的是，可以用`break`来结束：

```js
async function example() {
  for await (const number of asyncRandomNumbers()) {
    console.log(number);
    if (number > 0.95) break;
  }
}
```

[在线实例](https://jsbin.com/folotu/edit?js,console "在线示例")  

像常规的生成器一样，可以yield值，但和常规生成器不同的是，可以await promise。

和所有的for循环一样，可以在你想要break的时候break。这致使循环调用`iterator.return()`，会导致生成器会像在现在的（或下一个）yield后面有个return声明一样运行。

用web service来获取随机数是一个有点没意义的例子，可以看一些更实际的东西。

## 使流迭代起来


像我在文章开头提到的那样，很快可以这样做：
	
```js
async function example() {
  const response = await fetch(url);

  for await (const chunk of response.body) {
	// …
  }
}
```

...但是还没有被规范化。那么，我们来实现一个迭代流的异步迭代器吧！它有如下特性：

1.在流上加个锁，这样当我们在迭代的时候，没有其他东西可以使用流。

2.流的值可以被yield

3.完成之后释放掉锁。

释放锁很重要。如果开发者中断了循环，我们希望可以从中断的地方继续使用流。所以：
    
```js
async function* streamAsyncIterator(stream) {
  // Get a lock on the stream
  const reader = stream.getReader();

  try {
    while (true) {
      // Read from the stream
      const {done, value} = await reader.read();
      // Exit if we're done
      if (done) return;
      // Else yield the chunk
      yield value;
	}
  }
  finally {
	reader.releaseLock();
  }
}
```

这里的finally从句相当重要。如果用户在循环中跳出，会导致我们的异步生成器在现在的（或下一个）yield点返回。如果这情况发生了，我们仍然想解reader上的锁，`finally`是唯一可以在`return`之后执行的东西。

就是这样！现在可以：
	
```js
async function example() {
  const response = await fetch(url);

  for await (const chunk of streamAsyncIterator(response.body)) {
	// …
  }
}
```

[在线实例](https://jsbin.com/codapog/edit?js,console "在线示例") 

解锁意味着你在循环之后仍然可以控制流。假设我们想要在HTML spec里面找到第一个“J”字节的位置：

```js
async function example() {
  const find = 'J';
  const findCode = find.codePointAt(0);
  const response = await fetch('https://html.spec.whatwg.org');
  let bytes = 0;

  for await (const chunk of streamAsyncIterator(response.body)) {
    const index = chunk.indexOf(findCode);
    
    if (index != -1) {
      bytes += index;
      console.log(`Found ${find} at byte ${bytes}.`);
      break;
    }
    
    bytes += chunk.length;
  }

  response.body.cancel();
}
```

[在线实例](https://jsbin.com/gucesat/edit?js,console "在线示例")

这里当我们找到一个匹配的时候，跳出了循环。由于`streamAsyncIterator`在流上释放了锁，我们可以取消剩下的部分，来节省带宽。

注意这里没有把`streamAsyncIterator` 赋值给`ReadableStream.prototype[Symbol.asyncIterator]`。如果这样做的话，我们是可以直接迭代流，但是也弄脏了不属于我们的对象。如果以后流天然支持异步迭代，且其规范化的实现与我们的实现不同，那么我们将会遇到奇怪的 bug。

## 更简洁的实现


你不需要用异步生成器来生成异步可迭代对象，你可以自己生成迭代器对象。这是[Domenic Denicola](https://twitter.com/domenic/)所做的事情。这里是他的实现：

```js
function streamAsyncIterator(stream) {
  // Get a lock on the stream:
  const reader = stream.getReader();

  return {
    next() {
      // Stream reads already resolve with {done, value}, so
      // we can just call read:
      return reader.read();
    },
    return() {
      // Release the lock if the iterator terminates.
      return reader.releaseLock();
    },
    // for-await calls this on whatever it's passed, so
    // iterators tend to return themselves.
    [Symbol.asyncIterator]() {
      return this;
    }
  };
}
```

可以在Chrome Canary里面运行上面所有的例子，启动的时候要加标志位`--js-flags=--harmony-async-iteration`。如果现在想把这些用于生产环境，Babel可以做转换。
    
原文：[https://jakearchibald.com/2017/async-iterators-and-generators/](https://jakearchibald.com/2017/async-iterators-and-generators/)

译者：[Linda](https://github.com/LindaWhite)

作者：[Jake](https://jakearchibald.com/2017/async-iterators-and-generators/)

