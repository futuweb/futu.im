---
title: git merge 和 git rebase
date: 2018-05-02 16:26:45
category: 原创
tags: [git, 技术]
author: WillWang
---

在使用 `git` 进行版本管理的项目中，当完成一个特性的开发并将其合并到 `master` 分支时，我们有两种方式：`git merge` 和 `git rebase`。通常，我们对 `git merge` 使用的较多，而对于 `git rebase` 使用的较少，其实 `git rebase` 也是极其强大的一种方法。下面我们就来讲一讲 `git merge` 和 `git rebase` 的差别和在实际的使用。

<!-- more -->

# 准备工作

为了更好地观察执行 `git merge` 和 `git rebase` 之后发生的现象，我们首先来做一些准备工作，即创建一个项目仓库，然后在其中构建两条分支，再增加几次提交。

具体如下：

1. 创建一个目录 `gitTest`
2. 在目录 `myTest` 中新建一个文件 `readme.md`，随便添加一个标题，和第一个列表项 `add master1` 并提交到本地仓库
3. 在当前分支的基础上新建一条分支，名为 `feature`，将列表项 `add master1` 修改为 `add feature1` 并提交到本地仓库
4. 随后切换到分枝 `master` 上添加一个新的列表项 `add master2` 并提交到本地仓库
5. 随后切换到分枝 `feature` 上添加一个新的列表项 `add feature2` 并提交到本地仓库
6. 重复上面的步骤 4 和 5，直至在 `master` 和 `feature` 上各添加了 4 条列表项

此时你的仓库分支提交的记录看起来应该是这样的：

![初始分支提交记录](/images/2018-05-02-git-rebase-and-git-merge-in-practice/init_branch_log.png)

初始 `master` 分支内容应该是这样的：

![初始 master 分支内容](/images/2018-05-02-git-rebase-and-git-merge-in-practice/init_master_branch.png)

初始 `feature` 分支内容应该是这样的：

![初始 feature 分支内容](/images/2018-05-02-git-rebase-and-git-merge-in-practice/init_feature_branch.png)

# git merge

从目录 `gitTest` 拷贝出一份来，命名为 `gitMerge` 来进行我们的合并操作。

`git merge` 的使用方法很简单，假如你想将分支 `feature` 合并到分支 `master`，那么只需执行如下两步即可：

- 将分支切换到 `master` 上去：`git checkout master`
- 将分支 `feature` 合并到当前分支（即 `master` 分支）上：`git merge feature`

通常，`git merge` 有如下特点：

- 只处理一次冲突
- 引入了一次合并的历史记录，合并后的所有 `commit` 会按照提交时间从旧到新排列
- 所有的过程信息更多，可能会提高之后查找问题的难度

为什么讲 `git merge` 提交的信息过多可能会影响查找问题的难度呢？因为在一个大型项目中，单纯依靠 `git merge` 方法进行合并，会保存所有的提交过程的信息：引出分支，合并分支，在分支上再引出新的分支等等，类似这样的操作一多，提交历史信息就会显得杂乱，这时如果有问题需要查找就会比较困难了。

使用 `git merge` 之后的分支提交记录如下：

![使用 `git merge` 之后的分支提交记录](/images/2018-05-02-git-rebase-and-git-merge-in-practice/git_merge.png)

# git rebase

## git rebase 的合并操作

与 `git merge` 一致，`git rebase` 的目的也是将一个分支的更改并入到另外一个分支中去。他的主要特点如下：

- 改变当前分支从 `master` 上拉出分支的位置
- 没有多余的合并历史的记录，且合并后的 `commit` 顺序不一定按照 `commit` 的提交时间排列
- 可能会多次解决同一个地方的冲突（有 `squash` 来解决）
- 更清爽一些，`master` 分支上每个 `commit` 点都是相对独立完整的功能单元

那么我们现在来具体操作一下，看看 `git rebase` 是如何做的。

首先，和 `git merge` 不同的是，你需要在 `feature` 分支上进行 `git rebase master` 的操作，意味着让当前分支 `feature` 相对于 分支 `master` 进行变基：

![在 feature 分支上执行 `git rebase`](/images/2018-05-02-git-rebase-and-git-merge-in-practice/git_rebase_1.png)

可以看出，我们遇到了冲突，进行对比的双方分别是 `master` 分支的最新内容和 `feature` 分支的第一次提交的内容，上图下方红框内容告诉我们，在我们解决了冲突之后，需要执行 `git rebase --continue` 来继续变基的操作。

在解决冲突之后执行 `git rebase --continue` 时遇到了提示，看来我们首先需要把我们的修改存到暂存区，随后再执行 `git rebase --continue`。执行之后又遇到了冲突，这次是与 `feature` 分支的第二次提交进行对比出现的冲突，意味着我们需要多次解决同一个地方的冲突。

![进行 `git rebase --continue`](/images/2018-05-02-git-rebase-and-git-merge-in-practice/git_rebase_2.png)

继续重复先解决冲突，再 `git rebase --comtinue` 的步骤，直到遇到：

![完成 `git rebase --continue`](/images/2018-05-02-git-rebase-and-git-merge-in-practice/git_rebase_3.png)

意味着完成了 `feature` 最后一次提交的变基操作，至此整个变基就完成了。

再来看看执行 `git rebase` 之后的 `feature` 分支：

![完成 `git rebase --continue`的 feature](/images/2018-05-02-git-rebase-and-git-merge-in-practice/git_rebase_4.png)

完全符合上面所说的执行 `git rebase` 的特点，我们引出 `feature` 分支的位置变了，没有多余的提交历史，且提交的时序也改变了，另外回忆一下，在我们执行变基的过程中也多次解决了同一个地方的冲突。

这个时候我们再切换到 `master` 分支上，将 `feature` 分支合并进来。

![完成 `git rebase`后再merge](/images/2018-05-02-git-rebase-and-git-merge-in-practice/git_rebase_5.png)

看得出来，`feature` 分支上的所有提交信息都会被合并到 `master` 分支上了，这些信息对我们来说不是必要的，我们在 `masetr` 分支上往往只需要知道合并进来了什么新的功能即可，这些多余的信息可以通过 `git rebase` 的交互模式进行整合，下一节会讲到这个。

## git rebase 的交互模式

打开变基的交互模式只需要传入一个参数 `-i` 即可，同时还需要指定对哪些提交进行处理，如：

```bash
git rebase -i HEAD~4
```

上述命令指定了对当前分支的最近四次提交进行操作。下面我们使用上面这行命令将 `feature` 分支的提交合并。

![head rebase](/images/2018-05-02-git-rebase-and-git-merge-in-practice/git_rebase_6.png)

中间红框内有一些命令，可以用来处理某次提交的，此处我们使用 `squash` 来将所有的 `commit` 合并成一次提交，编辑并保存之后会出现编辑提交的信息的提示，编辑提交即可。

此时再看 `feature` 分支上的提交记录，会看到只有一次提交了。

![squash](/images/2018-05-02-git-rebase-and-git-merge-in-practice/git_rebase_7.png)

此时无论是直接将分支合并到 `master` 还是先变基再合并，`master` 分支上的提交记录都会十分清爽了。
