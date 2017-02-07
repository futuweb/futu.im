---
title: DNS 请求报文详解
date: 2016-11-16 18:00
category: Node.js
tags: [dns,dgram,JavaScript]
author: Jin
---

## DNS
DNS【域名系统：（英文：Domain Name System，缩写：DNS）】是互联网的一项服务。 它作为将域名和IP地址相互映射的一个分布式数据库，能够使人更方便地访问互联网。 DNS使用TCP和UDP端口53。

## 白话版
就是客户端（例如：浏览器）传入的网站域名，到DNS列表中找到对应的ip返回给客户端，然后客户端根据ip就可以找到对应的服务器，就可以向服务器发送请求了。

说的在直接点：DNS目的就是把对应服务器IP给客户端。最后客户端与服务器通信就没DNS什么事了。

<!--more-->

## DNS 报文格式
DNS报文格式，不论是请求报文，还是DNS服务器返回的应答报文，都使用统一的格式。

*   `Header` 报文头
*   `Question` 查询的问题
*   `Answer`   应答
*   `Authority` 授权应答
*   `Additional` 附加信息

``` 
  DNS format

  +--+--+--+--+--+--+--+
  |        Header      |
  +--+--+--+--+--+--+--+
  |      Question      |
  +--+--+--+--+--+--+--+
  |      Answer        |
  +--+--+--+--+--+--+--+
  |      Authority     |
  +--+--+--+--+--+--+--+
  |      Additional    |
  +--+--+--+--+--+--+--+
```


### Header 报文头

*   `ID`:  `2`个字节(`16bit`)，标识字段，客户端会解析服务器返回的DNS应答报文，获取`ID`值与请求报文设置的`ID`值做比较，如果相同，则认为是同一个DNS会话。
*   `FLAGS`: `2`个字节(`16bit`)的标志字段。包含以下属性:
    *   `QR`: `0`表示查询报文，`1`表示响应报文;
    *   `opcode`: 通常值为`0`（标准查询），其他值为`1`（反向查询）和`2`（服务器状态请求）,`[3,15]`保留值;
    *   `AA`: 表示授权回答（authoritative answer）-- 这个比特位在应答的时候才有意义，指出给出应答的服务器是查询域名的授权解析服务器;
    *   `TC`: 表示可截断的（truncated）--用来指出报文比允许的长度还要长，导致被截断;
    *   `RD`: 表示期望递归(Recursion Desired) -- 这个比特位被请求设置，应答的时候使用的相同的值返回。如果设置了RD，就建议域名服务器进行递归解析，递归查询的支持是可选的;
    *   `RA`: 表示支持递归(Recursion Available) --  这个比特位在应答中设置或取消，用来代表服务器是否支持递归查询;
    *   `Z` : 保留值，暂未使用;
    *   `RCODE`: 应答码(Response code) - 这4个比特位在应答报文中设置，代表的含义如下:
        *   `0` : 没有错误。
        *   `1` : 报文格式错误(Format error) - 服务器不能理解请求的报文;
        *   `2` : 服务器失败(Server failure) - 因为服务器的原因导致没办法处理这个请求;
        *   `3` : 名字错误(Name Error) - 只有对授权域名解析服务器有意义，指出解析的域名不存在;
        *   `4` : 没有实现(Not Implemented) - 域名服务器不支持查询类型;
        *   `5` : 拒绝(Refused) - 服务器由于设置的策略拒绝给出应答.比如，服务器不希望对某些请求者给出应答，或者服务器不希望进行某些操作（比如区域传送zone transfer）;
        *   `[6,15]` : 保留值，暂未使用。
*   `QDCOUNT`: 无符号`16bit`整数表示报文请求段中的问题记录数。
*   `ANCOUNT`: 无符号`16bit`整数表示报文回答段中的回答记录数。
*   `NSCOUNT`: 无符号`16bit`整数表示报文授权段中的授权记录数。
*   `ARCOUNT`: 无符号`16bit`整数表示报文附加段中的附加记录数。

```
  Header format

    0  1  2  3  4  5  6  7  0  1  2  3  4  5  6  7
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                      ID                       |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |QR|  opcode   |AA|TC|RD|RA|   Z    |   RCODE   |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    QDCOUNT                    |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    ANCOUNT                    |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    NSCOUNT                    |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    ARCOUNT                    |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
```


### Question 查询字段

*   `QNAME`  无符号`8bit`为单位长度不限表示查询名(广泛的说就是：域名).
*   `QTYPE`  无符号`16bit`整数表示查询的协议类型.
*   `QCLASS` 无符号`16bit`整数表示查询的类,比如，`IN`代表Internet.

