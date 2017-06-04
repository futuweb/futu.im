---
title: xhr/jsonp请求之abort详解
date: 2017-06-01 22:30
category: JavaScript
tags: [abort,ajax,jsonp,XMLHttpRequest]
author: Jin
---

当你看到文章标题的时候可能会觉得这是一个老生常谈的话题。

前端开发中向后端发起xhr（`XMLHttpRequest`）请求（代表性的就是熟悉的`ajax`）是再正常不过的事。

但在前端开发过程中，不怎么重视xhr的abort（中止掉xhr请求，及表示取消本次请求）。往往会带来一些不可意料的结果。

<!-- more -->

比如：切换tab，发起xhr请求，渲染同一个列表。就这么简单的拉取数据渲染列表的功能，并且可以根据tab切换。想想应该是很简单。但是假如你只顾着发起xhr请求，而没有abort掉它，想想会发生什么。很有可能就是当前选中的tab数据，并不是你想要的。说白了就是数据错了。这时候你可能就要考虑是不是xhr请求返回数据的顺序问题。

答案是肯定的，xhr请求返回数据顺序是不固定的。所以你要做的就是abort掉你之前的xhr请求，然后再发起一个新的xhr请求。

结合上面所说的例子可以知道xhr使用不当会存在以下问题：

* 容易出现页面最终数据与状态不一致的问题，这可能再列表筛选是出现的概率比较大。
* xhr请求达到一定数量之后，浏览器就会显得非常的慢。因为有太多的请求在请求服务器资源。

为了解决上面的问题，我们在进行页面的时候就必须考虑abort掉所有的xhr请求。

那么如何实现xhr的abort方法呢，或者通过何种方式abort掉xhr呢？

## 一个简单的xhr
我们都知道，现在的框架（例如：jQuery的`ajax`模块）对xhr都进行了封装，是为了让我们更好的使用xhr。但是也蒙蔽了我们的眼睛。让我们抛开框架，来看看一个简单的xhr怎么实现。

```js
//仅供参考 xhr
function ajax(type ,url , data , successCallBack , errorCallBack){
  let xhr = new XMLHttpRequest();
  xhr.onload = ()=>{
    if(xhr.status === 200){
      return successCallBack(xhr.response||xhr.responseText);
    }
    return errorCallBack('请求失败');
  }
  xhr.onerror = ()=>{
    return errorCallBack('出错了');
  }
  xhr.open(type,url);
  xhr.send(data ? data:null);
}
```

这就是一个简单的xhr请求的实现，我把它命名为`ajax`,我们现在可以通过以下方式进行调用：

```js
ajax('get','/test/getUserList' , undefined , function(result){
  console.log('成功了。', result);
} ,function(error){
  console.log(error);
});
```

如果使用这个方法我们是没办法`abort`掉xhr请求的。好吧，现在我们把它改造一下，让它支持abort方法：

```js
//仅供参考 xhr.abort
function ajax(type ,url , data , successCallBack , errorCallBack){
  let xhr = new XMLHttpRequest();
  xhr.onload = ()=>{
    if(xhr.status === 200){
      return successCallBack(xhr.response||xhr.responseText);
    }
    return errorCallBack('请求失败');
  }
  xhr.onerror = ()=>{
    return errorCallBack('出错了');
  }
  xhr.open(type,url);
  xhr.send(data ? data:null);

  return xhr;//返回XMLHttpRequest实例对象
}
```

好像没有什么变化对吧。不错，只要在函数的末尾添加`return xhr;`将`XMLHttpRequest`实例对象返回即可。那我们在就已经可以如愿的abort掉xhr请求。

```js
  let xhr = ajax('get','/test/getUserList' , undefined , function(result){
    console.log('成功了。', result);
  } ,function(error){
    console.log(error);
  });

  //abort
  xhr.abort();
```

好像我们已经大功告成了。但是问题来了，现在Promise这么好用，为什么不把它加进来呢。像这样没法在我们的Promise链式调用上使用它。


## Promise封装xhr
好了，现在的首要任务是封装出一个Promise版的ajax库。首要要确认的就是，`ajax`方法需要返回的是`Promise`实例对象，而不再是原生的`XMLHttpRequest`实例对象。知道了这一点那就可以进行封装了。

