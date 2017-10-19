---
title: HTTPS自建CA及自签名证书不完全指南（理论篇）
date: 2017-07-17 18:00
category: 网络安全
tags: [OpenSSL,HTTPS,Node.js,nginx]
author: Jin
---

HTTPS 全称 HTTP over SSL，即工作于SSL层之上的HTTP协议。它对开发者和使用者是透明的，只是数据传输部分是加密的。

SSL分为 1.0 / 2.0 / 3.0 等很多版本，随着时间的推移，它也变得越来越不安全，因此现在我们通常使用更安全的 TLS 协议。TLS 协议也有不同版本，目前最新最安全的是 TLS 1.2 。一般情况下，我们不会具体区别 SSL 和 TLS，现在很多场合提到的 SSL 其实也是 TLS 协议。

## HTTPS安全浏览

![HTTPS安全浏览](/images/2017-07-17-https-certificate/01-demo.png)

如果我们正在浏览的网页是安全的 HTTPS 网页，则大部分浏览器会显示一把绿色的锁，表示这是加密的连接，且通信过程是安全的。

而要让浏览器认为这个网页是安全的，则需要满足以下几个条件：

1. HTTPS 协议访问
2. 服务端出具的证书内容正确（域名、签名方式等正确）
3. 服务端出具的证书由 CA（数字证书中心） 签发
4. 签发证书的 CA 在浏览器（或操作系统）的受信任列表中

所谓的 CA（数字证书中心）一般是一个机构，它们被内置在浏览器或操作系统的受信任列表中。一个证书只有被 CA 签名过（也叫由 CA 签发的证书），浏览器才可能在受信任列表中找到它对应的 CA ，然后判断是否应该信任这个证书。

> 事实上第3点和第4点并不完全准确，如果一个证书不是由 CA 签发的，但是存在于浏览器（或操作系统）的受信任列表中，那么它事实上相当于一个CA的根证书，也会被认为是安全的。
> 
> 但是，在实际操作中，几乎没有这样的案例，因为几乎没有 CA 会直接拿自己的根证书来让某个网站使用。

<!-- more -->

## HTTPS服务器的搭建

在 Node.js 中配置一个 HTTPS 服务器非常简单。Node.js底层引入了OpenSSL开源库，并直接提供了`https`模块：

```javascript
// 引入https模块
const https = require('https');
const fs = require('fs');

// 创建HTTPS服务需要私钥和证书文件
let options = {
  key: fs.readFileSync('./server.key'), //私钥
  cert: fs.readFileSync('./server.crt') //数字证书
};

// 创建HTTPS服务器
https.createServer(options , (req , res)=>{
  res.writeHead(200);
  res.end('https is working');
}).listen(443);
```

可以发现创建https服务器比我们熟悉的创建http服务器要多一个`options`参数。`options`里面包含的是https服务器的私钥和数字证书。

如果使用`nginx`来创建https服务器，则可能是这样：

```
server
{
    listen 443 ssl;
    server_name  ssltest.com;
    index index.html index.htm;
    root /data/ssltest;

    ssl_certificate /data/ssltest.crt;
    ssl_certificate_key     /data/ssltest.key;

}
```

同样，在上方的配置文件中，需要使用`ssl_certificate_key`和`ssl_certificate`来指定私钥和数字证书。

问题来了：私钥和数字证书分别是什么？

## 科普：HTTPS相关知识

本文将介绍一些与我们接下来生成证书相关的知识。为了简单起见，有一些和实际操作关系不大的、理论性比较强的内容忽略不计。

### HTTPS是如何通信的？

我们都知道HTTPS是加密通信的，但是对于具体的过程，却并不是人人都知道。事实上，HTTPS的通信过程，大致上可以分为握手（非对称加密）和通信（对称加密）两个过程。

握手的部分是使用非对称加密的。既然是非对称加密，就会涉及到公钥、私钥的问题。在经典的非对称加密体系中，公钥用来加密，私钥用来签名，也即如果A同学要向B同学发一个加密信息，那么A同学必须拥有B同学的公钥。同理，如果B同学也要向A同学发加密信息，他也必须拥有A同学的公钥。

在HTTPS中，也是同样的情况，如果双向通信都需要加密的话，那么服务端和客户端各需要一套密钥（私钥+公钥）。而事实上，在握手的部分，客户端的密钥是可选的，常见的HTTPS通信中都没有客户端密钥的参与。那这个过程具体是怎样的呢？

1. 客户端向服务端打个招呼，并告诉服务端，自己要访问哪个域名（SNI），这一步是不加密的
2. 服务端向客户端打招呼，出示自己的证书，同时证书中包含了服务端的公钥，这一步也是不加密的
3. 客户端验证服务端的证书是否合法，如果不合法就中止请求并报错
4. 客户端生成一个后续使用密钥（用于对称加密），使用服务端的公钥对这个密钥进行加密，发送到服务端
5. 服务端对上一步客户端发来的加密消息进行解密并验证