```
  Question format

    0  1  2  3  4  5  6  7  0  1  2  3  4  5  6  7
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                     ...                       |
  |                    QNAME                      |
  |                     ...                       |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    QTYPE                      |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    QCLASS                     |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
```

### Answer/Authority/Additional
这3个字段的格式都是一样的。

*   `NAME` 资源记录包含的域名.
*   `TYPE` 表示`DNS`协议的类型.
*   `CLASS` 表示RDATA的类.
*   `TTL` 4字节无符号整数表示资源记录可以缓存的时间。0代表只能被传输，但是不能被缓存。
*   `RDLENGTH` 2个字节无符号整数表示RDATA的长度
*   `RDATA` 不定长字符串来表示记录，格式根TYPE和CLASS有关。比如，TYPE是A，CLASS 是 IN，那么RDATA就是一个4个字节的ARPA网络地址。

```
  Answer/Authority/Additional format

    0  1  2  3  4  5  6  7  0  1  2  3  4  5  6  7
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    NAME                       |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    TYPE                       |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    CLASS                      |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    TTL                        |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    RDLENGTH                   |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  |                    RDATA                      |
  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

```

## DNS请求报文解析
光说不做假把式。那如何对DNS请求报文进行解析呢。
先来看一下一个DNS请求报文：

```
  6dca 0100 0001 0000 0000 0000 0377 7777
  0561 7070 6c65 0363 6f6d 0000 0100 01 
```

这是一个`Buffer`实例，看完后是不是一脸懵B，别紧张，先看解析后`console.log`大概的样子，是不是世界瞬间变美好了。

下面是一个请求查询`www.apple.com`网站ip的DNS请求报文。

```
  //Header
  ID:  <Buffer 6d ca>
  FLAG:  QR:  0 opcode:  0 AA:  0 TC:  0 RD:  1
  RA:  0 zero:  0 recode:  0
  QDCOUNT:  <Buffer 00 01> ANCOUNT:  <Buffer 00 00> NSCOUNT:  <Buffer 00 00> ARCOUNT:  <Buffer 00 00>
  
  //QUESTION
  QNAME:  <Buffer 03 77 77 77 05 61 70 70 6c 65 03 63 6f 6d 00> QTYPE:  <Buffer 00 01> QCLASS:  <Buffer 00 01>
  
  QUESTION STRING:  www.apple.com 
```

请求报文解析分为2个小块：

*   `Header`报文头解析
*   `QUESTION`查询问题解析

### Header 报文头解析
对Header部分进行解析。

先确定一下每个字段的大小：

```
  ID: 2 字节
  QR: 1 bit
  opcode: 4bit
  AA: 1bit
  TC: 1bit
  RD: 1bit
  RA: 1bit
  Z : 3bit
  RCODE: 4bit
  QDCOUNT: 2 字节
  ANCOUNT: 2 字节
  NSCOUNT: 2 字节
  ARCOUNT: 2 字节
```

共12个字节。

假如我们抛开第`[3,4]`个字节，其实很容易就可以把header解析，但是单位为`bit`的就需要对`buffer`实例的值进行位运算操作了。

所以以下参数的值可以直接从`buffer`中获取：

```js
  var header = {};

  header.id = buf.slice(0,2);
  header.qdcount = buf.slice(4,6);
  header.ancount = buf.slice(6,8);
  header.nscount = buf.slice(8,10);
  header.arcount = buf.slice(10, 12);
```

难点就是如何获取第`[3,4]`的值，首先需要把`buffer`实例对应的字节转成`2`进制字符串然后转换为数值，然后按参数的长度计算最后的结果。

第一步，将`buffer`转换为2进制字符串然后转换为数值(假设dns报文是`buf`)：

```js
  //对第3个字节转成`2`进制字符串然后转换为数值
  var b = buf.slice(2,3).toString('binary', 0, 1).charCodeAt(0);
```

第2步，进行数据切割：

首先需要理解下面这个函数，功能无非就是提取从`offset`开始，长度为`length`数字位，通过位运算转换为`Integer`类型的数然后返回。

说直白一点，就是把你需要的那一段2进制数据转换为`Integer`类型，并返回。

```js
  var bitSlice = function(b, offset, length) {
      return (b >>> (7-(offset+length-1))) & ~(0xff << length);
  };
```

> 注意这里因为只考虑一个字节 === `8bit`，所以可以写成`(7-(offset+length-1))` 和 `0xff << length`。假如不是一个字节，那么可能需要改变一下里面的数字`7`和`0xff`的值。

demo走起：

