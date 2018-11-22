---
title: 如何搭建Express和Mongoose
subtitle: express是一个高度包容，快速，极简的nodeJs应用程序框架。
date: 2016-09-18 13:56
tags: [Express,Mongodb,mongoose]
categories: [Node.js]
author: Elly
---

## 一、Express

### express是什么

 	express是一个高度包容，快速，极简的nodeJs应用程序框架。

<!--more-->

### 如何快速启动Express

1、全局安装express-generator：
     
    $npm i express-generator -g --registry=https://registry.npm.taobao.org

2、创建名为myapp应用程序：
    
    $express myapp

3、进入到myapp：
    
    $cd myapp

4、安装依赖：
    
     $npm install

5、启动程序：
    
     $DEBUG=myapp:* npm start

     
### express generator生成的目录结构

![image](/images/expressMongoose/expressjade.png)


### 将jade改成ejs

通过express generator生成的项目，是用jade模板引擎，但是我觉得`jade`可读性比较差，且很难去适应`jade`写法，所以我用了ejs

- 修改方法如下：
	
	1、npm下载ejs-locals(在根目录下执行以下命令)：
	
		$npm i ejs-locals —save
	
	2、修改`app.js`3处地方
	
	![image](/images/expressMongoose/ejsdemo.png)
	
	3、将`views`目录下`.jade`结尾的文件修改成`.ejs`结尾
	
	![image](/images/expressMongoose/expressejs.png)
	
	4、重新启动
	
		$DEBUG=myapp:* npm start
		
- Note：监听端口是3000，所以本地访问http://127.0.0.1:3000/



	
## 二、Mongoose

	mongodb是一个对象模型工具，Mongoose是针对mongodb操作的一个对象模型库，它封装了mongodb增删改查的一些方法。
	
### Mongoose（Schema,Model,Entity）
- Schema：数据结构描述。

```js
	// 创建Schema
	var formSchema = new mongoose.Schema({
		title: String,
		content: String,
		name: String,
		age: Number,
		reqRes: Number
	});
```

- Model：数据实体的封装。

```js
var formModel = mongoose.model('form', formSchema);
```

- Entity: 是实体，对应一条数据。

### 如何连接数据库
1、安装mongodb：
	
	$brew install mongodb
	
2、进入myapp：
	
	$cd myapp
	
3、安装mongoose：
	
	$npm i mongoose —save
	
4、创建modules文件夹：
	
	$mkdir modules
	
5、进入modules：

	$cd modules
	
6.创建form_collections.js: 
	
	$touch form_collections.js
	
### form_collections.js如何实现数据库连接

![image](/images/expressMongoose/collectionfile.png)

```js

	// 链接数据库
	var mongoose = require('mongoose');
	mongoose.connect('mongodb://localhost/test');
	var db = mongoose.connection;
	db.on('error', console.error.bind(console, '链接错误'));
	db.once('open', function() {
		console.log('MongoDB连接成功！');
	});
	
	// 创建Schema
	var formSchema = new mongoose.Schema({
		title: String,
		content: String,
		name: String,
		age: Number,
		reqRes: Number
	});
	// 创建Model
	var formModel = mongoose.model('form', formSchema);
	
	module.exports = formModel;


```

### 在routes/index.js中引入form_collections.js
![image](/images/expressMongoose/index.png) 
![image](/images/expressMongoose/indexdemo.png)

### 启动mongodb

	$sudo mongod --dbpath=/Users/ellyliang/Downloads/myapp/data
	
- Note:连接数据库之后，要先启动mongodb之后，再启动express。

### mongoose的增删改查(额外的补充的信息)

- 1 .find()： 查找，读取信息
- 2 .create()： 增加信息
- 3 .update()： 更新信息
- 4 .remove()： 删除信息


## 三、结束语

以上是我的分享总结整理，如果你还是不太懂我写的是什么，可以去coding上边把我的项目拉下来,然后跑起来看看就好了。我的例子项目里边写了mongoose的增删该查的方法，希望能帮助到你。

[Coding上的项目](https://coding.net/u/useLess/p/expressMongodb/git)

如何启动：
	
	$DEBUG=expressMongodb:* npm start
	
	$sudo mongod --dbpath=/存放项目的目录结构/expressMongodb/data




	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	