```js
//仅供参考 promise
function ajax(type ,url , data ){
  let xhr = new XMLHttpRequest();

  let promise = new Promise(function(resolve , reject){
    xhr.onload = ()=>{
      if(xhr.status === 200){
        return resolve(xhr.response||xhr.responseText);
      }
      return reject('请求失败');
    }
    xhr.onerror = ()=>{
      return reject('出错了');
    }
    xhr.open(type,url);
    xhr.send(data ? data:null);
  });
  return promise;//返回Promise实例对象
}
```

使用了`Promise`之后我们不再需要传入回调函数。所以参数减少了。这样我们就可以愉快的进行链式调用了。

```js
let promise = ajax('get','/test/getUserList');
promise.then((result)=>{
  console.log('成功了。', result);
},(error)=>{
  console.log(error);
})
```

可问题有来了，`Promise`实例是没有`abort`方法的。假如我们把ajax方法修改为返回`xhr`，我们是可以如期调用`abort`方法杀死请求，但是我们就不能使用`Promise`带给我们的好处了。

仔细思考，最后一句`return promise;` 这里是不能改。我们只能另外想办法。

最简单的解决方式就是创建一个xhr和promise的映射关系。也就是每一个promise对应一个唯一的xhr请求。有了思路之后，解决方案就来了。

```js

let map = [];//用于保存promise和xhr之间的映射关系

//仅供参考 promise abort
function ajax(type ,url , data ){
  let xhr = new XMLHttpRequest();

  let promise = new Promise(function(resolve , reject){
    xhr.onload = ()=>{
      if(xhr.status === 200){
        return resolve(xhr.response||xhr.responseText);
      }
      return reject('请求失败');
    }
    xhr.onerror = ()=>{
      return reject('出错了');
    }
    xhr.open(type,url);
    xhr.send(data ? data:null);
  });
  map.push({promise:promise,request:xhr});//创建promise和xhr之间的映射关系，保存到全局的一个数组中。
  return promise;//返回Promise实例对象
}
//abort 请求
function abort(promise){
  for(let i = 0 ; i < map.length ; i++ ){
    if ( map[i].promise === promise ){
      map[i].request.abort();
    }
  }
}
```

通过在全局创建一个map保存所有的promise和xhr之间的映射关系。这样我们就可以在需要abort请求的时候根据映射关系找到xhr并abort请求。

```js
let promise = ajax('get','/test/getUserList');
promise.then((result)=>{
  console.log('成功了。', result);
},(error)=>{
  console.log(error);
})

abort(promise);
```

好吧，到这里Promise版的ajax,我们已经实现了。是不是很简单啊。

## 为何jsonp
假如你还不明白jsonp是何物，那希望下面的篇幅能让你明白。可能你零星的知道跨越请求，但是可能没有在实战中碰到过。那么我们先来看看，一个简单的`jsonp`函数是怎么实现的吧。

```js
let index = 0;
//仅供参考 jsonp
function jsonp(url,jsonp,successCallback , errorCallback){
  let script = document.createElement('script');
  let result ;
  script.onload = function(){
    successCallback(result);
  }
  script.onerror = function(){
    errorCallback('出错了');
  }
  let callBackName = 'jsonpCallback'+index++;
  script.src=url+(url.indexOf('?') >=0 ? '&':'?')+jsonp+'='+callBackName;

  window[callBackName]=function(){//拿给后端进行输出执行的。
    result = Array.prototype.slice.call(arguments);
  }
  document.head.append(script);
}
```

jsonp算起来应该就是通过`script`加载实现的跨域请求。其中重要的就是数据返回的接收，我们需要和后端开发同学协商回调函数的变量名。然后后端获取到回调函数名，并且在返回时把回调函数和数据拼接成字符串返回到前端。前端我们添加一个window对象的函数用于接收数据，在函数执行完成后，就会触发`script.onload`事件，这样就可以真正执行用户回调函数了。

可能你会觉得有点绕，其实细细的理一下，应该就明白了。

后端其实很简单，只要获取到`jsonp`函数变量名就可以了。然后把函数和数据拼接成字符串返回即可。

下面我们来看看Node.js中的实现：

```js
  let query = ctx.request.query;
  let jsonp = query.jsonp;//与后端协商的回调参数
  ctx.body = jsonp+'({code:0,msg:"success"})';
```

