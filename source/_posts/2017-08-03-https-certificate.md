---
title: HTTPS自建CA及自签名证书不完全指南（实战篇）
date: 2017-08-03 18:00
category: 网络安全
tags: [OpenSSL,HTTPS,Node.js,nginx]
author: Jin
---

在[上一篇](/posts/2017-07-17-https-certificate/)文章中，我们讲解了HTTPS自建CA及自签名证书相关的一些理论知识。本文将使用OpenSSL进行实战。

首先，需要安装好OpenSSL。Mac / Linux都有内置OpenSSL，但是版本并不是很新，建议自己再安装一个新版。

Mac可以使用homebrew进行安装，Linux可以通过包管理工具安装。Windows安装略麻烦一些，可以参考其它教程。也可以查看[这里](https://wiki.openssl.org/index.php/Binaries)试一下第三方提供的二进制包。

<!-- more -->

## CA和根证书

之前我们说过，CA也就是需要一个私钥和一个证书。而证书的生成需要首先有CSR，然后有私钥签名。因此大致过程如下：

### 第一步 生成CA私钥

```sh
openssl genrsa -out ca.key 1024
```

这样就得到了一个名为`ca.key`的私钥。

### 第二步 生成CSR

```sh
openssl req -new -key ca.key -out ca.csr -sha256
```

这一步会要求输入一些信息，按提示输入即可。需要注意的是，如果你想直接用根证书来配置服务器，那么Common Name一项必须填写域名，否则可以随意填写。最后，在空一行之后出现的`extra`可以直接回车，不用填。

![生成CSR](/images/2017-08-03-https-certificate/01-ca_key.png)

### 第三步 生成证书

生成证书的过程即是CA使用私钥对CSR进行签名的过程。在这里我们使用CA自己的证书对自己的CSR进行签名，即可得到根证书：

```sh
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt -sha256
```

默认情况下，证书的有效期是一个月。一般我们会通过`-days`参数（单位为天）将CA证书的有效期设得比较长，以免需要不时去更换：

```sh
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt -sha256 -days 3650
```

至此我们就有了作为CA使用的私钥和根证书。

## 使用CA签发证书

前文说过，直接使用CA配置服务器并不是很方便，因为要为每个证书配置信任关系。更好的方式是生成一次根证书，然后使用根证书的私钥为不同的域名签署不同的证书。具体的步骤和生成CA证书基本一致，只有最后签名的一步略有不同。

### 生成私钥

```sh
openssl genrsa -out server.key 1024
```

### 生成CSR

```sh
openssl req -new -key server.key -out server.csr -sha256
```

同样的需要填写一些信息，最重要的是`CommonName`需要填对。如果你的证书要在多个域名上使用的话，`CommonName`可以只填写一个，其余的到`.ext`中去指定。

### 准备server.ext文件

```
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName=@alt_names

[alt_names]
DNS.1=ssltest.com
```

如果有多个域名的话，分别在`[alt_names]`中指定，一行一个。

### 签署证书

```sh
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -extfile server.ext -sha256 -days 365
```

这一步和生成根证书的命令略有不同。

首先我们看到多了`-CA`和`-CAkey`两个参数，分别对应前面生成的CA私钥和CA根证书。表示需要使用CA的私钥来进行签名。

然后，因为我们指定了CA，所以不再需要`-signkey`参数。

最后，多了一个`CAcreateserial`参数。这个参数的作用是用来生成一个`ca.srl`文件。而这个文件的作用是记录当前CA生成的证书的序列号。而如果再次在同样的位置进行命令，OpenSSL会去读取这个文件中的序列号，并自动`+1`作为下一个证书的序列号。

这样，我们就有了服务器的私钥和证书，可以用于配置服务器了。

![根证书签名后的证书受信任](/images/2017-08-03-https-certificate/03-ca_signed_cert.png)

ok ， 大功告成！！！！！

## 附：根证书直接使用

> 注：大部分情况下我们不会拿CA根证书直接用于服务器配置，因此可以不用看本节内容。如果你一定要拿CA证书配置服务器的话，往下看。

前面说过，如果我们在CSR中指定了`CommonName`，是可以直接拿根证书去配置服务器的。但是如果我们将这个证书加入操作系统信任列表，并配置服务器之后，浏览器仍然会报不信任：

![根证书不受信任](/images/2017-08-03-https-certificate/02-ca_cert_invalid.png)

我们可以看到浏览器给出了“Subject Alternative Name Missing”的错误。查看证书的话，内容如下：

```
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number:
            ec:97:d7:aa:0e:33:89:f8
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=CN, ST=Guangdong, L=Shenzhen, O=TooBug, OU=TooBug, CN=toobug.net/emailAddress=i@toobug.net
        Validity
            Not Before: Aug  3 08:12:18 2017 GMT
            Not After : Sep  2 08:12:18 2017 GMT
        Subject: C=CN, ST=Guangdong, L=Shenzhen, O=TooBug, OU=TooBug, CN=toobug.net/emailAddress=i@toobug.net
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (1024 bit)
                Modulus:
                    00:cb:cf:c8:80:d4:39:6e:0c:17:9c:87:1a:4b:c7:
                    8b:0c:9b:9e:fc:fb:f7:b2:ef:80:e3:90:40:74:a9:
                    47:f3:e0:9b:d0:d2:f5:e3:e4:31:b7:40:9e:47:6e:
                    f6:07:68:39:d0:c7:0b:0f:8e:1e:54:ef:0b:c6:4e:
                    65:17:69:d8:64:7f:8c:80:4d:be:55:10:4f:df:47:
                    5e:6b:c8:f0:d4:3e:94:32:1a:45:80:c9:73:b2:87:
                    09:d1:b0:59:b7:e5:38:50:5b:26:dc:fc:d2:6c:d9:
                    d5:5e:10:2b:1a:a7:b1:61:c1:87:02:5d:f7:70:d5:
                    95:d7:0d:04:02:8c:37:fd:89
                Exponent: 65537 (0x10001)
    Signature Algorithm: sha256WithRSAEncryption
         22:8e:5a:49:4b:8b:59:f9:ca:ae:92:cc:d7:7a:e8:50:21:41:
         35:18:11:d3:82:89:df:8f:8f:3d:39:c8:b2:bc:9b:53:17:89:
         e0:47:85:22:bf:31:c1:47:3a:80:cb:a7:12:00:a9:2c:78:2c:
         02:27:15:19:2a:85:41:f0:78:4b:78:20:fd:51:69:b8:ff:5d:
         af:fc:6c:26:ab:04:33:50:43:a6:91:51:17:a6:47:e4:51:70:
         09:9f:e6:80:88:2d:82:60:22:ec:a1:df:55:2c:c0:43:47:07:
         e7:6c:0c:b5:ac:ba:23:a1:75:50:8a:90:e1:c6:53:7d:49:d2:
         3b:a5
```

和我们前面看过的证书相比，根证书缺少了`X509v3 extensions:`这一节，其中非常重要的一个字段就是`X509v3 Subject Alternative Name:`。这正是导致浏览器报错的原因。

事实上公钥证书体系的应用十分广泛，并不只是在HTTPS中使用。在某些特定的场景下，可能需要一些特定的信息，例如HTTPS下，就需要服务器端的主体信息（域名等）。为了应对这些特殊的场景，X509证书体系引入了扩展字段的概念，也就是`X509v3 extensions`的含义。

我们之前生成的证书并没有包含这个扩展字段，所以才导致浏览器不信任这个证书。所以如果根证书直接用于配置服务器的话，需要再加一个扩展字段。

首先需要准备一个`ca.ext`文件：

```
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName=@alt_names

[alt_names]
DNS.1=ssltest.com
```

注意`[alt_names]`部分，里面的`DNS.1`就是要使用这个证书的域名。如果有多个域名的话，每行写一个，依次使用`DNS.1` `DNS.2`等列出来即可。

然后，带上这个`.ext`文件再次生成证书：

```sh
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt -days 3650 -extfile ca.ext  
```

这样，根证书直接配置服务器的话就可以被浏览器信任了。