---

title: serviceworker离线缓存在种子项目上的实践
subtitle: 在种子农场站点下首次引入service-worker建设pwa，来实现资源的缓存
date: 2019-07-16 20:10:43
cover: /images/2019-07-16-seed-with-service-worker-md/seed.png
tags: service-worker
---

### 前记

早在半年前，在公司内部的前端研习会上，就在研究pwa这个东东了，我负责的特点刚好是用service-worker来实现资源缓存。所以之前就已经尝试在本地的富途资讯页面中引入pwa了，后面也在准备着要在正式环境中也引入，可一直没有好的机会。

而就在上个星期，收到用户反馈，种子页面进不去，一直卡着，上服务器上查看了nginx日志，发现是资源响应太慢超时了（这个站点没有使用cdn资源），js等资源没有加载出来。种子这个页面又是用前端渲染的，所以用户就一直白屏了。

刚好，组内的技术建设一直在准备引入pwa这个东西，这次正好可以现在种子这个影响面不会太广并且更新太频繁的页面来做实验，万一出了问题影响面也不会太大。。

于是就吭哧吭哧地开干了

首先问了一下公司内的同事，发现并没有人在正式环境中引入过sw。。看来我是第一个吃螃蟹的人，刺激。。

## 一. service worker介绍
----------
### service worker的由来

service worker是浏览器的一个高级特性，本质是一个web worker，`是独立于网页运行的脚本`。
web worker这个api被造出来时，就是为了`解放主线程`。因为，浏览器中的JavaScript都是运行在单一个线程上，随着web业务变得越来越复杂，js中耗时间、耗资源的运算过程则会导致各种程度的性能问题。
而web worker由于独立于主线程，则可以将一些复杂的逻辑交由它来去做，完成后再通过postMessage的方法告诉主线程。
service worker则是web worker的升级版本，相较于后者，前者拥有了持久离线缓存的能力。

### service worker的特点
sw有以下几个特点：
- 独立于主线程、在后台运行的脚本
- 被install后就永远存在，除非被手动卸载
- 可编程拦截请求和返回，缓存文件。sw可以通过fetch这个api，来拦截网络和处理网络请求，再配合cacheStorage来实现web页面的缓存管理以及与前端postMessage通信。
- 不能直接操纵dom：因为sw是个独立于网页运行的脚本，所以在它的运行环境里，不能访问窗口的window以及dom。
- 必须是https的协议才能使用。不过在本地调试时，在http://localhost 和http://127.0.0.1 下也是可以跑起来的。
- 异步实现，sw大量使用promise。

### service worker的生命周期
service worker从代码的编写，到在浏览器中的运行，主要经过下面几个阶段
installing -> installed -> activating -> activated -> redundant;

![img](/images/2019-07-16-seed-with-service-worker-md/sw-lifecycle.png)

> <b>installing：</b>这个状态发生在service worker注册之后，表示开始安装。`在这个过程会触发install事件回调指定一些静态资源进行离线缓存。`
>
> <b>installed</b>：sw已经完成了安装，进入了waiting状态，等待其他的Service worker被关闭（在install的事件回调中，可以调用skipWaiting方法来跳过waiting这个阶段）
>
> <b>activating：</b> 在这个状态下没有被其他的 Service Worker 控制的客户端，允许当前的 worker 完成安装，并且清除了其他的 worker 以及关联缓存的旧缓存资源，等待新的 Service Worker 线程被激活。
>
> <b>activated：</b> 在这个状态会处理activate事件回调，并提供处理功能性事件：fetch、sync、push。（在acitive的事件回调中，可以调用self.clients.claim()）
>
> <b>redundant：</b>废弃状态，这个状态表示一个sw的使命周期结束





### service worker代码实现

```javascript
//在页面代码里面监听onload事件，使用sw的配置文件注册一个service worker
 if ('serviceWorker' in navigator) {
        window.addEventListener('load', function () {
            navigator.serviceWorker.register('serviceWorker.js')
                .then(function (registration) {
                    // 注册成功
                    console.log('ServiceWorker registration successful with scope: ', registration.scope);
                })
                .catch(function (err) {
                    // 注册失败
                    console.log('ServiceWorker registration failed: ', err);
                });
        });
    }
```