这个回调函数并不是用户输入的`successCallback`,而是`jsonp`函数内部的`window[callBackName]`,为什么要这样。你细想一下JavaScript的作用域应该就会知道。这就好比你在`script`标签中执行一个函数一样。

有可能我们第一次调用`jsonp`函数服务器会返回如下结果：

```html
<script >
  //只有这一行是服务器返回的，
  //script标签是document.head.append(script)时候加的
  jsonpCallback0({code:0,msg:"success"});
</script>
```

所以，得出结论就是：函数必须能通过`window`对象上访问到。不然执行时就会报错。这就是为什么我们不能直接把用户传入的回调直接用来当成回调接收数据的真正原因。

再次强调：JavaScript作用域。

一次成功的jsonp应该是：添加`script`标签到`head`,后端接收到`jsonp`数据，返回拼接好的函数名和数据字符串，执行`window`对象上的函数拿到数据，执行`script.onload`事件，执行成功回调。

## jsonp的`abort`方法何去何从

现在你已经知道了jsonp的原理了。那么如何才能对`script`加载数据进行`abort`呢。

犯难的问题来了，`script`并没有真正的`abort`方法给我们使用。我们所做的就是尽最大的努力提供类似于abort功能的方法。

思路就是使用`Event`函数。触发`script`的`error`监听事件。所以我们得对`jsonp`函数添加一个`trigger`辅助函数进行触发`error`事件。

```js
//[trigger 触发事件]
function trigger(element,event){
  if( !isString(event) ) {
    return;
  }
  if ( element.dispatchEvent ){
    let evt = document.createEvent('Events');// initEvent接受3个参数
    evt.initEvent(event, true, true);
    element.dispatchEvent(evt);
  }else if ( element.fireEvent ){ //IE
    element.fireEvent('on'+event);
  }else{
    element['on'+event]();
  }
}
let index = 0;
//仅供参考 jsonp.abort
function jsonp(url,jsonp,successCallback , errorCallback){
  let script = document.createElement('script');
  let result ;
  script.onload = function(){
    successCallback(result);
  }
  script.onerror = function(){
    errorCallback('出错了');
  }
  let callBackName = 'jsonpCallback'+index++;
  script.src=url+(url.indexOf('?') >=0 ? '&':'?')+jsonp+'='+callBackName;

  window[callBackName]=function(){//拿给后端进行输出执行的。
    result = Array.prototype.slice.call(arguments);
  }
  script.abort = ()=>{
    return trigger(script,'error');
  };
  document.head.append(script);
}
```

我们把`Promise`也使用进来，那样的话，我们就可以脱离回调地狱了不是吗？

```js
let index = 0;
//仅供参考 jsonp.abort
function jsonp(url,query,jsonp){
  let script = document.createElement('script');
  let result ;

  let promise = new Promise(function(resolve,reject){
    script.onload = function(){
      return resolve(result);
    }
    script.onerror = function(){
      return reject('出错了');
    }
    let callBackName = 'jsonpCallback'+index++;
    script.src=url+(url.indexOf('?') >=0 ? '&':'?')+jsonp+'='+callBackName;

    window[callBackName]=function(){//拿给后端进行输出执行的。
      result = Array.prototype.slice.call(arguments);
    }
    document.head.append(script);
  });
  script.abort = ()=>{
    return trigger(script,'error');
  };
  map.push({promise:promise,request:script});//创建promise和script之间的映射关系，保存到全局的一个数组中。
  return promise;
}
```

同样的我们套用上面的`xhr`的`abort`函数封装。这样我们就大功告成了。基本的功能我们就全部实现了。我们就可以开始进行调用了。

```js
let promise = jsonp('/test/getUserList','jsonp');
promise.then((result)=>{
  console.log('成功了。', result);
},(error)=>{
  console.log(error);
})

abort(promise);
```

## 总结
虽然，我们已经完成了封装，但是还有很多的意外没有考虑，要想再实战中运用还必须进行封装和重构。我们必须重视`abort`方法在xhr/jsonp中的运用，但是也不能滥用，适可而止。存在多层服务器调用时，应该更需要慎重考虑。

要想了解更多，可以参考这是我封装好的一个Promise版本的ajax/jsonp库[https://github.com/Yi-love/xhrp](https://github.com/Yi-love/xhrp)。希望对你有所帮助。


