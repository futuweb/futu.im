---
title: web前端生成分享快照方式总结
date: 2018-09-04 10:27:39
categories: [前端]
author: Cynthia
---


之前做的活动里，关于分享快照这块，都是由后端生成，并将图片上传到图片库，获得图片链接后，前端调用接口后获取到分享图片的链接。考虑到快照存储还是其他原因，由后端生成的快照，我们都是一个用户只有特定的一张，所以快照上的内容是不会更改的。这样就使得一些动态变化的数据不能展示在快照中。

之后网上搜了一下，发现还是有一些`html`生成`canvas`或者`img`的库的，所以我们就试了一下，看能不能直接由前端生成分享快照

<!-- more -->

## 简单思路

将`htm`l转换为`image`，(或者`dom`转`canvas`再转`image`)，将生产的`image`的链接（多数是base64）放到页面的`img`元素的src属性上，再给出相关引导操作提示（如：长按保存图片），引导用户分享/保存图片。

网上搜到的`html`转`canvas`或`image`的库主要有两个：

- [html2canvas](https://html2canvas.hertzen.com/)
- [dom-to-image](https://github.com/tsayen/dom-to-image)

### demo试验

**简单的实例**

```javascript
// $snapshot为分享快照内容的dom元素，
// $snapshotImg为要放domtoimage生成的图片的img元素
// $snapshotImg2为要放html2canvas生成的图片的img元素
var $snapshot = BASE.$('.j_snapshot');
var $snapshotImg = BASE.$('.j_snapshot_img');
var $snapshotImg2 = BASE.$('.j_snapshot_img2');

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

- 在android微信中生成的图片
![在android微信中生成的图片](/images/2018-09-04-create-snapshot/androidWX.png)

- 在ios微信中生成的图片
![在ios微信中生成的图片](/images/2018-09-04-create-snapshot/iosWX.png)



可能是这张图的复杂度问题，还是其他原因，单看上图，个人觉得`html2canvas`生成的图片的还原度和清晰度都要比`dom-to-image`生成的图片高。

而且在ios微信下，`dom-to-image`生成的图片中的部分图片无法生成，猜测是图片的大小问题导致？（无法生成的几张图片都比较大）

so~ 还是用`html2canvas` 吧

但使用`html2canvas`还是有遇到一些问题的，所以这里将一些列出来



### 遇到的问题
#### 跨域图片无法展示
我们的图片资源是走cdn的，所以导致了图片的链接域名与网页的域名不一致，而产生了跨域问题，可能导致图片无法展示

**解决**：`html2canvas`里有个参数属性是控制是否允许跨域的`useCORS: true`，加上这个属性后，只要图片资源是允许跨域的话`Access-Control-Allow-Origin: *`的，那应该就可以显示跨域图片。

自己的图片实现允许跨域还是比较容易的，但如果用到了别人的不允许跨域的图片（如微信头像）呢，这时候需要我们再多做一下处理，将那张图片变成允许跨域的啦....

看别人的做法是：在服务器上实现微信头像的代理，使页面访问的链接是可以跨域的。这篇文章应该就是这种方式 [
canvas跨域完美解决，微信头像解决跨域](https://blog.csdn.net/mengruobaobao/article/details/79164793)

为了一个活动而修改服务器的`nginx`配置，是不是不太好（怂=.=）

所以我们活动里换了另一种方式。

后端不直接返回微信头像，而是一个能对应相关微信头像的链接（这个链接的资源允许跨域），当后端接收到这个链接的请求时，拉取微信头像信息，再返回给前端这个头像的图片信息。

后来发现，这个拉取微信头像的操作有时会超时，所以我们又做了层处理，再第一次获取微信头像后，将这个头像上传到自己的图片库中（异步操作），以后访问页面，需要微信头像时，就返回图片库中的图片链接。



#### 图片不清晰

如果原始的html中使用缩小的背景图片，那生成的分享图中的这部分会特别不清晰，但用`img`放图片感觉还好

- 缩放过的背景图片
![缩放过的背景图片](/images/2018-09-04-create-snapshot/bgTxtImg.png)

- img元素的图片
![img元素的图片](/images/2018-09-04-create-snapshot/imgTxtImg.png)

从图中可以看出，两张图的`html`部分显示的清晰度是差不多的，但生成图片之后，明显看出，背景图的那张图片的清晰度差好多，而且周围还有些渣渣小点。

so: 如果分享快照中有用到图片的话，还是尽量使用`img`标签，而不是用背景图~

如果使用的是雪碧图的话，也是可以改成用`img`标签的

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


#### `img` 图片对 `transform`属性的兼容性不是很好

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







