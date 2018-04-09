---
title: HTTP文件断点续传理论
date: 2018-04-04 22:00
category: HTTP
tags: [文件下载,HTTP]
author: Arlvin
---

> 免责声明：内容由作者分享，本文编写由 [Jin](/author/Jin) 代为执笔。

大家都有在网上下载文件的经历。文件下载到一半时，如果发生网络中断。会发现当网络恢复后，一般会继续下载剩下的部分而不是重头开始下载。

其实背后就是HTTP断点续传。它是HTTP知识里面的一个比较基础的东西。

<!-- more -->

## 断点续传的定义
就是在下载的断开点继续开始继续下载下载的内容，不用再从头开始下载。在HTTP1.1 协议（[RFC2616](https://tools.ietf.org/html/rfc2616)）开始支持断点续传，也就是1999年开始支持这个功能。

### 相关概念
HTTP实现断点续传是通过HTTP报文头部header里面设置的两个参数Range和`Content-Range`实现。


#### Range
客户端发送请求报文里面带上Range参数，用于表示需要请求哪个范围的数据。

> 指定第一个字节的位置和最后一个字节的位置。

一般格式：

```txt
Range:(unit=first byte pos)-[last byte pos]
```

#### Content-Range
服务器响应报文带上`Content-Range`参数，表示返回的数据范围和文件大小。

> 用于响应头中，在发出带 Range 的请求后，服务器会在`Content-Range`头部返回当前接受的范围和文件总大小。

一般格式：

```txt
Content-Range: bytes (unit first byte pos) - [last byte pos]/[entity legth]
```

#### If-Range
用于请求头中，服务器根据它判断实体是否发生改变，如果实体未改变，服务器发送客户端丢失的部分，否则发送整个实体。

一般格式：

```txt
If-Range: Etag | HTTP-Date
```

工作原理：If-Range中的内容可以为最初收到的ETag头或者是Last-Modfied中的最后修改时候。服务端在收到续传请求时，通过If-Range中的内容进行校验，校验一致时返回206的续传回应，不一致时服务端则返回200回应，回应的内容为新的文件的全部数据。

#### Last-Modified
`If-Modified-Since` 和 `Last-Modified` 一样都是用于记录页面最后修改时间的HTTP头信息，只是 `Last-Modified` 是由服务器往客户端发送的HTTP头，而`If-Modified-Since`是由客户端往服务器端发送的头。

#### Etag
ETag 头由服务器端生成，来放置文件的唯一标识。Etag（Entity Tags）主要为了解决 Last-Modified 无法解决的一些问题。

* 文件周期性更改，内容未改变；
* 文件修改频繁，1s 内修改了 N 次，If-Modified-Since 能检查到的粒度是s级的；
* 某些服务器不能精确的得到文件的最后修改时间。


## 断点续传实例
现在来看看实际当中的断点续传是怎样的。

就以百度的logo图片为例子：

![baidu](https://www.baidu.com/img/bd_logo1.png)

上面是一张百度的logo图片。通过命令行执行`curl`命令来看看它支不支持断点续传（也就是把文件切割开来，分别下载）。

第一次执行：

```sh
curl -D "dump1.txt" -H "Range: bytes=0-2000" https://www.baidu.com/img/bd_logo1.png -o part1
```

上面的指令会把图片的`0-2000`之间的字节保存到文件 part1 中。

我们先来看看请求的情况：

通过命令`cat dump1.txt`打开文件，查看本次请求响应的相关信息：

```txt
HTTP/1.1 206 Partial Content
Accept-Ranges: bytes
Cache-Control: max-age=315360000
Connection: Keep-Alive
Content-Length: 2001
Content-Range: bytes 0-2000/7877
Content-Type: image/png
Date: Wed, 14 Mar 2018 06:35:47 GMT
Etag: "1ec5-502264e2ae4c0"
Expires: Sat, 11 Mar 2028 06:35:47 GMT
Last-Modified: Wed, 03 Sep 2014 10:00:27 GMT
Server: Apache
```

最重要的是第一行：返回状态码`206`表示支持断点续传。[状态码相关](/posts/2018-03-20-http-status-code/)。里面也包含了上面我们是提到的`Content-Range`。

```txt
Content-Range: bytes 0-2000/7877
```

表示本次返回的是`0-2000`字节，一共有7877字节。

同理，第二次我们请求`2001-4000`字节的内容，保存到文件`part2`中：

```sh
curl -D "dump2.txt" -H "Range: bytes=2001-4000" https://www.baidu.com/img/bd_logo1.png -o part2
```

打开相应的请求响应信息文件`dump2.txt`，可以确定却是返回了`2001-4000`字节的内容。

```txt
HTTP/1.1 206 Partial Content
Accept-Ranges: bytes
Cache-Control: max-age=315360000
Connection: Keep-Alive
Content-Length: 2000
Content-Range: bytes 2001-4000/7877
Content-Type: image/png
Date: Wed, 14 Mar 2018 06:36:18 GMT
Etag: "1ec5-502264e2ae4c0"
Expires: Sat, 11 Mar 2028 06:36:18 GMT
Last-Modified: Wed, 03 Sep 2014 10:00:27 GMT
Server: Apache
```

第三次，我们请求到最后的数据保存到`part3`：

```sh
curl -D "dump3.txt" -H "Range: bytes=4001-" https://www.baidu.com/img/bd_logo1.png -o part3
```

到这里，所有的数据都请求到了，会发现单独打开单个文件，看到的是原始数据完全看不懂。可能这个时候可能会想，把后缀名改为`.png`，但其实每一部分并不会单独成为一张图片。

我们需要把3歌部分的数据拼起来，才会是一张图片。

```sh
cat part1 part2 part3 >> logo.png
```

通过`cat`命令，把3个部分的数据保存到名为`logo.png`的文件。神奇的事情发生了。

![baidu](https://www.baidu.com/img/bd_logo1.png)

logo 图片出现了。

## 总结
断点续传有利于节省流量，当遇到大文件需要下载的时候，可以分批次下载。






