---
title: 深入git
date: 2020-06-28 21:36:13
categories: code
tags:
  - git
  - 深入
---

## 文件结构

当使用`git init`创建一个新的仓库时，Git 会创建一个`.git`目录。目录结构如下：

```shell
HEAD
config
description
hooks/
index
info/
objects/
refs/
```

- HEAD 当前被检出分支的指针
- config 项目特有的配置
- description 描述文件
- hooks 钩子脚本
- index 保存暂存区信息，在首次`git add`后才会生成
- info 包含一个全局性排除文件
- objects 存储所有数据内容
- refs 所有分支的提交对象的指针

## 对象结构

Git 是一个内容寻址文件系统。其核心部分时一个简单的键值对数据库。你可以想 Git 仓库插入任意类型的内容，它会返回一个唯一的键，通过该键可以在任意时刻再次取回内容。

Git 有数据对象（blob），树对象（tree）

### blob

每个文件的数据内容以二进制的形式存储在 Git 仓库中，我们可以使用命令`git hash-object -w <file>`的方式，手动向 git 数据库中插入该数据（即在`.git/objects`目录下，写入该对象），而它只会返回存储在 Git 仓库的唯一键。此命令输出一个长度为 40 的 sha1 哈希值，前 2 位字符用于命名子目录，后 38 位则用作文件名
例如：

```shell
$ find .git/objects/ -type f
$ echo 'test content' |git hash-object -w --stdin
d670460b4b4aece5915caf5c68d12f560a9fe3e4
$ find .git/objects/ -type f
.git/objects/d6/70460b4b4aece5915caf5c68d12f560a9fe3e4
$ git cat-file -p d670460b4b4aece5915caf5c68d12f560a9fe3e4
test content
```

> git 使用 sha1 时，在可区分唯一 sha1 时最少可只用前四位就可以

一开始`.git/objects`下没有存储任何数据对象，当我们使用`git hash-object`命令存入一条内容时，可以观察到`.git.objects`目录下，生成了 sha1 相对应的子目录和文件名。通过`git cat-file -p <sha1>`查看数据对象时，我们可以看到之前存入的文本内容

我们使用`git add <file>`时，就是 Git 内部做了`git hash-object`的命令，将`<file>`的内容存入到`.git/objects`中。

```shell
$ echo 'version 1' > 1.txt
$ git add .
$ find .git/objects/ -type f
.git/objects/d6/70460b4b4aece5915caf5c68d12f560a9fe3e4
.git/objects/83/baae61804e65cc73a7201a7252750c76066a30
$ git cat-file -p 83baae
```

使用`git add`后，我们可以看到`index`文件的生成

```shell
$ find .git/ -type f
...
.git/objects/d6/70460b4b4aece5915caf5c68d12f560a9fe3e4
.git/objects/83/baae61804e65cc73a7201a7252750c76066a30
.git/index
# 查看index内容
$ git ls-files --stage
100644 83baae61804e65cc73a7201a7252750c76066a30 0 1.txt
```

我们可以看到 index 保存了工作区 add 的 blob 对象的 sha1

blob 对象是针对数据内容的，不区分文件

例如：

```shell
$ echo 'version 1' > 2.txt
$ git add 2.txt
$ find .git/objects/ -type f
# 可以看到blob对象并没有增加
.git/objects/d6/70460b4b4aece5915caf5c68d12f560a9fe3e4
.git/objects/83/baae61804e65cc73a7201a7252750c76066a
$ git ls-files --stage
100644 83baae61804e65cc73a7201a7252750c76066a30 0 1.txt
100644 83baae61804e65cc73a7201a7252750c76066a30 0 2.txt

```

### tree

Git 以一种类似于 UNIX 文件系统的方式存储内容，但作了些许简化。 所有内容均以树对象和数据对象的形式存储，其中树对象对应了 UNIX 中的目录项，数据对象则大致上对应了 inodes 或文件内容。 一个树对象包含了一条或多条树对象记录（tree entry），每条记录含有一个指向数据对象或者子树对象的 SHA-1 指针，以及相应的模式、类型、文件名信息。

当我们使用`git commit`后，我们可以看到

```shell

$ git commit -m 'commit 1'
[master (root-commit) 9f1224b] commit 1
 2 files changed, 2 insertions(+)
 create mode 100644 1.txt
 create mode 100644 2.txt

# 查看.git目录
$ find .git/ -type
.git/refs/heads/master
...
.git/objects/d6/70460b4b4aece5915caf5c68d12f560a9fe3e4
.git/objects/83/baae61804e65cc73a7201a7252750c76066a30
.git/objects/1d/49be59d2805f145b66c15641a11e945a5d021a
.git/objects/9f/1224bca340fb2e4235adfa3e42297033c26ec9
.git/index
.git/COMMIT_EDITMSG
...

# 我们可以看到生成了两个新的对象
# tree
$ git cat-file -p 1d49be
100644 blob 83baae61804e65cc73a7201a7252750c76066a30 1.txt
100644 blob 83baae61804e65cc73a7201a7252750c76066a30 2.txt

# commit commit中包含了tree对象的sha1
$ git cat-file -p 9f1224b
tree 1d49be59d2805f145b66c15641a11e945a5d021a
author leaderli <429243408@qq.com> 1593549136 +0800
committer leaderli <429243408@qq.com> 1593549136 +0800

commit 1

# 查看所有对象
$ git cat-file --batch-check --batch-all-objects
1d49be59d2805f145b66c15641a11e945a5d021a tree 66
83baae61804e65cc73a7201a7252750c76066a30 blob 10
9f1224bca340fb2e4235adfa3e42297033c26ec9 commit 163
d670460b4b4aece5915caf5c68d12f560a9fe3e4 blob 13

```

