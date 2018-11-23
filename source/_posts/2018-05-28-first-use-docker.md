---
title: docker 初探
subtitle: 最近搞了几个域名，想着玩一下。碰到了`CoreOS`然后就扒出了docker。
cover: /images/first-use-docker/cover.png
date: 2018-05-28 20:00
categories: [后端]
author: Jin
---

最近搞了几个域名，想着玩一下。碰到了`CoreOS`然后就扒出了docker。好吧，那就玩一把呗。就拿最近的[webpack4-demo](https://github.com/Yi-love/webpack4-demo/tree/step_2) 分支`step_2`试一下。

期望的效果就是：把`webpack4-demo`案例部署在docker容器里面，然后通过绑定外部端口，能在外边（docker容器外部）进行访问。

> 换句话说就是：`webpack4-demo`案例运行在docker里面的`4000`端口，通过绑定外部`8000`端口。在电脑上通过浏览器输入`localhost:8000`可以进行访问。

是不是很简单。

<!-- more -->

那这里就说说到达这个目的需要做的和需要注意的地方。

1. 安装docker环境
2. 编写Dockerfile && .dockerignore 文件
3. 构建生成镜像
4. 启动容器
5. 访问

安装docker并启动基础服务，这个略过。

docker 案例：[webpack4-demo](https://github.com/Yi-love/webpack4-demo/tree/step_2)。

### 编写Dockerfile && .dockerignore 文件
这里主要注意一下Dockerfile文件语法即可。

```
//webpack4-demo/Dockerfile

FROM node:8.4
COPY . /webpack4
WORKDIR /webpack4
RUN npm install -g webpack webpack-cli && npm install && webpack
EXPOSE 4000
CMD ["node","server/index.js"]
```

`FROM` ， 这里项目是在Node.js中运行的，所以要以Node.js为基础。如果为空使用`scratch`。

`RUN`， 主要用来创建镜像的。每一个`RUN`会产生一层镜像，最好不要过多使用`RUN`以免产生不必要的中间层镜像。这里我把`npm install` 和 `webpack`打包当作一层镜像，因为我最后只要启动服务就好了`node server/index.js`。

`CMD` 是启动docker容器时要执行的命令。

`.dockerignore`文件基本和`.gitignore`文件无差别。


上面的`webpack4-demo/Dockerfile`文件的大概意思就是：

以Node.js v8.4为基础，将当前目录下（这里指：webpack4-demo）的文件复制到docker服务器里面的`/webpack4`目录。在docker服务器里面的`/webpack4`目录执行`npm install -g webpack webpack-cli && npm install && webpack`，生成镜像文件，提示对外暴露`4000`端口（不一定真的是`4000`）。通过镜像生成并启动docker容器时，执行`node server/index.js`。


### 构建生成镜像
这里很简单。构建一个名为`webpack4`的镜像。

在`webpack4-demo`目录下执行：

```
docker build -t webpack4 .
```

![](/images/first-use-docker/0528_02.png)

### 启动容器
镜像是不能被直接访问的，而且只有已经启动的容器才能被访问。docker镜像和docker容器的关系就像JavaSCript里面对象和实例的关系。镜像是用来创建实例的。

```
docker run -p 8000:4000 webpack4
```

![](/images/first-use-docker/0528_03.png)

这里启动docker容器，将容器里的`4000`端口绑定到宿主机（这里指的是本机）的`8000`端口。

> 这里不懂为什么要这样操作，可以查查docker是什么，他在电脑上存在的方式是怎样的？最简单的理解可以表示为一台单独的服务器。

上面的命令通过绑定外部可以访问的`8000`端口，让外部可以通过`8000`端口可以访问到docker容器里面的`webpack4`应用。


### 访问
浏览器打开`localhost:8000`。

![](/images/first-use-docker/0528_01.png)

### 遇到的问题
上面的demo并不是一帆风顺的。

#### 1. webpack命令的位置
开始的时候，`webpack`命令我是放在`CMD`命令处的，其实是不合适的。后来才改到了 `RUN`这里。

#### 2. CMD 命令
CMD命令格式有多种。这里需要注意的是前台和后台执行的关系。[相关文档](https://yeasy.gitbooks.io/docker_practice/image/dockerfile/cmd.html)

开始的时候，为是这么写的：

```
CMD webpack && node server/index.js
```

这里就会造成命令会在后台执行。相关解释看上面的相关文档。

最后，改成了：

```
CMD ["node","server/index.js"]
```

#### 3. app.listen函数
这个开始的时候，为没有注意到。

在`node server/index.js`里面，开始不知道什么原因写成了：

```js
const path = require('path');

const Koa = require('koa');
const koaBody = require('koa-body');
const serve = require('koa-static');
const views = require('koa-views');
const routers = require('./routers');

const app = new Koa();

//解析body
app.use(koaBody());
app.use(serve(path.join(__dirname , '../static')));
app.use(views('server/views',  { map: {html: 'ejs'}}));
routers(app);

app.listen(4000 , '127.0.0.1' , ()=>{
  console.log(`server start listening port 4000...`);
});
```


可以看到`app.listen`函数里面多了一个`127.0.0.1` IP地址。也就是因为这个地址，调了整整一个几个小时都无法访问到。

最后去掉`127.0.0.1`，就可以从外部正常访问了。


### 一些命令
`docker image ls` 查看镜像。

`docker image rm [image_id]` 删除镜像

`docker ps -a` 查看所有容器

`docker container rm [container_id]` 删除容器

`docker container stop [container_id]` 停止容器，停止的容器才能被删除





