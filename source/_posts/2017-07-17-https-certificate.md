---
title: HTTPS自签名CA证书
date: 2017-07-17 18:00
category: 网络安全
tags: [OpenSSL,HTTPS,Node.js]
author: Jin
---

HTTPS服务是工作在SSL/TLS上的HTTP。

首先简单区分一下HTTPS，SSL ，TLS ，OpenSSL这四者的关系：

1. SSL：（Secure Socket Layer，安全套接字层）是在客户端和服务器之间建立一条SSL安全通道的安全协议；
2. TLS：（Transport Layer Security，传输层安全协议），用于两个应用程序之间提供保密性和数据完整性；
3. TLS的前身是SSL；
4. OpenSSL是TLS/SSL协议的开源实现，提供开发库和命令行程序；
5. HTTPS是HTTP的加密版，底层使用的加密协议是TLS。

结论：SSL/TLS 是协议，OpenSSL是协议的代码实现。

## 图说HTTPS

![https-demo](/images/2017-07-17-https-certificate/demo.png)

<!-- more -->

可以看到浏览器上面展示的url前面会加一把绿色的锁，表示这个是安全的HTTPS url。要达到这个目标需要什么：

1. HTTPS服务器：server私钥 + CA签发的证书  
2. client客户端：CA证书
3. nginx
4. 配置hosts

## 一个简单的HTTPS服务器
Node.js底层引入了OpenSSL开源库，OpenSSL是HTTPS模块的安全保障。下面来创建一个HTTPS服务器。

```js
const https = require('https');
const fs = require('fs');
let options = {
  key: fs.readFileSync('./server.key'),//私钥
  cert: fs.readFileSync('./server.crt')//数字证书
};
https.createServer(options , (req , res)=>{
  console.log('server got it');
  res.writeHead(200);
  res.end('hello https is work');
}).listen(8888);
console.log('server start');
```

可以发现https服务器比http服务器要多一个`options`参数。`options`里面包含的是https服务器的密钥和数字证书。

问题来了：

1. 密钥是什么？
2. 数字证书（CA：Certificate Authority）是什么？

### SSL/TLS密钥
SSL/TLS是一个公钥和私钥的结构，非对称结构，每个客户端和服务器端都有自己的公钥和私钥。公钥用来加密数据，私钥用来对数据解密。

![ssl](/images/2017-07-17-https-certificate/ssl.jpg)

总结：解决数据加密和解密的问题。

好，现在通过命令行执行OpenSSL生成服务器私钥：

```
openssl genrsa -out server.key 1024
```

> 没有安装openssl命令行的需要自行安装。

### 数字证书
数据都加密了，为什么还要数字证书啊？

公私钥的非对称加密虽然好，但是网络还是可能存在窃听的情况。典型的例子：中间人攻击。

![ssl-ca](/images/2017-07-17-https-certificate/ssl_ca.jpg)

原理和HTTP代理服务器一样。

为了确保数据安全引入了CA。CA会给上面创建的HTTPS服务器颁发数字证书。

现在有权威的CA机构的证书费用都很昂贵，有钱的可以去买，没钱的只能自签名CA证书了。

## 自签名证书
所谓的自签名证书，就是自己扮演CA机构，给自己的服务器颁发签名证书。

### CA机构
自己扮演CA角色，必须要准备好CA机构相关的文件。包括：私钥，CSR文件，CA证书。

1.命令行生成CA私钥:

```
openssl genrsa -out ca.key 1024
```

2.命令行生成CSR文件：

```
openssl req -new -key ca.key -out ca.csr
```

![ca](/images/2017-07-17-https-certificate/ca.png)

CSR是Cerificate Signing Request的英文缩写（即证书请求文件），是证书申请者向证书颁发机构（CA）申请证书时需要提供的文件。里面包含了一些申请者的基本信息，比如Common Name、 Organization等。同时也包含了申请者的公钥。

3.命令行生成CA自签名证书：

```
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt
```

CA机构的文件准备完毕，可以准备为HTTPS服务器颁发证书咯。

### 颁发签名证书
HTTPS服务器的私钥（上文的：`server.key`）已经生成。通过服务器私钥生成CSR文件提交给CA机构，CA机构通过自己的证书，私钥和服务器的CSR文件来给服务器颁发带CA认证的证书。

1.首先HTTPS服务器得准备CSR文件：

```
openssl req -new -key server.key -out server.csr
```

![server](/images/2017-07-17-https-certificate/server.png)

2.CA机构颁发服务器证书：

```
openssl x509 -req -sha256 -extfile v3.ext -CA ca.crt -CAkey ca.key -CAcreateserial -in server.csr -out server.crt
```

上面指定了证书的版本号为[X.509](https://en.wikipedia.org/wiki/X.509)的（v3）第3个扩展版本。 上面还指定了CA机构的证书和私钥。还包括服务器的证书申请文件，以及指定的保存服务器证书的文件。

默认的v3.ext 文件：

```txt
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName=@alt_names

[alt_names]
DNS.1=www.test.com
```

> 注意：`DNS.1=www.test.com` 这里指定了给哪个domain，与自己服务器域名要保持一致。

一句话概括：CA机构给服务器颁发哪个版本的证书。

## 实战之谈
 准备工作都做好了，现在就来访问一下呗。

1.启动server：

 ```
 node server.js
 ```

2.配置nginx

```
server{
    listen 443;
    server_name www.test.com;
    client_max_body_size 128M;

    index index.html index.htm;
    error_log D:/Wnmp/logs/error_test.com.log;
    access_log D:/Wnmp/logs/access_test.com.log combined;
    
    ssl             on;
    ssl_certificate E:/node/https/server.crt;
    ssl_certificate_key     E:/node/https/server.key;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !MEDIUM";
    ssl_prefer_server_ciphers on;

    add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";

    location / {
        proxy_pass https://127.0.0.1:8888/;
        proxy_redirect default ;
    }
}
```

3.配置host:

```
127.0.0.1    www.test.com
```

现在让我们打开chrome浏览器：https://www.test.com

![https_403](/images/2017-07-17-https-certificate/https_403.png)

靠。。。。。被忽悠了吗？什么情况？？？？？？

回想一下，漏掉了什么吗？

### CA证书安装
没错我们客户端的CA证书还没有安装啊。自己签发的证书是需要自己手动安装的。

1.找到生成好的`ca.crt`证书，双击点击安装：

![ca_install](/images/2017-07-17-https-certificate/ca_install.png)

2.选择安装为受信任的根证书颁发机构：

![ca_save](/images/2017-07-17-https-certificate/ca_save.png)


好了，关闭浏览器重新访问：

![https-demo](/images/2017-07-17-https-certificate/demo.png)

ok ， 大功告成！！！！！

## 总结
现在回顾一下这整个颁发证书的流程：

![https_ca](/images/2017-07-17-https-certificate/https_ca.jpg)


项目目录结构：

![dir](/images/2017-07-17-https-certificate/dir.png)