### git gc

当使用`git gc`或者`git push`时，git 会自动将`.git/objects/`下文件进行压缩，在`.git/objects/pack/`下生成`.idx`和`.pack`文件。

## 分支

git 的 commit 是一个有向无环图
查看.git 内的文件可以看到生成了.git/refs.heads/master，可以发现其指向 commit 1

```shell
$ more .git/refs/heads/master
9f1224bca340fb2e4235adfa3e42297033c26ec9
```

我们新增子目录以及子文件，并添加到 stage 区

```shell
$ mkdir dir
$ echo "version 3" > dir/3.txt
$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)

  dir/

nothing added to commit but untracked files present (use "git add" to track)
# 添加到缓存区

$ git add dir/
$ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

  new file:   dir/3.txt
```

### git diff

`git diff --cache`是比较 index 和 HEAD 的差异

```shell
# 我们查看HEAD的内容,发现HEAD指向master的commit 1
$ more .git/HEAD
ref: refs/heads/master
$ more .git/refs/heads/master
9f1224bca340fb2e4235adfa3e42297033c26ec9

# commit 1指向的tree对象的内容为
$ git cat-file  -p 9f1224bca340fb2e4235adfa3e42297033c26ec9
tree 1d49be59d2805f145b66c15641a11e945a5d021a
author leaderli <429243408@qq.com> 1593549136 +0800
committer leaderli <429243408@qq.com> 1593549136 +0800

commit 1
$ git cat-file -p 1d49be59d2805f145b66c15641a11e945a5d021a
100644 blob 83baae61804e65cc73a7201a7252750c76066a30 1.txt
100644 blob 83baae61804e65cc73a7201a7252750c76066a30 2.txt

# index
$ git ls-files -s
100644 83baae61804e65cc73a7201a7252750c76066a30 0 1.txt
100644 83baae61804e65cc73a7201a7252750c76066a30 0 2.txt
100644 7170a5278f42ea12d4b6de8ed1305af8c393e756 0 dir/3.txt

# 使用diff查看差异内容
$ git diff --cached
diff --git a/dir/3.txt b/dir/3.txt
new file mode 100644
index 0000000..7170a52
--- /dev/null
+++ b/dir/3.txt
@@ -0,0 +1 @@
+version 3

```

提交 commit 2

```shell
$ git commit -m 'commit 2'
[master 014901f] commit 2
 1 file changed, 1 insertion(+)
 create mode 100644 dir/3.txt

# HEAD当前执行commit 2
$ more .git/HEAD
ref: refs/heads/master
$ more .git/refs/heads/master
014901f4a370ec3d0db58fc7a4cf9950d2111fbe
$ git cat-file -p 014901f4a370ec3d0db58fc7a4cf9950d2111fbe
tree 162488e047cda08c69e932e81722f7ce191057ee
# commit 2的父节点为commit 1
parent 9f1224bca340fb2e4235adfa3e42297033c26ec9
author leaderli <429243408@qq.com> 1593555980 +0800
committer leaderli <429243408@qq.com> 1593555980 +0800

commit 2

# 查看commit 2 指向的tree
$ git cat-file -p 162488e047cda08c69e932e81722f7ce191057ee
100644 blob 83baae61804e65cc73a7201a7252750c76066a30 1.txt
100644 blob 83baae61804e65cc73a7201a7252750c76066a30 2.txt
040000 tree b57d4c5b3c1f31f87d0d5e7343db0b53f8f650c2 dir

$ git cat-file -p b57d4c5b3c1f31f87d0d5e7343db0b53f8f650c2
100644 blob 7170a5278f42ea12d4b6de8ed1305af8c393e756 3.txt

# HEAD执行的tree和index的一致了
$ git diff --cached
```

从概念上讲，此时 Git 内部存储的数据有点像这样：
![深入git_内部数据存储结构.png](./images/深入git_内部数据存储结构.png)

`git diff <commit1> <commit2>`的原理都是差不多的

### 切换分支

```shell
$ git sw -b dev
Switched to a new branch 'dev'
$ find .git/ -type f
.git/refs/heads/master
.git/refs/heads/dev
# HEAD 指向了dev分支
$ more .git/HEAD
ref: refs/heads/dev

#dev分支指向commit2
$ more .git/refs/heads/dev
014901f4a370ec3d0db58fc7a4cf9950d2111fbe

```
