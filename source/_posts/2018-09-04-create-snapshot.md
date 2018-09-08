---
title: 移动端页面分享快照生成总结
date: 2018-09-04 10:27:39
categories: [前端]
author: Cynthia
---


之前经常在微信中收到一些朋友分享带页面信息的图片（分享图片），这种分享方式相对于寻常的结构化分享（链接分享）更容易于表现页面内容。公司的产品童鞋也想在活动页面中生成一张分享图片（带用户专属二维码的），引导用户分享传播。

刚开始做这个功能时，我们是由后端根据用户的信息生成一张专属的分享图片，并将图片上传到图片库，获得图片链接；再由前端调用接口后获取到分享图片的链接，在页面中用`img`标签展示这张图片，配上一些引导的文案，提醒用户“长按保存分享”。但考虑到服务器压力、存储等问题，我们只会对一个用户做一次分享图片生成的操作（当用户再一次获取分享图片的时候，返回的是第一次生成的那张图片），即整个活动期间，单个用户生成的分享图片的内容是不会更改的。这样就使得一些动态变化的数据不能展示在分享图片中，分享图片中可展示的内容受到很大的限制。

后来，我们想能不能直接有前端生成这张分享快照呢？前端生成拖，无需经过网络传输等操作，可减少服务的压力，且可以每次都动态生成图片，可以使分享图片展示一些随用户操作而不断变化的数据。之后发现已经存在一些`html`生成`canvas`或者`img`的库，所以我们就试了一下，看能不能直接由前端生成分享快照。


<!-- more -->

## 简单思路

将`html`转换为`image`，(或者`dom`转`canvas`再转`image`)，将生产的`image`的链接（多数是base64）放到页面的`img`元素的src属性上，再给出相关引导操作提示（如：长按保存图片），引导用户分享/保存图片。

大家提起的`html`转`canvas`或`image`的库主要有两个：