接下来，就使用对称加密来通信了。

![HTTPS握手步骤](/images/2017-07-17-https-certificate/02-steps.png)

### 如何确定通信是安全的

在这个过程中涉及到很多我们接下来会接触到的知识点。

首先，服务端用于加密通信的私钥和公钥都是由自己生成的，稍后我们将看到具体的生成方式。但是，我们从一开始到现在出现过很多次的所谓“证书”是什么呢？以及客户端又是如何验证这个证书是否合法的呢？

我们可以想象一下，如果在客户端和服务端中间，存在一个中间人，就像代理一样。对于客户端来说，它是服务端，对于服务端来说，它又是客户端。这样它就可以两边同时通信，直接窃听整个通信过程，这样我们的加密就毫无意义了。因此必须要有一种机制，来防止中间人攻击。而证书正是这样一种身份验证的机制。

![中间人攻击示意图](/images/2017-07-17-https-certificate/03-mith.jpg)

具体而言，证书大约等于“公钥+身份+签名”三部分。身份主要就是服务器的相关信息，其中一个非常重要的信息就是域名。而签名的过程则是数字证书中心（CA）对身份表示认可，然后使用自己的私钥对这个身份进行签署，表示“我（CA）证明，这个身份是真的”。

使用OpenSSL可以非常方便地查看证书：

```sh
openssl x509 -in futu.im.crt -noout -text
```

如果证书格式是没有BASE64编码过的，则可能是`DER`二进制格式，需要加一个参数：

```sh
openssl x509 -inform der -in futu.im.crt -noout -text
```

下面是<https://futu.im>的证书：

```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            03:8b:7b:f9:68:43:6c:c9:0f:8b:c9:24:42:ea:78:b6:05:51
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, O=Let's Encrypt, CN=Let's Encrypt Authority X3
        Validity
            Not Before: Jul 20 09:21:00 2017 GMT
            Not After : Oct 18 09:21:00 2017 GMT
        Subject: CN=futu.im
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:db:b4:f5:9d:31:d0:7b:1b:76:c0:3a:06:30:a1:
                    da:a9:33:e9:1d:3e:d3:bf:8a:15:d3:b0:17:21:77:
                    2f:e3:f4:59:f9:96:79:a2:b0:80:0c:01:a1:04:4e:
                    b7:c1:fc:da:e6:d0:79:8f:5c:25:64:48:31:58:07:
                    48:fb:19:3e:ae:33:5b:22:73:e3:de:6f:f6:b4:d0:
                    a2:27:26:73:ce:20:4c:d1:05:fc:c8:5e:8a:f4:aa:
                    d0:88:ae:35:db:3e:c5:8d:f7:4c:6d:64:ad:98:fc:
                    63:70:90:a9:68:78:2a:72:df:56:93:ac:65:df:1e:
                    2c:61:ae:bf:a9:d7:32:ff:70:ea:1c:ff:76:60:81:
                    da:55:69:c7:d9:8c:b4:04:ea:85:84:4e:3e:22:dc:
                    e9:c4:56:7d:12:4b:8f:f0:93:9b:5d:0f:e1:ee:e7:
                    37:82:0d:32:41:9e:87:b5:e6:91:2b:b4:28:79:f7:
                    0e:99:d1:86:13:87:1d:fc:6f:c5:38:fd:38:0e:b0:
                    5e:b8:ca:b7:e1:fe:7a:86:86:88:8d:1d:e7:0d:cc:
                    79:82:b2:dd:e2:3d:b7:cc:3b:31:bd:fd:55:12:d8:
                    ab:35:e1:8d:2b:3e:a8:2a:1c:9c:69:5b:15:0f:14:
                    7b:6a:55:03:61:aa:a1:30:c8:a6:5d:c4:92:f9:e5:
                    32:01
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication, TLS Web Client Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                F2:E3:A5:CF:82:0A:72:A0:B3:67:28:DC:33:67:F9:6F:EA:8E:89:29
            X509v3 Authority Key Identifier:
                keyid:A8:4A:6A:63:04:7D:DD:BA:E6:D1:39:B7:A6:45:65:EF:F3:A8:EC:A1

            Authority Information Access:
                OCSP - URI:http://ocsp.int-x3.letsencrypt.org
                CA Issuers - URI:http://cert.int-x3.letsencrypt.org/

            X509v3 Subject Alternative Name:
                DNS:futu.im
            X509v3 Certificate Policies:
                Policy: 2.23.140.1.2.1
                Policy: 1.3.6.1.4.1.44947.1.1.1
                  CPS: http://cps.letsencrypt.org
                  User Notice:
                    Explicit Text: This Certificate may only be relied upon by Relying Parties and only in accordance with the Certificate Policy found at https://letsencrypt.org/repository/

    Signature Algorithm: sha256WithRSAEncryption
         90:9f:34:67:bc:3c:fb:fa:68:2e:97:38:04:bc:89:0a:bc:d0:
         a3:6d:e4:da:5a:ef:56:74:fd:ee:ff:ac:4a:e5:14:c9:b5:f6:
         8a:91:00:a8:42:be:8a:f6:e6:ba:0c:62:bf:f1:9f:a3:e6:e7:
         f0:b4:ab:9c:36:38:6f:81:b6:fd:eb:5f:8a:90:48:db:69:3b:
         03:61:b6:0f:84:e6:11:d3:b8:61:6f:9f:b6:da:16:3d:97:ae:
         a1:ed:21:1f:79:07:fb:95:06:d3:0c:89:d1:a7:fa:58:d0:b8:
         20:a8:2f:5e:51:77:91:e7:b2:b5:9d:f0:e8:d8:53:2b:c3:af:
         6c:de:c4:0a:24:dc:7d:25:31:31:af:a6:fd:9f:ea:44:82:ed:
         97:c5:74:d4:5c:11:3b:be:76:8d:3d:e8:9b:87:d7:d8:ad:21:
         95:82:16:cd:02:bd:12:3c:75:2b:43:c1:41:87:f9:b4:17:9e:
         df:0e:d9:ce:d9:e9:64:c8:23:a1:88:85:a8:25:82:4a:69:a4:
         51:6a:ad:6a:23:bf:7f:ba:98:5f:72:de:a4:25:29:10:e3:27:
         b5:00:16:60:08:0c:cc:f5:5b:88:df:5c:be:6b:10:3a:05:6a:
         61:01:c2:83:d5:88:b4:18:ca:cf:58:d7:14:58:1b:92:f4:69:
         b9:22:a2:3b
```

