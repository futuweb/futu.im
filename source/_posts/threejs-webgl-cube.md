---
title: ThreeJS四步制作一个简易魔方
date: 2017-03-03 14:00
tags: [ThreeJS,WebGL]
category: 技术预研
author: Young
---

## 概述

去年之所以再次兴起了学习WebGL的念头，主要是有两个原因；第一个是想制作一个魔方玩，另外一个是想用Web技术还原一些经典电影的经典镜头，比如《Cast Away》又译《荒岛余生》中电影快结束时主人公站在十字路口的场景。

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-0.jpg">

现在看来我想第一个目的已经达成了，有点可惜的是在此之前已经有很多人做过同样的事了，比如：

+ [https://github.com/miniwangdali/SimpleRubiksCube](https://github.com/miniwangdali/SimpleRubiksCube)
+ [https://www.google.com/logos/2014/rubiks/iframe/index.html](https://www.google.com/logos/2014/rubiks/iframe/index.html)

站在前人的肩膀上整个事情简单了很多，但是解决问题所带来的成就感也相对减少了很多，这也是没有办法的事情了。

<!--more-->

## 前言

首先我假设你是一名前端工程师而且已经初步了解WebGL和ThreeJS的基础知识，比如坐标系、相机、光线、矩阵、弧度等；

如若不清楚可以浏览以前几篇文章快速入门：

+ [WebGL ThreeJS学习总结一](https://newbieweb.lione.me/2016/10/19/WebGL%20ThreeJS%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93%E4%B8%80/)
+ [WebGL ThreeJS学习总结二](https://newbieweb.lione.me/2016/10/19/WebGL%20ThreeJS%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93%E4%BA%8C/)
+ [WebGL ThreeJS学习总结三](https://newbieweb.lione.me/2017/02/26/WebGL%20ThreeJS%E5%AD%A6%E4%B9%A0%E6%80%BB%E7%BB%93%E4%B8%89/)

## 编码

### 第一步：搭架子 

从我短暂的ThreeJS编程经验来看，有个通用的的架构能处理大部分情况，如下：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-1.jpg">

第一步完整代码如下：

[https://github.com/newbieYoung/Threejs_rubik/blob/master/step1.html](https://github.com/newbieYoung/Threejs_rubik/blob/master/step1.html)

### 第二步：画外型

魔方的外型很简单，就是由一些小正方体组成的一个大正方体而已。

用一个方法封装起来：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-2.jpg">

> 基本都是些ThreeJS对象的简单运用，比如盒子对象`BoxGeometry`、纹理`Texture`、材质`MeshLambertMaterial`等，纹理主要是用来描述物体表面静态属性的对象，材质主要是用来描述物体表面动态属性的对象，比如处理光照等，不知道这么理解有没有问题。

其中`faces`方法主要是生成一块黑色边框的大正方形其内部是某种颜色填充的圆角小正方形的canvas画布，用来充当纹理渲染魔方中小正方体的某个面。

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-3.png">

如果把这个canvas画布渲染出来，大致是下边这样的：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-5.png">

另外基于魔方中心在坐标系原点从而推算出所有小正方体中心点坐标可以画图理解如下：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-4.jpg">

最后需要把生成的魔方加入到场景中才会被渲染出来：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-6.png">

第二步完整代码如下：

[https://github.com/newbieYoung/Threejs_rubik/blob/master/step2.html](https://github.com/newbieYoung/Threejs_rubik/blob/master/step2.html)

此时在浏览器中运行第二步完整代码应该是下边这个样子的：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-7.png">

此时相比于第一步一片空白的页面而言，此时页面中多了一个类似九宫格的正方形，有人可能会说大兄弟要画这么个玩意用得着ThreeJS吗，DIV+CSS分分钟搞定......

其实之所以会这样是因为我们设置的`相机`的位置是在坐标系的Z轴，魔方的中心在坐标系原点，它们刚好处于同一条直线上，导致显示出来的是魔方的正视图。

### 第三步：操控魔方视角

第二步完成之后有个很严重的问题，我们只能看到魔方的正面，为了解决这个问题我们需要让`相机`随着鼠标或者触摸点的移动而移动；

在ThreeJS中作者提供了很多种视角控制类库，比如：

+ 轨迹球控件`TrackballControls`(最常用的控件,用鼠标控制相机移动和转动)；

+ 飞行控件`FlyControls`(飞行模拟器控件,用键盘和鼠标控制相机移动和旋转)；

+ 翻滚控件`RollControls`(翻滚控件是飞行控件的简化版,控制相机绕Z轴旋转)；

+ 第一人称控件`FirstPersonControls`(类似于第一人称视角的相机控件)；

+ 轨道空间`OrbitControls`(类似于轨道中的卫星,控制鼠标和键盘在场景中游走)；

+ 路径控件`PathControls`(控制相机在预定义的轨道上移动和旋转)；

在这里我使用OrbitControls控制器，具体用法很简单如下：

首先引入代码：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-8.png">

然后根据相机以及画布初始化即可：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-9.png">

第三步完整代码如下：

[https://github.com/newbieYoung/Threejs_rubik/blob/master/step3.html](https://github.com/newbieYoung/Threejs_rubik/blob/master/step3.html)

此时在浏览器中运行第三步完整代码应该是下边这个样子的：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-10.gif">

### 第四步：转动魔方

经过前三步在视觉方面简易魔方已经完成了差不多了，但是依然欠缺很重要的东西，没办法转动连最基本的可玩性都没有；

要想转动魔方需要解决以下几个问题：

+ 首先得确定触摸点

也就是说必须得在代码里边判断出魔方的哪个部位被触摸了，Canvas编程是没办法像DOM编程那样有完备的事件机制支持的；所以这个问题需要其它解决办法，比如在2D Canvas我们可以根据坐标来判断当前鼠标或者触摸点在哪个元素上，从而假定该元素获得了焦点；但是在WebGL中存在一个平面2D坐标映射为3D坐标的问题，万幸ThreeJS也提供了对应的解决方案`Raycaster`。

简单来说就是模拟一道光从屏幕点击或者触摸的位置上开始，以相机朝向为方向，然后检测光线与物体的碰撞，可以得知距离、碰撞点以及哪些物体先碰撞哪些物体慢碰撞。

首先得知道在页面的2D坐标，这里可以通过监听鼠标事件或者触摸事件来完成；

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-11.png">

`Raycaster`的调用也很简单，但是需要注意的是当魔方获得焦点时需要屏蔽视角的转动，给控制器的`enabled`属性置为false即可；另外如果魔方正在转动时下一次转动应该等这次转动完成才可以，这里用`isRotating`变量控制；开始一次转动时置为true，转动结束之后才还原为false。

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-12.png">

+ 然后得确定转动方向

转动魔方时应该是存在有六个方向的，分别是X轴正方向、X轴负方向、Y轴正方向、Y轴负方向、Z轴正方向、Z轴负方向；

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-13.png">

先根据滑动时的两点确定转动向量，然后判断转动向量和这六个方向向量夹角最小的方向即为转动方向；

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-14.png">

但是光知道方向其实还是不能够转动魔方的，比如下图中从点`A`滑动到点`B`和从点`C`滑动到点`D`，滑动方向都是X轴的正方向，而且还有其它情况滑动方向是X轴正方向的；对魔方来说这完全是两种不同的情形，所以我们还需要知道是在哪个平面滑动的。

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-15.jpg">

判断是在哪个平面，我们可以通过该平面的法向量和哪个坐标轴平行来判断，比如如果滑动平面的法向量平行于坐标系的Y轴且等于Y轴正方向的单位向量，那么该滑动平面肯定是魔方的`上平面`，以此类推；上边那个判断转动方向的方法可以优化为如下这个样子：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-16.png">

那么接下来的问题就是怎么获得滑动平面的法向量了，所幸ThreeJS的光线碰撞检测机制除了能得到碰撞物体、碰撞点，还能得到碰撞平面；已知平面那么就可以获得平面法向量了。

但是ThreeJS中有个问题需要我们注意，在ThreeJS中存在物体自身坐标系和世界坐标系的区分，在初始化时物体的坐标和世界坐标系一致，但是当物体发生变化之后它自身的坐标系也是会发生变化的；比如说刚开始某个物体`上平面`的法向量就是其自身坐标系Y轴正方向的单位向量，同时也是世界坐标系Y轴正方向的单位向量，如果该物体旋转180度之后，其`上平面`的法向量还是其自身坐标系Y轴正方向的单位向量，但是却是世界坐标系Y轴负方向的单位向量了，如图：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-17.jpg">

所以不能使用魔方中小正方体的碰撞平面，因为小正方体的坐标系是会随着小正方体的变化而变化的，此时需要再加入一个和魔方整体大小一样的透明正方体，然后根据该透明正方体的碰撞平面的法向量来判断。

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-18.png">

+ 再然后我们得根据转动方向、触发点获取转动物体

比如上图中从点A滑动到点B，转动物体是魔方`上平面`的所有小正方体；

至于怎么判断，有两种方法，第一种可以根据小正方体的中心点来判断，比如如果转动的是魔方`上平面`的正方体，那么已知触发点所在正方体的中心点，根据其Z轴大小就可以确定其它小正方体了；

还有一种办法则是根据小正方体初始化时的编号规律来判断，转动之后更新编号，保证其规律不发生变化，后续判断依旧即可，从下边的简图很容易就能看出其编号规律。

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-19.jpg">

第二种方法有个好处在于，我们可以把转动之后更新的编号和初始化时的编号进行比较，来判断魔方是否回到初始化状态，也就是被还原正常了。

> 这种方法不知道有问题没有，由于本人不会玩魔方所以一直没有测试。

+ 最后是制作转动动画

制作转动动画的过程中使用requestAnimationFrame，这没什么要说的；唯一要注意的地方还是关于物体自身坐标系和世界坐标系的问题，举例来说，绕世界坐标系Y轴旋转的方法应该是如下图所示：

<img src="https://raw.githubusercontent.com/newbieYoung/NewbieWebArticles/master/images/threejs-webgl-cube-20.png">

第四步完整代码如下：

[https://github.com/newbieYoung/Threejs_rubik/blob/master/step4.html](https://github.com/newbieYoung/Threejs_rubik/blob/master/step4.html)

可以通过点击下边的链接来查看在线例子

[https://yii-server.lione.me/harp-server/simple-cube](https://yii-server.lione.me/harp-server/simple-cube)

## 拓展

至此一个没什么卵用的魔方已经完成了，是时候开下脑洞了；

+ 玩具店应该只有最简单的三阶魔方买，但是对这个例子稍加拓展，你甚至可以玩100阶魔方。

+ 这个例子稍加扩展应该是能做出一些计时、计步的魔方游戏的。

+ 这个例子稍加扩展结合摄像头和自动还原算法，应该是可以做到扫描现实中的魔方，然后根据自动还原算法还原，得到一步步还原魔方的动画演示例子的。