---
title: http缓存
date: 2018-04-14 20:59:00
tags: [网络]
author: tony
categories: HTTP
---

### **什么是web缓存**

Web缓存是指一个Web资源（如html页面，图片，js，数据等）存在于Web服务器和客户端（浏览器）之间的副本。缓存会根据进来的请求保存输出内容的副本；当下一个请求来到的时候，如果是相同的URL，缓存会根据缓存机制决定是直接使用副本响应访问请求，还是向源服务器再次发送请求。比较常见的就是浏览器会缓存访问过网站的网页，当再次访问这个URL地址的时候，如果网页没有更新，就不会再次下载网页，而是直接使用本地缓存的网页。只有当网站明确标识资源已经更新，浏览器才会再次下载网页。

### **web缓存的作用**

1. 减少网络带宽消耗
1. 降低服务器压力
1. 减少服务器压力
1. 减少网络延迟，加快页面打开速度

<!-- more -->
浏览器HTTP缓存可以分为强缓存和协商缓存。强缓存和协商缓存最大区别是：强缓存命中的话不会发请求到服务器（比如chrome中的200 from memory cache），协商缓存一定会发请求到服务器，通过资源的请求首部字段难资源是否命中协商缓存，如果协商缓存命中，服务器会将这个请求返回，但是不会返回这个资源的实体，而是通知客户端可以从缓存中加载这个资源（304 not modifend）。流程图如下：

![](/images/2018-04-14-http-cache/161233e63a84f043.png)

#### http报文中与缓存相关的首部字段

1.通用首部字段（就是请求报文和响应都能用上的字段）


字段名称| 说明
---|---
Cache-Control |控制缓存的行为
Pragma |http1.0的旧社会遗留物，值为“no-cache”时禁用缓存

Cache-Control和浏览器相关的命令


指令 | 参数 | 说明
---|---|---
private | 无 | 表明响应只能被单个用户缓存，不能作为共享缓存（即代理服务器不能缓存它）
public | 可省略 |表明响应可以被任何对象（包括：发送请求的客户端，代理服务器，等等）缓存
no-cache | 可省略 |缓存前必需确认其有效性
no-store | 无 |不缓存请求或响应的任何内容
max-age=[s] | 必需 |响应的最大值

- max-age（单位为s）设置缓存的存在时间，相对于发送请求的时间。只有响应报文首部设置Cache-Control为非0的max-age或者设置了大于请求日期的Expires（下文会讲）才有可能命中强缓存。当满足这个条件，同时响应报文首部中Cache-Control不存在no-cache、no-store且请求报文首部不存在Pragma字段，才会真正命中强缓存。以下所有图片均为刷新（command+R）的截图。
- no-cache  表示请求必须先与服务器确认缓存的有效性，如果有效才能使用缓存（协商缓存），无论是响应报文首部还是请求报文首部出现这个字段均一定不会命中强缓存。Chrome硬性重新加载（Command+shift+R）会在请求的首部加上Pragma：no-cache和Cache-Control：no-cache。
- no-store  表示禁止浏览器以及所有中间缓存存储任何版本的返回响应，一定不会出现强缓存和协商缓存，适合个人隐私数据或者经济类数据。
- public 表明响应可以被浏览器、CDN等等缓存。
- private 响应只作为私有的缓存，不能被CDN等缓存。如果要求HTTP认证，响应会自动设置为private。


2.请求首部字段

字段名称 | 说明
---|---
if-Match | 比较ETag是否一致
if-None-Match | 比较ETag是否不一致
if-Modified-Since | 比较ETag是否不一致
if-UnModified-Since | 比较资源最后更新的时间是否一致

3.响应首部字段

字段名称 | 说明
---|---
ETag | 资源的匹配信息
Expires | http1.0的遗留物，实体主体过期时间
Last-Modifid | 资源的最后一次修改的时间



#### 强制缓存

与强缓存主要是Pragma、Cache-Control 、Expires

```
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
```
注意上面两条指令的作用是不允许浏览器缓存当前页面以及页面上引用的资源，强制浏览器每次请求当前页面时都需要从服务器端获取最新版本。这种方式仅对部分浏览器有效，而且不影响代理服务器对该页面的缓存控制，原因是因为代理服务器并不会去解析页面上的内容。

#### 控制协商缓存

1.Last-Modified/If-Modified-Since

If-Modified-Since是一个请求首部字段，并且只能用在GET或者HEAD请求中。Last-Modified是一个响应首部字段，包含服务器认定的资源作出修改的日期及时间。当带着If-Modified-Since头访问服务器请求资源时，服务器会检查Last-Modified，如果Last-Modified的时间早于或等于If-Modified-Since则会返回一个不带主体的304响应，否则将重新返回资源。

> If-Modified-Since: , :: GMT Last-Modified: , :: GMT


2.ETag/If-None-Match 

ETag是一个响应首部字段，它是根据实体内容生成的一段hash字符串，标识资源的状态，由服务端产生。If-None-Match是一个条件式的请求首部。如果请求资源时在请求首部加上这个字段，值为之前服务器端返回的资源上的ETag，则当且仅当服务器上没有任何资源的ETag属性值与这个首部中列出的时候，服务器才会返回带有所请求资源实体的200响应，否则服务器会返回不带实体的304响应。ETag优先级比Last-Modified高，同时存在时会以ETag为准。

> If-None-Match: <etag_value> If-None-Match: <etag_value>, <etag_value>, … If-None-Match: *

![image](/images/2018-04-14-http-cache/161233e63a97e53e.png)

> 
ETag属性之间的比较采用的是弱比较算法，即两个文件除了每个比特都相同外，内容一致也可以认为是相同的。例如，如果两个页面仅仅在页脚的生成时间有所不同，就可以认为二者是相同的。

因为ETag的特性，所以相较于Last-Modified有一些优势：


```
某些情况下服务器无法获取资源的最后修改时间
资源的最后修改时间变了但是内容没变，使用ETag可以正确缓存
如果资源修改非常频繁，在秒以下的时间进行修改，Last-Modified只能精确到秒
```

### 整体流程

![image](/images/2018-04-14-http-cache/161233e6685e5e73.png)

### 用户行为对浏览器的影响

![image](/images/2018-04-14-http-cache/181722532916918.png)

参考资料：

[透过浏览器看HTTP缓存](http://www.cnblogs.com/skylar/p/browser-http-caching.html)

[浅谈浏览器http的缓存机制](http://www.cnblogs.com/vajoy/p/5341664.html)

[浏览器HTTP缓存机制](https://juejin.im/post/5a673af06fb9a01c927ed880)
