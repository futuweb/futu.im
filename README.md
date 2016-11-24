# 富途web开发团队博客

## URL

<https://futu.im> 请大力点击、观看、评论、赞、宣传、友情链接、分享……（省略1000个词）

## 程序

使用了著名的静态博客程序[Hexo](https://hexo.io)，写作使用Markdown。

> 所谓静态博客，是指文章在本地编写，然后生成静态html发布，整个网站在发布后是完全静态的，只包含html、js、css、图片等文件，不需要PHP、Node等环境，任意静态空间均可托管。

## 写作开始

### 文艺青年版

参考Hexo[官方文档](https://hexo.io/docs/)，首先需要安装`hexo-cli`：

```sh
npm install -g hexo-cli --registry=http://registry.npm.taobao.org
```

写作文章时，参考[官方文档](https://hexo.io/docs/writing.html)：

1. `hexo server`让hexo在本机跑起来，这样可以通过`http://localhost:4000`进行预览
2. `hexo new title-in-english`新建一篇文章

## 二逼青年版

从`source/_posts`中复制一篇，或者参考格式，自己新建一个`title-in-english.md`文件

## 写作过程

就是写字啊，编辑啊，不停地按退格删除啊，一会复制一下粘贴一下什么的……

注意点：

1. 文章上方的meta信息写清楚，包括作者、时间、分类、tags等
2. 图片放到`source/images`目录下，按文章建立目录，独立存放
3. 每位作者需要一个简介页面，简介带一张照片。放在`source/author`目录下，可以通过文章列表页和文章详情页进入
4. 每篇文章必须设置`<!--more-->`标记，否则会在首页将文章全文显示出来，影响浏览

## 托管和发布

源码托管在Github（<https://github.com/futuweb/futu.im>）上，`master`分支为发布分支。

最终发布后的版本托管在Gitlab.com提供的pages服务上。

向Github仓库推送源代码后，1小时之内Gitlab.com会拉取源代码进行自动编译上线。

## 常见问题

略……请查文档……