- [html2canvas](https://html2canvas.hertzen.com/)
- [dom-to-image](https://github.com/tsayen/dom-to-image)

### demo试验

**简单的实例**

html代码中，主要包括了根据设计童鞋给的分享快照的原稿重构出的分享快照的html代码，和要放生成的图片的`img`容器

```html

<div class="actShareBox">
  我是html！！
  <!-- 要用于生成快照的html代码 -->
  <div class="j_snapshot snapshot">
  </div>
</div>
<div class="j_snapshot_img_box actShareImgBox">
    我是dom-to-image生成的图片
    <!-- 用于展示dom-to-image生成的图片 -->
    <img src="" class="j_snapshot_img">
</div>
<div class="j_snapshot_img_box actShareImgBox">
    我是html2canvas生成的图片
    <!-- 用于展示html2canvas生成的图片 -->
    <img src="" class="j_snapshot_img2">
</div>
```
在js代码中，主要是调用两个库的API，生成图片或者canvas

```javascript
// $snapshot为分享快照内容的dom元素，
// $snapshotImg为要放domtoimage生成的图片的img元素
// $snapshotImg2为要放html2canvas生成的图片的img元素
var $snapshot = document.querySelector('.j_snapshot');
var $snapshotImg = document.querySelector('.j_snapshot_img');
var $snapshotImg2 = document.querySelector('.j_snapshot_img2');

// domtoimage生成jpg的方法（这个库还有其他的方法）
domtoimage.toJpeg($snapshot,{
    quality: 1
}).then(function (dataUrl) {
    // 直接生成了base64的url
    $snapshotImg.src = dataUrl;
}).catch(function (error) {
    console.error('oops, something went wrong!', error);
});

// html2canvas 生成canvas
html2canvas($snapshot,{
    // useCORS: true, // 允许图片跨域
    backgroundColor: null,
    logging: false,
}).then(function(canvas) {
    // 'image/jpeg', 1.0
    // 再利用canvas的toDataURL 方法，将canvas转为图片
    var dataURL = canvas.toDataURL();
    $snapshotImg2.src = dataURL;
}, function(err) {
    console.error('oops, something went wrong!', err);
});
```

上图...

- 在android微信中生成的图片(小米note3)
![在android微信中生成的图片](/images/2018-09-04-create-snapshot/androidWX.png)

- 在ios微信中生成的图片(iphone6p)
![在ios微信中生成的图片](/images/2018-09-04-create-snapshot/iosWX.png)

从上面六张图中可以看出

- 从生成的图片内容的还原度看，无论在ios中或android中，`html2canvas`都能将分享图片html页面中内容完整的生成出来，而`dom-to-image`生成的图片中，ios端生成的是一张残缺的图片（所有html页面中图片无法正常的展示），在android也同样有部分图片无法展示，且存在样式错乱问题。（这轮，`html2canvas`胜）

- 从清晰度看，细看对比中间的图（`dom-to-image`生成的图片）和右边的图（`html2canvas`生成的图片），能看出右图中的文字、img图片的清晰度都要比左图的高很多(html中的背景图片生成出来的清晰度，两者都不是很好)（这轮，还是`html2canvas`胜）

so~， 还是用`html2canvas` 吧



### 遇到的问题

但使用`html2canvas`生成分享图片时，还是有遇到一些问题的，所以这里将一些列出来。      
刚开始用html/css重构分享快照时，我们有用到纯文本、`img`标签图片、css背景图、对图片/文字进行缩放。           
第一次生成的图片很不符合预期，生成的图片与原图效果相差较大。只能一一排查，寻找问题，解决问题了。

#### 1.跨域图片无法展示

我们的图片资源是走cdn的，所以导致了图片的链接域名与网页的域名不一致，而产生了跨域问题，可能导致图片无法展示

**解决：**         
步骤1：将`html2canvas`中的参数设置中的`useCORS`属性改为`true`，使`html2canvas`接受处理跨域资源。   
步骤2： 使图片资源允许跨域（响应头中加上 `Access-Control-Allow-Origin: *`）     
这样就能显示跨域图片了~

**第三方跨域图片处理：**      
自己的图片实现允许跨域还是比较容易的，但如果用到了第三方的不允许跨域的图片（如微信头像）呢，这时候需要我们再多做一下处理，将那张图片变成允许跨域的啦....

看别人的做法是：在*服务器上实现第三方图片的代理*（将第三方图片的域名变成自己的域名），再使自己的域名的资源允许跨域。

为了一个活动而修改服务器的`nginx`配置，是不是不太好（怂=.=）

所以我们活动里换了另一种方式。

后端不直接返回微信头像，而是一个能对应相关微信头像的链接（这个链接的资源允许跨域），当后端接收到这个链接的请求时，拉取微信头像信息，再返回给前端这个头像的图片信息。[这里的后端指的活动中的后端代码，与上面的改`nginx`配置不是一个做法]

后来发现，这个拉取微信头像的操作有时会超时，所以我们又做了层处理，在第一次获取微信头像后，将这个头像上传到自己的图片库中（异步操作），以后访问页面，需要微信头像时，就返回图片库中的图片链接（当然，这个图片库链接也是可以跨域的）。



#### 2.生成的分享图片不清晰

这里的不清晰指的有两方面：   

1. *整张分享图片*的清晰度不够
2. *原分享页面中的图片*在生成的分享图片中的清晰度不够

**整张分享图片清晰度不够问题解决：**    
这里的清晰度不够的问题，是由于图片的实际物理像素点不够的原因造成的，这里我的处理方法修改`html2canvas`的`scale`属性，增大绘制时的缩放比例，从而提高清晰度

```javascript
html2canvas($snapshot, {
    useCORS: true,
    scale: window.devicePixelRatio*2 // 默认值是window.devicePixelRatio
    backgroundColor: null,
    logging: false
});
```

**原分享页面中的图片在生成图片中清晰度不够问题解决：**

我们在分享页面中有用到两种方式展示图片     
1. 使用`img`标签元素引入图片
2. 使用元素中的背景图片引入图片

但从实际生成的图片的效果发现，使用页面中使用背景图片的部分，在分享快照中会特别的不清晰，而且背景图片的底部会有一些原页面中没有的小刺点（如下图的背景图里，生成的图片中富途logo下有一条类似的白色细线，但原页面中却没有）

而使用`img`标签元素引入图片则不会存在这种情况

- 缩放过的背景图片
![缩放过的背景图片](/images/2018-09-04-create-snapshot/bgTxtImg.png)

- img元素的图片
![img元素的图片](/images/2018-09-04-create-snapshot/imgTxtImg.png)

从图中可以看出，两张图的页面截图（上部分图）显示的清晰度是差不多的，但通过`html2canvs`生成图片之后，明显看出，背景图的那张图片的清晰度差好多，而且周围还有些渣渣小点。

so: 如果分享快照中有用到图片的话，还是尽量使用`img`标签，而不是用背景图，以保证分享图片的清晰度。

**分享图片页面中雪碧图**      
在重构分享图片页面时，里面有个vs的内容，里面的阵营图片会根据用户的阵营选择和最终获胜阵营的结果而展示不同的内容，而我们为了页面的性能问题，还有开发的方便，将这些阵营图片拼成了一张雪碧图，通过class控制展示不同的图片。     
一开始我也没想到怎么用`img`元素去展示雪碧图，就还是用了背景图来显示阵营选择这块内容，后来就时不时被产品童鞋吐槽分享图片中那部分内容太模糊了....

后来想了想，如果使用的是雪碧图的话，也是可以改成用`img`标签展示的

```html
<span class="emoji emoji01"><img src="/emoji.png" alt=""></span>

<style>
.emoji{
    width: 10px;
    height: 10px;
    /*固定大小，超过的隐藏*/
    overflow: hidden;
    display: block;
    position: relative;
}
.emoji.emoji01 img{
    position: absolute;
    /*使用top,left 偏移img图片使之展示对应的位置*/
    top: 0;
    left: -20px;
}
</style>
```


#### 3.`img` 图片对 `transform`属性的兼容性不是很好

`html2canvas`的官方文档中，有列了一些兼容性不是很好的[css属性](http://html2canvas.hertzen.com/features)，所以自己多测试一下，不能支持的属性，就换一种写法啦~

在活动中遇到的是，`img`元素中的`transform`的实现不太好。

例子中是想将图片居中展示，所以给`img`元素加了以下的`css`

```css
img{
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%,-50%);
    width: 100%;
}
```

但实际上出来的效果是这样的...

![img使用transform问题](/images/2018-09-04-create-snapshot/translateImg.png)



## 总结

使用`html2canvas`,将页面元素转为图片的方式生成分享快照的方式是可行的，但在重构分享图片页面时，因尽可能使用常用的方式和css属性，少用背景图片，就能生成一张清晰度不错的图片啦~



