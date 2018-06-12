---
title: 移动端开发调试技巧
date: 2018-06-12 15:30
categories: [前端]
author: Tyson
---

正所谓磨刀不误砍柴工，一个好的调试工具对效率的提升无疑是事半功倍的。本文汇总了一些在移动端开发方面的调试工具和常见技巧，希望对你日常的开发工作有所帮助。

<!-- more -->

本文分为三个方面介绍：

- 纯网页调试    
    -- Chrome 控制台调试
    -- Web Inspector Remote
    -- Vconsole
    -- Onerror捕获异常

- 客户端调试
    -- 微信端调试
    -- IOS调试
    -- Android调试

- 代理调试
    -- HTTPS抓包
    -- Fiddler代理本地文件
    -- DNS访问本地服务器
    
## 纯网页调试

### 1、Chrome 控制台调试

利用开发者工具提供的一些方法，可以有效帮助定位日常开发中遇到的问题，这里就不细说了，列举一些常见的手段：

    1、设置断点
    2、把 objects 输出成表格
    3、快速定位 DOM 元素
    4、用 console.time() 和 console.timeEnd() 测试循环耗时
    5、格式化代码
    6、屏蔽不相关代码
    7、节点变化时中断
    8、等等
    
更多详细信息可参考 [14 个你可能不知道的 JavaScript 调试技巧](https://mp.weixin.qq.com/s/ykGJDc_rZCfS_RhNsiwdtQ)

### 2、Web Inspector Remote

Web Inspector Remote 是一个远程调试工具，又称weinre。需要搭建一个weinre的服务器，然后被调试的页面中引入一个js，就可以进行远程调试，调试的界面如下，有点类似chrome开发者工具的调试，不过weinre比较适用于调试CSS，不太合适调试JS，有些JS的错误往往不能报出来。


![](/images/2018-06-12-how-to-debug-webview/weinre.png)

我在富途内网搭建了weinre服务，地址是 [https://weinre.futunn.com](https://weinre.futunn.com)，需要配host 172.28.249.39 weinre.futunn.com，富途的同学可以在内网直接使用。

### 3、Vconsole

Vconsole是腾讯微信团队出品的一个前端调试工具，功能很强大，可以看到页面日志、代理信息、网络请求、页面元素、还有cookie、localStorage等。

使用方式有两种：

npm安装

    npm install vconsole

或者直接引入压缩后的JS

    <script src="path/to/vconsole.min.js"></script>
    <script>
    // init vConsole
    var vConsole = new VConsole();
    console.log('Hello world');
    </script>
 
更多信息可访问他们的github： [https://github.com/Tencent/vConsole](https://github.com/Tencent/vConsole)。

引入Vconsole之后，页面在右下方会出来一个浮层，点开就可以查看更多信息：

![](/images/2018-06-12-how-to-debug-webview/vconsole1.png)
![](/images/2018-06-12-how-to-debug-webview/vconsole2.png)
![](/images/2018-06-12-how-to-debug-webview/vconsole3.png)

Vconsole功能很强大，适用于各类调试场景，而且在各类终端都能使用，非常推荐。

### 4、Onerror捕获异常

监听window的onerror事件可以捕获全局的一些JS异常，不过只适用于内联JS或者同域下的JS，否则就需要crossorigin参数和远程资源服务器的支持。

Onerror捕获异常比较适用于产品上线后的监控使用，通过收集错误信息，上报到监控服务器，并设置告警条件，可以有效及时地发现线上的错误。

在富途的产品中，我们通常使用公共组件tool-dedog.js，它会收集页面中的错误，告警到monitor，并且把具体的错误信息，上报到ULS日志中心，下图是一个例子：

![](/images/2018-06-12-how-to-debug-webview/log.png)

    总结一下：
    - 在开发阶段，我们使用chrome开发者工具进行移动端的模拟开发；
    - 在测试阶段，我们使用weinre和Vconsole定位具体的终端问题；
    - 上线之后，我们监控window的onerror事件，及时发现线上用户实际使用过程产生的一些异常。

## 客户端调试

### 1、微信端调试
微信端调试最好的当然是微信自家的产品——微信web开发者工具。这个工具在扫一扫登录之后，就可以模拟出微信客户端的环境，可以调试微信分享API、支付API等一系列客户端特定的功能。

![](/images/2018-06-12-how-to-debug-webview/wechat.png)

### 2、安卓端USB调试

安卓端USB调试的方式比较简单：
    
    - 连接USB
    - 开启安卓的调试模式
    - 访问chrome://inspect
    - 勾选Discover USB devices
    - 选取要调试的网页

如果是调试安卓手机中chrome访问的页面，以上方式就足够了，不过如果需要调试安卓APP内嵌的web网页，还需要同时满足以下条件：
    
    - Android 4.4+
    - 在APP代码中设置WebView.setWebContentsDebuggingEnabled(true)

### 3、IOS端USB调试

IOS端USB调试的原理其实跟安卓差不多，只不过换成了mac和safari而已：

    - 连接USB
    - 手机上Settings -> Safari -> Advanced，启用Web Inspector
    - 手机上打开web页面
    - Mac上Safari中点Develop -> 设备名 -> 选择网页
    - 弹出Web Inspector进行调试

同理，如果safari访问的页面，以上方式就可以调试，但如果是APP内嵌的页面，条件就比较苛刻了，需要满足以下两个条件之一：

    - Xcode编译安装的应用
    - 越狱IOS设置com.apple.private.webinspector.allow-remote-inspection和com.apple.security.get-task-allow


## 代理调试

### 1、https抓包

https抓包分别PC抓包和手机抓包，主要是通过fiddler，生成fiddler证书并信任后，就可以打开fiddler中的HTTPS选项进行抓包了。具体步骤如下：

    - 下载并安装Fiddler证书生成器 http://www.telerik.com/docs/default-source/fiddler/addons/fiddlercertmaker.exe 
    - 打开Fiddler，点击工具栏中的Tools——>Options
    - 切换到 HTTPS 选项卡，勾选 Capture HTTPS CONNECTs，勾选 Decrypt HTTPS traffic，一路点确定安装
    - 重启fiddler，切换到HTTPS 选项卡，点击右侧Actions，能看一个下拉菜单，点击 Export Root Certificate to Desktop
    - 证书会生成到桌面上，名为 FiddlerRoot.cer，点击安装为根证书

手机抓包也是类似，只不过需要把FiddlerRoot.cer拷到手机中安装并信任，另外通过在同一个局域网内设置fiddler的网络代理（端口通常是8888），就可以抓包手机上的HTTPS请求了。

### 2、fiddler代理本地文件

fiddler代理本地文件是通过fiddler的autoResponder实现的，可以编写匹配规则，指定本地电脑上的某个文件代替服务器上的某个文件来响应请求，这样在本地做的修改，就可以马上看到效果，这是很常用的手段，就不细说了。

![](/images/2018-06-12-how-to-debug-webview/fiddler.png)

### 3、DNS访问本地服务器

把本地计算机搭建成一台DNS服务器（可以通过Dnsproxy指令或者其他dns服务器工具），然后在手机上指定DNS服务器为本地计算机，就可以让本地计算机的host在手机上生效，可以在手机上查看开发环境或者测试环境的页面，并且很方便地做host切换，解决了手机上不好设置host的问题（特别是ios系统）。

#### 以上所有的调试手段，希望有一款满足你。


## 参考资料
- [14 个你可能不知道的 JavaScript 调试技巧](https://mp.weixin.qq.com/s/ykGJDc_rZCfS_RhNsiwdtQ)
- [Weinre移动端调试利器](https://div.io/topic/1322)
- [微信vConsole工具](https://github.com/Tencent/vConsole)
- [脚本错误量极致优化-监控上报与Script error](http://www.alloyteam.com/2017/03/jserror1/)
- [移动端真机调试指南](https://juejin.im/entry/58b7b35c570c350062028e02)
- [Fiddler证书安装（查看HTTPS）](https://blog.csdn.net/someone_yt/article/details/53149402)
