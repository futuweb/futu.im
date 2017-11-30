---
title: 浮点数计算引发的血泪史——以此为戒
date: 2017-11-30 21:00
category: JavaScript
tags: [number,float,JavaScript]
author: Jin
---

最近遇到很头疼的一件事，比较2个浮点数的大小，可能想想应该很简单。不就一行代码的事吗？但是也就是因为一行代码引发了不可想象的后果。

实际的开发中，难免会进行浮点数进行计算和判断大小。然后通过条件`if`语句执行相关的操作。

举个栗子，一个简单的比较2个浮点数的大小：

```js
function testAB(){
  let a = 34.16;
  let b = 34.16;

  if( a === b ){
    return console.log('a === b');
  }
  return console.log('a !== b');
}
testAB();
```

上面的一直会执行`if`语句里面的console，输出`a === b`，这是确信无疑的。

那下面这个，还能拍着胸脯说是相等的吗？

<!-- more -->

```js
function testAB(){
  let a = 34.17;
  let b = 34.16;

  if( (a - 0.01) === b ){
    return console.log('a === b');
  }
  return console.log('a !== b');
}
testAB();
```

答案很显然，这里会输出`a !== b`。

![float_error](/images/2017-11-30-javascript-float-fault/1130_02.jpg)

## 为什么 `34.17-0.01 !== 34.16`？
有时候就是这样，所想的和真正看到的完全是不一样的。难道JavaScript的数学是体育老师教的吗？然而并不是。

问题还得从JavaScript语言本身找：

* 第一，因为十进制浮点数在计算的时候都会被转换成二进制，但由于浮点数用二进制表达时是无穷的。所以2个无穷的数相加，得到的数也是无穷的。
* 第二，IEEE 754标准的64位双精度浮点数的小数部分最多支持53位二进制位。意味着2个浮点数相加的结果只会保留53位二进制位，53位后面的都会被切掉。


由于上面的2个原因，最终导致计算出来的结果被转换成十进制数的时候，其实是一个近似值（因为浮点数二进制53位以后的部分都被切掉了）。

所以：

```js
34.17 - 0.01 !== 34.16;
0.1 + 0.2 !== 0.3;
```

详细解释可查看 [这篇文章](http://www.css88.com/archives/7340)。


## 解决浮点数问题
问题知道了，现在要做的是正确的解决问题。


首先想到的是将计算逻辑移到`if`语句之外，这看起里会和第一个正确的比较很类似。

```js
function testAB(){
  let a = 34.17;
  a = a - 0.01;
  let b = 34.16;

  if( a === b ){
    return console.log('a === b');
  }
  return console.log('a !== b');
}
testAB();
```

现实是残酷的，这是行不通的。这只能证明一点，精度的计算和位置无关。也就是说，与`a - 0.01` 表达式放置的位置无关。

### 【方案1】toFixed方法

这里考虑到只保留2位小数。所以使用`toFixed(2)`方法，该方法会进行四舍五入，然后转成字符串。调用完`toFixed`方法后，最后再将字符串转为Number类型（JavaScript里面浮点数也算Number类型）再比较。


```js
function testAB(){
  let a = 34.17;
  a = a - 0.01;
  let b = 34.16;

  if( +(a.toFixed(2)) === b ){
    return console.log('a === b');
  }
  return console.log('a !== b');
}
testAB();
```

这确实得到了一正确结果。但是，说实话我对使用`toFixed`这个并不赞同。


#### 题外话

这里其实，还有一出戏。是这样的，一般数据库不会保存浮点数。都会把浮点数转换成整数保存。

例如这个价格`200.67`这个值可能数据库会保持为`200670`。

假如按上面的`toFixed(2)`方法取两位小数然后`*1000`进行保存，会得到正确的结果。

```js
let price = 200.67;
price = +(price.toFixed(2)) * 1000;
```

但是，凡是总有例外。

有图有真相：

![toFixed](/images/2017-11-30-javascript-float-fault/1130_01.jpg)

从此，脑瓜子一万头羊驼跑过。。。。。

### 【方案二】Math.round函数
这个方法是会对浮点数进行四舍五入，保存为整数进行比较。对于保留2位小数的浮点数。只需要`*100`然后取整比较就可以。

```js
function testAB(){
  let a = 34.17;
  a = a - 0.01;
  let b = 34.16;

  if( Math.round(a * 100)  === Math.round(b * 100) ){
    return console.log('a === b');
  }
  return console.log('a !== b');
}
testAB();
```

可能会产生误解，例如存在的问题就是`Math.round(23.562 * 100) > Math.round(23.56)`，这显然是错误的。

所以这里的前提条件就是必须保证比较的浮点数的位数要一样。

依此类推，3位小数的可以`*1000`。

推荐使用`Math.round`。

## 总结
切莫眼高手低，马失前蹄。


作者：[Jin](https://github.com/Yi-love)