可以非常清楚地看到几个部分：

1. `Subject Public Key Info`表示服务器的公钥
2. `Subject`是服务器的身份，可以看到`CN=futu.im`字样，视不同的证书，`Subject`中还有可能包含更多信息
3. `Issuer`表示证书的签名机构（CA），最下方则是签名算法和签名出来的结果

那CA又是什么东西呢？它其实就是一些内置在操作系统（浏览器）信任列表中的一些机构，每个机构都拥有自己的根证书，这些证书被操作系统（浏览器）无条件信任。当一个证书被CA签署后，操作系统（浏览器）就会信任这个证书所代表的身份。

CA在签署证书的时候，都会做一些真实性验证，保证只有真实的网站拥有者才可以被签署。因此，当浏览器拿到一个被CA签署过的证书的时候，只要看一下这个CA是不是在信任列表中，就可以决定是否信任这个证书了。

所以这就有了防中间人攻击的关键点：合法的证书是无法伪造的。如果中间人替换了这个证书，浏览器就不会信任这次握手，将中止通信。

那么，在不替换证书的前提下，为什么中间人就无法拦截通信了呢？这是因为证书中包含了服务器的公钥，客户端会使用这个公钥加密信息，而这个信息只有拥有私钥的人才可以解密。很显然，只有真实的服务器才有这个私钥，因此中间人是无法解密了。

## 证书签发过程

证书的签发过程大致分为几个步骤：

1. 生成私钥
2. 生成一个证书签名请求文件（CSR）
3. 对CSR进行签名，颁发证书

第1步非常好理解，就是要生成一个后续通信中用于解密的私钥。私钥中不包含任何主体相关的信息，也就是说生成私钥时并不需要提供任何信息。

第2步则需要提示主体相关信息，可能包括公司、城市、名称（CommonName，简称CN）等信息。这些信息是非常重要的，在HTTPS中，CommonName一般填写网站的域名，这是一个尤其重要的字段，因为它会作为通信过程中判断服务器证书是否合法的一个重要依据，即域名是否相符。在上方我们看到的证书信息中，主体`Subject`甚至只有这唯一的一个字段。

具体而言，一个CSR文件包含三部分信息，一是主体信息和公钥，二是签名方法，三是签名。后两部分其实是为了保证CSR在传输过程中不被修改，以免导致CA被利用，产生滥发证书等问题。

通过OpenSSL也可以查看一个CSR文件的具体信息：

```sh
openssl req -in ssltest.csr -noout -text
```

