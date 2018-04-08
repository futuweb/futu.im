---
title: 设备方向检测和加速传感器的运用
date: 2018-03-31 15:05:53
category: 技术预研
tags: [JavaScript,API,DeviceOrientationEvent,DeviceMotionEvent]
author: Cynthia
---

> 声明：本特性为新特性，在实际开发中请谨慎使用。

HTML5的Device API中提供了几个DOM事件，可以获得设备的物理方向及运动的信息。这些数据来源于设备上的陀螺仪、加速度传感器以及指南针等。

这里主要通过介绍的是两个负责处理设备方向信息JavaScript事件，来讲述设备方向检测。事件分别是

- `DeviceorientationEvent`：它会在加速度传感器检测到设备在方向上发生变化时触发。
- `DevicemotionEvent`：它会在加速度传感器检测到设备的运动加速度发生变化时触发。

<!-- more -->

## DeviceorientationEvent

`DeviceorientationEvent` 它会在加速度传感器检测到设备在方向上发生变化时触发。其数据是传感器与地球坐标系相比较所得的值，也就是说在设备上可能会采用设备地磁计的数据。

### 浏览器兼容性
![deviceorientation兼容性](/images/2018-03-31-deviceorientation-and-devicemotion/1.png)

### 判断设备是否支持处理方向（orientation）事件

```js
if(window.DeviceOrientationEvent){//判断设备是否支持设备方向检测事件。
    window.addEventListener('deviceorientation', function(event){
        // 处理event.alpha、event.beta及event.gamma
    }, false);
}else{
    // 不支持的处理
}
```

#### 需要注意
在一些非移动设备浏览器上（比如：电脑浏览器），通过`window.DeviceOrientationEvent`判断设备是否支持处理设备方向事件，虽然返回的结果为`true`，但这并不表明，此设备支持处理设备方向事件。这是因为电脑上可能存在一个用于保护存储设备的传感器。

所以个人观点是，在真正运用这一个新特性的时候，不仅需要判断设备是否支持处理设备方向事件，也需要判断是否为**移动端设备**？

### deviceorientation事件属性

- absolute: 是否为绝对定位？
- alpha（只读）:围绕 Z 轴的旋转角度
- beta（只读): 围绕 X 轴的旋转角度
- gamma（只读): 围绕 Y 轴的旋转角度

#### 设备坐标系
要使用设备方向和动作事件返回的数据，必须理解所提供的值。

设备坐标系由 `X`、`Y` 和 `Z` 值表示，以设备的中心为基准。
**设备坐标系与页面横屏竖屏无关**

|坐标系|描述|
|---|---|
|X | 处于屏幕平面，正值为设备的右侧|
|Y  | 处于屏幕平面，正值为设备的顶部|
|Z  | 与屏幕或键盘垂直，正值表示远离。|

![设备坐标系](/images/2018-03-31-deviceorientation-and-devicemotion/axes.png)

#### absolute

```js
var absolute = DeviceOrientationEvent.absolute;
```

如果方向数据跟地球坐标系和设备坐标系有差异，则`absolute`为`true`，如果方向数据由设备本身的坐标系提供，则`absolute`为`false`。 

注意：在ios里，`absolute`为`undefined`，在安卓chrome里，`absolute`为`false`。有可能是浏览器实现不同。