```js
  'use strict';

  var buf = Buffer.from([0x2d]);
  var b = buf.toString('binary' , 0,1).charCodeAt(0);

  console.log(bitSlice(b , 0, 1));//0
  console.log(bitSlice(b , 1, 1));//0
  console.log(bitSlice(b , 2, 1));//1
  console.log(bitSlice(b , 3, 1));//0
  console.log(bitSlice(b , 4, 1));//1
  console.log(bitSlice(b , 5, 1));//1
  console.log(bitSlice(b , 6, 1));//0
  console.log(bitSlice(b , 7, 1));//1
  console.log(bitSlice(b , 5, 3));//5  === 0000 0101

  /**
   * 16进制：0x2d
   * 10进制：45
   * 2进制： 0010 1101
   *
   * (45,0,1)：45>>>7 & ~(0xff<<1) 
   *    45>>>7 = 0000 0000
   *    (0xff<<1)  = 0000 0000 0000 0000 0000 0001 1111 1110   510
   *    ~(0xff<<1) = 1111 1111 1111 1111 1111 1110 0000 0001   -511 = -((0xff<<1)+1)
   *
   *      0000 0000 0000 0000 0000 0000 0000 0000  === 45>>>7
   *    & 1111 1111 1111 1111 1111 1110 0000 0001  === ~(0xff<<1)
   *      ----------------------------------------
   *      0000 0000 0000 0000 0000 0000 0000 0000 = 0
   *
   * (45,2,1)：45>>>5 & ~(0xff<<1) 
   *    45>>>5 = 0000 0001
   *    (0xff<<1)  = 0000 0000 0000 0000 0000 0001 1111 1110   510
   *    ~(0xff<<1) = 1111 1111 1111 1111 1111 1110 0000 0001   -511 = -((0xff<<1)+1)
   *
   *      0000 0000 0000 0000 0000 0000 0000 0001  === 45>>>5
   *    & 1111 1111 1111 1111 1111 1110 0000 0001  === ~(0xff<<1)
   *      ----------------------------------------
   *      0000 0000 0000 0000 0000 0000 0000 0001 = 1
   */
```

理解了上面的函数的作用之后就可以真正的使用这个函数取DNS报文Header的第`[3,4]`字节中的值。

信手拈来：

```js
  //第3个字节
  var b = buf.slice(2,3).toString('binary', 0, 1).charCodeAt(0);
  header.qr = bitSlice(b,0,1);
  header.opcode = bitSlice(b,1,4);
  header.aa = bitSlice(b,5,1);
  header.tc = bitSlice(b,6,1);
  header.rd = bitSlice(b,7,1);
  
  //第4个字节
  b = buf.slice(3,4).toString('binary', 0, 1).charCodeAt(0);
  header.ra = bitSlice(b,0,1);
  header.z = bitSlice(b,1,3);
  header.rcode = bitSlice(b,4,4);
```

### QUESTION 查询字段解析
主要包括了查询域名，协议类型及类别。

这3个参数`QTYPE`和`QCLASS`是固定`2`字节，`QNAME`是不固定的。


所以取数据的时候需要注意，因为`QUESTION`信息是跟随在`Header`之后，所以要从第`12`个字节往后取：

```js
var question = {};
  question.qname = buf.slice(12, buf.length-4);
  question.qtype = buf.slice(buf.length-4, buf.length-2);
  question.qclass = buf.slice(buf.length-2, buf.length);
```

`qname`使用的是`len+data`混合编码，以`0x00`结尾。每个字符串都以长度开始，然后后面接内容。`qname`长度必须以`8`字节为单位。

例如`www.apple.com`(注意：中间的`.`是解析的时候自己添加上去的)，它的`buffer`实例表示为：

```
  03 77 77 77 05 61 70 70 6c 65 03 63 6f 6d 00
  //约等于
  3www5apple3com
```

也就是第一位表示的是长度，后面跟随相同长度的数据，依此类推。

```js
  var domainify = function(qname) {
    var parts = [];

    for (var i = 0; i < qname.length && qname[i];) {
      var len = qname[i] , offset = i+1;//获取每一块域名长度

      parts.push(qname.slice(offset,offset+len).toString());//获取每一块域名

      i = offset+len;
    }

    return parts.join('.');//拼凑成完整域名
  };
```


