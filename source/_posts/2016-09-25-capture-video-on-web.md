---
title: 如何使用web录制视频
subtitle: 最近在某个需求的评审会上，产品同学脑洞大开，提出了使用web录制视频的想法。
date: 2016-09-25 12:41
tags: [Video,WebRTC]
categories: [前端]
author: TooBug
---

最近在某个需求的评审会上，产品同学脑洞大开，提出了**使用web录制视频**的想法。并兴致勃勃地说“看，XXX网站可以调用摄像头，还能聊天呢！”本着负（Zhuang）责（Bi）的原则，我们也对该方案做了认真的预研。大致结论：

1. 非实时录制时（文件上传框），兼容性相对较好，且API和性能稳定
2. 实时录制视频在Chrome for Android中可行，其它机型和浏览器均不可使用。考虑到相关标准仍处于不稳定状态，不建议在产品中使用
3. 微信有非公开接口可以调用实时视频录制（微证券使用）

详细方案如下：

<!--more-->

## 方案一：使用文件上传框

文件上传框`<input type="file">`是前端同学非常熟悉的一个HTML控件，它的主要作用是用来上传文件。而在移动端，这个文件上传框被赋予了更多的使命，除了可以选择文件上传之外，还可以调用摄像头来拍摄照片或者视频并上传。

具体的使用方式：

```html
<input type="file" accept="video/*"/>
```

或者

```html
<input type="file" accept="video/mp4,video/x-m4v,video/*"/>
```

这两种写法的区别在于对不同机型来说兼容性可能略有区别，但是具体的情况未做一一测试总结。经过初步测试，该方案可以在以下环境中运行：

- Android 4.4+
- iOS 6.0+
- 微信webview
- Chrome for Android

> 注：该兼容性中介我们简单测试一部分机器后的结论，不做任何保证。事实上我们也碰到一部分Android机器是例外。下文兼容性列表同理。

该方案API简单易用，且功能由浏览器或webview原生实现，性能比较稳定。


该方案缺点：非实时录制视频，无法确定用户是录制的还是选取的已有的视频文件。

相关demo <http://codepen.io/TooBug/embed/RRZQxr/>

## 方案二：视频录制

要使用web录制视频，需要两个相关API，一个用于调用摄像头，一个用于录制。调用摄像头后会产生一个视频流，然后调用录制API将这个视频流压缩和保存。

其中调用摄像头的API叫作`getUserMedia()`，以前属于`navigator`对象（Chrome 21-49），后来规范修改，现在属于`MediaDevices`（Chrome 49+）。该API还负责提示用户授权。

视频流叫作`MediaStream`。拿到`MediaStream`后，可配合`ObjectURL`，产生一个虚拟URL，供浏览器`video`标签调用，实现视频回放（回显）。

用于录制视频的API叫作`MediaRecorder`。该API在Chrome 49+可用。

该方案兼容性：

- Chrome 49+
- Firefox 29+
- Chrome for Android

相关Demo地址：<https://simpl.info/mediarecorder/>

## 方案三：WebRTC视频流远程录制

WebRTC是指实现web实时通信的一系列规范，一般可以通俗地理解为“P2P视频聊天”。实现这个功能依赖于上方说的摄像头调用API `getUserMedia()`取到`MediaStream`，同时还依赖一个P2P网络连接和传输的API来实现视频流数据的传输，这个API叫作`RTCPeerConnection`。

在实际运作时，需要服务额外处理两个浏览器在P2P通信之前的Session建立相关的逻辑：

![WebRTC实际原理图](/images/capture-video-on-web/1.png)

同时，还需要服务端支持来完成浏览器在NAT等复杂网络环境中的通信“打洞”需求：

![WebRTC实际原理图](/images/capture-video-on-web/2.png)

使用该方案录制视频的原理是通过服务端模拟一个浏览器（Peer），实现相关视频流接收解码协议以及`RTCPeerConnection`协议。

Session管理的服务端和打洞的服务端实现和维护比较麻烦，但有例可循，而模拟Peer的部分则实现过于复杂，因此，虽然该方案理论上可行，且浏览器兼容性稍好，但仍然认为该方案在实际操作中不可行。

这个方案的兼容性

- Firefox 17+
- Chrome 21+
- Edge 12+
- Chrome for Android

## 方案四：截图上传

该方案原理：在使用`getUserMedia()`获取视频流之后，将该视频流定时投映到一张2d画布中（`canvas`），然后将画布中的画面提取成图片数据（`base64`）。

该方案原理比较简单，兼容性

- Firefox 17+
- Chrome 21+
- Edge 12+
- Chrome for Android

但同时也有明显缺陷：
- 无法获取声音数据，只能获取到图片数据
- 需要上传后由后台转换成视频
- 帧数多时图片可能较大，造成性能问题（比如崩溃）
- 帧数多时图片可能较大，造成网络传输慢

## 相关文档

- [MDN上的navigator.getUserMedia文档](https://developer.mozilla.org/zh-CN/docs/Web/API/Navigator/getUserMedia)
- [MDN上的MediaDevices.getUserMedia文档](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia)
- [MDN上的MediaStream文档](https://developer.mozilla.org/en-US/docs/Web/API/MediaStream)
- [MDN上的MediaRecorder文档](https://developer.mozilla.org/zh-CN/docs/Web/API/MediaRecorder)
- [W3C Media Capture and Streams规范（发布候选状态）](https://www.w3.org/TR/mediacapture-streams/)
- [W3C MediaRecording规范（Working Draft草稿状态）](https://w3c.github.io/mediacapture-record/MediaRecorder.html)
- [W3C webrtc规范（Working Draft草稿状态）](http://w3c.github.io/webrtc-pc/)
- [webrtc官方网站](https://webrtc.github.io)
- [教程：webrtc入门](https://codelabs.developers.google.com/codelabs/webrtc-web/)
- [文章：真实世界中的webrtc](http://www.html5rocks.com/en/tutorials/webrtc/infrastructure/)
