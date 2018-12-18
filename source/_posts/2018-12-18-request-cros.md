---
title: Nginx跨域请求配置
subtitle: 网站开发过程中，会遇上跨越请求，如果不进行跨越配置，这无法正常访问。
cover: /images/2018-12-18-request-cros/cover.jpg
date: 2018-12-18 20:00
categories: [后端]
author: Jin
---

今天碰到一个跨域请求的问题。`a.domain.com` 域名下需要请求`b.domain.com`下的接口。

不做任何处理，正常情况下回报以下错误：

![cros](/images/2018-12-18-request-cros/01.png)


## 解决方案
浏览器端需要对发起的请求做跨域处理。设置`xhr`的属性`withCredentials = true`。

```js
var xhr = new XMLHttpRequest();
xhr.open('GET', 'http://example.com/', true);
xhr.withCredentials = true;
xhr.send(null);
```

Nginx也需要做对应的`Access-Control-Allow-Origin`设置。

```
if ($http_origin ~* ^https://[a-z\\d]+\.domain\.com$){
    add_header 'Access-Control-Allow-Origin' '$http_origin';
    add_header 'Access-Control-Allow-Credentials' 'true';
    add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS';
    add_header 'Access-Control-Allow-Headers' 'Cookie,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
}
```

> 只要是`*.domain.com`的域名都可以正常访问。

这样，就可以满足了。