---
title: HTTP报文首部格式简介
date: 2018-03-22 12:00
category: 科普
tags: [http,requset,response]
author: Jin
---

HTTP属于应用层协议，HTTP传输的信息被称为HTTP报文。

报文分为2种：

1. 请求报文
2. 响应报文

HTTP报文由2部分组成：报文首部和报文体。中间用空行隔开（CR+LF）。

![报文结构](/images/2018-03-22-http-header/01.jpg)

<!-- more -->

那一个正真的HTTP请求是什么样子呢，下面是用`curl`工具请求`www.google.com`域名时整个HTTP请求和响应报文的信息。
![报文demo](/images/2018-03-22-http-header/03.jpg)

### 1. 请求报文
请求报文是客户端发送给服务器端的报文。

报文首部包括：

1. 请求行
2. 请求首部字段
3. 通用首部字段
4. 实体首部字段
5. 其它

![请求报文首部](/images/2018-03-22-http-header/02.jpg)

客户端发送一个HTTP请求到服务器的请求消息包括以下格式：

![请求报文格式](/images/2018-03-22-http-header/05.jpg)

可以看到使用红框框起来的就是整个HTTP请求报文的信息了。

![请求报文首部](/images/2018-03-22-http-header/04.jpg)

#### 1.1. 请求行
请求行由请求方法和URL和HTTP协议版本构成。

```txt
GET / HTTP/1.1
```