```javascript
//serviceWorker.js
var CACHE_NAME = 'my-first-sw';
var urlsToCache = [
    '/',
    '/styles/main.css',
    '/script/main.js'
];

self.addEventListener('install', function(event) {
    // 在install阶段里可以预缓存一些资源
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(function(cache) {
                console.log('Opened cache');
                return cache.addAll(urlsToCache);
            })
    );
});

//在fetch事件里能拦截网络请求，进行一些处理
self.addEventListener('fetch', function (event) {
    event.respondWith(
        caches.match(event.request).then(function (response) {
            // 如果匹配到缓存里的资源，则直接返回
            if (response) {
                return response;
            }
          
            // 匹配失败则继续请求
            var request = event.request.clone(); // 把原始请求拷过来

            //默认情况下，从不支持 CORS 的第三方网址中获取资源将会失败。
            // 您可以向请求中添加 no-CORS 选项来克服此问题，不过这可能会导致“不透明”的响应，这意味着您无法辨别响应是否成功。
            if (request.mode !== 'navigate' && request.url.indexOf(request.referrer) === -1) 						{
                request = new Request(request, { mode: 'no-cors' })
            }

            return fetch(request).then(function (httpRes) {
								//拿到了http请求返回的数据，进行一些操作
              
              	//请求失败了则直接返回、对于post请求也直接返回，sw不能缓存post请求
                if (!httpRes  || ( httpRes.status !== 200 && httpRes.status !== 304 && httpRes.type !== 'opaque') || request.method === 'POST') {
                    return httpRes;
                }

                // 请求成功的话，将请求缓存起来。
                var responseClone = httpRes.clone();
                caches.open('my-first-sw').then(function (cache) {
                    cache.put(event.request, responseClone);
                });

                return httpRes;
            });
        })
    );
});


```



## 二. service worker在seed中的引入

上面展示了在半年前研究pwa离线缓存时写的代码，而这次，真正要在正式环境上使用时，我决定使用webpack一个插件：workbox-webpack-plugin。workbox是google官方的pwa框架，workbox-webpack-plugin是由其产生的其中一个工具，内置了两个插件：`GenerateSW` 、`InjectManifest`

- GenerateSW：这个插件会帮你生成一个service worker配置文件，不过这个插件的能力较弱，主要是处理文件缓存和install、activate
- InjectManifest：这个插件可以自定义更多的配置，比如fecth、push、sync事件

由于这次是为了进行资源缓存，所以只使用了GenerateSW这部分。

```js
		//在webpack配置文件里
		var WorkboxPlugin = require('workbox-webpack-plugin');
		
		new WorkboxPlugin.GenerateSW({
            cacheId: 'seed-cache',

            importWorkboxFrom: 'disabled', // 可填`cdn`,`local`,`disabled`,
            importScripts: '/scripts-build/commseed/workboxswMain.js',

            skipWaiting: true, //跳过waiting状态
            clientsClaim: true, //通知让新的sw立即在页面上取得控制权
            cleanupOutdatedCaches: true,//删除过时、老版本的缓存
            
            //最终生成的service worker地址，这个地址和webpack的output地址有关
            swDest: '../workboxServiceWorker.js', 
            include: [
                
            ], 
            //缓存规则，可用正则匹配请求，进行缓存
            //这里将js、css、还有图片资源分开缓存，可以区分缓存时间(虽然这里没做区分。。)
            //由于种子农场此站点较长时间不更新，所以缓存时间可以稍微长一些
            runtimeCaching: [
                {
                    urlPattern: /.*\.js.*/i,
                    handler: 'CacheFirst',
                    options: {
                        cacheName: 'seed-js',
                        expiration: {
                            maxEntries: 20,  //最多缓存20个，超过的按照LRU原则删除
                            maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
                        },
                    },
                },
                {
                    urlPattern: /.*css.*/,
                    handler: 'CacheFirst',
                    options: {
                        cacheName: 'seed-css',
                        expiration: {
                            maxEntries: 30,  //最多缓存30个，超过的按照LRU原则删除
                            maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
                        },
                    },
                },
                {
                    urlPattern: /.*(png|svga).*/,
                    handler: 'CacheFirst',
                    options: {
                        cacheName: 'seed-image',
                        expiration: {
                            maxEntries: 30,  //最多缓存30个，超过的按照LRU原则删除
                            maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
                        },
                    },
                }
            ]
        })
```

