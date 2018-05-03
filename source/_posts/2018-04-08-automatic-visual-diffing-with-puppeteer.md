---
title: 【译】使用puppeteer进行截图对比测试
date: 2018-04-08 10:00
categories: [Node.js]
tags: [Js,技术]
author: Diandian
---

测试是必要的吗？这是我们应该做的。问题是，测试很难，而一个好的测试是难上加难，并且讲真，我并不擅长测试。所以我没有对我的apps进行测试，对此我感到非常内疚，但现在我同样也会阻止你：你不能对Travis感到内疚。如果这听起来很熟悉，那么这篇文章就是为你准备的。
<!-- more -->
我对[Puppeteer](https://github.com/GoogleChrome/puppeteer)做了一些学习研究，对你的app进行截图（比如，你关心的所有路由），然后将他们与核心的一个相比较。如果匹配，那么你的测试就通过了！但是，这只适用于chrome。其实这不是单元测试。实际上，你不知道他只是计算了像素。它将它们看做是宽和窄的视口大小，其实有测试总比没有测试好，和我一起加油吧。

Puppeteer是一个可以让你控制Chrome的npm库。你知道，就像一个傀儡。尤其是，Puppeteer可以非常容易地获取屏幕截图（并点击页面的内容）。这不亚于令人不喜欢的Selenium，并且写起来又很麻烦。

这篇文章看起来很长，所以我已经放好了所有的代码，这样你就可以复制粘贴了。如果你已经知道如何测试了，那么可以直接跳到代码部分。

### Npm部分

如果你想用Puppeteer测试，你必须为测试设置一些东西，也就是一个能启动网站的服务器，然后Puppeteer去查找你的那个网站。我在我的package.json中用这样的内容来解决这些问题：

```
"devDependencies": {
  "chai": "^4.1.2",
  "mocha": "^5.0.0",
  "puppeteer": "^1.0.0",
  "pixelmatch": "^4.0.2",
  "polyserve": "^0.23.0"
}

```

说明：

* 我选择Mocha/Chai进行测试，是因为我习惯用这个。你也可以直接用你喜欢的测试框架；我认为这不重要。
* [Pixelmatch](https://github.com/mapbox/pixelmatch)是用来对两张图像进行比较，并且会告诉你像素级的差异。这个非常棒🏆。
* [Polyserve](https://github.com/Polymer/polyserve)是我用作本地服务器的东西。你也可以用python或者Express或者任意你喜欢的。我会在代码中之处它是Polyserve特有的（字面上是两行），你可以在那里分享你最喜欢的服务器。

### 设置你的测试
为了告诉Puppeteer去调查你的网站，你需要：

1.  开启测试组件
2.  建立一个本地服务器
3.  并在每个测试中告诉Puppeteer要做些什么

我的设置如下所示：
```
const puppeteer = require('puppeteer');
const expect = require('chai').expect;
const {startServer} = require('polyserve');

describe('👀 screenshots are correct', function() {
  let polyserve, browser, page;

  // 组件启动时运行.
  before(async function() {
    // 这里你可以用 python 或 Express等服务器替代。
    polyserve = await startServer({port:4000});

    // 根据需要创建测试目录. 这个和 goldenDir
    // 变量是全局变量
    if (!fs.existsSync(testDir)) fs.mkdirSync(testDir);

    // 和宽屏幕和小屏幕的子目录
    if (!fs.existsSync(`${testDir}/wide`)) fs.mkdirSync(`${testDir}/wide`);
    if (!fs.existsSync(`${testDir}/narrow`)) fs.mkdirSync(`${testDir}/narrow`);
  });

  // 组件跑完时它会停止运行。在这里停止服务器。
  after((done) => polyserve.close(done));

  //这是每次测试之前运行的。这是你开始一个干净的浏览器的地方。 
  beforeEach(async function() {
    browser = await puppeteer.launch();
    page = await browser.newPage();
  });

  // 这里每次测试运行后都会做清理。
  afterEach(() => browser.close());

  // 宽屏幕测试！
  describe('wide screen', function() {
    beforeEach(async function() {
      return page.setViewport({width: 800, height: 600});
    });
    it('/view1', async function() {
      return takeAndCompareScreenshot(page, 'view1', 'wide');
    });
    // 你的其他路由, 404, 等.
  });

  // 窄屏幕测试是相同的，但是具有不同的视口。
  describe('narrow screen', function() {
    beforeEach(async function() {
      return page.setViewport({width: 375, height: 667});
    });
    it('/view1', async function() {
      return takeAndCompareScreenshot(page, 'view1', 'narrow');
    });
    // 你的其他路由, 404, 等.
  });
});
```

顺便说下，你可以测试各种各样的东西。Puppeteer能让你和页面交互（点击按钮，链接等）所以也许你想在截图之前触发不同的用户界面状态（比如窄视图，打开导航栏）。

### 提交
所有复杂的工作（其实也不是很复杂）是在takeAndCompareScreenshot中完成：

```
// - 页面是对Puppeteer页面的引用.
// - 路由是你正在加载的路径，我用它来命名文件。
// - filePrefix不是宽就是窄，因为我自动测试两者。
async function takeAndCompareScreenshot(page, route, filePrefix) {
  // 如果你没有指定文件，请使用路由名称
  let fileName = filePrefix + '/' + (route ? route : 'index');

  // 启动浏览器，进入页面并截图
  await page.goto(`http://127.0.0.1:4000/${route}`);
  await page.screenshot({path: `${testDir}/${fileName}.png`});

  // 测试以查看是否正确
  return compareScreenshots(fileName);
}
```

### 获取截图

这个很简单。用不同的测试组件（只要确保每次运行测试时不要运行它）然后针对所有正在测试的路由运行`page.goto`和`page.screenshot`。我建议你也做视口大小的区别，免费获取宽屏幕和窄屏幕（这里我只使用视口大小，因为我的app工作原理就是这样。Puppeteer可以让你做[设备仿真](https://github.com/GoogleChrome/puppeteer/blob/master/docs/api.md#pageemulateoptions)和其他的用处，只需要查阅文档就好了）把所有的截图丢到一个地方；我把我的房子一个名叫`test/screenshots-golden`的文件夹中。

### 对比差异

这是compareScreenshots中的逻辑，它基本上直接出自[Pixelmatch文档](https://github.com/mapbox/pixelmatch#nodejs)：

```
function compareScreenshots(fileName) {
  return new Promise((resolve, reject) => {
    const img1 = fs.createReadStream(`${testDir}/${fileName}.png`).pipe(new PNG()).on('parsed', doneReading);
    const img2 = fs.createReadStream(`${goldenDir}/${fileName}.png`).pipe(new PNG()).on('parsed', doneReading);

    let filesRead = 0;
    function doneReading() {
      // 等到两个文件都被读取.
      if (++filesRead < 2) return;

      // 这些文件大小应该是相同的
      expect(img1.width, 'image widths are the same').equal(img2.width);
      expect(img1.height, 'image heights are the same').equal(img2.height);

      // 做视觉差异
      const diff = new PNG({width: img1.width, height: img2.height});
      const numDiffPixels = pixelmatch(
          img1.data, img2.data, diff.data, img1.width, img1.height,
          {threshold: 0.1});

      // 这些文件看起来应该是一样的。
      expect(numDiffPixels, 'number of different pixels').equal(0);
      resolve();
    }
  });
}
```

### 一切都是值得的

现在，当你运行你的测试（mocha测试/--我的例子是超时5000），你会得到这样的结果：

![](/images/2018-04-08-automatic-visual-diffing-with-puppeteer/1.png)

如果失败，你会得到一个错误以及你丢失的像素数量。

⭐️

现在，用这个指引来测试你要测试的东西吧，用你狗狗的照片感谢我。（译者表示最后一句啥意思。。）





原文：[Automatic visual diffing with Puppeteer](https://meowni.ca/posts/2017-puppeteer-tests/)

作者：[Monica](https://meowni.ca/about/)

译者：[Diandian](https://futu.im/author/Diandian)
