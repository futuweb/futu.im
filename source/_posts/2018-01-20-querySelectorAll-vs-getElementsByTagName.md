---
title: 简单讨论 querySelectorAll Vs getElementsByTagName 区别
subtitle: 虽然表面上看没有很大区别，但是往往现实却并非如此。
cover: /images/2018-01-20-querySelectorAll-vs-getElementsByTagName/cover.png
date: 2018-01-20 12:00
categories: [前端]
tags: [web前端,html,document,javascript]
author: Jin
---


日常开发中，有时候会用到`querySelectorAll` 或者 `getElementsByTagName` 从DOM树中获取元素集合。虽然表面上看没有很大区别，但是往往现实却并非如此。

| \ | querySelectorAll | getElementsByTagName  |
| --- | --- | --- |
| 遍历方式 | 深度优先 | 深度优先 |
| 返回值类型 | NodeList | HTMLCollection |
| 返回值状态 | 静态 | 动态 |

由此可知，除了遍历方式都是深度优先之外。返回值类型，状态都是有不同的。

<!-- more -->

### 深度优先遍历

**深度优先搜索算法**（英语：Depth-First-Search，简称DFS）是一种用于遍历或搜索树或图的算法。沿着树的深度遍历树的节点，尽可能深的搜索树的分支。当节点v的所在边都己被探寻过，搜索将回溯到发现节点v的那条边的起始节点。这一过程一直进行到已发现从源节点可达的所有节点为止。如果还存在未被发现的节点，则选择其中一个作为源节点并重复以上过程，整个进程反复进行直到所有节点都被访问为止。属于盲目搜索。

--摘自《[wikipedia](https://zh.wikipedia.org/wiki/%E6%B7%B1%E5%BA%A6%E4%BC%98%E5%85%88%E6%90%9C%E7%B4%A2)》

那么使用`querySelectorAll`或者`getElementsByTagName`方法进行DOM树遍历的思路就是深度优先遍历算法，只不过节点就对应着DOM树中的元素。

![different——01](/images/2018-01-20-querySelectorAll-vs-getElementsByTagName/0101_01.jpg)

从图中的浏览器的控制台输出可以看出，两个方法返回的顺序都是一样的。返回的结果都是：

```
[div.one, div.two, div.three, div.four, div.five, div.six]
```

### 返回值
那么主要的 区别就是返回值。NodeList 和 HTMLCollection 都是DOM树元素集合的操作对象。

先从定义上区分一下动态和静态集合。动态集合指的就是元素集合会随着DOM树元素的增加而增加，减少而减少；静态集合则不会受DOM树元素变化的影响。

NodeList对象是一个节点的集合，是由`Node.childNodes`和`document.querySelectorAll`返回的。NodeList并不是都是静态的，也就是说`Node.childNodes`返回的是动态的元素集合；`querySelectorAll` 返回的是一个静态集合。

HTMLCollection 返回一个时时包括所有给定标签名称的元素的HTML集合，也就是动态集合。

下面来看看静态集合和动态集合的具体表现：

![different——02](/images/2018-01-20-querySelectorAll-vs-getElementsByTagName/0101_04.jpg)

从上面的图中可以看出，通过`document.querySelectorAll('div')`选择的DOM元素集合`query`的大小不会随着`document.body.appendChild(seven)`增加的一个新的`div`元素而改变。而`document.getElementsByTagName('div')`选择的DOM元素集合`elemts`的大小之前和`query`的大小同为`6`个，在添加入新的`div`元素“seven”之后就变成了`7`个。这就很好的诠释了动态还让静态集合最大的区别。

上面提到 NodeList 既可以是静态也可以是动态的，而HTMLCollection则一直是动态的。那什么情况下NodeList是动态的呢？我们来看下面的这个例子。

下面的代码是往`<div class="one">`这个元素里面插入一个新的`div`元素，会发现插入前和插入后输出的`length`是不一样的。这也就表明NodeList动态集合确实存在。

```js
var one = document.querySelector('.one')
var child = one.childNodes;
console.log(child.length);//7
one.appendChild(document.createElement('div'));
console.log(child.length);//8
```

![different——02](/images/2018-01-20-querySelectorAll-vs-getElementsByTagName/0101_02.jpg)

上面图中`one.childNodes.length`和前面讨论的`document.getElementsByTagName('div')`都会随着DOM树元素的增加或减少而发生变化（集合内）。

所以在需要遍历DOM树元素的时候就需要格外注意了，使用动态集合有可能会出现意想不到的结果。


案例HTML代码：

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>test</title>
</head>
<style>
  div{
    padding-left: 20px;
  }
</style>
<body>
  <div class="one">
    one
    <div class="two">
        two
        <div class="three">three</div>
    </div>
    <div class="four">four</div>
    <div class="five">five</div>
  </div>
  <div class="six">six</div>
</body>
</html>
<script>
  var one = document.querySelector('.one')
  var child = one.childNodes;
  console.log(child.length);//7
  one.appendChild(document.createElement('div'));
  console.log(child.length);//8
</script>
```

#### Array VS NodeList
有时候确实会在想`Array`和`NodeList`到底有什么联系，就好比`Array`和`arguments`的关系一样。

其实`NodeList`并非直接继承`Array.prototype`属性，也没有类数组（例如：`arguments`）的方法。

![different——03](/images/2018-01-20-querySelectorAll-vs-getElementsByTagName/0101_03.jpg)

由此可知，

```
array --> Array.prototype --> Object.prototype --> null
nodeList --> NodeList.prototype --> Object.prototype --> null
```

所以不能想当然的把`Array`和`NodeList`混为一谈。

### 总结
所以在以后的开发中一定要注意`querySelectorAll` 和 `getElementsByTagName`选择器的用法，因为有可能死循环就会出莫名其妙的出现在某个角落里面。