1. importWorkboxForm和importScripts：

> importWorkboxFrom：workbox框架文件的地址，可选cdn、local、disabled
>
> - cdn：引入google的官方cdn，当然在国内会被强。。pass
> - Local：workboxPlugin会在本地生成workbox的代码，可以将这些配置文件一起上传部署，这样是每次都要部署一次这个生成的代码。
> - Disabled：上面两种都不选用，将生成出来的workbox代码使用importscript指定js文件从而引入。
>
> 我最终选择的是第三种，因为这样可以由自己指定要从哪里引入，比如以后如果这个站点有了cdn，可以将这个workbox.js放到cdn上面。目前是将生成的文件，放到script文件夹下。

2. workbox的策略
   - Stale-While-Revalidate：尽可能快地利用缓存返回响应，缓存无效时则使用网络请求
   - Cache-First：缓存优先
   - Network-First：网络优先
   - Network-Only：只使用网络请求的资源
   - Cache-Only：只使用缓存

> 一般站点的 CSS，JS 都在 CDN 上，SW 并没有办法判断从 CDN 上请求下来的资源是否正确（HTTP 200），如果缓存了失败的结果，就不好了。这种情况下使用stale-while-Revalidate策略，既保证了页面速度，即便失败，用户刷新一下就更新了。
>
> 而由于种子项目的js和css资源都在站点下面，所以这里就直接使用了cache-first策略。



在webpack中配置好之后，执行webpack打包，就能看到在指定目录下由workbox-webpack-plugin生成的service worker配置文件了。

![baidu](/images/2019-07-16-seed-with-service-worker-md/sw.js.png)



接入之后，打开网站，在电脑端的chrome调试工具上可以看到缓存的资源

![image-20190720153512842](/images/2019-07-16-seed-with-service-worker-md/image-20190720153512842.png)



### 接入过程的考虑

1. 前文也有介绍，service worker一旦被install，就永远存在；`如果有一天想要去除跑在浏览器背后的这个service worker线程，要手动去卸载`。所以在接入之前，我得先知道如何卸载service worker，留好后手：		

   ```js
   if ('serviceWorker' in navigator) {
          navigator.serviceWorker.getRegistrations()
              .then(function(registrations) {
   				for(let registration of registrations) {
                        //安装在网页的service worker不止一个，找到我们的那个并删除
                       if(registration && registration.scope === 'https://seed.futunn.com/'){
                           registration.unregister();
                       }
                   }
               });
       }
   ```

   

2. 使用service worker缓存了资源，那下次重新发布了，还`会不会拉取新的资源`呢？这里也是可以的，只要资源地址不一样、修改了hash值，那么资源是会重新去拉取并进行缓存的，如下图，可以看到对同一个js的不同版本，都进行了缓存。

   ![image-20190720154102350](/images/2019-07-16-seed-with-service-worker-md/image-20190720154102350.png)

3. 还有个就是对于考虑开发过程的问题，如果以后上线了，sw这个东西安装下去了，每次打开都直接读取缓存的资源，那以后在`本地调试`时怎办？试了下，chrome的“disabled cache”也没有用，总不能在本地开发时也给资源打上hash值吧（目前这个项目是在发布到正式环境时才会打上hash值）。。然后针对这个问题想了蛮久的，最后发现chrome早有这个设置，在devtool中可以设置跳过service worker,`bypass for network`	

   ![image-20190720155118504](/images/2019-07-16-seed-with-service-worker-md/image-20190720155118504.png)

4. 比起浏览器的默认缓存功能，service woker的缓存功能赋予我们更强大地、更完善地控制缓存的能力。

5. 这个东西其中一个不足在于，还没有很多浏览器支持service worker这个东西，苹果系统是从11.3才开始支持，所以直到现在，富途牛牛ios版的webview、微信ios版的webview都还不支持service worker这个特性；在安卓上的支持更为广泛一些，所以这次在种子的优化上，安卓客户可以更好地感受到这个成效。



## 后记

种子农场加入service worker上线快两周了，到现在还没有啥问题，似乎一切都挺顺利的。

从最开始研习会上的接触之后，就一直在想着要准备把它用起来，可一直都有种对于它的不确定性的畏惧。随着对它的越来越熟悉，这次终于把它搞起来了， 挂念许久的东西可算是有个交代了。。




