---
title: 如何与NPM package-lock.json愉快地玩耍
date: 2018-07-26 19:40
categories: [Node.js]
author: TooBug
---

## 背景

对的，最近写文章都会交代一下背景。因为按标题的套路，这本应该是一篇教程类的文章，但这种文章其实挺无趣的。之所以想写这篇，是因为确实碰到了一些很麻烦的事情。闲言少叙，我们进入正题。

最近我们前端代码打包正在接入Gitlab CI，使用Docker来作为Executor，也就是在Docker中进行前端代码打包，然后收集打包结果，以备发布时使用。打包时Docker镜像很自然地就选择了官方Node镜像，最新版本（Node 10）。

一开始我们尝试性地接入了几个项目，有使用NPM scripts进行打包的，也有使用Gulp进行打包的，一切都很正常。但是昨天在接入一个新项目，使用Gulp打包的时候，却突然碰到了报错：

```sh
$ gulp gitlab-ci
gulp[85]: ../src/node_contextify.cc:631:static void node::contextify::ContextifyScript::New(const v8::FunctionCallbackInfo<v8::Value>&): Assertion `args[1]->IsString()' failed.
Aborted
ERROR: Job failed: exit code 134
```

看了一眼这个错误信息，一下子就发现，这并不是来自JS层的错误，而是来自Node原生层，这就超出了我的理解范围了。

<!-- more -->

## 模块版本兼容问题

通过搜索，首先找到一篇中文的解决方案：[升级node10后gulp报错的解决办法](https://liyang.pro/after-upgrading-node10-gulp-error-solution/)。文中给出了如下解决办法：

```sh
rm -fr node_modules
rm -fr package-lock.json
npm cache clean --force
npm install
```

所以这是什么原理呢？没看到文章有解释，另外这文章本身也写得不是很清楚。抱着半信半疑的态度，在CI的脚本中加上了`npm cache clean --force`，结果问题依旧。

接着搜索了一下，很快发现一些和这个问题有关的issue：

- nodejs/node: [node 10.0.0安装模块时core dump](https://github.com/nodejs/node/issues/20281)
- nodejs/node: [新发布的版本与Gulp ^3.9.0不兼容](https://github.com/nodejs/node/issues/20285)
- gulpjs/gulp: [将graceful-fs的升级合并回Gulp 3](https://github.com/gulpjs/gulp/issues/2146)
- gulpjs/gulp: [node 10中崩溃](https://github.com/gulpjs/gulp/issues/2162)
- isaacs/node-graceful-fs [v3.x分支与Node.js master不兼容](https://github.com/isaacs/node-graceful-fs/issues/120)
- isaacs/node-graceful-fs [v3.0.11依赖natives 1.1.1，后者与node 10不兼容](https://github.com/isaacs/node-graceful-fs/issues/130)

通过`npm ls`，一下子就看到了`natives`模块的版本是1.1.1，于是定位到真正的问题：`gulp`依赖`vinyl-fs`，`vinyl-fs`依赖`graceful-fs`，`graceful-fs`依赖`natives`，而`natives`在1.1.3之前都不兼容Node 10。

那么解决方案就简单了，想办法升级一下模块不就好了？

## 如何升级间接依赖

首先想到的是Gulp是否有解决这个问题，`npm info gulp`看了一下，发现最新版本是`3.9.1`，然后`npm ls`一下，发现本机装的已经是`3.9.1`了，也就是说，Gulp根本没有升级的可能。那要如何升级这个间接的依赖呢？

这里我绕了个弯子，`package.json`中直接依赖的模块无法升级，`npm update`也不能搞定。于是想到，如果显式安装一下这个模块，是不是能解决问题？

```sh
npm install natives@1.1.3
```

安装完之后还要在`package.json`中将直接依赖`natives`删除（因为我并不直接依赖它，留着没用）。然后再次查看依赖：

```sh
▶ npm ls natives
seed@1.0.0 /Users/TooBug/work/oa/learn/frontend
└─┬ gulp@3.9.1
  └─┬ vinyl-fs@0.3.14
    └─┬ graceful-fs@3.0.11
      └── natives@1.1.3
```

这次对了。

但是，这个操作我是在本机进行的，这个操作到底改了什么呢？如果去CI上再次执行`npm install`，会不会依然安装到旧版本呢？毕竟`package.json`并没有任何改动。

于是翻看了一下`git diff`，发现了本文的主角`package-lock.json`被修改了，其中的`natives`由1.1.1变成了1.1.3。

```json
"natives": {
    "version": "1.1.3",
    "resolved": "http://registry.npm.oa.com/natives/download/natives-1.1.3.tgz",
    "integrity": "sha1-RKV5vmRQfqLW7RygSpQVkVz3VVg="
},
```

于是怦然大悟：本来npm在安装模块是是按语义化版本安装最新版的，但是在CI上却没有安装`natives@1.1.3`，而是安装了`natives@1.1.1`，这正是因为`package-lock.json`装版本锁定了，从而导致了与Node 10的不兼容问题。

这也能很好地解释，为什么其它项目没有这样的问题，因为其它的项目在代码仓库中没有包含`package-lock.json`，在安装时自然就安装了`natives@1.1.3`。

于是再回头看一开始搜到的文章提出的解决办法：

```sh
rm -fr node_modules
rm -fr package-lock.json
npm cache clean --force
npm install
```

其实是非常有效的，因为它将`package-lock.json`直接删除了，然后重新安装一遍最新版本，生成新的`package-lock.json`，从而解决问题。

## 延伸：如何正确地在项目中使用`package-lock.json`

最后，也补充说明一下`package-lock.json`的正确用法。（虽然我知道，但还是不小心踩坑了。如果不清楚它的用法的话，可能会在坑里待更长时间爬不出来。）

首先，需要确保`npm`的版本在5.6以上，因为在5.0 - 5.6中间，对`package-lock.json`的处理逻辑更新过几个版本。5.6以上的才是符合认知的逻辑。

然后，在项目中如果没有锁版本的必要，可以不使用`package-lock.json`，在安装模块时指定`--no-lock`即可。

如果项目中有`package-lock.json`，则安装模块时会以这个文件中指定的版本和地址为准，直接下载安装。（除非它和`package.json`中指定的版本不相符。）

最后，如果已经锁定了版本的情况下，需要更新直接依赖，则直接安装指定版本，`package.json`和`package-lock.json`都会同步更新。如果需要更新间接依赖的话，则需要像本文这样，手工安装一下，保证`package-lock.json`被更新到。或者如果其它模块的锁定并不是那么重要时，也可以直接删除`package-lock.json`，然后重新安装一遍，相当于把所有（直接依赖+间接依赖）模块全部更新一遍。
