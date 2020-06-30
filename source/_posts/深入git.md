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