`qtype`协议类型. [查看详情](https://nodejs.org/dist/latest-v6.x/docs/api/dns.html#dns_dns_resolve_hostname_rrtype_callback)

协议类型对应的列表：

| 值 | 协议类型 | 描述 |
| --- | --- | --- |
| 1 | A | IPv4地址 |
| 2 | NS | 名字服务器 |
| 5 | CNAME | 规范名称定义主机的正式名字的别名 |
| 6 | SOA | 开始授权标记一个区的开始 |
| 11 | WKS | 熟知服务定义主机提供的网络服务 |
| 12 | PTR | 指针把IP地址转化为域名 |
| 13 | HINFO | 主机信息给出主机使用的硬件和操作系统的表述 |
| 15 | MX | 邮件交换把邮件改变路由送到邮件服务器 |
| 28 | AAAA | IPv6地址 |
| 252 | AXFR | 传送整个区的请求 |
| 255 | ANY | 对所有记录的请求 |

`qclass`通常为1，指Internet数据.


### 应用场景--dns请求代理
将以下代码保存为`.js`文件，然后使用`Node.js`执行，使用相同局域网内的机器配置DNS到这台机器即可。

以下代码仅供参考：

```js
  'use strict';

  const dgram = require('dgram');
  const dns = require('dns');
  const fs = require('fs');
  const server = dgram.createSocket('udp4');

  var bitSlice = function(b, offset, length) {
      return (b >>> (7-(offset+length-1))) & ~(0xff << length);
  };

  var domainify = function(qname) {
      var parts = [];

      for (var i = 0; i < qname.length && qname[i];) {
          var length = qname[i];
          var offset = i+1;

          parts.push(qname.slice(offset,offset+length).toString());

          i = offset+length;
      }

      return parts.join('.');
  };

  var parse = function(buf) {
      var header = {};
      var question = {};
      var b = buf.slice(2,3).toString('binary', 0, 1).charCodeAt(0);
      console.log('b：',b,buf.slice(2,3));
      header.id = buf.slice(0,2);
      header.qr = bitSlice(b,0,1);
      header.opcode = bitSlice(b,1,4);
      header.aa = bitSlice(b,5,1);
      header.tc = bitSlice(b,6,1);
      header.rd = bitSlice(b,7,1);

      b = buf.slice(3,4).toString('binary', 0, 1).charCodeAt(0);

      header.ra = bitSlice(b,0,1);
      header.z = bitSlice(b,1,3);
      header.rcode = bitSlice(b,4,4);

      header.qdcount = buf.slice(4,6);
      header.ancount = buf.slice(6,8);
      header.nscount = buf.slice(8,10);
      header.arcount = buf.slice(10, 12);

      question.qname = buf.slice(12, buf.length-4);
      question.qtype = buf.slice(buf.length-4, buf.length-2);
      question.qclass = buf.slice(buf.length-2, buf.length);

      return {header:header, question:question};
  };

  server.on('error' , (err)=>{
      console.log(`server error: ${err.stack}`);
  });

  server.on('message' , (msg , rinfo)=>{
      //fs.writeFile('dns.json' ,msg, {flag:'w',endcoding:'utf-8'} ,(err)=>{
      //    console.log(err);
      //});
      var query = parse(msg);
      console.log('标识ID: ' ,query.header.id);
      console.log('标识FLAG: ' , 'QR: ',query.header.qr , 'opcode: ',query.header.opcode , 'AA: ',query.header.aa , 'TC: ',query.header.tc,'RD: ',query.header.rd);
      
      console.log('RA: ',query.header.ra , 'zero: ',query.header.z , 'recode: ',query.header.rcode);

      console.log('QDCOUNT: ',query.header.qdcount , 'ANCOUNT: ' , query.header.ancount, 'NSCOUNT: ' , query.header.nscount,'ARCOUNT: ',query.header.arcount);
          
      console.log('QNAME: ',query.question.qname , 'QTYPE: ', query.question.qtype ,'QCLASS: ' , query.question.qclass);

      console.log('QUESTION STRING: ' ,domainify(query.question.qname));

      server.close();
  });

  server.on('listening' , ()=>{
      var address = server.address();
      console.log(`server listening ${address.address}:${address.port}`);
  });

  server.bind({port:53,address:'8.8.8.8'});//address需要指定到你要用于进行代理的机器ip

```

下一篇： [DNS 响应报文详解](/posts/dns-response)

### 参考资料

[http://docstore.mik.ua/orelly/networking_2ndEd/dns/appa_02.htm](http://docstore.mik.ua/orelly/networking_2ndEd/dns/appa_02.htm)

[http://www.comptechdoc.org/independent/networking/terms/dns-message-format.html](http://www.comptechdoc.org/independent/networking/terms/dns-message-format.html)

[http://www.iprotocolsec.com/2012/01/13/%E4%BD%BF%E7%94%A8wireshark%E5%AD%A6%E4%B9%A0dns%E5%8D%8F%E8%AE%AE%E5%8F%8Adns%E6%AC%BA%E9%AA%97%E5%8E%9F%E7%90%86/](http://www.iprotocolsec.com/2012/01/13/%E4%BD%BF%E7%94%A8wireshark%E5%AD%A6%E4%B9%A0dns%E5%8D%8F%E8%AE%AE%E5%8F%8Adns%E6%AC%BA%E9%AA%97%E5%8E%9F%E7%90%86/)