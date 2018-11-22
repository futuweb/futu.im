---
title: 【译】nginx是如何处理请求的
subtitle: Nginx首先需要确定由哪个`server`来处理请求。
date: 2017-05-05 12:55
categories: [后端]
author: TooBug
---

Nginx首先需要确定由哪个`server`来处理请求。我们看一个简单的配置文件，在`*:80`端口上包含了三个虚拟主机（`server`）：

```
server {
    listen      80;
    server_name example.org www.example.org;
    ...
}

server {
    listen      80;
    server_name example.net www.example.net;
    ...
}

server {
    listen      80;
    server_name example.com www.example.com;
    ...
}
```

在这个配置下，Nginx只通过请求的`Host`头来决定路由到哪个`server`。如果`Host`头的值跟所有的`server`的`server_name`都不匹配，或者请求中没有包含这个阔大，Nginx会使用这个端口上的默认`server`。在这个配置文件中，默认`server`是指第一个，这正是Nginx标准的默认行为。默认`server`也可以通过配置显示指定，只需要在`listen`指令值中加上`default_server`参数即可。

<!-- more -->

```
server {
    listen      80 default_server;
    server_name example.net www.example.net;
    ...
}
```

> `default_server`参数在 0.8.21 版本之后可用。在更早的版本中，应该使用`default`参数。

值得注意的是，默认`server`是`listen`指令的参数，而不是`server_name`的。下文会详细介绍。

## 如何阻止没有指明 Host 的请求

如果要禁止没有包含`Host`头的请求，可以用下面的配置让一个`server`丢弃这样的请求：

```
server {
    listen      80;
    server_name "";
    return      444;
}
```

如果请求没有带`Host`头，将与`server_name`为空字符串的`server`匹配，返回非标准的私有状态码444时，Nginx会关闭连接。

> 从 0.8.48 版本开始，空字符串是`server_name`的默认值，因此`server_name ""`可以省略。在更早的版本中，默认值是机器的主机名。

## 基于 IP 和基于主机名的虚拟主机

我们来看一个更复杂的例子，这个例子中有一些监听在不同地址上的`server`：

```
server {
    listen      192.168.1.1:80;
    server_name example.org www.example.org;
    ...
}

server {
    listen      192.168.1.1:80;
    server_name example.net www.example.net;
    ...
}

server {
    listen      192.168.1.2:80;
    server_name example.com www.example.com;
    ...
}
```

在这个配置中，Nginx 首先将请求的 IP 地址和端口与`server`进行匹配，得到一些匹配的`server`。然后根据请求的`Host`头与这些`server`的`server_name`进行匹配。如果`server_name`无法匹配，则请求将由默认`server`处理。例如，在`192.168.1.1:80`上收到一个`www.example.com`的请求，这个请求将由`192.168.1.1:80`上的默认`server`进行处理，也就是由第一个`server`进行处理，因为无法在这个（IP 地址和）端口上匹配到`www.example.com`。

前面已经说过，默认`server`是`listen`指令的一个参数，那么监听不同的（IP 地址和）端口就可以指定不同的默认`server`：

```
server {
    listen      192.168.1.1:80;
    server_name example.org www.example.org;
    ...
}

server {
    listen      192.168.1.1:80 default_server;
    server_name example.net www.example.net;
    ...
}

server {
    listen      192.168.1.2:80 default_server;
    server_name example.com www.example.com;
    ...
}
```

## 一个简单的 PHP 站点配置

现在我们通过一个简单的 PHP 站点来看一下 Nginx 是如何处理`location`的：

```
server {
    listen      80;
    server_name example.org www.example.org;
    root        /data/www;

    location / {
        index   index.html index.php;
    }

    location ~* \.(gif|jpg|png)$ {
        expires 30d;
    }

    location ~ \.php$ {
        fastcgi_pass  localhost:9000;
        fastcgi_param SCRIPT_FILENAME
                      $document_root$fastcgi_script_name;
        include       fastcgi_params;
    }
}
```

Nginx 首先会通过遍历字符串的方式查找指向最具体的`location`前缀，这与配置顺便无关。在上面的楝文件中，唯一的前缀是`/`，它可以匹配任意请求，将被最后使用。然后 Nginx 会按照配置书写的顺序进行正则表达式匹配。一旦匹配到第一条规则，则会停止后续查找，Nginx 将使用这个`location`。如果正则表达式匹配全部失败了，则 Nginx 会使用前面找到的前缀指向最具体的`location`。

值得注意的是，所有类型的`location`都只匹配请求的`URI`部分，不包括任何参数。这是因为请求的参数可能有很多种形式，例如：

```
/index.php?user=john&page=1
/index.php?page=1&user=john
```

此外，用户可以在参数中随便添加任何东西：

```
/index.php?page=1&something+else&user=john
```

现在我们来看看，按上面的配置文件，一个请求将如何被处理：

- 请求`/logo.gif`首先被前缀`location` `/`匹配到，然后被正则表达式`\.(gif|jpg|png)$`匹配到。这样的话，它将由后者进行处理。因为指定了`root /data/www`，因此这个请求将被映射到`/data/www/logo.gif`，这个文件将被发送到客户端。
- 请求`/index.php`也被前缀`location ` `/`匹配到，然后被正则表达式`\.(php)$`匹配到。这样的话，它将由后者进行处理。请求被转交到监听在`localhost:9000`的 FastCGI 服务进行处理。`fastcgi_param`指令会将 FastCGI 的参数`SCRIPT_FILENAME`设置为`/data/www/index.php`，然后 FastCGI 服务会执行这个文件。`$document_root`变量的值等于`root`指令的值，变量`$fastcgi_script_name`的值等于请求的 URI ，也就是`/index.php`。
- 请求`/about.html`只被前缀`location` `/`匹配到，这样它将被在这个`location`中进行处理。因为指定了`root /data/www`，因此这个请求将被映射到`/data/www/about.html`，这个文件将被发送到客户端。
- 请求`/`的处理更复杂一些。它只被前缀`location` `/`匹配到，这样它将被在这个`location`中进行处理。接下来`index`指令将根据`root /data/www`指令的路径探测`index`参数中指定的文件是否存在。如果`/data/www/index.html`不存在，而`/data/www/index.php`存在，则该指令将内部跳转到`/index.php`，然后 Nginx 会像对待新请求一样重新匹配这个请求。如前文所述，这个请求将被 FastCGI 服务进行处理。

编写：Igor Sysoev 编辑：Brian Mercer

原文：<http://nginx.org/en/docs/http/request_processing.html>