#### 1.2. 通用首部字段
请求报文和响应报文双方都会使用的首部。这是打开阮一峰的[curl](http://www.ruanyifeng.com/blog/2011/09/curl.html)介绍文章的一个HTTP报文信息。

![通用首部字段](/images/2018-03-22-http-header/06.jpg)

##### 1.2.1. Cache-Control
`Cache-Control`能操作缓存的工作机制。指令的参数是可选的，多个指令之间通过“,”分隔。首部字段 `Cache-Control` 的指令可用于请求及响应时。

```txt
Cache-Control: private, max-age=0, no-cache
```
##### 1.2.2. Connection
`Connection`首部字段具备如下两个作用。 

1. 控制不再转发给代理的首部字段
2. 管理持久连接

```txt
Connection: 不再转发的首部字段名
Connection: Keep-Alive
Connection: close
```

> 常设请求首部字段，见附录

### 2. 响应报文
响应报文是服务器端发送给客户端的报文。

报文首部包括：

1. 状态行
2. 响应首部字段
3. 通用首部字段
4. 实体首部字段
5. 其它

![响应报文首部](/images/2018-03-22-http-header/07.jpg)

可以看出和请求报文很相似，除了状态行和响应首部字段，其它的基本是通用的。下图是上面`curl www.google.com` 返回的HTTP报文。

![响应报文首部](/images/2018-03-22-http-header/08.jpg)

通过上图，可以清楚的看到状态码为`302`。可以简单的理解为该资源原本确实存在，但已经被临时改变了位置。

一个完整的响应报文的格式如下：

![响应报文首部](/images/2018-03-22-http-header/09.jpg)


### 3. HTTP攻击

#### 3.1. HTTP首部注入攻击
举个列子，图书管理系统可能会有一个分类页面。通过`/library?catId=XXX`，来查询对应类别的书籍，并触发浏览器跳转。

那其实可以结合HTTP首部的特性，进行首部注入攻击。HTTP首部的首部字段都是按行为单位。

`%0D%0A`代表HTTP报文中的换行符。如果我们设置将上面的url链接改成：

```txt
/library?catId=100%0D%0ASet-Cookie:+UID=123456
```

是不是就可以往Cookie里面添加一个为UID=123456的字段。

```txt
Location: http://www.xxx.com//library?catId=100
Set-Cookie: UID=123456
```

总结就是：通过换行符`%0D%0A`拼接字符串达到注入攻击的效果。

#### 3.2. HTTP响应截断攻击
响应截断攻击是用在HTTP首部注入的一种攻击。

攻击的方法就是同时插入2个`%0D%0A`并排与字符串一起发送。利用连续的2个换行符作出HTTP首部与主体分隔的样子，就可以显示伪造的主体，达到攻击效果。

注入的字符串：

```txt
%0D%0A%0D%0A<html><head><title>HTTP攻击</title><head><body>想要展示的攻击内容</body></html> <!-- 注释掉后面所有的内容
```

得到的响应体如下：

```txt
Location: http://www.xxx.com//library?catId=100
Set-Cookie: UID=123456

<html><head><title>HTTP攻击</title><head><body>想要展示的攻击内容</body></html> <!-- 注释掉后面所有的内容
```

### 4. 附录

#### 4.1 常设请求首部字段
上面的案例可以看出，请求报文中出现了几个常设的请求首部字段。现在来看看常见的请求首部报文有哪些。

| 字段 | 说明 | 案例 |
| --- | --- | --- |
| Accept | 能够接受的回应内容类型（Content-Types）| Accept: text/plain |
| Accept-Charset | 能够接受的字符集 | Accept-Charset: utf-8 |
| Accept-Encoding | 能够接受的编码方式列表。参考HTTP压缩。| Accept-Encoding: gzip, deflate |
| Accept-Language | 能够接受的回应内容的自然语言列表。参考 内容协商 | Accept-Language: en-US | 
| Authorization | 用于超文本传输协议的认证的认证信息 | Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ== |
| Cache-Control | 用来指定在这次的请求/响应链中的所有缓存机制 都必须 遵守的指令 | Cache-Control: no-cache |
| Connection | 该浏览器想要优先使用的连接类型 | Connection: keep-alive / Connection: Upgrade |
| Cookie | 之前由服务器通过 Set- Cookie （下文详述）发送的一个 超文本传输协议Cookie | Cookie: $Version=1; Skin=new; |
| Content-Length | 以八位字节数组（8位的字节）表示的请求体的长度 | Content-Length: 348 |
| Content-Type | 请求体的 多媒体类型 （用于POST和PUT请求中）| Content-Type: application/x-www-form-urlencoded |
| Date | 发送该消息的日期和时间(按照 RFC 7231 中定义的"超文本传输协议日期"格式来发送) | Date: Tue, 15 Nov 1994 08:12:31 GMT |
| Expect | 表明客户端要求服务器做出特定的行为 | Expect: 100-continue |
| From | 发起此请求的用户的邮件地址 | From: user@example.com |
| Host | 服务器的域名(用于虚拟主机 )，以及服务器所监听的传输控制协议端口号。标准端口号可被省略。| Host: en.wikipedia.org:80 / Host: en.wikipedia.org |
| If-Match | 仅当客户端提供的实体与服务器上对应的实体相匹配时，才进行对应的操作。主要作用时，用作像 PUT 这样的方法中，仅当从用户上次更新某个资源以来，该资源未被修改的情况下，才更新该资源。| If-Match: "737060cd8c284d8af7ad3082f209582d" |
| If-Modified-Since | 允许在对应的内容未被修改的情况下返回304未修改（ 304 Not Modified ）| If-Modified-Since: Sat, 29 Oct 1994 19:43:31 GMT |
| If-None-Match | 允许在对应的内容未被修改的情况下返回304未修改（ 304 Not Modified ），参考 超文本传输协议 的实体标记 | If-None-Match: "737060cd8c284d8af7ad3082f209582d" |
| If-Range | 如果该实体未被修改过，则向我发送我所缺少的那一个或多个部分；否则，发送整个新的实体 | If-Range: "737060cd8c284d8af7ad3082f209582d" |
| If-Unmodified-Since | 仅当该实体自某个特定时间已来未被修改的情况下，才发送回应。| If-Unmodified-Since: Sat, 29 Oct 1994 19:43:31 GMT |
| Max-Forwards | 限制该消息可被代理及网关转发的次数。|  Max-Forwards: 10 |
| Origin | 发起一个针对 跨来源资源共享 的请求（要求服务器在回应中加入一个‘访问控制-允许来源’（'Access-Control-Allow-Origin'）字段） | Origin: http://www.example-social-network.com  |
| Proxy-Authorization | 用来向代理进行认证的认证信息。| Proxy-Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ== |
| Range | 仅请求某个实体的一部分。字节偏移以0开始。参见字节服务。 | Range: bytes=500-999 |
| Referer | [sic] [11]  表示浏览器所访问的前一个页面，正是那个页面上的某个链接将浏览器带到了当前所请求的这个页面。| Referer: http://en.wikipedia.org/wiki/Main_Page|
| User-Agent | 浏览器的浏览器身份标识字符串 | User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:12.0) Gecko/20100101 Firefox/21.0 |
| Upgrade | 要求服务器升级到另一个协议。| Upgrade: HTTP/2.0, SHTTP/1.3, IRC/6.9, RTA/x11 |

### 参考

[https://zh.wikipedia.org/zh-hans/HTTP%E5%A4%B4%E5%AD%97%E6%AE%B5](https://zh.wikipedia.org/zh-hans/HTTP%E5%A4%B4%E5%AD%97%E6%AE%B5)

[https://book.douban.com/subject/25863515/](https://book.douban.com/subject/25863515/)