#### alpha（只读）
**围绕 Z 轴的旋转角度**，取值[0,360）。

当设备逆时针旋转时，`alpha` 值增加。

```js
var alpha = DeviceOrientationEvent.alpha;
```

![设备坐标系中 Alpha 的图示](/images/2018-03-31-deviceorientation-and-devicemotion/alpha.png)

#### beta（只读）
**围绕 X 轴的旋转角度**。取值(-180,180)。

*旋转方式与beta值的变化关系*：  
当设备向前旋转时，`beta`值增大。     
当设备的顶部和底部**平行**于水平面时，且屏幕**向上**，`beta`值为`0`。     
当设备的顶部**高于**底部时，且屏幕**向上**，`beta`值为`正数`。        
当设备的顶部和底部**平行**于水平面时，且屏幕**向下**，`beta`值为`-180`            
当设备的顶部**低于**底部时，且屏幕**向下**，`beta`值为`负数`。             

*绕X轴，旋转360°，得到的结果*：     
0(屏幕向上) -> 90（屏幕向前，顶部在上） -> 180/-180（屏幕向下） -> -90（屏幕向后，底部在上） -> -0（屏幕向上）

![设备坐标系中 beta 的图示](/images/2018-03-31-deviceorientation-and-devicemotion/beta.png)

#### gamma（只读）

**围绕 Y 轴的旋转角度**。取值(-90,90)。

*旋转方式与gamma值的变化关系*  
当设备向右侧旋转时，`gamma`值增大    
当设备左端和右端**平行**于水平面时，`gamma`值为`0`,
当设备左端**高于**右端时，`gamma`值为`正数`    
当设备屏幕**垂直**于水平面时，`gamma`值为`90`。

*屏幕向上且平行于水平面，绕Y轴，旋转360°，得到的结果：*         
0(屏幕向上) -> 90/-90(屏幕向右) -> -0/0（屏幕向下） -> 90/-90（屏幕向左） -> -0（屏幕向上） 

![设备坐标系中 Gamma 的图示](/images/2018-03-31-deviceorientation-and-devicemotion/gamma.png)

### 注意事项

- 旋转方向与属性值的关系符合**右手定则**，拇指指向属性围绕的轴，其余四指形成的方向，即为该属性旋转时，值增大的方向。 

- 在ios中，如有监听`deviceorientation`事件，即使手机处于静止状态，`deviceorientation`事件也会一直被触发，得到的`alpha`,`beta`,`gamma`属性值也会变。所以如果在UI层面用到这些属性时，应该用`requestanimationframe`方法改变UI（这不算废话吧，哈哈）。

- 在mac Chrome中，`alpha`,`beta`,`gamma`值都为`null`


## devicemotion
`devicemotion`事件会在加速度发生改变时触发。用于获取移动速度，得到设备移动时相对之前某个时间的差值比

### 浏览器兼容性
与上文的`deviceorientation`事件兼容性相同。

![deviceorientation兼容性](/images/2018-03-31-deviceorientation-and-devicemotion/1.png)

### 判断设备是否支持事件

```js
if (window.DeviceMotionEvent) {
    window.addEventListener('devicemotion', function(event){
        // 处理event.acceleration、event.accelerationIncludingGravity、event.rotationRate和event.interval
    },false);
} else {
    alert('本设备不支持devicemotion事件');
}
```

### 属性数据

- acceleration（只读）: 设备加速度信息对象
- accelerationIncludingGravity (只读) : 设备加速度信息对象，该值包括重力的影响
- rotationRate （只读）: 设备旋转速率
- interval : 事件触发的时间间隔

#### acceleration（只读）

设备加速度，提供有关设备沿三个轴（x、y、z）的加速度的信息，该加速度是去除了重力加速度的影响的。

如果硬件不知道如何从加速度数据中消除重力，则该值可能不存在。

acceleration.x : 沿X轴的加速度        
acceleration.y : 沿Y轴的加速度            
acceleration.z : 沿Z轴的加速度        

#### accelerationIncludingGravity (只读)
设备加速度，该值包括重力的影响。并且可能是没有陀螺仪的设备上可用的唯一值。

* `accelerationIncludingGravity.x`：沿X轴的加速度，单位为m/(s*s)；
* `accelerationIncludingGravity.y`：沿Y轴的加速度；
* `accelerationIncludingGravity.z`：沿Z轴的加速。

#### rotationRate（只读）
设备围绕所有三个轴的旋转速率。

rotationRate.alpha: 围绕Z轴的旋转量，单位为度/秒     
rotationRate.beta : 围绕X轴的旋转量，单位为度/秒     
rotationRate.gamma : 围绕Y轴的旋转量，单位为度/秒   

#### interval 

`devicemotion`事件触发的时间间隔（以毫秒为单位）。     

### 注意事项

- 如有监听`devicemotion`事件，即使设备处于静止状态，`devicemotion`事件还是会一直触发。
- 由于这个事件的值一直在变化，所以没有测出变化的规律，[设备屏幕方向与运动](https://developers.google.com/web/fundamentals/native-hardware/device-orientation/?hl=zh-cn#_12)这篇文章中给出了设备运动时，`devicemotion`事件中各个属性的值。


## 应用

### 摇一摇

`deviceorientation`或者`devicemotion`都可以实现摇一摇的功能，二者的区别在于`deviceorientation`只是判断用户设备的偏转角度，而`devicemotion`则可以计算用户手机移动的加速度。

*思路*
通过判断前后两次各个属性值之差是否大于阈值

```js
// 用用户设备的偏转角度判断是否摇了
if (window.DeviceOrientationEvent) {
    var lastEvent = '';
    var THRESHOLD = 15; // 阈值为15度。
    window.addEventListener('deviceorientation', function(event) {
        var delA = Math.abs(event.alpha-lastEvent.alpha);
        var delB = Math.abs(event.beta -lastEvent.beta);
        var delG = Math.abs(event.gamma - lastEvent.gamma);
        if (delA>THRESHOLD || delB >THRESHOLD || delG>THRESHOLD) {
            // 这里只是认为任意一方向的变化大于阈值，都算摇了
            // 为防止移动时导致的误判，这里可以考虑两个方向都改变时才算
        }
        lastEvent = event; // 保存上一次event
    },false);
}


// 用设备运动运动加速度判断是否摇了


if(window.DeviceMotionEvent) {
    var THRESHOLD = 15; // 阈值为15度。
    var x, y, z, lastX, lastY, lastZ;
    x = y = z = lastX = lastY = lastZ = 0;

    window.addEventListener('devicemotion', function(event){
        var acceleration = event.accelerationIncludingGravity;
        x = acceleration.x;
        y = acceleration.y;
        if(Math.abs(x-lastX) > THRESHOLD || Math.abs(y-lastY) > THRESHOLD) {
            // 用户设备摇动了，触发响应操作
            // 此处的判断依据是用户设备的加速度大于我们设置的阈值
        }
        lastX = x;
        lastY = y;
    }, false);
}
```

*注意事项*

- **ios中的如果页面上有输入框，且输入框被手动填写过内容的话**，摇一摇会触发一个【撤销键入】的弹窗。这篇文章是关于这个问题的解决方案[解决IOS在网页摇一摇会出现撤销弹出框的一种方案](http://blog.csdn.net/u010440155/article/details/52387351)

- 感觉如果以摇一摇作为触发条件干某些事情的话，是否应该给定一个摇一摇的时间？只有在这个时间段内的摇一摇才算事件触发。

## 晃动手机，控制物体方向

*思路*
根据`deviceorientation`事件，获取设配偏移度，换算为物体在屏幕中的位置


```html
<style>
    .garden {
      position: relative;
      width : 200px;
      height: 200px;
      border: 5px solid #CCC;
      border-radius: 10px;
    }
    .ball {
      position: absolute;
      top   : 90px;
      left  : 90px;
      width : 20px;
      height: 20px;
      background: green;
      border-radius: 100%;
    }
</style>
<div class="garden">
  <div class="ball"></div>
</div>
```

```js
// 通过左右晃动，控制小球的左右位置
if (window.DeviceOrientationEvent) {
    var ball = document.querySelector('.ball');
    var garden = document.querySelector('.garden');
    var maxX = garden.clientWidth - ball.clientWidth;
    var maxY = garden.clientHeight - ball.clientHeight;
    window.addEventListener('deviceorientation', function(event) {
        var y = event.gamma; // gamma取值范围 [-90,90]
        // 想要的手机晃动范围[-45,45]
        if (y>45) {
            y = 45;
        }else if(y<-45){
            y = -45;
        }
        // 这个用requestanimationframe来改变left会比较好点？
        ball.style.left = (maxY * y/90 + garden.clientWidth/2) + "px";
    });
}
```




