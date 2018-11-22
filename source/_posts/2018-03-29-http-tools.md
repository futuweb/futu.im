---
title: HTTP常用工具——Chrome DevTools与Fiddler 4使用介绍
subtitle: Chrome DevTools和Fiddler应该都不会陌生。在日常的开发调试中经常会使用到。
date: 2018-03-29 20:00
categories: [工具]
tags: [HTTP,Fiddler]
author: WillWang
---

![http-tools](/images/2018-03-29-http-tools/01.jpg)

> 免责声明：内容由作者分享，本文编写由 [Jin](/author/Jin) 代为执笔。

作为开发者，对于Chrome DevTools和Fiddler应该都不会陌生。在日常的开发调试中经常会使用到。

我们利用上面的2个工具的目的其实很简单：

1. 方便调试
2. 追踪页面加载的过程
3. 为页面性能调优提供参考

<!-- more -->

## Chrome Network介绍
在我们的电脑上打开Chrome浏览器，然后在键盘上按下F12 ，就可以调起DevTools面板。选择Network菜单，最后在浏览器地址栏输入网站地址，回车就可以观察到当前页面的所有请求。

我们以[www.futu5.com](https://www.futu5.com/)为例：


![http-tools](/images/2018-03-29-http-tools/02.jpg)

从上图可以看到，chrome是以表格的形式展现页面加载时候的所有 HTTP 请求。


### 自定义筛选
第一列固定为http请求的名字，剩下列的展示信息可以通过右键单击表头来自行定义。

![http-tools](/images/2018-03-29-http-tools/03.jpg)


从上图可以看出，自定义的选项有很多：

* 请求方法
* 状态码
* 使用的协议
* Scheme
* 域名
* 地址
* 请求的文件类型
* 由谁触发
* Cookies 数目
* 设置的 cookies 的数目
* 资源大小
* 响应时间
* 优先级
* ID
* 响应头
* 瀑布流

通过不同状态可以进行HTTP请求筛选。


### 查看HTTP请求
针对特定的HTTP请求，可以直接点击 http 请求就可以看到该请求的详细信息。

![http-tools](/images/2018-03-29-http-tools/04.jpg)


### HTTP请求详细信息的面板
每一个HTTP请求都会有一个属于自己的请求明细面板。

![http-tools](/images/2018-03-29-http-tools/05.jpg)

* Headers：查看http请求的头部信息，包括请求头和响应头，还会包含发送请求时带着的参数或数据
* Preview/Response：请求的响应
* Cookies：就是 cookies 列表
* Timing：请求的时间线，表示该请求完整的耗时信息


#### 请求的时间线 Timing
我们先来看，一张关于HTTP请求的生命周期时间轴片段。

![http-tools](/images/2018-03-29-http-tools/06.jpg)

请求生命周期的主要阶段包括：

1. 重定向
2. 立即开始 startTime
3. 如果正在发生重定向，redirectStart 也会开始
4. 如果重定向在本阶段末发生，将采集 redirectEnd
5. 应用缓存
6. 如果是应用缓存在实现请求，将采集 fetchStart 时间
7. DNS
8. domainLookupStart 时间在 DNS 请求开始时采集
9. domainLookupEnd 时间在 DNS 请求结束时采集
10. TCP
11. connectStart 在初始连接到服务器时采集
12. 如果正在使用 TLS 或 SSL，secureConnectionStart 将在握手（确保连接安全）开始时开始
13. connectEnd 将在到服务器的连接完成时采集
14. 请求
15. requestStart 会在对某个资源的请求被发送到服务器后立即采集
16. 响应
17. responseStart 是服务器初始响应请求的时间
18. responseEnd 是请求结束并且数据完成检索的时间

![http-tools](/images/2018-03-29-http-tools/07.jpg)
![http-tools](/images/2018-03-29-http-tools/08.jpg)

耗时时间线各字段含义：

1. Queuing （某个请求正在排队）：
请求已被渲染引擎推迟，因为该请求的优先级被视为低于关键资源（例如脚本/样式）的优先级。 图像经常发生这种情况。
请求已被暂停，以等待将要释放的不可用 TCP 套接字。
请求已被暂停，因为在 HTTP 1 上，浏览器仅允许每个源拥有六个 TCP 连接。
生成磁盘缓存条目所用的时间（通常非常迅速）
2. Stalled/Blocking：请求等待发送所用的时间。 可以是等待 Queueing 中介绍的任何一个原因。 此外，此时间包含代理协商所用的任何时间。
3. Proxy Negotiation：与代理服务器连接协商所用的时间。
4. DNS Lookup：执行 DNS 查询所用的时间。 页面上的每一个新域都需要完整的往返才能执行 DNS 查询。
5. Initial Connection / Connecting：建立连接所用的时间，包括 TCP 握手/重试和协商 SSL 的时间。
6. SSL：完成 SSL 握手所用的时间。
7. Request Sent / Sending：发出网络请求所用的时间。 通常不到一毫秒。
8. Waiting (TTFB)：等待初始响应所用的时间，也称为至第一字节的时间。 此时间将捕捉到服务器往返的延迟时间，以及等待服务器传送响应所用的时间。
9. Content Download / Downloading：接收响应数据所用的时间。


### Chrome Network工具栏部分
![http-tools](/images/2018-03-29-http-tools/09.jpg)


![http-tools](/images/2018-03-29-http-tools/10.jpg)

1. 过滤：根据 XHR请求/JS文件/CSS文件/img文件/媒体文件/字体文件/文档/Web Sockets/manifest文件/其它文件进行区分，还可以对 data url 进行显示/隐藏
2. 屏幕截图：可以确定出屏幕白屏时间，提供优化的参考
3. 资源加载时间流：可以确定出各个资源加载的时间，有助于优化



## Fiddler 4

![http-tools](/images/2018-03-29-http-tools/11.jpg)

### 左侧请求列表
以表格形式显示Fiddler 工具拦截的 HTTP/HTTPS 请求。

* Result 表示HTTP返回的状态码
* Protocol 表示请求的协议：HTTP/HTTPS
* Host 请求的IP或网址
* URL 请求的路径
* Body 请求资源的大小
* Caching 请求的缓存过期时间或者缓存控制值
* Content-Type 请求响应的类型
* Process 发送此请求的进程：进程ID
* Comments 允许用户为此回话添加备注
* Custom 允许用户设置自定义值

### 右侧 Inspectors 标签
用于查看会话的内容，上半部分是请求的内容，下半部分是响应的内容。

* 对于每一部分，提供了多种不同格式查看每个请求和响应的内容：
* Header 标签用于显示HTTP请求和响应的头信息
* TextView 标签用于查看 HTML/JS/CSS 等格式的数据
* ImageView 标签用于显示图片格式的数据
* WebForms 标签用于显示请求的表单数据。如登录请求，就可以通过它查查看登录用户名密码信息。它以表格形式显示。
* Raw 标签可以查看原始的符合HTTP标准的请求和响应头
* Auth 标签可以查看授权Proxy-Authorization 和 Authorization的相关信息
* Cookies 标签可以看到请求的cookie和响应的set-cookie头信息
* XML 和 JSON 标签用于显示 XML和JSON格式的数据

### 设置代理 HTTPS 请求
Fiddler 使用 man-in-the-middle (中间人) 攻击的方式来截取 HTTPS 流量。在 Web 浏览器面前 Fiddler 假装成一个 HTTPS 服务器，在真正的 HTTPS 服务器面前 Fiddler 假装成浏览器。

服务器 ==> 客户端：Fiddler 接收到服务器发送的密文，用对称密钥解开，获得服务器发送的明文。再次加密， 发送给客户端。

客户端 ==> 服务端：客户端用对称密钥加密，被 Fiddler 截获后，解密获得明文。再次加密，发送给服务器端。

由于Fiddler一直拥有通信用对称密钥，所以在整个HTTPS通信过程中信息对其透明。


菜单栏 Tools ==> Fiddler Options 打开fiddler配置 ==> HTTPS 配置项 ==> 勾选“Capture HTTPS CONNECTs” 和“Decrypt HTTPS traffic”

![http-tools](/images/2018-03-29-http-tools/12.jpg)