```
Certificate Request:
    Data:
        Version: 0 (0x0)
        Subject: C=CN, ST=Guangdong, L=Shenzhen, O=futu, OU=futu, CN=ssltest.com/emailAddress=test@example.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (1024 bit)
                Modulus:
                    00:b9:74:77:16:5a:8e:fd:94:22:70:bb:ee:56:46:
                    06:80:26:03:8d:03:4f:36:df:41:7d:28:aa:b6:2c:
                    d7:42:51:d6:28:e1:aa:c4:06:cd:32:22:bd:79:d0:
                    c0:3a:a2:d8:03:8e:38:45:b0:8c:2d:81:f0:b1:5c:
                    6a:97:ec:dc:bb:58:88:62:c3:bf:86:1c:e8:1a:45:
                    ca:50:ac:e6:5e:e2:d3:d5:dd:43:2d:35:05:e0:b8:
                    77:7f:e6:f2:82:37:32:15:1b:52:7f:64:d1:62:d6:
                    9f:ac:bb:ce:86:45:63:52:c5:4e:71:da:82:5b:94:
                    2e:62:fe:37:c6:47:e0:fe:af
                Exponent: 65537 (0x10001)
        Attributes:
            a0:00
    Signature Algorithm: sha256WithRSAEncryption
         01:a2:21:62:6a:5c:03:c2:f8:1a:42:23:a9:d4:12:20:3c:9f:
         af:3c:f1:2c:f5:4d:f8:b6:c5:aa:f5:42:b7:b6:39:5c:a9:2c:
         cb:67:2c:99:1a:85:94:73:05:ce:9a:11:4e:fd:d1:29:f4:ae:
         b9:19:22:bb:ad:53:9c:02:db:04:c0:6f:79:44:37:b0:bd:34:
         8f:96:37:6d:a2:2d:49:aa:62:d1:75:2f:eb:b7:08:6b:d8:f5:
         d1:db:16:7b:2f:9c:fd:c9:85:36:3c:2f:15:67:08:45:9d:1d:
         a2:50:6e:f5:f4:3b:4a:d6:5c:50:5f:6c:ef:d1:f7:79:33:42:
         81:8a
```

我们可以非常清楚地看到，一个CSR文件中包含了主体信息和公钥。

CA在拿到CSR文件之后就会去做一些合法性判断，例如判断域名（CommonName）所有者是不是你之类的，如果确定合法之后，就会使用CA自己的私钥对提交上来的这个公钥和主体进行签名，从而产生一张证书。

我们看到CSR文件的信息和证书的信息非常像，主要就是缺少了最后的签名部分。（当然还有extensions部分，稍后说明。）

## 无CA时自签名（根）证书

事实上，CA也没有什么很神秘的地方，它最重要的东西也是一个私钥和一个自己签名的证书。拥有这一对私钥和证书，我们就完全可以充当一个CA了。（是否被信任是另一回事。）

因此，我们完全可以自己生成这样一对私钥和证书。只要将这个证书加入到系统（浏览器）的信任列表中，就可以被信任了。

下面是windows机器设置信任根证书的方法，注意第二步中，一定要选择“受信任的根证书颁发机构”这一项才能生效。

![windows安装CA证书](/images/2017-07-17-https-certificate/04-win_ca_install.png)

![windows安装CA证书](/images/2017-07-17-https-certificate/05-win_ca_save.png)

Mac下设置信任的方法：

![Mac信任根证书](/images/2017-07-17-https-certificate/06-mac_ca_trust.png)

如果我们将证书的CommonName和网站的域名设置成一致的，我们就可以直接拿这个根证书去配置HTTPS服务了。

![根证书直接配置HTTPS](/images/2017-07-17-https-certificate/07-ca_root_trust.png)

可以看到，此时证书只有一级，即根证书，但是因为根证书的CommonName就用的ssltest.com，因此被信任了。

直接将CA证书用于网站HTTPS配置的话，优点是操作非常简单，不用考虑CA什么的。缺点也很明显：

1. 每一个不同的域名都需要一个不同的根证书
2. 每个根证书都需要在系统（浏览器）设置一次信任

## 使用CA自签名证书

如果我们把上一步的证书当成根证书来用，而不是直接用来配置服务器，我们就有了一个CA。

接下来我们需要配置网站的时候，就需要再生成一个私钥和CSR，然后由CA对CSR中的主体和公钥进行签名，得到一个证书。这样就有了一个CA签名的证书，可以用于服务器的配置。

![根证书签名后受信任](/images/2017-07-17-https-certificate/08-ca_signed_cert.png)

## 小结

至此，我们比较详细地了解了HTTPS的通信过程以及安全机制。中间涉及到了私钥、公钥、CA、签名等比较重要的概念。[下一篇](/posts/2017-08-03-https-certificate/)中，我们将看到如何使用OpenSSL进行自签名证书。
